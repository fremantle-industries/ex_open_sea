defmodule ExOpenSea.QueryEncoders.SingleKeyMultipleValueWwwFormTest do
  use ExUnit.Case, async: false
  alias ExOpenSea.QueryEncoders.SingleKeyMultipleValueWwwForm
  doctest ExOpenSea.QueryEncoders.SingleKeyMultipleValueWwwForm

  @base_map_params %{hello: "world", foo: "bar"}
  @base_keyword_params [hello: "world", foo: "bar"]

  test ".encode/1 combines map parameters with multiple entries by &" do
    assert SingleKeyMultipleValueWwwForm.encode(@base_map_params) == "hello=world&foo=bar"
    assert SingleKeyMultipleValueWwwForm.encode(@base_keyword_params) == "foo=bar&hello=world"
  end

  test ".encode/1 combines keyword list parameters with multiple entries by &" do
    assert SingleKeyMultipleValueWwwForm.encode(@base_map_params) == "hello=world&foo=bar"
    assert SingleKeyMultipleValueWwwForm.encode(@base_keyword_params) == "foo=bar&hello=world"
  end

  test ".encode/1 concats keyword list parameters with the same key" do
    assert SingleKeyMultipleValueWwwForm.encode([hello: "joe", hello: "mike"]) == "hello=mike&hello=joe"
    assert SingleKeyMultipleValueWwwForm.encode([hello: ["joe", "mike"]]) == "hello=joe&hello=mike"
  end

  test ".encode/1 escapes keys with x-www-form-urlencoded" do
    assert SingleKeyMultipleValueWwwForm.encode(%{"big hello" => "JOE"}) == "big+hello=JOE"
    assert SingleKeyMultipleValueWwwForm.encode(%{:"big hello" => "JOE"}) == "big+hello=JOE"
  end

  test ".encode/1 escapes values with x-www-form-urlencoded" do
    assert SingleKeyMultipleValueWwwForm.encode(%{hello: "Joe Armstrong"}) == "hello=Joe+Armstrong"
  end

  test ".encode/1 converts numbers to string" do
    assert SingleKeyMultipleValueWwwForm.encode(%{age: 10}) == "age=10"
    assert SingleKeyMultipleValueWwwForm.encode(%{score: 90.5}) == "score=90.5"
  end
end
