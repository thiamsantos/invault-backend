defmodule Invault.Accounts do
  @moduledoc """
  Provides functionality to handle the lifecycle of an account.
  """

  @doc """
  Create a TOTP to setup 2FA for an client.
  It generates a 20 bytes base 32 encoded secret and 
  six recovery codes in case the client loses to his phone.
  """
  defdelegate create_totp_secret!, to: Invault.Accounts.TOTP, as: :create_secret!
end
