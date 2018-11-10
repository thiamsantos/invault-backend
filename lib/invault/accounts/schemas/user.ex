defmodule Invault.Accounts.Schemas.User do
  @moduledoc """
  Registered user.
  """
  use Invault.Schema
  import Ecto.Changeset

  alias Invault.Accounts.Schemas.{IdentityVerifier, TotpSecret}

  schema "accounts_users" do
    field :activated_at, :utc_datetime_usec
    field :email, :string
    field :name, :string
    belongs_to :totp_secret, TotpSecret
    belongs_to :identity_verifier, IdentityVerifier

    timestamps()
  end

  @required_fields [:name, :email, :totp_secret_id, :identity_verifier_id]
  @optional_fields [:activated_at]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:email, max: 255)
    |> validate_length(:name, max: 255)
    |> validate_format(:email, ~r/@/)
    |> foreign_key_constraint(:totp_secret_id)
    |> foreign_key_constraint(:identity_verifier_id)
    |> unique_constraint(:email)
    |> unique_constraint(:totp_secret_id)
    |> unique_constraint(:identity_verifier_id)
  end
end
