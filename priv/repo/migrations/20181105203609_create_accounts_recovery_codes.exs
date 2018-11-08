defmodule Invault.Repo.Migrations.CreateAccountsRecoveryCodes do
  use Ecto.Migration

  def change do
    create table(:accounts_recovery_codes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :used_at, :utc_datetime_usec

      add :totp_secret_id,
          references(:accounts_totp_secrets, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:accounts_recovery_codes, [:totp_secret_id])
  end
end
