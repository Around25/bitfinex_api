defmodule BitfinexApi.WebSocket do
  use WebSockex

  @pairs ["BTCUSD", "LTCUSD", "LTCBTC", "ETHUSD", "ETHBTC", "ETCUSD", "ETCBTC", "RRTUSD", "RRTBTC", "ZECUSD", "ZECBTC"] # invalid: "BFXUSD", "BFXBTC",

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %{}, name: __MODULE__)
  end

  def subscribe(client, "ticker") do
    @pairs
    |> Enum.map(&(%{"event" => "subscribe", "channel" => "ticker", "pair" => &1}))
    |> Enum.map(&(send_message(client, &1)))
  end

  def send_message(client, message) do
    WebSockex.send_frame(client, {:text, Poison.encode!(message)})
  end

  def handle_connect(_conn, state) do
    {:ok, state}
  end

  # restart on socket connection issues
  def handle_info({:ssl_closed, _}, state) do IO.inspect("SSL Socket closed"); {:stop, :normal, state} end
  def handle_info({:DOWN, _from, :process, _pid, :normal}, state) do IO.inspect("SSL Socket DOWN"); {:stop, :normal, state} end

  # handle any other valid message from the web socket
  def handle_frame({type, msg}, state) do
    msg = Poison.decode!(msg)
    process_message(msg, state)
  end

  defp process_message(%{"chanId" => chanId, "channel" => "ticker", "event" => "subscribed", "pair" => pair} = msg, state) do
    state = Map.merge(state, Map.new([{chanId, pair}]))
    {:ok, state}
  end
  defp process_message([_ | ["hb"]], state), do: {:ok, state}
  defp process_message([chanId, bid, bid_size, ask, ask_size, daily_change, daily_change_perc, last_price, volume, high, low], state) do
    ask = ask |> Decimal.new() |> Decimal.to_string(:normal)
    bid = bid |> Decimal.new() |> Decimal.to_string(:normal)
    last_price = last_price |> Decimal.new() |> Decimal.to_string(:normal)
    volume =volume |> Decimal.new() |> Decimal.to_string(:normal)
    daily_change = daily_change |> Decimal.new() |> Decimal.to_string(:normal)
    daily_change_perc = daily_change_perc |> Decimal.new() |> Decimal.to_string(:normal)
    low = low |> Decimal.new() |> Decimal.to_string(:normal)
    high = high |> Decimal.new() |> Decimal.to_string(:normal)

    event = [{Map.get(state, chanId), %{
              ask: ask,
              bid: bid,
              last: last_price,
              vol_today: %{today: volume, last_24: volume},
              price: %{today: last_price, last_24: last_price},
              daily_change: %{amount: daily_change, perc: daily_change_perc},
              trades: %{today: nil, last_24: nil},
              low: %{today: low, last_24: low},
              high: %{today: high, last_24: high},
              open: nil}
            }]
            |> Map.new()
    task = Task.async(BitfinexApi.WebSocket.Producer, :sync_notify, [event])
    {:ok, state}
  end
  defp process_message(%{"event"=> "info"}, state) do {:ok, state} end
  defp process_message(msg, state) do IO.inspect(msg); {:ok, state} end

  def handle_disconnect(%{reason: {:local, reason}}, state), do: {:ok, state}
  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end

end