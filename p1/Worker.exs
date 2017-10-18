defmodule Worker do
    def initListen do
        loop()
    end

    def loop do
        IO.puts "Esperando trabajo..."
        receive do
            {:calcular, master_pid, {min, max}} ->
                IO.puts "Calculando primos desde #{min} hasta #{max}."
                send(master_pid, {:resultado, Primes.find_primes({min, max})})
        end
        loop()
    end
end
