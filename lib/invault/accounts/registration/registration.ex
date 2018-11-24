defmodule Invault.Accounts.Registration do
  @moduledoc """
  Registrate a user on the application. The following steps are taken:

  - Validate the 2FA information.
  - Create a identity verifier for the user.
  - Insert the user on the database.
  - Generate a activation code for the account.
  - Send via email to the user the activation code.
  """
  alias Invault.Repo
  alias Invault.{CurrentTime, Mailer, SecurePassword}
  alias Invault.Accounts.Registration.{ActivationEmail, Mutator, Request}
  alias Invault.Accounts.Schemas.{ActivationCode, User}

  @pepper :invault |> Application.fetch_env!(__MODULE__) |> Keyword.fetch!(:pepper)

  def register(%Request{} = request) do
    Repo.transaction(fn ->
      case do_request(request) do
        {:ok, user} -> user
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp do_request(%Request{} = request) do
    with {:ok, %User{} = user} <- insert_user(request),
         {:ok, %ActivationCode{} = activation_code} <- create_activation_code(user) do
      deliver_activation_email!(user, activation_code)

      {:ok, user}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp insert_user(%Request{} = request) do
    attrs = %{
      name: request.name,
      email: request.email,
      password_digest: SecurePassword.digest(request.password, @pepper)
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
end
