# AUTOR: Rafael Tolosana Calasanz
# NIAs: -
# FICHERO: para_primes.exs
# FECHA: 29 de septiembre de 2017
# TIEMPO: -
# DESCRIPCI'ON: c’odigo para el servidor / worker

defmodule Primes do

  defp is_prime(a, i)  when i == a - 1 do
    rem(a, a - 1) != 0
  end
  defp is_prime(a, i) do
    if rem(a, i) == 0 do 
      false 
    else
      is_prime(a, i + 1)
    end
  end

  def is_prime(a) when (a == 1 or a == 2) do
    true
  end
  def is_prime(a) when a > 2 do
    is_prime(a, 2)
  end

  defp find_primes({a, a}, queue) do
    if is_prime(a), do: [a | queue], else: queue
  end
  defp find_primes({a, b}, queue) when a != b do
    find_primes({a, b - 1}, (if is_prime(b), do: [b | queue], else: queue))
  end

  def find_primes({a, b}) do
    find_primes({a, b}, [])
  end  
end
 
