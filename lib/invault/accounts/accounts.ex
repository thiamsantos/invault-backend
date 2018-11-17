defmodule Invault.Accounts do
  @moduledoc """
  Provides functionality to handle the lifecycle of an account.
  """

  alias Invault.Accounts.{Loader, Registration, TOTP}

  @doc """
  Create a TOTP to setup 2FA for an client.
  It generates a 20 bytes base 32 encoded secret and
  six recovery codes in case the client loses to his phone.
  """
  defdelegate create_totp_secret!, to: TOTP, as: :create_secret!

  @doc """
  Get from the database a recovery code given its id.
  """
  defdelegate get_recovery_code!(recovery_code_id), to: Loader

  @doc """
  Get from the database a totp secret given its id.
  """
  defdelegate get_totp_secret!(totp_secret_id), to: Loader

  defdelegate register(request), to: Registration
end
