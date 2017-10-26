# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: Server.exs
# FECHA: 26/10/17
# TIEMPO: 7 + 9  = 16 horas de trabajo conjunto
# DESCRIPCI'ON: fichero Elixir que contiene las funciones para la práctica 1 de Sistemas Distribuidos. Server - Client
# 	Deben estar los nodos configurados y los archivos cargados
# 	Es necesario ejecutar los nodos con  "iex --name nombre@IP  -- cookie palabra"		


defmodule Server do

  def loop do
    IO.puts "Escuchando..."
    receive do
      {pid, {:calcular, a} } when is_integer(a) ->
        IO.puts "calculando numero #{a}..."
        spawn(fn -> send(pid, {:resultado,Primes.is_prime(a)}) end)
      
      {pid, {:rango, min, max} } when is_integer(min) ->
        IO.puts "rango #{min} - #{max}..." 
        spawn(fn -> send(pid, {:resultado,Primes.find_primes({min, max})}) end)
    end
    loop()
  end

  def initListen do
    loop()
  end

end

