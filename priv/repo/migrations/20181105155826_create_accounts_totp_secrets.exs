defmodule Invault.Repo.Migrations.CreateAccountsTotpSecrets do
  use Ecto.Migration

  def change do
    create table(:accounts_totp_secrets, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:secret, :string, null: false, size: 32)

      timestamps()
    end
  end
end
