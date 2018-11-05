defmodule InvaultWeb.GraphQL.Schema do
  @moduledoc """
  GraphQL Schema.
  """
  use Absinthe.Schema

  query do
    field :posts, list_of(:string) do
      resolve fn _, _, _ -> {:ok, ["pow", "test"]} end
    end
  end
end
