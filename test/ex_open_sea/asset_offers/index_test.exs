defmodule ExOpenSea.AssetOffers.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use WithEnv
  doctest ExOpenSea.AssetOffers.Index

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
    use_cassette "asset_offers/index/get_ok" do
      assert {:ok, offers} = ExOpenSea.AssetOffers.Index.get(@api_key, @contract_address, @token_id)
      assert length(offers) >= 1
      assert %ExOpenSea.AssetOffer{} = offer = Enum.at(offers, 0)
      assert offer.created_date != nil
    end
  end

  test ".get/2 can filter by limit" do
    use_cassette "asset_offers/index/get_filter_limit_ok", match_requests_on: [:query] do
      assert {:ok, offers} = ExOpenSea.AssetOffers.Index.get(@api_key, @contract_address, @token_id)
      assert length(offers) > 1

      assert {:ok, offers} = ExOpenSea.AssetOffers.Index.get(@api_key, @contract_address, @token_id, %{limit: 1})
      assert length(offers) == 1
    end
  end

  test ".send/1 bubbles adapter errors" do
    with_env put: [ex_open_sea: [adapter: ErrorAdapter]] do
      assert ExOpenSea.AssetOffers.Index.get(@api_key, @contract_address, @token_id) == {:error, :from_adapter}
    end
  end
end
