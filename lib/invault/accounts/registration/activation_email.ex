defmodule Invault.Accounts.Registration.ActivationEmail do
  import Invault.Mailer.Email

  @origin "Awesome"
  @origin_address "invault-team@gmail.com"
  @subject "Welcome to Invault!"
  @template_id "801b6484-400c-4c0f-bdf8-86970d9e97c3"
  @activation_base_url "https://invault.io/activate"
  @login_url "https://invault.io/login"

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
