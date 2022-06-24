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
  @type asset :: ExOpenSea.Asset.t()
  @type error_reason :: :parse_result_item | String.t()
  @type result :: {:ok, asset} | {:error, error_reason}

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

  defp parse_response({:ok, %{"traits" => raw_traits} = data}) do
    raw_traits
    |> Enum.map(&Mapail.map_to_struct(&1, ExOpenSea.Trait))
    |> Enum.reduce(
      {:ok, []},
      fn
        {:ok, i}, {:ok, acc} -> {:ok, [i | acc]}
        _, _acc -> {:error, :parse_result_item}
      end
    )
    |> case do
      {:ok, traits} ->
        %{data | "traits" => traits}
        |> Mapail.map_to_struct(ExOpenSea.Asset)

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
