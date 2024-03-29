defmodule ExOpenSea.AssetListings.Index do
  @moduledoc """
  Return active listings on a given NFT

  https://docs.opensea.io/reference/asset-listings
  """

  alias ExOpenSea.Http

  @type api_key :: ExOpenSea.ApiKey.t()
  @type contract_address :: String.t()
  @type token_id :: non_neg_integer
  @type params :: %{
          optional(:limit) => String.t()
        }
  @type listing :: ExOpenSea.AssetListing.t()
  @type error_reason :: :parse_result_item | String.t()
  @type result :: {:ok, [listing]} | {:error, error_reason}

  @spec get(api_key, contract_address, token_id) :: result
  @spec get(api_key, contract_address, token_id, params) :: result
  def get(api_key, contract_address, token_id, params \\ %{}) do
    "/api/v1/asset/#{contract_address}/#{token_id}/listings"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params)
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, %{"listings" => listings} = raw_payload}) do
    {ok_or_error, parsed_listings} =
      listings
      |> Enum.map(&Mapail.map_to_struct(&1, ExOpenSea.AssetListing))
      |> Enum.reduce(
        {:ok, []},
        fn
          {:ok, i}, {:ok, acc} -> {:ok, [i | acc]}
          _, _acc -> {:error, :parse_result_item}
        end
      )

    {ok_or_error, parsed_listings, raw_payload}
  end

  defp parse_response({:error, response_reasons}) when is_map(response_reasons) do
    reasons =
      response_reasons
      |> Enum.reduce(
        [],
        fn {k, v}, acc ->
          acc ++ [{k, v}]
        end
      )

    {:error, reasons}
  end

  defp parse_response({:error, reason}) do
    {:error, reason, nil}
  end
end
