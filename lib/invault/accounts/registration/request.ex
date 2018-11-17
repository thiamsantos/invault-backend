defmodule Invault.Accounts.Registration.Request do
  @moduledoc """
  A registration request.
  """
  @enforce_keys [:name, :email, :totp_secret_id, :totp_code, :salt, :password_verifier]
  defstruct [:name, :email, :totp_secret_id, :totp_code, :salt, :password_verifier]
end
