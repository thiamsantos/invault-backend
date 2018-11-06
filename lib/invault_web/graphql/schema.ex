defmodule InvaultWeb.GraphQL.Schema do
  @moduledoc """
  GraphQL Schema.
  """
  use Absinthe.Schema

  import_types Absinthe.Type.Custom

  object :totp_secret do
    field :id, :id
    field :secret, non_null(:string)
    field :recovery_codes, list_of(:recovery_code)
  end

  object :recovery_code do
    field :id, :id
    field :used_at, :datetime
  end

  mutation do
    field :create_totp_secret, :totp_secret do
      resolve fn _, _, _ -> {:ok, Invault.Accounts.create_totp_secret()} end
    end
  end

  query do
  end
end
