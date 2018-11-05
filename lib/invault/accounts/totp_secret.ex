defmodule Invault.Accounts.TotpSecret do
  @moduledoc """
  Totp Secret used to validate the totp sended by a user on a login with 2FA.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts_totp_secrets" do
    field :secret, :string
    timestamps()
  end

  @fields [:secret]

  @doc false
  def changeset(totp_secret, attrs) do
    totp_secret
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_length(:secret, is: 32)
  end
end
