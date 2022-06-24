defmodule ExOpenSea.EventsResponse do
  @type asset_event :: ExOpenSea.AssetEvent.t()
  @type t :: %__MODULE__{
          next: String.t() | nil,
          previous: String.t() | nil,
          asset_events: [asset_event]
        }

  defstruct ~w[
    next
    previous
    asset_events
  ]a
end
