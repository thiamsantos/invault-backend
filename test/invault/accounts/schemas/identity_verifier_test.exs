defmodule Invault.Accounts.Schemas.IdentityVerifierTest do
  use Invault.DataCase, async: true

  alias Invault.Support.Generator
  alias Invault.Accounts.Schemas.IdentityVerifier

  describe "changeset/2" do
    test "secret and password verifier should be required" do
      changeset = IdentityVerifier.changeset(%IdentityVerifier{}, %{})

      assert changeset.valid? == false

      assert errors_on(changeset) == %{
               password_verifier: ["can't be blank"],
               salt: ["can't be blank"]
             }
    end

    test "changeset should be valid" do
      salt = Generator.random_string(44)
      password_verifier = Generator.random_string(344)

      changeset =
        IdentityVerifier.changeset(%IdentityVerifier{}, %{
          salt: salt,
          password_verifier: password_verifier
        })

      assert changeset.valid? == true
    end

    test "changeset invalid with password verifier below 344 characters" do
      salt = Generator.random_string(44)
      password_verifier = Generator.random_string(343)

      changeset =
        IdentityVerifier.changeset(%IdentityVerifier{}, %{
          salt: salt,
          password_verifier: password_verifier
        })

      assert changeset.valid? == false
      assert errors_on(changeset) == %{password_verifier: ["should be 344 character(s)"]}
    end

    test "changeset invalid with password verifier above 344 characters" do
      salt = Generator.random_string(44)
      password_verifier = Generator.random_string(345)

      changeset =
        IdentityVerifier.changeset(%IdentityVerifier{}, %{
          salt: salt,
          password_verifier: password_verifier
        })

      assert changeset.valid? == false
      assert errors_on(changeset) == %{password_verifier: ["should be 344 character(s)"]}
    end

    test "changeset invalid with salt below 44 characters" do
      salt = Generator.random_string(43)
      password_verifier = Generator.random_string(344)

      changeset =
        IdentityVerifier.changeset(%IdentityVerifier{}, %{
          salt: salt,
          password_verifier: password_verifier
        })

      assert changeset.valid? == false
      assert errors_on(changeset) == %{salt: ["should be 44 character(s)"]}
    end

    test "changeset invalid with salt above 344 characters" do
      salt = Generator.random_string(45)
      password_verifier = Generator.random_string(344)

      changeset =
        IdentityVerifier.changeset(%IdentityVerifier{}, %{
          salt: salt,
          password_verifier: password_verifier
        })

      assert changeset.valid? == false
      assert errors_on(changeset) == %{salt: ["should be 44 character(s)"]}
    end
  end
end
