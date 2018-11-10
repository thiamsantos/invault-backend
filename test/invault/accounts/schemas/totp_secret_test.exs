defmodule Invault.Accounts.Schemas.TotpSecretTest do
  use Invault.DataCase, async: true

  alias Invault.Accounts.Schemas.TotpSecret

  describe "changeset/2" do
    test "should require secret field" do
      changeset = TotpSecret.changeset(%TotpSecret{}, %{secret: nil})

      assert changeset.valid? == false
      assert errors_on(changeset) == %{secret: ["can't be blank"]}
    end

    test "secret return error for secret below 32 characters" do
      changeset = TotpSecret.changeset(%TotpSecret{}, %{secret: "123"})

      assert changeset.valid? == false
      assert errors_on(changeset) == %{secret: ["should be 32 character(s)"]}
    end

    test "secret return error for secret above 32 characters" do
      secret = 80 |> :crypto.strong_rand_bytes() |> Base.encode32()
      changeset = TotpSecret.changeset(%TotpSecret{}, %{secret: secret})

      assert changeset.valid? == false
      assert String.length(secret) > 32
      assert errors_on(changeset) == %{secret: ["should be 32 character(s)"]}
    end

    test "secret should be a string" do
      changeset = TotpSecret.changeset(%TotpSecret{}, %{secret: 1234})

      assert changeset.valid? == false
      assert errors_on(changeset) == %{secret: ["is invalid"]}
    end

    test "should secret should accept 32 characters" do
      secret = 20 |> :crypto.strong_rand_bytes() |> Base.encode32()
      changeset = TotpSecret.changeset(%TotpSecret{}, %{secret: secret})

      assert changeset.valid? == true
      assert String.length(secret) == 32
      assert errors_on(changeset) == %{}
      assert changeset.changes == %{secret: secret}
    end
  end
end
