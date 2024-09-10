UNIT LOCPlay;
{$Include GlobalDefines.Inc}
INTERFACE

USES Windows,
     MMSystem,
     SysUtils,
     Classes,
     AvenusBase,
     AvenusCommon,
     LOCBased,
     LOCShow,
     LOCScreen,
     LOCUnits,
     LOCWorld,
     LOCEditor,
     LOCMenu,
     LOCDraw,
     LOCUnitProcess,
     LOCPlayer,
     LOCAIPlayer,
     LOCScript,
     LOCNetwork;

TYPE
  TLOCPlay = Class
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
    MyNetwork     : TLOCNetwork;
    MyEditor      : TLOCEditor;
    Constructor Create(Screen : TLOCScreen;
                       Show : TLOCShow;
                       Units : TLOCUnits;
                       World : TLOCWorld;
                       Menu : TLOCMenu;
                       Draw : TLOCDraw;
                       UnitProcess : TLOCUnitProcess;
                       Player : TLOCPlayer;
                       AIPlayer : TLOCAIPlayer;
                       Script : TLOCScript;
                       Network : TLOCNetwork;
                       Editor : TLOCEditor);
    Destructor Destroy;OverRide;
    //Main looping
    Procedure InfinieLoop;
    //Menu call
    Procedure CallMenuSingleGame;
    Procedure CallMenuMultiGame;
    Procedure CallMenuGameOption;
    Procedure CallMenuGameEditor;
    Procedure CallMenuGameInfo;
    Procedure CallOnGameMenu;
    Procedure CallVictoryMenu;
    //Run specific map file
    Procedure RunMap(FileName : String);
    //Process play game mode, previous step that loading map
    Procedure PlayGame;
    //Process editor game mode
    Procedure EditorGame;
    //Set unit rate
    Procedure SetUnitRate(NewRate : FastInt);
    //Set screen rate
    Procedure SetScreenRate(NewRate : FastInt);
    //Check game button click if left mouse click
    Procedure CallGameButtonLeftClick(Button : TGameButtonCount);
    //Check game button click if right button click
    Procedure CallGameButtonRightClick(Button : TGameButtonCount);
    //Call game button by left mouse click
    Procedure CheckCallGameButtonByLeftMouse;
    //Call game button by right mouse click
    Procedure CheckCallGameButtonByRightMouse;
    //Cancel left mouse command by right click
    Procedure CancelLeftMouseCommand;
    //Left mouse click ? (In play game)
    Procedure LeftMouseClick;
    //Right mouse click ? (In play game)
    Procedure RightMouseClick;
    //Send wait command for exact unit (click on unit selected icon)
    Procedure SendWaitCommandTarget(UnitTarget : TUnitCount);
    //Send wait command choise on view screen
    Procedure SendWaitCommand(X,Y,XS,YS : FastInt);
    //Send wait command by click on mini map
    Procedure SendWaitCommandOnMiniMap(X,Y : FastInt);
    //Send hotkey, every hot key for command has been detected here
    //If want to add new command, must add code for this here, ok ?
    Procedure SendHotKey(SkillUse : TUnitSkill);
    //Insert character
    Procedure InsertCommandLine(C : Char);
    //Get from keyboard
    Procedure GetCommandLine;
    //Check for debug, cheats
    Function  CheckCommandLine : Boolean;
    //Send message
    Procedure SendCommandLine;
    //Clear commandline
    Procedure DeleteCommandLine;
    //Check button status when mouse left holding
    Procedure CheckMouseLeftHolding;
    Procedure CheckMouseRightHolding;
    Procedure CheckMouseLeftHoldInGameButton;
    Procedure CheckMouseRightHoldInGameButton;
    Procedure CheckMousePosition;
    //Process left mouse holding (unit selection)
    Procedure MouseLeftHolding;
    Procedure MouseRightHolding;
    //Check for game button hotkey
    Procedure GameButtonControl;
    //Only check for game button
    Procedure GameButtonControlOnly;
    //Keep hotkey when command not input ! Only for game play mode !
    Procedure GetHotKeyInput;
    Procedure GetHotKeyInputEditor;
    //Process input of player
    Procedure GetPlayerInput;
    //Process mouse control
    Procedure GetPlayerMouseControl;
    Procedure GetPlayerCommonControl;
    Procedure GameMenuControl;
    //
    Procedure GroupingControl;
    //Process mini map control
    Procedure MiniMapControl;
    //
    Procedure CallSaveGameMenu;
    Procedure CallLoadGameMenu;
    //Process input when game play mode
    Procedure ProcessInput;
    //Process unit when game play mode
    Procedure ProcessUnits;
    //Process game events, currently used for both gameplay and gameeditor mode
    Procedure ProcessEvents;
    //Process game screen, currently used for both gameplay and gameeditor mode
    Procedure ProcessScreen;
    //
    //Save & load method
    //
    Procedure SaveSlot(Return : TMenuSelectResult);
    Procedure LoadSlot(Return : TMenuSelectResult);
    Function  SaveWorld(FileName : String) : Boolean;
    Function  LoadWorld(FileName : String) : Boolean;
    //
    //Editor method ?
    //
    Procedure EditorMap(FileName : String);
    //Left mouse click ? (In editor game)
    Procedure LeftMouseClickEditor;
    //Right mouse click ? (In editor game)
    Procedure RightMouseClickEditor;
    //Process input while editor mode
    Procedure GetEditorInput;
    //Process mouse holding when editor
    Procedure CheckMouseLeftHoldingEditor;
    Procedure CheckMouseRightHoldingEditor;
    Procedure MouseLeftHoldingEditor;
    Procedure MouseRightHoldingEditor;
    Procedure GetPlayerMouseControlEditor;
    //Process input when in editor mode
    Procedure ProcessEditorInput;
    //Process units when in editor mode
    Procedure ProcessEditorUnits;
  End;

VAR
  GamePlay : TLOCPlay;  

IMPLEMENTATION

CONSTRUCTOR TLOCPlay.Create(Screen : TLOCScreen;
                            Show : TLOCShow;
                            Units : TLOCUnits;
                            World : TLOCWorld;
                            Menu : TLOCMenu;
                            Draw : TLOCDraw;
                            UnitProcess : TLOCUnitProcess;
                            Player : TLOCPlayer;
                            AIPlayer : TLOCAIPlayer;
                            Script : TLOCScript;
                            Network : TLOCNetwork;
                            Editor : TLOCEditor);
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
    MyNetwork:=Network;
    MyEditor:=Editor;
  End;

DESTRUCTOR TLOCPlay.Destroy;
  Begin
  End;

PROCEDURE TLOCPlay.InfinieLoop;
  Var MenuSelect : TMenuSelectResult;
  Begin
    Repeat
      MyMenu.SetupForMainMenu;
      MenuSelect:=MyMenu.MainMenuSelection(True);
      Case MenuSelect of
        MenuPlaySingle : CallMenuSingleGame;
        MenuPlayMulti  : CallMenuMultiGame;
        MenuGameOption : CallMenuGameOption;
        MenuGameEditor : CallMenuGameEditor;
        MenuGameInfo   : CallMenuGameInfo;
        MenuQuitGame   : MyScreen.QuitGame:=True;
      End;
    Until MyScreen.QuitGame;
  End;

PROCEDURE TLOCPlay.CallMenuSingleGame;
  Begin
    RunMap('');
  End;

PROCEDURE TLOCPlay.CallMenuMultiGame;
  Begin
  End;

PROCEDURE TLOCPlay.CallMenuGameOption;
  Begin
  End;

PROCEDURE TLOCPlay.CallMenuGameEditor;
  Begin
    MyWorld.LoadEmptyMap(DefaultMapSize,DefaultMapSize);
    MyScreen.GamePause:=False;
    MyDraw.RestartData;
    MyScreen.RestartTime;
    MyScript.RemoveAllScript;
    Self.EditorGame;
  End;

PROCEDURE TLOCPlay.CallMenuGameInfo;
  Begin
    MyShow.ShowCredits;
  End;

PROCEDURE TLOCPlay.RunMap(FileName : String);
  Begin
    MyWorld.LoadMap(FileName);
    MyScreen.GamePause:=False;
    MyScreen.RestartData;
    MyDraw.RestartData;
    MyScreen.RestartTime;
    MyScript.RemoveAllScript;
    MyScript.LoadScript(GameDataDir+GameScriptDir+'DefaultMeleScript.PSS');
    //MyScript.LoadScript(GameDataDir+GameScriptDir+'DefaultScriptTest.PSS');
    MyScript.LoadScript(GameDataDir+GameScriptDir+'DefaultDemotranstion.PSS');
    Self.PlayGame;
  End;

PROCEDURE TLOCPlay.CallOnGameMenu;
  Begin
    With MyScreen,MyMenu do
      Begin
        SetupForOnGameMenu;
        MenuActive:=True;
      End;
  End;

PROCEDURE TLOCPlay.CallVictoryMenu;
  Begin
    With MyScreen,MyMenu do
      Begin
        SetupForVictoryGameMenu;
        MenuActive:=True;
      End;
  End;

PROCEDURE TLOCPlay.CallGameButtonLeftClick(Button : TGameButtonCount);
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu,GameButtons[Button] do
      Begin
        Pressed:=False;
        Case Typer of
          //Call button menu
          ButtonMenu :
            Begin
              Case MenuTyper of
                //Menu button
                GameButtonMenu :
                  Begin
                    CallOnGameMenu;
                  End;
                //Pause button
                GameButtonPause :
                  Begin
                    GamePause:=Not GamePause;
                  End;
                //Diplomacy button
                GameButtonDiplomacy :
                  Begin
                  End;
              End;
            End;
          ButtonUnitSelected :
            Begin
              If CmdWaitForSelect<>NoCmd then
                Begin
                  SendWaitCommandTarget(UnitNumRef);
                End
              Else//Unselect this unit ?
              If Input.KeyDown(Key_LControl) then UnSelectUnitNum(UnitNumRef)
              Else
                Begin
                  If NumberUnitInGroup(SaveGroups[MaxGroup])=1 then CenterGroup(MaxGroup)
                  Else SelectUnitNum(UnitNumRef);
                End;
            End;
          ButtonUnitCommand :
            Begin
              SendHotkey(UnitSkill);
            End;
          ButtonUnitItem :
            Begin
              If CmdWaitForSelect=CmdPutItem then
                Begin
                  If UnitItem.Typer<>ItemNone then
                    Begin
                      If Not UnitSwitchItem(UnitFocus,ItemSlot,ItemWaitToPut) then
                        Begin
                          SendMessage(Format(MsgNotSupport,[SlotName[ItemSlot],
                                                            ItemClassName[ItemProperty[ItemWaitToPut.Typer].ItemClass]]));
                        End;
                    End
                  Else
                    Begin
                      If Not UnitSwitchItem(UnitFocus,ItemSlot,ItemWaitToPut) then
                        Begin
                          SendMessage(Format(MsgNotSupport,[SlotName[ItemSlot],
                                                            ItemClassName[ItemProperty[ItemWaitToPut.Typer].ItemClass]]));
                        End
                      Else CmdWaitForSelect:=NoCmd;
                    End;
                  SetupUnitItemButtons(UnitFocus);
                End
              Else
              //If item can be direct used then used this item ?
              If ItemProperty[UnitItem.Typer].ItemAttribute and
                 ItemUsedDirective=ItemUsedDirective then
                Begin
                End;
            End;
          ButtonUnitQueue :
            Begin
            End;
          ButtonEditorCommand :
            Begin
              Case EditorCommand of
                ECTerrain :
                  Begin
                  End;
                ECSelectUnit :
                  Begin
                  End;
                ECNextUnit :
                  Begin
                    //Select next unit
                    MyEditor.SelectNextUnit;
                  End;
                ECPrevUnit :
                  Begin
                    //Select prev unit
                    MyEditor.SelectPrevUnit;
                  End;
                ECPlaceUnit :
                  Begin
                    //Set command to place unit
                    CmdWaitForSelect:=CmdPlaceUnit;
                  End;
                ECRemoveUnit :
                  Begin
                    //Set command to remove unit
                    CmdWaitForSelect:=CmdRemoveUnit;
                  End;
                ECSelectClan :
                  Begin
                  End;
                ECNextClan :
                  Begin
                    //Select next clan
                    MyEditor.SelectNextClan;
                  End;
                ECPrevClan :
                  Begin
                    //Select prev clan
                    MyEditor.SelectPrevClan;
                  End;
                ECSmallTerrain :
                  Begin
                    //Set command to remove unit
                    CmdWaitForSelect:=CmdPlaceSmallTerrain;
                  End;
                ECNormalTerrain :
                  Begin
                    //Set command to remove unit
                    CmdWaitForSelect:=CmdPlaceNormalTerrain;
                  End;
                ECHugeTerrain :
                  Begin
                    //Set command to remove unit
                    CmdWaitForSelect:=CmdPlaceHugeTerrain;
                  End;
                ECSelectTerrain :
                  Begin
                  End;
                ECNextTerrain :
                  Begin
                    //Select next terrain
                    MyEditor.SelectNextTerrain;
                  End;
                ECPrevTerrain :
                  Begin
                    //Select prev terrain
                    MyEditor.SelectPrevTerrain;
                  End;
              End;
            End;
          ButtonEditorUnit :
            Begin
              MyEditor.CurrentEditorUnit:=UnitSelected;
            End;
        End;
        Pressed:=False;
      End;
  End;

PROCEDURE TLOCPlay.CallGameButtonRightClick(Button : TGameButtonCount);
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu,GameButtons[Button] do
      Begin
        Pressed:=False;
        Case Typer of
          ButtonMenu :
            Begin
            End;
          ButtonUnitSelected :
            Begin
            End;
          ButtonUnitCommand :
            Begin
            End;
          ButtonUnitItem :
            Begin
              //Pick up item to puting to somewhere ?
              If UnitItem.Typer<>ItemNone then
                Begin
                  CmdWaitForSelect:=CmdPutItem;
                  ItemWaitToPut:=UnitItem;
                  ItemSlotSelection:=ItemSlot;
                  With Units[UnitFocus] do
                    _UnitItems[ItemSlotSelection].Typer:=ItemNone;
                  SetupGroupSelected(MaxGroup);
                End;
            End;
          ButtonUnitQueue :
            Begin
            End;
          ButtonEditorCommand :
            Begin
              Case EditorCommand of
                ECTerrain :
                  Begin
                  End;
                ECSelectUnit :
                  Begin
                  End;
                ECNextUnit :
                  Begin
                  End;
                ECPrevUnit :
                  Begin
                  End;
                ECPlaceUnit :
                  Begin
                  
                  End;
                ECRemoveUnit :
                  Begin
                  End;
                ECSelectClan :
                  Begin
                  End;
                ECNextClan :
                  Begin
                  End;
                ECPrevClan :
                  Begin
                  End;
                ECSmallTerrain :
                  Begin
                  End;
                ECNormalTerrain :
                  Begin
                  End;
                ECHugeTerrain :
                  Begin
                  End;
                ECSelectTerrain :
                  Begin
                  End;
                ECNextTerrain :
                  Begin
                  End;
                ECPrevTerrain :
                  Begin
                  End;
              End;
            End;
          ButtonEditorUnit :
            Begin
            End;
        End;
        Pressed:=False;
      End;
  End;

PROCEDURE TLOCPlay.CheckCallGameButtonByLeftMouse;
  Var Index : TGameButtonCount;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      Begin
        For Index:=Low(TGameButtonCount) to High(TGameButtonCount) do
          With GameButtons[Index] do
            If Used and Active and
               InRange(Input.MouseX,Input.MouseY,PosX1,PosY1,PosX2,PosY2) then
              Begin
                CallGameButtonLeftClick(Index);
              End;
      End;
  End;

PROCEDURE TLOCPlay.CheckCallGameButtonByRightMouse;
  Var Index : TGameButtonCount;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      Begin
        For Index:=Low(TGameButtonCount) to High(TGameButtonCount) do
          With GameButtons[Index] do
            If Used and Active and AllowRightClick and
               InRange(Input.MouseX,Input.MouseY,PosX1,PosY1,PosX2,PosY2) then
              Begin
                CallGameButtonRightClick(Index);
              End;
      End;
  End;

PROCEDURE TLOCPlay.CancelLeftMouseCommand;
  Begin
    With MyScreen do
      Begin
        LeftMouseStatus:=SNone;
      End;
  End;

PROCEDURE TLOCPlay.LeftMouseClick;
  Var X,Y,XS,YS : FastInt;
      UnitNum   : TUnitCount;
  Begin
    With MyScreen,MyUnits,MyWorld,MyUnitProcess do
      Begin
        CheckCallGameButtonByLeftMouse;
        //Unit in view map
        If InRange(Input.MouseX,Input.MouseY,
                   ViewPosXOS,ViewPosYOS,
                   ViewPosX2OS,ViewPosY2OS) then
          Begin
            GetRealMousePos(X,Y,XS,YS);
            UnitNum:=GetUnitOnMapPointClick(X,Y,XS,YS);
            If UnitNum<>0 then SendWaitCommandTarget(UnitNum)
            Else SendWaitCommand(X,Y,XS,YS);
          End
        Else//Unit in mini map
        If InRange(Input.MouseX,Input.MouseY,
                   MapViewPosXOS,MapViewPosYOS,
                   MapViewPosXOS+MapViewDivX,
                   MapViewPosYOS+MapViewDivY) then
          Begin
            X:=Input.MouseX-MapViewPosXOS+MapViewPosX;
            Y:=Input.MouseY-MapViewPosYOS+MapViewPosY;
            SendWaitCommandOnMiniMap(X,Y);
          End
      End;
  End;

PROCEDURE TLOCPlay.LeftMouseClickEditor;
  Var X,Y,XS,YS,I,J : FastInt;
  Begin
    With MyScreen,MyUnits,MyWorld,MyUnitProcess,MyEditor do
      Begin
        CheckCallGameButtonByLeftMouse;
        If InRange(Input.MouseX,Input.MouseY,
                   ViewPosXOS,ViewPosYOS,
                   ViewPosX2OS,ViewPosY2OS) then
          Begin
            Case CmdWaitForSelect of
              CmdPlaceUnit :
                Begin
                  GetRealMousePos(X,Y,XS,YS);
                  NewUnitAt(CurrentEditorClan,CurrentEditorUnit,X,Y);
                End;
              CmdPlaceSmallTerrain :
                Begin
                  GetRealMousePos(X,Y,XS,YS);
                  X:=(X div 2);
                  Y:=(Y div 2);
                  //X:=(X div 4)*2;
                  //Y:=(Y div 4)*2;
                  For I:=0 to PatternSmallSize do
                    For J:=0 to PatternSmallSize do
                      Begin
                        ClearTileAt(X+I,Y+J,CurrentEditorTerrain);
                        SetTile(X+I,Y+J,CurrentEditorTerrain,Random(16));
                      End;
                  UpDateTileAttr;
                  MyDraw.RefreshMiniMap(X,Y,
                                        X+PatternSmallSize,
                                        Y+PatternSmallSize);
                End;
              CmdPlaceNormalTerrain :
                Begin
                  GetRealMousePos(X,Y,XS,YS);
                  X:=(X div 2);
                  Y:=(Y div 2);
                  //X:=(X div 4)*2;
                  //Y:=(Y div 4)*2;
                  For I:=0 to PatternNormalSize do
                    For J:=0 to PatternNormalSize do
                      Begin
                        ClearTileAt(X+I,Y+J,CurrentEditorTerrain);
                        SetTile(X+I,Y+J,CurrentEditorTerrain,Random(16));
                      End;
                  UpDateTileAttr;
                  MyDraw.RefreshMiniMap(X,Y,
                                        X+PatternNormalSize,
                                        Y+PatternNormalSize);
                End;
              CmdPlaceHugeTerrain :
                Begin
                  GetRealMousePos(X,Y,XS,YS);
                  X:=(X div 2);
                  Y:=(Y div 2);
                  //X:=(X div 4)*2;
                  //Y:=(Y div 4)*2;
                  For I:=0 to PatternHugeSize do
                    For J:=0 to PatternHugeSize do
                      Begin
                        ClearTileAt(X+I,Y+J,CurrentEditorTerrain);
                        SetTile(X+I,Y+J,CurrentEditorTerrain,Random(16));
                      End;
                  UpDateTileAttr;
                  MyDraw.RefreshMiniMap(X,Y,
                                        X+PatternHugeSize,
                                        Y+PatternHugeSize);
                End;
            End;
          End;
      End;
  End;

PROCEDURE TLOCPlay.RightMouseClickEditor;
  Begin
    With MyScreen,MyUnits,MyWorld,MyUnitProcess do
      Begin
      End;
  End;

PROCEDURE TLOCPlay.RightMouseClick;
  Var X,Y,XS,YS : FastInt;
      UnitNum   : TUnitCount;
  Begin
    With MyScreen,MyUnits,MyWorld,MyUnitProcess do
      Begin
        If CmdWaitForSelect<>NoCmd then
          Begin
            Case CmdWaitForSelect of
              CmdBuild :
                Begin
                  GetGroupBuildSkill(CurrentSkillButton,MaxGroup,HumanControl,False,True)
                End;
              CmdPutItem :
                Begin
                  //Can't cancel switch because can drop item back ?
                  If Not UnitSwitchItem(UnitFocus,ItemSlotSelection,ItemWaitToPut) then
                    Begin
                      SendMessage(Format(MsgCanPutBackItem,[SlotName[ItemSlotSelection],
                                                            ItemClassName[ItemProperty[ItemWaitToPut.Typer].ItemClass]]));
                      Exit;
                    End
                  Else SetupUnitItemButtons(UnitFocus);
                End;
              Else GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
            CmdWaitForSelect:=NoCmd;
            UnitWaitForBuild:=NoneUnit;
            Exit;
          End;
        CheckCallGameButtonByRightMouse;
        //Cancel send command
        If InRange(Input.MouseX,Input.MouseY,
                   ViewPosXOS,ViewPosYOS,
                   ViewPosX2OS,ViewPosY2OS) then
          Begin
            GetRealMousePos(X,Y,XS,YS);
            UnitNum:=GetUnitOnMapPointClick(X,Y,XS,YS);
            If UnitNum=0 then
              Begin
                CrossAt(X,Y);
                SendGroupRightClickCommand(X,Y)
              End
            Else
              Begin
                ClickAtUnit(HumanControl,UnitNum);
                SendGroupRightClickCommand(UnitNum);
              End;
          End;
        If InRange(Input.MouseX,Input.MouseY,
                   MapViewPosXOS,MapViewPosYOS,
                   MapViewPosXOS+MapViewDivX,
                   MapViewPosYOS+MapViewDivY) then
          Begin
            X:=Input.MouseX-MapViewPosXOS+MapViewPosX;
            Y:=Input.MouseY-MapViewPosYOS+MapViewPosY;
            CrossAt(X,Y);
            SendGroupRightClickCommand(X,Y);
          End
      End;
  End;

PROCEDURE TLOCPlay.SendWaitCommandTarget(UnitTarget : TUnitCount);
  Begin
    With MyScreen,MyWorld,MyUnits,MyUnitProcess do
      Begin
        Case CmdWaitForSelect of
          CmdMove,CmdPatrol :
            Begin
              If UnitFocus<>0 then
                Begin
                  //Unit target is item store and unit focus has a item slot, set command to pick up item
                  If (Units[UnitTarget]._UnitTyper=ItemStore) then
                    Begin
                      UnitCommandPickUpItem(UnitFocus,UnitTarget,HumanControl);
                    End
                  Else
                    Begin
                      SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,
                                      Units[UnitTarget]._UnitPos.X,Units[UnitTarget]._UnitPos.Y,HumanControl);
                    End;
                End
              Else
                Begin
                  SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,
                                  Units[UnitTarget]._UnitPos.X,Units[UnitTarget]._UnitPos.Y,HumanControl);
                End;
              ClickAtUnit(HumanControl,UnitTarget);
              CmdWaitForSelect:=NoCmd;
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
          CmdAttack :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,UnitTarget,HumanControl);
              ClickAtUnit(HumanControl,UnitTarget);
              CmdWaitForSelect:=NoCmd;
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
          CmdHarvest :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,UnitTarget,HumanControl);
              ClickAtUnit(HumanControl,UnitTarget);
              CmdWaitForSelect:=NoCmd;
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
          CmdCastSpell :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],SpellWaitForSelect,UnitTarget,HumanControl);
              ClickAtUnit(HumanControl,UnitTarget);
              CmdWaitForSelect:=NoCmd;
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
          CmdPutItem :
            Begin
              //Get back item to unit slot
              With Units[UnitFocus] do
                _UnitItems[ItemSlotSelection]:=ItemWaitToPut;
              //Set unit command to put item command
              UnitCommandPutItem(UnitFocus,UnitTarget,ItemSlotSelection,HumanControl);
              //Shown unit click at
              ClickAtUnit(HumanControl,UnitTarget);
              //Reset command waiting and item button command
              CmdWaitForSelect:=NoCmd;
              SetupUnitItemButtons(UnitFocus);
            End;
          CmdUnLoadUnit :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,UnitTarget,HumanControl);
              CmdWaitForSelect:=NoCmd;
              ClickAtUnit(HumanControl,UnitTarget);
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
        End;
      End;
  End;

PROCEDURE TLOCPlay.SendWaitCommand(X,Y,XS,YS : FastInt);
  Var UnitNum : TUnitCount;
  Begin
    With MyScreen,MyWorld,MyUnits,MyUnitProcess do
      Begin
        Case CmdWaitForSelect of
          CmdMove,CmdPatrol :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,X,Y,HumanControl);
              CrossAt(X,Y);
              CmdWaitForSelect:=NoCmd;
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
          CmdAttack :
            Begin
              UnitNum:=GetUnitOnMapPointClick(X,Y,XS,YS);
              If UnitNum<>0 then
                Begin
                  SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,UnitNum,HumanControl);
                  ClickAtUnit(HumanControl,UnitNum);
                  CmdWaitForSelect:=NoCmd;
                  GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                End
              Else//Attack target ?
                Begin
                  SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,X,Y,HumanControl);
                  CrossAt(X,Y);
                  CmdWaitForSelect:=NoCmd;
                  GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                End;
            End;
          CmdHarvest :
            Begin
              UnitNum:=GetUnitOnMapPointClick(X,Y,XS,YS);
              If UnitNum<>0 then
                Begin
                  SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,UnitNum,HumanControl);
                  ClickAtUnit(HumanControl,UnitNum);
                  CmdWaitForSelect:=NoCmd;
                  GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                End
            End;
          CmdBuild :
            Begin
              UnitNum:=GetUnitCanBuild(SaveGroups[MaxGroup],HumanControl,UnitWaitForBuild);
              If UnitNum<>-1 then
                Begin
                  If TestTyperUnitPos(HumanControl,UnitWaitForBuild,
                                      HeadWaitForBuild,X,Y)<>PlaceOk then
                    Begin
                      SendMessage(CanNotPlaceBuildingHere);
                    End
                  Else
                    Begin
                      UnitCommandBuild(UnitNum,UnitWaitForBuild,HeadWaitForBuild,X,Y,HumanControl);
                      //If left or right shift holding, this the queue building command !
                      If (Not (Input.KeyDown(Key_LShift) or Input.KeyDown(Key_RShift))) or
                         (GetUnitCanBuild(SaveGroups[MaxGroup],HumanControl,UnitWaitForBuild)<=0) then
                        Begin
                          CmdWaitForSelect:=NoCmd;
                          UnitWaitForBuild:=NoneUnit;
                          GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                        End;
                    End;
                End;
            End;
          CmdCastSpell :
            Begin
              UnitNum:=GetUnitOnMapPointClick(X,Y,XS,YS);
              If UnitNum<>0 then
              //Set cast spell to specific unit ?
                Begin
                  //Send group command cast spell
                  SetGroupCommand(SaveGroups[MaxGroup],SpellWaitForSelect,UnitNum,HumanControl);
                  //Shown unit clicking
                  ClickAtUnit(HumanControl,UnitNum);
                  //Reset waiting command and skill button
                  CmdWaitForSelect:=NoCmd;
                  GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                End
              Else
              //Set cast spell to area ?
                Begin
                  //Send group command cast spell
                  SetGroupCommand(SaveGroups[MaxGroup],SpellWaitForSelect,X,Y,HumanControl);
                  CrossAt(X,Y);
                  //Reset waiting command and skill button
                  CmdWaitForSelect:=NoCmd;
                  GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                End;
            End;
          CmdPutItem :
            Begin
              UnitNum:=GetUnitOnMapPointClick(X,Y,XS,YS);
              If UnitNum<>0 then
              //Set put item to specific unit ?
                Begin
                  //Get back item to unit slot
                  With Units[UnitFocus] do
                    _UnitItems[ItemSlotSelection]:=ItemWaitToPut;
                  //Set unit command to put item command
                  UnitCommandPutItem(UnitFocus,UnitNum,ItemSlotSelection,HumanControl);
                  //Shown unit click at
                  ClickAtUnit(HumanControl,UnitNum);
                  //Reset command waiting and item button command
                  CmdWaitForSelect:=NoCmd;
                  SetupUnitItemButtons(UnitFocus);
                End
              Else
              //Set cast spell to area ?
                Begin
                  //Get back item to unit slot
                  With Units[UnitFocus] do
                    _UnitItems[ItemSlotSelection]:=ItemWaitToPut;
                  //Set unit command to put item command
                  UnitCommandPutItem(UnitFocus,X,Y,ItemSlotSelection,HumanControl);
                  //Shown unit click at
                  CrossAt(X,Y);
                  //Reset command waiting and item button command
                  CmdWaitForSelect:=NoCmd;
                  SetupUnitItemButtons(UnitFocus);
                End;
            End;
          CmdUnLoadUnit :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,X,Y,HumanControl);
              CmdWaitForSelect:=NoCmd;
              CrossAt(X,Y);
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
        End;
      End;
  End;

PROCEDURE TLOCPlay.SendWaitCommandOnMiniMap(X,Y : FastInt);
  Begin
    With MyScreen,MyWorld,MyUnits,MyUnitProcess do
      Begin
        Case CmdWaitForSelect of
          CmdMove,CmdAttack,CmdPatrol :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,X,Y,HumanControl);
              CrossAt(X,Y);
              CmdWaitForSelect:=NoCmd;
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
          CmdUnLoadUnit :
            Begin
              SetGroupCommand(SaveGroups[MaxGroup],CmdWaitForSelect,X,Y,HumanControl);
              CmdWaitForSelect:=NoCmd;
              CrossAt(X,Y);
              GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            End;
          Else
            Begin
              SetMapView(X-DefaultMapViewX div 2,
                         Y-DefaultMapViewY div 2);
            End;
        End;
      End;
  End;

PROCEDURE TLOCPlay.SendHotKey(SkillUse : TUnitSkill);
  Begin
    With MyScreen,MyUnits,MyWorld do
      Case SkillUse.Skill of
        CmdStop :
          Begin
            SetGroupCommand(SaveGroups[MaxGroup],CmdStop,0,0,HumanControl);
          End;
        CmdHoldPosition :
          Begin
            SetGroupCommand(SaveGroups[MaxGroup],CmdHoldPosition,0,0,HumanControl);
          End;
        CmdMove,CmdPatrol,CmdAttack,CmdHarvest,CmdUnLoadUnit :
          Begin
            CmdWaitForSelect:=SkillUse.Skill;
            SetGroupSkillTo(CurrentSkillButton,CmdCancel,NoneUnit);
          End;
        CmdBuildingHuman,CmdBuildingOrc,CmdBuildingDevil :
          Begin
            GetGroupBuildSkill(CurrentSkillButton,MaxGroup,HumanControl,False,True);
          End;
        CmdBuild :
          Begin
            If CheckUnitIsBuilding(HumanControl,SkillUse.UnitToBorn) then
              Begin
                CmdWaitForSelect:=CmdBuild;
                UnitWaitForBuild:=SkillUse.UnitToBorn;
                HeadWaitForBuild:=GetRandomHeading;
                //HeadWaitForBuild:=H2;
                SetGroupSkillTo(CurrentSkillButton,CmdCancel,NoneUnit);
              End
            Else
              Begin
                SetGroupCommand(SaveGroups[MaxGroup],SkillUse.UnitToBorn,HumanControl);
                SetupGroupSelected(MaxGroup);
              End;
          End;
        CmdCastSpell :
          Begin
            If CheckSpellAttribute(SkillUse.SpellToCast,SpellDirective) then
              Begin
                SetGroupCommand(SaveGroups[MaxGroup],SkillUse.SpellToCast,HumanControl);
              End
            Else
              Begin
                CmdWaitForSelect:=SkillUse.Skill;
                SpellWaitForSelect:=SkillUse.SpellToCast;
                SetGroupSkillTo(CurrentSkillButton,CmdCancel,NoneUnit);
              End;
          End;
        CmdCancelBuilding :
          Begin
            //On MyWorld class ? Yeah !!!!
            SetGroupCommandCancelBuilding(SaveGroups[MaxGroup],HumanControl);
          End;
        CmdCancel :
          Begin
            If CmdWaitForSelect=CmdBuild then
              GetGroupBuildSkill(CurrentSkillButton,MaxGroup,HumanControl,False,True)
            Else GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            CmdWaitForSelect:=NoCmd;
            UnitWaitForBuild:=NoneUnit;
          End;
      End;
  End;

PROCEDURE TLOCPlay.InsertCommandLine(C : Char);
  Begin
    With MyScreen do
      If Length(CommandLine)<CommandLineLengthMax then
        CommandLine:=CommandLine+C;
  End;

PROCEDURE TLOCPlay.DeleteCommandLine;
  Begin
    With MyScreen do
      If Length(CommandLine)>0 then
        Delete(CommandLine,Length(CommandLine),1);
  End;

FUNCTION  TLOCPlay.CheckCommandLine : Boolean;
  {$IfDef Debug}
  Var DTemp : TDebugStatus;
  {$EndIf}
  Var Code,Value : Integer;
      CTemp      : TCheatStatus;
      Tmp        : String;
  Begin
    Result:=True;
    With MyScreen,MyDraw,MyWorld do
      Begin
        Tmp:=CommandLine;
        StrippedAllSpaceAndUpCase(Tmp);
        {$IfDef Debug}
        For DTemp:=Low(TDebugStatus) to High(TDebugStatus) do
          If Tmp=DebugToggle[DTemp] then
            Begin
              DebugStatus[DTemp]:=Not DebugStatus[DTemp];
              Exit;
            End;
        If Tmp='CLEARINFO' then
          Begin
            FillChar(DebugStatus,SizeOf(DebugStatus),False);
            Exit;
          End;
        {$EndIf}
        //Cheats
        For CTemp:=Low(TCheatStatus) to High(TCheatStatus) do
          If Tmp=CheatToggle[CTemp] then
            Begin
              CheatStatus[CTemp]:=Not CheatStatus[CTemp];
              If CheatStatus[OnScreen] then OpenWorldMapVisited;
              If CheatStatus[NoFog] then OpenWorldFog;
              Exit;
            End;
        //Quit by command line
        If Tmp='EXIT' then
          Begin
            EndGame:=True;
            Exit;
          End;
        If Tmp='QUIT' then
          Begin
            EndGame:=True;
            Exit;
          End;
        //Setting draw method
        If Tmp='UNITSELECTSQUARE' then
          Begin
            UnitSelectStyle:=Square;
            Exit;
          End;
        If Tmp='UNITSELECTELLIPSE' then
          Begin
            UnitSelectStyle:=Ellipse;
            Exit;
          End;
        If Tmp='MOUSESELECTRECT' then
          Begin
            MouseSelectStyle:=Rect;
            Exit;
          End;
        If Tmp='MOUSESELECTALPHARECT' then
          Begin
            MouseSelectStyle:=ALphaRect;
            Exit;
          End;
        If Tmp='MINIMAPPIXEL' then
          Begin
            MiniMapStyle:=ShowPixel;
            Exit;
          End;
        If Tmp='MINIMAPRECT' then
          Begin
            MiniMapStyle:=ShowRect;
            Exit;
          End;
        If System.Pos('ASTARSTEP',Tmp)=1 then
          Begin
            Delete(Tmp,1,Length('ASTARSTEP'));
            Val(Tmp,Value,Code);
            If Code=0 then DefaultMaxStep:=Value;
            SendMessage(Format('%d',[DefaultMaxStep]));
            Exit;
          End;
        If System.Pos('SETTIME',Tmp)=1 then
          Begin
            Delete(Tmp,1,Length('SETTIME'));
            Val(Tmp,Value,Code);
            If Code=0 then
              Begin
                CurrentMinute:=Value mod MinutePerDay;
                GetDayTime;
              End;
            Exit;
          End;
      End;
    Result:=False;
  End;

PROCEDURE TLOCPlay.SendCommandLine;
  Begin
    With MyScreen,MyUnits,MyPlayer do
      Begin
        If CheckCommandLine=False then
          PlayerSay(HumanControl,CommandLine);
        CmdLineEnter:=False;
        CommandLine:='';
      End;
  End;

PROCEDURE TLOCPlay.GetCommandLine;
  Begin
    With MyScreen do
      Begin
        If Input.MouseHoldL then MouseLeftHolding
        Else
        If Input.MouseHoldR then MouseRightHolding
        Else
          Begin
            //GetPlayerMouseControl;
            //MiniMapControl;
            //GetPlayerCommonControl;
            If Input.KeyPress(Key_1) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('!')
              Else InsertCommandLine('1');
            If Input.KeyPress(Key_2) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('@')
              Else InsertCommandLine('2');
            If Input.KeyPress(Key_3) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('#')
              Else InsertCommandLine('3');
            If Input.KeyPress(Key_4) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('$')
              Else InsertCommandLine('4');
            If Input.KeyPress(Key_5) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('%')
              Else InsertCommandLine('5');
            If Input.KeyPress(Key_6) then 
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('^')
              Else InsertCommandLine('6');
            If Input.KeyPress(Key_7) then 
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('&')
              Else InsertCommandLine('7');
            If Input.KeyPress(Key_8) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('*')
              Else InsertCommandLine('8');
            If Input.KeyPress(Key_9) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('(')
              Else InsertCommandLine('9');
            If Input.KeyPress(Key_0) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine(')')
              Else InsertCommandLine('0');
            If Input.KeyPress(Key_Minus) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('_')
              Else InsertCommandLine('-');
            If Input.KeyPress(Key_Equals) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('+')
              Else InsertCommandLine('=');
            If Input.KeyPress(Key_Q) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('Q')
              Else InsertCommandLine('q');
            If Input.KeyPress(Key_W) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('W')
              Else InsertCommandLine('w');
            If Input.KeyPress(Key_E) then 
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('E')
              Else InsertCommandLine('e');
            If Input.KeyPress(Key_R) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('R')
              Else InsertCommandLine('r');
            If Input.KeyPress(Key_T) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('T')
              Else InsertCommandLine('t');
            If Input.KeyPress(Key_Y) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('Y')
              Else InsertCommandLine('y');
            If Input.KeyPress(Key_U) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('U')
              Else InsertCommandLine('u');
            If Input.KeyPress(Key_I) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('I')
              Else InsertCommandLine('i');
            If Input.KeyPress(Key_O) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('O')
              Else InsertCommandLine('o');
            If Input.KeyPress(Key_P) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('P')
              Else InsertCommandLine('p');
            If Input.KeyPress(Key_LBracket) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('{')
              Else InsertCommandLine('[');
            If Input.KeyPress(Key_RBracket) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('}')
              Else InsertCommandLine(']');
            If Input.KeyPress(Key_A) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('A')
              Else InsertCommandLine('a');
            If Input.KeyPress(Key_S) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('S')
              Else InsertCommandLine('s');
            If Input.KeyPress(Key_D) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('D')
              Else InsertCommandLine('d');
            If Input.KeyPress(Key_F) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('F')
              Else InsertCommandLine('f');
            If Input.KeyPress(Key_G) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('G')
              Else InsertCommandLine('g');
            If Input.KeyPress(Key_H) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('H')
              Else InsertCommandLine('h');
            If Input.KeyPress(Key_J) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('J')
              Else InsertCommandLine('j');
            If Input.KeyPress(Key_K) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('K')
              Else InsertCommandLine('k');
            If Input.KeyPress(Key_L) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('L')
              Else InsertCommandLine('l');
            If Input.KeyPress(Key_SemiColon) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine(':')
              Else InsertCommandLine(';');
            If Input.KeyPress(Key_Apostrophe) then 
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('''')
              Else InsertCommandLine('"');
            If Input.KeyPress(Key_Grave) then 
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('`')
              Else InsertCommandLine('~');
            If Input.KeyPress(Key_BackSlash) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('\')
              Else InsertCommandLine('|');
            If Input.KeyPress(Key_Z) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('Z')
              Else InsertCommandLine('z');
            If Input.KeyPress(Key_X) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('X')
              Else InsertCommandLine('x');
            If Input.KeyPress(Key_C) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('C')
              Else InsertCommandLine('c');
            If Input.KeyPress(Key_V) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('V')
              Else InsertCommandLine('v');
            If Input.KeyPress(Key_B) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('B')
              Else InsertCommandLine('b');
            If Input.KeyPress(Key_N) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('N')
              Else InsertCommandLine('n');
            If Input.KeyPress(Key_M) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('M')
              Else InsertCommandLine('m');
            If Input.KeyPress(Key_Comma) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('<')
              Else InsertCommandLine(',');
            If Input.KeyPress(Key_Period) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('>')
              Else InsertCommandLine('.');
            If Input.KeyPress(Key_Slash) then
              If Input.KeyDown(Key_LShift) or
                 Input.KeyDown(Key_RShift) then InsertCommandLine('?')
              Else InsertCommandLine('/');
            If Input.KeyPress(Key_Space) then InsertCommandLine(' ');
            If Input.KeyPress(Key_Back) then DeleteCommandLine;
            If Input.KeyPress(Key_Return) then SendCommandLine;
            If Input.KeyPress(Key_Escape) then
              Begin
                CommandLine:='';
                CmdLineEnter:=False;
              End;
          End;
      End;
  End;

PROCEDURE TLOCPlay.CheckMouseLeftHolding;
  Begin
    CheckMouseLeftHoldInGameButton;
  End;

PROCEDURE TLOCPlay.CheckMouseRightHolding;
  Begin
    CheckMouseRightHoldInGameButton;
  End;

PROCEDURE TLOCPlay.CheckMouseLeftHoldingEditor;
  Begin
    CheckMouseLeftHoldInGameButton;
  End;

PROCEDURE TLOCPlay.CheckMouseRightHoldingEditor;
  Begin
    CheckMouseRightHoldInGameButton;
  End;

PROCEDURE TLOCPlay.CheckMouseLeftHoldInGameButton;
  Var Index : TGameButtonCount;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      Begin
        For Index:=Low(TGameButtonCount) to High(TGameButtonCount) do
          With GameButtons[Index] do
            Begin
              If Not Active then Continue;
              If Not Pressed then
                Pressed:=InRange(Input.MouseX,Input.MouseY,PosX1,PosY1,PosX2,PosY2);
            End;
      End;
  End;

PROCEDURE TLOCPlay.CheckMouseRightHoldInGameButton;
  Var Index : TGameButtonCount;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      Begin
        For Index:=Low(TGameButtonCount) to High(TGameButtonCount) do
          With GameButtons[Index] do
            Begin
              If CmdWaitForSelect<>NoCmd then Continue;
              If Not Active then Continue;
              If Not AllowRightClick then Continue;
              If Not Pressed then
                Pressed:=InRange(Input.MouseX,Input.MouseY,PosX1,PosY1,PosX2,PosY2);
            End;
      End;
  End;

PROCEDURE TLOCPlay.CheckMousePosition;
  Var Index : TGameButtonCount;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      Begin
        MouseInButton:=False;
        For Index:=Low(TGameButtonCount) to High(TGameButtonCount) do
          With GameButtons[Index] do
            Begin
              If Pressed then
                Begin
                  MouseInButton:=False;
                  OldRange:=High(TGameButtonCount);
                  Exit;
                End;
              If Used and InRange(Input.MouseX,Input.MouseY,PosX1,PosY1,PosX2,PosY2) then
                Begin
                  ButtonInRange:=Index;
                  MouseInButton:=True;
                  MouseIn:=MIGameButton;
                  UpDateToolTip:=True;
                  If ButtonInRange<>OldRange then
                    Begin
                      //Restart tooltip fading
                      {$IfDef ToolTipFade}
                      ToolTipFade:=ToolTipFadeStart;
                      {$EndIf}
                      OldRange:=ButtonInRange;
                    End;
                  Exit;
                End;
            End;
        OldRange:=High(TGameButtonCount);
      End;
  End;

PROCEDURE TLOCPlay.MouseLeftHolding;
  Begin
    With MyScreen,MyUnits,MyWorld do
      Begin
        GetPlayerCommonControl;
        If LeftMouseStatus=SSelection then
          Begin
            SelectEnd.X:=Input.MouseX;
            SelectEnd.Y:=Input.MouseY;
            ReduceToRange(SelectEnd.X,ViewPosXOS,ViewPosX2OS);
            ReduceToRange(SelectEnd.Y,ViewPosYOS,ViewPosY2OS);
          End
        Else
          Begin
            //Mouse in mini map and not wait for command set
            CheckMouseLeftHolding;
            If InRange(Input.MouseX,Input.MouseY,
                       MapViewPosXOS,MapViewPosYOS,
                       MapViewPosXOS+MapViewDivX,
                       MapViewPosYOS+MapViewDivY) and
               (CmdWaitForSelect=NoCmd) then
              Begin
                SetMapView(Input.MouseX-MapViewPosXOS+MapViewPosX-DefaultMapViewX div 2,
                           Input.MouseY-MapViewPosYOS+MapViewPosY-DefaultMapViewY div 2);
              End
            Else
            //If mouse in view map then set mouse to selection status
            If InRange(Input.MouseX,Input.MouseY,
                       ViewPosXOS,ViewPosYOS,
                       ViewPosX2OS,ViewPosY2OS) then
              Begin
                If CmdWaitForSelect<>NoCmd then //LeftMouseClick
                Else
                  Begin
                    LeftMouseStatus:=SSelection;
                    SelectStart.X:=Input.MouseX;
                    SelectStart.Y:=Input.MouseY;
                    SelectEnd:=SelectStart;
                  End;
              End
            Else
            //Mouse in button bar
              Begin
              End;
          End;
      End
  End;

PROCEDURE TLOCPlay.MouseRightHolding;
  Begin
    CheckMouseRightHolding;
  End;

PROCEDURE TLOCPlay.GetPlayerMouseControl;
  Begin
    With MyScreen,MyUnits,MyWorld,MyUnitProcess do
      Begin
        //If mouse status = end selection then I select all unit in mouse rect
        If LeftMouseStatus=SSelection then
          Begin
            LeftMouseStatus:=SNone;
            If (SelectStart.X=SelectEnd.X) and
               (SelectStart.Y=SelectEnd.Y) then
              Begin
                If Input.KeyDown(Key_LControl) or
                   Input.KeyDown(Key_RControl) then
                  Begin
                    UnSelectUnitClick(True);
                  End
                Else SelectUnitClick(Input.KeyDown(Key_LShift) or
                                     Input.KeyDown(Key_RShift));
              End
            Else
              Begin
                SelectUnitByMouse(Input.KeyDown(Key_LShift) or
                                  Input.KeyDown(Key_LControl),
                                  Input.KeyDown(Key_LAlt))
              End;
          End;
        //Mouse right release
        If Input.MouseReleasedR then
          Begin
            If LeftMouseStatus<>SNone then
              CancelLeftMouseCommand
            Else RightMouseClick;
          End;
      End;
  End;

PROCEDURE TLOCPlay.GetPlayerMouseControlEditor;
  Begin
    With MyScreen,MyUnits,MyWorld,MyUnitProcess do
      Begin
        //If mouse status = end selection then I select all unit in mouse rect
        If LeftMouseStatus=SSelection then
          Begin
            LeftMouseStatus:=SNone;
            If (SelectStart.X=SelectEnd.X) and
               (SelectStart.Y=SelectEnd.Y) then
              Begin
                If Input.KeyDown(Key_LControl) or
                   Input.KeyDown(Key_RControl) then
                  Begin
                    UnSelectUnitClick(True);
                  End
                Else SelectUnitClick(Input.KeyDown(Key_LShift) or
                                     Input.KeyDown(Key_RShift));
              End
            Else
              Begin
                SelectUnitByMouse(Input.KeyDown(Key_LShift) or
                                  Input.KeyDown(Key_LControl),
                                  Input.KeyDown(Key_LAlt))
              End;
          End;
        //Mouse right release
        If Input.MouseReleasedR then
          Begin
            If LeftMouseStatus<>SNone then
              CancelLeftMouseCommand
            Else RightMouseClickEditor;
          End;
      End;
  End;

PROCEDURE TLOCPlay.GetPlayerCommonControl;
  Var Z : TUnitCount;
  Begin
    With MyScreen,MyUnits,MyWorld do
      Begin
        If Input.KeyDown(Key_LAlt) then
          If Input.KeyPress(Key_X) then EndGame:=True;
        If Input.KeyDown(Key_LControl) then
          Begin
            If Input.KeyPress(Key_NumpadMinus) then SetScreenRate(ScreenTimeRate+3);
            If Input.KeyPress(Key_NumpadPlus) then SetScreenRate(ScreenTimeRate-3);
          End
        Else
          Begin
            If Input.KeyPress(Key_NumpadMinus) then SetUnitRate(UnitRate+1);
            If Input.KeyPress(Key_NumpadPlus) then SetUnitRate(UnitRate-1);
          End;
        If Input.KeyPress(Key_Delete) then SendCurrentGroupToDeath;
        {$IfDef Debug}
        If Input.KeyPress(Key_PgUp) then 
          For Z:=1 to MaxUnits do
            If Units[Z]._UnitHitPoint>0 then
              UnitCommandPatrol(Z,Random(MapSizeX),Random(MapSizeY),HumanControl);
        {$EndIf}
      End;
  End;

PROCEDURE TLOCPlay.MiniMapControl;
  Begin
    With MyScreen,MyUnits,MyWorld do
      Begin
        //Key Up,Down,Left,Right for control mapview
        If Input.KeyDown(Key_Up) then
          SetMapView(MapViewX,MapViewY-MapKeyScrollSpeed);
        If Input.KeyDown(Key_Down) then
          SetMapView(MapViewX,MapViewY+MapKeyScrollSpeed);
        If Input.KeyDown(Key_Left) then
          SetMapView(MapViewX-MapKeyScrollSpeed,MapViewY);
        If Input.KeyDown(Key_Right) then
          SetMapView(MapViewX+MapKeyScrollSpeed,MapViewY);
      End;
  End;

PROCEDURE TLOCPlay.GameButtonControl;
  Var Index : TGameButtonCount;
  Begin
    With MyScreen,MyUnits,MyWorld,MyMenu do
      Begin
        For Index:=Low(TGameButtonCount) to High(TGameButtonCount) do
          With GameButtons[Index] do
            If Used and Active then
              Begin
                If CmdLineEnter then
                  If Not CanPressWhenCmdInput then Continue;
                If HoldKey<>0 then
                  Begin
                    If Input.KeyDown(HoldKey) and
                       Input.KeyPress(HotKey) then
                      CallGameButtonLeftClick(Index);
                  End
                Else
                  Begin
                    If Input.KeyPress(HotKey) then
                      CallGameButtonLeftClick(Index);
                  End;
                If Input.KeyDown(HotKey) then
                  Begin
                    Pressed:=True;
                    Exit;
                  End;
              End;
      End;
  End;

PROCEDURE TLOCPlay.GameButtonControlOnly;
  Begin
    With MyScreen,MyUnits,MyWorld,MyMenu do
      Begin
        If Input.MouseHoldL then
          CheckMouseLeftHoldInGameButton
        Else
        If Input.MouseReleasedL then
          CheckCallGameButtonByLeftMouse;
        GameButtonControl;
      End;
  End;

PROCEDURE TLOCPlay.GroupingControl;
  Begin
    With MyScreen,MyUnits,MyWorld,MyMenu do
      Begin
        If Input.KeyDown(Key_LControl) or
           Input.KeyDown(Key_RControl) then
          Begin
            //Group saving control
            If Input.KeyPress(Key_1) then SaveGroup(1);
            If Input.KeyPress(Key_2) then SaveGroup(2);
            If Input.KeyPress(Key_3) then SaveGroup(3);
            If Input.KeyPress(Key_4) then SaveGroup(4);
            If Input.KeyPress(Key_5) then SaveGroup(5);
            If Input.KeyPress(Key_6) then SaveGroup(6);
            If Input.KeyPress(Key_7) then SaveGroup(7);
            If Input.KeyPress(Key_8) then SaveGroup(8);
            If Input.KeyPress(Key_9) then SaveGroup(9);
            If Input.KeyPress(Key_0) then SaveGroup(10);
          End
        Else
          Begin
            //Group loading control
            If Input.KeyPress(Key_1) then SelectGroup(1);
            If Input.KeyPress(Key_2) then SelectGroup(2);
            If Input.KeyPress(Key_3) then SelectGroup(3);
            If Input.KeyPress(Key_4) then SelectGroup(4);
            If Input.KeyPress(Key_5) then SelectGroup(5);
            If Input.KeyPress(Key_6) then SelectGroup(6);
            If Input.KeyPress(Key_7) then SelectGroup(7);
            If Input.KeyPress(Key_8) then SelectGroup(8);
            If Input.KeyPress(Key_9) then SelectGroup(9);
            If Input.KeyPress(Key_0) then SelectGroup(10);
          End;
      End;
  End;

PROCEDURE TLOCPlay.GetHotKeyInput;
  Begin
    With MyScreen,MyUnits,MyWorld,MyMenu do
      Begin
        If Input.KeyPress(Key_Return) then CmdLineEnter:=True;
        If Input.KeyPress(Key_Comma) then SelectFreeWorker;
        If Input.KeyPress(Key_Period) then SelectFreeTroop;
        If Input.KeyPress(Key_Slash) then SelectFreeBuilding;
      End;
  End;

PROCEDURE TLOCPlay.GetHotKeyInputEditor;
  Begin
    With MyScreen,MyUnits,MyWorld,MyMenu do
      Begin
        If Input.KeyPress(Key_Return) then CmdLineEnter:=True;
      End;
  End;

PROCEDURE TLOCPlay.GetPlayerInput;
  Begin
    With MyScreen,MyUnits,MyWorld,MyMenu do
      Begin
        If Input.MouseHoldL then MouseLeftHolding Else
        If Input.MouseHoldR then MouseRightHolding Else
        If Input.MouseReleasedL then LeftMouseClick
        Else
          Begin
            GetPlayerMouseControl;
            MiniMapControl;
            GetPlayerCommonControl;
            GameButtonControl;
            GroupingControl;
            If CmdLineEnter then GetCommandLine
            Else GetHotKeyInput;
          End;
        CheckMousePosition;
      End;
  End;

PROCEDURE TLOCPlay.CallSaveGameMenu;
  Begin
    //SaveWorld(DefaultQuickSavedName);
    MyMenu.SetupForSaveGameMenu;
  End;

PROCEDURE TLOCPlay.CallLoadGameMenu;
  Begin
    MyMenu.SetupForLoadGameMenu;
    ///LoadWorld(DefaultQuickSavedName);
  End;

PROCEDURE TLOCPlay.GameMenuControl;
  Var Return : TMenuSelectResult;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      Begin
        Return:=MainMenuProcess(False,False);
        Case Return of
          MenuOGReturnToGame :
            Begin
              //Off menu
              MenuActive:=False;
            End;
          MenuOGPauseGame :
            Begin
              //Toggle game pause mode
              GamePause:=Not GamePause;
            End;
          MenuOGSaveGame :
            Begin
              CallSaveGameMenu;
            End;
          MenuOGLoadGame :
            Begin
              CallLoadGameMenu;
            End;
          MenuOGQuitGame :
            Begin
              SetupForQuitGameMenu;
            End;
          MenuOGQuitGameToMainMenu :
            Begin
              //Off menu
              MenuActive:=False;
              //Quit current game
              EndGame:=True;
            End;
          MenuOGQuitGameToOS :
            Begin
              //Off menu
              MenuActive:=False;
              //Quit current game
              EndGame:=True;
              //Quit game
              QuitGame:=True;
            End;
          MenuOGQuitGameCancel :
            Begin
              CallOnGameMenu;
            End;
          MenuOGSaveSlot1..MenuOGSaveSlot8 :
            Begin
              SaveSlot(Return);
            End;
          MenuOGLoadSlot1..MenuOGLoadSlot8 :
            Begin
              LoadSlot(Return);
            End;
        End;
      End;
  End;

PROCEDURE TLOCPlay.ProcessInput;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      If GameTime-InputUpdateSavedTime>InputTimeRate then
        Begin
          InputUpdateSavedTime:=GameTime;
          Input.GetState;
          UnPressedAllButton;
          //Check events on game window
          If Screen.DoEvents=False then EndGame:=True;
          //If menu active, I must check input for control menu
          If MenuActive then GameMenuControl
          //Else check input for game control
          Else
          If Not AllowPlayerInput then
            Begin
              GameButtonControlOnly;
            End
          Else
            Begin
              GetPlayerInput;
            End;
        End;
  End;

PROCEDURE TLOCPlay.ProcessUnits;
  Var UIdx : TUnitCount;
      MIdx : TMissileCount;
      EIdx : TEffectedCount;
  Begin
    With MyScreen,MyUnits do
      Begin
        If Not AllowUnitAction then Exit;
        If GameTime-UnitUpdateSavedTime>UnitRate then
          Begin
            If GamePause then Exit;
            UnitUpdateSavedTime:=GameTime;
            Inc(GameFrame);
            IsBuildFrame:=GameFrame mod FrameBuildRate=0;
            IsManaGrowFrame:=GameFrame mod FrameManaGrowRate=0;
            IsHitpointGrowFrame:=GameFrame mod FrameHitpointGrowRate=0;
            IsFindTargetFrame:=GameFrame mod FrameFindTargetRate=0;
            IsChangeHeadingFrame:=GameFrame mod FrameChangeHeadingRate=0;
            IsTimeUpFrame:=GameFrame mod FrameTimeGrowRate=0;
            If IsTimeUpFrame then GetDayTime;
            //Updated mouse clicking
            If ClanInfo[HumanControl].UnitClick<>0 then
              Begin
                If ClanInfo[HumanControl].ClickCount<30 then
                  Inc(ClanInfo[HumanControl].ClickCount)
                Else ClanInfo[HumanControl].UnitClick:=0;
              End;
            //Action all unit !
            For UIdx:=Low(Units) to High(Units) do
              If Units[UIdx]._UnitHitPoint>=0 then MyUnitProcess.UnitAction(UIdx);
            //Action all missile !
            For MIdx:=Low(Missiles) to High(Missiles) do
              If Missiles[MIdx].Typer<>MissileNone then MyUnitProcess.MissileAction(MIdx);
            //Action all effect ? If this time to counting effect ?
            For EIdx:=Low(Effects) to High(Effects) do
              If Effects[EIdx].Typer<>NoEffected then MyUnitProcess.EffectAction(EIdx);
          End;
      End;
  End;

PROCEDURE TLOCPlay.ProcessEvents;
  Begin
    With MyScreen,MyWorld,MyScript do
      Begin
        GameTime:=TimeGetTime;
        If GamePause then Exit;
        //Update message board
        If GameTime-MsgBoardUpdateSavedTime>MessageBoardTimeRate then
          Begin
            ProcessMessageBoard;
            MsgBoardUpdateSavedTime:=GameTime;
          End;
        //Update game fog !
        If GameTime-FogUpdateSavedTime>FogUpdateTimeRate then
          Begin
            UpdateWorldFog;
            FogUpdateSavedTime:=GameTime;
          End;
        If GameTime-WaterUpDateSavedTime>WaterUpDateTimeRate then
          Begin
            If WaterFrame<MaxWaterFrame then Inc(WaterFrame) Else WaterFrame:=0;
            WaterUpDateSavedTime:=GameTime;
            WaterUpDate;
          End;
        If GameResult<>NoResult then
          Begin
            EndGameResult:=GameResult;
            GameResult:=NoResult;
            Case EndGameResult of
              Victory :
                Begin
                  CallVictoryMenu;
                End;
              QuitByMenu :
                Begin
                  EndGame:=True;
                End;
              Surrender :
                Begin
                  EndGame:=True;
                End;
              RestartGame :
                Begin
                End;
              Lost :
                Begin
                End;
            End;
          End;
      End;
  End;

PROCEDURE TLOCPlay.ProcessScreen;
  Begin
    MyDraw.DrawScreen;
  End;

PROCEDURE TLOCPlay.PlayGame;
  Begin
    With MyScreen do
      Begin
        //Reset some data
        AllowUnitAction:=True;
        AllowPlayerInput:=True;
        EndGame:=False;
        CmdWaitForSelect:=NoCmd;
        GameResult:=NoResult;
        EndGameResult:=NoResult;
        RestartButtons;
        SetupButtonMenu;
        SetupButtonDiplomacy;
        SetupButtonPause;
        //AI player prepare for play
        MyAIPlayer.AIPlayerPrepare;
        //
        {$IfDef TestOnScreen}
        CheatStatus[OnScreen]:=False;
        CheatStatus[NoFog]:=True;
        MyWorld.OpenWorldMapVisited;
        MyWorld.OpenWorldFog;
        {$EndIf}
        //Prepare for run script ?
        MyScript.PrepareRun;
        Repeat
          //Get network info
          MyNetwork.ProcessNetwork;
          //My turn ?
          Self.ProcessInput;
          //Ready for next frame huh ?
          If ReadyForNextFrame then
            Begin
              //Now AI turn ?
              If Not GamePause then
                MyAIPlayer.AIPlayerRun;
              //Script runing ?
              If Not GamePause then
                MyScript.ScriptRun;
              //Process all units ?
              Self.ProcessUnits;
              //Process concurrent events ?
              Self.ProcessEvents;
              //Ready for next frame ?
              MyNetwork.ImReady;
            End;
          //Send info to screen ?
          Self.ProcessScreen;
        Until EndGame;
        MyScript.DoneRun;
      End;
  End;

PROCEDURE TLOCPlay.SetUnitRate(NewRate : FastInt);
  Begin
    If NewRate<MinUnitRate then UnitRate:=MinUnitRate Else
    If NewRate>MaxUnitRate then UnitRate:=MaxUnitRate Else UnitRate:=NewRate;
    MyScreen.SendMessage(Format('Now UnitTimeRate = %d !',[UnitRate]));
  End;

PROCEDURE TLOCPlay.SetScreenRate(NewRate : FastInt);
  Begin
    If NewRate<MinScreenTimeRate then ScreenTimeRate:=MinScreenTimeRate Else
    If NewRate>MaxScreenTimeRate then ScreenTimeRate:=MaxScreenTimeRate
    Else ScreenTimeRate:=NewRate;
    MyScreen.SendMessage(Format('Now ScreenTimeRate = %d !',[ScreenTimeRate]));
  End;

PROCEDURE TLOCPlay.SaveSlot(Return : TMenuSelectResult);
  Var Name : String;
  Begin
    Case Return of
      MenuOGSaveSlot1 : Name:='Save\Slot1.lms';
      MenuOGSaveSlot2 : Name:='Save\Slot2.lms';
      MenuOGSaveSlot3 : Name:='Save\Slot3.lms';
      MenuOGSaveSlot4 : Name:='Save\Slot4.lms';
      MenuOGSaveSlot5 : Name:='Save\Slot5.lms';
      MenuOGSaveSlot6 : Name:='Save\Slot6.lms';
      MenuOGSaveSlot7 : Name:='Save\Slot7.lms';
      MenuOGSaveSlot8 : Name:='Save\Slot8.lms';
    End;
    If Not SaveWorld(Name) then
      MyMenu.MessageBox('Failed to saved game !')
    Else MyMenu.MenuActive:=False;
  End;

PROCEDURE TLOCPlay.LoadSlot(Return : TMenuSelectResult);
  Var Name : String;
  Begin
    Case Return of
      MenuOGLoadSlot1 : Name:='Save\Slot1.lms';
      MenuOGLoadSlot2 : Name:='Save\Slot2.lms';
      MenuOGLoadSlot3 : Name:='Save\Slot3.lms';
      MenuOGLoadSlot4 : Name:='Save\Slot4.lms';
      MenuOGLoadSlot5 : Name:='Save\Slot5.lms';
      MenuOGLoadSlot6 : Name:='Save\Slot6.lms';
      MenuOGLoadSlot7 : Name:='Save\Slot7.lms';
      MenuOGLoadSlot8 : Name:='Save\Slot8.lms';
    End;
    If Not LoadWorld(Name) then
      MyMenu.MessageBox('Failed to load saved game !')
    Else MyMenu.MenuActive:=False;
  End;

FUNCTION  TLOCPlay.SaveWorld(FileName : String) : Boolean;
  Var Stream    : TStream;
  Begin
    Result:=False;
    //If Not FileExist(FileName) then Exit;
    Stream:=TFileStream.Create(FileName,FMCreate);
    If Stream=Nil then Exit;
    If MyEditor.InEditorMode then
      Begin
        //Restart before saved
        MyWorld.RestartWorldVisited;
      End;
    If Not MyScreen.SaveToStream(Stream) then Exit;
    If Not MyWorld.SaveToStream(Stream) then Exit;
    If Not MyUnits.SaveToStream(Stream) then Exit;
    Stream.Free;
    If MyEditor.InEditorMode then
      Begin
        //Open back to editor
        MyWorld.OpenWorldMapVisited;
        MyWorld.OpenWorldFog;
      End;
    Result:=True;
  End;

FUNCTION  TLOCPlay.LoadWorld(FileName : String) : Boolean;
  Var Stream   : TStream;
      {$IfNDef SavedMapNum}
      Index    : TUnitCount;
      {$EndIf}
  Begin
    Result:=False;
    If Not FileExist(FileName) then Exit;
    Stream:=TFileStream.Create(FileName,FMOpenRead);
    If Stream=Nil then Exit;
    If Not MyScreen.LoadFromStream(Stream) then Exit;
    If Not MyWorld.LoadFromStream(Stream) then Exit;
    If Not MyUnits.LoadFromStream(Stream) then Exit;
    Stream.Free;
    MyAIPlayer.AIRestartData;
    MyWorld.AdjustMapView;
    If MyEditor.InEditorMode=False then
      MyScreen.RestartData;
    With MyScreen,MyUnits,MyWorld do
      Begin
        SetMapView(MapViewX,MapViewY);
        {$IfNDef SavedMapNum}
        //Here must check for if unit on map we are take unit to map, else don't !
        For Index:=Low(Units) to High(Units) do
          If Units[Index]._UnitHitPoint>=0 then
            Begin
              If GetUnitAttribute(Index,UnitOnMapNum) then
                PutUnit(Index,GetUnitAttribute(Index,UnitTakeATile),True);
              AIAddUnitToForce(Units[Index]._UnitClan,UnitsProperty[Units[Index]._UnitClan,
                                                                    Units[Index]._UnitTyper].UnitForce,Index);
            End;
        {$EndIf}
        //Not load in editor mode ?
        If MyEditor.InEditorMode=False then
          Begin
            //Get group skill
            GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            //Set up unit button for group
            SetupGroupSelected(MaxGroup);
            //Prepare for AI player
            MyAIPlayer.AIPlayerPrepare;
          End
        Else
          Begin
            OpenWorldMapVisited;
            OpenWorldFog;
          End;
      End;
    MyDraw.RestartData;
    Result:=True;
  End;

PROCEDURE TLOCPlay.MouseLeftHoldingEditor;
  Begin
    With MyScreen,MyUnits,MyWorld do
      Begin
        GetPlayerCommonControl;
        If LeftMouseStatus=SSelection then
          Begin
            SelectEnd.X:=Input.MouseX;
            SelectEnd.Y:=Input.MouseY;
            ReduceToRange(SelectEnd.X,ViewPosXOS,ViewPosX2OS);
            ReduceToRange(SelectEnd.Y,ViewPosYOS,ViewPosY2OS);
          End
        Else
          Begin
            //Mouse in mini map and not wait for command set
            CheckMouseLeftHolding;
            //  When click on mini map, always change map view because in editor mode,
            //no one command can be active.
            If InRange(Input.MouseX,Input.MouseY,
                       MapViewPosXOS,MapViewPosYOS,
                       MapViewPosXOS+MapViewDivX,
                       MapViewPosYOS+MapViewDivY)then
              Begin
                SetMapView(Input.MouseX-MapViewPosXOS+MapViewPosX-DefaultMapViewX div 2,
                           Input.MouseY-MapViewPosYOS+MapViewPosY-DefaultMapViewY div 2);
              End
            Else
            //If mouse in view map then set mouse to selection status
            If InRange(Input.MouseX,Input.MouseY,
                       ViewPosXOS,ViewPosYOS,
                       ViewPosX2OS,ViewPosY2OS) then
              Begin
                If CmdWaitForSelect<>NoCmd then //LeftMouseClick
                Else
                  Begin
                    LeftMouseStatus:=SSelection;
                    SelectStart.X:=Input.MouseX;
                    SelectStart.Y:=Input.MouseY;
                    SelectEnd:=SelectStart;
                  End;
              End
            Else
            //Mouse in button bar
              Begin
              End;
          End;
      End
  End;

PROCEDURE TLOCPlay.MouseRightHoldingEditor;
  Begin
    CheckMouseRightHolding;
  End;

PROCEDURE TLOCPlay.GetEditorInput;
  Begin
    With MyScreen,MyUnits,MyWorld,MyMenu do
      Begin
        If Input.MouseHoldL then MouseLeftHoldingEditor Else
        If Input.MouseHoldR then MouseRightHoldingEditor Else
        If Input.MouseReleasedL then LeftMouseClickEditor
        Else
          Begin
            GetPlayerMouseControlEditor;
            MiniMapControl;
            GetPlayerCommonControl;
            GameButtonControl;
            GroupingControl;
            If CmdLineEnter then GetCommandLine
            Else GetHotKeyInputEditor;
          End;
        CheckMousePosition;
      End;
  End;

PROCEDURE TLOCPlay.ProcessEditorInput;
  Begin
    With MyScreen,MyWorld,MyUnits,MyMenu do
      If GameTime-InputUpdateSavedTime>InputTimeRate then
        Begin
          InputUpdateSavedTime:=GameTime;
          Input.GetState;
          UnPressedAllButton;
          //Check events on game window
          If Screen.DoEvents=False then EndGame:=True;
          //If menu active, I must check input for control menu
          If MenuActive then GameMenuControl
          //Else check input for game control
          Else GetEditorInput;
        End;
  End;

PROCEDURE TLOCPlay.ProcessEditorUnits;
  Var UIdx : TUnitCount;
      MIdx : TMissileCount;
      EIdx : TEffectedCount;
  Begin
    With MyScreen,MyUnits do
      Begin
        If Not AllowUnitAction then Exit;
        If GameTime-UnitUpdateSavedTime>UnitRate then
          Begin
            If GamePause then Exit;
            UnitUpdateSavedTime:=GameTime;
            Inc(GameFrame);
            IsBuildFrame:=GameFrame mod FrameBuildRate=0;
            IsManaGrowFrame:=GameFrame mod FrameManaGrowRate=0;
            IsHitpointGrowFrame:=GameFrame mod FrameHitpointGrowRate=0;
            IsFindTargetFrame:=GameFrame mod FrameFindTargetRate=0;
            IsChangeHeadingFrame:=GameFrame mod FrameChangeHeadingRate=0;
            IsTimeUpFrame:=GameFrame mod FrameTimeGrowRate=0;
            If IsTimeUpFrame then GetDayTime;
            //Updated mouse clicking
            If ClanInfo[HumanControl].UnitClick<>0 then
              Begin
                If ClanInfo[HumanControl].ClickCount<30 then
                  Inc(ClanInfo[HumanControl].ClickCount)
                Else ClanInfo[HumanControl].UnitClick:=0;
              End;
            //Action all unit !
            For UIdx:=Low(Units) to High(Units) do
              If Units[UIdx]._UnitHitPoint>=0 then MyUnitProcess.UnitIdleAction(UIdx);
            //Action all missile !
            For MIdx:=Low(Missiles) to High(Missiles) do
              If Missiles[MIdx].Typer<>MissileNone then MyUnitProcess.MissileAction(MIdx);
            //Action all effect ? If this time to counting effect ?
            For EIdx:=Low(Effects) to High(Effects) do
              If Effects[EIdx].Typer<>NoEffected then MyUnitProcess.EffectAction(EIdx);
          End;
      End;
  End;

PROCEDURE TLOCPlay.EditorGame;
  Begin
    EditorMap('');
  End;

PROCEDURE TLOCPlay.EditorMap(FileName : String);
  Begin
    With MyScreen do
      Begin
        //Reset some data
        AllowUnitAction:=True;
        AllowPlayerInput:=True;
        EndGame:=False;
        CmdWaitForSelect:=CmdPlaceUnit;
        HeadWaitForBuild:=MyUnits.GetRandomHeading;
        GameResult:=NoResult;
        EndGameResult:=NoResult;
        MyEditor.CurrentEditorClan:=MyUnits.HumanControl;
        MyEditor.CurrentEditorUnit:=Knight;
        MyEditor.CurrentEditorTerrain:=Low(TMapTile);
        MyEditor.CurrentEditorCommand:=ECNone;
        MyEditor.InEditorMode:=True;
        CheatStatus[OnScreen]:=False;
        CheatStatus[NoFog]:=True;
        MyWorld.OpenWorldMapVisited;
        MyWorld.OpenWorldFog;
        RestartButtons;
        SetupButtonMenu;
        MyEditor.AdjustViewSize;
        MyEditor.SetupEditorUnitButtons;
        Repeat
          Self.ProcessEditorInput;
          Self.ProcessEditorUnits;
          Self.ProcessEvents;
          Self.ProcessScreen;
        Until EndGame;
        MyEditor.InEditorMode:=False;
      End;
  End;
END.
