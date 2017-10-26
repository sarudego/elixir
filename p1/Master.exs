defmodule Master do
  @host1 "127.0.0.1"
  @numWorkers 3

  defp timestamp do
    :os.system_time(:milli_seconds)  
  end

  defp assign([{worker_pid, task} | tail]) do
    send(worker_pid, {:calcular, {self(), task}}) 
    IO.puts "#{inspect tail}"
    if length(tail) != 0 do
      assign(tail)
    end
    IO.puts "fin assign"
  end

  defp collect(results) do
    new_result = receive do
      {:resultado, result} -> IO.inspect "#{result}"
                              result
    end
    #IO.inspect "#{results}"
    if length(results) < 2 do
      #IO.puts "vuelta...."
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
            {{:worker2, :"worker2@#{@host1}"}, {slice + 1, slice * 2}},
            {{:worker3, :"worker3@#{@host1}"}, {slice * 2 + 1, max}}])
    collect([])
  end


end


defmodule Heterogeneous do

  @host1 "127.0.0.1"

  defp timestamp do
    :os.system_time(:milli_seconds)  
  end

  
  defp assign(workers, task, pos) do
    IO.puts "entra assign"
    if (pos != 11) do
      IO.puts "entra if"
      IO.inspect "#{workers}"
      IO.inspect List.to_string(task)
      send(Enum.at(workers,pos+2), {:calcular, {self(), Enum.at(task,pos+1)}}) 
      pos = pos + 1
      assign(workers, task, pos)
    end
    IO.puts "sale assign"
  end

  def init() do
    task = [{1,9999}, {10000, 19999}, {20000, 29999},
            {30000,39999}, {40000,49999}, {50000,59999}, 
            {60000,69999}, {70000,79999}, {80000,89999}, 
            {90000,100000} 
           ] 
    workers = ["worker1@#{@host1}", "worker2@#{@host1}", "worker3@#{@host1}"]

    IO.puts "llamada assign"
    assign(workers, task, -1)

    IO.puts "collect"
    collect([])
  end  

  defp collect(results) do
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

  def registerAndConnect() do
    Process.register self(), :server
    Node.connect :"worker1@#{@host1}"
    Node.connect :"worker2@#{@host1}"
    Node.connect :"worker3@#{@host1}"
  end

end
