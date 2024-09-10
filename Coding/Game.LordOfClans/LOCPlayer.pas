UNIT LOCPlayer;
{$Include GlobalDefines.Inc}
INTERFACE

USES LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCMenu,
     LOCDraw,
     LOCUnitProcess;

TYPE
  TLOCPlayer = Class
    Public
    MyScreen      : TLOCScreen;
    MyShow        : TLOCShow;
    MyUnits       : TLOCUnits;
    MyWorld       : TLOCWorld;
    MyMenu        : TLOCMenu;
    MyDraw        : TLOCDraw;
    MyUnitProcess : TLOCUnitProcess;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                       Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess);
    Destructor Destroy;OverRide;
    Procedure PlayerSay(Clan : TClan;Msg : String);
  End;

VAR
  GamePlayer : TLOCPlayer;

IMPLEMENTATION

CONSTRUCTOR TLOCPlayer.Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                              Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    MyMenu:=Menu;
    MyDraw:=Draw;
    MyUnitProcess:=UnitProcess;
  End;

DESTRUCTOR TLOCPlayer.Destroy;
  Begin
  End;

PROCEDURE TLOCPlayer.PlayerSay(Clan : TClan;Msg : String);
  Begin
    If Length(Msg)=0 then Exit;
    With MyScreen,MyUnits do
      SendMessage(ClanInfo[Clan].ClanName+SeperatorSymbol+Msg);
  End;
END.