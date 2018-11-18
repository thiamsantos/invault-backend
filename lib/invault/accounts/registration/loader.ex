defmodule Invault.Accounts.Registration.Loader do
  alias Invault.Accounts.Registration.Queries
  alias Invault.Repo

  def one_totp_secret(totp_secret_id) do
    totp_secret_id
    |> Queries.one_totp_secret()
    |> Repo.one()
  end
end
