unit UCardGameClasses;

{$IFDEF FPC}
{$MODE Delphi}
{$ENDIF}

interface

uses sysutils, math, Classes;

type
  TCard = class
  private
    Rank: 1 .. 14;
    Suit: 0 .. 3;
  public
    constructor Create(r: integer; s: integer); virtual;
    function GetRank: integer;
    function GetSuit: integer;
    function GetRankAsString: string;
    function GetSuitAsString: string;
    function GetName: string;
  end;

  TJokerCard = class(TCard)
  public
    constructor CreateJoker;
  end;

  TCanastaCard = class(TCard)
  private
    score: integer;
  public
    constructor Create(r: integer; s: integer); override;
    function GetScore: integer;
  end;

  TCards = array [0 .. 107] of TCard;

  TPack = class
  protected
    FCards: TCards;
    Ffront, Frear, FSize: integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Shuffle;
    function DealCard: TCard; virtual;
    procedure AddCard(card: TCard);
    function IsEmpty: boolean;
    function IsFull: boolean;
    property Top: integer read Ffront write Ffront;
    property Bottom: integer read Frear write Frear;
    property Size: integer read FSize write FSize;

  end;

  TDoublePack = class(TPack)
  public
    constructor Create; override;
    function DealCard: TCard; override;
  end;

  THand = class
  protected
    FCards: TList;
    function GetSize: integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AddCard(card: TCard);
    function RemoveCard(index: integer): TCard;
    function RemoveFirstCard: TCard;
    function FindCard(Rank, Suit: integer): integer;
    function ContainsCard(Rank: integer; Suit: integer): boolean;
    function First: TCard;
    function Last: TCard;
    function IsEmpty: boolean;
    function PrintCard(int: integer): TCard;
    procedure PrintHand;
    property Size: integer read GetSize;
  end;

  TScoringHand = class abstract(THand)
  public
    function GetScore: integer; virtual; abstract;

  end;

  TBlackJackHand = class(TScoringHand)
  public
    function GetScore: integer; override;
  end;

  MCards = array [1..14] of integer;
  CScores = array [1..14] of integer;

  TMelds = class
  private
  MeldCards:MCards;
  CardScores:CScores;
  public
    constructor Create;
    function GetScore: integer;
  end;

  TCanastaHand = class(TScoringHand)
  private
    Melds,TableMelds: TMelds;
    TableCards: TList;
    HandScore, TableScore: integer;
  public
    constructor Create; override;
    function GetScore: integer; override;
    procedure AddCardToTable(List: TList; card: TCard);
    function RemoveCardFromHand(List: TList; index: integer): TCard;
    procedure RemoveRankCards(rank:integer);
    function RedThree:integer;
    procedure SortIntoMelds;
    procedure AddToMelds(card:TCard);
    procedure PrintMelds;
    procedure MoveMeldsToTable;
    function DiscardCard:TCard;
    function CheckCanasta:boolean;
  end;


implementation

{ TCard }

constructor TCard.Create(r: integer; s: integer);
begin
  Rank := r;
  Suit := s;
end;

function TCard.GetName: string;
begin
  if Rank = 14 then
    result := GetRankAsString
  else
    result := GetRankAsString + ' of ' + GetSuitAsString;
end;

function TCard.GetRank: integer;
begin
  result := Rank;
end;

function TCard.GetRankAsString: string;
begin
  case Rank of
    1:
      result := 'Ace';
    2:
      result := 'Two';
    3:
      result := 'Three';
    4:
      result := 'Four';
    5:
      result := 'Five';
    6:
      result := 'Six';
    7:
      result := 'Seven';
    8:
      result := 'Eight';
    9:
      result := 'Nine';
    10:
      result := 'Ten';
    11:
      result := 'Jack';
    12:
      result := 'Queen';
    13:
      result := 'King';
    14:
      result := 'Joker';
  end;
end;

function TCard.GetSuit: integer;
begin
  result := Suit;
end;

function TCard.GetSuitAsString: string;
begin
  case Suit of
    0:
      result := 'Clubs';
    1:
      result := 'Diamonds';
    2:
      result := 'Hearts';
    3:
      result := 'Spades';
  end;
end;

{ TPack }

procedure TPack.AddCard(card: TCard);
begin
  if not IsFull then
  begin
    if (Bottom = 51) then
      Bottom := 0
    else
      Bottom := Bottom + 1;
    FCards[Bottom] := card;
    Size := Size + 1;

  end;
end;

constructor TPack.Create;
var
  I: integer;
begin
  inherited Create;
  for I := 0 to 51 do
    FCards[I] := TCard.Create((I mod 13) + 1, I div 13);
  FCards[52] := TJokerCard.CreateJoker;
  FCards[53] := TJokerCard.CreateJoker;
  Top := 0;
  Bottom := 51;
  Size := 52;
  randomize;

end;

destructor TPack.Destroy;
var
  I: integer;
begin
  for I := 0 to 51 do
    FCards[I].Free;
  inherited Destroy;
end;

function TPack.IsEmpty: boolean;
begin
  result := Size = 0;
end;

function TPack.IsFull: boolean;
begin
  result := Size = 52;
end;

procedure TPack.Shuffle;
var
  I, r: integer;
  temp: TCard;
begin
  for I := Top to Bottom do
  begin
    r := randomrange(I - 1, Bottom + 1);
    temp := FCards[I];
    FCards[I] := FCards[r];
    FCards[r] := temp;
  end;

end;

function TPack.DealCard: TCard;
begin
  if not IsEmpty then
  begin
    result := FCards[Top];
    if Top = 51 then
      Top := 0
    else
      Top := Top + 1;
    Size := Size - 1;
  end;
end;

{ THand }

procedure THand.AddCard(card: TCard);
begin
  FCards.Add(card);
end;

function THand.ContainsCard(Rank: integer; Suit: integer): boolean;
var
  I: integer;
begin
  result := false;
  for I := 0 to (self.GetSize - 1) do
    if (TCard(FCards[I]).GetRank = Rank) and (TCard(FCards[I]).GetSuit = Suit)
    then
      result := true;
  // writeln(result);
end;

constructor THand.Create;
begin
  inherited;
  FCards := TList.Create;
end;

destructor THand.Destroy;
begin
  FCards.Free;
  inherited;
end;

function THand.FindCard(Rank, Suit: integer): integer;
var
  I: integer;

begin
  for I := 0 to (self.GetSize - 1) do
    if (TCard(FCards[I]).GetRank = Rank) and (TCard(FCards[I]).GetSuit = Suit)
    then
      result := FCards.IndexOf(FCards[I]);
end;

function THand.First: TCard;
begin
  result := FCards[0];
end;

function THand.GetSize: integer;
begin
  result := FCards.Count;
end;

function THand.IsEmpty: boolean;
begin
  result := Size = 0;
end;

function THand.Last: TCard;
begin
  result := FCards[FCards.Count - 1];
end;

function THand.PrintCard(int: integer): TCard;
begin
  result := FCards[int];
end;

procedure THand.PrintHand;
var
  n: integer;
begin
  for n := 0 to (self.GetSize - 1) do
    writeln((self.PrintCard(n)).GetName);
end;

function THand.RemoveCard(index: integer): TCard;
var
  I: integer;
begin
  result := FCards.Extract(FCards[index]);
end;

function THand.RemoveFirstCard: TCard;
begin
  result := FCards.First;
  FCards.Delete(0);
end;

{ TBlackJackHand }

function TBlackJackHand.GetScore: integer;
var
  I, score: integer;
  current: TCard;

begin
  score := 0;
  for I := 0 to (Size - 1) do
  begin
    current := FCards[I];
    case current.GetRank of
      1:
        score := score + 11;
      2:
        score := score + 2;
      3:
        score := score + 3;
      4:
        score := score + 4;
      5:
        score := score + 5;
      6:
        score := score + 6;
      7:
        score := score + 7;
      8:
        score := score + 8;
      9:
        score := score + 9;
      10:
        score := score + 10;
      11:
        score := score + 10;
      12:
        score := score + 10;
      13:
        score := score + 10;
    end;
    if current.GetRank = 1 then
    begin
      if score > 21 then
        score := score - 10;
    end;
  end;
  result := score;
end;
{ TCanstaHand }

procedure TCanastaHand.AddCardToTable(List: TList; card: TCard);
begin
  List.Add(card);
end;

procedure TCanastaHand.AddToMelds(card: TCard);
var
rank:integer;
begin
rank:=card.GetRank;
if TableMelds.MeldCards[rank]>0 then
  TableMelds.MeldCards[rank]:= TableMelds.MeldCards[rank] + 1
else
  Melds.MeldCards[rank]:=Melds.MeldCards[rank] + 1;
end;

function TCanastaHand.CheckCanasta: boolean;
var
I:integer;
begin
result:= false;
for I := 1 to 14 do
  begin
    if TableMelds.MeldCards[I] > 6 then
      result:=true;
  end;


end;

constructor TCanastaHand.Create;
begin
  inherited;
  FCards := TList.Create;
  HandScore := 0;
  TableCards := TList.Create;
  TableScore := 0;
  Melds:=TMelds.Create;
  TableMelds:=TMelds.Create;
end;

function TCanastaHand.DiscardCard:TCard;
var
  I,rank: Integer;
begin
for I := 0 to (FCards.Count-1) do
  begin
    rank := (TCard(FCards[I]).GetRank);
    if Melds.MeldCards[rank] = 1 then
      begin
      result:= FCards.Extract(FCards[I]);
      Melds.MeldCards[rank]:=0;
      writeln('you are removing: ', TCard(FCards[I]).GetName);
      readln;
      exit
      end;
  end;
end;

function TCanastaHand.RemoveCardFromHand(List: TList; index: integer): TCard;
begin
  result := List.Extract(List[index]);
end;

procedure TCanastaHand.RemoveRankCards(rank:integer);
var
  I: Integer;
begin
for I := 0 to (FCards.count-1) do
  begin
    if TCard(FCards[I]).GetRank = rank then
    begin
      writeln('Removing card rank: ', rank);
      writeln('At position: ', I);
      readln;
      FCards.Remove(FCards[I]);
      exit
    end;
  end;
end;

procedure TCanastaHand.SortIntoMelds;
var
  i,rank: Integer;
begin
for i := 0 to (FCards.count-1) do
  begin
  rank := (TCard(FCards[i]).GetRank);
  Melds.MeldCards[rank] := Melds.MeldCards[rank]+1;
  end;
end;

function TCanastaHand.RedThree:integer;
var
  card,count: integer;
begin
  count:=0;
  while self.ContainsCard(3, 1) or self.ContainsCard(3, 2) do
  begin
    if self.ContainsCard(3, 1) then
    begin
      card := 1;
    end
    else if self.ContainsCard(3, 2) then
    begin
      card := 2;
    end
    else
      exit;
    self.AddCardToTable(TableCards, self.RemoveCardFromHand(FCards,self.FindCard(3, card)));
    count:=count + 1;
  end;
  result:=count;
end;

function TCanastaHand.GetScore: integer;
begin

end;

procedure TCanastaHand.MoveMeldsToTable;
var
  i,n: Integer;
begin
for i := 1 to 14 do
  begin
    if Melds.MeldCards[i] > 2 then
      begin
        TableMelds.MeldCards[i] := Melds.MeldCards[i];
        for n := 0 to (Melds.MeldCards[i]-1) do
          self.RemoveRankCards(i);
        Melds.MeldCards[i] := 0;

      end;
  end;
end;

procedure TCanastaHand.PrintMelds;
var
i:integer;
begin
writeln('You have the following melds: ');
for i := 1 to 14 do
  begin
    writeln('Rank: ', i,' Count: ', Melds.MeldCards[i]);
  end;



end;

{ TJokerCard }

constructor TJokerCard.CreateJoker;
begin
  Rank := 14;
end;

{ procedure TJokerCard.GetScore;
  begin
  result:=score;
  end;
}
{ TDoublePack }

constructor TDoublePack.Create;
var
  I, n: integer;
begin
  inherited;
  for I := 0 to 103 do
    FCards[I] := TCanastaCard.Create((I mod 13) + 1, I div 26);
  for n := 0 to 3 do
    FCards[104 + n] := TJokerCard.CreateJoker;
  Top := 0;
  Bottom := 107;
  Size := 108;
  randomize;

end;

function TDoublePack.DealCard: TCard;
begin
  if not IsEmpty then
  begin
    result := FCards[Top];
    if Top = 107 then
      Top := 0
    else
      Top := Top + 1;
    Size := Size - 1;
  end;
end;

{ TCanastaCard }

function TCanastaCard.GetScore: integer;
begin
  result := score;
end;

constructor TCanastaCard.Create(r: integer; s: integer);
begin
  inherited;
  Rank := r;
  Suit := s;
  case Rank of
    1 .. 2:
      score := 20;
    4 .. 7:
      score := 5;
    8 .. 13:
      score := 10;
    14:
      score := 50;
  end;
end;

{ TMeld }


constructor TMelds.Create;
var
  i: Integer;
begin
  for i := 1 to 14 do
    MeldCards[i]:=0;
  CardScores[1]:=20;
  CardScores[2]:=20;
  CardScores[4]:=5;
  CardScores[5]:=5;
  CardScores[6]:=5;
  CardScores[7]:=5;
  CardScores[8]:=10;
  CardScores[9]:=10;
  CardScores[10]:=10;
  CardScores[11]:=10;
  CardScores[12]:=10;
  CardScores[13]:=10;
  CardScores[14]:=50;
end;

function TMelds.GetScore: integer;
var
i,score:integer;
begin
score:=0;
for i := 1 to 14 do
  score:=score + (MeldCards[i]*CardScores[i]);
result:=score;
end;

end.
