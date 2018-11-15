defmodule Invault.Accounts.TOTP.Mutator do
  alias Invault.Repo
  alias Invault.Accounts.Schemas.{RecoveryCode, TotpSecret}

  def insert_secret!(secret) do
    %TotpSecret{}
    |> TotpSecret.changeset(%{secret: secret})
    |> Repo.insert!()
  end

  def insert_multiple_recovery_codes!(secret_id, amount) do
    attrs = %{
      totp_secret_id: secret_id,
      inserted_at: naive_timestamp(),
      updated_at: naive_timestamp()
    }

    content = times(attrs, amount)

    {^amount, recovery_codes} =
      Repo.insert_all(RecoveryCode, content, returning: true, on_conflict: :raise)

    recovery_codes
  end

  defp times(attrs, amount) do
    Enum.map(1..amount, fn _ -> attrs end)
  end

  defp naive_timestamp do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
  end
end
