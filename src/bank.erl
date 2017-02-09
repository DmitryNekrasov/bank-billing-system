%%%-------------------------------------------------------------------
%%% @author nekrasov
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(bank).
-author("nekrasov").

%% API
-export([main/0]).

getBalanceProcess(Clients, Deposit, Pin) ->
  ClientPid = findClient(Clients, Deposit),
  ClientPid ! {get_card, Deposit, self()},
  receive
    {card, Card} ->
      GoodPin = checkPin(Pin, Card),
      if
        GoodPin -> getBalance(Card);
        true -> false
      end
  end.

getMoneyProcess(Clients, Deposit, Pin, Sum) ->
  ClientPid = findClient(Clients, Deposit),
  ClientPid ! {get_card, Deposit, self()},
  receive
    {card, Card} ->
      GoodPin = checkPin(Pin, Card),
      GoodSum = checkSum(Sum, Card),
      if
        (GoodPin and GoodSum) ->
          ClientPid ! {get_money, Deposit, Sum},
          true;
        true -> false
      end
  end.

putMoneyProcess(Clients, Deposit, Pin, Sum) ->
  ClientPid = findClient(Clients, Deposit),
  ClientPid ! {get_card, Deposit, self()},
  receive
    {card, Card} ->
      GoodPin = checkPin(Pin, Card),
      if
        GoodPin ->
          ClientPid ! {put_money, Deposit, Sum},
          true;
        true -> false
      end
  end.

sendMoneyProcess(Clients, Deposit, Pin, DepositTo, Sum) ->
  Ok = getMoneyProcess(Clients, Deposit, Pin, Sum),
  if
    Ok == true ->
      putMoneyWithoutPinProcess(Clients, DepositTo, Sum),
      true;
    true -> false
  end.

putMoneyWithoutPinProcess(Clients, Deposit, Sum) ->
  ClientPid = findClient(Clients, Deposit),
  ClientPid ! {get_card, Deposit, self()},
  receive
    {card, _} -> ClientPid ! {put_money, Deposit, Sum}
  end.

findClient([], _) -> false;
findClient([ClientPid | T], Deposit) ->
  ClientPid ! {has_card, Deposit, self()},
  receive
    {have, ClientPid, true} -> ClientPid;
    {have, _, false} -> findClient(T, Deposit)
  end.

getBalance({_, _, _, Sum, _}) -> Sum.

checkSum(Sum, {_, _, _, RealSum, _}) -> (RealSum >= Sum).

checkPin(Pin, {_, Pin, _, _, _}) -> true;
checkPin(_, {_, _, _, _, _}) -> false.

main() ->
  ClientsCount = 3,
  BankPid = spawn(fun() -> bank(ClientsCount) end),
  global:register_name(bank, BankPid).

bank(Clients) when is_list(Clients) ->
  receive
    {get_clients, Pid} ->
      Pid ! {clients, Clients};
    {add_client, ClientId} ->
      NewClientPid = spawn(fun() -> bankClient(ClientId, 3) end),
      NewClientsList = [NewClientPid | Clients],
      bank(NewClientsList)
  end;
bank(ClientsCount) ->
  Clients = createClients(ClientsCount),
  bank(Clients).

createClients(0) -> [];
createClients(ClientsCount) ->
  ClientId = generateClientId(ClientsCount),
  CardsCount = generateCardsCount(),
  ClientPid = spawn(fun() -> bankClient(ClientId, CardsCount) end),
  [ClientPid | createClients(ClientsCount - 1)].

generateClientId(X) -> X * 3.

generateCardsCount() -> rand:uniform(5).

bankClient(ClientId, Cards) when is_list(Cards) ->
  receive
    {has_card, Deposit, Pid} ->
      HasCard = hasCard(Cards, Deposit),
      Pid ! {have, self(), HasCard};
    {get_card, Deposit, Pid} ->
      Card = getCard(Cards, Deposit),
      Pid ! {card, Card};
    {put_money, Deposit, Sum} ->
      UpdateCards = putMoneyToDeposit(Cards, Deposit, Sum),
      bankClient(ClientId, UpdateCards);
    {get_money, Deposit, Sum} ->
      UpdateCards = getMoneyFromDeposit(Cards, Deposit, Sum),
      bankClient(ClientId, UpdateCards)
  end;
bankClient(ClientId, CardsCount) ->
  Cards = createCards(ClientId, CardsCount),
  bankClient(ClientId, Cards).

hasCard([], _) -> false;
hasCard([{Deposit, _, _, _, _} | _], Deposit) -> true;
hasCard([_ | T], Deposit) -> hasCard(T, Deposit).

getCard([], _) -> {};
getCard([{Deposit, Pin, Date, Sum, Currency} | _], Deposit) -> {Deposit, Pin, Date, Sum, Currency};
getCard([_ | T], Deposit) -> getCard(T, Deposit).

putMoneyToDeposit([], _, _) -> [];
putMoneyToDeposit([{Deposit, Pin, Date, OldSum, Currency} | T], Deposit, Sum) ->
  [{Deposit, Pin, Date, OldSum + Sum, Currency} | T];
putMoneyToDeposit([H | T], Deposit, Sum) ->
  [H | putMoneyToDeposit(T, Deposit, Sum)].

getMoneyFromDeposit([], _, _) -> [];
getMoneyFromDeposit([{Deposit, Pin, Date, OldSum, Currency} | T], Deposit, Sum) ->
  [{Deposit, Pin, Date, OldSum + Sum, Currency} | T];
getMoneyFromDeposit([H | T], Deposit, Sum) ->
  [H | getMoneyFromDeposit(T, Deposit, Sum)].

createCards(_, 0) -> [];
createCards(ClientId, CardsCount) ->
  Deposit = generateDeposit(ClientId, CardsCount),
  Pin = generatePin(ClientId, CardsCount),
  Date = generateDate(ClientId, CardsCount),
  Sum = generateSum(),
  Currency = generateCurrency(),
  [{Deposit, Pin, Date, Sum, Currency} | createCards(ClientId, CardsCount - 1)].

generateDeposit(X, Y) -> 10 * X + Y.

generatePin(X, Y) -> 2 * X + Y.

generateDate(X, Y) -> 5 * X + Y.

generateSum() -> rand:uniform(1000).

generateCurrency() ->
  Rand = rand:uniform(3),
  if
    Rand == 1 -> usd;
    Rand == 2 -> eur;
    true -> rub
  end.