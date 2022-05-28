defmodule ExOpenSea.QueryEncoders.SingleKeyMultipleValueWwwForm do
  @moduledoc """
  Encode parameters with multiple values for the same key in the OpenSea accepted format.

  e.g. https://docs.opensea.io/reference/getting-assets

  - token_ids: string
    An array of token IDs to search for (e.g. ?token_ids=1&token_ids=209). Will return a list 
    of assets with token_id matching any of the IDs in this array.
  """

  @behaviour ExOpenSea.QueryEncoder

  @spec encode(Enum.t()) :: String.t()
  def encode(params) do
    params
    |> Enum.reduce(
      [],
      fn
        {k, values}, acc when is_list(values) ->
          multi = values |> Enum.map(fn v -> {k, v} end)
          multi ++ acc

        {k, v}, acc ->
          [{k, v} | acc]
      end
    )
    |> Enum.map(fn {k, v} ->
      encoded_key = encode_www_form(k)
      encoded_value = encode_www_form(v)
      "#{encoded_key}=#{encoded_value}"
    end)
    |> Enum.join("&")
  end

  defp encode_www_form(v) when is_atom(v), do: v |> Atom.to_string() |> encode_www_form()
  defp encode_www_form(v) when is_integer(v), do: v |> Integer.to_string() |> encode_www_form()
  defp encode_www_form(v) when is_float(v), do: v |> Float.to_string() |> encode_www_form()
  defp encode_www_form(v), do: v |> URI.encode_www_form()
end
