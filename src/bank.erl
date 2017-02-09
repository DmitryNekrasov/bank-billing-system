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
-export([]).

bankClient(ClientId, Cards) ->
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