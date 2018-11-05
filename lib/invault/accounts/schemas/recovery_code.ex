defmodule Invault.Accounts.Schemas.RecoveryCode do
  @moduledoc """
  Code to recovery two factor authentication.
  """
  use Invault.Schema
  import Ecto.Changeset
  alias Invault.Accounts.Schemas.TotpSecret

  schema "accounts_recovery_codes" do
    field :code, :string
    field :used_at, :utc_datetime
    belongs_to :totp_secret, TotpSecret

    timestamps()
  end

  @required_fields [:code, :totp_secret_id]
  @optional_fields [:used_at]

  @doc false
  def changeset(recovery_code, attrs) do
    recovery_code
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:code, is: 44)
    |> unique_constraint(:code)
    |> foreign_key_constraint(:totp_secret_id)
  end
end
