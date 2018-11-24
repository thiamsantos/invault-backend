defmodule Invault.Accounts.Schemas.UserTest do
  use Invault.DataCase, async: true

  alias Invault.Accounts.Schemas.User
  alias Invault.{Generator, SecurePassword}

  describe "changeset/2" do
    test "should be valid with right parameters" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_name(),
        password_digest: SecurePassword.digest(password, pepper)
      }

      user =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert!()

      persisted_user = Repo.get!(User, user.id)

      assert persisted_user.name == attrs[:name]
      assert persisted_user.email == attrs[:email]
      assert persisted_user.password_digest == attrs[:password_digest]
    end

    test "email should be required" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      attrs = %{
        name: Generator.random_name(),
        password_digest: SecurePassword.digest(password, pepper)
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["can't be blank"]}
    end

    test "name should be required" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      attrs = %{
        email: Generator.random_email(),
        password_digest: SecurePassword.digest(password, pepper)
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end

    test "password_digest should be required" do
      attrs = %{
        name: Generator.random_name(),
        email: Generator.random_email()
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{password_digest: ["can't be blank"]}
    end

    test "email should have less than 255 characters" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      attrs = %{
        email: Generator.random_string(300) <> Generator.random_email(),
        name: Generator.random_name(),
        password_digest: SecurePassword.digest(password, pepper)
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["should be at most 255 character(s)"]}
    end

    test "email should have include an @" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      attrs = %{
        email: "invault.com",
        name: Generator.random_name(),
        password_digest: SecurePassword.digest(password, pepper)
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["has invalid format"]}
    end

    test "name should have less than 255 characters" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_string(300),
        password_digest: SecurePassword.digest(password, pepper)
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{name: ["should be at most 255 character(s)"]}
    end

    test "password digest should have less 128 characters" do
      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_name(),
        password_digest: Generator.random_string(64)
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{password_digest: ["should be 128 character(s)"]}
    end

    test "email should be unique" do
      email = Generator.random_email()
      insert(:accounts_user, email: email)

      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      attrs = %{
        email: email,
        name: Generator.random_name(),
        password_digest: SecurePassword.digest(password, pepper)
      }

      {:error, changeset} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["has already been taken"]}
    end

    test "activated_at should be parsed" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      activated_at = DateTime.utc_now()

      attrs = %{
        name: Generator.random_name(),
        email: Generator.random_email(),
        password_digest: SecurePassword.digest(password, pepper),
        activated_at: activated_at
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == true
      assert changeset.changes[:activated_at] == activated_at
    end
  end
end
