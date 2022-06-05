defmodule ExOpenSea.Http.HTTPoisonAdapter do
  alias ExOpenSea.Http

  @behaviour Http.Adapter

  @impl true
  def send(request) do
    url = Http.Request.url(request)

    %HTTPoison.Request{
      method: request.method,
      url: url,
      headers: request.headers,
      body: request.body || ""
    }
    |> HTTPoison.request()
    |> map_response()
  end

  defp map_response({:ok, %HTTPoison.Response{} = httpoison_response}) do
    response = %Http.Response{
      status_code: httpoison_response.status_code,
      body: httpoison_response.body
    }
    {:ok, response}
  end

  defp map_response({:error, reason} = error) do
    case reason do
      %HTTPoison.Error{reason: :timeout} -> {:error, :timeout}
      %HTTPoison.Error{reason: "nxdomain"} -> {:error, :nxdomain}
      _ -> error
    end
  end
end
