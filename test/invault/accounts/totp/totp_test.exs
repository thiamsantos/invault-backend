defmodule Invault.Accounts.TOTPTTest do
  use ExUnit.Case, async: true

  alias Invault.Accounts.TOTP

  describe "generate_secret/0" do
    test "should return a string with 32 characters of length" do
      secret = TOTP.generate_secret()

      assert String.length(secret) == 32
    end
  end

  describe "valid?/2" do
    test "should return true for a valid totp" do
      secret = TOTP.generate_secret()
      code = TOTP.generate_totp_code(secret)

      assert TOTP.valid?(secret, code) == true
    end

    test "should return false for a invalid totp" do
      secret = TOTP.generate_secret()
      another_secret = TOTP.generate_secret()
      code = TOTP.generate_totp_code(secret)

      assert TOTP.valid?(another_secret, code) == false
    end
  end

  describe "generate_totp_code/1" do
    test "should generate a valid totp code" do
      secret = TOTP.generate_secret()
      code = TOTP.generate_totp_code(secret)

      assert TOTP.valid?(secret, code) == true
    end

    test "should generate a six digits code" do
      secret = TOTP.generate_secret()
      code = TOTP.generate_totp_code(secret)

      assert Regex.match?(~r/^\d{6}$/, code) == true
    end
  end
end
