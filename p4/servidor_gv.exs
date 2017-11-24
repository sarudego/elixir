defmodule ServidorGV do

    @moduledoc """
        modulo del servicio de vistas
    """

    # Tipo estructura de dtos que guarda el estado del servidor de vistas
    # COMPLETAR  con lo campos necesarios para gestionar
    # el estado del gestor de vistas


    #num_vista: 0 , primario: nil, copia: nil , otros: [] # Vista

    defstruct   vista_v:
                  %{num_vista: 0,primario: :undefined,copia: :undefined},

                vista_t:
                    %{num_vista: 0,primario: :undefined,copia: :undefined},


                vidas: %{}, # vida de todos
                otros: %{}, # otros servidores

                reloj: %{}, #latido mas reciente
                init: false,
                confirmar: false,
                valido: true
                #vista lista otros no necesaria
    @tiempo_espera_carga_remota 1000

    @periodo_latido 50

    @latidos_fallidos 4


   @doc """
        Generar un estructura de datos vista inicial
    """

    def vista_inicial() do
        #%ServidorGV{}.vista_v
        %{num_vista: 0,primario: :undefined,copia: :undefined}
    end

    @doc """
        Poner en marcha el servidor para gestión de vistas
    """
    @spec start(String.t, String.t) :: atom
    def start(host, nombre_nodo) do
        nodo = NodoRemoto.start(host, nombre_nodo,__ENV__.file,
                                __MODULE__)

        Node.spawn(nodo, __MODULE__, :init_sv, [])

        nodo
    end


    #------------------- Funciones privadas

    # Estas 2 primeras deben ser defs para llamadas tipo (MODULE, funcion,[])
    def init_sv() do
        Process.register(self(), :servidor_gv)

        spawn(__MODULE__, :init_monitor, [self()]) # otro proceso concurrente

        #### VUESTRO CODIGO DE INICIALIZACION


        bucle_recepcion( %ServidorGV{} )
    end

    def init_monitor(pid_principal) do
        send(pid_principal, :procesa_situacion_servidores)
        Process.sleep(@periodo_latido)
        init_monitor(pid_principal)
    end


    defp bucle_recepcion( estado ) do

      nuevo_estado = receive do
                {:latido, nodo_origen, n_vista} ->
                      ### VUESTRO CODIGO
                      #si esta sin inicializar
                      if (estado.init == false ) do
                        a = %{estado.vista_v |
                              primario: nodo_origen ,num_vista: 1}
                        nvida = Map.merge(estado.vidas,
                              %{nodo_origen => 5})
                        nreloj = Map.merge(estado.reloj,
                                %{nodo_origen => n_vista})
                        nest = %{estado |
                              init: true , vista_v: a,vista_t: a ,
                              vidas: nvida, reloj: nreloj}
                        send({:cliente_gv,nodo_origen},
                            {:vista_tentativa,nest.vista_t,nest.valido})
                        nest
                      else
                        #esta inicializado, se añaden vidas, reloj
                        nvida = Map.merge(estado.vidas,
                                  %{nodo_origen => 5})
                        nreloj = Map.merge(estado.reloj,
                                %{nodo_origen => n_vista})
                        #si ya esta en primario,copia entonces a otros
                        #Comprobar si ya estaba trazeado el nodo
                        nest =
                        if(estado.vista_v.primario == nodo_origen) do
                          %{estado |  vidas: nvida, reloj: nreloj}
                        else
                            if(estado.vista_v.copia == nodo_origen )do
                                %{estado |  vidas: nvida, reloj: nreloj}
                            else
                                notros = Map.merge(estado.otros,
                                          %{nodo_origen => 0})
                                  #IO.puts("#{inspect notros}\n")
                                %{estado |
                                    vidas: nvida,
                                    reloj: nreloj ,
                                    otros: notros}
                            end
                        end
                        #si falta confirmacion por parte del
                        #primario de tentativa  num vista
                        last=
                        if(nest.confirmar == true
                              && nest.vista_t.primario == nodo_origen)do
                          if (nest.vista_t.num_vista
                              == nest.reloj[nodo_origen])do
                            #Limpieza de otros si han pasado a las vistas
                            a =  Map.delete(nest.otros, nest.vista_t.primario)
                            b =  Map.delete(a, nest.vista_t.copia)
                            #modificar vista valida
                            vistaNu = nest.vista_t
                             %{nest |
                                confirmar: false ,
                                vista_v: vistaNu,
                                 otros: b}
                            else
                                nest
                          end
                        else

                          nest
                        end
                        send({:cliente_gv,nodo_origen},
                            {:vista_tentativa,last.vista_t, last.valido})
                         last

                      end


                {:obten_vista, pid} ->

                    ###5 VUESTRO CODIGO

                  send(pid,{:vista_valida,estado.vista_v,estado.valido})
                  #IO.puts("
                  #  Vp: #{inspect estado.vidas[estado.vista_v.primario]}
                  #  Vc: #{inspect estado.vidas[estado.vista_v.copia]}
                  #  Valido:    #{inspect estado.valido}
                  #  Confirmar: #{inspect estado.confirmar}
                  #  vistaValida: #{inspect estado.vista_v}
                  #  vistaTentat: #{inspect estado.vista_t}")


                    estado

                :procesa_situacion_servidores ->

                    ### VUESTRO CODIGO
                    procesar_situacion_servidores(estado)

        end

        bucle_recepcion(nuevo_estado)
    end

    defp procesar_situacion_servidores(estado) do


        #### VUESTRO CODIGO

        if (estado.valido == false) do
          estado
        else
        n = quitar_vidas(estado)
        nestado =
        if (n.vidas[n.vista_v.primario] < 1)do
          #primario ha caido ,
            #pasar si habia copia en valida a primaria en tentativa
          if (n.vista_v.copia != :undefined )do
            #primario ha caido ,
              #pasar si habia copia en valida a primaria en tentativa
             ntentativa = %{n.vista_t |
                  primario: n.vista_v.copia ,
                  copia: :undefined ,
                  num_vista: n.vista_v.num_vista+1}
             %{n | vista_t: ntentativa, confirmar: true}
          else
            can = %{n.vista_v | primario: :undefined , copia: :undefined }

            %{n | valido: false , vista_v: can, vista_t: can}
          end
        else

          if (n.vidas[n.vista_v.copia] < 1)do
            #copia ha caido , pasar alguno de otros a copia tentativa
            listaOtros = for {k,_x} <- n.otros do
              k
            end

            if (length(listaOtros)>0)do
              #se puede pasar de otros a copia tentativa
              [h | _tail ]= listaOtros

              ntentativa = %{n.vista_t |
                            copia: h,
                            num_vista: n.vista_v.num_vista + 1}
              %{n | vista_t: ntentativa, confirmar: true}
            else
              #no hay otros disponibles
              # pues en esta ronda no se puede crear tentativa
              n
            end
          else

              if (n.vista_v.copia == :undefined )do
                #copia no asignada
                 listaOtros = for {k,_x} <- n.otros do
                   k
                 end

                 if (length(listaOtros)>0)do
                   #se puede pasar de otros a copia tentativa
                   [h | _tail ]= listaOtros

                   ntentativa = %{n.vista_t |
                                  copia: h,
                                  num_vista: n.vista_v.num_vista + 1}
                   %{n | vista_t: ntentativa, confirmar: true}
                 else
                   #no hay otros disponibles
                   # pues en esta ronda no se puede crear tentativa
                   n
                 end
              else
                  n
              end
          end
        end
        nestado
      end
    end

    #funcion para quitar vidas a los nodos
    defp quitar_vidas(estado) do
      a =  Enum.map(estado.vidas, fn({t,x}) ->
        {t ,x - 1}
      end)
      a2 = Enum.into(a,%{})
       %{estado | vidas: a2 }
    end
end
