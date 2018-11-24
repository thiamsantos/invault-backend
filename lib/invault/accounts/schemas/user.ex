defmodule Invault.Accounts.Schemas.User do
  @moduledoc """
  Registered user.
  """
  use Invault.Schema
  import Ecto.Changeset

  schema "accounts_users" do
    field :activated_at, :utc_datetime_usec
    field :email, :string
    field :name, :string
    field :password_digest, :string

    timestamps()
  end

  @required_fields [:name, :email, :password_digest]
  @optional_fields [:activated_at]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:email, max: 255)
    |> validate_length(:name, max: 255)
    |> validate_length(:password_digest, is: 128)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
