defmodule Invault.Accounts.Schemas.RecoveryCodeTest do
  use Invault.DataCase, async: true

  alias Ecto.UUID
  alias Invault.Repo
  alias Invault.Accounts.Schemas.RecoveryCode

  describe "changeset/2" do
    test "should require code and totp_secret_id" do
      changeset = RecoveryCode.changeset(%RecoveryCode{}, %{})

      assert changeset.valid? == false

      assert errors_on(changeset) == %{
               code: ["can't be blank"],
               totp_secret_id: ["can't be blank"]
             }
    end

    test "totp_secret_id should references to a valid record" do
      code = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64()
      totp_secret_id = UUID.generate()

      {:error, changeset} =
        %RecoveryCode{}
        |> RecoveryCode.changeset(%{code: code, totp_secret_id: totp_secret_id})
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{totp_secret_id: ["does not exist"]}
    end

    test "code should be unique" do
      code = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64()

      totp_secret = insert(:accounts_totp_secret)
      insert(:accounts_recovery_code, code: code)

      {:error, changeset} =
        %RecoveryCode{}
        |> RecoveryCode.changeset(%{code: code, totp_secret_id: totp_secret.id})
        |> Repo.insert()

      assert changeset.valid? == false
      assert errors_on(changeset) == %{code: ["has already been taken"]}
    end

    test "should work when all fields are valid" do
      code = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64()
      totp_secret = insert(:accounts_totp_secret)

      {:ok, %RecoveryCode{} = recovery_code} =
        %RecoveryCode{}
        |> RecoveryCode.changeset(%{code: code, totp_secret_id: totp_secret.id})
        |> Repo.insert()

      assert recovery_code.code == code
      assert recovery_code.totp_secret_id == totp_secret.id
    end

    test "should return an error if code has less than 44 characters" do
      totp_secret = insert(:accounts_totp_secret)

      changeset =
        RecoveryCode.changeset(%RecoveryCode{}, %{code: "12344", totp_secret_id: totp_secret.id})

      assert changeset.valid? == false
      assert errors_on(changeset) == %{code: ["should be 44 character(s)"]}
    end

    test "should return an error if code has more than 44 characters" do
      code = 80 |> :crypto.strong_rand_bytes() |> Base.url_encode64()

      totp_secret = insert(:accounts_totp_secret)

      changeset =
        RecoveryCode.changeset(%RecoveryCode{}, %{code: code, totp_secret_id: totp_secret.id})

      assert changeset.valid? == false
      assert errors_on(changeset) == %{code: ["should be 44 character(s)"]}
    end

    test "used_at should be optional" do
      code = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64()
      totp_secret = insert(:accounts_totp_secret)
      used_at = DateTime.utc_now()

      attrs = %{
        code: code,
        totp_secret_id: totp_secret.id,
        used_at: used_at
      }

      changeset = RecoveryCode.changeset(%RecoveryCode{}, attrs)

      assert changeset.valid? == true
      assert changeset.changes == attrs
    end
  end
end
