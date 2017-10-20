defmodule NodoRemoto do

  def stop(nodo) do
    :rpc_call(nodo, :erlang, :halt, [])
  end

end
