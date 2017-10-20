defmodule Server do

  def loop do
    IO.puts "Escuchando..."
    receive do
      {pid, {:saludo, msg} } -> IO.puts "I got a message! #{inspect msg} from #{pid}"
      
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


# iex --sname name@ip --cookie word
# Node.connect :name2@ip
# Process.register self(), :name@ip
#
# Node.spawn(:"server@Jupiter", fn -> Primes.is_prime(4) end ) 
#
