defmodule ExOpenSea.Events.ListTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest ExOpenSea.Events.List

  @api_key ExOpenSea.ApiKey.get()

  setup_all do
    HTTPoison.start()
    :ok
  end

  test ".get/1" do
    use_cassette "events/list/get_ok" do
      assert {:ok, events_response} = ExOpenSea.Events.List.get(@api_key)
      assert events_response.asset_events != nil
    end
  end
end
