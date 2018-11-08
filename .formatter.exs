locals_without_parens = [
  assert_delivered_email: 1,
  assert_email_delivered_with: 1
]

[
  locals_without_parens: locals_without_parens,
  import_deps: [:ecto, :ecto_sql, :phoenix, :absinthe],
  inputs: ["*.{ex,exs}", "{config,lib,priv,test}/**/*.{ex,exs}"]
]
