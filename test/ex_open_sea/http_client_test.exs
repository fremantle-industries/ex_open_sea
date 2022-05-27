defmodule ExOpenSea.HttpClientTest do
  use ExUnit.Case, async: false
  import Mock
  doctest ExOpenSea.HTTPClient

  @api_key ExOpenSea.ApiKey.get()

  setup_all do
    HTTPoison.start()
    :ok
  end

  test "returns an error tuple for a HTTP timeout" do
    with_mock HTTPoison, request: fn _url -> {:error, %HTTPoison.Error{reason: :timeout}} end do
      assert ExOpenSea.HTTPClient.auth_get("/api/v1/collection/azuki", @api_key, %{}) == {:error, :timeout}
    end
  end
end
