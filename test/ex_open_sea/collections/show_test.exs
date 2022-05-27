defmodule ExOpenSea.Collections.ShowTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Mock
  doctest ExOpenSea.Collections.Show

  @api_key ExOpenSea.ApiKey.get()

  setup_all do
    HTTPoison.start()
    :ok
  end

  test ".get/2" do
    use_cassette "collections/show/get_ok" do
      assert {:ok, collection} = ExOpenSea.Collections.Show.get("azuki", @api_key)
      assert collection.name != nil
    end
  end

  test ".get/2 returns an error when the collection doesn't exist" do
    use_cassette "collections/show/get_not_found_error" do
      assert ExOpenSea.Collections.Show.get("i_dont_exist", @api_key) == {:error, :not_found}
    end
  end

  test ".get/2 bubbles error tuples" do
    with_mock HTTPoison, request: fn _url -> {:error, %HTTPoison.Error{reason: :timeout}} end do
      assert ExOpenSea.Collections.Show.get("ze-timeout", @api_key) == {:error, :timeout}
    end
  end
end
