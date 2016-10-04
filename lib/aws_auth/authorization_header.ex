defmodule AWSAuth.AuthorizationHeader do
  @moduledoc false

  #http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html
  def sign(access_key, secret_key, http_method, url, region, service, payload, headers, request_time) do
    now = request_time
    uri = URI.parse(url)

    params = case uri.query do
               nil ->
                 Map.new
               _ ->
                 URI.decode_query(uri.query)
             end

    http_method = String.upcase(http_method)
    region = String.downcase(region)
    service = String.downcase(service)

    headers = Map.put_new(headers, "host", uri.host)

    payload = case payload do
      "" -> ""
      _ -> AWSAuth.Utils.hash_sha256(payload)
    end

    headers = Map.put_new(headers, "x-amz-content-sha256", payload)

    amz_date = Timex.format!(now, "%Y%m%dT%H%M%SZ", :strftime)
    date = Timex.format!(now, "%Y%m%d", :strftime)

    scope = "#{date}/#{region}/#{service}/aws4_request"

    string_to_sign = AWSAuth.Utils.build_canonical_request(http_method, uri.path || "/", params, headers, payload)
    |>  AWSAuth.Utils.build_string_to_sign(amz_date, scope)

    signature =  AWSAuth.Utils.build_signing_key(secret_key, date, region, service)
    |>  AWSAuth.Utils.build_signature(string_to_sign)

    signed_headers = Enum.map(headers, fn({key, _}) -> String.downcase(key)  end)
    |> Enum.sort(&(&1 < &2))
    |> Enum.join(";")

    "AWS4-HMAC-SHA256 Credential=#{access_key}/#{scope},SignedHeaders=#{signed_headers},Signature=#{signature}"
  end
end
