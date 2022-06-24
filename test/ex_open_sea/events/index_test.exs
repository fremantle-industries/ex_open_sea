defmodule ExOpenSea.Events.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use WithEnv
  doctest ExOpenSea.Events.Index

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
    use_cassette "events/index/get_ok" do
      assert {:ok, events_response} = ExOpenSea.Events.Index.get(@api_key)
      assert length(events_response.asset_events) > 1
      assert %ExOpenSea.AssetEvent{} = asset_event = Enum.at(events_response.asset_events, 0)
      assert asset_event.event_type != nil
    end
  end

  test ".get/1 bubbles error tuples" do
    with_env put: [ex_open_sea: [adapter: ErrorAdapter]] do
      assert ExOpenSea.Events.Index.get(@api_key) == {:error, :from_adapter}
    end
  end
end
