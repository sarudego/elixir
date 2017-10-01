Code.require_file("#{__DIR__}/Nodo.exs")

defmodule ServerWorker do
  #setup_all do
  #IO.puts("Iniciando nodos...")
  #IO.puts("Iniciando servidor...")
  #server = Servidor.start(127.0.0.1, "server")
  #IO.puts("Iniciando worker1...")
  #worker1 = Worker.start(127.0.0.1, "worker1")
  #IO.puts("Iniciando worker2...")
  #worker2 = Worker.start(127.0.0.1, "worker2")
  #IO.puts("Iniciando worker3...")
  #worker3 = Worker.start(127.0.0.1, "worker3")
  #IO.puts("Iniciando worker4...")
  #worker4 = Worker.start(127.0.0.1, "worker4")
  #end


  def start(host, nombre) do
    "elixir --name #{nombre}@#{host} --cookie secreto\
    --erl \'-kernel inet_dist_listen_min 32000\'
    --erl \'-kernel inet_dist_listen_max 32009\'
    --detached"
  end

  def init() do
    node1 = start("node1", "127.0.0.1")
    node2 = start("node2", "127.0.0.1")
    Process.register(node1, :server)
    Process.register(node2, :worker1)
    node1
  end

  def calculate(nodo, numero) do
    send({:server, nodo}, Primes.is_prime(numero))
  end
  #spawn(fn -> send({:worker1, :"node1@127.0.0.1"}, Primes.find_primes({1,10})) end)

  def listen() do
    IO.puts "Estoy escuchando..."
    receive do
      {:calculate, numero} -> Primes.is_prime(numero)
    end
    listen()
  end

end
