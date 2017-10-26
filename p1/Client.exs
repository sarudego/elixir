# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: Client.exs
# FECHA: 26/10/17
# TIEMPO: 7 + 9  = 16 horas de trabajo conjunto
# DESCRIPCI'ON: fichero Elixir que contiene las funciones para la práctica 1 de Sistemas Distribuidos. Server - Client
# 	Deben estar los nodos configurados y los archivos cargados
# 	Es necesario ejecutar los nodos con  "iex --name nombre@IP  -- cookie palabra"		


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
