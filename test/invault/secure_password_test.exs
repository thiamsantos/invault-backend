defmodule Invault.SecurePasswordTest do
  use ExUnit.Case, async: true

  alias Invault.{Generator, SecurePassword}

  describe "digest/2" do
    test "should return a 128 characters length string" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)

      digest = SecurePassword.digest(password, pepper)

      assert String.length(digest) == 128
    end
  end

  describe "valid?/3" do
    test "should return true when password an pepper are valid" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)
      digest = SecurePassword.digest(password, pepper)

      assert SecurePassword.valid?(digest, password, pepper) == true
    end

    test "should return false when password is invalid" do
      password = Generator.random_string(64)
      another_password = Generator.random_string(64)
      pepper = Generator.random_string(128)
      digest = SecurePassword.digest(password, pepper)

      assert SecurePassword.valid?(digest, another_password, pepper) == false
    end

    test "should return false when pepper is invalid" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)
      another_pepper = Generator.random_string(128)
      digest = SecurePassword.digest(password, pepper)

      assert SecurePassword.valid?(digest, password, another_pepper) == false
    end

    test "should return false when both password and pepper are invalid" do
      password = Generator.random_string(64)
      pepper = Generator.random_string(128)
      another_password = Generator.random_string(64)
      another_pepper = Generator.random_string(128)
      digest = SecurePassword.digest(password, pepper)

      assert SecurePassword.valid?(digest, another_password, another_pepper) == false
    end
  end
end
