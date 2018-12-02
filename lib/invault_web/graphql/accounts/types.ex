defmodule InvaultWeb.GraphQL.Accounts.Types do
  @moduledoc """
  GraphQL types related to accounts.
  """
  use Absinthe.Schema.Notation

  object :user do
    description "A registered user."
    field :id, non_null(:id), description: "Unique identifier for a user"
    field :email, non_null(:string), description: "User unique email address"
    field :name, non_null(:string), description: "How the user want's to be called"
  end
end
