defmodule ExOpenSea.Assets.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use WithEnv
  doctest ExOpenSea.Assets.Index

  @api_key ExOpenSea.ApiKey.get()

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
    use_cassette "assets/index/get_ok" do
      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key)
      assert length(cursor.assets) != 0
      assert %ExOpenSea.Asset{} = asset = Enum.at(cursor.assets, 0)
      assert asset.name != nil
    end
  end

  test ".get/2 can filter by collection" do
    use_cassette "assets/index/get_filter_collection_ok" do
      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, %{collection: "doodles-official"})
      assert length(cursor.assets) == 20
      assert Enum.all?(cursor.assets, & String.starts_with?(&1.name, "Doodle")) == true
    end
  end

  test ".get/2 can filter by collection_slug" do
    use_cassette "assets/index/get_filter_collection_slug_ok" do
      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, %{collection_slug: "azuki"})
      assert length(cursor.assets) == 20
      assert Enum.all?(cursor.assets, & String.starts_with?(&1.name, "Azuki")) == true
    end
  end

  test ".get/2 can filter by token_ids" do
    use_cassette "assets/index/get_filter_token_ids_ok" do
      token_ids = [1, 2]
      str_token_ids = token_ids |> Enum.map(&Integer.to_string/1)

      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, %{collection_slug: "azuki", token_ids: token_ids})
      assert length(cursor.assets) == 2
      assert %ExOpenSea.Asset{} = asset_1 = Enum.at(cursor.assets, 0)
      assert Enum.member?(str_token_ids, asset_1.token_id) == true
      assert %ExOpenSea.Asset{} = asset_2 = Enum.at(cursor.assets, 1)
      assert Enum.member?(str_token_ids, asset_2.token_id) == true
    end
  end

  test ".get/2 can filter by owner" do
    use_cassette "assets/index/get_filter_owner_ok" do
      owner = "0x5117fa741c86921b0910e889d4123ec111349fa3"

      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, %{collection_slug: "azuki", owner: owner})
      assert length(cursor.assets) == 1
      assert %ExOpenSea.Asset{} = asset = Enum.at(cursor.assets, 0)
      assert asset.name == "Azuki #1094"
      assert asset.owner["address"] == owner
    end
  end

  # NOTE: ocm-dessert is an ERC-1155 contract and seems like it should return multiple sell orders
  # - is this a bug in the OpenSea API?
  # - are these the correct parameters to get multiple orders from a single request?
  test ".get/2 can filter by order_direction" do
    use_cassette "assets/index/get_filter_order_direction_ok" do
      params = %{collection_slug: "ocm-dessert", token_ids: [1], include_orders: true, order_direction: "desc"}

      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, params)
      assert length(cursor.assets) == 1
      assert %ExOpenSea.Asset{} = asset = Enum.at(cursor.assets, 0)
      assert length(asset.sell_orders) == 1
    end
  end

  @azuki_contract_address "0xed5af388653567af2f388e6224dc7c4b3241c544"
  @doodles_contract_address "0x8a90cab2b38dba80c64b7734e58ee1db38b8992e"

  test ".get/2 can filter by asset_contract_address" do
    use_cassette "assets/index/get_filter_asset_contract_address_ok", match_requests_on: [:query] do
      assert {:ok, cursor_1} = ExOpenSea.Assets.Index.get(@api_key, %{asset_contract_address: @azuki_contract_address, limit: 1})
      assert length(cursor_1.assets) == 1
      assert %ExOpenSea.Asset{} = asset_1 = Enum.at(cursor_1.assets, 0)
      assert asset_1.collection["name"] == "Azuki"

      assert {:ok, cursor_2} = ExOpenSea.Assets.Index.get(@api_key, %{asset_contract_address: @doodles_contract_address, limit: 1})
      assert length(cursor_2.assets) == 1
      assert %ExOpenSea.Asset{} = asset_2 = Enum.at(cursor_2.assets, 0)
      assert asset_2.collection["name"] == "Doodles"
    end
  end

  test ".get/2 can filter by asset_contract_addresses" do
    use_cassette "assets/index/get_filter_asset_contract_addresses_ok" do
      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, %{asset_contract_addresses: [@azuki_contract_address, @doodles_contract_address], token_ids: [1, 1]})
      assert length(cursor.assets) == 2
      assert %ExOpenSea.Asset{} = asset_1 = Enum.at(cursor.assets, 0)
      assert asset_1.collection["name"] == "Azuki"
      assert %ExOpenSea.Asset{} = asset_2 = Enum.at(cursor.assets, 1)
      assert asset_2.collection["name"] == "Doodles"
    end
  end

  test ".get/2 can filter by limit" do
    use_cassette "assets/index/get_filter_limit_ok" do
      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, %{collection_slug: "azuki", limit: 1})
      assert length(cursor.assets) == 1
      assert %ExOpenSea.Asset{} = asset = Enum.at(cursor.assets, 0)
      assert String.starts_with?(asset.name, "Azuki") == true
    end
  end

  test ".get/2 can filter by cursor" do
    use_cassette "assets/index/get_filter_cursor_ok", match_requests_on: [:query] do
      assert {:ok, cursor_1} = ExOpenSea.Assets.Index.get(@api_key, %{limit: 1})
      assert length(cursor_1.assets) == 1
      assert %ExOpenSea.Asset{} = asset_1 = Enum.at(cursor_1.assets, 0)
      assert asset_1.name != nil

      assert {:ok, page_2} = ExOpenSea.Assets.Index.get(@api_key, %{cursor: cursor_1.next, limit: 1})
      assert length(page_2.assets) == 1
      assert %ExOpenSea.Asset{} = asset_2 = Enum.at(page_2.assets, 0)
      assert asset_2.name != nil

      assert page_2.previous != cursor_1.next
      assert asset_1.name != asset_2.name
    end
  end

  test ".get/2 can filter by include_orders" do
    use_cassette "assets/index/get_filter_include_orders_ok" do
      assert {:ok, cursor} = ExOpenSea.Assets.Index.get(@api_key, %{collection_slug: "azuki", token_ids: [1378], include_orders: true})
      assert %ExOpenSea.Asset{} = asset = Enum.at(cursor.assets, 0)
      assert length(asset.sell_orders) == 1
    end
  end

  test ".get/n bubbles error tuples" do
    with_env put: [ex_open_sea: [adapter: ErrorAdapter]] do
      assert ExOpenSea.Assets.Index.get(@api_key) == {:error, :from_adapter}
    end
  end
end
