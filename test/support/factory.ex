defmodule Invault.Factory do
  @moduledoc """
  Easily create data on the database for testing purposes.
  """
  use ExMachina.Ecto, repo: Invault.Repo

  alias Faker.{Internet, Name}
  alias Invault.Accounts.Schemas.{IdentityVerifier, RecoveryCode, TotpSecret, User}

  def accounts_totp_secret_factory do
    secret = 20 |> :crypto.strong_rand_bytes() |> Base.encode32()

    %TotpSecret{
      secret: secret
    }
  end

  def accounts_recovery_code_factory do
    totp_secret = build(:accounts_totp_secret)

    %RecoveryCode{
      totp_secret: totp_secret
    }
  end

  def accounts_identity_verifier_factory do
    email = Internet.email()

    identity = SRP.new_identity(email, "password123")
    identity_verifier = SRP.generate_verifier(identity)

    %IdentityVerifier{
      password_verifier: Base.encode64(identity_verifier.password_verifier),
      salt: Base.encode64(identity_verifier.salt)
    }
  end

  def accounts_user_factory do
    identity_verifier = build(:accounts_identity_verifier)
    totp_secret = build(:accounts_totp_secret)

    %User{
      email: Internet.email(),
      name: Name.name(),
      totp_secret: totp_secret,
      identity_verifier: identity_verifier
    }
  end
end
