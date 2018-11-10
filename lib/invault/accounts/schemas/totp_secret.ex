defmodule Invault.Accounts.Schemas.TotpSecret do
  @moduledoc """
  Totp Secret used to validate the totp sended by a user on a login with 2FA.
  """
  use Invault.Schema
  import Ecto.Changeset
  alias Invault.Accounts.Schemas.RecoveryCode

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
