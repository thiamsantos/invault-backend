# defmodule InvaultWeb.GraphQL.Accounts.Types do
#   @moduledoc """
#   GraphQL types related to accounts.
#   """
#   use Absinthe.Schema.Notation

#   object :totp_secret do
#     description "A secret used to generate TOTP codes for 2FA authentication"
#     field :id, :id, description: "Unique identifier for a recovery code"
#     field :secret, non_null(:string), description: "TOTP Secret"

#     field :recovery_codes, list_of(:recovery_code),
#       description: "List of totp codes for this totp secret"
#   end

#   object :recovery_code do
#     description "A code to recover a 2FA authentication"
#     field :id, :id, description: "Unique identifier for a recovery code"
#     field :used_at, :datetime, description: "When the recovery code was used"
#   end
# end
