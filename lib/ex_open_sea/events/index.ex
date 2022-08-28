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
  @type raw_payload :: map
  @type result :: {:ok, events_response, raw_payload} | {:error, error_reason, raw_payload | nil}

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

  defp parse_response({:ok, %{"asset_events" => raw_asset_events} = raw_payload}) do
    {ok_or_error, events_response_or_reason} =
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
          %{raw_payload | "asset_events" => asset_events}
          |> Mapail.map_to_struct(ExOpenSea.EventsResponse)

        {:error, _} = error ->
          error
      end

    {ok_or_error, events_response_or_reason, raw_payload}
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
