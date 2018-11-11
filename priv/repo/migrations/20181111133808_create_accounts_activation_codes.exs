defmodule Invault.Repo.Migrations.CreateAccountsActivationCodes do
  use Ecto.Migration

  def change do
    create table(:accounts_activation_codes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :used_at, :utc_datetime_usec
      add :expires_at, :utc_datetime_usec, null: false

      add :user_id, references(:accounts_users, on_delete: :nothing, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:accounts_activation_codes, [:user_id])
  end
end
