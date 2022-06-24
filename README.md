# ExOpenSea
[![Build Status](https://github.com/fremantle-industries/ex_open_sea/workflows/test/badge.svg?branch=main)](https://github.com/fremantle-industries/ex_open_sea/actions?query=workflow%3Atest)
[![hex.pm version](https://img.shields.io/hexpm/v/ex_open_sea.svg?style=flat)](https://hex.pm/packages/ex_open_sea)

OpenSea API client for Elixir

## Installation

Add the `ex_open_sea` package to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_open_sea, "~> 0.0.6"}
  ]
end
```

## Requirements

- Erlang 22+
- Elixir 1.13+

## API Documentation

https://docs.opensea.io/reference/api-overview

## REST API

#### Assets

- [x] `GET /api/v1/assets`
- [x] `GET /api/v1/asset/{asset_contract_address}/{token_id}/`
- [ ] `GET /api/v1/asset/{asset_contract_address}/{token_id}/validate`
- [x] `GET /api/v1/asset/{asset_contract_address}/{token_id}/listings`
- [x] `GET /api/v1/asset/{asset_contract_address}/{token_id}/offers`

#### Events

- [x] `GET /api/v1/events`

#### Collections

- [x] `GET /api/v1/collections`
- [x] `GET /api/v1/collection/{collection_slug}`

#### Bundles

- [ ] `GET /api/v1/bundles`

#### Contracts

- [ ] `GET /api/v1/asset_contract/{asset_contract_address}`

#### Orders

- [ ] `GET /wyvern/v1/orders`

## Authors

- Alex Kwiatkowski - alex+git@fremantle.io

## License

`ex_open_sea` is released under the [MIT license](./LICENSE)
