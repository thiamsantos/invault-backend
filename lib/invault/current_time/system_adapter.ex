defmodule Invault.CurrentTime.SystemAdapter do
  @moduledoc """
  `Invault.CurrentTime` adapter that gets the current time of the operational system.
  """
  @behaviour Invault.CurrentTime.Adapter

  defdelegate utc_now, to: DateTime
end
