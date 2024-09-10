UNIT LOCScreen;
{$Include GlobalDefines.Inc}
INTERFACE

USES Windows,
     MMSystem,
     Classes,
     SysUtils,
     HTTPApp,
     DirectXGraphics,
     DirectInput8,
     AvenusBase,
     AvenusCommon,
     AvenusMedia,
     Avenus3D,
     {$IfDef LoadOnDataBase}
     KPF,
     {$EndIf}
     LOCBased;

CONST
  CMenuButtonStart   = 1;
  CUnitSelectedStart = CMenuButtonStart+1+Byte(High(TButtonMenuTyper));
  CUnitCommandStart  = CUnitSelectedStart+1+Byte(High(TUnitSelectionCount));
  CUnitItemStart     = CUnitCommandStart+1+Byte(High(TSkillCount));
  CUnitQueueStart    = CUnitItemStart+1+Byte(High(TItemCount));
  CButtonEnd         = CUnitQueueStart+1+Byte(High(TQueueCount))+1;

TYPE
  TGameButtonCount = CMenuButtonStart..CButtonEnd;
  TGameButton = Record
    Used,Active,Pressed,
    CanPressWhenCmdInput,
    AllowRightClick    : Boolean;
    PosX1,PosY1,PosX2,PosY2 : Integer;
    Caption                 : NameString;
    HoldKey,HotKey          : Byte;
    Case Typer : TGameButtonTyper of
      ButtonMenu : (
        MenuTyper : TButtonMenuTyper;
      );
      ButtonUnitSelected,ButtonUnitQueue : (
        UnitNumRef : FastInt;
      );
      ButtonUnitCommand : (
        UnitSkill : TUnitSkill;
      );
      ButtonUnitItem : (
        UnitItem : TUnitItem;
        ItemSlot : TItemCount;
      );
      ButtonEditorCommand : (
        EditorCommand : TEditorCommand;
      );
      ButtonEditorUnit : (
        UnitSelected : TUnit;
      );
  End;
  TGameButtons = Array[TGameButtonCount] of TGameButton;
  TMouseInRange = (MINoWhere,MIGameButton,MIGameMiniMap);

TYPE
  TInputInterface = Class(TAvenusInput)
    FirstState,LastState : TDIKeyboardState;
    MouseL,MouseR,MouseM : Boolean;
    MouseX,MouseY        : Integer;
    Function  KeyDown(Key : Byte) : Boolean;
    Function  KeyPress(Key : Byte) : Boolean;
    Function  MouseFirstClickL : Boolean;
    Function  MouseFirstClickR : Boolean;
    Function  MouseFirstClickM : Boolean;
    Function  MouseReleasedL : Boolean;
    Function  MouseReleasedR : Boolean;
    Function  MouseReleasedM :  Boolean;
    Function  MouseHoldL : Boolean;
    Function  MouseHoldR : Boolean;
    Procedure GetState;
  End;

TYPE
  TGameInfo = Record
    GameName      : String[40];
    GameVersion   : String[20];
    GameProduct   : String[20];
    GameCopyRight : String[20];
  End;

TYPE
//  Variable of game config like screen pos, game counting, foging...
// Also all the config of game
  TLOCScreen = Class
    GameInfo                                      : TGameInfo;
    Screen                                        : TAvenus3D;
    Input                                         : TInputInterface;
    VideoMode                                     : TVideoMode;
    //Play in full screen ?
    FullScreen                                    : Boolean;
    ScreenWidth,ScreenHeight                      : FastInt;
    //Mouse information
    LeftMouseStatus                               : TMouseStatus;
    //Time & frame information
    GameTimeStart,GameTime,GameFrame,ScreenFrame  : Integer;
    ScreenUpdateSavedTime,
    UnitUpdateSavedTime,
    InputUpdateSavedTime,
    FogUpdateSavedTime,
    MsgBoardUpdateSavedTime,
    ScriptRunSavedTime,
    WaterUpDateSavedTime  : Integer;
    //For shown water animation
    WaterFrame : Integer;
    //Mapview pos on screen, mapview pos on real map
    MapViewPosXOS,MapViewPosYOS,
    //View on screen [ViewPosXOS,ViewPosYOS,ViewPosX2OS,ViewPosY2OS]
    ViewPosXOS,ViewPosYOS,ViewPosX2OS,ViewPosY2OS : FastInt2;
    //Button selection pos and size
    SelectionPosX1,SelectionPosY1,
    SelectionButtonSizeX,SelectionButtonSizeY     : FastInt2;
    NamePosX,NamePosY                             : FastInt2;
    //Queue button pos and size
    QueuePosX,QueuePosY,QueueButtonSizeX,QueueButtonSizeY : FastInt2;
    //Skill button pos and size
    SkillPosX,SkillPosY,SkillButtonSizeX,SkillButtonSizeY : FastInt2;
    //Item button pos and size
    ItemPosX,ItemPosY,ItemButtonSizeX,ItemButtonSizeY : FastInt2;
    //Menu button
    GameButtons                                   : TGameButtons;
    //Resource button pos
    ResourcePosX,ResourcePosY                     : FastInt2;
    //Command line info
    CmdLinePosX,CmdLinePosY,CmdLineSizeX,CmdLineSizeY : FastInt2;
    CommandLine                                   : String;
    CmdLineEnter                                  : Boolean;
    //
    MsgBoardPosX,MsgBoardPosY,LastestMsg          : FastInt2;
    MessageBoard                                  : Array[1..MaxMessage] of String;
    MessageBoardType                              : Array[1..MaxMessage] of TCommonMessage;
    MessageBoardData                              : Array[1..MaxMessage] of Record
      FadeStart,FadeEnd : Integer;
    End;
    GameResult,EndGameResult                      : TGameResult;
    //
    DayTime                                       : TDayTime;
    CurrentMinute,Hour,Minute                     : Integer;
    //Commandline status
    //Command wait for select, send command when left mouse click
    CmdWaitForSelect                              : TSkill;
    SpellWaitForSelect                            : TSpell;
    UnitWaitForBuild                              : TUnit;
    HeadWaitForBuild                              : THeading;
    ItemWaitToPut                                 : TUnitItem;
    ItemSlotSelection                             : TItemCount;
    EndGame,QuitGame,GamePause                    : Boolean;
    AllowUnitAction,AllowPlayerInput              : Boolean;
    ReadyForNextFrame                             : Boolean;
    IsBuildFrame,
    IsManaGrowFrame,
    IsHitpointGrowFrame,
    IsFindTargetFrame,
    IsChangeHeadingFrame,
    IsTimeUpFrame : Boolean;
    //For check button tooltips
    ButtonInRange,OldRange                        : TGameButtonCount;
    MouseInButton,UpDateToolTip                   : Boolean;
    MouseIn                                       : TMouseInRange;
    ToolTip                                       : String;
    {$IfDef ToolTipFade}
    ToolTipFade                                   : Byte;
    {$EndIf}
    //
    White,Green,Red,Yellow,Blue,SeaBlue,DarkGreen : LongInt;
    CheatStatus                                   : Array[TCheatStatus] of Boolean;
    CheatToggle                                   : Array[TCheatStatus] of String;
    {$IfDef Debug}
    DebugStatus                                   : Array[TDebugStatus] of Boolean;
    DebugToggle                                   : Array[TDebugStatus] of String;
    {$EndIf}
    Font                                          : TAvenusNewFont;
    {$IfDef LoadOnDataBase}
    GraphicDataFile : TKPF;
    {$EndIf}
    Constructor Create;
    Destructor Destroy;OverRide;
    Procedure ParserParameters;
    Procedure RestartTime;
    Procedure RestartData;
    Procedure GetDayTime;
    Procedure AdjustViewSize;
    Procedure SetupButtonMenu;
    Procedure SetupButtonPause;
    Procedure SetupButtonDiplomacy;
    Procedure SendMessage(Msg : String); OverLoad;
    Procedure SendMessage(Msg : TCommonMessage); OverLoad;
    Procedure ProcessMessageBoard;
    Function  GetHotKeyByName(Name : String) : Byte;
    Function  HotKeyName(HoldKey,HotKey : Byte) : String;
    Procedure StrDraw(X,Y : LongInt;Color : LongWord;St : String); OverLoad;
    Procedure StrDraw(X,Y : LongInt;Color : LongWord;St : String;StyleCol,StyleRow : TStyle); OverLoad;
    Procedure StrDraw(X,Y : LongInt;Color : LongWord;St : String;Effect : Integer); OverLoad;
    Procedure StrDraw(X,Y : LongInt;Color1,Color2 : LongWord;St : String;Effect : Integer); OverLoad;
    Procedure RestartButtons;
    Procedure UnPressedAllButton;
    Procedure InitButton(Var Button : TGameButton;
                         BX1,BY1,BX2,BY2 : Integer;
                         BCaption : String;
                         BHoldKey,BHotKey : Byte;
                         CActive,CPWCI : Boolean;
                         CTyper : TGameButtonTyper;
                         CMenuTyper : TButtonMenuTyper); OverLoad;
    Procedure InitButton(Var Button : TGameButton;
                         BX1,BY1,BX2,BY2 : Integer;
                         BCaption : String;
                         BHoldKey,BHotKey : Byte;
                         CActive,CPWCI : Boolean;
                         CTyper : TGameButtonTyper;
                         CUnitNum : FastInt); OverLoad;
    Procedure InitButton(Var Button : TGameButton;
                         BX1,BY1,BX2,BY2 : Integer;
                         BCaption : String;
                         BHoldKey,BHotKey : Byte;
                         CActive,CPWCI : Boolean;
                         CTyper : TGameButtonTyper;
                         CUnitSkill : TUnitSkill); OverLoad;
    Procedure InitButton(Var Button : TGameButton;
                         BX1,BY1,BX2,BY2 : Integer;
                         BCaption : String;
                         BHoldKey,BHotKey : Byte;
                         CActive,CPWCI : Boolean;
                         CTyper : TGameButtonTyper;
                         CUnitItem : TUnitItem); OverLoad;
    Procedure InitButton(Var Button : TGameButton;
                         BX1,BY1,BX2,BY2 : Integer;
                         BCaption : String;
                         BHoldKey,BHotKey : Byte;
                         CActive,CPWCI : Boolean;
                         CTyper : TGameButtonTyper;
                         CEditorCommand : TEditorCommand); OverLoad;
    Procedure InitButton(Var Button : TGameButton;
                         BX1,BY1,BX2,BY2 : Integer;
                         BCaption : String;
                         BHoldKey,BHotKey : Byte;
                         CActive,CPWCI : Boolean;
                         CTyper : TGameButtonTyper;
                         CUnitSelected : TUnit); OverLoad;
    Function  NewButton : Integer; Overload;
    Function  NewButton(BX1,BY1,BX2,BY2 : Integer;
                        BCaption : String;
                        BHoldKey,BHotKey : Byte;
                        CActive,CPWCI : Boolean;
                        CTyper : TGameButtonTyper;
                        CMenuTyper : TButtonMenuTyper) : Boolean; OverLoad;
    Function  NewButton(BX1,BY1,BX2,BY2 : Integer;
                        BCaption : String;
                        BHoldKey,BHotKey : Byte;
                        CActive,CPWCI : Boolean;
                        CTyper : TGameButtonTyper;
                        CUnitNum : FastInt) : Boolean; OverLoad;
    Function  NewButton(BX1,BY1,BX2,BY2 : Integer;
                        BCaption : String;
                        BHoldKey,BHotKey : Byte;
                        CActive,CPWCI : Boolean;
                        CTyper : TGameButtonTyper;
                        CUnitSkill : TUnitSkill) : Boolean; OverLoad;
    Function  NewButton(BX1,BY1,BX2,BY2 : Integer;
                        BCaption : String;
                        BHoldKey,BHotKey : Byte;
                        CActive,CPWCI : Boolean;
                        CTyper : TGameButtonTyper;
                        CUnitItem : TUnitItem) : Boolean; OverLoad;
    Function  NewButton(BX1,BY1,BX2,BY2 : Integer;
                        BCaption : String;
                        BHoldKey,BHotKey : Byte;
                        CActive,CPWCI : Boolean;
                        CTyper : TGameButtonTyper;
                        CEditorCommand : TEditorCommand) : Boolean; OverLoad;
    Function  NewButton(BX1,BY1,BX2,BY2 : Integer;
                        BCaption : String;
                        BHoldKey,BHotKey : Byte;
                        CActive,CPWCI : Boolean;
                        CTyper : TGameButtonTyper;
                        CUnitSelected : TUnit) : Boolean; OverLoad;
    //
    Function  SaveToStream(Stream : TStream) : Boolean;
    Function  LoadFromStream(Stream : TStream) : Boolean;
    Procedure ErrorMessage(Msg : String);
    //
    //Log helper
    //
    Public
    LogFile : Text;
    LogFileOpen : Boolean;
    Procedure LogToFile(FileName : String);
    Procedure Log(Msg : String);
  End;

VAR
  GameScreen : TLOCScreen;

IMPLEMENTATION

FUNCTION  TInputInterface.KeyDown(Key : Byte) : Boolean;
  Begin
    Result:=FirstState[Key]=$80;
  End;

FUNCTION  TInputInterface.KeyPress(Key : Byte) : Boolean;
  Begin
    Result:=(FirstState[Key]=$80) and (LastState[Key]<>$80);
  End;
{$R-}
PROCEDURE TInputInterface.GetState;
  Var DiDod        : Array[0..19] of TDIDeviceObjectData;
      DWElements,I : LongWord;
      HRet         : HResult;
  Begin
    FirstState:=LastState;
    MouseL:=L;MouseR:=R;MouseM:=M;
    ZeroMemory(@LastState,SizeOf(LastState));
    HRet:=DIKeyboard.GetDeviceState(SizeOf(LastState),@LastState);
    If (HRet<>DI_Ok) then
      Begin
        HRet:=DIKeyboard.Acquire();
        While (HRet=DIERR_InputLost) do HRet:=DIKeyboard.Acquire();
        Exit;
      End;
    DWElements:=20;
    HRet:=DIMouse.GetDeviceData(SizeOf(TDIDeviceObjectData),@DiDod,DWElements,0);
    If HRet<>DI_OK then
      Begin
        HRet:=DIMouse.Acquire();
        While (HRet=DIERR_INPUTLOST) do HRet:=DIMouse.Acquire();
        Exit;
      End;
    If DWElements=0 then Exit;
    For I:=0 to DWElements-1 do
      Begin
        Case (DiDod[I].DWOfs) of
          DIMOFS_BUTTON0 : If (DiDod[I].DWData=$80) then L:=True Else L:=False;
          DIMOFS_BUTTON1 : If (DiDod[I].DWData=$80) then R:=True Else R:=False;
          DIMOFS_BUTTON2 : If (DiDod[I].DWData=$80) then M:=True Else M:=False;
          DIMOFS_X       : AX:=DiDod[I].DWData; 
          DIMOFS_Y       : AY:=DiDod[I].DWData;
        End;
      End;
    MouseGetPosition(MouseX,MouseY);
  End;
{$R+}
FUNCTION  TInputInterface.MouseReleasedL : Boolean;
  Begin
    Result:=MouseL and (L=False);
  End;

FUNCTION  TInputInterface.MouseReleasedM : Boolean;
  Begin
    Result:=MouseM and (M=False);
  End;

FUNCTION  TInputInterface.MouseReleasedR : Boolean;
  Begin
    Result:=MouseR and (R=False);
  End;

FUNCTION  TInputInterface.MouseFirstClickL : Boolean;
  Begin
    Result:=(MouseL=False) and L;
  End;

FUNCTION  TInputInterface.MouseFirstClickM : Boolean;
  Begin
    Result:=(MouseM=False) and M;
  End;

FUNCTION  TInputInterface.MouseFirstClickR : Boolean;
  Begin
    Result:=(MouseR=False) and R;
  End;

FUNCTION  TInputInterface.MouseHoldL : Boolean;
  Begin
    Result:=MouseL and L;
  End;

FUNCTION  TInputInterface.MouseHoldR : Boolean;
  Begin
    Result:=MouseR and R;
  End;

CONSTRUCTOR TLOCScreen.Create;
  Begin
    //Log file initialize
    LogFileOpen:=False;
    LogToFile(DefaultLogFileName);
    Log('.K-Outertainment Game System Loging [KGSL]');
    Log('.Warcraft new generation');
    Log('.Log in '+TimeToStr(Time)+' '+DayOfWeekStr(Date)+' '+DateToStr(Date));
    //Parser parameter configurations
    ParserParameters;
    GameInfo.GameName:=GameCaption;
    GameInfo.GameVersion:=GameVersion;
    GameInfo.GameProduct:=GameProduct;
    GameInfo.GameCopyRight:=GameCopyRight;
    {$IfDef Debug}
    GameTimeStart:=TimeGetTime;
    {$EndIf}
    Case VideoMode of
      M800x600 :
        Begin
          ScreenWidth:=800;
          ScreenHeight:=600;
        End;
      M1024x768 :
        Begin
          ScreenWidth:=1024;
          ScreenHeight:=768;
        End;
    End;
    If FullScreen then
      Screen:=TSelfFullAvenus3D.Create(ScreenWidth,ScreenHeight,ColorDepth,GameID)
    Else Screen:=TSelfAvenus3D.Create(ScreenWidth,ScreenHeight,GameID);
    Input:=TInputInterface.Create(Screen.Handle);
    {$IfDef WinCursor}
    Input.SetWinCursor(True);
    {$EndIf}
    {$IfDef LoadOnDataBase}
    GraphicDataFile:=TKPF.Create;
    GraphicDataFile.FileName:=GraphicDataFileName;
    GraphicDataFile.OpenMode:=OpenReadOnly;
    If GraphicDataFile.Initialize<>0 then
      Begin
        GraphicDataFile.Free;
        Exit;
      End;
    {$EndIf}
    //Setup color
    White:=RGBToLongWord(255,255,255);
    Red:=RGBToLongWord(255,0,0);
    Green:=RGBToLongWord(0,255,0);
    Blue:=RGBToLongWord(0,0,255);
    SeaBlue:=RGBToLongWord(10,120,255);
    DarkGreen:=RGBToLongWord(0,155,0);
    Yellow:=RGBToLongWord(255,255,128);
    //Setup for cheats
    CheatToggle[NoFog]:='NOFOG';
    CheatToggle[OnScreen]:='ONSCREEN';
    CheatToggle[NoFoodLimit]:='POINTBREAK';
    CheatToggle[NoCost]:='WHONEEDMONEY?';
    {$IfDef Debug}
    FillChar(DebugStatus,SizeOf(DebugStatus),False);
    DebugToggle[ShowClanInfo        ]:='SHOWCLANSINFO';
    DebugToggle[ShowMapInfo         ]:='SHOWMAPINFO';
    DebugToggle[ShowGameInfo        ]:='SHOWGAMEINFO';
    DebugToggle[ShowVideoInfo       ]:='SHOWGLOBALINFO';
    DebugToggle[ShowUnitInfo        ]:='SHOWUNITINFO';
    DebugToggle[ShowScriptDebug     ]:='SHOWSCRIPTDEBUG';
    {$EndIf}
    RestartData;
    AdjustViewSize;
    Font:=TAvenusNewFont.Create(Screen);
    {$IfDef LoadOnDataBase}
    Font.LoadFromPackFile(GraphicDataFile,GameDataDir+ImagesDir+'Font.png',0);
    {$Else}
    Font.LoadFromFile(GameDataDir+ImagesDir+'Font.png',0); 
    {$EndIf}
    //Screen.Antialias:=True;
  End;

DESTRUCTOR TLOCScreen.Destroy;
  Begin
    {$IfDef LoadOnDataBase}
    GraphicDataFile.Free;
    {$EndIf}
    Font.Free;
    Input.Free;
    Screen.Free;
    Log('.Log out');
    If LogFileOpen then
      Begin
        Flush(LogFile);
        Close(LogFile);
      End;
  End;
  
PROCEDURE TLOCScreen.ParserParameters;
  Var St : String;
      Z  : Integer;
  Begin
    //Default config
    VideoMode:=M1024x768;
    FullScreen:=True;
    For Z:=1 to ParamCount do
      Begin
        St:=ParamStr(Z);
        StrippedAllSpaceAndUpCase(St);
        Case St[1] of
          'M' :
            Begin
              If St='M1024' then VideoMode:=M1024x768
              Else VideoMode:=M800x600;
            End;
          'F' :
            Begin
              If St[2]='+' then FullScreen:=True;
              If St[2]='-' then FullScreen:=False;
            End;
        End;
      End;
    Log('Parameter configuration processing complete.');
  End;

PROCEDURE TLOCScreen.RestartTime;
  Begin
    GameFrame:=0;
    ScreenFrame:=0;
    CmdLineEnter:=False;
    GameTimeStart:=TimeGetTime;
    ScreenUpdateSavedTime:=GameTimeStart;
    UnitUpdateSavedTime:=GameTimeStart;
    FogUpdateSavedTime:=GameTimeStart;
    InputUpdateSavedTime:=GameTimeStart;
    MsgBoardUpdateSavedTime:=GameTimeStart;
    ScriptRunSavedTime:=GameTimeStart;
    //
    //CurrentMinute:=Random(MinutePerDay);
    CurrentMinute:=07*TimePerHour;
    //
    GetDayTime;
  End;

PROCEDURE TLOCScreen.RestartData;
  Begin
    FillChar(CheatStatus,SizeOf(CheatStatus),False);
    GameFrame:=0;
    LastestMsg:=0;
    CmdWaitForSelect:=Low(TSkill);
    EndGame:=False;
    QuitGame:=False;
    GamePause:=False;
    AllowUnitAction:=True;
    AllowPlayerInput:=True;
    ReadyForNextFrame:=False;
    ButtonInRange:=1;
    OldRange:=1;
    MouseInButton:=False;
    UpDateToolTip:=True;
    MouseIn:=MINoWhere;
    ToolTip:='';
  End;
  
PROCEDURE TLOCScreen.GetDayTime;
  Begin
    CurrentMinute:=(CurrentMinute+1) mod MinutePerDay;
    Hour:=CurrentMinute div TimePerHour;
    Minute:=CurrentMinute mod TimePerHour;
    If (CurrentMinute>=07*TimePerHour) and (CurrentMinute<18*TimePerHour) then DayTime:=Noon Else
    If (CurrentMinute>=18*TimePerHour) and (CurrentMinute<22*TimePerHour) then DayTime:=Dusk Else
    If (CurrentMinute>=22*TimePerHour) and (CurrentMinute<24*TimePerHour) then DayTime:=MidNight Else
    If (CurrentMinute>=00*TimePerHour) and (CurrentMinute<04*TimePerHour) then DayTime:=MidNight Else
    If (CurrentMinute>=04*TimePerHour) and (CurrentMinute<07*TimePerHour) then DayTime:=Dawn;
  End;

PROCEDURE TLOCScreen.SendMessage(Msg : String);
  Var Z : FastInt;
  Begin
    If Length(Msg)=0 then Exit;
    If LastestMsg=MaxMessage then
      Begin
        For Z:=1 to LastestMsg-1 do
          Begin
            MessageBoard[Z]:=MessageBoard[Z+1];
            MessageBoardType[Z]:=MessageBoardType[Z+1];
            MessageBoardData[Z]:=MessageBoardData[Z+1];
          End;
      End
    Else Inc(LastestMsg);
    MessageBoard[LastestMsg]:=Msg;
    MessageBoardType[LastestMsg]:=CommonChat;
    MessageBoardData[LastestMsg].FadeStart:=1000;
    MessageBoardData[LastestMsg].FadeEnd:=MessageBoardData[LastestMsg].FadeStart+128;
    If LastestMsg=1 then MsgBoardUpdateSavedTime:=GameTime;
  End;

PROCEDURE TLOCScreen.SendMessage(Msg : TCommonMessage);
  Var Z : FastInt;
  Begin
    If (LastestMsg<>0) and (Msg<>CommonChat) and
       (Msg=MessageBoardType[LastestMsg]) and
       (MessageBoardData[LastestMsg].FadeEnd>64) then Exit;
    If LastestMsg=MaxMessage then
      Begin
        For Z:=1 to LastestMsg-1 do
          Begin
            MessageBoard[Z]:=MessageBoard[Z+1];
            MessageBoardType[Z]:=MessageBoardType[Z+1];
            MessageBoardData[Z]:=MessageBoardData[Z+1];
          End;
      End
    Else Inc(LastestMsg);
    MessageBoard[LastestMsg]:=CommonMessage[Msg];
    MessageBoardType[LastestMsg]:=Msg;
    MessageBoardData[LastestMsg].FadeStart:=2000;
    MessageBoardData[LastestMsg].FadeEnd:=MessageBoardData[LastestMsg].FadeStart+128;
    If LastestMsg=1 then MsgBoardUpdateSavedTime:=GameTime;
  End;

PROCEDURE TLOCScreen.ProcessMessageBoard;
  Var Z : FastInt;
  Begin
    For Z:=1 to LastestMsg do
      Begin
        Dec(MessageBoardData[Z].FadeStart,MessageFadeSpeed);
        Dec(MessageBoardData[Z].FadeEnd,MessageFadeSpeed);
        If MessageBoardData[Z].FadeStart<0 then
          MessageBoardData[Z].FadeStart:=0;
        If MessageBoardData[Z].FadeEnd<0 then
          MessageBoardData[Z].FadeEnd:=0;
      End;
    If (LastestMsg<>0) and
       (MessageBoardData[1].FadeEnd=0) then
      Begin
        For Z:=1 to LastestMsg-1 do
          Begin
            MessageBoard[Z]:=MessageBoard[Z+1];
            MessageBoardType[Z]:=MessageBoardType[Z+1];
            MessageBoardData[Z]:=MessageBoardData[Z+1];
          End;
        Dec(LastestMsg);
      End;
  End;

PROCEDURE TLOCScreen.SetupButtonMenu;
  Begin
    Case VideoMode of
      M800x600 :
        Begin
          {$IfDef NewInsertButtonEditor}
          NewButton(000,000,000+055,020,MenuStr,
                    Key_LControl,Key_F11,True,True,ButtonMenu,GameButtonMenu);
          {$Else}
          InitButton(GameButtons[CMenuButtonStart+Byte(GameButtonMenu)],000,000,000+055,020,MenuStr,
                     Key_LControl,Key_F11,True,True,ButtonMenu,GameButtonMenu);
          {$EndIf}
        End;
      M1024x768 :
        Begin
          {$IfDef NewInsertButtonEditor}
          NewButton(000,000,000+055,020,MenuStr,
                    Key_LControl,Key_F11,True,True,ButtonMenu,GameButtonMenu);
          {$Else}
          InitButton(GameButtons[CMenuButtonStart+Byte(GameButtonMenu)],000,000,000+055,020,MenuStr,
                     Key_LControl,Key_F11,True,True,ButtonMenu,GameButtonMenu);
          {$EndIf}
        End;
    End;
  End;

PROCEDURE TLOCScreen.SetupButtonPause;
  Begin
    Case VideoMode of
      M800x600 :
        Begin
          {$IfDef NewInsertButtonEditor}
          NewButton(060,000,060+055,020,PauseStr,
                    0,Key_Pause,True,True,ButtonMenu,GameButtonPause);
          {$Else}
          InitButton(GameButtons[CMenuButtonStart+Byte(GameButtonPause)],060,000,060+055,020,PauseStr,
                     0,Key_Pause,True,True,ButtonMenu,GameButtonPause);
          {$EndIf}
        End;
      M1024x768 :
        Begin
          {$IfDef NewInsertButtonEditor}
          NewButton(060,000,060+055,020,PauseStr,
                    0,Key_Pause,True,True,ButtonMenu,GameButtonPause);
          {$Else}
          InitButton(GameButtons[CMenuButtonStart+Byte(GameButtonPause)],060,000,060+055,020,PauseStr,
                     0,Key_Pause,True,True,ButtonMenu,GameButtonPause);
          {$EndIf}
        End;
    End;
  End;

PROCEDURE TLOCScreen.SetupButtonDiplomacy;
  Begin
    Case VideoMode of
      M800x600 :
        Begin
          {$IfDef NewInsertButtonEditor}
          NewButton(120,000,120+080,020,DiplomacyStr,
                    0,Key_F11,True,True,ButtonMenu,GameButtonDiplomacy);
          {$Else}
          InitButton(GameButtons[CMenuButtonStart+Byte(GameButtonDiplomacy)],120,000,120+080,020,DiplomacyStr,
                     0,Key_F11,True,True,ButtonMenu,GameButtonDiplomacy);
          {$EndIf}
        End;
      M1024x768 :
        Begin
          {$IfDef NewInsertButtonEditor}
          NewButton(120,000,120+080,020,DiplomacyStr,
                    0,Key_F11,True,True,ButtonMenu,GameButtonDiplomacy);
          {$Else}
          InitButton(GameButtons[CMenuButtonStart+Byte(GameButtonDiplomacy)],120,000,120+080,020,DiplomacyStr,
                     0,Key_F11,True,True,ButtonMenu,GameButtonDiplomacy);
          {$EndIf}
        End;
    End;
  End;

PROCEDURE TLOCScreen.AdjustViewSize;
  Begin
    RestartButtons;
    Case VideoMode of
      M800x600 :
        Begin
          MapViewPosXOS:=8;
          MapViewPosYOS:=24;
          ViewPosXOS:=184;
          ViewPosYOS:=22;
          //For selection button
          SelectionButtonSizeX:=40;
          SelectionButtonSizeY:=36;
          SelectionPosX1:=8;
          SelectionPosY1:=192;
          //Unit queue button setting
          QueueButtonSizeX:=38;
          QueueButtonSizeY:=32;
          QueuePosX:=16;
          QueuePosY:=SelectionPosY1+SelectionButtonSizeY+8;
          //Item button setting
          ItemPosX:=4;
          ItemPosY:=SelectionPosY1+SelectionButtonSizeY*4+8;
          ItemButtonSizeX:=28;
          ItemButtonSizeY:=32;
          //Skill button setting
          SkillButtonSizeX:=40;
          SkillButtonSizeY:=36;
          SkillPosX:=8;
          SkillPosY:=ItemPosY+ItemButtonSizeY*3+8;
          //Resource position
          ResourcePosX:=204;
          ResourcePosY:=4;
          //Command line position
          CmdLinePosX:=184+8;
          CmdLinePosY:=570;
          CmdLineSizeX:=19*32-16;
          CmdLineSizeY:=20;
          //Messages board position
          MsgBoardPosX:=184;
          MsgBoardPosY:=CmdLinePosY-30;
        End;
      M1024x768 :
        Begin
          MapViewPosXOS:=8;
          MapViewPosYOS:=48;
          ViewPosXOS:=216;
          ViewPosYOS:=22;
          //Unit selection button setting
          SelectionButtonSizeX:=46;
          SelectionButtonSizeY:=38+2;
          SelectionPosX1:=8;
          SelectionPosY1:=288;
          NamePosX:=SelectionButtonSizeX+4;
          NamePosY:=4;
          //Unit queue button setting
          QueueButtonSizeX:=40;
          QueueButtonSizeY:=36;
          QueuePosX:=16;
          QueuePosY:=SelectionPosY1+SelectionButtonSizeY+8;
          //Item button setting
          ItemPosX:=4;
          ItemPosY:=SelectionPosY1+SelectionButtonSizeY*4+8;
          ItemButtonSizeX:=32;
          ItemButtonSizeY:=36;
          //Skill button setting
          SkillButtonSizeX:=40;
          SkillButtonSizeY:=36;
          SkillPosX:=8;
          SkillPosY:=ItemPosY+ItemButtonSizeY*3+8;
          {//Unit queue button setting
          QueueButtonSizeX:=40;
          QueueButtonSizeY:=36+2;
          QueuePosX:=16;
          QueuePosY:=330;
          //For skill button
          SkillButtonSizeX:=46;
          SkillButtonSizeY:=38;
          SkillPosX:=8;
          SkillPosY:=288+200+16;}
          ResourcePosX:=216;
          ResourcePosY:=4;
          //
          CmdLinePosX:=216+16;
          CmdLinePosY:=734;
          CmdLineSizeX:=24*32-16;
          CmdLineSizeY:=20;
          //
          MsgBoardPosX:=216;
          MsgBoardPosY:=CmdLinePosY-30;
        End;
    End;
  End;

FUNCTION  TLOCScreen.GetHotKeyByName(Name : String) : Byte;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    If Name='ESC'           then Result:=Key_ESCAPE         Else//$01;
    If Name='1'             then Result:=Key_1              Else//$02;
    If Name='2'             then Result:=Key_2              Else//$03;
    If Name='3'             then Result:=Key_3              Else//$04;
    If Name='4'             then Result:=Key_4              Else//$05;
    If Name='5'             then Result:=Key_5              Else//$06;
    If Name='6'             then Result:=Key_6              Else//$07;
    If Name='7'             then Result:=Key_7              Else//$08;
    If Name='8'             then Result:=Key_8              Else//$09;
    If Name='9'             then Result:=Key_9              Else//$0A;
    If Name='0'             then Result:=Key_0              Else//$0B;
    If Name='-'             then Result:=Key_MINUS          Else//$0C;Else//- on main keyboard
    If Name='='             then Result:=Key_EQUALS         Else//$0D;
    If Name='BACKSPACE'     then Result:=Key_BACK           Else//$0E;Else//backspace
    If Name='TAB'           then Result:=Key_TAB            Else//$0F;
    If Name='Q'             then Result:=Key_Q              Else//$10;
    If Name='W'             then Result:=Key_W              Else//$11;
    If Name='E'             then Result:=Key_E              Else//$12;
    If Name='R'             then Result:=Key_R              Else//$13;
    If Name='T'             then Result:=Key_T              Else//$14;
    If Name='Y'             then Result:=Key_Y              Else//$15;
    If Name='U'             then Result:=Key_U              Else//$16;
    If Name='I'             then Result:=Key_I              Else//$17;
    If Name='O'             then Result:=Key_O              Else//$18;
    If Name='P'             then Result:=Key_P              Else//$19;
    If Name='['             then Result:=Key_LBRACKET       Else//$1A;
    If Name=']'             then Result:=Key_RBRACKET       Else//$1B;
    If Name='ENTER'         then Result:=Key_RETURN         Else//$1C;Else//Enter on main keyboard
    If Name='LCONTROL'      then Result:=Key_LCONTROL       Else//$1D;
    If Name='A'             then Result:=Key_A              Else//$1E;
    If Name='S'             then Result:=Key_S              Else//$1F;
    If Name='D'             then Result:=Key_D              Else//$20;
    If Name='F'             then Result:=Key_F              Else//$21;
    If Name='G'             then Result:=Key_G              Else//$22;
    If Name='H'             then Result:=Key_H              Else//$23;
    If Name='J'             then Result:=Key_J              Else//$24;
    If Name='K'             then Result:=Key_K              Else//$25;
    If Name='L'             then Result:=Key_L              Else//$26;
    If Name=';'             then Result:=Key_SEMICOLON      Else//$27;
    If Name=''''            then Result:=Key_APOSTROPHE     Else//$28;
    If Name='`'             then Result:=Key_GRAVE          Else//$29;Else//accent grave
    If Name='LSHIFT'        then Result:=Key_LSHIFT         Else//$2A;
    If Name='\'             then Result:=Key_BACKSLASH      Else//$2B;
    If Name='Z'             then Result:=Key_Z              Else//$2C;
    If Name='X'             then Result:=Key_X              Else//$2D;
    If Name='C'             then Result:=Key_C              Else//$2E;
    If Name='V'             then Result:=Key_V              Else//$2F;
    If Name='B'             then Result:=Key_B              Else//$30;
    If Name='N'             then Result:=Key_N              Else//$31;
    If Name='M'             then Result:=Key_M              Else//$32;
    If Name=','             then Result:=Key_COMMA          Else//$33;
    If Name='.'             then Result:=Key_PERIOD         Else//$34;Else//. on main keyboard
    If Name='/'             then Result:=Key_SLASH          Else//$35;Else///on main keyboard
    If Name='RSHIFT'        then Result:=Key_RSHIFT         Else//$36;
    If Name='NUMPADMUL'     then Result:=Key_MULTIPLY       Else//$37;Else//* on numeric keypad
    If Name='LALT'          then Result:=Key_LMENU          Else//$38;Else//Left Alt
    If Name='SPACE'         then Result:=Key_SPACE          Else//$39;
    If Name='CAPITAL'       then Result:=Key_CAPITAL        Else//$3A;
    If Name='F1'            then Result:=Key_F1             Else//$3B;
    If Name='F2'            then Result:=Key_F2             Else//$3C;
    If Name='F3'            then Result:=Key_F3             Else//$3D;
    If Name='F4'            then Result:=Key_F4             Else//$3E;
    If Name='F5'            then Result:=Key_F5             Else//$3F;
    If Name='F6'            then Result:=Key_F6             Else//$40;
    If Name='F7'            then Result:=Key_F7             Else//$41;
    If Name='F8'            then Result:=Key_F8             Else//$42;
    If Name='F9'            then Result:=Key_F9             Else//$43;
    If Name='F10'           then Result:=Key_F10            Else//$44;
    If Name='NUMLOCK'       then Result:=Key_NUMLOCK        Else//$45;
    If Name='SCROLLLOCK'    then Result:=Key_SCROLL         Else//$46;Else//Scroll Lock
    If Name='NUMPAD7'       then Result:=Key_NUMPAD7        Else//$47;
    If Name='NUMPAD8'       then Result:=Key_NUMPAD8        Else//$48;
    If Name='NUMPAD9'       then Result:=Key_NUMPAD9        Else//$49;
    If Name='NUMPADSUB'     then Result:=Key_SUBTRACT       Else//$4A;Else//- on numeric keypad
    If Name='NUMPAD4'       then Result:=Key_NUMPAD4        Else//$4B;
    If Name='NUMPAD5'       then Result:=Key_NUMPAD5        Else//$4C;
    If Name='NUMPAD6'       then Result:=Key_NUMPAD6        Else//$4D;
    If Name='NUMPADADD'     then Result:=Key_ADD            Else//$4E;Else//+ on numeric keypad
    If Name='NUMPAD1'       then Result:=Key_NUMPAD1        Else//$4F;
    If Name='NUMPAD2'       then Result:=Key_NUMPAD2        Else//$50;
    If Name='NUMPAD3'       then Result:=Key_NUMPAD3        Else//$51;
    If Name='NUMPAD0'       then Result:=Key_NUMPAD0        Else//$52;
    If Name='NUMPADDECIMAL' then Result:=Key_DECIMAL        Else//$53;Else//. on numeric keypad
    If Name='F11'           then Result:=Key_F11            Else//$57;
    If Name='F12'           then Result:=Key_F12            Else//$58;
    If Name='F13'           then Result:=Key_F13            Else//$64;Else//(NEC PC98)
    If Name='F14'           then Result:=Key_F14            Else//$65;Else//(NEC PC98)
    If Name='F15'           then Result:=Key_F15            Else//$66;Else//(NEC PC98)
    If Name='KANA'          then Result:=Key_KANA           Else//$70;Else//(Japanese keyboard)
    If Name='CONVERT'       then Result:=Key_CONVERT        Else//$79;Else//(Japanese keyboard)
    If Name='NOCONVERT'     then Result:=Key_NOCONVERT      Else//$7B;Else//(Japanese keyboard)
    If Name='YEN'           then Result:=Key_YEN            Else//$7D;Else//(Japanese keyboard)
    If Name='NUMPADEQUAL'   then Result:=Key_NUMPADEQUALS   Else//$8D;Else//Else//on numeric keypad (NEC PC98)
    If Name='CIRCUMFLEX'    then Result:=Key_CIRCUMFLEX     Else//$90;Else//(Japanese keyboard)
    If Name='AT'            then Result:=Key_AT             Else//$91;Else//(NEC PC98)
    If Name='COLON'         then Result:=Key_COLON          Else//$92;Else//(NEC PC98)
    If Name='UNDERLINE'     then Result:=Key_UNDERLINE      Else//$93;Else//(NEC PC98)
    If Name='KANJI'         then Result:=Key_KANJI          Else//$94;Else//(Japanese keyboard)
    If Name='STOP'          then Result:=Key_STOP           Else//$95;Else//(NEC PC98)
    If Name='AX'            then Result:=Key_AX             Else//$96;Else//(Japan AX)
    If Name='UNLABELED'     then Result:=Key_UNLABELED      Else//$97;Else//(J3100)
    If Name='NUMPADENTER'   then Result:=Key_NUMPADENTER    Else//$9C;Else//Enter on numeric keypad
    If Name='RCONTROL'      then Result:=Key_RCONTROL       Else//$9D;
    If Name='NUMPADCOMMA'   then Result:=Key_NUMPADCOMMA    Else//$B3;Else//,on numeric keypad (NEC PC98)
    If Name='NUMPADDIV'     then Result:=Key_DIVIDE         Else//$B5;Else///on numeric keypad
    If Name='PRINT'         then Result:=Key_SYSRQ          Else//$B7;
    If Name='RALT'          then Result:=Key_RMENU          Else//$B8;Else//Right Alt
    If Name='PAUSE'         then Result:=Key_PAUSE          Else//$C5;Else//Pause (watch out - not realiable on some kbds)
    If Name='HOME'          then Result:=Key_HOME           Else//$C7;Else//Home on arrow keypad
    If Name='UP'            then Result:=Key_UP             Else//$C8;Else//UpArrow on arrow keypad
    If Name='PAGEUP'        then Result:=Key_PRIOR          Else//$C9;Else//PgUp on arrow keypad
    If Name='LEFT'          then Result:=Key_LEFT           Else//$CB;Else//LeftArrow on arrow keypad
    If Name='RIGHT'         then Result:=Key_RIGHT          Else//$CD;Else//RightArrow on arrow keypad
    If Name='END'           then Result:=Key_END            Else//$CF;Else//End on arrow keypad
    If Name='DOWN'          then Result:=Key_DOWN           Else//$D0;Else//DownArrow on arrow keypad
    If Name='PAGEDOWN'      then Result:=Key_NEXT           Else//$D1;Else//PgDn on arrow keypad
    If Name='INSERT'        then Result:=Key_INSERT         Else//$D2;Else//Insert on arrow keypad
    If Name='DELETE'        then Result:=Key_DELETE         Else//$D3;Else//Delete on arrow keypad
    If Name='LWIN'          then Result:=Key_LWIN           Else//$DB;Else//Left Windows Key
    If Name='RWIN'          then Result:=Key_RWIN           Else//$DC;Else//Right Windows Key
    If Name='APPMENU'       then Result:=Key_APPS           Else//$DD;Else//AppMenu Key
    If Name='POWER'         then Result:=Key_POWER          Else//$DE;
    If Name='SLEEP'         then Result:=Key_SLEEP
    Else Result:=0;
  End;

FUNCTION  TLOCScreen.HotKeyName(HoldKey,HotKey : Byte) : String;
  Var Return : String;
  Begin
    If HotKey=Key_ESCAPE         then Return:='Esc'       Else//$01;
    If HotKey=Key_1              then Return:='1'          Else//$02;
    If HotKey=Key_2              then Return:='2'          Else//$03;
    If HotKey=Key_3              then Return:='3'          Else//$04;
    If HotKey=Key_4              then Return:='4'          Else//$05;
    If HotKey=Key_5              then Return:='5'          Else//$06;
    If HotKey=Key_6              then Return:='6'          Else//$07;
    If HotKey=Key_7              then Return:='7'          Else//$08;
    If HotKey=Key_8              then Return:='8'          Else//$09;
    If HotKey=Key_9              then Return:='9'          Else//$0A;
    If HotKey=Key_0              then Return:='0'          Else//$0B;
    If HotKey=Key_MINUS          then Return:='-'          Else//$0C;Else//- on main keyboard
    If HotKey=Key_EQUALS         then Return:='='          Else//$0D;
    If HotKey=Key_BACK           then Return:='BackSpace'  Else//$0E;Else//backspace
    If HotKey=Key_TAB            then Return:='Tab'        Else//$0F;
    If HotKey=Key_Q              then Return:='Q'          Else//$10;
    If HotKey=Key_W              then Return:='W'          Else//$11;
    If HotKey=Key_E              then Return:='E'          Else//$12;
    If HotKey=Key_R              then Return:='R'          Else//$13;
    If HotKey=Key_T              then Return:='T'          Else//$14;
    If HotKey=Key_Y              then Return:='Y'          Else//$15;
    If HotKey=Key_U              then Return:='U'          Else//$16;
    If HotKey=Key_I              then Return:='I'          Else//$17;
    If HotKey=Key_O              then Return:='O'          Else//$18;
    If HotKey=Key_P              then Return:='P'          Else//$19;
    If HotKey=Key_LBRACKET       then Return:='['          Else//$1A;
    If HotKey=Key_RBRACKET       then Return:=']'          Else//$1B;
    If HotKey=Key_RETURN         then Return:='Enter'      Else//$1C;Else//Enter on main keyboard
    If HotKey=Key_LCONTROL       then Return:='LControl'   Else//$1D;
    If HotKey=Key_A              then Return:='A'          Else//$1E;
    If HotKey=Key_S              then Return:='S'          Else//$1F;
    If HotKey=Key_D              then Return:='D'          Else//$20;
    If HotKey=Key_F              then Return:='F'          Else//$21;
    If HotKey=Key_G              then Return:='G'          Else//$22;
    If HotKey=Key_H              then Return:='H'          Else//$23;
    If HotKey=Key_J              then Return:='J'          Else//$24;
    If HotKey=Key_K              then Return:='K'          Else//$25;
    If HotKey=Key_L              then Return:='L'          Else//$26;
    If HotKey=Key_SEMICOLON      then Return:=';'          Else//$27;
    If HotKey=Key_APOSTROPHE     then Return:=''''         Else//$28;
    If HotKey=Key_GRAVE          then Return:='`'          Else//$29;Else//accent grave
    If HotKey=Key_LSHIFT         then Return:='LShift'     Else//$2A;
    If HotKey=Key_BACKSLASH      then Return:='\'          Else//$2B;
    If HotKey=Key_Z              then Return:='Z'          Else//$2C;
    If HotKey=Key_X              then Return:='X'          Else//$2D;
    If HotKey=Key_C              then Return:='C'          Else//$2E;
    If HotKey=Key_V              then Return:='V'          Else//$2F;
    If HotKey=Key_B              then Return:='B'          Else//$30;
    If HotKey=Key_N              then Return:='N'          Else//$31;
    If HotKey=Key_M              then Return:='M'          Else//$32;
    If HotKey=Key_COMMA          then Return:=','          Else//$33;,
    If HotKey=Key_PERIOD         then Return:='.'          Else//$34;Else//. on main keyboard
    If HotKey=Key_SLASH          then Return:='/'          Else//$35;Else///on main keyboard
    If HotKey=Key_RSHIFT         then Return:='RShift'     Else//$36;
    If HotKey=Key_MULTIPLY       then Return:='NumMul'     Else//$37;Else//* on numeric keypad
    If HotKey=Key_LMENU          then Return:='LAlt'       Else//$38;Else//Left Alt
    If HotKey=Key_SPACE          then Return:='Space'      Else//$39;
    If HotKey=Key_CAPITAL        then Return:='Capital'    Else//$3A;
    If HotKey=Key_F1             then Return:='F1'         Else//$3B;
    If HotKey=Key_F2             then Return:='F2'         Else//$3C;
    If HotKey=Key_F3             then Return:='F3'         Else//$3D;
    If HotKey=Key_F4             then Return:='F4'         Else//$3E;
    If HotKey=Key_F5             then Return:='F5'         Else//$3F;
    If HotKey=Key_F6             then Return:='F6'         Else//$40;
    If HotKey=Key_F7             then Return:='F7'         Else//$41;
    If HotKey=Key_F8             then Return:='F8'         Else//$42;
    If HotKey=Key_F9             then Return:='F9'         Else//$43;
    If HotKey=Key_F10            then Return:='F10'        Else//$44;
    If HotKey=Key_NUMLOCK        then Return:='NumLock'    Else//$45;
    If HotKey=Key_SCROLL         then Return:='Scroll'     Else//$46;Else//Scroll Lock
    If HotKey=Key_NUMPAD7        then Return:='NumPad7'    Else//$47;
    If HotKey=Key_NUMPAD8        then Return:='NumPad8'    Else//$48;
    If HotKey=Key_NUMPAD9        then Return:='NumPad9'    Else//$49;
    If HotKey=Key_SUBTRACT       then Return:='NumSub'     Else//$4A;Else//- on numeric keypad
    If HotKey=Key_NUMPAD4        then Return:='NumPad4'    Else//$4B;
    If HotKey=Key_NUMPAD5        then Return:='NumPad5'    Else//$4C;
    If HotKey=Key_NUMPAD6        then Return:='NumPad6'    Else//$4D;
    If HotKey=Key_ADD            then Return:='NumAdd'     Else//$4E;Else//+ on numeric keypad
    If HotKey=Key_NUMPAD1        then Return:='NumPad1'    Else//$4F;
    If HotKey=Key_NUMPAD2        then Return:='NumPad2'    Else//$50;
    If HotKey=Key_NUMPAD3        then Return:='NumPad3'    Else//$51;
    If HotKey=Key_NUMPAD0        then Return:='NumPad0'    Else//$52;
    If HotKey=Key_DECIMAL        then Return:='NumDec'     Else//$53;Else//. on numeric keypad
    If HotKey=Key_F11            then Return:='F11'        Else//$57;
    If HotKey=Key_F12            then Return:='F12'        Else//$58;
    If HotKey=Key_F13            then Return:='F13'        Else//$64;Else//(NEC PC98)
    If HotKey=Key_F14            then Return:='F14'        Else//$65;Else//(NEC PC98)
    If HotKey=Key_F15            then Return:='F15'        Else//$66;Else//(NEC PC98)
    If HotKey=Key_KANA           then Return:='Kana'       Else//$70;Else//(Japanese keyboard)
    If HotKey=Key_CONVERT        then Return:='Convert'    Else//$79;Else//(Japanese keyboard)
    If HotKey=Key_NOCONVERT      then Return:='NoConvert'  Else//$7B;Else//(Japanese keyboard)
    If HotKey=Key_YEN            then Return:='Yen'        Else//$7D;Else//(Japanese keyboard)
    If HotKey=Key_NUMPADEQUALS   then Return:='NumEqual'   Else//$8D;Else//Else//on numeric keypad (NEC PC98)
    If HotKey=Key_CIRCUMFLEX     then Return:='CircumFlex' Else//$90;Else//(Japanese keyboard)
    If HotKey=Key_AT             then Return:='AT'         Else//$91;Else//(NEC PC98)
    If HotKey=Key_COLON          then Return:='Colon'      Else//$92;Else//(NEC PC98)
    If HotKey=Key_UNDERLINE      then Return:='UnderLine'  Else//$93;Else//(NEC PC98)
    If HotKey=Key_KANJI          then Return:='Kanji'      Else//$94;Else//(Japanese keyboard)
    If HotKey=Key_STOP           then Return:='Stop'       Else//$95;Else//(NEC PC98)
    If HotKey=Key_AX             then Return:='AX'         Else//$96;Else//(Japan AX)
    If HotKey=Key_UNLABELED      then Return:='UnLabeled'  Else//$97;Else//(J3100)
    If HotKey=Key_NUMPADENTER    then Return:='PadEnter'   Else//$9C;Else//Enter on numeric keypad
    If HotKey=Key_RCONTROL       then Return:='RControl'   Else//$9D;
    If HotKey=Key_NUMPADCOMMA    then Return:='PadComma'   Else//$B3;Else//,on numeric keypad (NEC PC98)
    If HotKey=Key_DIVIDE         then Return:='PadDiv'     Else//$B5;Else///on numeric keypad
    If HotKey=Key_SYSRQ          then Return:='SysRQ'      Else//$B7;
    If HotKey=Key_RMENU          then Return:='RAlt'       Else//$B8;Else//Right Alt
    If HotKey=Key_PAUSE          then Return:='Pause'      Else//$C5;Else//Pause (watch out - not realiable on some kbds)
    If HotKey=Key_HOME           then Return:='Home'       Else//$C7;Else//Home on arrow keypad
    If HotKey=Key_UP             then Return:='UpArrow'    Else//$C8;Else//UpArrow on arrow keypad
    If HotKey=Key_PRIOR          then Return:='PageUp'     Else//$C9;Else//PgUp on arrow keypad
    If HotKey=Key_LEFT           then Return:='LeftArrow'  Else//$CB;Else//LeftArrow on arrow keypad
    If HotKey=Key_RIGHT          then Return:='RightArrow' Else//$CD;Else//RightArrow on arrow keypad
    If HotKey=Key_END            then Return:='End'        Else//$CF;Else//End on arrow keypad
    If HotKey=Key_DOWN           then Return:='DownArrow'  Else//$D0;Else//DownArrow on arrow keypad
    If HotKey=Key_NEXT           then Return:='PageDown'   Else//$D1;Else//PgDn on arrow keypad
    If HotKey=Key_INSERT         then Return:='PadIns'     Else//$D2;Else//Insert on arrow keypad
    If HotKey=Key_DELETE         then Return:='PadDel'     Else//$D3;Else//Delete on arrow keypad
    If HotKey=Key_LWIN           then Return:='LWin'       Else//$DB;Else//Left Windows Key
    If HotKey=Key_RWIN           then Return:='RWin'       Else//$DC;Else//Right Windows Key
    If HotKey=Key_APPS           then Return:='AppMenu'    Else//$DD;Else//AppMenu Key
    If HotKey=Key_POWER          then Return:='Power'      Else//$DE;
    If HotKey=Key_SLEEP          then Return:='Sleep'           
    Else Return:='';
    Result:=Return;
  End;

PROCEDURE TLOCScreen.StrDraw(X,Y : LongInt;Color : LongWord;St : String);
  Begin
    Font.TextOut(X,Y,St,Color);
  End;
  
PROCEDURE TLOCScreen.StrDraw(X,Y : LongInt;Color : LongWord;St : String;
                             StyleCol,StyleRow : TStyle); 
  Begin
    Case StyleCol of
      StyleLeftText :
        Begin
        End;
      StyleCenterText :
        Begin
          X:=X-Font.Width*Length(St) div 2;
        End;
      StyleRightText :
        Begin
          X:=X-Font.Width*Length(St);
        End;
    End;
    Case StyleRow of
      StyleLeftText :
        Begin
        End;
      StyleCenterText :
        Begin
          Y:=Y-Font.Height div 2;
        End;
      StyleRightText :
        Begin
          Y:=Y-Font.Height;
        End;
    End;
    Font.TextOut(X,Y,St,Color);
  End;

PROCEDURE TLOCScreen.StrDraw(X,Y : LongInt;Color : LongWord;St : String;Effect : Integer);
  Begin
    Font.TextOut(X,Y,St,Color,Effect);
  End;

PROCEDURE TLOCScreen.StrDraw(X,Y : LongInt;Color1,Color2 : LongWord;St : String;Effect : Integer);
  Begin
    Font.TextOut(X,Y,St,Color1,Color2,Effect);
  End;

PROCEDURE TLOCScreen.RestartButtons;
  Var Z : TGameButtonCount;
  Begin
    FillChar(GameButtons,SizeOf(GameButtons),0);
    For Z:=Low(TGameButtonCount) to
           High(TGameButtonCount) do
      GameButtons[Z].Used:=False;
  End;

PROCEDURE TLOCScreen.UnPressedAllButton;
  Var Z : TGameButtonCount;
  Begin
    For Z:=Low(TGameButtonCount) to
           High(TGameButtonCount) do
      GameButtons[Z].Pressed:=False;
  End;

PROCEDURE TLOCScreen.InitButton(Var Button : TGameButton;
                                BX1,BY1,BX2,BY2 : Integer;
                                BCaption : String;
                                BHoldKey,BHotKey : Byte;
                                CActive,CPWCI : Boolean;
                                CTyper : TGameButtonTyper;
                                CMenuTyper : TButtonMenuTyper);
  Begin
    With Button do
      Begin
        Used:=True;
        PosX1:=BX1;PosY1:=BY1;
        PosX2:=BX2;PosY2:=BY2;
        Caption:=BCaption;
        HoldKey:=BHoldKey;
        HotKey:=BHotKey;
        Pressed:=False;
        Active:=CActive;
        CanPressWhenCmdInput:=CPWCI;
        Typer:=CTyper;
        MenuTyper:=CMenuTyper;
      End;
  End;

PROCEDURE TLOCScreen.InitButton(Var Button : TGameButton;
                                BX1,BY1,BX2,BY2 : Integer;
                                BCaption : String;
                                BHoldKey,BHotKey : Byte;
                                CActive,CPWCI : Boolean;
                                CTyper : TGameButtonTyper;
                                CUnitNum : FastInt);
  Begin
    With Button do
      Begin
        Used:=True;
        PosX1:=BX1;PosY1:=BY1;
        PosX2:=BX2;PosY2:=BY2;
        Caption:=BCaption;
        HoldKey:=BHoldKey;
        HotKey:=BHotKey;
        Pressed:=False;
        Active:=CActive;
        CanPressWhenCmdInput:=CPWCI;
        Typer:=CTyper;
        UnitNumRef:=CUnitNum;
      End;
  End;

PROCEDURE TLOCScreen.InitButton(Var Button : TGameButton;
                                BX1,BY1,BX2,BY2 : Integer;
                                BCaption : String;
                                BHoldKey,BHotKey : Byte;
                                CActive,CPWCI : Boolean;
                                CTyper : TGameButtonTyper;
                                CUnitSkill : TUnitSkill);
  Begin
    With Button do
      Begin
        Used:=True;
        PosX1:=BX1;PosY1:=BY1;
        PosX2:=BX2;PosY2:=BY2;
        Caption:=BCaption;
        HoldKey:=BHoldKey;
        HotKey:=BHotKey;
        Pressed:=False;
        Active:=CActive;
        CanPressWhenCmdInput:=CPWCI;
        Typer:=CTyper;
        UnitSkill:=CUnitSkill;
      End;
  End;

PROCEDURE TLOCScreen.InitButton(Var Button : TGameButton;
                                BX1,BY1,BX2,BY2 : Integer;
                                BCaption : String;
                                BHoldKey,BHotKey : Byte;
                                CActive,CPWCI : Boolean;
                                CTyper : TGameButtonTyper;
                                CUnitItem : TUnitItem);
  Begin
    With Button do
      Begin
        Used:=True;
        PosX1:=BX1;PosY1:=BY1;
        PosX2:=BX2;PosY2:=BY2;
        Caption:=BCaption;
        HoldKey:=BHoldKey;
        HotKey:=BHotKey;
        Pressed:=False;
        Active:=CActive;
        CanPressWhenCmdInput:=CPWCI;
        Typer:=CTyper;
        UnitItem:=CUnitItem;
      End;
  End;

PROCEDURE TLOCScreen.InitButton(Var Button : TGameButton;
                                BX1,BY1,BX2,BY2 : Integer;
                                BCaption : String;
                                BHoldKey,BHotKey : Byte;
                                CActive,CPWCI : Boolean;
                                CTyper : TGameButtonTyper;
                                CEditorCommand : TEditorCommand);
  Begin
    With Button do
      Begin
        Used:=True;
        PosX1:=BX1;PosY1:=BY1;
        PosX2:=BX2;PosY2:=BY2;
        Caption:=BCaption;
        HoldKey:=BHoldKey;
        HotKey:=BHotKey;
        Pressed:=False;
        Active:=CActive;
        CanPressWhenCmdInput:=CPWCI;
        Typer:=CTyper;
        EditorCommand:=CEditorCommand;
      End;
  End;

PROCEDURE TLOCScreen.InitButton(Var Button : TGameButton;
                                BX1,BY1,BX2,BY2 : Integer;
                                BCaption : String;
                                BHoldKey,BHotKey : Byte;
                                CActive,CPWCI : Boolean;
                                CTyper : TGameButtonTyper;
                                CUnitSelected : TUnit);
  Begin
    With Button do
      Begin
        Used:=True;
        PosX1:=BX1;PosY1:=BY1;
        PosX2:=BX2;PosY2:=BY2;
        Caption:=BCaption;
        HoldKey:=BHoldKey;
        HotKey:=BHotKey;
        Pressed:=False;
        Active:=CActive;
        CanPressWhenCmdInput:=CPWCI;
        Typer:=CTyper;
        UnitSelected:=CUnitSelected;
      End;
  End;

FUNCTION  TLOCScreen.NewButton : Integer;
  Var Z : Integer;
  Begin
    For Z:=Low(GameButtons) to
           High(GameButtons) do
      If GameButtons[Z].Used=False then
        Begin
          Result:=Z;
          Exit;
        End;
    Result:=0;
  End;

FUNCTION  TLOCScreen.NewButton(BX1,BY1,BX2,BY2 : Integer;
                               BCaption : String;
                               BHoldKey,BHotKey : Byte;
                               CActive,CPWCI : Boolean;
                               CTyper : TGameButtonTyper;
                               CMenuTyper : TButtonMenuTyper) : Boolean;
  Var Z : Integer;
  Begin
    For Z:=Low(GameButtons) to
           High(GameButtons) do
      If GameButtons[Z].Used=False then
        Begin
          Result:=True;
          InitButton(GameButtons[Z],
                     BX1,BY1,BX2,BY2,
                     BCaption,BHoldKey,BHotKey,
                     CActive,CPWCI,CTyper,CMenuTyper);
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCScreen.NewButton(BX1,BY1,BX2,BY2 : Integer;
                               BCaption : String;
                               BHoldKey,BHotKey : Byte;
                               CActive,CPWCI : Boolean;
                               CTyper : TGameButtonTyper;
                               CUnitNum : FastInt) : Boolean;
  Var Z : Integer;
  Begin
    For Z:=Low(GameButtons) to
           High(GameButtons) do
      If GameButtons[Z].Used=False then
        Begin
          Result:=True;
          InitButton(GameButtons[Z],
                     BX1,BY1,BX2,BY2,
                     BCaption,BHoldKey,BHotKey,
                     CActive,CPWCI,CTyper,CUnitNum);
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCScreen.NewButton(BX1,BY1,BX2,BY2 : Integer;
                               BCaption : String;
                               BHoldKey,BHotKey : Byte;
                               CActive,CPWCI : Boolean;
                               CTyper : TGameButtonTyper;
                               CUnitSkill : TUnitSkill) : Boolean;
  Var Z : Integer;
  Begin
    For Z:=Low(GameButtons) to
           High(GameButtons) do
      If GameButtons[Z].Used=False then
        Begin
          Result:=True;
          InitButton(GameButtons[Z],
                     BX1,BY1,BX2,BY2,
                     BCaption,BHoldKey,BHotKey,
                     CActive,CPWCI,CTyper,CUnitSkill);
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCScreen.NewButton(BX1,BY1,BX2,BY2 : Integer;
                               BCaption : String;
                               BHoldKey,BHotKey : Byte;
                               CActive,CPWCI : Boolean;
                               CTyper : TGameButtonTyper;
                               CUnitItem : TUnitItem) : Boolean;
  Var Z : Integer;
  Begin
    For Z:=Low(GameButtons) to
           High(GameButtons) do
      If GameButtons[Z].Used=False then
        Begin
          Result:=True;
          InitButton(GameButtons[Z],
                     BX1,BY1,BX2,BY2,
                     BCaption,BHoldKey,BHotKey,
                     CActive,CPWCI,CTyper,CUnitItem);
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCScreen.NewButton(BX1,BY1,BX2,BY2 : Integer;
                               BCaption : String;
                               BHoldKey,BHotKey : Byte;
                               CActive,CPWCI : Boolean;
                               CTyper : TGameButtonTyper;
                               CEditorCommand : TEditorCommand) : Boolean;
  Var Z : Integer;
  Begin
    For Z:=Low(GameButtons) to
           High(GameButtons) do
      If GameButtons[Z].Used=False then
        Begin
          Result:=True;
          InitButton(GameButtons[Z],
                     BX1,BY1,BX2,BY2,
                     BCaption,BHoldKey,BHotKey,
                     CActive,CPWCI,CTyper,CEditorCommand);
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCScreen.NewButton(BX1,BY1,BX2,BY2 : Integer;
                               BCaption : String;
                               BHoldKey,BHotKey : Byte;
                               CActive,CPWCI : Boolean;
                               CTyper : TGameButtonTyper;
                               CUnitSelected : TUnit) : Boolean;
  Var Z : Integer;
  Begin
    For Z:=Low(GameButtons) to
           High(GameButtons) do
      If GameButtons[Z].Used=False then
        Begin
          Result:=True;
          InitButton(GameButtons[Z],
                     BX1,BY1,BX2,BY2,
                     BCaption,BHoldKey,BHotKey,
                     CActive,CPWCI,CTyper,CUnitSelected);
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCScreen.SaveToStream(Stream : TStream) : Boolean;
  Begin
    Stream.Write(GameInfo,SizeOf(GameInfo));
    Result:=True;
  End;

FUNCTION  TLOCScreen.LoadFromStream(Stream : TStream) : Boolean;
  Var TempInfo : TGameInfo;
  Begin
    Result:=False;
    Stream.Read(TempInfo,SizeOf(TempInfo));
    If GameInfo.GameName<>TempInfo.GameName then Exit;
    If GameInfo.GameVersion<>TempInfo.GameVersion then Exit;
    If GameInfo.GameProduct<>TempInfo.GameProduct then Exit;
    If GameInfo.GameCopyRight<>TempInfo.GameCopyRight then Exit;
    Result:=True;
  End;

PROCEDURE TLOCScreen.ErrorMessage(Msg : String);
  Begin
    Raise Exception.Create(Msg);
  End;

PROCEDURE TLOCScreen.LogToFile(FileName : String);
  Begin
    If LogFileOpen then Exit;
    LogFileOpen:=True;
    Assign(LogFile,FileName);
    Rewrite(LogFile);
  End;
  
PROCEDURE TLOCScreen.Log(Msg : String);
  Begin
    WriteLn(LogFile,Msg);
    Flush(LogFile);
  End;
END.
