defmodule Invault.MailerTest do
  use ExUnit.Case, async: true
  use Bamboo.Test

  alias Bamboo.Email
  alias Invault.Mailer

  describe "deliver_now/1" do
    test "should deliver an email" do
      email =
        Email.new_email(
          from: "me@app.com",
          to: "someone@example.com",
          subject: "Welcome!",
          text_body: "Welcome to the app",
          html_body: "<strong>Welcome to the app</strong>"
        )

      Mailer.deliver_now(email)

      assert_delivered_email email
    end
  end
end
