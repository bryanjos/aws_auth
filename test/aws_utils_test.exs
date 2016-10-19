defmodule AWSAuth.UtilsTest do
  use ExUnit.Case

  test "format_time formats a time correctly" do
    time = AWSAuth.Utils.format_time(~N[2016-10-20 10:32:45.12345])
    assert time == "20161020T103245Z"
  end
end
