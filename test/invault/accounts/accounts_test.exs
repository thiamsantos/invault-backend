defmodule Invault.AccountsTest do
  use Invault.DataCase, async: true

  alias Invault.Accounts
  alias Invault.Repo
  alias Invault.Accounts.Schemas.{RecoveryCode, TotpSecret}

  describe "create_totp_secret/0" do
    test "should return a valid secret" do
      %TotpSecret{} = totp_secret = Accounts.create_totp_secret()

      assert Repo.get!(TotpSecret, totp_secret.id).secret == totp_secret.secret
      assert String.length(totp_secret.secret) == 32
    end

    test "should return a list of valid recovery codes" do
      %TotpSecret{} = totp_secret = Accounts.create_totp_secret()

      assert length(totp_secret.recovery_codes) == 6

      for recovery_code <- totp_secret.recovery_codes do
        assert Repo.get!(RecoveryCode, recovery_code.id).code == recovery_code.code
        assert String.length(recovery_code.code) == 44
      end
    end
  end
end
