defmodule Invault.Accounts.Schemas.ActivationCode do
  @moduledoc """
  Code used to activate a user account.
  """
  use Invault.Schema
  import Ecto.Changeset
  alias Invault.Accounts.Schemas.User

  schema "accounts_activation_codes" do
    field :expires_at, :utc_datetime_usec
    field :used_at, :utc_datetime_usec
    belongs_to :user, User

    timestamps()
  end

  @required_fields [:expires_at, :user_id]
  @optional_fields [:used_at]

  @doc false
  def changeset(activation_code, attrs) do
    activation_code
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end
end
