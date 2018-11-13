defmodule Invault.Mailer.EmailTest do
  use ExUnit.Case, async: true

  alias Invault.Mailer.Email

  describe "new_email/0" do
    test "should return a bamboo email" do
      assert %Bamboo.Email{} == Email.new_email()
    end
  end

  describe "subject/2" do
    test "should add a subject to the email" do
      subject = "Super important subject!"

      email =
        Email.new_email()
        |> Email.subject(subject)

      assert email.subject == subject
    end
  end

  describe "with_template/2" do
    test "should add the template id subject to the email" do
      template_id = "1c9aa8bb-f649-4806-b89f-b86bdf866b84"

      email =
        Email.new_email()
        |> Email.with_template(template_id)

      assert email.private == %{send_grid_template: %{template_id: template_id}}
    end
  end

  describe "to/3" do
    test "should add the destination to the email" do
      name = "Cool name"
      email_address = "cool.name@example.com"

      email =
        Email.new_email()
        |> Email.to(name, email_address)

      assert email.to == {name, email_address}
    end
  end

  describe "from/3" do
    test "should add the origin to the email" do
      name = "Cool name"
      email_address = "cool.name@example.com"

      email =
        Email.new_email()
        |> Email.from(name, email_address)

      assert email.from == {name, email_address}
    end
  end

  describe "substitute/3" do
    test "should add the substition to the email" do
      name = "Cool name"

      email =
        Email.new_email()
        |> Email.substitute(:name, name)

      assert email.private == %{send_grid_template: %{substitutions: %{"<%= name %>" => name}}}
    end

    test "should escape html characters" do
      name = ~s(Q1"><a href="kajmer.tk"><img src="https://kajmer.tk/img.jpg"></a>)

      escaped_name =
        "Q1&quot;&gt;&lt;a href=&quot;kajmer.tk&quot;&gt;&lt;img src=&quot;https://kajmer.tk/img.jpg&quot;&gt;&lt;/a&gt;"

      email =
        Email.new_email()
        |> Email.substitute(:name, name)

      assert email.private == %{
               send_grid_template: %{substitutions: %{"<%= name %>" => escaped_name}}
             }
    end
  end
end
