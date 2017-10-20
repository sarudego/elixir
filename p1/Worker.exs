defmodule Worker do
    def initListen do
        loop()
    end

    def loop do
        IO.puts "Esperando trabajo..."
        result = receive do
            {:calcular, {master_pid, {min, max}}} ->
                IO.puts "Calculando primos desde #{min} hasta #{max}."
                #if :rand.uniform(100)>60, do: Process.sleep(round(:rand.uniform(100)/100*2000))
                send(master_pid, {:resultado, Primes.find_primes({min, max})})
        end
        loop()
    end
end
