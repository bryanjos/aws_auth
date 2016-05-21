defmodule AWSAuth do
  alias Timex.Date
  alias AWSAuth.Signature

  @moduledoc """
  Signs urls or authentication headers for use with AWS requests
  """

  @doc """
  Signs the given URL

  `access_key`: Your AWS Access key

  `secret_key`: Your AWS secret key

  `http_method`: "GET","POST","PUT","DELETE", "HEAD"

  `url`: The AWS url you want to sign

  `region`: The AWS name for the region you want to access (i.e. us-east-1). Check [here](http://docs.aws.amazon.com/general/latest/gr/rande.html) for the region names

  `service`: The AWS service you are trying to access (i.e. s3). Check the url above for names as well.

  `headers` (optional. defaults to `Map.new`): The headers that will be used in the request. Used for signing the request.
  For signing, host is the only one required unless using any other x-amx-* headers.
  If host is present here, it will override using the host in the url to attempt signing.
  If only the host is needed, then you don't have to supply it and the host from the url will be used.
   """
  def sign_url(access_key, secret_key, http_method, url, region, service) do
    sign_url(access_key, secret_key, http_method, url, region, service, Map.new)
  end

  def sign_url(access_key, secret_key, http_method, url, region, service, headers) do
    sign_url(access_key, secret_key, http_method, url, region, service, headers, Date.now)
  end

  def sign_url(access_key, secret_key, http_method, url, region, service, headers, request_time) do
    sign_url(access_key, secret_key, http_method, url, region, service, headers, request_time, "")
  end

  def sign_url(access_key, secret_key, http_method, url, region, service, headers, request_time, payload) do
    AWSAuth.QueryParameters.sign(access_key, secret_key, http_method, url, region, service, headers, request_time, payload)
  end


  @doc """
  Signs an authorization header

  `access_key`: Your AWS Access key

  `secret_key`: Your AWS secret key

  `http_method`: "GET","POST","PUT","DELETE", "HEAD"

  `url`: The AWS url you want to sign

  `region`: The AWS name for the region you want to access (i.e. us-east-1). Check [here](http://docs.aws.amazon.com/general/latest/gr/rande.html) for the region names

  `service`: The AWS service you are trying to access (i.e. s3). Check the url above for names as well.

  `headers` (optional. defaults to `Map.new`): The headers that will be used in the request. Used for signing the request.
  For signing, host is the only one required unless using any other x-amx-* headers.
  If host is present here, it will override using the host in the url to attempt signing.
  Same goes for the x-amz-content-sha256 headers
  If only the host and x-amz-content-sha256 headers are needed, then you don't have to supply it and the host from the url will be used and
  the payload will be hashed to get the x-amz-content-sha256 header.

  `payload` (optional. defaults to `""`): The contents of the payload if there is one.
  """
  def sign_authorization_header(access_key, secret_key, http_method, url, region, service) do
    sign_authorization_header(access_key, secret_key, http_method, url, region, service, Map.new)
  end

  def sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers) do
    sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers, "")
  end

  def sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers, payload) do
    sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers, payload, Date.now)
  end

  def sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers, payload, request_time) do
    AWSAuth.AuthorizationHeader.sign(access_key, secret_key, http_method, url, region, service, payload, headers, request_time)
  end



  @doc("Creates a new Signature")
  @spec new() :: Signature.t
  def new() do
    %Signature{}
  end

  @doc("Adds the HTTP Method to the signature")
  @spec with_method(Signature.t, binary) :: Signature.t
  def with_method(signature, method) when method in ["GET", "POST", "PUT", "DELETE", "HEAD"] do
    %{ signature | method: method }
  end

  def with_method(_, method) do
    raise ArgumentError, message: "Unsupported HTTP Method: #{method}. Supported Methods: [\"GET\", \"POST\", \"PUT\", \"DELETE\", \"HEAD\"]"
  end

  @doc("Adds the url to the signature")
  @spec with_url(Signature.t, binary) :: Signature.t
  def with_url(signature, url) do
    %{ signature | url: url }
  end

  @doc("Adds the region to the signature")
  @spec with_region(Signature.t, binary) :: Signature.t
  def with_region(signature, region) do
    %{ signature | region: region }
  end

  @doc("Adds the service to the signature")
  @spec with_service(Signature.t, binary) :: Signature.t
  def with_service(signature, service) do
    %{ signature | service: service }
  end

  @doc("Adds the headers to the signature")
  @spec with_headers(Signature.t, Map.t) :: Signature.t
  def with_headers(signature, headers) do
    %{ signature | headers: headers }
  end

  @doc("Adds the specified header to the signature")
  @spec with_header(Signature.t, binary, binary) :: Signature.t
  def with_header(signature, key, value) do
    %{ signature | headers: Map.put(signature.headers, key, value) }
  end

  @doc("Adds the payload to the signature")
  @spec with_payload(Signature.t, binary) :: Signature.t
  def with_payload(signature, payload) do
    %{ signature | payload: payload }
  end

  @doc("Adds the request_time to the signature")
  @spec with_request_time(Signature.t, Timex.Date.t) :: Signature.t
  def with_request_time(signature, request_time) do
    %{ signature | request_time: request_time }
  end

  @doc("Signs request and returns the authorization header")
  @spec sign_authorization_header(Signature.t, binary, binary) :: Signature.t
  def sign_authorization_header(signature, access_key, secret_key) do
    AWSAuth.AuthorizationHeader.sign(access_key, secret_key, signature.method,
      signature.url, signature.region, signature.service, signature.payload,
      signature.headers, signature.request_time)
  end

  @doc("Signs request and returns the signed url")
  @spec sign_url(Signature.t, binary, binary) :: Signature.t
  def sign_url(signature, access_key, secret_key) do
    AWSAuth.QueryParameters.sign(access_key, secret_key, signature.method,
      signature.url, signature.region, signature.service, signature.headers,
      signature.request_time, signature.payload)
  end


end
