defmodule Invault.Factory do
  @moduledoc """
  Easily create data on the database for testing purposes.
  """
  use ExMachina.Ecto, repo: Invault.Repo

  alias Invault.Accounts.Schemas.{RecoveryCode, TotpSecret}

  def accounts_totp_secret_factory do
    secret = 20 |> :crypto.strong_rand_bytes() |> Base.encode32()

    %TotpSecret{
      secret: secret
    }
  end

  def accounts_recovery_code_factory do
    totp_secret = build(:accounts_totp_secret)

    %RecoveryCode{
      totp_secret: totp_secret
    }
  end
end
