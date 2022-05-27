defmodule ExOpenSea.HTTPClient do
  @type verb :: :get | :post | :put | :delete
  @type params :: map
  @type path :: String.t()
  @type uri :: String.t()
  @type api_key :: String.t()
  @type error_reason :: :timeout | Maptu.Extension.non_strict_error_reason() | HTTPoison.Error.t() | map
  @type auth_response :: {:ok, map} | {:error, error_reason}

  @spec domain :: String.t()
  def domain, do: Application.get_env(:ex_open_sea, :domain, "api.opensea.io")

  @spec protocol :: String.t()
  def protocol, do: Application.get_env(:ex_open_sea, :protocol, "https://")

  @spec origin :: String.t()
  def origin, do: protocol() <> domain()

  @spec url(uri) :: String.t()
  def url(uri), do: origin() <> uri

  @spec auth_get(path, api_key, params) :: auth_response
  def auth_get(path, api_key, params) do
    auth_request(:get, path |> to_uri(params), api_key, "")
  end

  @spec auth_post(path, api_key, params) :: auth_response
  def auth_post(path, api_key, params) do
    uri = path |> to_uri(%{})
    body = Jason.encode!(params)
    auth_request(:post, uri, api_key, body)
  end

  @spec auth_request(verb, uri, api_key, term) :: auth_response
  def auth_request(verb, uri, api_key, body) do
    headers =
      api_key
      |> auth_headers()
      |> put_content_type(:json)

    %HTTPoison.Request{
      method: verb,
      url: url(uri),
      headers: headers,
      body: body
    }
    |> send
  end

  defp to_uri(path, params) do
    %URI{
      path: path,
      query: URI.encode_query(params)
    }
    |> URI.to_string()
    |> String.trim("?")
  end

  defp put_content_type(headers, :json) do
    Keyword.put(headers, :"Content-Type", "application/json")
  end

  defp send(request) do
    request
    |> HTTPoison.request()
    |> parse_response
  end

  defp auth_headers(api_key) do
    ["X-API-KEY": api_key]
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    cond do
      status_code >= 200 && status_code < 300 ->
        Jason.decode(body)

      status_code >= 400 && status_code < 500 ->
        case Jason.decode(body) do
          {:ok, json} -> {:error, json}
          {:error, _} = result -> result
        end

      true ->
        {:error, body}
    end
  end

  defp parse_response({:error, %HTTPoison.Error{reason: :timeout}}) do
    {:error, :timeout}
  end

  defp parse_response({:error, _} = result) do
    result
  end
end
