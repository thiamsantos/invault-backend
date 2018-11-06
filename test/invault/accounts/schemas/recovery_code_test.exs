defmodule Invault.Accounts.Schemas.RecoveryCodeTest do
  use Invault.DataCase, async: true

  alias Ecto.UUID
  alias Invault.Accounts.Schemas.RecoveryCode
  alias Invault.Repo

  describe "changeset/2" do
    test "should require totp_secret_id" do
      changeset = RecoveryCode.changeset(%RecoveryCode{}, %{})

      assert changeset.valid? == false

      assert errors_on(changeset) == %{totp_secret_id: ["can't be blank"]}
    end

    test "totp_secret_id should references to a valid record" do
      totp_secret_id = UUID.generate()

      {:error, changeset} =
        %RecoveryCode{}
        |> RecoveryCode.changeset(%{totp_secret_id: totp_secret_id})
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{totp_secret_id: ["does not exist"]}
    end

    test "should work when all fields are valid" do
      totp_secret = insert(:accounts_totp_secret)

      {:ok, %RecoveryCode{} = recovery_code} =
        %RecoveryCode{}
        |> RecoveryCode.changeset(%{totp_secret_id: totp_secret.id})
        |> Repo.insert()

      assert recovery_code.totp_secret_id == totp_secret.id
    end

    test "used_at should be optional" do
      totp_secret = insert(:accounts_totp_secret)
      used_at = DateTime.utc_now()

      attrs = %{
        totp_secret_id: totp_secret.id,
        used_at: used_at
      }

      changeset = RecoveryCode.changeset(%RecoveryCode{}, attrs)

      assert changeset.valid? == true
      assert changeset.changes == attrs
    end
  end
end
