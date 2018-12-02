defmodule InvaultWeb.GraphQL.Accounts.Resolver do
  @moduledoc """
  GraphQL resolver that handles operations related to accounts.
  """
  alias Invault.Accounts.Registration.Request
  alias Invault.Accounts

  def register_user(%{input: input}, _) do
    Request
    |> struct(input)
    |> Accounts.register()
  end
end
