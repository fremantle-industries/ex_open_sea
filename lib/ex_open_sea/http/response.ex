defmodule ExOpenSea.Http.Response do
  @type t :: %__MODULE__{
    status_code: non_neg_integer,
    body: String.t()
  }

  defstruct ~w[status_code body]a
end
