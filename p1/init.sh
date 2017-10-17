elixir  --name nodoA@127.0.0.1 --cookie 'monster' \
  --erl  '-kernel inet_dist_listen_min 32000' \
  --erl  '-kernel inet_dist_listen_max 32009' \
Server.exs

pkill epmd
