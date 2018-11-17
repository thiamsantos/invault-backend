defmodule Invault.CurrentTime do
  @behaviour Invault.CurrentTime.Behaviour

  @adapter :invault |> Application.fetch_env!(__MODULE__) |> Keyword.fetch!(:adapter)

  defdelegate utc_now, to: @adapter
end
