# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: Chat.exs
# FECHA: 11/11/17
# TIEMPO: 
# DESCRIPCI'ON: 
# 	Deben estar los nodos configurados y los archivos cargados
# 	Es necesario ejecutar los nodos con  "iex --name nombre@IP  -- cookie palabra"		


defmodule Chat do

  @numParticipantes 3
  @host1 "127.0.0.1"
  @host2 "127.0.0.1"


  defp registrar(pidResponse, nombreRegistro) do
    Process.register pidResponse, nombreRegistro
  end

  defp connect() do
    Node.connect :"node1@#{@host1}"
  end

  def participante(nombreRegistro) do
    connect()
    pidRequest = spawn(Chat, :serverVar, [0,0,false,[],1,false,[]])
    pidResponse = spawn(Chat, :listen, [pidRequest])
    spawn(Chat,:keyboard,[pidRequest,[[:"node1@#{@host1}",:node1],[:"node2@#{@host1}",:node2],[:"node3@#{@host1}",:node3]],nombreRegistro])
    registrar(pidResponse, nombreRegistro)
    while()
  end

  def keyboard(pidRequest, participantes, nombreRegistro) do
    msg = IO.gets "Mensaje a enviar: "
    send(pidRequest, {self(), :waitVar})
    receive do
      {pidRequest, {osc, hsc, rcs, rd}} -> send(pidRequest, {self(), :signalVar, hsc+1, hsc, true, rd})
      Enum.each(participantes, fn([x|tx]) -> if hd(tx) != nombreRegistro, do: send({hd(tx),x},{:request, osc, self()})end)
      esperarACK(@numParticipantes-1)
      Enum.each(participantes,fn([x|tx])->send({hd(tx),x},{nombreRegistro,:mensaje,msg})end)
      send(pidRequest,{self(),:cambiarRCS})
      send(pidRequest,{self(),:leerDeferred})
      receive do
        {pidRequest,rd} -> if rd != [], do: Enum.each(rd,fn(x)->send(x,{self(),:ack})end)
      end
    end
    keyboard(pidRequest, participantes, nombreRegistro)
  end

  defp esperarACK(n) do
    receive do
      {pid,:ack} -> if n>1, do: esperarACK(n-1)
    end  
  end

  def escuchar(pidServidor) do
    receive do
      {:request,k,j} -> 
        send(pidServidor,{self(),:leerHSC})
        receive do
          {pidServidor,hsc} -> send(pidServidor,{self(),:modificarHSC,max(hsc,k)})
        end
        send(pidServidor,{self(),:waitVariables})
        receive do
          {pidServidor,{osc,hsc,rcs,rd}} -> defer_it = rcs && ((k>osc) || (k==osc && j>self()))
            send(pidServidor,{self(),:signalVariables,osc,hsc,rcs,rd})
        if defer_it, do: send(pidServidor,{self(),:cambiarRD,j}),
        else: send(j,{self(),:ack})
        escuchar(pidServidor)
    end
    {pid,:mensaje,msg} -> IO.puts(inspect(pid) <> ": " <> msg)
      escuchar(pidServidor)
    end
  end
  

  def serverVar(osc,hsc,rcs,rd,mutex,esperando,wait) do 
    if mutex == 1 do
      receive do
        {pid,:waitVariables} -> send(pid,{self(),{osc,hsc,rcs,rd}}); serverVar(osc,hsc,rcs,rd,0,false,wait)
        {pid,:cambiarRCS} -> serverVar(osc,hsc,false,rd,mutex,esperando,wait)
        {pid,:cambiarRD,nrd} -> serverVar(osc,hsc,false,rd ++ [nrd],mutex,esperando,wait)
        {pid,:leerDeferred} -> send(pid,{self(),rd}); serverVar(osc,hsc,rcs,[],mutex,esperando,wait)
        {pid,:leerHSC} -> send(pid,{self(),hsc}); serverVar(osc,hsc,rcs,rd,mutex,esperando,wait)
        {pid,:modificarHSC,x} -> serverVar(osc,x,rcs,rd,mutex,esperando,wait)
      end
    else
      receive do
        {pid,:waitVariables} -> serverVar(osc,hsc,rcs,rd,0,true,pid)
        {pid,:signalVariables,nosc,nhsc,nrcs,nrd} -> if esperando do 
          send(wait,{self(),{nosc,nhsc,nrcs,nrd}})
            serverVar(nosc,nhsc,nrcs,nrd,0,false,[])
          else
            serverVar(nosc,nhsc,nrcs,nrd,1,false,[])
          end
        {pid,:cambiarRCS} -> serverVar(osc,hsc,false,rd,mutex,esperando,wait)
        {pid,:cambiarRD,nrd} -> serverVar(osc,hsc,false,rd ++ [nrd],mutex,esperando,wait)
        {pid,:leerDeferred} -> send(pid,{self(),rd}); serverVar(osc,hsc,rcs,[],mutex,esperando,wait)
        {pid,:leerHSC} -> send(pid,{self(),hsc}); serverVar(osc,hsc,rcs,rd,mutex,esperando,wait)
        {pid,:modificarHSC,x} -> serverVar(osc,x,rcs,rd,mutex,esperando,wait)
    end

    end
  end

  defp while() do
    while()
  end


end
