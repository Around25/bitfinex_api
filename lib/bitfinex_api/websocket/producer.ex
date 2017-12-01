defmodule BitfinexApi.WebSocket.Producer do
  use GenStage

  @doc "Starts the broadcaster."
  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    schedule_work() # Schedule work to be performed on start
    {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_info(:work, state) do
    BitfinexApi.WebSocket.subscribe(BitfinexApi.WebSocket, "ticker")
    {:noreply, [], state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 10 * 1000) # In 10 seconds
  end

  def sync_notify(event, timeout \\ 5000) do
    GenStage.call(__MODULE__, {:notify, event}, timeout)
  end

  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, {from, event}}, queue} ->
        GenStage.reply(from, :ok)
        dispatch_events(queue, demand - 1, [event | events])
      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end