defmodule Worker do
  def enviar(a) do
    send({:server, :"node1@192.168.1.22"}, {:calcular,Primes.find_primes(a)})
  end 

  def saludo(msg) do
    send({:server, :"node1@192.168.1.22"}, {:saludo,msg})
  end 


end
