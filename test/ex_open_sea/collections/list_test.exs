defmodule ExOpenSea.Collections.ListTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Mock
  doctest ExOpenSea.Collections.List

  @api_key ExOpenSea.ApiKey.get()

  setup_all do
    HTTPoison.start()
    :ok
  end

  test ".get/1" do
    use_cassette "collections/list/get_ok" do
      assert {:ok, collections} = ExOpenSea.Collections.List.get(@api_key)
      assert Enum.count(collections) != 0
      assert %ExOpenSea.Collection{} = collection = Enum.at(collections, 0)
      assert collection.name != nil
    end
  end

  test ".get/2 can filter by limit" do
    use_cassette "collections/list/get_filter_limit_ok" do
      assert {:ok, collections} = ExOpenSea.Collections.List.get(@api_key, %{limit: 1})
      assert Enum.count(collections) == 1
      assert %ExOpenSea.Collection{} = collection = Enum.at(collections, 0)
      assert collection.name != nil
    end
  end

  test ".get/2 can filter by offset" do
    use_cassette "collections/list/get_filter_offset_ok", match_requests_on: [:query] do
      assert {:ok, collections} = ExOpenSea.Collections.List.get(@api_key, %{limit: 2})
      assert Enum.count(collections) == 2

      assert {:ok, offset_0_collections} = ExOpenSea.Collections.List.get(@api_key, %{offset: 0, limit: 1})
      assert Enum.count(offset_0_collections) == 1

      assert {:ok, offset_1_collections} = ExOpenSea.Collections.List.get(@api_key, %{offset: 1, limit: 1})
      assert Enum.count(offset_1_collections) == 1

      assert Enum.at(offset_0_collections, 0) != Enum.at(offset_1_collections, 0)
    end
  end

  test ".get/2 returns an error for negative offsets" do
    use_cassette "collections/list/get_negative_offset_error" do
      assert {:error, error_reasons} = ExOpenSea.Collections.List.get(@api_key, %{offset: -1})
      assert length(error_reasons) == 1
      assert Enum.at(error_reasons, 0) == {"offset", ["ensure this value is greater than or equal to 0"]}
    end
  end

  test ".get/2 returns an error for negative limit" do
    use_cassette "collections/list/get_negative_limit_error" do
      assert {:error, error_reasons} = ExOpenSea.Collections.List.get(@api_key, %{limit: -1})
      assert length(error_reasons) == 1
      assert Enum.at(error_reasons, 0) == {"limit", ["ensure this value is greater than or equal to 0"]}
    end
  end

  test ".get/n bubbles error tuples" do
    with_mock HTTPoison, request: fn _url -> {:error, %HTTPoison.Error{reason: :timeout}} end do
      assert ExOpenSea.Collections.List.get(@api_key) == {:error, :timeout}
    end
  end
end
