defmodule Invault.AccountsTest do
  use Invault.DataCase, async: true
  use Bamboo.Test

  import Mox

  alias Ecto.UUID
  alias Invault.CurrentTime.Mock, as: CurrentTimeMock
  alias Invault.CurrentTime.SystemAdapter, as: SystemAdapter
  alias Invault.{Generator, Accounts}
  alias Invault.Accounts.Registration.Request, as: RegistrationRequest
  alias Invault.Accounts.Schemas.{ActivationCode, RecoveryCode, TotpSecret, User}
  alias Invault.Accounts.TOTP
  alias Invault.Accounts.Registration.ActivationEmail

  setup :verify_on_exit!

  describe "create_totp_secret!/0" do
    test "should return a valid secret" do
      {:ok, %TotpSecret{} = totp_secret} = Accounts.create_totp_secret!()

      assert Accounts.get_totp_secret!(totp_secret.id).secret == totp_secret.secret
      assert String.length(totp_secret.secret) == 32
    end

    test "should return a list of valid recovery codes" do
      {:ok, %TotpSecret{} = totp_secret} = Accounts.create_totp_secret!()

      assert length(totp_secret.recovery_codes) == 6

      for recovery_code <- totp_secret.recovery_codes do
        persisted_recovery_code = Accounts.get_recovery_code!(recovery_code.id)

        assert persisted_recovery_code.used_at == nil
        assert persisted_recovery_code.totp_secret_id == totp_secret.id
      end
    end
  end

  describe "get_recovery_code!/1" do
    test "should return a recovery code" do
      recovery_code = insert(:accounts_recovery_code)
      id = recovery_code.id

      assert %RecoveryCode{id: ^id} = Accounts.get_recovery_code!(id)
    end

    test "should raise an error in case the recovery code does not exist" do
      id = UUID.generate()

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_recovery_code!(id)
      end
    end
  end

  describe "get_totp_secret!/1" do
    test "should return a totp secret" do
      totp_secret = insert(:accounts_totp_secret)
      id = totp_secret.id

      assert %TotpSecret{id: ^id} = Accounts.get_totp_secret!(id)
    end

    test "should raise an error in case the totp secret does not exist" do
      id = UUID.generate()

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_totp_secret!(id)
      end
    end
  end

  describe "register/1 with valid attributes" do
    setup do
      totp_secret = insert(:accounts_totp_secret)
      email = Generator.random_email()

      password = Generator.random_string(64)
      identity_verifier = email |> SRP.new_identity(password) |> SRP.generate_verifier()

      request = %RegistrationRequest{
        name: Generator.random_name(),
        email: email,
        totp_secret_id: totp_secret.id,
        totp_code: TOTP.generate_totp_code(totp_secret.secret),
        salt: Base.encode64(identity_verifier.salt),
        password_verifier: Base.encode64(identity_verifier.password_verifier)
      }

      %{request: request}
    end

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
        Repo.get!(User, user.id)
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
    test "should return error when email was already used"
    test "should return error when name has more than 255 characters"
    test "should return error when email has more than 256 characters"
    test "should return error when email does not have a @"
    test "should return error when salt does not have 44 characters"
    test "should return error when password verifier does not have 344 characters"
    test "should return error when totp secret id does not exists"
    test "should return error when given totp code is invalid"
    test "should return error when totp secret id is not unique on users table"
    test "should rollback the transaction case occurs an error"
  end
end
