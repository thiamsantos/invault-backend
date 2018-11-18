defmodule Invault.Accounts.Registration.ActivationEmail do
  @moduledoc """
  Account activation email.

  ## Example

  ```elixir
  alias Invault.Accounts.Registration.ActivationEmail
  alias Invault.Mailer

  attrs = %{
    name: "alice",
    email: "alice@gmail.com",
    activation_code: "a9f7a494-43bc-439b-bff2-56a2c4a3eed2"
  }

  attrs
  |> ActivationEmail.create()
  |> Mailer.deliver_now()
  ```

  ## Configuration

  ```elixir
  config :invault, Invault.Accounts.Registration.ActivationEmail,
    origin: "Awesome",
    origin_address: "invault-team@gmail.com",
    subject: "Welcome to Invault!",
    template_id: "801b6484-400c-4c0f-bdf8-86970d9e97c3",
    activation_base_url: "https://invault.io/activate",
    login_url: "https://invault.io/login"
  ```

  """
  import Invault.Mailer.Email

  @config Application.fetch_env!(:invault, __MODULE__)
  @origin Keyword.fetch!(@config, :origin)
  @origin_address Keyword.fetch!(@config, :origin_address)
  @subject Keyword.fetch!(@config, :subject)
  @template_id Keyword.fetch!(@config, :template_id)
  @activation_base_url Keyword.fetch!(@config, :activation_base_url)
  @login_url Keyword.fetch!(@config, :login_url)

  def create(%{name: name, email: email, activation_code: activation_code}) do
    new_email()
    |> from(@origin, @origin_address)
    |> to(name, email)
    |> subject(@subject)
    |> with_template(@template_id)
    |> substitute(:name, name)
    |> substitute(:email, email)
    |> substitute(:activation_url, @activation_base_url <> "?code=#{activation_code}")
    |> substitute(:login_url, @login_url)
  end
end
