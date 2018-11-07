defmodule InvaultWeb.GraphQL.Accounts.Mutations do
  @moduledoc """
  GraphQL mutations related to accounts.
  """
  use Absinthe.Schema.Notation

  alias InvaultWeb.GraphQL.Accounts.Resolver

  object :accounts_mutations do
    mutation do
      field :create_totp_secret, :totp_secret do
        description "Create a totp secret to setup the 2FA for an account"
        resolve &Resolver.create_totp_secret/2
      end
    end
  end
end
