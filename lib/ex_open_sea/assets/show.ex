defmodule ExOpenSea.Assets.Show do
  @moduledoc """
  Return information about a single NFT, based on its contract address and token ID. The response
  will contain an Asset Object.

  https://docs.opensea.io/reference/retrieving-a-single-asset
  """

  @type api_key :: ExOpenSea.ApiKey.t()
  @type contract_address :: String.t()
  @type token_id :: non_neg_integer
  @type params :: %{
    optional(:account_address) => String.t(),
    optional(:include_orders) => boolean
  }
  @type assets_cursor :: ExOpenSea.AssetsCursor.t()
  @type error_reason :: :parse_result_item | String.t()
  @type result :: {:ok, assets_cursor} | {:error, error_reason}

  @spec get(api_key, contract_address, token_id) :: result
  @spec get(api_key, contract_address, token_id, params) :: result
  def get(api_key, contract_address, token_id, params \\ %{}) do
    "/api/v1/asset/#{contract_address}/#{token_id}"
    |> ExOpenSea.HTTPClient.auth_get(api_key, params)
    |> parse_response()
  end

  defp parse_response({:ok, data}) do
    Mapail.map_to_struct(data, ExOpenSea.Asset)
  end

  defp parse_response({:error, response_reasons}) when is_map(response_reasons) do
    reasons = response_reasons
              |> Enum.reduce(
                [],
                fn {k, v}, acc ->
                  acc ++ [{k, v}]
                end
              )

    {:error, reasons}
  end

  defp parse_response({:error, _reason} = error) do
    error
  end
end
