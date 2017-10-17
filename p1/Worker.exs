defmodule Worker do
  def enviar(a) do
    send({:server, :"server@192.168.45.17"}, {:calcular,a})
    IO.puts "Esperando respuesta..."
    receive do
      {:resultado, true} -> IO.puts "Es primo!"
      {:resultado, false} -> IO.puts "No es primo :("
    end
  end 

  def saludo(msg) do
    send({:server, :"server@192.168.45.17"}, {:saludo,msg})
  end 

end