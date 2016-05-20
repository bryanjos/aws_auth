defmodule AWSAuth do
  alias Timex.Date

  @doc """
  `AWSAuth.sign_url(access_key, secret_key, http_method, url, region, service, headers)`

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
  def sign_url(access_key, secret_key, http_method, url, region, service) do
    sign_url(access_key, secret_key, http_method, url, region, service, HashDict.new)
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
  `AWSAuth.sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers, payload)`

  `access_key`: Your AWS Access key

  `secret_key`: Your AWS secret key

  `http_method`: "GET","POST","PUT","DELETE", etc

  `url`: The AWS url you want to sign

  `region`: The AWS name for the region you want to access (i.e. us-east-1). Check [here](http://docs.aws.amazon.com/general/latest/gr/rande.html) for the region names

  `service`: The AWS service you are trying to access (i.e. s3). Check the url above for names as well.

  `headers` (optional. defaults to `HashDict.new`): The headers that will be used in the request. Used for signing the request.
  For signing, host is the only one required unless using any other x-amx-* headers.
  If host is present here, it will override using the host in the url to attempt signing.
  Same goes for the x-amz-content-sha256 headers
  If only the host and x-amz-content-sha256 headers are needed, then you don't have to supply it and the host from the url will be used and
  the payload will be hashed to get the x-amz-content-sha256 header.

  `payload` (optional. defaults to `""`): The contents of the payload if there is one.
  """
  def sign_authorization_header(access_key, secret_key, http_method, url, region, service) do
    sign_authorization_header(access_key, secret_key, http_method, url, region, service, HashDict.new)
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

end
