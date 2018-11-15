defmodule Invault.Accounts.TOTP do
  alias Invault.Repo
  alias Invault.Accounts.TOTP.Mutator
  alias Invault.Accounts.Schemas.TotpSecret

  @recovery_codes_amount 6

  def create_secret! do
    Repo.transaction(fn ->
      generate_secret()
      |> Mutator.insert_secret!()
      |> create_recovery_codes!()
    end)
  end

  defp generate_secret do
    20
    |> :crypto.strong_rand_bytes()
    |> Base.encode32()
  end

  defp create_recovery_codes!(%TotpSecret{} = totp_secret) do
    recovery_codes =
      Mutator.insert_multiple_recovery_codes!(totp_secret.id, @recovery_codes_amount)

    %{totp_secret | recovery_codes: recovery_codes}
  end
end
