defmodule ExOpenSea.Events.IndexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Mock
  doctest ExOpenSea.Events.Index

  @api_key ExOpenSea.ApiKey.get()

  setup_all do
    HTTPoison.start()
    :ok
  end

  test ".get/1" do
    use_cassette "events/index/get_ok" do
      assert {:ok, events_response} = ExOpenSea.Events.Index.get(@api_key)
      assert events_response.asset_events != nil
    end
  end

  test ".get/1 bubbles error tuples" do
    with_mock HTTPoison, request: fn _url -> {:error, %HTTPoison.Error{reason: :timeout}} end do
      assert ExOpenSea.Events.Index.get(@api_key) == {:error, :timeout}
    end
  end
end
