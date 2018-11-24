defmodule Invault.Accounts.RegistrationTest do
  use Invault.DataCase, async: true
  use Bamboo.Test

  import Mox

  alias Invault.{Accounts, Generator, SecurePassword}
  alias Invault.Accounts.Registration.{ActivationEmail, Request}
  alias Invault.Accounts.Schemas.{ActivationCode, User}
  alias Invault.CurrentTime.Mock, as: CurrentTimeMock
  alias Invault.CurrentTime.SystemAdapter, as: SystemAdapter

  @pepper :invault
          |> Application.fetch_env!(Invault.Accounts.Registration)
          |> Keyword.fetch!(:pepper)

  setup do
    verify_on_exit!()

    request = %Request{
      name: Generator.random_name(),
      email: Generator.random_email(),
      password: Generator.random_string(64)
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

      assert SecurePassword.valid?(persisted_user.password_digest, request.password, @pepper) ==
               true
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

      assert Repo.get_by(User, name: request.name) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when name has more than 255 characters", %{request: request} do
      invalid_request = %{request | name: Generator.random_string(300)}

      assert {:error, changeset} = Accounts.register(invalid_request)
      assert errors_on(changeset) == %{name: ["should be at most 255 character(s)"]}

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

      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end

    test "should return error when email does not have a @", %{request: request} do
      invalid_request = %{request | email: "notaemail.example.com"}

      assert {:error, changeset} = Accounts.register(invalid_request)
      assert errors_on(changeset) == %{email: ["has invalid format"]}

      assert Repo.get_by(User, email: invalid_request.email) == nil
      assert Repo.all(ActivationCode) == []
      assert_no_emails_delivered()
    end
  end
end
