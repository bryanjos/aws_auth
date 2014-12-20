defmodule AWSAuth.QueryParameters do
  alias Timex.DateFormat

  #http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
  def sign(access_key, secret_key, http_method, url, region, service, headers, request_time) do
    now = request_time
    uri = URI.parse(url)

    http_method = String.upcase(http_method)
    region = String.downcase(region)
    service = String.downcase(service)

    if !Dict.has_key?(headers, "host") do
      headers = Dict.put(headers, "host", uri.host)
    end

    amz_date = DateFormat.format!(now, "{ISOz}") |> String.replace("-", "") |> String.replace(":", "")
    date = DateFormat.format!(now, "%Y%m%d", :strftime)

    scope = "#{date}/#{region}/#{service}/aws4_request"

    params = case uri.query do
      nil ->
        HashDict.new
      _ ->
        String.split(uri.query, "&")
        |> Enum.map(fn(x) -> String.split(x, "=") end)
        |> Enum.reduce(HashDict.new, fn(x, acc) -> Dict.put(acc, hd(x), hd(tl(x))) end)
    end

    params = params
    |> Dict.put("X-Amz-Algorithm", "AWS4-HMAC-SHA256")
    |> Dict.put("X-Amz-Credential", AWSAuth.Utils.uri_encode("#{access_key}/#{scope}"))
    |> Dict.put("X-Amz-Date", AWSAuth.Utils.uri_encode(amz_date))
    |> Dict.put("X-Amz-Expires", AWSAuth.Utils.uri_encode("86400"))
    |> Dict.put("X-Amz-SignedHeaders", AWSAuth.Utils.uri_encode("#{Dict.keys(headers) |> Enum.join(";")}"))

    string_to_sign = AWSAuth.Utils.build_canonical_request(http_method, uri.path, params, headers, :unsigned)
    |> AWSAuth.Utils.build_string_to_sign(amz_date, scope)

    signature = AWSAuth.Utils.build_signing_key(secret_key, date, region, service) 
    |> AWSAuth.Utils.build_signature(string_to_sign)

    params = Dict.put(params, "X-Amz-Signature", signature)
    query_string = Enum.map(params, fn({key, value}) -> "#{key}=#{value}"  end) |> Enum.sort(&(&1 < &2))  |> Enum.join("&")

    "#{uri.scheme}://#{uri.authority}#{uri.path || "/"}?#{query_string}"
  end
end