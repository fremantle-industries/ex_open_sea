defmodule ExOpenSea.ApiKey do
  @type t :: String.t()

  @spec get :: t | nil
  def get do
    Application.get_env(:ex_open_sea, :api_key)
  end
end
