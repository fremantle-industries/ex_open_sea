defmodule ExOpenSea.Assets.Show do
  @moduledoc """
  Return information about a single NFT, based on its contract address and token ID. The response
  will contain an Asset Object.

  https://docs.opensea.io/reference/retrieving-a-single-asset
  """

  alias ExOpenSea.Http

  @type api_key :: ExOpenSea.ApiKey.t()
  @type contract_address :: String.t()
  @type token_id :: non_neg_integer
  @type params :: %{
          optional(:account_address) => String.t(),
          optional(:include_orders) => boolean
        }
  @type assets_cursor :: ExOpenSea.AssetsCursor.t()
  @type error_reason :: Maptu.non_strict_error_reason() | String.t()
  @type raw_payload :: map
  @type result :: {:ok, assets_cursor, raw_payload} | {:error, error_reason, raw_payload | nil}

  @spec get(api_key, contract_address, token_id) :: result
  @spec get(api_key, contract_address, token_id, params) :: result
  def get(api_key, contract_address, token_id, params \\ %{}) do
    "/api/v1/asset/#{contract_address}/#{token_id}"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params)
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, raw_payload}) do
    {ok_or_error, asset_or_reason} = Mapail.map_to_struct(raw_payload, ExOpenSea.Asset)
    {ok_or_error, asset_or_reason, raw_payload}
  end

  defp parse_response({:error, raw_reasons}) when is_map(raw_reasons) do
    reasons =
      raw_reasons
      |> Enum.reduce(
        [],
        fn {k, v}, acc ->
          acc ++ [{k, v}]
        end
      )

    {:error, reasons, raw_reasons}
  end

  defp parse_response({:error, reason}) do
    {:error, reason, nil}
  end
end
