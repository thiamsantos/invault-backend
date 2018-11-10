defmodule Invault.Repo.Migrations.CreateAccountsUsers do
  use Ecto.Migration

  def change do
    create table(:accounts_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, size: 255
      add :email, :string, null: false, size: 255
      add :activated_at, :utc_datetime_usec

      add :totp_secret_id,
          references(:accounts_totp_secrets, on_delete: :nothing, type: :binary_id),
          null: false

      add :identity_verifier_id,
          references(:accounts_identity_verifiers, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create unique_index(:accounts_users, [:totp_secret_id])
    create unique_index(:accounts_users, [:identity_verifier_id])
    create unique_index(:accounts_users, [:email])
  end
end
