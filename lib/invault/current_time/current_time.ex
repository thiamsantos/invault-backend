defmodule Invault.CurrentTime do
  @moduledoc """
  Adapter based module to get the current time.

  ## Configuration

  ```elixir
  config :invault, Invault.CurrentTime, adapter: Invault.CurrentTime.SystemAdapter
  ```

  ## Adapters

  Are available the following adapters:

  - `Invault.CurrentTime.SystemAdapter` - Get the current time from the system.
  - `Invault.CurrentTime.Mock` - Mock defined with `Mox` to be used on tests.s

  """
  @behaviour Invault.CurrentTime.Adapter

  @adapter :invault |> Application.fetch_env!(__MODULE__) |> Keyword.fetch!(:adapter)

  defdelegate utc_now, to: @adapter
end
