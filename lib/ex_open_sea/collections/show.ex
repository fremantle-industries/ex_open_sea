defmodule ExOpenSea.Collections.Show do
  @moduledoc """
  Return in-depth information about an individual collection, including real time statistics such
  as floor price.

  https://docs.opensea.io/reference/retrieving-a-single-collection
  """

  alias ExOpenSea.Http

  @type slug :: ExOpenSea.Collection.slug()
  @type api_key :: ExOpenSea.ApiKey.t()
  @type collection :: ExOpenSea.Collection.t()
  @type error_reason :: :not_found | :parse_result_item | String.t()
  @type raw_payload :: map
  @type result :: {:ok, collection, raw_payload} | {:error, error_reason, raw_payload | nil}

  @spec get(slug, api_key) :: result
  def get(collection_slug, api_key) do
    "/api/v1/collection/#{collection_slug}"
    |> Http.Request.for_path()
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, %{"collection" => raw_collection} = raw_payload}) do
    {ok_or_error, collection_or_reason} =
      Mapail.map_to_struct(raw_collection, ExOpenSea.Collection)

    {ok_or_error, collection_or_reason, raw_payload}
  end

  defp parse_response({:error, %{"success" => false} = raw_payload}) do
    {:error, :not_found, raw_payload}
  end

  defp parse_response({:error, reason}) do
    {:error, reason, nil}
  end
end
