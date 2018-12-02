defmodule InvaultWeb.GraphQL.Schema do
  @moduledoc """
  GraphQL Schema.
  """
  use Absinthe.Schema

  import_types Absinthe.Type.Custom
  import_types InvaultWeb.GraphQL.Accounts.Types
  import_types InvaultWeb.GraphQL.Accounts.Mutations

  mutation do
    import_fields :accounts_mutations
  end

  query do
    field :posts, list_of(:string) do
      resolve fn _, _, _ -> {:ok, ["pow", "test"]} end
    end
  end
end
