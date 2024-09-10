UNIT LOCMenu;
{$Include GlobalDefines.Inc}
INTERFACE

USES DirectXGraphics,
     AvenusBase,
     AvenusCommon,
     Avenus3D,
     LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCWindow;

TYPE
  TLOCMenu = Class
    Public
    MyScreen   : TLOCScreen;
    MyShow     : TLOCShow;
    MyUnits    : TLOCUnits;
    MyWorld    : TLOCWorld;
    MenuActive : Boolean;
    MainWindow : TWindow;
    BackGround : TAvenusTextureImages;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld);
    Destructor Destroy;OverRide;
    Procedure MainMenuUpdate(Check : Boolean;ShowBackGround : Boolean;Flip : Boolean);
    Function  MainMenuSelection(ShowBackGround : Boolean) : TMenuSelectResult;
    Function  MainMenuProcess(CheckState : Boolean;ShowBackGround : Boolean) : TMenuSelectResult;
    Procedure SetupForMainMenu;
    Procedure SetupForOnGameMenu;
    Procedure SetupForQuitGameMenu;
    Procedure SetupForVictoryGameMenu;
    Procedure SetupForSaveGameMenu;
    Procedure SetupForLoadGameMenu;
    Procedure MessageBox(Caption : String);
    Procedure MenuShow;
    Procedure MenuInput;
  End;

VAR
  GameMenu : TLOCMenu;

IMPLEMENTATION

CONSTRUCTOR TLOCMenu.Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    MenuActive:=False;
  End;

DESTRUCTOR TLOCMenu.Destroy;
  Begin
  End;

PROCEDURE TLOCMenu.MainMenuUpdate(Check : Boolean;ShowBackGround : Boolean;Flip : Boolean);
  Begin
    With MyScreen do
      Begin
        If Check then
          If MainWindow.Change then MainWindow.Change:=False
          Else Exit;
        //Screen.Clear(0);
        Screen.BeginScene;
        If ShowBackGround then
          Screen.RenderEffect(BackGround,0,0,0,EffectNone);
        MainWindow.Render;
        Screen.EndScene;
        If Flip then Screen.Present;
      End;
  End;

FUNCTION  TLOCMenu.MainMenuProcess(CheckState : Boolean;ShowBackGround : Boolean) : TMenuSelectResult;
  Var Return : TMenuSelectResult;
  Begin
    Return:=MenuNone;
    With MyScreen do
      Begin
        If CheckState then
          Begin
            Input.GetState;
            If Screen.DoEvents=False then Return:=MenuQuitGame;
          End;
        MainWindow.Mouse.PosX:=Input.MouseX;
        MainWindow.Mouse.PosY:=Input.MouseY;
        If Input.MouseReleasedL then
          Begin
            MainWindow.Mouse.Button:=0;
            If MainWindow.OnLeftMouseUp then
              Begin
                Return:=MainWindow.ButtonReturn;
              End;
          End;
        If Input.MouseFirstClickL then
          Begin
            MainWindow.Mouse.Button:=1;
            MainWindow.OnLeftMouseDown;
          End;
        If Input.MouseHoldL then
          Begin
            MainWindow.OnLeftMouseDrag;
          End;
      End;
    Result:=Return;
  End;

FUNCTION  TLOCMenu.MainMenuSelection(ShowBackGround : Boolean) : TMenuSelectResult;
  Var Return : TMenuSelectResult;
  Begin
    With MyScreen do
      Repeat
        Return:=MainMenuProcess(True,ShowBackGround);
        MainMenuUpdate(True,ShowBackGround,True);
      Until Return<>MenuNone;
    Result:=Return;
  End;

PROCEDURE TLOCMenu.SetupForMainMenu;
  Begin
    With MyScreen do
      Begin
        If Assigned(BackGround) then
          Begin
            BackGround.Free;
            BackGround:=Nil;
          End;
        If Assigned(MainWindow) then
          Begin
            MainWindow.Free;
            MainWindow:=Nil;
          End;
        BackGround:=TAvenusTextureImages.Create;
        {$IfDef LoadOnDataBase}
        BackGround.LoadFromPackFile(GraphicDataFile,Screen.D3DDevice8,
                                    GameDataDir+ImagesDir+'ScreenStart.jpg',0,0,D3DFMT_R5G6B5);
        {$Else}
        BackGround.LoadFromFile(Screen.D3DDevice8,
                                GameDataDir+ImagesDir+'ScreenStart.jpg',0,0,D3DFMT_R5G6B5);
        {$EndIf}
        MainWindow:=TWindow.Create(MyScreen,
                                   (ScreenWidth-MainMenuSizeX) div 2,
                                   (ScreenHeight-MainMenuSizeY) div 2,
                                   MainMenuSizeX,
                                   MainMenuSizeY,
                                   GameCaption);
        MainWindow.AddButton((MainMenuSizeX-MainMenuButtonSizeX) div 2,
                             (MainMenuButtonSizeY+10)*2,
                             MainMenuButtonSizeX,
                             MainMenuButtonSizeY,
                             SinglePlayStr,
                             MenuPlaySingle);
        MainWindow.AddButton((MainMenuSizeX-MainMenuButtonSizeX) div 2,
                             (MainMenuButtonSizeY+10)*3,
                             MainMenuButtonSizeX,
                             MainMenuButtonSizeY,
                             MultiPlayStr,
                             MenuPlayMulti);
        MainWindow.AddButton((MainMenuSizeX-MainMenuButtonSizeX) div 2,
                             (MainMenuButtonSizeY+10)*4,
                             MainMenuButtonSizeX,
                             MainMenuButtonSizeY,
                             OptionsStr,
                             MenuGameOption);
        MainWindow.AddButton((MainMenuSizeX-MainMenuButtonSizeX) div 2,
                             (MainMenuButtonSizeY+10)*5,
                             MainMenuButtonSizeX,
                             MainMenuButtonSizeY,
                             EditorStr,
                             MenuGameEditor);
        MainWindow.AddButton((MainMenuSizeX-MainMenuButtonSizeX) div 2,
                             (MainMenuButtonSizeY+10)*6,
                             MainMenuButtonSizeX,
                             MainMenuButtonSizeY,
                             CreditStr,
                             MenuGameInfo);
        MainWindow.AddButton((MainMenuSizeX-MainMenuButtonSizeX) div 2,
                             (MainMenuButtonSizeY+10)*7,
                             MainMenuButtonSizeX,
                             MainMenuButtonSizeY,
                             QuitStr,
                             MenuQuitGame);
      End;
  End;

PROCEDURE TLOCMenu.SetupForOnGameMenu;
  Begin
    With MyScreen do
      Begin
        If Assigned(BackGround) then
          Begin
            BackGround.Free;
            BackGround:=Nil;
          End;
        If Assigned(MainWindow) then
          Begin
            MainWindow.Free;
            MainWindow:=Nil;
          End;
        MainWindow:=TWindow.Create(MyScreen,
                                   (ScreenWidth-GameMenuSizeX) div 2,
                                   (ScreenHeight-GameMenuSizeY) div 2,
                                   GameMenuSizeX,
                                   GameMenuSizeY,
                                   GameCaption);
        MainWindow.AddButton((GameMenuSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*2,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             ReturnToGameStr,
                             MenuOGReturnToGame);
        MainWindow.AddButton((GameMenuSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*3,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             PauseGameStr,
                             MenuOGPauseGame);
        MainWindow.AddButton((GameMenuSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*4,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             LoadGameStr,
                             MenuOGLoadGame);
        MainWindow.AddButton((GameMenuSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*5,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             SaveGameStr,
                             MenuOGSaveGame);
        MainWindow.AddButton((GameMenuSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*6,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             OptionsStr,MenuOGGameOption);
        MainWindow.AddButton((GameMenuSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*7,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             QuitStr,MenuOGQuitGame);
      End;
  End;

PROCEDURE TLOCMenu.SetupForQuitGameMenu;
  Begin
    With MyScreen do
      Begin
        If Assigned(BackGround) then
          Begin
            BackGround.Free;
            BackGround:=Nil;
          End;
        If Assigned(MainWindow) then
          Begin
            MainWindow.Free;
            MainWindow:=Nil;
          End;
        MainWindow:=TWindow.Create(MyScreen,
                                   (ScreenWidth-GameMenuQuitSizeX) div 2,
                                   (ScreenHeight-GameMenuQuitSizeY) div 2,
                                   GameMenuQuitSizeX,
                                   GameMenuQuitSizeY,
                                   GameCaption);
        MainWindow.AddText(GameMenuQuitSizeX div 2,
                           GameMenuButtonSizeY+10,
                           DoYouWantToQuitStr);
        MainWindow.AddButton((GameMenuQuitSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*2-10,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             QuitToMenuStr,
                             MenuOGQuitGameToMainMenu);
        MainWindow.AddButton((GameMenuQuitSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*3-10,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             QuitToOSStr,
                             MenuOGQuitGameToOS);
        MainWindow.AddButton((GameMenuQuitSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*4-10,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             CancelStr,
                             MenuOGQuitGameCancel);
      End;
  End;

PROCEDURE TLOCMenu.SetupForVictoryGameMenu;
  Begin
    With MyScreen do
      Begin
        If Assigned(BackGround) then
          Begin
            BackGround.Free;
            BackGround:=Nil;
          End;
        If Assigned(MainWindow) then
          Begin
            MainWindow.Free;
            MainWindow:=Nil;
          End;
        MainWindow:=TWindow.Create(MyScreen,
                                   (ScreenWidth-GameMessageSizeX) div 2,
                                   (ScreenHeight-GameMessageSizeY) div 2,
                                   GameMessageSizeX,
                                   GameMessageSizeY,
                                   VictoryStr);
        MainWindow.AddButton((GameMessageSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*1,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             QuitStr,
                             MenuOGQuitGameToMainMenu);
        MainWindow.AddButton((GameMessageSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*2,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             ContinueGameStr,
                             MenuOGReturnToGame);
      End;
  End;

PROCEDURE TLOCMenu.SetupForSaveGameMenu;
  Begin
    With MyScreen do
      Begin
        If Assigned(BackGround) then
          Begin
            BackGround.Free;
            BackGround:=Nil;
          End;
        If Assigned(MainWindow) then
          Begin
            MainWindow.Free;
            MainWindow:=Nil;
          End;
        MainWindow:=TWindow.Create(MyScreen,
                                   (ScreenWidth-GameSaveLoadSizeX) div 2,
                                   (ScreenHeight-GameSaveLoadSizeY) div 2,
                                   GameSaveLoadSizeX,
                                   GameSaveLoadSizeY,
                                   SaveStr);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*1,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot1Str,
                             MenuOGSaveSlot1);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*2,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot2Str,
                             MenuOGSaveSlot2);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*3,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot3Str,
                             MenuOGSaveSlot3);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*4,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot4Str,
                             MenuOGSaveSlot4);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*5,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot5Str,
                             MenuOGSaveSlot5);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*6,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot6Str,
                             MenuOGSaveSlot6);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*7,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot7Str,
                             MenuOGSaveSlot7);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*8,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot8Str,
                             MenuOGSaveSlot8);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*9,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             CancelStr,
                             MenuOGReturnToGame);
      End;
  End;

PROCEDURE TLOCMenu.SetupForLoadGameMenu;
  Begin
    With MyScreen do
      Begin
        If Assigned(BackGround) then
          Begin
            BackGround.Free;
            BackGround:=Nil;
          End;
        If Assigned(MainWindow) then
          Begin
            MainWindow.Free;
            MainWindow:=Nil;
          End;
        MainWindow:=TWindow.Create(MyScreen,
                                   (ScreenWidth-GameSaveLoadSizeX) div 2,
                                   (ScreenHeight-GameSaveLoadSizeY) div 2,
                                   GameSaveLoadSizeX,
                                   GameSaveLoadSizeY,
                                   LoadStr);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*1,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot1Str,
                             MenuOGLoadSlot1);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*2,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot2Str,
                             MenuOGLoadSlot2);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*3,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot3Str,
                             MenuOGLoadSlot3);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*4,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot4Str,
                             MenuOGLoadSlot4);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*5,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot5Str,
                             MenuOGLoadSlot5);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*6,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot6Str,
                             MenuOGLoadSlot6);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*7,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot7Str,
                             MenuOGLoadSlot7);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*8,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             Slot8Str,
                             MenuOGLoadSlot8);
        MainWindow.AddButton((GameSaveLoadSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*9,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             CancelStr,
                             MenuOGReturnToGame);
      End;
  End;

PROCEDURE TLOCMenu.MessageBox(Caption : String);
  Begin
    With MyScreen do
      Begin
        If Assigned(BackGround) then
          Begin
            BackGround.Free;
            BackGround:=Nil;
          End;
        If Assigned(MainWindow) then
          Begin
            MainWindow.Free;
            MainWindow:=Nil;
          End;
        MainWindow:=TWindow.Create(MyScreen,
                                   (ScreenWidth-GameMessageSizeX) div 2,
                                   (ScreenHeight-GameMessageSizeY) div 2,
                                   GameMessageSizeX,
                                   GameMessageSizeY,
                                   Caption);
        MainWindow.AddButton((GameMessageSizeX-GameMenuButtonSizeX) div 2,
                             (GameMenuButtonSizeY+10)*1,
                             GameMenuButtonSizeX,
                             GameMenuButtonSizeY,
                             OkStr,
                             MenuOGReturnToGame);
      End;
  End;

PROCEDURE TLOCMenu.MenuShow;
  Begin
    With MyScreen do
      Begin
      End;
  End;

PROCEDURE TLOCMenu.MenuInput;
  Begin
    With MyScreen do
      Begin
        If Input.KeyPress(Key_Escape) then MenuActive:=False;
        If Input.KeyDown(Key_LAlt) and Input.KeyPress(Key_M) then MenuActive:=False;
      End;
  End;
END.
