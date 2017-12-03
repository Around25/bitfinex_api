defmodule BitfinexApi do
  @moduledoc """
  Documentation of all the API calls and the corresponding parameters.
  """


  @doc """
  Get order book

  Params:
  - pair = asset pair to get market depth for
  - limit_bids = maximum number of bids (optional)
  - limit_asks = maximum number of asks (optional)
  - group = group orders by price, default 1
  """
  def get_order_book(params \\ %{}) do
    invoke_public_api("/v1/book/#{params.pair}?" <> URI.encode_query(params))
  end

  def symbols do
    [ "btcusd","ltcusd","ltcbtc","ethusd","ethbtc","etcbtc","etcusd","rrtusd","rrtbtc",
      "zecusd","zecbtc","xmrusd","xmrbtc","dshusd","dshbtc","bccbtc","bcubtc","bccusd",
      "bcuusd","btceur","xrpusd","xrpbtc","iotusd","iotbtc","ioteth","eosusd","eosbtc",
      "eoseth","sanusd","sanbtc","saneth","omgusd","omgbtc","omgeth","bchusd","bchbtc",
      "bcheth","neousd","neobtc","neoeth","etpusd","etpbtc","etpeth","qtmusd","qtmbtc",
      "qtmeth","bt1usd","bt2usd","bt1btc","bt2btc","avtusd","avtbtc","avteth","edousd",
      "edobtc","edoeth","btgusd","btgbtc","datusd","datbtc","dateth","qshusd","qshbtc",
      "qsheth","yywusd","yywbtc","yyweth"] |> Enum.map(&String.upcase/1)
  end

  @doc """
  Get info about the account
  """
  def get_account_infos(params \\ %{}) do
    invoke_private_api("/v1/account_infos", params)
  end

  def get_deposit_address(method, wallet \\ "exchange", renew \\ 1) do
    invoke_private_api("/v1/deposit/new", %{method: method, wallet_name: wallet, renew: renew})
  end

  def exchange("market", from, to \\ "USD", amount \\ 0) do
    symbol = from <> to
    invoke_private_api("/v1/order/new", %{symbol: symbol, amount: amount, price: 0.001, exchange: "bitfinex", side: "sell", type: "exchange market"})
  end

  @doc """
  An array of deposit/withdrawal logs.

  Params:
  - currency: string
  - method:   string
  - since:    date-time
  - until:    date-time
  - limit:    int32

  Key	              Type	      Description
  currency	        [string]
  method	          [string]
  type	            [string]
  txid	            [long]	    Transmission ID
  amount	          [decimal]	  Absolute value of the movement
  description	      [string]	  Description of the movement (txid, destination address,...)
  address	          [string]	  Deposit address used or withdrawal destination address
  status	          [string]	  Status of the movement
  timestamp	        [time]	    Timestamp of the movement
  timestamp_created	[time]	    Creation timestamp of the movement
  fee	              [decimal]	  Fee

  Ratelimit: 20 req/min
  """

  def get_history_movements(currency, params \\ %{}, limit \\ 500) do
    invoke_private_api("/v1/history/movements", Map.merge(%{currency: currency, limit: limit}, params))
  end

    # Helper method to invoke the public APIs
    # Returns a tuple {status, result}
    defp invoke_public_api(method) do
      query_url = Application.get_env(:bitfinex_api, :api_endpoint) <> method

      case HTTPoison.get(query_url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, Poison.decode!(body)}
        {:ok, %HTTPoison.Response{status_code: _, body: body}} -> {:error, Poison.decode!(body)}
        err -> {:error, err}
      end
    end

  defp invoke_private_api(url, params, nonce \\ DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> to_string) do
    api_key = Application.get_env(:bitfinex_api, :api_key)
    api_secret = Application.get_env(:bitfinex_api, :private_key)
    endpoint = Application.get_env(:bitfinex_api, :api_endpoint) # https://api.bitfinex.com
    complete_url = endpoint <> url

    post_data = Map.merge(params, %{request: url, nonce: nonce})
    payload = post_data |> Poison.encode!() |> Base.encode64
    signature = :crypto.hmac(:sha384, api_secret, payload)
                |> Base.encode16
                |> String.downcase

    # Transform the data into list-of-tuple format required by HTTPoison.
    post_data = Enum.map(post_data, fn({k, v}) -> {k, v} end)
    headers = [{"X-BFX-APIKEY", api_key}, {"X-BFX-PAYLOAD", payload}, {"X-BFX-SIGNATURE", signature}]
    case HTTPoison.post(complete_url, {:form, post_data}, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}}  -> {:ok, Poison.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: _, body: body}}    -> {:error, Poison.decode!(body)}
      err -> {:error, err}
    end
  end

end
