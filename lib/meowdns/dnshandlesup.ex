defmodule Meowdns.Dnshandlesup do
  use Supervisor.Behaviour

  def start_link(nworkers) do
    :supervisor.start_link(__MODULE__, [nworkers])
  end

  def init([nworkers]) do
    children = :lists.map(
        fn i -> worker(Meowdns.Dnshandle, [i], [id: list_to_atom('dnshandle_' ++ integer_to_list(i))]) end,
        :lists.seq(1, nworkers)
    )

    supervise(children, strategy: :one_for_one)
  end
end
