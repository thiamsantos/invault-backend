defmodule Invault.Accounts.Schemas.IdentityVerifier do
  @moduledoc """
  Data used to verify the identity of an user. 
  """
  use Invault.Schema
  import Ecto.Changeset

  schema "accounts_identity_verifiers" do
    field :password_verifier, :string
    field :salt, :string

    timestamps()
  end

  @fields [:salt, :password_verifier]

  @doc false
  def changeset(identity_verifier, attrs) do
    identity_verifier
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_length(:salt, is: 44)
    |> validate_length(:password_verifier, is: 344)
  end
end
