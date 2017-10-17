defmodule Worker do
  
  #def start(host, nombre, fichero_programa_cargar) do
    #System.cmd("ssh", [host,
          #"elixir --name #{nombre}@#{host} --cookie monster",
          #"--erl \'-kernel inet_dist_listen_min 32000\'",
          #"--erl \'-kernel inet_dist_listen_max 32009\'",
          #"--detached --no-halt #{fichero_programa_cargar}"])
  #end
  
  def enviar(a) do
    send({:server, :"server@Jupiter"}, {:calcular,a})
    IO.puts "Esperando respuesta..."
    receive do
      {:resultado, true} -> IO.puts "Es primo!"
      {:resultado, false} -> IO.puts "No es primo :("
    end
  end 

  def rango(min, max) do
    send({:server, :"server@Jupiter"}, {:rango,min, max})
    IO.puts "Esperando respuesta..."
    receive do
      {:resultado, true} -> IO.puts "Es primo!"
      {:resultado, false} -> IO.puts "No es primo :("
    end
  end

  def saludo(msg) do
    send({:server, :"server@Jupiter"}, {:saludo,msg})
  end 

end
