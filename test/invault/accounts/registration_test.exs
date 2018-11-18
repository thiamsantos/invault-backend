defmodule Invault.Accounts.RegistrationTest do
  use Invault.DataCase, async: true
  use Bamboo.Test

  import Mox

  alias Ecto.UUID
  alias Invault.{Accounts, Generator}
  alias Invault.Accounts.Registration.{ActivationEmail, Request}
  alias Invault.Accounts.Schemas.{ActivationCode, IdentityVerifier, TotpSecret, User}
  alias Invault.Accounts.TOTP
  alias Invault.CurrentTime.Mock, as: CurrentTimeMock
  alias Invault.CurrentTime.SystemAdapter, as: SystemAdapter

  setup do
    verify_on_exit!()
    totp_secret = insert(:accounts_totp_secret)
    email = Generator.random_email()

    password = Generator.random_string(64)
    identity_verifier = email |> SRP.new_identity(password) |> SRP.generate_verifier()

    request = %Request{
      name: Generator.random_name(),
      email: email,
      totp_secret_id: totp_secret.id,
      totp_code: TOTP.generate_totp_code(totp_secret.secret),
      salt: Base.encode64(identity_verifier.salt),
      password_verifier: Base.encode64(identity_verifier.password_verifier)
    }

    %{request: request}
  end

  describe "register/1 with valid attributes" do
    test "should store the user on the database", %{request: request} do
      stub_with(CurrentTimeMock, SystemAdapter)
      {:ok, %User{} = user} = Accounts.register(request)

      persisted_user = Repo.get!(User, user.id)
      assert persisted_user.name == request.name
      assert persisted_user.email == request.email
      assert persisted_user.totp_secret_id == request.totp_secret_id
    end

    test "should store the identity verifier", %{request: request} do
      stub_with(CurrentTimeMock, SystemAdapter)
      {:ok, %User{} = user} = Accounts.register(request)

      persisted_identity_verifier =
        User
        |> Repo.get!(user.id)
        |> Repo.preload(:identity_verifier)
        |> Map.get(:identity_verifier)

      assert persisted_identity_verifier.salt == request.salt
      assert persisted_identity_verifier.password_verifier == request.password_verifier
    end

    test "should generate an activation token that expires in a week", %{request: request} do
      now = DateTime.utc_now()
      expect(CurrentTimeMock, :utc_now, fn -> now end)

      {:ok, %User{} = user} = Accounts.register(request)

      persisted_activation_code = Repo.get_by!(ActivationCode, user_id: user.id)
      assert persisted_activation_code.expires_at == Timex.shift(now, days: 7)
    end

    test "should send an activation email", %{request: request} do
      now = DateTime.utc_now()
      expect(CurrentTimeMock, :utc_now, fn -> now end)

      {:ok, %User{} = user} = Accounts.register(request)
      activation_code = Repo.get_by!(ActivationCode, user_id: user.id)

      email =
        ActivationEmail.create(%{
          name: request.name,
          email: request.email,
          activation_code: activation_code.id
        })

      assert_delivered_email email
    end
  end

  describe "register/1 with invalid attributes" do
    test "should return error when email was already used", %{request: request} do
      insert(:accounts_user, email: request.email)

      assert {:error, changeset} = Accounts.register(request)
      assert errors_on(changeset) == %{email: ["has already been taken"]}

      assert Repo.get_by(IdentityVerifier, salt: request.salt) == nil
      assert Repo.get_by(User, name: request.name) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when totp secret id does not exists", %{request: request} do
      invalid_request = %{request | totp_secret_id: UUID.generate()}

      assert {:error, error} = Accounts.register(invalid_request)

      assert error == %{
               totp_secret_id: [validation: :invalid_reference, message: "does not exist"]
             }

      assert Repo.get_by(IdentityVerifier, salt: invalid_request.salt) == nil
      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when name has more than 255 characters", %{request: request} do
      invalid_request = %{request | name: Generator.random_string(300)}

      assert {:error, changeset} = Accounts.register(invalid_request)
      assert errors_on(changeset) == %{name: ["should be at most 255 character(s)"]}

      assert Repo.get_by(IdentityVerifier, salt: invalid_request.salt) == nil
      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when email has more than 255 characters", %{request: request} do
      invalid_request = %{
        request
        | email: Generator.random_string(300) <> Generator.random_email()
      }

      assert {:error, changeset} = Accounts.register(invalid_request)
      assert errors_on(changeset) == %{email: ["should be at most 255 character(s)"]}

      assert Repo.get_by(IdentityVerifier, salt: invalid_request.salt) == nil
      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when email does not have a @", %{request: request} do
      invalid_request = %{request | email: "notaemail.example.com"}

      assert {:error, changeset} = Accounts.register(invalid_request)
      assert errors_on(changeset) == %{email: ["has invalid format"]}

      assert Repo.get_by(IdentityVerifier, salt: invalid_request.salt) == nil
      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when salt does not have 44 characters", %{request: request} do
      invalid_request = %{request | salt: Generator.random_string(50)}

      assert {:error, changeset} = Accounts.register(invalid_request)
      assert errors_on(changeset) == %{salt: ["should be 44 character(s)"]}

      assert Repo.get_by(IdentityVerifier, salt: invalid_request.salt) == nil
      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when password verifier does not have 344 characters", %{
      request: request
    } do
      invalid_request = %{request | password_verifier: Generator.random_string(350)}

      assert {:error, changeset} = Accounts.register(invalid_request)
      assert errors_on(changeset) == %{password_verifier: ["should be 344 character(s)"]}

      assert Repo.get_by(IdentityVerifier, salt: invalid_request.salt) == nil
      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when given totp code is invalid", %{request: request} do
      another_totp_secret = insert(:accounts_totp_secret)
      wrong_totp_code = TOTP.generate_totp_code(another_totp_secret.secret)
      invalid_request = %{request | totp_code: wrong_totp_code}

      assert {:error, error} = Accounts.register(invalid_request)
      assert error == %{totp_code: [validation: :invalid, message: "Invalid TOTP code"]}

      assert Repo.get_by(IdentityVerifier, salt: invalid_request.salt) == nil
      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when totp secret id is not unique on users table", %{
      request: request
    } do
      totp_secret = Repo.get!(TotpSecret, request.totp_secret_id)
      insert(:accounts_user, totp_secret: totp_secret)

      assert {:error, changeset} = Accounts.register(request)
      assert errors_on(changeset) == %{totp_secret_id: ["has already been taken"]}

      assert Repo.get_by(IdentityVerifier, salt: request.salt) == nil
      assert Repo.get_by(User, email: request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end
  end
end
