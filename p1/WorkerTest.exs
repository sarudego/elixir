defmodule WorkerTest do
  def loop() do
    IO.puts "Escuchando..."
    receive do
      {:saludo, msg} -> IO.puts "I got a message! #{inspect msg}"
      #{:calcular, a,b} when is_function(a) -> IO.puts "calculando #{b}" 
      {:calcular, a} when is_integer(a) -> IO.puts "calculando numero#{a}" 
      {:calcular, a} when is_list(a)-> IO.puts "calculando lista#{a}" 

    end
    loop()
  end
  def enviar(a) do
    send({:server, :"node1@192.168.1.22"}, {:calcular,Primes.find_primes(a)})
  end 

  def saludo(msg) do
    send({:server, :"node1@192.168.1.22"}, {:saludo,msg})
  end 


end
