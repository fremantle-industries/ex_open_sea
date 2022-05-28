defmodule ExOpenSea.AssetsCursor do
  @type t :: %__MODULE__{
    next: String.t() | nil,
    previous: String.t() | nil,
    assets: [map]
  }

  defstruct ~w[next previous assets]a
end

