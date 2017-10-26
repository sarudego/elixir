defmodule Master do
  @host1 "127.0.0.1"
  @numWorkers 3

  def timestamp do
    :os.system_time(:milli_seconds)  
  end

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
            {{:worker2, :"worker2@#{@host1}"}, {slice + 1, slice * 2}},
            {{:worker3, :"worker3@#{@host1}"}, {slice * 2 + 1, max}}])
    collect([])
  end


end


defmodule Heterogeneous do

  @host1 "127.0.0.1"

  def timestamp do
    :os.system_time(:milli_seconds)  
  end

 # def assign([worker_pid | workersTail],[task | taskTail], listWorkers) do
    #if (length(workersTail) == 0) do
      ##[worker_pid | workersTail ] = listWorkers 
      ##worker_pid = [listWorkers]
    #end  
    #send(worker_pid, {:calcular, {self(), task}}) 
    #if length(workersTail != 0) do 
      #assign(workersTail, taskTail,listWorkers)
    #end
  #end
  
  def assign(workers, task, pos) do
    if length(pos != 11) do
      send(Enum.at(workers,pos+1), {:calcular, {self(), Enum.at(task,pos+1)}}) 
      assign(workers, task, pos)
    end
  end

  def initH() do
    task = [{1,9999}, {10000, 19999}, {20000, 29999},
            {30000,39999}, {40000,49999}, {50000,59999}, 
            {60000,69999}, {70000,79999}, {80000,89999}, 
            {90000,100000} 
           ] 
    workers = ["worker1", "worker2", "worker3"]

    assign(workers, task, -1)

    collect([])
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

end
