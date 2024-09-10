UNIT LOCNetwork;
{$Include GlobalDefines.Inc}
INTERFACE

USES LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCMenu,
     LOCDraw,
     LOCUnitProcess,
     LOCPlayer,
     LOCAIPlayer,
     LOCScript;

TYPE
  TLOCNetwork = Class
    Public
    MyScreen      : TLOCScreen;
    MyShow        : TLOCShow;
    MyUnits       : TLOCUnits;
    MyWorld       : TLOCWorld;
    MyMenu        : TLOCMenu;
    MyDraw        : TLOCDraw;
    MyUnitProcess : TLOCUnitProcess;
    MyPlayer      : TLOCPlayer;
    MyAIPlayer    : TLOCAIPlayer;
    MyScript      : TLOCScript;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                       Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess;
                       Player : TLOCPlayer;AIPlayer : TLOCAIPlayer;Script : TLOCScript);
    Destructor Destroy;OverRide;
    Procedure GetNetworkPackage;
    Procedure ImReady;
    Procedure ProcessNetwork;
  End;

VAR
  GameNetwork : TLOCNetwork;

IMPLEMENTATION

CONSTRUCTOR TLOCNetwork.Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                               Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess;
                               Player : TLOCPlayer;AIPlayer : TLOCAIPlayer;Script : TLOCScript);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    MyMenu:=Menu;
    MyDraw:=Draw;
    MyUnitProcess:=UnitProcess;
    MyPlayer:=Player;
    MyAIPlayer:=AIPlayer;
    MyScript:=Script;
  End;

DESTRUCTOR TLOCNetwork.Destroy;
  Begin
  End;

PROCEDURE TLOCNetwork.GetNetworkPackage;
  Begin
  End;

PROCEDURE TLOCNetwork.ImReady;
  Begin
    MyScreen.ReadyForNextFrame:=False;
  End;

PROCEDURE TLOCNetwork.ProcessNetwork;
  Begin
    GetNetworkPackage;
    MyScreen.ReadyForNextFrame:=True;
  End;
END.