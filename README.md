AWSAuth
=======

A small library used to sign AWS request urls using AWS Signature Version 4.

Takes some inspiration from the [Simplex](https://github.com/adamkittelson/simplex) Library.

Does both URL and Authorization Header signing.

`AWSAuth.sign_url(access_key, secret_key, http_method, url, region, service, headers \\ HashDict.new)`

`access_key`: Your AWS Access key

`secret_key`: Your AWS secret key

`http_method`: "GET","POST","PUT","DELETE", etc

`url`: The AWS url you want to sign

`region`: The AWS name for the region you want to access (i.e. us-east-1). Check [here](http://docs.aws.amazon.com/general/latest/gr/rande.html) for the region names

`service`: The AWS service you are trying to access (i.e. s3). Check the url above for names as well.

`headers` (optional): The headers that will be used in the request. Used for signing the request. For signing, host is the only one required unless using any other x-amx-* headers. If host is present here, it will override using the host in the url to attempt signing. If only the host is needed, then you don't have to supply it and the host from the url will be used.

In most cases, you would probably call it like this (examples using the example access key and secret from AWS):

```elixir
signed_request = AWSAuth.sign_url("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "GET",
  "https://examplebucket.s3.amazonaws.com/test.txt",
  "us-east-1",
  "s3")
"https://examplebucket.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20141219%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20141219T153739Z&X-Amz-Expires=86400&X-Amz-Signature=89d9f702dc8fb4fad2fd75bf07fc8468d60634f13234dd17e63835ed1fc324cd&X-Amz-SignedHeaders=host"
```

Or if you need to supply headers for signing, like this:

```elixir
signed_request = AWSAuth.sign_url("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "GET",
  "https://examplebucket.s3.amazonaws.com/test.txt",
  "us-east-1",
  "s3",
  HashDict.new |> Dict.put("x-amz-header","value"))
"https://examplebucket.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20141219%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20141219T153646Z&X-Amz-Expires=86400&X-Amz-Signature=b05688cc482398bf2d6ff4068560b85b310a6bb24c5d21711b7099ab5e3df510&X-Amz-SignedHeaders=host,x-amx-header"
```


Using the example from AWS (http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html)

```elixir
signed_request = AWSAuth.sign_url("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "GET",
  "https://examplebucket.s3.amazonaws.com/test.txt",
  "us-east-1",
  "s3",
  HashDict.new,
  Timex.Date.from({2013,05,24}, Timex.Date.timezone("GMT")))
"https://examplebucket.s3.amazonaws.com/test.txt?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-Signature=aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404&X-Amz-SignedHeaders=host"
```


`AWSAuth.sign_authorization_header(access_key, secret_key, http_method, url, region, service, headers \\ HashDict.new, payload \\ "")`

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


```elixir
headers = HashDict.new
|> Dict.put("Date", "Fri, 24 May 2013 00:00:00 GMT")
|> Dict.put("x-amz-storage-class", "REDUCED_REDUNDANCY")
|> Dict.put("x-amz-date", "20130524T000000Z")

signed_request = AWSAuth.sign_authorization_header("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "PUT", 
  "https://examplebucket.s3.amazonaws.com/test$file.text", 
  "us-east-1", 
  "s3",
  headers,
  "Welcome to Amazon S3.")
"AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20141220/us-east-1/s3/aws4_request,SignedHeaders=date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class,Signature=dddba55b1ae5cd9233e9dc8e43a0daf6e2e120bec86294b1d80d802cab8af258"
```

Using the example from AWS (http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html)

```elixir
headers = HashDict.new
|> Dict.put("Date", "Fri, 24 May 2013 00:00:00 GMT")
|> Dict.put("x-amz-storage-class", "REDUCED_REDUNDANCY")
|> Dict.put("x-amz-date", "20130524T000000Z")

signed_request = AWSAuth.sign_authorization_header("AKIAIOSFODNN7EXAMPLE", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
  "PUT", 
  "https://examplebucket.s3.amazonaws.com/test$file.text", 
  "us-east-1", 
  "s3",
  headers,
  "Welcome to Amazon S3.",
  Timex.Date.from({2013,05,24}, Timex.Date.timezone("GMT")))
"AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request,SignedHeaders=date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class,Signature=98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd"
```