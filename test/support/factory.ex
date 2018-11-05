defmodule Invault.Factory do
  use ExMachina.Ecto, repo: Invault.Repo

  alias Invault.Accounts.Schemas.{TotpSecret, RecoveryCode}

  def accounts_totp_secret_factory do
    secret = 20 |> :crypto.strong_rand_bytes() |> Base.encode32()

    %TotpSecret{
      secret: secret
    }
  end

  def accounts_recovery_code_factory do
    code = 32 |> :crypto.strong_rand_bytes() |> Base.url_encode64()
    totp_secret = build(:accounts_totp_secret)

    %RecoveryCode{
      code: code,
      totp_secret: totp_secret
    }
  end
end
