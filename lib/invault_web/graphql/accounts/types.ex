defmodule InvaultWeb.GraphQL.Accounts.Types do
  @moduledoc """
  GraphQL types related to accounts.
  """
  use Absinthe.Schema.Notation

  object :totp_secret do
    field :id, :id
    field :secret, non_null(:string)
    field :recovery_codes, list_of(:recovery_code)
  end

  object :recovery_code do
    field :id, :id
    field :used_at, :datetime
  end
end
