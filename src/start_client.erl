-module(start_client).
-author("nekrasov").

-export([main/0]).

main() ->
  erlang:display(net_kernel:connect_node('bank_server@razrab11.csort.local')),
  erlang:display(code:load_file(bank_server)),
  timer:sleep(1000),
  erlang:display(bank_server:getBalance(64, 16)),
  erlang:display(bank_server:putMoney(64, 16, 1000)),
  erlang:display(bank_server:getBalance(64, 16)),
  erlang:display(bank_server:getMoney(64, 16, 25)),
  erlang:display(bank_server:getBalance(64, 16)),
  erlang:display(bank_server:getBalance(32, 8)),
  erlang:display(bank_server:sendMoney(64, 16, 32, 100)),
  erlang:display(bank_server:getBalance(64, 16)),
  erlang:display(bank_server:getBalance(32, 8)).