defmodule Invault.Accounts.Registration.Request do
  @moduledoc """
  A registration request.
  """
  @enforce_keys [:name, :email, :password]
  defstruct [:name, :email, :password]
end
