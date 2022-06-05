defmodule ExOpenSea.Http.HTTPoisonAdapterTest do
  use ExUnit.Case, async: false
  import Mock
  alias ExOpenSea.Http
  doctest ExOpenSea.Http.HTTPoisonAdapter

  setup_all do
    HTTPoison.start()
    :ok
  end

  test "returns an error tuple for a HTTP timeout" do
    with_mock HTTPoison, request: fn _url -> {:error, %HTTPoison.Error{reason: :timeout}} end do
      request = Http.Request.for_path("/v2/collections")
      assert Http.HTTPoisonAdapter.send(request) == {:error, :timeout}
    end
  end

  test "returns an error tuple for a domain lookup failure" do
    with_mock HTTPoison, request: fn _url -> {:error, %HTTPoison.Error{reason: "nxdomain"}} end do
      request = Http.Request.for_path("/v2/collections")
      assert Http.HTTPoisonAdapter.send(request) == {:error, :nxdomain}
    end
  end
end
