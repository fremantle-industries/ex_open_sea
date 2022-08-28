defmodule ExOpenSea.Collections.ShowTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use WithEnv
  alias ExOpenSea.Collections.Show
  doctest ExOpenSea.Collections.Show

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

  test ".get/2" do
    use_cassette "collections/show/get_ok" do
      assert {:ok, collection, raw_payload} = Show.get("azuki", @api_key)
      assert collection.name != nil
      assert Map.get(raw_payload, "collection") != nil
    end
  end

  test ".get/2 returns an error when the collection doesn't exist" do
    use_cassette "collections/show/get_not_found_error" do
      assert {:error, :not_found, raw_payload} = Show.get("i_dont_exist", @api_key)
      assert Map.get(raw_payload, "success") == false
    end
  end

  test ".get/2 bubbles error tuples" do
    with_env put: [ex_open_sea: [adapter: ErrorAdapter]] do
      assert Show.get("ze-timeout", @api_key) == {:error, :from_adapter, nil}
    end
  end
end
