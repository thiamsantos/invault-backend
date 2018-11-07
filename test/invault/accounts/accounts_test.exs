defmodule Invault.AccountsTest do
  use Invault.DataCase, async: true

  alias Invault.Accounts
  alias Invault.Repo
  alias Invault.Accounts.Schemas.{RecoveryCode, TotpSecret}

  describe "create_totp_secret!/0" do
    test "should return a valid secret" do
      {:ok, %TotpSecret{} = totp_secret} = Accounts.create_totp_secret!()

      assert Repo.get!(TotpSecret, totp_secret.id).secret == totp_secret.secret
      assert String.length(totp_secret.secret) == 32
    end

    test "should return a list of valid recovery codes" do
      {:ok, %TotpSecret{} = totp_secret} = Accounts.create_totp_secret!()

      assert length(totp_secret.recovery_codes) == 6

      for recovery_code <- totp_secret.recovery_codes do
        persisted_recovery_code = Repo.get!(RecoveryCode, recovery_code.id)

        assert persisted_recovery_code.used_at == nil
        assert persisted_recovery_code.totp_secret_id == totp_secret.id
      end
    end
  end
end
