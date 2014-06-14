defmodule Meowdns.Storage.Txt do
  def start_link([i, txtfile]) do
    name = list_to_atom('storage_' ++ integer_to_list(i))
    :gen_server.start_link({:local, name}, __MODULE__, txtfile, [])
  end

  def get_filters([], res) do
    res
  end

  def get_filters([h | t], res) do
    [filtername, filterargsstr] = :string.tokens(h, ':')
    filterargs = :string.tokens(filterargsstr, ',')
    hh = [filtername, filterargs]
    get_filters(t, [hh | res])
  end

  def get_filters(filters) do
    :lists.reverse get_filters(filters, [])
  end

  def convert(cachedrecords, []) do
    cachedrecords
  end

  def convert(cachedrecords, [h | t]) do
    [zone, reqtype, resptype, ttl, respval, filters] = :string.tokens(h, '\t')
    kkk = list_to_bitstring(zone ++ ':' ++ reqtype)
    newval = {
      reqtype: list_to_bitstring(reqtype),
      resptype: list_to_bitstring(resptype),
      ttl: list_to_integer(ttl),
      respval: list_to_bitstring(respval),
      filters: get_filters(:string.tokens(filters, ' ')),
    }
    cachedrecords = case Map.fetch(cachedrecords, kkk) do
      {:ok, oldval} -> 
        Map.put(cachedrecords, kkk, [newval | oldval])
      :error ->
        Map.put(cachedrecords, kkk, [newval])
    end
    convert(cachedrecords, t)
  end

  def init(txtfile) do
    ruleset = :string.tokens(
      bitstring_to_list(File.read!(txtfile)),
      '\n'
      )
    cachedrecords = Map.new
    cachedrecords = convert(cachedrecords, ruleset)
    {:ok, cachedrecords}
  end

  def handle_call({:query, domain, qtype}, from, cachedrecords) do
    {:reply, Map.fetch(cachedrecords, domain <> ":" <> qtype), cachedrecords}
  end

end
