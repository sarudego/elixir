# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: main.exs
# FECHA: 26/10/17
# TIEMPO: 7 + 9  = 16 horas de trabajo conjunto
# DESCRIPCI'ON: fichero Elixir que contiene las funciones para la práctica 1 de Sistemas Distribuidos. Server - Client
# 	Deben estar los nodos configurados y los archivos cargados
# 	Es necesario ejecutar los nodos con  "iex --name nombre@IP  -- cookie palabra"		


defmodule Fail do

  Code.require_file("amigos.exs")
  Code.require_file("worker.exs")

  def timestamp do
    :os.system_time(:milli_seconds)  
  end

  defp action({proxy_pid, proxy_dir} , {worker_reg, worker_dir}, {natural, m, resLista}, {timeout, retry}) when retry < 5 do
	send({worker_reg, worker_dir}, {:req, { proxy_pid, proxy_dir, m, natural, resLista}})
	receive do
	  {:res, result} ->   
		result		
	after
		timeout -> action({proxy_pid, proxy_dir} , {worker_reg, worker_dir}, {natural, m, resLista}, {timeout, retry + 1})
	end
  end

  defp action({proxy_pid, proxy_dir} , {worker_reg, worker_dir}, {natural, m, resLista}, {timeout, retry}) when retry == 5 do
	IO.puts("FAIL")
	-1
  end

  defp proxy_loop( {my_reg, my_dir}, pid_proxy_lider) do
	receive do
	  {:req_proxy, reg, dir, natural, unused} -> 
		send( pid_proxy_lider, {:request_lider, my_reg})
		receive do
		  {:res_lider, lider} -> 
			{worker_tipo2_reg, worker_tipo2_dir} = Enum.at(lider, 1)
			resultado = action({my_reg, my_dir} , {worker_tipo2_reg, worker_tipo2_dir}, {natural, 1, []}, {800, 0})
			if resultado == -1 do
			  IO.puts("ERROR 2")
			  {worker_tipo1_reg, worker_tipo1_dir} = Enum.at(lider, 0)
			  resultado = action({my_reg, my_dir} , {worker_tipo1_reg, worker_tipo1_dir}, {natural, 1, []}, {800, 0})
			  if resultado == -1 do
				IO.puts("ERROR 1")
				send({my_reg, my_dir}, {:req_proxy, reg, dir, natural, unused} )
			  else
				{worker_tipo3_reg, worker_tipo3_dir} = Enum.at(lider, 2)
				resultado = action({my_reg, my_dir} , {worker_tipo3_reg, worker_tipo3_dir}, {natural, 1, resultado}, {800, 0})
				if(resultado == -1) do
				  IO.puts("ERROR 3")
				  send({my_reg, my_dir}, {:req_proxy, reg, dir, natural, unused} )
				else
				  IO.puts("CORRECTO 1 3")
				  send({:"master", :"master@127.0.0.1"}, {:resultado, resultado, natural, my_reg})
				end
			  end
			else
			  IO.puts("CORRECTO 2")
			  send({:"master", :"master@127.0.0.1"}, {:resultado, resultado, natural, my_reg})
			end	#if
		end #receive
	end	#receive
	proxy_loop( {my_reg, my_dir}, pid_proxy_lider)
  end

  def proxy_lider( lider ) do
	receive do
	  {:request_lider, pid_proxy} -> send(pid_proxy, {:res_lider, lider})
	  {:soy_lider, {reg_lider, dir_lider}, tipo} -> 
		lider = List.replace_at(lider, tipo-1, {reg_lider, dir_lider})
	end
	proxy_lider( lider )
  end

  def enviar_eleccion( {id, my_reg, my_dir}, [{id_dest, reg_dest, dir_dest}|tail] ) do
	if id_dest > id do
	  IO.puts("envio eleccion")
	  IO.puts(dir_dest)
	  send( {reg_dest, dir_dest},  {:eleccion, my_reg, my_dir} )
	end
	if List.last(tail) != nil do
	  enviar_eleccion( {id, my_reg, my_dir}, tail)
	end
  end

  def enviar_soy_lider(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, [{id_dest, reg_dest, dir_dest}|tail]) do
	if List.last(tail) != nil do
	  if dir_dest != my_dir do
	    send({:"worker_rec", dir_dest},{:soy_lider, my_worker, my_dir})
	    enviar_soy_lider(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, tail)
	  else
		enviar_soy_lider(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, tail)
	  end
	else
	  if dir_dest != my_dir do
		send({:"worker_rec", dir_dest},{:soy_lider, my_worker, my_dir})
	    IO.puts("envio a proxy")
	    send({:"proxy_rec1", proxy_dir}, {:soy_lider, {my_worker, my_dir}, tipo})
	    send({:"proxy_rec2", proxy_dir}, {:soy_lider, {my_worker, my_dir}, tipo})
	  else
		IO.puts("envio a proxy")
	    send({:"proxy_rec1", proxy_dir}, {:soy_lider, {my_worker, my_dir}, tipo})
	    send({:"proxy_rec2", proxy_dir}, {:soy_lider, {my_worker, my_dir}, tipo})
	  end
	  
	end
  end

  def recibir_eleccion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, [{id_dest, reg_dest, dir_dest}|tail] , grupo) do
	if id_dest > id do
	  receive do
		{:"ok",pid_rec, dir_rec} -> 
			bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, {pid_rec, dir_rec})
	  after
		500 -> IO.puts("LIDER SIN RESP") 
		enviar_soy_lider(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo)
		bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, {my_reg, my_dir})
	  end
	else
	  if List.last(tail) != nil do
	  	recibir_eleccion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, tail , grupo)
	  else
		IO.puts("LIDER MAYOR ID") 
		enviar_soy_lider(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo)
		bucle_recepcion(proxy_dir,  {id, my_reg, my_dir, tipo, my_worker}, grupo, {my_reg, my_dir})
	  end
	end
  end

  def bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, {reg_lider, dir_lider}) do
	receive do
	  {:soy_lider, pid_origen, dir_origen} ->
		IO.puts(" HAY NUEVO  LIDER")
		IO.puts(dir_origen)
		IO.puts(pid_origen)
		send({pid_origen, dir_origen}, {:pulso, my_reg, my_dir})
		bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, {pid_origen, dir_origen})
	  {:res_pulso, pid_origen, dir_origen} ->
		:timer.sleep(200)
		if dir_origen == dir_lider do
		  send({pid_origen, dir_origen}, {:pulso, my_reg, my_dir})
		  bucle_recepcion(proxy_dir,  {id, my_reg, my_dir, tipo, my_worker}, grupo, {reg_lider, dir_lider})
		else
		  bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, {reg_lider, dir_lider})
		end
	after
	  300 -> 
		  if dir_lider == my_dir do
			bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, {reg_lider, dir_lider}) 
		  else
			send({my_worker, my_dir},{:ready,  my_reg, my_dir})
			IO.puts("ESPERA READY")
			receive do
			  {:ready_ok} ->
				IO.puts("ELECCION")
				IO.puts(timestamp())
				enviar_eleccion({id, my_reg, my_dir}, grupo)
				IO.puts("RECEPCION")
				IO.puts(timestamp())
				recibir_eleccion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, grupo)
			after
	  			300 ->  bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, {reg_lider, dir_lider}) 
			end
		  end
	end
	
  end

  def proxy_lider_init(id, lider) do
	myReg = String.to_atom("proxy_rec"<>Integer.to_string(id))
	Process.register(self(), myReg)
	proxy_lider(lider)
  end

  def proxy(id,  myDir , lider) do
	myReg = String.to_atom("proxy"<>Integer.to_string(id))
	Process.register(self(), myReg)
	pid = spawn(Fail, :proxy_lider_init, [id, lider])
	proxy_loop({myReg, myDir}, pid)
  end

  def bucle_recepcion_init(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, lider) do
	Process.register(self(), :"worker_rec")
	bucle_recepcion(proxy_dir, {id, my_reg, my_dir, tipo, my_worker}, grupo, lider)
  end

  def workerInit(id, myReg ,myDir, tipo, proxy_dir) do
	workers = [:"worker1", :"worker2", :"worker3", :"worker4", :"worker5", :"worker6", :"worker7", :"worker8", :"worker9"]
	grupo1 = [{1, :"worker1", :"worker1@127.0.0.1"},{2, :"worker2", :"worker2@127.0.0.1"},{3, :"worker3", :"worker3@127.0.0.1"}]
	grupo2 = [{4, :"worker4", :"worker4@127.0.0.1"},{5, :"worker5", :"worker5@127.0.0.1"},{6, :"worker6", :"worker6@127.0.0.1"}]
 	grupo3 = [{7, :"worker7", :"worker7@127.0.0.1"},{8, :"worker8", :"worker8@127.0.0.1"},{9, :"worker9", :"worker9@127.0.0.1"}]
	if(tipo == 1) do
      pid = spawn(Fail, :bucle_recepcion_init, [proxy_dir, {id, :"worker_rec", myDir, tipo, Enum.at(workers, id-1)}, grupo1, {:"0" ,:"0"}])
      Process.register(self(), String.to_atom("worker" <> Integer.to_string(id)))
      Worker.loop(tipo,myReg , myDir)
	end
	if(tipo == 2) do
      pid = spawn(Fail, :bucle_recepcion_init, [proxy_dir, {id, :"worker_rec", myDir, tipo, Enum.at(workers, id-1)}, grupo2, {:"0" ,:"0"}])
      Process.register(self(), String.to_atom("worker" <> Integer.to_string(id)))
      Worker.loop(tipo,myReg , myDir)
	end
	if(tipo == 3) do
      pid = spawn(Fail, :bucle_recepcion_init, [proxy_dir, {id, :"worker_rec", myDir, tipo, Enum.at(workers, id-1)}, grupo3, {:"0" ,:"0"}])
      Process.register(self(), String.to_atom("worker" <> Integer.to_string(id)))
      Worker.loop(tipo,myReg , myDir)
	end
  end

  def comprobarAmigo([val | tail], new, new_suma, pos) do
	if List.last(tail) != nil do
	  if val == new and new_suma==pos do
		IO.puts("----------------------------------")
		IO.puts(pos)
	  end
	  comprobarAmigo(tail, new, new_suma,  pos+1)
	end
  end

  def recorrer(lista, recorrido, my_dir) do
	IO.puts(timestamp())
	receive do
	  {:resultado, res, n, origen} -> IO.puts(Integer.to_string(n) <> "--")
		comprobarAmigo(lista, n, res, 0)
		lista = List.insert_at(lista, n, res)
		send({origen,:"master@127.0.0.1"}, {:req_proxy, :"master", my_dir, recorrido, 30} )
		if(n < 100000) do
		  recorrer(lista, recorrido+1, my_dir)
		end
	end
  end

  def master(my_dir) do
	pid_proxy_1 = spawn(Fail, :proxy, [1, my_dir, [{:"worker3",:"worker3@127.0.0.1"}, {:"worker6",:"worker6@127.0.0.1"}, {:"worker9",:"worker9@127.0.0.1"}]])
	pid_proxy_2 = spawn(Fail, :proxy, [2, my_dir, [{:"worker3",:"worker3@127.0.0.1"}, {:"worker6",:"worker6@127.0.0.1"}, {:"worker9",:"worker9@127.0.0.1"}]])
	Process.register(self(), :"master")
	:timer.sleep(2000)
	send({:"proxy1",:"master@127.0.0.1"}, {:req_proxy, :"master", my_dir, 3, 30} )
	send({:"proxy2",:"master@127.0.0.1"}, {:req_proxy, :"master", my_dir, 4, 30} )
	recorrer([0, 0, 0], 5, my_dir)
  end

end
