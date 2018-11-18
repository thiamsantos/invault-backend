defmodule Invault.Accounts.Registration.Loader do
  @moduledoc """
  Load account registation related data from the database.
  """
  alias Invault.Accounts.Registration.Queries
  alias Invault.Repo

  def one_totp_secret(totp_secret_id) do
    totp_secret_id
    |> Queries.one_totp_secret()
    |> Repo.one()
  end
end
