defmodule Invault.Accounts.Schemas.UserTest do
  use Invault.DataCase, async: true

  alias Ecto.UUID
  alias Invault.Accounts.Schemas.User
  alias Invault.Generator

  describe "changeset/2" do
    test "should be valid with right parameters" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      user =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert!()

      persisted_user = Repo.get!(User, user.id)

      assert persisted_user.name == attrs[:name]
      assert persisted_user.email == attrs[:email]
      assert persisted_user.totp_secret_id == attrs[:totp_secret_id]
      assert persisted_user.identity_verifier_id == attrs[:identity_verifier_id]
    end

    test "email should be required" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["can't be blank"]}
    end

    test "name should be required" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        email: Generator.random_email(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end

    test "totp_secret_id should be required" do
      identity_verifier = insert(:accounts_identity_verifier)

      attrs = %{
        name: Generator.random_name(),
        email: Generator.random_email(),
        identity_verifier_id: identity_verifier.id
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{totp_secret_id: ["can't be blank"]}
    end

    test "identity_verifier_id should be required" do
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        name: Generator.random_name(),
        email: Generator.random_email(),
        totp_secret_id: totp_secret.id
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{identity_verifier_id: ["can't be blank"]}
    end

    test "email should have less than 255 characters" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        email: Generator.random_string(300) <> Generator.random_email(),
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["should be at most 255 character(s)"]}
    end

    test "email should have include an @" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        email: "invault.com",
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["has invalid format"]}
    end

    test "name should have less than 255 characters" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_string(300),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{name: ["should be at most 255 character(s)"]}
    end

    test "email should be unique" do
      email = Generator.random_email()
      insert(:accounts_user, email: email)

      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        email: email,
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      {:error, changeset} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{email: ["has already been taken"]}
    end

    test "totp_secret_id should be unique" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      insert(:accounts_user, totp_secret: totp_secret)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      {:error, changeset} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{totp_secret_id: ["has already been taken"]}
    end

    test "identity_verifier_id should be unique" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      insert(:accounts_user, identity_verifier: identity_verifier)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id
      }

      {:error, changeset} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{identity_verifier_id: ["has already been taken"]}
    end

    test "totp_secret_id should a valid reference" do
      identity_verifier = insert(:accounts_identity_verifier)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_name(),
        totp_secret_id: UUID.generate(),
        identity_verifier_id: identity_verifier.id
      }

      {:error, changeset} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{totp_secret_id: ["does not exist"]}
    end

    test "identity_verifier_id should a valid reference" do
      totp_secret = insert(:accounts_totp_secret)

      attrs = %{
        email: Generator.random_email(),
        name: Generator.random_name(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: UUID.generate()
      }

      {:error, changeset} =
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{identity_verifier_id: ["does not exist"]}
    end

    test "activated_at should be parsed" do
      identity_verifier = insert(:accounts_identity_verifier)
      totp_secret = insert(:accounts_totp_secret)

      activated_at = DateTime.utc_now()

      attrs = %{
        name: Generator.random_name(),
        email: Generator.random_email(),
        totp_secret_id: totp_secret.id,
        identity_verifier_id: identity_verifier.id,
        activated_at: activated_at
      }

      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid? == true
      assert changeset.changes[:activated_at] == activated_at
    end
  end
end
