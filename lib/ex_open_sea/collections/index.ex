defmodule ExOpenSea.Collections.Index do
  @moduledoc """
  Return a list of all the collections supported and vetted by OpenSea. To include all collections
  relevant to a user (including non-whitelisted ones) include the `asset_owner` parameter.

  Each collection in the response has an attribute called `primary_asset_contracts` with info about
  the smart contracts belonging to that collection. For example, ERC-1155 contracts maybe have
  multiple collections all referencing the same contract, but many ERC-721 contracts may all
  belong to the same collection (dapp).

  You can also use this endpoint to find which dapps an account uses, and how many items they own
  in each in a single API call.

  https://docs.opensea.io/reference/retrieving-collections
  """

  alias ExOpenSea.Http

  @type params :: %{
          optional(:asset_owner) => String.t(),
          optional(:offset) => non_neg_integer,
          optional(:limit) => non_neg_integer
        }
  @type collection :: ExOpenSea.Collection.t()
  @type error_reason :: :parse_result_item | String.t()
  @type raw_payload :: map
  @type result :: {:ok, [collection], raw_payload} | {:error, error_reason, raw_payload | nil}

  @spec get(params) :: result
  def get(params \\ %{}) do
    "/api/v1/collections"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, %{"collections" => raw_collections} = raw_payload}) do
    {ok_or_error, parsed_collections} =
      raw_collections
      |> Enum.map(&Mapail.map_to_struct(&1, ExOpenSea.Collection))
      |> Enum.reduce(
        {:ok, []},
        fn
          {:ok, c}, {:ok, acc} -> {:ok, [c | acc]}
          _, _acc -> {:error, :parse_result_item}
        end
      )

    {ok_or_error, parsed_collections, raw_payload}
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
