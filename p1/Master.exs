defmodule Master do
    def assign([{worker_pid, task} | tail]) do
        send(worker_pid, {:calcular, {self(), task}})
        assign(tail)
    end

    def collect(results) do
        new_result = receive do
            {:resultado, result} -> result
        end
        collect([new_result | results])
    end

    def init(min, max) do
        #Divisón del rango en tres trozos
        slice = div max, 3
        assign([{{:worker1, :"worker1@192.168.45.17"}, {min, min + slice}},
                {{:worker2, :"worker2@192.168.45.17"}, {min + slice, min + slice * 2}},
                {{:worker3, :"worker3@192.168.45.17"}, {min + slice * 2, max}}])
        collect([])
    end
end