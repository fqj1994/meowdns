defmodule Meowdns.Udpserver do

  def start_link(port) do
    :gen_server.start_link({:local, :udpserver}, __MODULE__, port, [])
  end

  def init(port) do
    {:ok, port} = :gen_udp.open(port, [{:reuseaddr, true}, {:active, true}, :inet6, :binary])
    {:ok, {port, 0}}
  end

  def handle_info({:udp, port, peerip, peerport, data}, {_port, counter}) do
    workers = :erlang.registered |> 
              Enum.filter(fn x -> String.starts_with?(atom_to_binary(x), "dnshandle_") end)
    chosen_worker = workers |> Enum.at(:random.uniform(length(workers)) - 1)
    :gen_server.cast chosen_worker, {:dnsreq, peerip, peerport, data }
    {:noreply, {port, counter + 1}}
  end

  def handle_cast({:send, peerip, peerport, data}, {port, counter}) do
    :gen_udp.send(port, peerip, peerport, data)
    {:noreply, {port, counter}}
  end

end
