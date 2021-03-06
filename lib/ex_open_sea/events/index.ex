defmodule ExOpenSea.Events.Index do
  @moduledoc """
  Return a list of events that occur on the NFTs that are tracked by OpenSea. The event_type field
  indicates the type of event (transfer, successful auction, etc) and the results are sorted by
  event timestamp.

  Note that due to block reorganizations, recent events (less than 10 minutes old) may not reflect
  the final state of the blockchain.

  https://docs.opensea.io/reference/retrieving-asset-events
  """

  alias ExOpenSea.Http

  @type api_key :: ExOpenSea.ApiKey.t()
  @type params :: %{
          optional(:only_opensea) => boolean,
          optional(:token_id) => non_neg_integer,
          optional(:collection_slug) => String.t(),
          optional(:collection_editor) => String.t(),
          optional(:account_address) => String.t(),
          optional(:event_type) => String.t(),
          optional(:auction_type) => String.t(),
          optional(:occured_before) => non_neg_integer,
          optional(:cursor) => String.t()
        }
  @type events_response :: ExOpenSea.EventsResponse.t()
  @type error_reason :: :parse_result_item | String.t()
  @type result :: {:ok, events_response} | {:error, error_reason}

  @spec get(api_key) :: result
  @spec get(api_key, params) :: result
  def get(api_key, params \\ %{}) do
    "/api/v1/events"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params)
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, %{"asset_events" => raw_asset_events} = data}) do
    raw_asset_events
    |> Enum.map(&Mapail.map_to_struct(&1, ExOpenSea.AssetEvent))
    |> Enum.reduce(
      {:ok, []},
      fn
        {:ok, i}, {:ok, acc} -> {:ok, [i | acc]}
        _, _acc -> {:error, :parse_result_item}
      end
    )
    |> case do
      {:ok, asset_events} ->
        %{data | "asset_events" => asset_events}
        |> Mapail.map_to_struct(ExOpenSea.EventsResponse)

      {:error, _} = error ->
        error
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

    {:error, reasons}
  end

  defp parse_response({:error, _reason} = error) do
    error
  end
end
