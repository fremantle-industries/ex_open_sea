defmodule ExOpenSea.Collection do
  @type slug :: String.t()
  @type t :: %__MODULE__{
          banner_image_url: String.t() | nil,
          chat_url: String.t() | nil,
          created_date: String.t(),
          default_to_fiat: boolean,
          description: String.t() | nil,
          dev_buyer_fee_basis_points: String.t(),
          dev_seller_fee_basis_points: String.t(),
          discord_url: String.t() | nil,
          display_data: map,
          external_url: String.t() | nil,
          featured: boolean,
          featured_image_url: String.t() | nil,
          hidden: boolean,
          image_url: String.t(),
          instagram_username: String.t() | nil,
          is_nsfw: boolean,
          is_subject_to_whitelist: boolean,
          large_image_url: String.t() | nil,
          medium_username: String.t() | nil,
          name: String.t(),
          only_proxied_transfers: boolean,
          opensea_buyer_fee_basis_points: String.t(),
          opensea_seller_fee_basis_points: String.t(),
          payout_address: String.t() | nil,
          primary_asset_contracts: list,
          require_email: boolean,
          safelist_request_status: String.t(),
          short_description: String.t() | nil,
          slug: String.t(),
          stats: map,
          telegram_url: String.t() | nil,
          traits: map,
          twitter_username: String.t() | nil,
          wiki_url: String.t() | nil
        }

  defstruct ~w[
    banner_image_url
    chat_url
    created_date
    default_to_fiat
    description
    dev_buyer_fee_basis_points
    dev_seller_fee_basis_points
    discord_url
    display_data
    external_url
    featured
    featured_image_url
    hidden
    image_url
    instagram_username
    is_nsfw
    is_subject_to_whitelist
    large_image_url
    medium_username
    name
    only_proxied_transfers
    opensea_buyer_fee_basis_points
    opensea_seller_fee_basis_points
    payout_address
    primary_asset_contracts
    require_email
    safelist_request_status
    short_description
    slug
    stats
    telegram_url
    traits
    twitter_username
    wiki_url
  ]a
end
