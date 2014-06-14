defmodule Meowdns.Supervisor do
  use Supervisor.Behaviour

  def start_link([port, nworkers]) do
    :supervisor.start_link(__MODULE__, [port, nworkers])
  end

  def init([port, nworkers]) do
    children = [
      worker(Meowdns.Udpserver, [port]),
      supervisor(Meowdns.Dnshandle.Supervisor, [nworkers])
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end
end
