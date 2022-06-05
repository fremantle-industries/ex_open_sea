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
  @type result :: {:ok, collection} | {:error, error_reason}

  @spec get(slug, api_key) :: result
  def get(collection_slug, api_key) do
    "/api/v1/collection/#{collection_slug}"
    |> Http.Request.for_path()
    |> Http.Request.with_auth(api_key)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, %{"collection" => collection}}) do
    Mapail.map_to_struct(collection, ExOpenSea.Collection)
  end

  defp parse_response({:error, %{"success" => false}}) do
    {:error, :not_found}
  end

  defp parse_response({:error, _reason} = error) do
    error
  end
end
