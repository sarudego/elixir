# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: Master.exs
# FECHA: 26/10/17
# TIEMPO: 7 + 9  = 16 horas de trabajo conjunto
# DESCRIPCI'ON: fichero Elixir que contiene las funciones para la práctica 1 de Sistemas Distribuidos. Master - Worker
# 	Deben estar los nodos configurados y los archivos cargados
# 	Es necesario ejecutar los nodos con  "iex --name nombre@IP  -- cookie palabra"		

Code.load_file("primos.exs")


defmodule Master do
  @host1 "127.0.0.1"

  def registerAndConnect() do
    Process.register self(), :server
    Node.connect :"worker1@#{@host1}"
    Node.connect :"worker2@#{@host1}"
    Node.connect :"worker3@#{@host1}"
  end

  defp timestamp do
    :os.system_time(:milli_seconds)  
  end

  defp assign([{worker_pid, task} | tail]) do
    send(worker_pid, {:calcular, {self(), task}}) 
    if length(tail) != 0 do
      assign(tail)
    end
  end

  defp collect(results) do
    new_result = receive do
      {:resultado, result} -> IO.inspect "#{result}"
                              result
    end
    if length(results) < 2 do
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


defmodule Heter do
  @host1 "127.0.0.1"

  defp timestamp do
    :os.system_time(:milli_seconds)  
  end

  
  defp assign(names, workers, task, pos) do
    if (pos != 11) do
      send({Enum.at(names,rem(pos+1,3)),Enum.at(workers,rem(pos+1,3))}, {:calcular, {self(), Enum.at(task,pos+1)}}) 
      IO.puts "Enviado #{pos+1}, #{Enum.at(workers,rem(pos+1,3))}"
      pos = pos + 1
      assign(names, workers, task, pos)
    end

  end

  def init() do
    task = [{1,24999}, {25000, 39999}, {40000, 52999},
            {53000,64999}, {65000,70000}, {70001,74999}, 
            {75000,81999}, {84000,89999}, {90000,94000}, 
            {95000,100000} 
           ] 
    workers = [:"worker1@#{@host1}", :"worker2@#{@host1}", :"worker3@#{@host1}"]
    names = [:worker1, :worker2, :worker3]
    assign(names, workers, task, -1)
    collect([], 0)
  end  

  defp collect(results,pos) do
    IO.puts "Estoy esperando..."
    new_result = receive do
      {:resultado, result} ->  result
                               
      #                        IO.inspect "#{result}"[0]
      #{:resultado, result} -> IO.puts List.to_string(result)
                              #result
    end
    IO.puts "Recibido #{pos}"
    first = List.first(new_result)
    last = List.last(new_result)
    IO.puts "#{first} to #{last}"
    if pos < 9 do
      #IO.puts "entra en el IF"
      pos = pos + 1
      collect([results | new_result],pos)
    else
      #IO.puts "entra en el ELSE"
      List.flatten(results, new_result)
      #results = [results | new_result]
      #results = List.flatten(results)
      #list = List.to_string(results)
      #IO.inspect "#{results}"

    end
  end


end
