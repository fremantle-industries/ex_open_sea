defmodule ExOpenSea.Collections.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use WithEnv
  alias ExOpenSea.Collections.Index
  doctest ExOpenSea.Collections.Index

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
    use_cassette "collections/index/get_ok" do
      assert {:ok, collections, raw_payload} = Index.get()
      assert Enum.count(collections) != 0
      assert %ExOpenSea.Collection{} = collection = Enum.at(collections, 0)
      assert collection.name != nil
      assert Map.get(raw_payload, "collections") != nil
    end
  end

  test ".get/2 can filter by limit" do
    use_cassette "collections/index/get_filter_limit_ok" do
      assert {:ok, collections, _} = Index.get(%{limit: 1})
      assert Enum.count(collections) == 1
      assert %ExOpenSea.Collection{} = collection = Enum.at(collections, 0)
      assert collection.name != nil
    end
  end

  test ".get/2 can filter by offset" do
    use_cassette "collections/index/get_filter_offset_ok", match_requests_on: [:query] do
      assert {:ok, collections, _} = Index.get(%{limit: 2})
      assert Enum.count(collections) == 2

      assert {:ok, offset_0_collections, _} = Index.get(%{offset: 0, limit: 1})
      assert Enum.count(offset_0_collections) == 1

      assert {:ok, offset_1_collections, _} = Index.get(%{offset: 1, limit: 1})
      assert Enum.count(offset_1_collections) == 1
      assert Enum.at(offset_0_collections, 0) != Enum.at(offset_1_collections, 0)
    end
  end

  test ".get/2 returns an error for negative offsets" do
    use_cassette "collections/index/get_negative_offset_error" do
      assert {:error, error_reasons, raw_reasons} = Index.get(%{offset: -1})
      assert length(error_reasons) == 1

      assert Enum.at(error_reasons, 0) ==
               {"offset", ["ensure this value is greater than or equal to 0"]}

      assert raw_reasons != nil
    end
  end

  test ".get/2 returns an error for negative limit" do
    use_cassette "collections/index/get_negative_limit_error" do
      assert {:error, error_reasons, raw_reasons} = Index.get(%{limit: -1})
      assert length(error_reasons) == 1

      assert Enum.at(error_reasons, 0) ==
               {"limit", ["ensure this value is greater than or equal to 0"]}

      assert raw_reasons != nil
    end
  end

  test ".get/n bubbles error tuples" do
    with_env put: [ex_open_sea: [adapter: ErrorAdapter]] do
      assert Index.get() == {:error, :from_adapter, nil}
    end
  end
end
