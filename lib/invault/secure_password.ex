defmodule Invault.SecurePassword do
  @moduledoc """
  Generate and verifies secure password digests.
  """
  alias Comeonin.Argon2
  alias JOSE.JWA

  def digest(password, pepper) do
    password
    |> sha512()
    |> slow_hash()
    |> encrypt(pepper)
    |> Base.encode64()
  end

  def valid?(digest, password, pepper) do
    digest
    |> Base.decode64!()
    |> decrypt(pepper)
    |> verify_password(password)
  end

  defp slow_hash(text) do
    Argon2.hashpwsalt(text)
  end

  defp encrypt(text, pepper) do
    key = sha256(pepper)

    JWA.block_encrypt({:aes_ecb, 256}, key, text)
  end

  defp decrypt(digest, pepper) do
    key = sha256(pepper)
    JWA.block_decrypt({:aes_ecb, 256}, key, digest)
  end

  defp verify_password(hash, password) do
    password
    |> sha512()
    |> Argon2.checkpw(hash)
  rescue
    _ -> false
  end

  defp sha512(text), do: :crypto.hash(:sha512, text)
  defp sha256(text), do: :crypto.hash(:sha256, text)
end
