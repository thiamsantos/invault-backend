defmodule Invault.Accounts.Registration do
  alias Invault.Repo
  alias Invault.{CurrentTime, Mailer}
  alias Invault.Accounts.Registration.{ActivationEmail, Loader, Mutator, Request}
  alias Invault.Accounts.Schemas.{ActivationCode, IdentityVerifier, User}
  alias Invault.Accounts.TOTP

  def register(%Request{} = request) do
    Repo.transaction(fn ->
      with :ok <- validate_totp_code(request),
           {:ok, %IdentityVerifier{} = identity_verifier} <- insert_identity_verifier(request),
           {:ok, %User{} = user} <- insert_user(request, identity_verifier),
           {:ok, %ActivationCode{} = activation_code} <- create_activation_code(user) do
        deliver_activation_email!(user, activation_code)

        user
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp insert_identity_verifier(%Request{salt: salt, password_verifier: password_verifier}) do
    attrs = %{
      password_verifier: password_verifier,
      salt: salt
    }

    Mutator.insert_identity_verifier(attrs)
  end

  defp insert_user(%Request{} = request, %IdentityVerifier{} = identity_verifier) do
    attrs = %{
      name: request.name,
      email: request.email,
      totp_secret_id: request.totp_secret_id,
      identity_verifier_id: identity_verifier.id
    }

    Mutator.insert_user(attrs)
  end

  defp create_activation_code(%User{id: user_id}) do
    attrs = %{
      user_id: user_id,
      expires_at: CurrentTime.utc_now() |> Timex.shift(days: 7)
    }

    Mutator.insert_activation_code(attrs)
  end

  defp deliver_activation_email!(%User{name: name, email: email}, %ActivationCode{
         id: activation_code
       }) do
    attrs = %{
      name: name,
      email: email,
      activation_code: activation_code
    }

    attrs
    |> ActivationEmail.create()
    |> Mailer.deliver_now()
  end

  defp validate_totp_code(%Request{totp_secret_id: totp_secret_id, totp_code: totp_code}) do
    totp_secret_id
    |> Loader.one_totp_secret()
    |> handle_totp_secret_load(totp_code)
  end

  defp handle_totp_secret_load(nil, _) do
    {:error, %{totp_secret_id: [validation: :invalid_reference, message: "does not exist"]}}
  end

  defp handle_totp_secret_load(secret, totp_code) when is_binary(secret) do
    if TOTP.valid?(secret, totp_code) do
      :ok
    else
      {:error, %{totp_code: [validation: :invalid, message: "Invalid TOTP code"]}}
    end
  end
end
