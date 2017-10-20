defmodule Master do
  @host1 "127.0.0.1"
  @numWorkers 3 
  def assign([{worker_pid, task} | tail]) do
    send(worker_pid, {:calcular, {self(), task}}) 
    IO.puts "#{inspect tail}"
    if length(tail) != 0 do
      assign(tail)
    end
  end

  def collect(results) do
    new_result = receive do
      {:resultado, result} -> result
    end
    if length(results) <= 3 do
      collect([new_result | results])
    end
    IO.puts "#{inspect results}"
    #if length(results) == String.to_integer("#{@numWorkers}") do
      #printResults(results)
    #end
  end

  defp printResults(results) do
    IO.puts "#{inspect results}"
  end

  def init(min, max) do
    #Divisón del rango en tres trozos
    slice = div max, 3 
    assign([{{:worker1, :"worker1@#{@host1}"}, {min, min + slice}},
            {{:worker2, :"worker2@#{@host1}"}, {min + slice + 1, min + slice * 2}},
            {{:worker3, :"worker3@#{@host1}"}, {min + slice * 2 +1, max}}])
    IO.puts "collect"
    collect([])
  end
end
