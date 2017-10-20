defmodule Client do
  @host1 "127.0.0.1"

  def enviar(a) do
    send({:server, :"server@#{@host1}"}, {self(), {:calcular,a} })
    IO.puts "Esperando respuesta..."
    receive do
      {:resultado, true} -> IO.puts "Es primo!"
      {:resultado, false} -> IO.puts "No es primo :("
    end
  end 

  def rango(min, max) do
    send({:server, :"server@#{@host1}"}, {self(), {:rango,min, max} })
    IO.puts "Esperando respuesta..."
    receive do
      {:resultado, range} -> IO.inspect "#{range}" 
    end
  end

  def saludo(msg) do
    send({:server, :"server@#{@host1}"}, {self(), {:saludo,msg} })
  end 

end
