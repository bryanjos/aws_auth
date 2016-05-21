defmodule SignatureTest do
  use ExUnit.Case
  import AWSAuth

  @time Timex.date({2013,05,24})

  test "url signing" do

    signed_request = new
    |> with_method("GET")
    |> with_url("https://examplebucket.s3.amazonaws.com/test.txt")
    |> with_region("us-east-1")
    |> with_service("s3")
    |> with_request_time(@time)
    |> sign_url("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")

    assert signed_request == "https://examplebucket.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Signature=aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404&X-Amz-SignedHeaders=host"
  end

  test "sign_authorization_header PUT" do

    signed_request = new
    |> with_method("PUT")
    |> with_url("https://examplebucket.s3.amazonaws.com/test$file.text")
    |> with_region("us-east-1")
    |> with_service("s3")
    |> with_header("Date", "Fri, 24 May 2013 00:00:00 GMT")
    |> with_header("x-amz-storage-class", "REDUCED_REDUNDANCY")
    |> with_header("x-amz-date", "20130524T000000Z")
    |> with_payload("Welcome to Amazon S3.")
    |> with_request_time(@time)
    |> sign_authorization_header("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")

    assert signed_request == "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,SignedHeaders=date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class,Signature=98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd"
  end

  test "sign_query_parameters_request_with_multiple_headers" do

    signed_request = new
    |> with_method("PUT")
    |> with_url("https://examplebucket.s3.amazonaws.com/test.txt")
    |> with_region("us-east-1")
    |> with_service("s3")
    |> with_header("x-amz-acl", "public-read")
    |> with_request_time(@time)
    |> sign_url("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")

    assert signed_request == "https://examplebucket.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Signature=0f5e83a5df8c5fc898824b8c2e0def42b6ef5f6af114e86f4f2282672ff83152&X-Amz-SignedHeaders=host%3Bx-amz-acl"
  end
end
