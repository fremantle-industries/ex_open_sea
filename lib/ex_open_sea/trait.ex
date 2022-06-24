defmodule ExOpenSea.Trait do
  @type t :: %__MODULE__{}

  defstruct ~w[
    trait_type
    value
    display_type
    max_value
    trait_count
    order
  ]a
end
