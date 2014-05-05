defmodule Meowdns.Dnshandle do
  require Record
  defrecord :dns_rec, Record.extract(:dns_rec, from_lib: "kernel/src/inet_dns.hrl")
  defrecord :dns_query, Record.extract(:dns_query, from_lib: "kernel/src/inet_dns.hrl")
  defrecord :dns_header, Record.extract(:dns_header, from_lib: "kernel/src/inet_dns.hrl")
  defrecord :dns_rr, Record.extract(:dns_rr, from_lib: "kernel/src/inet_dns.hrl")

  def start_link(i) do
    handlename = list_to_atom('dnshandle_' ++ integer_to_list(i))
    :gen_server.start_link({:local, handlename}, __MODULE__, [], [])
  end

  def init(i) do
    {:ok, 0}
  end


  def handle_cast({:dnsreq, peerip, peerport, data}, state) do
    {:ok, qdata} = :inet_dns.decode(data)
    :dns_rec[header: header, qdlist: [:dns_query[domain: domain, type: qtype]]] = qdata
    dbresult = :gen_server.call :storage, {:query, domain}
    rrlist = :lists.map(
      fn {dbdomain, dbtype, dbttl, dbdata} -> 
        :dns_rr.new domain: dbdomain, type: dbtype, ttl: dbttl, data: dbdata
        end,
      dbresult
    )
    newheader = header.qr(1).ra(0)
    replydata = qdata.header(newheader).anlist(rrlist)
    :gen_server.cast :udpserver, {:send, peerip, peerport, :inet_dns.encode(replydata)}
    {:noreply, state + 1}
  end

end
