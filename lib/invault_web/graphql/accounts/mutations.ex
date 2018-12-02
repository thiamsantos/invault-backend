defmodule InvaultWeb.GraphQL.Accounts.Mutations do
  @moduledoc """
  GraphQL mutations related to accounts.
  """
  use Absinthe.Schema.Notation

  alias InvaultWeb.GraphQL.Accounts.Resolver

  object :accounts_mutations do
    mutation do
      field :register_user, :user do
        description "Register a user in the application"

        arg :input, non_null(:register_user_input)

        resolve &Resolver.register_user/2
      end
    end
  end

  input_object :register_user_input do
    field :name, non_null(:string)
    field :email, non_null(:string)
    field :password, non_null(:string)
  end
end
