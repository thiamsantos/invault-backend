defmodule Invault.Accounts.Schemas.ActivationCodeTest do
  use Invault.DataCase, async: true

  alias Ecto.UUID
  alias Invault.Accounts.Schemas.ActivationCode

  describe "changeset/2" do
    test "should be valid with right parameters" do
      user = insert(:accounts_user)

      attrs = %{
        expires_at: DateTime.utc_now() |> Timex.shift(days: 7),
        user_id: user.id
      }

      activation_code =
        %ActivationCode{}
        |> ActivationCode.changeset(attrs)
        |> Repo.insert!()

      persisted_activation_code = Repo.get!(ActivationCode, activation_code.id)

      assert persisted_activation_code.expires_at == attrs[:expires_at]
      assert persisted_activation_code.user_id == attrs[:user_id]
    end

    test "user_id should be required" do
      attrs = %{
        expires_at: DateTime.utc_now() |> Timex.shift(days: 7)
      }

      changeset = ActivationCode.changeset(%ActivationCode{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{user_id: ["can't be blank"]}
    end

    test "expires_at should be required" do
      user = insert(:accounts_user)

      attrs = %{
        user_id: user.id
      }

      changeset = ActivationCode.changeset(%ActivationCode{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{expires_at: ["can't be blank"]}
    end

    test "user_id should be a valid reference" do
      attrs = %{
        expires_at: DateTime.utc_now() |> Timex.shift(days: 7),
        user_id: UUID.generate()
      }

      {:error, changeset} =
        %ActivationCode{}
        |> ActivationCode.changeset(attrs)
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{user_id: ["does not exist"]}
    end

    test "used_at should be casted" do
      user = insert(:accounts_user)

      attrs = %{
        expires_at: DateTime.utc_now() |> Timex.shift(days: 7),
        user_id: user.id,
        used_at: DateTime.utc_now() |> Timex.shift(hours: 1)
      }

      changeset = ActivationCode.changeset(%ActivationCode{}, attrs)

      assert changeset.valid? == true
      assert changeset.changes == attrs
    end
  end
end
