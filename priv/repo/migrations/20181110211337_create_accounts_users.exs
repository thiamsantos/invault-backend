defmodule Invault.Repo.Migrations.CreateAccountsUsers do
  use Ecto.Migration

  def change do
    create table(:accounts_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, size: 255
      add :email, :string, null: false, size: 255
      add :password_digest, :string, null: false, size: 128
      add :activated_at, :utc_datetime_usec

      timestamps()
    end

    create unique_index(:accounts_users, [:email])
  end
end
