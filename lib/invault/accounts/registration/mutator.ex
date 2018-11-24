defmodule Invault.Accounts.Registration.Mutator do
  @moduledoc """
  Database mutation related to account registration.
  """
  alias Invault.Repo
  alias Invault.Accounts.Schemas.{ActivationCode, User}

  def insert_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def insert_activation_code(attrs) do
    %ActivationCode{}
    |> ActivationCode.changeset(attrs)
    |> Repo.insert()
  end
end
