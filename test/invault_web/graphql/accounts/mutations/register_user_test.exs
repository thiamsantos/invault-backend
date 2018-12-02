defmodule InvaultWeb.GraphQL.Accounts.Mutations.RegisterUserTest do
  use InvaultWeb.ConnCase, async: true

  import Mox
  alias Invault.Generator
  alias Invault.CurrentTime.Mock, as: CurrentTimeMock
  alias Invault.CurrentTime.SystemAdapter, as: SystemAdapter

  @register_user """
  mutation RegisterUserMutation($input: RegisterUserInput!) {
    registerUser(input: $input) {
      id
      name
      email
    }
  }
  """

  setup do
    verify_on_exit!()
    stub_with(CurrentTimeMock, SystemAdapter)

    :ok
  end

  describe "register user" do
    test "return the user", %{conn: conn} do
      input = %{
        "name" => Generator.random_name(),
        "email" => Generator.random_email(),
        "password" => Generator.random_string(64)
      }

      %{"data" => %{"registerUser" => user}} =
        conn
        |> post("/graphql", %{
          "query" => @register_user,
          "variables" => %{"input" => input}
        })
        |> json_response(200)

      assert user["email"] == input["email"]
      assert user["name"] == input["name"]
    end

    test "return error when email was already used"
    test "return error when name has more than 255 characters"
    test "return error when email has more than 255 characters"
    test "return error when email does not have a @"
    test "return error when password is too short"
    test "return error when password is too long"
    test "return error when password has been in a data leak"
  end
end
