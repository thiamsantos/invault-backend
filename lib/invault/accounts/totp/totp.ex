defmodule Invault.Accounts.TOTP do
  @moduledoc """
  Provides funcionality to handle Time-based One-time Password (TOTP).
  It's used in two factor authentication.
  """
  alias Invault.Accounts.Schemas.TotpSecret
  alias Invault.Accounts.TOTP.Mutator
  alias Invault.Repo

  @recovery_codes_amount 6

  @doc """
  Create a TOTP secret, stores it on the database and 
  create #{@recovery_codes_amount} recovery codes that can be used in the 
  future to restore the two factor authentication of an user.
  """
  def create_secret! do
    Repo.transaction(fn ->
      generate_secret()
      |> Mutator.insert_secret!()
      |> create_recovery_codes!()
    end)
  end

  @doc """
  Verifies the validity of a TOTP code given it's secret.
  """
  def valid?(secret, totp_code) do
    :pot.valid_totp(totp_code, secret)
  end

  @doc """
  Generate a TOTP code given the secret.
  """
  def generate_totp_code(secret) do
    :pot.totp(secret)
  end

  @doc """
  Generate a 32 characters of length random TOTP secret.
  """
  def generate_secret do
    20
    |> :crypto.strong_rand_bytes()
    |> Base.encode32()
  end

  defp create_recovery_codes!(%TotpSecret{} = totp_secret) do
    recovery_codes =
      Mutator.insert_multiple_recovery_codes!(totp_secret.id, @recovery_codes_amount)

    %{totp_secret | recovery_codes: recovery_codes}
  end
end
