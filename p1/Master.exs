defmodule Master do
  @host1 "127.0.0.1"
  
  def assign([{worker_pid, task} | tail]) do
    send(worker_pid, {:calcular, {self(), task}}) 
    IO.puts "#{inspect tail}"
    if length(tail) != 0 do
      assign(tail)
    end
    IO.puts "fin assign"
  end

  def collect(results) do

    new_result = receive do
      {:resultado, result} -> IO.inspect "#{result}"
                              result
    end
    IO.inspect "#{results}"
    if length(results) < 2 do
      IO.puts "vuelta...."
      collect([results | new_result])
    else
      results = results ++ new_result
      IO.inspect "#{results}"
    end
  end

  def init(min, max) do
    #Divisón del rango en tres trozos
    slice = div max, 3
    assign([{{:worker1, :"worker1@#{@host1}"}, {min, slice}},
            {{:worker2, :"worker2@#{@host1}"}, {slice + 1, slice * 2 + 1}},
            {{:worker3, :"worker3@#{@host1}"}, {slice * 2 + 2, max}}])
    collect([])
  end
end
