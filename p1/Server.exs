#Code.require_file("#{__DIR__}/primos.exs")
#Code.require_file("#{__DIR__}/Worker.exs")
#Code.require_file("#{__DIR__}/Nodo.exs")

defmodule Server do

  #@host1 "127.0.0.1"

  #setup_all do
    #IO.puts("Iniciando nodos...")
    #IO.puts("Iniciando servidor...")
    #server = Server.start(@host1, "server", Elixir.Server.beam)
    #IO.puts("Iniciando worker1...")
    #worker1 = Worker.start(@host1, "worker1", Worker.exs)
    #IO.puts("Iniciando worker2...")
    #worker2 = Worker.start(127.0.0.1, "worker2")
    #IO.puts("Iniciando worker3...")
    #worker3 = Worker.start(127.0.0.1, "worker3")
    #IO.puts("Iniciando worker4...")
    #worker4 = Worker.start(127.0.0.1, "worker4")
  #end


  #def start(host, nombre, fichero_programa_cargar) do
    #System.cmd("ssh", [host,
                       #"elixir --name #{nombre}@#{host} --cookie monster",
                       #"--erl  \'-kernel inet_dist_listen_min 32000\'",
                       #"--erl  \'-kernel inet_dist_listen_max 32009\'",
                       #"--detached --no-halt #{fichero_programa_cargar}"])
  #end

  #def init() do
  #node1 = start("node1", "127.0.0.1")
  #node2 = start("node2", "127.0.0.1")
  #Process.register(node1, :server)
  #Process.register(node2, :worker1)
  #node1
  #end


  # empezar con esto ...
  def loop do
    IO.puts "Escuchando..."
    receive do
      {pid, {:saludo, msg} } -> IO.puts "I got a message! #{inspect msg}"
      
      {pid, {:calcular, a} } when is_integer(a) ->
        IO.puts "calculando numero #{a}..."
        send(pid, {:resultado,Primes.is_prime(a)})
      
      {pid, {:rango, min, max} } when is_integer(min) ->
        IO.puts "rango #{min} - #{max}..." 
        send(pid, {:resultado,Primes.find_primes({min, max})})
    end
    loop()
  end

  def initListen do
    loop()
  end

end


# iex --sname name@ip --cookie word
# Node.connect :name2@ip
# Process.register self(), :name@ip
#
# Node.spawn(:"server@Jupiter", fn -> Primes.is_prime(4) end ) 
#
