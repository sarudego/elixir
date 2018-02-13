defmodule Worker do

  #Code.require_file("amigos.exs")

  def init do
    case :random.uniform(100) do
      #random when random > 80 -> :crash
      #random when random > 50 -> :omission
      #random when random > 25 -> :timing
      _ -> :no_fault
    end
  end

  def loop(tipo, myReg,myDir) do
    loopI(init(), tipo, myReg,myDir)
  end



  def receive_worker(worker_type, tipo, myReg ,myDir) do
	 receive do
     {:req, { reg, dir, id_op, natural, list}} ->
			IO.puts("recibido")
            if (((worker_type == :omission) and (:random.uniform(100) < 75)) or (worker_type == :timing) or (worker_type==:no_fault)) do
			  send( {reg, dir} , {:res, op(tipo, natural, list)} )
			end
			loopI(worker_type, tipo,myReg, myDir)
	 {:pulso, pid_origen, dir_origen} ->
		 if (((worker_type == :omission) and (:random.uniform(100) < 75)) or (worker_type == :timing) or (worker_type==:no_fault)) do
			send({pid_origen, dir_origen}, {:res_pulso, myReg, myDir})
		 end
		receive_worker(worker_type, tipo, myReg,myDir)
	  {:eleccion, pid_origen, dir_origen} -> IO.puts("envio ------> ok")
		 if (((worker_type == :omission) and (:random.uniform(100) < 75)) or (worker_type == :timing) or (worker_type==:no_fault)) do
			send({pid_origen, dir_origen}, {:"ok", myReg, myDir})
		  end
		receive_worker(worker_type, tipo, myReg,myDir)
	  {:ready, pid_origen, dir_origen} -> 
		send({pid_origen, dir_origen}, {:ready_ok})
		receive_worker(worker_type, tipo, myReg,myDir)
    end
  end

  defp loopI(worker_type, tipo, myReg, myDir) do
	IO.puts(worker_type)
    delay = case worker_type do
      :crash -> if :random.uniform(100) > 75, do: :infinity
      :timing -> :random.uniform(100)*1000
      _ ->  0
    end
    Process.sleep(delay)
    receive_worker(worker_type, tipo, myReg,myDir)
    loopI(worker_type, tipo,myReg, myDir)
  end

  def op(m, n, list) do
		case {m,n,list} do
			{1, n, list} -> Amigos.divisores(n,n-1)
			{2, n, list} -> Amigos.sum_div(n)
			{3, n, list} -> Amigos.sum_list(list)
		end
	end

end
