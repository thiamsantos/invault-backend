defmodule Invault.Factory do
  @moduledoc """
  Easily create data on the database for testing purposes.
  """
  use ExMachina.Ecto, repo: Invault.Repo

  alias Invault.Generator

  alias Invault.Accounts.Schemas.{
    ActivationCode,
    IdentityVerifier,
    RecoveryCode,
    TotpSecret,
    User
  }

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
    email = Generator.random_email()

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
      email: Generator.random_email(),
      name: Generator.random_name(),
      totp_secret: totp_secret,
      identity_verifier: identity_verifier
    }
  end

  def accounts_activation_code_factory do
    user = build(:accounts_user)

    %ActivationCode{
      user: user,
      expires_at: DateTime.utc_now() |> Timex.shift(days: 7)
    }
  end
end
