defmodule Meowdns do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Meowdns.Supervisor.start_link _args
  end
end
