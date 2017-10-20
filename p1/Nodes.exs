Code.require_file("#{__DIR__}/primos.exs")
Code.require_file("#{__DIR__}/Server.exs")
Code.require_file("#{__DIR__}/Worker.exs")
#Code.require_file("#{__DIR__}/NodoRemoto.exs")

ExUnit.start([timeout: 20000, seed: 0]) # milisegundos

defmodule Nodes do
 
  use ExUnit.Case, async: true

  @host1 "127.0.0.1"

  setup_all do
    IO.puts("Iniciando nodos...")
    IO.puts("Iniciando servidor...")
    server = Server.start(@host1, "server", Server.exs)
    Server.register(server,@host1)
    IO.puts("Iniciando worker1...")
    worker1 = Worker.start(@host1, "worker1", Worker.exs)
    Server.register(worker1,@host1)
    IO.puts("Iniciando worker2...")
    #worker2 = Worker.start(127.0.0.1, "worker2")
    #IO.puts("Iniciando worker3...")
    #worker3 = Worker.start(127.0.0.1, "worker3")
    #IO.puts("Iniciando worker4...")
    #worker4 = Worker.start(127.0.0.1, "worker4")
    testCalculo()
    on_exit fn ->
      IO.puts "Eliminamos nodos..."

      NodoRemoto.stop(server)
      NodoRemoto.stop(worker1)
    
    end

    {:ok, server: server, worker1: worker1}
  end

  defp testCalculo() do
    #server.initListen

  end
  #def init() do
  #node1 = start("node1", "127.0.0.1")
  #node2 = start("node2", "127.0.0.1")
  #Process.register(node1, :server)
  #Process.register(node2, :worker1)
  #node1
  #end


end


# iex --sname name@ip --cookie word
# Node.connect :name2@ip
# Process.register self(), :name@ip
#
# Node.spawn(:"server@Jupiter", fn -> Primes.is_prime(4) end ) 
#
