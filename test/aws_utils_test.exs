defmodule AWSAuth.UtilsTest do
  use ExUnit.Case

  test "build_canonical_request/5 builds correct AWS request representation" do
    canonical_request = AWSAuth.Utils.build_canonical_request("GET", "path/subpath", %{ "a" => 1, "b" => "2", "c" => 1.0},
                                                              %{ "a" => "1", "b" => "2" }, "hashed_payload")
    assert canonical_request == "GET\npath/subpath\na=1&b=2&c=1.0\na:1\nb:2\n\na;b\nhashed_payload"
  end

  test "build_canonical_request/5 builds correct AWS request representation with unsigned hash_payload" do
    canonical_request = AWSAuth.Utils.build_canonical_request("GET", "path/subpath", %{ "a" => 1, "b" => "2", "c" => 1.0},
                                                              %{ "a" => "1", "b" => "2" }, :unsigned)
    assert canonical_request == "GET\npath/subpath\na=1&b=2&c=1.0\na:1\nb:2\n\na;b\nUNSIGNED-PAYLOAD"
  end

  test "build_canonical_request/5 builds correct AWS request representation correctly escaped" do
    canonical_request = AWSAuth.Utils.build_canonical_request("GET", "path/subpath/!@#$%^&*()-_=+?,.<>;:'\"[]{}|\\~`", %{}, %{}, "")
    assert canonical_request == "GET\npath/subpath/%21%40%23%24%25%5E%26%2A%28%29-_%3D%2B%3F%2C.%3C%3E%3B%3A%27%22%5B%5D%7B%7D%7C%5C~%60\n\n\n\n\n"
  end

  test "format_time/1 formats a time correctly" do
    time = AWSAuth.Utils.format_time(~N[2016-10-20 10:32:45.12345])
    assert time == "20161020T103245Z"
  end
end
