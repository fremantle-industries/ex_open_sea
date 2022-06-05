defmodule ExOpenSea.Assets.ShowTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use WithEnv
  doctest ExOpenSea.Assets.Show

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

  @azuki_contract_address "0xed5af388653567af2f388e6224dc7c4b3241c544"

  test ".get/2" do
    use_cassette "assets/show/get_ok" do
      assert {:ok, asset} = ExOpenSea.Assets.Show.get(@api_key, @azuki_contract_address, 1)
      assert %ExOpenSea.Asset{} = asset
      assert asset.name == "Azuki #1"
      assert length(asset.top_ownerships) > 0
      assert asset.ownership == nil
    end
  end

  test ".get/2 can include orders" do
    use_cassette "assets/show/get_include_orders_ok" do
      assert {:ok, asset} = ExOpenSea.Assets.Show.get(@api_key, @azuki_contract_address, 1, %{include_orders: true})
      assert %ExOpenSea.Asset{} = asset
      assert asset.name == "Azuki #1"
      assert length(asset.sell_orders) > 1
      assert length(asset.top_ownerships) > 0
      assert asset.ownership == nil
    end
  end

  test ".get/2 can include asset_contract_address" do
    use_cassette "assets/show/get_asset_contract_address_ok" do
      owner = "0x5117fa741c86921b0910e889d4123ec111349fa3"

      assert {:ok, asset} = ExOpenSea.Assets.Show.get(@api_key, @azuki_contract_address, 1094, %{account_address: owner})
      assert %ExOpenSea.Asset{} = asset
      assert asset.name == "Azuki #1094"
      assert length(asset.top_ownerships) > 0
      assert asset.ownership["owner"] != nil
    end
  end

  test ".get/n bubbles error tuples" do
    with_env put: [ex_open_sea: [adapter: ErrorAdapter]] do
      assert ExOpenSea.Assets.Show.get(@api_key, @azuki_contract_address, 1) == {:error, :from_adapter}
    end
  end
end
