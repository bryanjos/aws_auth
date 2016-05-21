defmodule AWSAuth.Signature do

  @type t :: %AWSAuth.Signature{
    method: binary,
    url: binary | nil,
    region: binary | nil,
    service: binary | nil,
    headers: Map.t,
    payload: binary,
    request_time: Timex.Date.t
  }


  defstruct [
    method: "GET",
    url: nil,
    region: nil,
    service: nil,
    headers: Map.new,
    payload: "",
    request_time: Timex.Date.now
  ]

end
