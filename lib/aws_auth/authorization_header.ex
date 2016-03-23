defmodule AWSAuth.AuthorizationHeader do
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
        |> Enum.reduce(HashDict.new, fn(x, acc) ->
            {key, value} = case length(x) do
              1 ->
                {hd(x), ""}
              _ ->
                {hd(x), List.last(x)}
            end

            Dict.put(acc, key,  AWSAuth.Utils.uri_encode(value))
        end)
    end

    http_method = String.upcase(http_method)
    region = String.downcase(region)
    service = String.downcase(service)

    if !Dict.has_key?(headers, "host") do
      headers = Dict.put(headers, "host", uri.host)
    end

    hashed_payload = AWSAuth.Utils.hash_sha256(payload)

    if !Dict.has_key?(headers, "x-amz-content-sha256") do
      headers = Dict.put(headers, "x-amz-content-sha256", case payload do
          "" -> ""
          _  -> hashed_payload
        end)
    end

    amz_date = Timex.format!(now, "%Y%m%dT%H%M%SZ", :strftime)
    date = Timex.format!(now, "%Y%m%d", :strftime)

    scope = "#{date}/#{region}/#{service}/aws4_request"

    string_to_sign =  AWSAuth.Utils.build_canonical_request(http_method, uri.path || "/", params, headers, hashed_payload)
    |>  AWSAuth.Utils.build_string_to_sign(amz_date, scope)

    signature =  AWSAuth.Utils.build_signing_key(secret_key, date, region, service)
    |>  AWSAuth.Utils.build_signature(string_to_sign)

    signed_headers = Enum.map(headers, fn({key, _}) -> String.downcase(key)  end)
    |> Enum.sort(&(&1 < &2))
    |> Enum.join(";")

    "AWS4-HMAC-SHA256 Credential=#{access_key}/#{scope},SignedHeaders=#{signed_headers},Signature=#{signature}"
  end
end
