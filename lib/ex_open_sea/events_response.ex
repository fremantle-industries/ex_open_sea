defmodule ExOpenSea.EventsResponse do
  @type t :: %__MODULE__{
    next: String.t() | nil,
    previous: String.t() | nil,
    asset_events: list
  }

  defstruct ~w[
    next
    previous
    asset_events
  ]a
end
