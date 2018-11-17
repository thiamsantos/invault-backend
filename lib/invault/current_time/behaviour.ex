defmodule Invault.CurrentTime.Behaviour do
  @callback utc_now :: DateTime.t()
end
