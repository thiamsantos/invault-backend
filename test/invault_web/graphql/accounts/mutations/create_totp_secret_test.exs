# defmodule InvaultWeb.GraphQL.Accounts.Mutations.CreateTotpSecretTest do
#   use InvaultWeb.ConnCase, async: true

#   alias Invault.Accounts

#   @create_totp_secret_mutation """
#   mutation CreateTotpSecret {
#     createTotpSecret {
#       id
#       secret
#       recoveryCodes {
#         id
#         usedAt
#       }
#     }
#   }
#   """

#   describe "create totp secret" do
#     test "should return a valid secret", %{conn: conn} do
#       response =
#         conn
#         |> post("/graphql", %{"query" => @create_totp_secret_mutation})
#         |> json_response(200)

#       assert %{"data" => %{"createTotpSecret" => %{"secret" => secret}}} = response
#       assert String.length(secret) == 32
#     end

#     test "should return a persisted secret", %{conn: conn} do
#       response =
#         conn
#         |> post("/graphql", %{"query" => @create_totp_secret_mutation})
#         |> json_response(200)

#       assert %{"data" => %{"createTotpSecret" => %{"secret" => secret, "id" => id}}} = response

#       assert Accounts.get_totp_secret!(id).secret == secret
#     end

#     test "should return a list of recovery codes", %{conn: conn} do
#       response =
#         conn
#         |> post("/graphql", %{"query" => @create_totp_secret_mutation})
#         |> json_response(200)

#       assert %{
#                "data" => %{"createTotpSecret" => %{"id" => id, "recoveryCodes" => recovery_codes}}
#              } = response

#       for recovery_code <- recovery_codes do
#         assert Accounts.get_recovery_code!(recovery_code["id"]).totp_secret_id == id
#       end
#     end
#   end
# end
