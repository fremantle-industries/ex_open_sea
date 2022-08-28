defmodule ExOpenSea.AssetListings.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use WithEnv
  alias ExOpenSea.AssetListings.Index
  doctest ExOpenSea.AssetListings.Index

  @api_key ExOpenSea.ApiKey.get()
  @contract_address "0xbCe3781ae7Ca1a5e050Bd9C4c77369867eBc307e"
  @token_id 6927

  defmodule ErrorAdapter do
    def send(_request) do
      {:error, :from_adapter}
    end
  end

  setup_all do
    HTTPoison.start()
    :ok
  end

  test ".get/1" do
    use_cassette "asset_listings/index/get_ok" do
      assert {:ok, listings, raw_payload} = Index.get(@api_key, @contract_address, @token_id)
      assert length(listings) >= 1
      assert %ExOpenSea.AssetListing{} = listing = Enum.at(listings, 0)
      assert listing.created_date != nil
      assert Map.get(raw_payload, "listings") != nil
    end
  end

  test ".get/2 can filter by limit" do
    use_cassette "asset_listings/index/get_filter_limit_ok", match_requests_on: [:query] do
      assert {:ok, listings, _} = Index.get(@api_key, @contract_address, @token_id)
      assert length(listings) > 1

      assert {:ok, listings, _} = Index.get(@api_key, @contract_address, @token_id, %{limit: 1})
      assert length(listings) == 1
    end
  end

  test ".send/1 bubbles adapter errors" do
    with_env put: [ex_open_sea: [adapter: ErrorAdapter]] do
      assert Index.get(@api_key, @contract_address, @token_id) == {:error, :from_adapter, nil}
    end
  end
end
