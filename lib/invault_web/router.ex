defmodule InvaultWeb.Router do
  use InvaultWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: InvaultWeb.GraphQL.Schema

    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: InvaultWeb.GraphQL.Schema,
            interface: :playground
  end
end
