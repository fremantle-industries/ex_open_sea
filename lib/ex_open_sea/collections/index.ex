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
  @type result :: {:ok, [collection]} | {:error, error_reason}

  @spec get(params) :: result
  def get(params \\ %{}) do
    "/api/v1/collections"
    |> Http.Request.for_path()
    |> Http.Request.with_query(params)
    |> Http.Client.get()
    |> parse_response()
  end

  defp parse_response({:ok, %{"collections" => raw_collections}}) do
    raw_collections
    |> Enum.map(fn %{"traits" => raw_traits} = c ->
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
          %{c | "traits" => traits}
          |> Mapail.map_to_struct(ExOpenSea.Collection)

        {:error, _} = error ->
          error
      end
    end)
    |> Enum.reduce(
      {:ok, []},
      fn
        {:ok, i}, {:ok, acc} -> {:ok, [i | acc]}
        _, _acc -> {:error, :parse_result_item}
      end
    )
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
