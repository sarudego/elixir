# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: chat.exs
# FECHA: 20/10/17
# TIEMPO: 4 + 3 + 3 + 2 = 12 horas de trabajo en pareja.
# DESCRIPCI'ON: fichero Elixir que contiene la primera parte de la practica 2 de Sistemas Distribuidos. Chat distribuido en Elixir.
# 				Para lanzar cualquiera de los nodos se ejecuta "iex --name nombre@IP --cookie p2 chat.exs"	

defmodule Chat do

  @numParticipantes 3
  
  def participante(nombreRegistro) do
  	Node.connect(:"node1@lab000")
    pidServidor = spawn(Chat,:servidorVariables,[0,0,false,[],1,false,[]])
    pidEscuchar = spawn(Chat,:escuchar,[pidServidor])
    spawn(Chat,:teclado,[pidServidor,[[:"node1@lab000",:node1],[:"node2@lab000",:node2],[:"node3@lab000",:node3]],nombreRegistro])
    Process.register(pidEscuchar,nombreRegistro)
    while() 
  end
  
  def teclado(pidServidor,participantes,nombreRegistro) do
  	msg = IO.gets "Mensaje a enviar: "
    send(pidServidor,{self(),:waitVariables})
    receive do
      {pidServidor,{osc,hsc,rcs,rd}} -> send(pidServidor,{self(),:signalVariables,hsc+1,hsc,true,rd})
             Enum.each(participantes,fn([x|xs])-> if hd(xs) != nombreRegistro, do: send({hd(xs),x},{:request,osc,self()})end)	
			 esperarACK(@numParticipantes-1)
			 Enum.each(participantes,fn([x|xs])->send({hd(xs),x},{nombreRegistro,:mensaje,msg})end)
			 send(pidServidor,{self(),:cambiarRCS})
			 send(pidServidor,{self(),:leerDeferred})
			 receive do
			   {pidServidor,rd} -> if rd != [], do: Enum.each(rd,fn(x)->send(x,{self(),:ack})end)
			 end
     end
     teclado(pidServidor,participantes,nombreRegistro)
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
  
  def servidorVariables(osc,hsc,rcs,rd,mutex,esperando,wait) do 
  	if mutex == 1 do
  	  receive do
        {pid,:waitVariables} -> send(pid,{self(),{osc,hsc,rcs,rd}}); servidorVariables(osc,hsc,rcs,rd,0,false,wait)
  	  	{pid,:cambiarRCS} -> servidorVariables(osc,hsc,false,rd,mutex,esperando,wait)
  	  	{pid,:cambiarRD,nrd} -> servidorVariables(osc,hsc,false,rd ++ [nrd],mutex,esperando,wait)
  	  	{pid,:leerDeferred} -> send(pid,{self(),rd}); servidorVariables(osc,hsc,rcs,[],mutex,esperando,wait)
  	  	{pid,:leerHSC} -> send(pid,{self(),hsc}); servidorVariables(osc,hsc,rcs,rd,mutex,esperando,wait)
  	  	{pid,:modificarHSC,x} -> servidorVariables(osc,x,rcs,rd,mutex,esperando,wait)
  	  end
  	else
  	  receive do
        {pid,:waitVariables} -> servidorVariables(osc,hsc,rcs,rd,0,true,pid)
        {pid,:signalVariables,nosc,nhsc,nrcs,nrd} -> if esperando do 
        	send(wait,{self(),{nosc,nhsc,nrcs,nrd}})
      	    servidorVariables(nosc,nhsc,nrcs,nrd,0,false,[])
      	  else
      	    servidorVariables(nosc,nhsc,nrcs,nrd,1,false,[])
      	  end
      	{pid,:cambiarRCS} -> servidorVariables(osc,hsc,false,rd,mutex,esperando,wait)
      	{pid,:cambiarRD,nrd} -> servidorVariables(osc,hsc,false,rd ++ [nrd],mutex,esperando,wait)
      	{pid,:leerDeferred} -> send(pid,{self(),rd}); servidorVariables(osc,hsc,rcs,[],mutex,esperando,wait)
      	{pid,:leerHSC} -> send(pid,{self(),hsc}); servidorVariables(osc,hsc,rcs,rd,mutex,esperando,wait)
      	{pid,:modificarHSC,x} -> servidorVariables(osc,x,rcs,rd,mutex,esperando,wait)
  	  end
  	
  	end
  end
  
  defp while() do
  	while()
  end

end
		
