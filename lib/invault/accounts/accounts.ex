defmodule Invault.Accounts do
  @moduledoc """
  Provides functionality to handle the lifecycle of an account.
  """
  alias Invault.Repo
  alias Invault.Accounts.Schemas.{RecoveryCode, TotpSecret}

  @recovery_codes_quantity 6

  @doc """
  Create a TOTP to setup 2FA for an client.
  It generates a 20 bytes base 32 encoded secret and 
  six recovery codes in case the client loses to his phone.
  """
  def create_totp_secret! do
    Repo.transaction(fn ->
      generate_secret()
      |> persist_secret!()
      |> create_recovery_codes!()
    end)
  end

  defp generate_secret do
    20
    |> :crypto.strong_rand_bytes()
    |> Base.encode32()
  end

  defp persist_secret!(secret) do
    %TotpSecret{}
    |> TotpSecret.changeset(%{secret: secret})
    |> Repo.insert!()
  end

  defp create_recovery_codes!(%TotpSecret{} = totp_secret) do
    recovery_codes =
      1..@recovery_codes_quantity
      |> Enum.map(&persist_code!(&1, totp_secret))

    %{totp_secret | recovery_codes: recovery_codes}
  end

  defp persist_code!(_, totp_secret) do
    %RecoveryCode{}
    |> RecoveryCode.changeset(%{totp_secret_id: totp_secret.id})
    |> Repo.insert!()
  end
end
