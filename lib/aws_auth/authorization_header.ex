defmodule AWSAuth.AuthorizationHeader do
  alias Timex.DateFormat

  #http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html
  def sign(access_key, secret_key, http_method, url, region, service, payload, headers, request_time) do
    now = request_time
    uri = URI.parse(url)

    params = case uri.query do
      nil ->
        HashDict.new
      _ ->
        String.split(uri.query, "&")
        |> Enum.map(fn(x) -> String.split(x, "=") end)
        |> Enum.reduce(HashDict.new, fn(x, acc) -> Dict.put(acc, hd(x),  AWSAuth.Utils.uri_encode(hd(tl(x)))) end)
    end

    http_method = String.upcase(http_method)
    region = String.downcase(region)
    service = String.downcase(service)

    if !Dict.has_key?(headers, "host") do
      headers = Dict.put(headers, "host", uri.host)
    end

    hashed_payload =  AWSAuth.Utils.hash_sha256(payload)

    if !Dict.has_key?(headers, "x-amz-content-sha256") do
      headers = Dict.put(headers, "x-amz-content-sha256", hashed_payload)
    end

    amz_date = DateFormat.format!(now, "{ISOz}") |> String.replace("-", "") |> String.replace(":", "")
    date = DateFormat.format!(now, "%Y%m%d", :strftime)

    scope = "#{date}/#{region}/#{service}/aws4_request"

    string_to_sign =  AWSAuth.Utils.build_canonical_request(http_method, uri.path, params, headers, hashed_payload)
    |>  AWSAuth.Utils.build_string_to_sign(amz_date, scope)

    signature =  AWSAuth.Utils.build_signing_key(secret_key, date, region, service) 
    |>  AWSAuth.Utils.build_signature(string_to_sign)

    signed_headers = Enum.map(headers, fn({key, _}) -> String.downcase(key)  end) 
    |> Enum.sort(&(&1 < &2)) 
    |> Enum.join(";")

    "AWS4-HMAC-SHA256 Credential=#{access_key}/#{scope},SignedHeaders=#{signed_headers},Signature=#{signature}"
  end
end