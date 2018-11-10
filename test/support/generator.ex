defmodule Invault.Support.Generator do
  @moduledoc """
  Easily create test data.
  """
  def random_string(length) do
    length |> :crypto.strong_rand_bytes() |> Base.url_encode64() |> binary_part(0, length)
  end
end
