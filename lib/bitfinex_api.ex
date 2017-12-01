defmodule BitfinexApi do
  @moduledoc """
  Documentation of all the API calls and the corresponding parameters.
  """

#  @doc """
#  Get the server time.
#
#  (This API call accepts no parameters)
#
#  ## Example
#
#      iex(1)> BitfinexApi.get_server_time()
#      {:ok, %{"rfc1123" => "Thu,  5 Oct 17 14:03:21 +0000", "unixtime" => 1507212201}}
#  """
#  def get_server_time(params \\ %{}) do
#    invoke_public_api("Time?" <> URI.encode_query(params))
#  end
#
#  # Helper method to invoke the public APIs
#  # Returns a tuple {status, result}
#  defp invoke_public_api(method) do
#    query_url = Application.get_env(:bitfinex_api, :api_endpoint) <> method
#
#    case HTTPoison.get(query_url) do
#      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#        body = Poison.decode!(body)
#        {:ok, Map.get(body, "result")}
#      # Try to get and display the error message from Bitfinex.
#      {:ok, %HTTPoison.Response{status_code: _, body: body}} ->
#        body = Poison.decode!(body)
#        {:error, Map.get(body, "error")}
#      # Otherwise just error
#      _ ->
#        {:error, %{}}
#    end
#  end

end
