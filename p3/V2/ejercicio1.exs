# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: ejercicio1.exs
# FECHA: 12/11/17
# TIEMPO: 4 + 3  = 7 horas de trabajo conjunto
# DESCRIPCI'ON: fichero Elixir que contiene la practica 3 de Sistemas Distribuidos. Sistema Master-Worker con tolerancia a fallos.
#				Se consideran todos nodos configurados y los archivos necesarios cargados (ejercicio1.exs); se debe lanzar primero el servidor en ambos casos.
# 				Para lanzar cualquiera de los nodos se ejecuta "iex --name nombre@IP --cookie p3 ejericcio1.exs"

defmodule Worker do

  @host1 "127.0.0.1"

  def init do
    case :random.uniform(100) do
      random when random > 80 -> :crash
      random when random > 50 -> :omission
      random when random > 25 -> :timing
      _ -> :no_fault
    end
  end

  def crearWorker(tipoOP,proxyN,proxyR) do
    Node.connect(:"node1@#{@host1}")
    loopI(init(),tipoOP,proxyN,proxyR,0)
  end

  defp loopI(worker_type,tipoOP,proxyN,proxyR,aux) do
    Code.load_file("operaciones.exs")
    if ((worker_type == :timing) or (worker_type == :no_fault) and aux==0), do: send({proxyR,proxyN},{:nuevo_lider,tipoOP,self()})
    delay = case worker_type do
      :crash -> if :random.uniform(100) > 75, do: :infinity
        :timing -> :random.uniform(100)*10
        _ ->  0
    end
    Process.sleep(delay)
    receive do
      {:req,m_pid,m} -> if (((worker_type == :omission) and (:random.uniform(100) < 75)) or (worker_type == :timing) or (worker_type==:no_fault)), do: send(m_pid, {:res,op(m,tipoOP)})
    end
    loopI(worker_type,tipoOP,proxyN,proxyR,1)
  end

  defp op(n,tipoOP) do
    case tipoOP do
      1 -> Operaciones.divisores(n)
      2 -> Operaciones.sumaDivisoresPropios(n)
      3 -> Operaciones.suma(n)
    end
  end

end

defmodule Proxy do

  def proxy(master_PID,worker1,worker2,worker3,n) do
    receive do
      {:req,master_PID,n,trabajador} ->
        case trabajador do
          1 ->spawn(Proxy,:action,[n,worker1,1,master_PID,1000,0])
          2 ->spawn(Proxy,:action,[n,worker2,2,master_PID,1000,0])
          3 ->spawn(Proxy,:action,[n,worker3,3,master_PID,1000,0])
        end
        proxy(master_PID,worker1,worker2,worker3,n)
      {:nuevo_lider,tipo,pid} -> if n == 2 do
        case tipo do
          1 ->  send(master_PID,{self(),:registro_completo}); proxy(master_PID,pid,worker2,worker3,n+1)
          2 ->  send(master_PID,{self(),:registro_completo}); proxy(master_PID,worker1,pid,worker3,n+1)
          3 ->  send(master_PID,{self(),:registro_completo}); proxy(master_PID,worker1,worker2,pid,n+1)
        end
        else
          case tipo do
            1 ->  proxy(master_PID,pid,worker2,worker3,n+1)
            2 ->  proxy(master_PID,worker1,pid,worker3,n+1)
            3 ->  proxy(master_PID,worker1,worker2,pid,n+1)
          end
      end
    end
  end

  def action(n,worker_pid,tipo,master_PID,timeout,retry) when retry < 5 do
    send(worker_pid,{:req,self(),n})
    receive do
      {:res,sol} -> send(master_PID,{:ok,sol})
    after
      timeout ->  action(n,worker_pid,tipo,master_PID,timeout,retry+1)
    end
  end

  def action(n,worker_pid,tipo,master_PID,timeout,retry) when retry == 5 do
    send(master_PID,{:error})
  end

end

defmodule Master do

  def master() do
    pid = spawn(Proxy,:proxy,[self(),0,0,0,0])
    Process.register(pid,:proxy)
    Code.load_file("operaciones.exs")
    receive do
      {pid,:registro_completo} -> IO.puts "REGISTRO COMPLETO";comprobar(1,[],pid)
    end
  end

  defp calcularAmigos(n,pid,listaVisitados) do
    bucle2(n,0,0,0,pid,listaVisitados)
  end

  defp comprobar(n,listaVisitados,pid) when n <= 1000000 do
    if n in listaVisitados, do: comprobar(n+1,listaVisitados,pid),
    else: calcularAmigos(n,pid,listaVisitados)
  end

  defp comprobar(n,listaVisitados,pid) do
    IO.puts "Trabajo terminado"
  end

  defp bucle2(a,b,sumA,v,pid,listaVisitados) do
    send(pid,{:req,self(),a,2})
    receive do

      {:ok,sol} -> if v == 0, do: bucle2(sol,a,sol,1,pid,listaVisitados ++ [a]),
        else: if  (a != b) && Operaciones.sonAmigos(b,sumA,a,sol), do: IO.inspect [b,a]; comprobar(b+1,listaVisitados ++ [a],pid)

          {:error}  -> if v == 0, do: bucle1y3(a,b,sumA,0,pid,listaVisitados),
            else: bucle1y3(a,b,sumA,1,pid,listaVisitados)

    end
  end

  defp bucle1y3(a,b,sumA,v,pid,listaVisitados) do
    send(pid,{:req,self(),a,1})
    receive do

      {:ok,sol1} -> if v == 0 do
        send(pid,{:req,self(),sol1,3})
        receive do
          {:ok,sol2} -> bucle2(b,a,sol2,1,pid,listaVisitados ++ [a])
          {:error} -> bucle2(a,b,0,0,pid,listaVisitados)
        end
      else send(pid,{:req,self(),sol1,3})
        receive do
          {:ok,sol2} -> if Operaciones.sonAmigos(b,sumA,a,sol2), do: IO.inspect [b,a]; comprobar(b+1,listaVisitados ++ [a],pid)
            {:error} -> bucle2(a,b,sumA,1,pid,listaVisitados)
        end
      end

      {:error}  -> if v == 0, do: bucle2(a,b,sumA,0,pid,listaVisitados),
       else: bucle2(a,b,sumA,1,pid,listaVisitados)
    end
  end

end
