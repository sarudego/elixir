# AUTORES: Roberto Claver Ubiergo / Samuel Ruiz de Gopegui Muñoz 
# NIAs: 720100 / 685127
# FICHERO: operaciones.exs
# FECHA: 12/11/17
# TIEMPO: 4 + 3  = 7 horas de trabajo conjunto
# DESCRIPCI'ON: fichero Elixir que contiene las operaciones que ejecutan los trabajadores y el maestro de la practica 3 de Sistemas Distribuidos. Sistema Master-Worker con tolerancia a fallos.

defmodule Operaciones do

  def suma(lista) when lista != [0] do
    Enum.sum(lista)
  end

  def suma(lista) when lista == [0] do
    0
  end

  defp divisoresAux(n, d, queue) when d == 1 do
    if rem(n,d) == 0, do: [d | queue], else: queue
  end

  defp divisoresAux(n, d, queue) do
    divisoresAux(n, d-1 , (if rem(n,d) == 0, do: [d | queue], else: queue))
  end

  def divisores(n) when n > 1 do
    divisoresAux(n, n-1, [])
  end

  def divisores(n) when n < 2 do
    [0]
  end

  def sumaDivisoresPropios(n) do
    suma(divisores(n))
  end

  def sonAmigos(a,sumA,b,sumB) do
    a==sumB && b==sumA
  end

end
