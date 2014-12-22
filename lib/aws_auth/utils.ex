defmodule AWSAuth.Utils do

  def build_canonical_request(http_method, url, params, headers, hashed_payload) do

    query_params = Enum.map(params, fn({key, value}) -> "#{key}=#{value}"  end) 
    |> Enum.sort(&(&1 < &2))  
    |> Enum.join("&")


    header_params = Enum.map(headers, fn({key, value}) -> "#{String.downcase(key)}:#{String.strip(value)}"  end) 
    |> Enum.sort(&(&1 < &2)) 
    |> Enum.join("\n")


    signed_header_params = Enum.map(headers, fn({key, _}) -> String.downcase(key)  end) 
    |> Enum.sort(&(&1 < &2)) 
    |> Enum.join(";")

    if hashed_payload == :unsigned do
      hashed_payload = "UNSIGNED-PAYLOAD"
    end

    "#{http_method}\n#{URI.encode(url) |> String.replace("$", "%24")}\n#{query_params}\n#{header_params}\n\n#{signed_header_params}\n#{hashed_payload}"
  end

  def build_string_to_sign(canonical_request, timestamp, scope) do    
    hashed_canonical_request = hash_sha256(canonical_request)
    
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

  def hash_sha256(data) do
    :crypto.hash(:sha256, data) 
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
    |> String.replace("$", "%24")
  end

  def bytes_to_string(bytes) do
    :crypto.bytes_to_integer(bytes)
    |> Integer.to_string(16)
    |> String.downcase
  end

end
