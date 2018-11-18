defmodule Invault.Accounts.Registration.Queries do
  @moduledoc """
  Database queries related to account registration.
  """
  import Ecto.Query, only: [from: 2]
  alias Invault.Accounts.Schemas.TotpSecret

  def one_totp_secret(totp_secret_id) do
    from(
      t in TotpSecret,
      where: t.id == ^totp_secret_id,
      select: t.secret,
      limit: 1
    )
  end
end
