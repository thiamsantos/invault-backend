defmodule InvaultWeb.GraphQL.Accounts.Resolver do
  @moduledoc """
  GraphQL resolver that handles operations related to accounts.
  """
  alias Invault.Accounts

  def create_totp_secret(_, _) do
    Accounts.create_totp_secret!()
  end
end
