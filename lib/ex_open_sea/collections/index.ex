defmodule ExOpenSea.Collections.Index do
  @type api_key :: ExOpenSea.ApiKey.t()
  @type params :: %{
    optional(:asset_owner) => String.t(),
    optional(:offset) => non_neg_integer,
    optional(:limit) => non_neg_integer,
  }
  @type collection :: ExOpenSea.Collection.t()
  @type error_reason :: :parse_result_item | String.t()
  @type result :: {:ok, [collection]} | {:error, error_reason}

  @spec get(api_key) :: result
  @spec get(api_key, params) :: result
  def get(api_key, params \\ %{}) do
    "/api/v1/collections"
    |> ExOpenSea.HTTPClient.auth_get(api_key, params)
    |> parse_response()
  end

  defp parse_response({:ok, %{"collections" => collections}}) do
    collections
    |> Enum.map(&Mapail.map_to_struct(&1, ExOpenSea.Collection))
    |> Enum.reduce(
      {:ok, []},
      fn
        {:ok, i}, {:ok, acc} -> {:ok, [i | acc]}
        _, _acc -> {:error, :parse_result_item}
      end
    )
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
