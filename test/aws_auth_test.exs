defmodule AWSAuthTest do
  use ExUnit.Case

  #Example from http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
  test "request" do
    signed_request = AWSAuth.sign("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
      "GET", 
      "https://examplebucket.s3.amazonaws.com/test.txt", 
      "us-east-1", 
      "s3", 
      HashDict.new,
      Timex.Date.from({2013,05,24}, Timex.Date.timezone("GMT")))

    assert signed_request == "https://examplebucket.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Signature=aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404&X-Amz-SignedHeaders=host"
  end
end
