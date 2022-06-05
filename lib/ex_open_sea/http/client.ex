defmodule ExOpenSea.Http.Client do
  alias ExOpenSea.Http

  @type request :: Http.Request.t()
  @type data :: map | list
  @type error_reason :: Jason.DecodeError.t() | Http.Adapter.error_reason()
  @type result :: {:ok, data} | {:error, error_reason}

  @spec domain :: String.t()
  def domain, do: Application.get_env(:ex_open_sea, :domain, "api-devnet.magiceden.dev")

  @spec protocol :: String.t()
  def protocol, do: Application.get_env(:ex_open_sea, :protocol, "https")

  @spec adapter :: module
  def adapter, do: Application.get_env(:ex_open_sea, :adapter, Http.HTTPoisonAdapter)

  @spec get(request) :: result
  def get(request) do
    request
    |> Http.Request.with_method(:get)
    |> send()
  end

  @spec send(request) :: result
  def send(request) do
    http_adapter = adapter()

    request
    |> Http.Request.with_protocol(protocol())
    |> Http.Request.with_domain(domain())
    |> http_adapter.send()
    |> parse_response()
  end

  defp parse_response({:ok, %Http.Response{status_code: status_code, body: body}}) do
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

  defp parse_response({:error, _reason} = error) do
    error
  end
end
