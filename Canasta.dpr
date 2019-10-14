program Canasta;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, UCardGameClasses;

var
  IsCanasta:Boolean;
  pack: TDoublePack;
  player1, player2, table1, table2: TCanastaHand;
  discard: THand;



procedure Initialise;
var
  i, n: integer;
begin
  IsCanasta := false;
  pack := TDoublePack.Create;
  player1 := TCanastaHand.Create;
  player2 := TCanastaHand.Create;
  table1 := TCanastaHand.Create;
  table2 := TCanastaHand.Create;
  discard := THand.Create;
  pack.Shuffle;
  writeln('This is a two player varient of Canasta');
  readln;
  for i := 0 to 14 do
  begin
    player1.AddCard(pack.DealCard);
    player2.AddCard(pack.DealCard);
  end;
  writeln('Player 1 Starting Hand:');
  for n := 0 to 14 do
    writeln((player1.PrintCard(n)).GetName);
  readln;
  writeln('Player 2 Starting Hand:');
  for n := 0 to 14 do
    writeln((player2.PrintCard(n)).GetName);
  player1.SortIntoMelds;
  player2.SortIntoMelds;
end;

procedure Turn(player:TCanastaHand);
var
rank,I,n:integer;
begin
I := player.RedThree;
  for n := 0 to (I-1) do
    player.AddCard(pack.DealCard);
writeln('Any red threes have been played and replaced');
player.AddCard(pack.DealCard);
writeln('Just picked: ', player1.Last.GetName);
player.AddToMelds(player.last);
player.PrintMelds;
readln;
player.MoveMeldsToTable;
player.PrintMelds;
player.PrintHand;
discard.AddCard(player.DiscardCard);
end;


begin
  Initialise;
  readln;
  writeln('It is now player 1''s turn');
  player1.PrintHand; //remove after debugging
  while IsCanasta = false do
  begin
    Turn(Player1);
    if player1.CheckCanasta then
      IsCanasta := true;
    Turn(Player2);
    if player2.CheckCanasta then
      IsCanasta := true;
  end;
writeln('The Game has ended');
readln;
                  //SCORING
end.
