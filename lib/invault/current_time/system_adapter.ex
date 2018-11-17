defmodule Invault.CurrentTime.SystemAdapter do
  @behaviour Invault.CurrentTime.Behaviour

  defdelegate utc_now, to: DateTime
end
