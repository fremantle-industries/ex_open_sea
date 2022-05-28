defmodule ExOpenSea.QueryEncoders.WwwForm do
  @moduledoc """
  Encodes enumerable keys and values as "x-www-form-urlencoded". It encodes " " as "+".

  Note "x-www-form-urlencoded" is not specified as part of RFC 3986. However, it is a commonly 
  used format to encode query strings and form data by browsers.
  """

  @behaviour ExOpenSea.QueryEncoder

  @spec encode(Enum.t()) :: String.t()
  def encode(params) do
    URI.encode_query(params, :www_form)
  end
end
