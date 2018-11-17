defmodule Invault.Generator do
  @moduledoc """
  Easily create test data.
  """

  alias Faker.{Internet, Name}

  def random_string(length) do
    length |> :crypto.strong_rand_bytes() |> Base.url_encode64() |> binary_part(0, length)
  end

  def random_name do
    Name.name()
  end

  def random_email do
    Internet.email()
  end
end
