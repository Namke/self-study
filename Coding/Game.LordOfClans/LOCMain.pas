UNIT LOCMain;
{$Include GlobalDefines.Inc}
INTERFACE

PROCEDURE LOCRun;

IMPLEMENTATION

USES LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCEditor,
     LOCMenu,
     LOCDraw,
     LOCUnitProcess,
     LOCPlayer,
     LOCAIPlayer,
     LOCScript,
     LOCNetwork,
     LOCPlay;

PROCEDURE LOCGameStart;
  Begin
    GameScreen     :=TLOCScreen     .Create;
    GameShow       :=TLOCShow       .Create(GameScreen);
    GameUnits      :=TLOCUnits      .Create(GameScreen,GameShow);
    GameWorld      :=TLOCWorld      .Create(GameScreen,GameShow,GameUnits);
    GameEditor     :=TLOCEditor     .Create(GameScreen,GameShow,GameUnits,GameWorld);
    GameMenu       :=TLOCMenu       .Create(GameScreen,GameShow,GameUnits,GameWorld);
    GameDraw       :=TLOCDraw       .Create(GameScreen,GameShow,GameUnits,GameWorld,GameEditor,GameMenu);
    GameUnitProcess:=TLOCUnitProcess.Create(GameScreen,GameShow,GameUnits,GameWorld,GameMenu,GameDraw);
    GamePlayer     :=TLOCPlayer     .Create(GameScreen,GameShow,GameUnits,GameWorld,GameMenu,GameDraw,GameUnitProcess);
    GameAI         :=TLOCAIPlayer   .Create(GameScreen,GameShow,GameUnits,GameWorld,GameMenu,GameDraw,GameUnitProcess,GamePlayer);
    GameScript     :=TLOCScript     .Create(GameScreen,GameShow,GameUnits,GameWorld,GameMenu,GameDraw,GameUnitProcess,GamePlayer,GameAI);
    GameNetwork    :=TLOCNetwork    .Create(GameScreen,GameShow,GameUnits,GameWorld,GameMenu,GameDraw,GameUnitProcess,GamePlayer,GameAI,GameScript);
    GamePlay       :=TLOCPlay       .Create(GameScreen,GameShow,GameUnits,GameWorld,GameMenu,GameDraw,GameUnitProcess,GamePlayer,GameAI,GameScript,GameNetwork,GameEditor);
  End;

PROCEDURE LOCGamePlay;
  Begin
    GamePlay.InfinieLoop;
  End;

PROCEDURE LOCGameEnd;                     
  Begin
    GamePlay.Destroy;
    GameNetwork.Destroy;
    GameScript.Destroy;
    GameAI.Destroy;
    GamePlayer.Destroy;
    GameUnitProcess.Destroy;
    GameDraw.Destroy;
    GameMenu.Destroy;
    GameWorld.Destroy;
    GameUnits.Destroy;
    GameShow.Destroy;
    GameScreen.Destroy;
  End;

PROCEDURE LOCRun;
  Begin
    LOCGameStart;
    LOCGamePlay;
    LOCGameEnd;
  End;
END.