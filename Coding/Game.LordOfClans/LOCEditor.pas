UNIT LOCEditor;

INTERFACE

USES LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     AvenusCommon;

TYPE
  TLOCEditor = Class
    Public
    MyScreen      : TLOCScreen;
    MyShow        : TLOCShow;
    MyUnits       : TLOCUnits;
    MyWorld       : TLOCWorld;
    InEditorMode  : Boolean;
    //Editor data
    CurrentEditorClan  : TClan;
    CurrentEditorUnit  : TUnit;
    CurrentEditorTerrain : TMapTile;
    CurrentEditorCommand : TEditorCommand;
    //Editor button setting
    NextUnitPos,NextUnitSize,
    PrevUnitPos,PrevUnitSize,
    SelectUnitPos,SelectUnitSize,
    PlaceUnitPos,PlaceUnitSize,
    RemoveUnitPos,RemoveUnitSize,
    NextClanPos,NextClanSize,
    PrevClanPos,PrevClanSize,
    SelectClanPos,SelectClanSize,
    SmallTerrainPos,SmallTerrainSize,
    NormalTerrainPos,NormalTerrainSize,
    HugeTerrainPos,HugeTerrainSize,
    NextTerrainPos,NextTerrainSize,
    PrevTerrainPos,PrevTerrainSize,
    SelectTerrainPos,SelectTerrainSize
     : TPoint;
    Constructor Create(Screen : TLOCScreen;
                       Show : TLOCShow;
                       Units : TLOCUnits;
                       World : TLOCWorld);
    Destructor Destroy;OverRide;
    Procedure AdjustViewSize;
    Procedure SetupEditorUnitButtons;
    Procedure SetupEditorTerrainButtons;
    Procedure SelectNextUnit;
    Procedure SelectPrevUnit;
    Procedure SelectNextClan;
    Procedure SelectPrevClan;
    Procedure SelectNextTerrain;
    Procedure SelectPrevTerrain;
  End;

VAR
  GameEditor : TLOCEditor;

IMPLEMENTATION

CONSTRUCTOR TLOCEditor.Create(Screen : TLOCScreen;
                              Show : TLOCShow;
                              Units : TLOCUnits;
                              World : TLOCWorld);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    InEditorMode:=False;
  End;

DESTRUCTOR TLOCEditor.Destroy;
  Begin
  End;

PROCEDURE TLOCEditor.AdjustViewSize;
  Begin
    With MyScreen do
      Case VideoMode of
        M800x600 :
          Begin
            //Next unit button
            NextUnitPos.X:=104;
            NextUnitPos.Y:=192;
            NextUnitSize.X:=16;
            NextUnitSize.Y:=32;
            //Prev unit button
            PrevUnitPos.X:=008;
            PrevUnitPos.Y:=192;
            PrevUnitSize.X:=16;
            PrevUnitSize.Y:=32;
            //Select unit button
            SelectUnitPos.X:=40;
            SelectUnitPos.Y:=192;
            SelectUnitSize.X:=48;
            SelectUnitSize.Y:=32;
            //Place unit button
            PlaceUnitPos.X:=008;
            PlaceUnitPos.Y:=228;
            PlaceUnitSize.X:=64;
            PlaceUnitSize.Y:=32;
            //Remove unit button
            RemoveUnitPos.X:=080;
            RemoveUnitPos.Y:=228;
            RemoveUnitSize.X:=64;
            RemoveUnitSize.Y:=32;
            //Next clan button
            NextClanPos.X:=104;
            NextClanPos.Y:=264;
            NextClanSize.X:=16;
            NextClanSize.Y:=32;
            //Prev clan button
            PrevClanPos.X:=008;
            PrevClanPos.Y:=264;
            PrevClanSize.X:=16;
            PrevClanSize.Y:=32;
            //Select clan button
            SelectClanPos.X:=40;
            SelectClanPos.Y:=264;
            SelectClanSize.X:=48;
            SelectClanSize.Y:=32;
            //Small terrain button
            SmallTerrainPos.X:=008;
            SmallTerrainPos.Y:=300;
            SmallTerrainSize.X:=48;
            SmallTerrainSize.Y:=48;
            //Small terrain button
            NormalTerrainPos.X:=060;
            NormalTerrainPos.Y:=300;
            NormalTerrainSize.X:=48;
            NormalTerrainSize.Y:=48;
            //Small terrain button
            HugeTerrainPos.X:=112;
            HugeTerrainPos.Y:=300;
            HugeTerrainSize.X:=48;
            HugeTerrainSize.Y:=48;
            //Next Terrain button
            NextTerrainPos.X:=104;
            NextTerrainPos.Y:=352;
            NextTerrainSize.X:=16;
            NextTerrainSize.Y:=32;
            //Prev Terrain button
            PrevTerrainPos.X:=008;
            PrevTerrainPos.Y:=352;
            PrevTerrainSize.X:=16;
            PrevTerrainSize.Y:=32;
            //Select Terrain button
            SelectTerrainPos.X:=40;
            SelectTerrainPos.Y:=352;
            SelectTerrainSize.X:=48;
            SelectTerrainSize.Y:=32;
          End;
        M1024x768 :
          Begin
          End;
      End;
  End;

PROCEDURE TLOCEditor.SetupEditorUnitButtons;
  Begin
    With MyScreen do
      Begin
        NewButton(NextUnitPos.X,NextUnitPos.Y,
                  NextUnitPos.X+NextUnitSize.X,
                  NextUnitPos.Y+NextUnitSize.Y,
                  '>',0,Key_Period,True,False,
                  ButtonEditorCommand,
                  ECNextUnit);
        NewButton(PrevUnitPos.X,PrevUnitPos.Y,
                  PrevUnitPos.X+PrevUnitSize.X,
                  PrevUnitPos.Y+PrevUnitSize.Y,
                  '<',0,Key_Comma,True,False,
                  ButtonEditorCommand,
                  ECPrevUnit);
        NewButton(SelectUnitPos.X,SelectUnitPos.Y,
                  SelectUnitPos.X+SelectUnitSize.X,
                  SelectUnitPos.Y+SelectUnitSize.Y,
                  '',0,0,True,False,
                  ButtonEditorCommand,
                  ECSelectUnit);
        NewButton(PlaceUnitPos.X,PlaceUnitPos.Y,
                  PlaceUnitPos.X+PlaceUnitSize.X,
                  PlaceUnitPos.Y+PlaceUnitSize.Y,
                  'Place',0,0,True,False,
                  ButtonEditorCommand,
                  ECPlaceUnit);
        NewButton(RemoveUnitPos.X,RemoveUnitPos.Y,
                  RemoveUnitPos.X+RemoveUnitSize.X,
                  RemoveUnitPos.Y+RemoveUnitSize.Y,
                  'Remove',0,0,True,False,
                  ButtonEditorCommand,
                  ECRemoveUnit);
        NewButton(NextClanPos.X,NextClanPos.Y,
                  NextClanPos.X+NextClanSize.X,
                  NextClanPos.Y+NextClanSize.Y,
                  '>',0,Key_RBracket,True,False,
                  ButtonEditorCommand,
                  ECNextClan);
        NewButton(PrevClanPos.X,PrevClanPos.Y,
                  PrevClanPos.X+PrevClanSize.X,
                  PrevClanPos.Y+PrevClanSize.Y,
                  '<',0,Key_LBracket,True,False,
                  ButtonEditorCommand,
                  ECPrevClan);
        NewButton(SelectClanPos.X,SelectClanPos.Y,
                  SelectClanPos.X+SelectClanSize.X,
                  SelectClanPos.Y+SelectClanSize.Y,
                  '',0,0,True,False,
                  ButtonEditorCommand,
                  ECSelectClan);
        NewButton(SmallTerrainPos.X,SmallTerrainPos.Y,
                  SmallTerrainPos.X+SmallTerrainSize.X,
                  SmallTerrainPos.Y+SmallTerrainSize.Y,
                  'Small',0,0,True,False,
                  ButtonEditorCommand,
                  ECSmallTerrain);
        NewButton(NormalTerrainPos.X,NormalTerrainPos.Y,
                  NormalTerrainPos.X+NormalTerrainSize.X,
                  NormalTerrainPos.Y+NormalTerrainSize.Y,
                  'Normal',0,0,True,False,
                  ButtonEditorCommand,
                  ECNormalTerrain);
        NewButton(HugeTerrainPos.X,HugeTerrainPos.Y,
                  HugeTerrainPos.X+HugeTerrainSize.X,
                  HugeTerrainPos.Y+HugeTerrainSize.Y,
                  'Huge',0,0,True,False,
                  ButtonEditorCommand,
                  ECHugeTerrain);
        NewButton(NextTerrainPos.X,NextTerrainPos.Y,
                  NextTerrainPos.X+NextTerrainSize.X,
                  NextTerrainPos.Y+NextTerrainSize.Y,
                  '>',0,Key_Apostrophe,True,False,
                  ButtonEditorCommand,
                  ECNextTerrain);
        NewButton(PrevTerrainPos.X,PrevTerrainPos.Y,
                  PrevTerrainPos.X+PrevTerrainSize.X,
                  PrevTerrainPos.Y+PrevTerrainSize.Y,
                  '<',0,Key_SemiColon,True,False,
                  ButtonEditorCommand,
                  ECPrevTerrain);
        NewButton(SelectTerrainPos.X,SelectTerrainPos.Y,
                  SelectTerrainPos.X+SelectTerrainSize.X,
                  SelectTerrainPos.Y+SelectTerrainSize.Y,
                  '',0,0,True,False,
                  ButtonEditorCommand,
                  ECSelectTerrain);
      End;
  End;

PROCEDURE TLOCEditor.SetupEditorTerrainButtons;
  Begin
  End;

PROCEDURE TLOCEditor.SelectNextUnit;
  Var Temp : TUnit;
  Begin
    Temp:=CurrentEditorUnit;
    With MyUnits do
      Repeat
        If Temp<High(TUnit) then Inc(Temp)
        Else Temp:=Low(TUnit);
      Until UnitsProperty[CurrentEditorClan,Temp].UnitAvail;
    CurrentEditorUnit:=Temp;
  End;

PROCEDURE TLOCEditor.SelectPrevUnit;
  Var Temp : TUnit;
  Begin
    Temp:=CurrentEditorUnit;
    With MyUnits do
      Repeat
        If Temp>Low(TUnit) then Dec(Temp)
        Else Temp:=High(TUnit);
      Until UnitsProperty[CurrentEditorClan,Temp].UnitAvail;
    CurrentEditorUnit:=Temp;
  End;

PROCEDURE TLOCEditor.SelectNextClan;
  Var Temp : TClan;
  Begin
    Temp:=CurrentEditorClan;
    If Temp<High(TClan) then Inc(Temp)
    Else Temp:=Low(TClan);
    CurrentEditorClan:=Temp;
  End;

PROCEDURE TLOCEditor.SelectPrevClan;
  Var Temp : TClan;
  Begin
    Temp:=CurrentEditorClan;
    If Temp>Low(TClan) then Dec(Temp)
    Else Temp:=High(TClan);
    CurrentEditorClan:=Temp;
  End;

PROCEDURE TLOCEditor.SelectPrevTerrain;
  Begin
    If CurrentEditorTerrain>Low(TMapTile) then
      Dec(CurrentEditorTerrain)
    Else CurrentEditorTerrain:=High(TMapTile);
  End;

PROCEDURE TLOCEditor.SelectNextTerrain;
  Begin
    If CurrentEditorTerrain<High(TMapTile) then
      Inc(CurrentEditorTerrain)
    Else CurrentEditorTerrain:=Low(TMapTile);
  End;
END.
