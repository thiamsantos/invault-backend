defmodule Invault.Accounts.Registration.Mutator do
  alias Invault.Repo
  alias Invault.Accounts.Schemas.{ActivationCode, IdentityVerifier, User}

  def insert_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def insert_identity_verifier(attrs) do
    %IdentityVerifier{}
    |> IdentityVerifier.changeset(attrs)
    |> Repo.insert()
  end

  def insert_activation_code(attrs) do
    %ActivationCode{}
    |> ActivationCode.changeset(attrs)
    |> Repo.insert()
  end
end
