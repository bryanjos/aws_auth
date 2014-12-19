defmodule AWSAuth do
  alias Timex.Date
  alias Timex.DateFormat

  @moduledoc """
  `AWSAuth.sign(access_key, secret_key, http_method, url, region, service, headers)`

  `access_key`: Your AWS Access key

  `secret_key`: Your AWS secret key

  `http_method`: "GET","POST","PUT","DELETE", etc

  `url`: The AWS url you want to sign

  `region`: The AWS name for the region you want to access (i.e. us-east-1). Check [here](http://docs.aws.amazon.com/general/latest/gr/rande.html) for the region names

  `service`: The AWS service you are trying to access (i.e. s3). Check the url above for names as well.

  `headers` (optional. defaults to `HashDict.new`): The headers that will be used in the request. Used for signing the request. 
  For signing, host is the only one required unless using any other x-amx-* headers. 
  If host is present here, it will override using the host in the url to attempt signing. 
  If only the host is needed, then you don't have to supply it and the host from the url will be used.
  """

  def sign(access_key, secret_key, http_method, url, region, service) do
    sign(access_key, secret_key, http_method, url, region, service, HashDict.new, Date.now)
  end  

  def sign(access_key, secret_key, http_method, url, region, service, headers) do
    sign(access_key, secret_key, http_method, url, region, service, headers, Date.now)
  end  

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

    params = HashDict.new
    |> Dict.put("X-Amz-Algorithm", "AWS4-HMAC-SHA256")
    |> Dict.put("X-Amz-Credential", uri_encode("#{access_key}/#{scope}"))
    |> Dict.put("X-Amz-Date", uri_encode(amz_date))
    |> Dict.put("X-Amz-Expires", uri_encode("86400"))
    |> Dict.put("X-Amz-SignedHeaders", uri_encode("#{Dict.keys(headers) |> Enum.join(",")}"))

    string_to_sign = build_canonical_request(http_method, uri.path, params, headers)
    |> build_string_to_sign(amz_date, scope)

    signature = build_signing_key(secret_key, date, region, service) 
    |> build_signature(string_to_sign)

    params = Dict.put(params, "X-Amz-Signature", signature)
    query_string = Enum.map(params, fn({key, value}) -> "#{key}=#{value}"  end) |> Enum.sort(&(&1 < &2))  |> Enum.join("&")

    "#{uri.scheme}://#{uri.authority}#{uri.path || "/"}?#{query_string}"
  end

  def build_canonical_request(http_method, url, params, headers) do

    query_params = Enum.map(params, fn({key, value}) -> "#{key}=#{value}"  end) 
    |> Enum.sort(&(&1 < &2))  
    |> Enum.join("&")


    header_params = Enum.map(headers, fn({key, value}) -> "#{String.downcase(key)}:#{String.strip(value)}"  end) 
    |> Enum.sort(&(&1 < &2)) 
    |> Enum.join("\n")


    signed_header_params = Enum.map(headers, fn({key, _}) -> String.downcase(key)  end) 
    |> Enum.sort(&(&1 < &2)) 
    |> Enum.join(";")

    "#{http_method}\n#{URI.encode(url)}\n#{query_params}\n#{header_params}\n\n#{signed_header_params}\nUNSIGNED-PAYLOAD"
  end

  def build_string_to_sign(canonical_request, timestamp, scope) do    
    hashed_canonical_request = :crypto.hash(:sha256, canonical_request) 
    |> bytes_to_string
    
    "AWS4-HMAC-SHA256\n#{timestamp}\n#{scope}\n#{hashed_canonical_request}"
  end

  def build_signing_key(secret_key, date, region, service) do
    hmac_sha256("AWS4#{secret_key}", date)
    |> hmac_sha256(region)
    |> hmac_sha256(service)
    |> hmac_sha256("aws4_request")
  end

  def build_signature(signing_key, string_to_sign) do
    hmac_sha256(signing_key, string_to_sign)
    |> bytes_to_string
  end

  def hmac_sha256(key, data) do
    :crypto.hmac(:sha256, key, data)
  end

  def uri_encode(data) do
    URI.encode(data)
    |> String.replace("/", "%2F")
    |> String.replace("+", "%2B")
    |> String.replace("=", "%3D")
  end

  def bytes_to_string(bytes) do
    :crypto.bytes_to_integer(bytes)
    |> Integer.to_string(16)
    |> String.downcase
  end

end
