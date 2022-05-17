use Mix.Config

config :ex_open_sea, api_key: System.get_env("OPEN_SEA_API_KEY")

config :exvcr,
  filter_request_headers: [
    "X-API-KEY"
  ],
  response_headers_blacklist: [
    "Set-Cookie",
    "account-id",
    "ETag",
    "cf-request-id",
    "CF-RAY",
    "X-Trace-Id"
  ]
