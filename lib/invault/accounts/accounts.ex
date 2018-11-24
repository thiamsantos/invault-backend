defmodule Invault.Accounts do
  @moduledoc """
  Provides functionality to handle the lifecycle of an account.
  """

  alias Invault.Accounts.Registration

  @doc """
  Register a user on database.
  """
  defdelegate register(request), to: Registration
end
