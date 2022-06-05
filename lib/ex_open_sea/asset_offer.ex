defmodule ExOpenSea.AssetOffer do
  @type t :: %__MODULE__{}

  defstruct ~w[
    created_date
    closing_date
    closing_extendable
    expiration_time
    listing_time
    order_hash
    metadata
    exchange
    maker
    taker
    current_price
    current_bounty
    bounty_multiple
    maker_relayer_fee
    taker_relayer_fee
    maker_protocol_fee
    taker_protocol_fee
    maker_referrer_fee
    fee_recipient
    fee_method
    side
    sale_kind
    target
    how_to_call
    calldata
    replacement_pattern
    static_target
    static_extradata
    payment_token
    payment_token_contract
    base_price
    extra
    quantity
    salt
    v
    r
    s
    approved_on_chain
    cancelled
    finalized
    marked_invalid
    prefixed_hash
  ]a
end
