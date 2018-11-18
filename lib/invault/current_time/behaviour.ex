defmodule Invault.CurrentTime.Adapter do
  @moduledoc """
  Behaviour for a `Invault.CurrentTime` adapter.
  """
  @callback utc_now :: DateTime.t()
end
