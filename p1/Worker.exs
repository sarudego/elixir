defmodule Worker do
  def initListen do
    loop()
  end

  def initListenH do
    loopH()
  end

  defp timestamp do
    :os.system_time(:milli_seconds)
  end

  def loop do
    IO.puts "Esperando trabajo..."
    result = receive do
      {:calcular, {master_pid, {min, max}}} ->
        IO.puts "Calculando primos desde #{min} hasta #{max}."
        before = timestamp
        send(master_pid, {:resultado, Primes.find_primes({min, max})})
        #after = timestamp - before
        #IO.puts "#{after} milisegundos "
    end
    loop()
  end

  def loopH do
    IO.puts "Esperando trabajo..."
    result = receive do
      {:calcular, {master_pid, {min, max}}} ->
        IO.puts "Calculando primos desde #{min} hasta #{max}."
        if :rand.uniform(100)>60, do: Process.sleep(round(:rand.uniform(100)/100*2000))
        time_before = timestamp
        IO.puts(to_string( timestamp ) ++ " Enviando")
        send(master_pid, {:resultado, Primes.find_primes({min, max})})
        time_after = timestamp - time_before
        IO.puts "Cost in time... #{time_after}"  
    end
    loop()
  end

  def register1() do
    Process.register self(), :worker1
  end
  def register2() do
    Process.register self(), :worker2
  end
  def register3() do
    Process.register self(), :worker3
  end

end
