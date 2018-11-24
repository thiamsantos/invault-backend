defmodule Invault.Factory do
  @moduledoc """
  Easily create data on the database for testing purposes.
  """
  use ExMachina.Ecto, repo: Invault.Repo

  alias Invault.{Generator, SecurePassword}

  alias Invault.Accounts.Schemas.{ActivationCode, User}

  def accounts_user_factory do
    password = Generator.random_string(64)
    pepper = Generator.random_string(128)

    %User{
      email: Generator.random_email(),
      name: Generator.random_name(),
      password_digest: SecurePassword.digest(password, pepper)
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
