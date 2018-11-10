defmodule Invault.Repo.Migrations.CreateAccountsIdentityVerifiers do
  use Ecto.Migration

  def change do
    create table(:accounts_identity_verifiers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :salt, :string, size: 44, null: false
      add :password_verifier, :string, size: 344, null: false

      timestamps()
    end
  end
end
