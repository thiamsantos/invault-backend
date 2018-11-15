defmodule Invault.Accounts.Loader do
  @moduledoc """
  Loads from the database records related to accounts.
  """
  alias Invault.Accounts.Schemas.{RecoveryCode, TotpSecret}
  alias Invault.Repo

  def get_recovery_code!(recovery_code_id) do
    Repo.get!(RecoveryCode, recovery_code_id)
  end

  def get_totp_secret!(totp_secret_id) do
    Repo.get!(TotpSecret, totp_secret_id)
  end
end
