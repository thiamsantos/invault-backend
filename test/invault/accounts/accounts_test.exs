defmodule Invault.AccountsTest do
  use Invault.DataCase, async: true

  alias Ecto.UUID
  alias Invault.Accounts
  alias Invault.Accounts.Schemas.{RecoveryCode, TotpSecret}

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
end
