defmodule ExOpenSea.Assets.Index do
  @moduledoc """
  Return a cursor to a list of NFTs based on the specified filter parameters.

  Auctions created on OpenSea don't use an escrow contract, which enables gas-free auctions and
  allows users to retain ownership of their items while they're on sale. In these cases, some
  NFTs from opensea.io may not appear in the API until a transaction has been completed.

  https://docs.opensea.io/reference/getting-assets
  """

  alias ExOpenSea.Http

  @type api_key :: ExOpenSea.ApiKey.t()
  @type params :: %{
          optional(:owner) => String.t(),
          optional(:token_ids) => [String.t()],
          # unsure how :collection is different to :collection_slug based on the docs???
          optional(:collection) => String.t(),
          optional(:collection_slug) => String.t(),
          optional(:order_direction) => String.t(),
          optional(:asset_contract_address) => String.t(),
          optional(:asset_contract_addresses) => [String.t()],
          optional(:limit) => String.t(),
          optional(:cursor) => String.t(),
          optional(:include_orders) => boolean
        }
  @type assets_cursor :: ExOpenSea.AssetsCursor.t()
  @type error_reason :: :parse_result_item | String.t()
  @type raw_payload :: map
  @type result :: {:ok, assets_cursor} | {:error, error_reason, raw_payload | nil}

  @query_encoder ExOpenSea.QueryEncoders.SingleKeyMultipleValueWwwForm

  @spec get(api_key) :: result
  @spec get(api_key, params) :: result
  def get(api_key, params \\ %{}) do
    "/api/v1/assets"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params, @query_encoder)
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({
         :ok,
         %{"assets" => assets, "next" => next, "previous" => previous} = raw_payload
       }) do
    assets
    |> Enum.map(&Mapail.map_to_struct(&1, ExOpenSea.Asset))
    |> Enum.reduce(
      {:ok, []},
      fn
        {:ok, a}, {:ok, acc} -> {:ok, acc ++ [a]}
        _, _acc -> {:error, :parse_result_item}
      end
    )
    |> case do
      {:ok, struct_assets} ->
        asset_cursor = %ExOpenSea.AssetsCursor{
          assets: struct_assets,
          next: next,
          previous: previous
        }

        {:ok, asset_cursor, raw_payload}

      {:error, reason} ->
        {:error, reason, raw_payload}
    end
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

    {:error, reasons, nil}
  end

  defp parse_response({:error, reason}) do
    {:error, reason, nil}
  end
end
