defmodule ExOpenSea.AssetEvent do
  @type t :: %__MODULE__{}

  defstruct ~w[
    id
    approved_account
    asset
    asset_bundle
    auction_type
    bid_amount
    collection_slug
    contract_address
    created_date
    custom_event_name
    dev_fee_payment_event
    dev_seller_fee_basis_points
    duration
    ending_price
    event_timestamp
    event_type
    from_account
    is_private
    listing_time
    owner_account
    payment_token
    quantity
    seller
    starting_price
    to_account
    total_price
    transaction
    winner_account
  ]a
end
