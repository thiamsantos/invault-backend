defmodule Invault.Mailer.Email do
  @moduledoc """
  Functions for composing emails.
  """

  import Phoenix.HTML, only: [html_escape: 1, safe_to_string: 1]

  alias Bamboo.Email, as: BambooEmail
  alias Bamboo.SendGridHelper

  defdelegate new_email, to: BambooEmail
  defdelegate subject(email, attr), to: BambooEmail
  defdelegate with_template(email, template_id), to: SendGridHelper

  def to(email, name, email_address) do
    BambooEmail.to(email, {name, email_address})
  end

  def from(email, name, email_address) do
    BambooEmail.from(email, {name, email_address})
  end

  def substitute(%BambooEmail{} = email, key, value)
      when is_atom(key) and is_binary(value) do
    parsed_key = parse_key(key)
    parsed_value = parse_value(value)

    SendGridHelper.substitute(email, parsed_key, parsed_value)
  end

  defp parse_key(key) when is_atom(key) do
    "<%= #{Atom.to_string(key)} %>"
  end

  defp parse_value(value) when is_binary(value) do
    value
    |> html_escape()
    |> safe_to_string()
  end
end
