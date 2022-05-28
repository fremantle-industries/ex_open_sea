defmodule ExOpenSea.Asset do
  @type slug :: String.t()
  @type t :: %__MODULE__{
    id: non_neg_integer,
    num_sales: non_neg_integer,
    background_color: String.t() | nil,
    image_url: String.t(),
    image_preview_url: String.t(),
    image_thumbnail_url: String.t(),
    image_original_url: String.t(),
    animation_url: String.t() | nil,
    animation_original_url: String.t() | nil,
    name: String.t(),
    description: String.t() | nil,
    external_link: String.t(),
    asset_contract: map,
    permalink: String.t(),
    collection: String.t(),
    decimals: non_neg_integer | nil,
    token_metadata: String.t(),
    is_nsfw: boolean,
    owner: map,
    sell_orders: [map] | nil,
    seaport_sell_orders: list | nil,
    creator: map,
    traits: [map],
    last_sale: map,
    top_bid: term | nil,
    listing_date: term | nil,
    is_presale: boolean,
    transfer_fee_payment_token: term | nil,
    transfer_fee: term | nil,
    related_assets: list,
    orders: [map] | nil,
    auctions: list,
    supports_wyvern: boolean,
    top_ownerships: list,
    ownership: term | list,
    highest_buyer_commitment: term | nil,
    token_id: String.t()
  }

  defstruct ~w[
    id
    num_sales
    background_color
    image_url
    image_preview_url
    image_thumbnail_url
    image_original_url
    animation_url
    animation_original_url
    name
    description
    external_link
    asset_contract
    permalink
    collection
    decimals
    token_metadata
    is_nsfw
    owner
    sell_orders
    seaport_sell_orders
    creator
    traits
    last_sale
    top_bid
    listing_date
    is_presale
    transfer_fee_payment_token
    transfer_fee
    related_assets
    orders
    auctions
    supports_wyvern
    top_ownerships
    ownership
    highest_buyer_commitment
    token_id
  ]a
end

