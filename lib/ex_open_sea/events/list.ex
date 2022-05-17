defmodule ExOpenSea.Events.List do
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
  @type result :: {:ok, [events_response]} | {:error, error_reason}

  @spec get(api_key) :: result
  @spec get(api_key, params) :: result
  def get(api_key, params \\ %{}) do
    "/api/v1/events"
    |> ExOpenSea.HTTPClient.auth_get(api_key, params)
    |> parse_response()
  end

  defp parse_response({:ok, events_response}) do
    Mapail.map_to_struct(events_response, ExOpenSea.EventsResponse)
  end

  defp parse_response({:error, response_reasons}) do
    reasons = response_reasons
              |> Enum.reduce(
                [],
                fn {k, v}, acc ->
                  acc ++ [{k, v}]
                end
              )

    {:error, reasons}
  end
end
