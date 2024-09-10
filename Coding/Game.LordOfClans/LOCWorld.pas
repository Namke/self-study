UNIT LOCWorld;
{$Include GlobalDefines.Inc}
INTERFACE

USES Windows,
     MMSystem,
     Classes,
     SysUtils,
     PNGZLib,
     LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits;

TYPE
  TItemOnMap = Record
    Item    : TItem;
    Quatity : FastInt;
  End;

TYPE
  TUnitUnderFog = Record
    _UnitColor       : TCLan;
    _UnitTyper      : TUnit;
    Heading         : THeading;
    {$IfDef RandomUnitPosShift}
    _ShiftPX,_ShiftPY : ShortInt;
    {$EndIf}
  End;

TYPE
  TLOCWorld = Class
    Public
    MyScreen                        : TLOCScreen;
    MyShow                          : TLOCShow;
    MyUnits                         : TLOCUnits;
    //Size of map
    MapSizeX,MapSizeY               : FastInt;
    MapTileSizeX,MapTileSizeY       : FastInt;
    DefaultMapViewX,DefaultMapViewY : FastInt;
    //Viewmap position and view size, center view mode !
    //Viewmap on
    //  [MapViewX,MapViewY,
    //   MapViewX+DefaultMapViewX,MapViewY+DefaultMapViewY]
    //  show on screen
    //Viewmap on
    //  [MapViewPosX,MapViewPosY,MapViewPosX+MapViewDivX,MapViewPosY+MapViewDivY]
    //  show on minimap
    //Mapview size
    MapViewDivX,MapViewDivY,MapViewPosX,MapViewPosY,
    //Mapview pos in real map
    MapViewX,MapViewY               : FastInt;
    //Select status
    OnSelect                        : Boolean;
    SelectStart,SelectEnd           : TPoint;
    //Tile on map, above all ability of tile / must saved
    MapTile                         : Array of Array of TMapTileValue;
    MapTileFrame                    : Array of Array of TMapTileFrame;
    MapTileHeight                   : Array of Array of TMapTileHeight;
    FrameTile                       : Array[Byte] of Integer;
    FrameTile2                      : Array[0..15] of Integer;
    //Attribute of map / must saved
    MapAttr                         : Array of Array of TMapAttr;
    //Map number reference back to units on map / maybe could saved
    MapNum                          : Array of Array of TMapNum;
    //Map number reference back to units on map / maybe could saved
    MapTrueSight                    : Array of Array of TUnitSawState;
    //Map unit under fog
    MapUnitUnderFog                 : Array of Array of TUnitUnderFog;
    {$IfDef LimitAirUnitOnTile}
    //Map count number of unit on tile / like MapNum, maybe saved
    MapCount                        : Array of Array of Byte;
    {$EndIf}
    //
    TileAttribute                   : Array[TMapTile] of TTileAttribute;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits);
    Destructor Destroy;OverRide;
    Procedure FreeMap;
    Function  GetLastTile(TileX,TileY : FastInt) : TMapTile;
    Function  GetTile(TileX,TileY : FastInt;Level : TMapTile) : Boolean;
    Procedure UpDateTile(TileX,TileY : FastInt);
    Procedure SetTileFrame(TileX,TileY : FastInt;TileFrame : TMapTileFrame);
    Procedure SetTileHeight(TileX,TileY : FastInt;TileHeight : TMapTileHeight);
    Procedure SetTile(TileX,TileY : FastInt;Level : TMapTile;TileFrame : TMapTileFrame);OverLoad;
    Procedure SetTile(TileX,TileY : FastInt;Level : TMapTile;TileFrame : TMapTileFrame;TileHeight : TMapTileHeight);OverLoad;
    Procedure ClearTile(TileX,TileY : FastInt); OverLoad;
    Procedure ClearTile(TileX,TileY : FastInt;Level : TMapTile); OverLoad;
    Procedure ClearTileAt(TileX,TileY : FastInt;Level : TMapTile); 
    Procedure SetTileAttr(TileX,TileY : FastInt;SetMapAttr : TMapAttr;SwitchOn : Boolean = True);
    Function  GetTileAttr(TileX,TileY : FastInt;SetMapAttr : TMapAttr) : Boolean;
    Procedure SetTrueSight(Clan : TClan;TileX,TileY : FastInt;SwitchOn : Boolean = True);
    Function  GetTrueSight(Clan : TClan;TileX,TileY : FastInt) : Boolean;
    //Get tile frame, but not checked for map bound
    Function  GetTileFrame(TileX,TileY : FastInt;Level : TMapTile) : Byte;
    Procedure UpDateTileAttr;
    Procedure SetupTileAttribute;
    Procedure SetupMapSize(MapSizeX,MapSizeY : FastInt);
    Procedure SetupRandomMap(MapSizeX,MapSizeY : FastInt);
    Procedure LoadEmptyMap(MapSizeX,MapSizeY : FastInt);
    Procedure RestartMapTile;
    Procedure RestartMapNum;
    Procedure RandomMapTile;
    //Restart map under fog for no unit under fog may saw
    Procedure RestartMapUnitUnderFog;
    Procedure LoadMap(FileName : String);
    Procedure SetMapView(ViewX,ViewY : FastInt);
    Procedure AdjustMapView;
    Function  NewUnitAt(UnitClan : TClan;UnitTyper : TUnit;X,Y : FastInt) : Boolean; OverLoad;
    Function  NewUnitAt(UnitName : NameString;UnitClan : TClan;
                        UnitTyper : TUnit;X,Y : FastInt) : Boolean; OverLoad;
    Function  NewGoldMineAt(GoldAmound : LongInt;X,Y : FastInt) : Boolean;
    //Set all cell tile on unit see range have status attribute on/off
    //Support line of sight ?
    Procedure SetUnitSeeRangeStatus(UnitNum : TUnitCount;Status : TMapAttr;SwitchOn : Boolean = True);
    //Calculate unit true sight
    Procedure SetUnitTrueSight(UnitNum : TUnitCount);
    //Update unit fog, unit under map...
    Procedure UnitUpdatePosition(UnitNum : TUnitCount);
    //Testing for unit position
    Function  TestUnitPos(UnitNum : TUnitCount;PosX,PosY : FastInt) : Integer; OverLoad;
    Function  TestUnitPos(UnitNum : TUnitCount;Head : THeading;PosX,PosY : FastInt) : Integer; OverLoad;
    Function  TestTyperUnitPos(UnitClan : TClan;UnitTyper : TUnit;
                               Head : THeading;PosX,PosY : FastInt) : Integer;
    //Place unit, take land unit used land cell
    Procedure PlaceUnit(UnitNum : TUnitCount);
    //Clear cell unit used
    Procedure TakeUnit(UnitNum : TUnitCount);
    //Put unit in map num
    //If place then set UnitOnMapNum on, place unit into MapNum
    Procedure PutUnit(UnitNum : TUnitCount;Place,UpdatePos : Boolean);
    //Pick unit from map num
    //If take then set UnitOnMapNum off, take unit from MapNum
    Procedure PickUnit(UnitNum : TUnitCount;Take : Boolean);
    //Set unit attribute as HasTarget :>
    Procedure AlertUnitArea(UnitNum : TUnitCount);
    //Set unit position, also put unit on this position !
    Procedure SetUnitPos(UnitNum : TUnitCount;PosX,PosY : FastInt);
    //Select all unit on area into group MaxGroup
    Procedure SelectUnitOnArea(X1,Y1,X2,Y2 : FastInt;AddUnit,SelectBuilding : Boolean);
    Procedure SelectUnitOnMap(X1,Y1,X2,Y2 : FastInt;AddUnit,SelectBuilding : Boolean);
    //Place unit into under fog map, clear all cell unit used
    Procedure PlaceUnitInUnderFogMap(UnitNum : TUnitCount);
    //Clear unit on under fog map, clear all cell unit used
    Procedure ClearUnitInUnderFogMap(UnitNum : TUnitCount);
    //Clear all unit under fog in see range of unit num
    Procedure ClearUnitUnderFogVisible(UnitNum : TUnitCount);
    //Check unit under fog can see for clear
    Function  UnitUnderFogVisible(X,Y : FastInt) : Boolean;
    //Finding unit in range for unit attack, include some AI for unit
    Function  UnitFindTargetForAttack(UnitNum : TUnitCount;Range,SeeRange : FastInt) : TUnitCount;
    //Get unit type near by unit num
    Function  GetUnitNear(UnitNum : TUnitCount;Find : TUnit;MinRange,MaxRange : FastInt) : TUnitCount;
    Function  GetFreePosNear(UnitNum : TUnitCount;MinRange,MaxRange : FastInt;Var X,Y : FastInt) : Boolean;
    //Find unit can see on group
    Function  FindUnitCanSee(Group : TGroup) : Boolean;
    //Check unit saw state (cloak, invisible, under fogging..)
    Function  CanSeeThisUnit(FromClan : TClan;UnitNum : TUnitCount) : Boolean;
    //Clear all unit lost vision on group
    Procedure ClearAllUnitCantSee(Var Group : TGroup);
    //Set group to command cancel building
    Procedure SetGroupCommandCancelBuilding(Group : TGroup;FromClan : TClan);
    //  When unit change heading, unit maybe take a field differ from last heading
    //then I must check this before change unit heading !
    Function  UnitChangeHeading(UnitNum : TUnitCount;Head : THeading) : Boolean;
    //Get heading for unit attack
    Function  UnitGetHeadingToAttack(UnitNum : TUnitCount) : Boolean;
    Function  UnitGetHeadingToAttackNoTarget(UnitNum : TUnitCount) : Boolean;
    //Must check place unit position before calling this function
    Function  UnitCommandBuild(UnitNum : TUnitCount;Typer : TUnit;
                               X,Y : FastInt;FromClan : TClan) : FastInt; OverLoad;
    Function  UnitCommandBuild(UnitNum : TUnitCount;Typer : TUnit;Head : THeading;
                               X,Y : FastInt;FromClan : TClan) : FastInt; OverLoad;
    Procedure UnitCommandGotoBuild(UnitNum,Target : TUnitCount);
    //Check unit attacking state
    Procedure UnitCheckAttacking(UnitNum : TUnitCount);
    //Check unit castspell state
    Procedure UnitCheckCastSpell(UnitNum : TUnitCount);
    //Check unit nearby unit target build,please unit building
    Procedure UnitCheckBuilding(UnitNum : TUnitCount);
    //Check unit nearby unit target gold mine, mining ?
    Procedure UnitCheckMining(UnitNum : TUnitCount);
    //Check unit nearby unit target town, return gold and back to work !
    Procedure UnitCheckReturnGold(UnitNum : TUnitCount);
    //Check unit put item, if unit nearby target then unit put item and reset unit command
    Procedure UnitCheckPutItem(UnitNum : TUnitCount);
    Procedure UnitCheckPickUpItem(UnitNum : TUnitCount);
    //Set unit pickup all item in target, also freedom unit in target ? That great !!!!!!
    Function  UnitPickUpItem(UnitNum,UnitTarget : TUnitCount) : Boolean;
    //Check unit load unit
    Procedure UnitCheckLoadUnit(UnitNum : TUnitCount);
    //Check unit unload unit to specific area
    Procedure UnitCheckUnLoadUnit(UnitNum : TUnitCount);
    //Check unit transport
    Procedure UnitCheckTransport(UnitNum : TUnitCount);
    //Process training queue, of course...
    Procedure UnitProcessQueue(UnitNum : TUnitCount);
    //Training this unit
    Procedure UnitTraining(UnitNum : TUnitCount);
    //Add unit carrier..., also clear unit on mapnum ?
    Function  AddUnitCarrier(UnitNum,Target : TUnitCount;UpdateButton : Boolean = True) : Boolean;
    //Get free tile around unit to place unit place, tile address is [X,Y]
    Function  GetFreeTileAroundUnit(UnitNum,UnitPlace : TUnitCount;Var X,Y : FastInt) : Boolean;
    Function  GetBestFreeTileAroundUnit(UnitNum,UnitPlace,NearUnit : TUnitCount;Var X,Y : FastInt) : Boolean;
    //Unit unload slot
    Function  UnitUnLoadSlot(UnitNum : TUnitCount;SlotNum : TQueueCount;SendRally : Boolean = True) : Boolean; OverLoad;
    Function  UnitUnLoadSlot(UnitNum,NearUnit : TUnitCount;SlotNum : TQueueCount;SendRally : Boolean = True) : Boolean; OverLoad;
    //
    Function  UnitUnLoad(UnitNum,Target : TUnitCount) : Boolean; OverLoad;
    Function  UnitUnLoad(UnitNum,Target,NearUnit : TUnitCount) : Boolean; OverLoad;
    //Unit unload all unit in carrier
    Procedure UnitUnLoadCarrier(UnitNum : TUnitCount;SendRally : Boolean = True);
    //
    Procedure SendGroupRightClickCommand(X,Y : FastInt); Overload;
    Procedure SendUnitRightClickCommand(UnitNum : TUnitCount;X,Y : FastInt); Overload;
    Procedure SendGroupRightClickCommand(Target : TUnitCount); Overload;
    Procedure SendUnitRightClickCommand(UnitNum,Target : TUnitCount); Overload;
    //Unit selection function
    Procedure SelectUnitByMouse(AddUnit,SelectBuilding : Boolean);
    Procedure SelectGroup(GroupNum : Byte);
    Procedure CenterGroup(GroupNum : Byte);
    Procedure GetRealMousePos(Var X,Y,XS,YS : FastInt);
    //Select freedom unit under human control
    Procedure SelectFreeWorker;
    Procedure SelectFreeTroop;
    Procedure SelectFreeBuilding;
    //
    Function  CanSeeMissile(MisNum : TMissileCount) : Boolean;
    //World fog
    Procedure RestartWorldVisited;
    //Restart world fog and truesight map
    Procedure RestartWorldFog;
    Procedure UpdateWorldFog;
    Procedure OpenWorldMapVisited;
    Procedure OpenWorldFog;
    //Water update for waves
    Procedure WaterUpDate;
    //Path finding method
    Public
    AStarMatrix       : Array of TNode;
    OpenSet           : Array of TOpen;
    CloseSet          : Array of Integer;
    PathHead          : Array of THeading;
    PathLength        : Integer;
    OpenSetMaxSize,AStarMatrixSize,NumInCloseSet,OpenSetSize,
    FirstOpenSet,ThresholdCloseSet,FindPathStepCounter : Integer;
    StartTimeFindPath                                  : Cardinal;
    Function  Cost(X1,Y1,X2,Y2 : SmallInt) : Integer;
    Procedure AStarRemoveMinimum(Post : Integer);
    Procedure AStarAddNode(X,Y : SmallInt;{$IfNDef NoIndex}O,{$EndIf}Cost : Integer);
    Procedure AStarReplaceNode(Node,Cost : Integer);
    Function  AStarFindNode(EO : Integer) : Integer;
    Procedure ClearSet;
    Function  FindPath(UnitNum : TUnitCount) : Boolean;
    //
    Function  SaveToStream(Stream : TStream;Compress : Boolean = True) : Boolean;
    Function  LoadFromStream(Stream : TStream) : Boolean;
  End;

VAR
  GameWorld : TLOCWorld;
  
IMPLEMENTATION
{$IfDef LightOfSight}
CONST
  //Max range unit can see !
  MaxRange = 20;
  LightPos : Array[0..7,0..MaxRange,0..MaxRange,0..1] of SmallInt =
    //89
  ((((  0,  0),(  0, -1),(  0, -2),(  0, -3),(  0, -4),(  0, -5),(  0, -6),(  0, -7),(  0, -8),(  0, -9),(  0,-10),(  0,-11),(  0,-12),(  0,-13),(  0,-14),(  0,-15),(  0,-16),(  0,-17),(  0,-18),(  0,-19),(  0,-20)),
    ((  0,  0),(  0, -1),(  0, -2),(  0, -3),(  0, -4),(  0, -5),(  0, -6),(  0, -7),(  0, -8),(  0, -9),(  1,-10),(  1,-11),(  1,-12),(  1,-13),(  1,-14),(  1,-15),(  1,-16),(  1,-17),(  1,-18),(  1,-19),(  1,-20)),
    ((  0,  0),(  0, -1),(  0, -2),(  0, -3),(  0, -4),(  1, -5),(  1, -6),(  1, -7),(  1, -8),(  1, -9),(  1,-10),(  1,-11),(  1,-12),(  1,-13),(  1,-14),(  2,-15),(  2,-16),(  2,-17),(  2,-18),(  2,-19),(  2,-20)),
    ((  0,  0),(  0, -1),(  0, -2),(  0, -3),(  1, -4),(  1, -5),(  1, -6),(  1, -7),(  1, -8),(  1, -9),(  2,-10),(  2,-11),(  2,-12),(  2,-13),(  2,-14),(  2,-15),(  2,-16),(  3,-17),(  3,-18),(  3,-19),(  3,-20)),
    ((  0,  0),(  0, -1),(  0, -2),(  1, -3),(  1, -4),(  1, -5),(  1, -6),(  1, -7),(  2, -8),(  2, -9),(  2,-10),(  2,-11),(  2,-12),(  3,-13),(  3,-14),(  3,-15),(  3,-16),(  3,-17),(  4,-18),(  4,-19),(  4,-20)),
    ((  0,  0),(  0, -1),(  1, -2),(  1, -3),(  1, -4),(  1, -5),(  2, -6),(  2, -7),(  2, -8),(  2, -9),(  3,-10),(  3,-11),(  3,-12),(  3,-13),(  4,-14),(  4,-15),(  4,-16),(  4,-17),(  5,-18),(  5,-19),(  5,-20)),
    ((  0,  0),(  0, -1),(  1, -2),(  1, -3),(  1, -4),(  2, -5),(  2, -6),(  2, -7),(  2, -8),(  3, -9),(  3,-10),(  3,-11),(  4,-12),(  4,-13),(  4,-14),(  5,-15),(  5,-16),(  5,-17),(  5,-18),(  6,-19),(  6,-20)),
    ((  0,  0),(  0, -1),(  1, -2),(  1, -3),(  1, -4),(  2, -5),(  2, -6),(  2, -7),(  3, -8),(  3, -9),(  4,-10),(  4,-11),(  4,-12),(  5,-13),(  5,-14),(  5,-15),(  6,-16),(  6,-17),(  6,-18),(  7,-19),(  7,-20)),
    ((  0,  0),(  0, -1),(  1, -2),(  1, -3),(  2, -4),(  2, -5),(  2, -6),(  3, -7),(  3, -8),(  4, -9),(  4,-10),(  4,-11),(  5,-12),(  5,-13),(  6,-14),(  6,-15),(  6,-16),(  7,-17),(  7,-18),(  8,-19),(  8,-20)),
    ((  0,  0),(  0, -1),(  1, -2),(  1, -3),(  2, -4),(  2, -5),(  3, -6),(  3, -7),(  4, -8),(  4, -9),(  5,-10),(  5,-11),(  5,-12),(  6,-13),(  6,-14),(  7,-15),(  7,-16),(  8,-17),(  8,-18),(  9,-19),(  9,-20)),
    ((  0,  0),(  1, -1),(  1, -2),(  2, -3),(  2, -4),(  3, -5),(  3, -6),(  4, -7),(  4, -8),(  5, -9),(  5,-10),(  6,-11),(  6,-12),(  7,-13),(  7,-14),(  8,-15),(  8,-16),(  9,-17),(  9,-18),( 10,-19),( 10,-20)),
    ((  0,  0),(  1, -1),(  1, -2),(  2, -3),(  2, -4),(  3, -5),(  3, -6),(  4, -7),(  4, -8),(  5, -9),(  6,-10),(  6,-11),(  7,-12),(  7,-13),(  8,-14),(  8,-15),(  9,-16),(  9,-17),( 10,-18),( 10,-19),( 11,-20)),
    ((  0,  0),(  1, -1),(  1, -2),(  2, -3),(  2, -4),(  3, -5),(  4, -6),(  4, -7),(  5, -8),(  5, -9),(  6,-10),(  7,-11),(  7,-12),(  8,-13),(  8,-14),(  9,-15),( 10,-16),( 10,-17),( 11,-18),( 11,-19),( 12,-20)),
    ((  0,  0),(  1, -1),(  1, -2),(  2, -3),(  3, -4),(  3, -5),(  4, -6),(  5, -7),(  5, -8),(  6, -9),(  7,-10),(  7,-11),(  8,-12),(  8,-13),(  9,-14),( 10,-15),( 10,-16),( 11,-17),( 12,-18),( 12,-19),( 13,-20)),
    ((  0,  0),(  1, -1),(  1, -2),(  2, -3),(  3, -4),(  4, -5),(  4, -6),(  5, -7),(  6, -8),(  6, -9),(  7,-10),(  8,-11),(  8,-12),(  9,-13),( 10,-14),( 11,-15),( 11,-16),( 12,-17),( 13,-18),( 13,-19),( 14,-20)),
    ((  0,  0),(  1, -1),(  2, -2),(  2, -3),(  3, -4),(  4, -5),(  5, -6),(  5, -7),(  6, -8),(  7, -9),(  8,-10),(  8,-11),(  9,-12),( 10,-13),( 11,-14),( 11,-15),( 12,-16),( 13,-17),( 14,-18),( 14,-19),( 15,-20)),
    ((  0,  0),(  1, -1),(  2, -2),(  2, -3),(  3, -4),(  4, -5),(  5, -6),(  6, -7),(  6, -8),(  7, -9),(  8,-10),(  9,-11),( 10,-12),( 10,-13),( 11,-14),( 12,-15),( 13,-16),( 14,-17),( 14,-18),( 15,-19),( 16,-20)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  3, -4),(  4, -5),(  5, -6),(  6, -7),(  7, -8),(  8, -9),(  9,-10),(  9,-11),( 10,-12),( 11,-13),( 12,-14),( 13,-15),( 14,-16),( 14,-17),( 15,-18),( 16,-19),( 17,-20)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  4, -4),(  5, -5),(  5, -6),(  6, -7),(  7, -8),(  8, -9),(  9,-10),( 10,-11),( 11,-12),( 12,-13),( 13,-14),( 14,-15),( 14,-16),( 15,-17),( 16,-18),( 17,-19),( 18,-20)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  4, -4),(  5, -5),(  6, -6),(  7, -7),(  8, -8),(  9, -9),( 10,-10),( 10,-11),( 11,-12),( 12,-13),( 13,-14),( 14,-15),( 15,-16),( 16,-17),( 17,-18),( 18,-19),( 19,-20)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  4, -4),(  5, -5),(  6, -6),(  7, -7),(  8, -8),(  9, -9),( 10,-10),( 11,-11),( 12,-12),( 13,-13),( 14,-14),( 15,-15),( 16,-16),( 17,-17),( 18,-18),( 19,-19),( 20,-20))),
    //96
   (((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4,  0),(  5,  0),(  6,  0),(  7,  0),(  8,  0),(  9,  0),( 10,  0),( 11,  0),( 12,  0),( 13,  0),( 14,  0),( 15,  0),( 16,  0),( 17,  0),( 18,  0),( 19,  0),( 20,  0)),
    ((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4,  0),(  5,  0),(  6,  0),(  7,  0),(  8,  0),(  9,  0),( 10, -1),( 11, -1),( 12, -1),( 13, -1),( 14, -1),( 15, -1),( 16, -1),( 17, -1),( 18, -1),( 19, -1),( 20, -1)),
    ((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4,  0),(  5, -1),(  6, -1),(  7, -1),(  8, -1),(  9, -1),( 10, -1),( 11, -1),( 12, -1),( 13, -1),( 14, -1),( 15, -2),( 16, -2),( 17, -2),( 18, -2),( 19, -2),( 20, -2)),
    ((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4, -1),(  5, -1),(  6, -1),(  7, -1),(  8, -1),(  9, -1),( 10, -2),( 11, -2),( 12, -2),( 13, -2),( 14, -2),( 15, -2),( 16, -2),( 17, -3),( 18, -3),( 19, -3),( 20, -3)),
    ((  0,  0),(  1,  0),(  2,  0),(  3, -1),(  4, -1),(  5, -1),(  6, -1),(  7, -1),(  8, -2),(  9, -2),( 10, -2),( 11, -2),( 12, -2),( 13, -3),( 14, -3),( 15, -3),( 16, -3),( 17, -3),( 18, -4),( 19, -4),( 20, -4)),
    ((  0,  0),(  1,  0),(  2, -1),(  3, -1),(  4, -1),(  5, -1),(  6, -2),(  7, -2),(  8, -2),(  9, -2),( 10, -3),( 11, -3),( 12, -3),( 13, -3),( 14, -4),( 15, -4),( 16, -4),( 17, -4),( 18, -5),( 19, -5),( 20, -5)),
    ((  0,  0),(  1,  0),(  2, -1),(  3, -1),(  4, -1),(  5, -2),(  6, -2),(  7, -2),(  8, -2),(  9, -3),( 10, -3),( 11, -3),( 12, -4),( 13, -4),( 14, -4),( 15, -5),( 16, -5),( 17, -5),( 18, -5),( 19, -6),( 20, -6)),
    ((  0,  0),(  1,  0),(  2, -1),(  3, -1),(  4, -1),(  5, -2),(  6, -2),(  7, -2),(  8, -3),(  9, -3),( 10, -4),( 11, -4),( 12, -4),( 13, -5),( 14, -5),( 15, -5),( 16, -6),( 17, -6),( 18, -6),( 19, -7),( 20, -7)),
    ((  0,  0),(  1,  0),(  2, -1),(  3, -1),(  4, -2),(  5, -2),(  6, -2),(  7, -3),(  8, -3),(  9, -4),( 10, -4),( 11, -4),( 12, -5),( 13, -5),( 14, -6),( 15, -6),( 16, -6),( 17, -7),( 18, -7),( 19, -8),( 20, -8)),
    ((  0,  0),(  1,  0),(  2, -1),(  3, -1),(  4, -2),(  5, -2),(  6, -3),(  7, -3),(  8, -4),(  9, -4),( 10, -5),( 11, -5),( 12, -5),( 13, -6),( 14, -6),( 15, -7),( 16, -7),( 17, -8),( 18, -8),( 19, -9),( 20, -9)),
    ((  0,  0),(  1, -1),(  2, -1),(  3, -2),(  4, -2),(  5, -3),(  6, -3),(  7, -4),(  8, -4),(  9, -5),( 10, -5),( 11, -6),( 12, -6),( 13, -7),( 14, -7),( 15, -8),( 16, -8),( 17, -9),( 18, -9),( 19,-10),( 20,-10)),
    ((  0,  0),(  1, -1),(  2, -1),(  3, -2),(  4, -2),(  5, -3),(  6, -3),(  7, -4),(  8, -4),(  9, -5),( 10, -6),( 11, -6),( 12, -7),( 13, -7),( 14, -8),( 15, -8),( 16, -9),( 17, -9),( 18,-10),( 19,-10),( 20,-11)),
    ((  0,  0),(  1, -1),(  2, -1),(  3, -2),(  4, -2),(  5, -3),(  6, -4),(  7, -4),(  8, -5),(  9, -5),( 10, -6),( 11, -7),( 12, -7),( 13, -8),( 14, -8),( 15, -9),( 16,-10),( 17,-10),( 18,-11),( 19,-11),( 20,-12)),
    ((  0,  0),(  1, -1),(  2, -1),(  3, -2),(  4, -3),(  5, -3),(  6, -4),(  7, -5),(  8, -5),(  9, -6),( 10, -7),( 11, -7),( 12, -8),( 13, -8),( 14, -9),( 15,-10),( 16,-10),( 17,-11),( 18,-12),( 19,-12),( 20,-13)),
    ((  0,  0),(  1, -1),(  2, -1),(  3, -2),(  4, -3),(  5, -4),(  6, -4),(  7, -5),(  8, -6),(  9, -6),( 10, -7),( 11, -8),( 12, -8),( 13, -9),( 14,-10),( 15,-11),( 16,-11),( 17,-12),( 18,-13),( 19,-13),( 20,-14)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -2),(  4, -3),(  5, -4),(  6, -5),(  7, -5),(  8, -6),(  9, -7),( 10, -8),( 11, -8),( 12, -9),( 13,-10),( 14,-11),( 15,-11),( 16,-12),( 17,-13),( 18,-14),( 19,-14),( 20,-15)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -2),(  4, -3),(  5, -4),(  6, -5),(  7, -6),(  8, -6),(  9, -7),( 10, -8),( 11, -9),( 12,-10),( 13,-10),( 14,-11),( 15,-12),( 16,-13),( 17,-14),( 18,-14),( 19,-15),( 20,-16)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  4, -3),(  5, -4),(  6, -5),(  7, -6),(  8, -7),(  9, -8),( 10, -9),( 11, -9),( 12,-10),( 13,-11),( 14,-12),( 15,-13),( 16,-14),( 17,-14),( 18,-15),( 19,-16),( 20,-17)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  4, -4),(  5, -5),(  6, -5),(  7, -6),(  8, -7),(  9, -8),( 10, -9),( 11,-10),( 12,-11),( 13,-12),( 14,-13),( 15,-14),( 16,-14),( 17,-15),( 18,-16),( 19,-17),( 20,-18)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  4, -4),(  5, -5),(  6, -6),(  7, -7),(  8, -8),(  9, -9),( 10,-10),( 11,-10),( 12,-11),( 13,-12),( 14,-13),( 15,-14),( 16,-15),( 17,-16),( 18,-17),( 19,-18),( 20,-19)),
    ((  0,  0),(  1, -1),(  2, -2),(  3, -3),(  4, -4),(  5, -5),(  6, -6),(  7, -7),(  8, -8),(  9, -9),( 10,-10),( 11,-11),( 12,-12),( 13,-13),( 14,-14),( 15,-15),( 16,-16),( 17,-17),( 18,-18),( 19,-19),( 20,-20))),
    //63
   (((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4,  0),(  5,  0),(  6,  0),(  7,  0),(  8,  0),(  9,  0),( 10,  0),( 11,  0),( 12,  0),( 13,  0),( 14,  0),( 15,  0),( 16,  0),( 17,  0),( 18,  0),( 19,  0),( 20,  0)),
    ((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4,  0),(  5,  0),(  6,  0),(  7,  0),(  8,  0),(  9,  0),( 10,  1),( 11,  1),( 12,  1),( 13,  1),( 14,  1),( 15,  1),( 16,  1),( 17,  1),( 18,  1),( 19,  1),( 20,  1)),
    ((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4,  0),(  5,  1),(  6,  1),(  7,  1),(  8,  1),(  9,  1),( 10,  1),( 11,  1),( 12,  1),( 13,  1),( 14,  1),( 15,  2),( 16,  2),( 17,  2),( 18,  2),( 19,  2),( 20,  2)),
    ((  0,  0),(  1,  0),(  2,  0),(  3,  0),(  4,  1),(  5,  1),(  6,  1),(  7,  1),(  8,  1),(  9,  1),( 10,  2),( 11,  2),( 12,  2),( 13,  2),( 14,  2),( 15,  2),( 16,  2),( 17,  3),( 18,  3),( 19,  3),( 20,  3)),
    ((  0,  0),(  1,  0),(  2,  0),(  3,  1),(  4,  1),(  5,  1),(  6,  1),(  7,  1),(  8,  2),(  9,  2),( 10,  2),( 11,  2),( 12,  2),( 13,  3),( 14,  3),( 15,  3),( 16,  3),( 17,  3),( 18,  4),( 19,  4),( 20,  4)),
    ((  0,  0),(  1,  0),(  2,  1),(  3,  1),(  4,  1),(  5,  1),(  6,  2),(  7,  2),(  8,  2),(  9,  2),( 10,  3),( 11,  3),( 12,  3),( 13,  3),( 14,  4),( 15,  4),( 16,  4),( 17,  4),( 18,  5),( 19,  5),( 20,  5)),
    ((  0,  0),(  1,  0),(  2,  1),(  3,  1),(  4,  1),(  5,  2),(  6,  2),(  7,  2),(  8,  2),(  9,  3),( 10,  3),( 11,  3),( 12,  4),( 13,  4),( 14,  4),( 15,  5),( 16,  5),( 17,  5),( 18,  5),( 19,  6),( 20,  6)),
    ((  0,  0),(  1,  0),(  2,  1),(  3,  1),(  4,  1),(  5,  2),(  6,  2),(  7,  2),(  8,  3),(  9,  3),( 10,  4),( 11,  4),( 12,  4),( 13,  5),( 14,  5),( 15,  5),( 16,  6),( 17,  6),( 18,  6),( 19,  7),( 20,  7)),
    ((  0,  0),(  1,  0),(  2,  1),(  3,  1),(  4,  2),(  5,  2),(  6,  2),(  7,  3),(  8,  3),(  9,  4),( 10,  4),( 11,  4),( 12,  5),( 13,  5),( 14,  6),( 15,  6),( 16,  6),( 17,  7),( 18,  7),( 19,  8),( 20,  8)),
    ((  0,  0),(  1,  0),(  2,  1),(  3,  1),(  4,  2),(  5,  2),(  6,  3),(  7,  3),(  8,  4),(  9,  4),( 10,  5),( 11,  5),( 12,  5),( 13,  6),( 14,  6),( 15,  7),( 16,  7),( 17,  8),( 18,  8),( 19,  9),( 20,  9)),
    ((  0,  0),(  1,  1),(  2,  1),(  3,  2),(  4,  2),(  5,  3),(  6,  3),(  7,  4),(  8,  4),(  9,  5),( 10,  5),( 11,  6),( 12,  6),( 13,  7),( 14,  7),( 15,  8),( 16,  8),( 17,  9),( 18,  9),( 19, 10),( 20, 10)),
    ((  0,  0),(  1,  1),(  2,  1),(  3,  2),(  4,  2),(  5,  3),(  6,  3),(  7,  4),(  8,  4),(  9,  5),( 10,  6),( 11,  6),( 12,  7),( 13,  7),( 14,  8),( 15,  8),( 16,  9),( 17,  9),( 18, 10),( 19, 10),( 20, 11)),
    ((  0,  0),(  1,  1),(  2,  1),(  3,  2),(  4,  2),(  5,  3),(  6,  4),(  7,  4),(  8,  5),(  9,  5),( 10,  6),( 11,  7),( 12,  7),( 13,  8),( 14,  8),( 15,  9),( 16, 10),( 17, 10),( 18, 11),( 19, 11),( 20, 12)),
    ((  0,  0),(  1,  1),(  2,  1),(  3,  2),(  4,  3),(  5,  3),(  6,  4),(  7,  5),(  8,  5),(  9,  6),( 10,  7),( 11,  7),( 12,  8),( 13,  8),( 14,  9),( 15, 10),( 16, 10),( 17, 11),( 18, 12),( 19, 12),( 20, 13)),
    ((  0,  0),(  1,  1),(  2,  1),(  3,  2),(  4,  3),(  5,  4),(  6,  4),(  7,  5),(  8,  6),(  9,  6),( 10,  7),( 11,  8),( 12,  8),( 13,  9),( 14, 10),( 15, 11),( 16, 11),( 17, 12),( 18, 13),( 19, 13),( 20, 14)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  2),(  4,  3),(  5,  4),(  6,  5),(  7,  5),(  8,  6),(  9,  7),( 10,  8),( 11,  8),( 12,  9),( 13, 10),( 14, 11),( 15, 11),( 16, 12),( 17, 13),( 18, 14),( 19, 14),( 20, 15)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  2),(  4,  3),(  5,  4),(  6,  5),(  7,  6),(  8,  6),(  9,  7),( 10,  8),( 11,  9),( 12, 10),( 13, 10),( 14, 11),( 15, 12),( 16, 13),( 17, 14),( 18, 14),( 19, 15),( 20, 16)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  4,  3),(  5,  4),(  6,  5),(  7,  6),(  8,  7),(  9,  8),( 10,  9),( 11,  9),( 12, 10),( 13, 11),( 14, 12),( 15, 13),( 16, 14),( 17, 14),( 18, 15),( 19, 16),( 20, 17)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  4,  4),(  5,  5),(  6,  5),(  7,  6),(  8,  7),(  9,  8),( 10,  9),( 11, 10),( 12, 11),( 13, 12),( 14, 13),( 15, 14),( 16, 14),( 17, 15),( 18, 16),( 19, 17),( 20, 18)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  4,  4),(  5,  5),(  6,  6),(  7,  7),(  8,  8),(  9,  9),( 10, 10),( 11, 10),( 12, 11),( 13, 12),( 14, 13),( 15, 14),( 16, 15),( 17, 16),( 18, 17),( 19, 18),( 20, 19)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  4,  4),(  5,  5),(  6,  6),(  7,  7),(  8,  8),(  9,  9),( 10, 10),( 11, 11),( 12, 12),( 13, 13),( 14, 14),( 15, 15),( 16, 16),( 17, 17),( 18, 18),( 19, 19),( 20, 20))),
    //32
   (((  0,  0),(  0,  1),(  0,  2),(  0,  3),(  0,  4),(  0,  5),(  0,  6),(  0,  7),(  0,  8),(  0,  9),(  0, 10),(  0, 11),(  0, 12),(  0, 13),(  0, 14),(  0, 15),(  0, 16),(  0, 17),(  0, 18),(  0, 19),(  0, 20)),
    ((  0,  0),(  0,  1),(  0,  2),(  0,  3),(  0,  4),(  0,  5),(  0,  6),(  0,  7),(  0,  8),(  0,  9),(  1, 10),(  1, 11),(  1, 12),(  1, 13),(  1, 14),(  1, 15),(  1, 16),(  1, 17),(  1, 18),(  1, 19),(  1, 20)),
    ((  0,  0),(  0,  1),(  0,  2),(  0,  3),(  0,  4),(  1,  5),(  1,  6),(  1,  7),(  1,  8),(  1,  9),(  1, 10),(  1, 11),(  1, 12),(  1, 13),(  1, 14),(  2, 15),(  2, 16),(  2, 17),(  2, 18),(  2, 19),(  2, 20)),
    ((  0,  0),(  0,  1),(  0,  2),(  0,  3),(  1,  4),(  1,  5),(  1,  6),(  1,  7),(  1,  8),(  1,  9),(  2, 10),(  2, 11),(  2, 12),(  2, 13),(  2, 14),(  2, 15),(  2, 16),(  3, 17),(  3, 18),(  3, 19),(  3, 20)),
    ((  0,  0),(  0,  1),(  0,  2),(  1,  3),(  1,  4),(  1,  5),(  1,  6),(  1,  7),(  2,  8),(  2,  9),(  2, 10),(  2, 11),(  2, 12),(  3, 13),(  3, 14),(  3, 15),(  3, 16),(  3, 17),(  4, 18),(  4, 19),(  4, 20)),
    ((  0,  0),(  0,  1),(  1,  2),(  1,  3),(  1,  4),(  1,  5),(  2,  6),(  2,  7),(  2,  8),(  2,  9),(  3, 10),(  3, 11),(  3, 12),(  3, 13),(  4, 14),(  4, 15),(  4, 16),(  4, 17),(  5, 18),(  5, 19),(  5, 20)),
    ((  0,  0),(  0,  1),(  1,  2),(  1,  3),(  1,  4),(  2,  5),(  2,  6),(  2,  7),(  2,  8),(  3,  9),(  3, 10),(  3, 11),(  4, 12),(  4, 13),(  4, 14),(  5, 15),(  5, 16),(  5, 17),(  5, 18),(  6, 19),(  6, 20)),
    ((  0,  0),(  0,  1),(  1,  2),(  1,  3),(  1,  4),(  2,  5),(  2,  6),(  2,  7),(  3,  8),(  3,  9),(  4, 10),(  4, 11),(  4, 12),(  5, 13),(  5, 14),(  5, 15),(  6, 16),(  6, 17),(  6, 18),(  7, 19),(  7, 20)),
    ((  0,  0),(  0,  1),(  1,  2),(  1,  3),(  2,  4),(  2,  5),(  2,  6),(  3,  7),(  3,  8),(  4,  9),(  4, 10),(  4, 11),(  5, 12),(  5, 13),(  6, 14),(  6, 15),(  6, 16),(  7, 17),(  7, 18),(  8, 19),(  8, 20)),
    ((  0,  0),(  0,  1),(  1,  2),(  1,  3),(  2,  4),(  2,  5),(  3,  6),(  3,  7),(  4,  8),(  4,  9),(  5, 10),(  5, 11),(  5, 12),(  6, 13),(  6, 14),(  7, 15),(  7, 16),(  8, 17),(  8, 18),(  9, 19),(  9, 20)),
    ((  0,  0),(  1,  1),(  1,  2),(  2,  3),(  2,  4),(  3,  5),(  3,  6),(  4,  7),(  4,  8),(  5,  9),(  5, 10),(  6, 11),(  6, 12),(  7, 13),(  7, 14),(  8, 15),(  8, 16),(  9, 17),(  9, 18),( 10, 19),( 10, 20)),
    ((  0,  0),(  1,  1),(  1,  2),(  2,  3),(  2,  4),(  3,  5),(  3,  6),(  4,  7),(  4,  8),(  5,  9),(  6, 10),(  6, 11),(  7, 12),(  7, 13),(  8, 14),(  8, 15),(  9, 16),(  9, 17),( 10, 18),( 10, 19),( 11, 20)),
    ((  0,  0),(  1,  1),(  1,  2),(  2,  3),(  2,  4),(  3,  5),(  4,  6),(  4,  7),(  5,  8),(  5,  9),(  6, 10),(  7, 11),(  7, 12),(  8, 13),(  8, 14),(  9, 15),( 10, 16),( 10, 17),( 11, 18),( 11, 19),( 12, 20)),
    ((  0,  0),(  1,  1),(  1,  2),(  2,  3),(  3,  4),(  3,  5),(  4,  6),(  5,  7),(  5,  8),(  6,  9),(  7, 10),(  7, 11),(  8, 12),(  8, 13),(  9, 14),( 10, 15),( 10, 16),( 11, 17),( 12, 18),( 12, 19),( 13, 20)),
    ((  0,  0),(  1,  1),(  1,  2),(  2,  3),(  3,  4),(  4,  5),(  4,  6),(  5,  7),(  6,  8),(  6,  9),(  7, 10),(  8, 11),(  8, 12),(  9, 13),( 10, 14),( 11, 15),( 11, 16),( 12, 17),( 13, 18),( 13, 19),( 14, 20)),
    ((  0,  0),(  1,  1),(  2,  2),(  2,  3),(  3,  4),(  4,  5),(  5,  6),(  5,  7),(  6,  8),(  7,  9),(  8, 10),(  8, 11),(  9, 12),( 10, 13),( 11, 14),( 11, 15),( 12, 16),( 13, 17),( 14, 18),( 14, 19),( 15, 20)),
    ((  0,  0),(  1,  1),(  2,  2),(  2,  3),(  3,  4),(  4,  5),(  5,  6),(  6,  7),(  6,  8),(  7,  9),(  8, 10),(  9, 11),( 10, 12),( 10, 13),( 11, 14),( 12, 15),( 13, 16),( 14, 17),( 14, 18),( 15, 19),( 16, 20)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  3,  4),(  4,  5),(  5,  6),(  6,  7),(  7,  8),(  8,  9),(  9, 10),(  9, 11),( 10, 12),( 11, 13),( 12, 14),( 13, 15),( 14, 16),( 14, 17),( 15, 18),( 16, 19),( 17, 20)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  4,  4),(  5,  5),(  5,  6),(  6,  7),(  7,  8),(  8,  9),(  9, 10),( 10, 11),( 11, 12),( 12, 13),( 13, 14),( 14, 15),( 14, 16),( 15, 17),( 16, 18),( 17, 19),( 18, 20)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  4,  4),(  5,  5),(  6,  6),(  7,  7),(  8,  8),(  9,  9),( 10, 10),( 10, 11),( 11, 12),( 12, 13),( 13, 14),( 14, 15),( 15, 16),( 16, 17),( 17, 18),( 18, 19),( 19, 20)),
    ((  0,  0),(  1,  1),(  2,  2),(  3,  3),(  4,  4),(  5,  5),(  6,  6),(  7,  7),(  8,  8),(  9,  9),( 10, 10),( 11, 11),( 12, 12),( 13, 13),( 14, 14),( 15, 15),( 16, 16),( 17, 17),( 18, 18),( 19, 19),( 20, 20))),
    //21
   (((  0,  0),(  0,  1),(  0,  2),(  0,  3),(  0,  4),(  0,  5),(  0,  6),(  0,  7),(  0,  8),(  0,  9),(  0, 10),(  0, 11),(  0, 12),(  0, 13),(  0, 14),(  0, 15),(  0, 16),(  0, 17),(  0, 18),(  0, 19),(  0, 20)),
    ((  0,  0),(  0,  1),(  0,  2),(  0,  3),(  0,  4),(  0,  5),(  0,  6),(  0,  7),(  0,  8),(  0,  9),( -1, 10),( -1, 11),( -1, 12),( -1, 13),( -1, 14),( -1, 15),( -1, 16),( -1, 17),( -1, 18),( -1, 19),( -1, 20)),
    ((  0,  0),(  0,  1),(  0,  2),(  0,  3),(  0,  4),( -1,  5),( -1,  6),( -1,  7),( -1,  8),( -1,  9),( -1, 10),( -1, 11),( -1, 12),( -1, 13),( -1, 14),( -2, 15),( -2, 16),( -2, 17),( -2, 18),( -2, 19),( -2, 20)),
    ((  0,  0),(  0,  1),(  0,  2),(  0,  3),( -1,  4),( -1,  5),( -1,  6),( -1,  7),( -1,  8),( -1,  9),( -2, 10),( -2, 11),( -2, 12),( -2, 13),( -2, 14),( -2, 15),( -2, 16),( -3, 17),( -3, 18),( -3, 19),( -3, 20)),
    ((  0,  0),(  0,  1),(  0,  2),( -1,  3),( -1,  4),( -1,  5),( -1,  6),( -1,  7),( -2,  8),( -2,  9),( -2, 10),( -2, 11),( -2, 12),( -3, 13),( -3, 14),( -3, 15),( -3, 16),( -3, 17),( -4, 18),( -4, 19),( -4, 20)),
    ((  0,  0),(  0,  1),( -1,  2),( -1,  3),( -1,  4),( -1,  5),( -2,  6),( -2,  7),( -2,  8),( -2,  9),( -3, 10),( -3, 11),( -3, 12),( -3, 13),( -4, 14),( -4, 15),( -4, 16),( -4, 17),( -5, 18),( -5, 19),( -5, 20)),
    ((  0,  0),(  0,  1),( -1,  2),( -1,  3),( -1,  4),( -2,  5),( -2,  6),( -2,  7),( -2,  8),( -3,  9),( -3, 10),( -3, 11),( -4, 12),( -4, 13),( -4, 14),( -5, 15),( -5, 16),( -5, 17),( -5, 18),( -6, 19),( -6, 20)),
    ((  0,  0),(  0,  1),( -1,  2),( -1,  3),( -1,  4),( -2,  5),( -2,  6),( -2,  7),( -3,  8),( -3,  9),( -4, 10),( -4, 11),( -4, 12),( -5, 13),( -5, 14),( -5, 15),( -6, 16),( -6, 17),( -6, 18),( -7, 19),( -7, 20)),
    ((  0,  0),(  0,  1),( -1,  2),( -1,  3),( -2,  4),( -2,  5),( -2,  6),( -3,  7),( -3,  8),( -4,  9),( -4, 10),( -4, 11),( -5, 12),( -5, 13),( -6, 14),( -6, 15),( -6, 16),( -7, 17),( -7, 18),( -8, 19),( -8, 20)),
    ((  0,  0),(  0,  1),( -1,  2),( -1,  3),( -2,  4),( -2,  5),( -3,  6),( -3,  7),( -4,  8),( -4,  9),( -5, 10),( -5, 11),( -5, 12),( -6, 13),( -6, 14),( -7, 15),( -7, 16),( -8, 17),( -8, 18),( -9, 19),( -9, 20)),
    ((  0,  0),( -1,  1),( -1,  2),( -2,  3),( -2,  4),( -3,  5),( -3,  6),( -4,  7),( -4,  8),( -5,  9),( -5, 10),( -6, 11),( -6, 12),( -7, 13),( -7, 14),( -8, 15),( -8, 16),( -9, 17),( -9, 18),(-10, 19),(-10, 20)),
    ((  0,  0),( -1,  1),( -1,  2),( -2,  3),( -2,  4),( -3,  5),( -3,  6),( -4,  7),( -4,  8),( -5,  9),( -6, 10),( -6, 11),( -7, 12),( -7, 13),( -8, 14),( -8, 15),( -9, 16),( -9, 17),(-10, 18),(-10, 19),(-11, 20)),
    ((  0,  0),( -1,  1),( -1,  2),( -2,  3),( -2,  4),( -3,  5),( -4,  6),( -4,  7),( -5,  8),( -5,  9),( -6, 10),( -7, 11),( -7, 12),( -8, 13),( -8, 14),( -9, 15),(-10, 16),(-10, 17),(-11, 18),(-11, 19),(-12, 20)),
    ((  0,  0),( -1,  1),( -1,  2),( -2,  3),( -3,  4),( -3,  5),( -4,  6),( -5,  7),( -5,  8),( -6,  9),( -7, 10),( -7, 11),( -8, 12),( -8, 13),( -9, 14),(-10, 15),(-10, 16),(-11, 17),(-12, 18),(-12, 19),(-13, 20)),
    ((  0,  0),( -1,  1),( -1,  2),( -2,  3),( -3,  4),( -4,  5),( -4,  6),( -5,  7),( -6,  8),( -6,  9),( -7, 10),( -8, 11),( -8, 12),( -9, 13),(-10, 14),(-11, 15),(-11, 16),(-12, 17),(-13, 18),(-13, 19),(-14, 20)),
    ((  0,  0),( -1,  1),( -2,  2),( -2,  3),( -3,  4),( -4,  5),( -5,  6),( -5,  7),( -6,  8),( -7,  9),( -8, 10),( -8, 11),( -9, 12),(-10, 13),(-11, 14),(-11, 15),(-12, 16),(-13, 17),(-14, 18),(-14, 19),(-15, 20)),
    ((  0,  0),( -1,  1),( -2,  2),( -2,  3),( -3,  4),( -4,  5),( -5,  6),( -6,  7),( -6,  8),( -7,  9),( -8, 10),( -9, 11),(-10, 12),(-10, 13),(-11, 14),(-12, 15),(-13, 16),(-14, 17),(-14, 18),(-15, 19),(-16, 20)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -3,  4),( -4,  5),( -5,  6),( -6,  7),( -7,  8),( -8,  9),( -9, 10),( -9, 11),(-10, 12),(-11, 13),(-12, 14),(-13, 15),(-14, 16),(-14, 17),(-15, 18),(-16, 19),(-17, 20)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -4,  4),( -5,  5),( -5,  6),( -6,  7),( -7,  8),( -8,  9),( -9, 10),(-10, 11),(-11, 12),(-12, 13),(-13, 14),(-14, 15),(-14, 16),(-15, 17),(-16, 18),(-17, 19),(-18, 20)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -4,  4),( -5,  5),( -6,  6),( -7,  7),( -8,  8),( -9,  9),(-10, 10),(-10, 11),(-11, 12),(-12, 13),(-13, 14),(-14, 15),(-15, 16),(-16, 17),(-17, 18),(-18, 19),(-19, 20)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -4,  4),( -5,  5),( -6,  6),( -7,  7),( -8,  8),( -9,  9),(-10, 10),(-11, 11),(-12, 12),(-13, 13),(-14, 14),(-15, 15),(-16, 16),(-17, 17),(-18, 18),(-19, 19),(-20, 20))),
    //14
   (((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4,  0),( -5,  0),( -6,  0),( -7,  0),( -8,  0),( -9,  0),(-10,  0),(-11,  0),(-12,  0),(-13,  0),(-14,  0),(-15,  0),(-16,  0),(-17,  0),(-18,  0),(-19,  0),(-20,  0)),
    ((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4,  0),( -5,  0),( -6,  0),( -7,  0),( -8,  0),( -9,  0),(-10,  1),(-11,  1),(-12,  1),(-13,  1),(-14,  1),(-15,  1),(-16,  1),(-17,  1),(-18,  1),(-19,  1),(-20,  1)),
    ((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4,  0),( -5,  1),( -6,  1),( -7,  1),( -8,  1),( -9,  1),(-10,  1),(-11,  1),(-12,  1),(-13,  1),(-14,  1),(-15,  2),(-16,  2),(-17,  2),(-18,  2),(-19,  2),(-20,  2)),
    ((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4,  1),( -5,  1),( -6,  1),( -7,  1),( -8,  1),( -9,  1),(-10,  2),(-11,  2),(-12,  2),(-13,  2),(-14,  2),(-15,  2),(-16,  2),(-17,  3),(-18,  3),(-19,  3),(-20,  3)),
    ((  0,  0),( -1,  0),( -2,  0),( -3,  1),( -4,  1),( -5,  1),( -6,  1),( -7,  1),( -8,  2),( -9,  2),(-10,  2),(-11,  2),(-12,  2),(-13,  3),(-14,  3),(-15,  3),(-16,  3),(-17,  3),(-18,  4),(-19,  4),(-20,  4)),
    ((  0,  0),( -1,  0),( -2,  1),( -3,  1),( -4,  1),( -5,  1),( -6,  2),( -7,  2),( -8,  2),( -9,  2),(-10,  3),(-11,  3),(-12,  3),(-13,  3),(-14,  4),(-15,  4),(-16,  4),(-17,  4),(-18,  5),(-19,  5),(-20,  5)),
    ((  0,  0),( -1,  0),( -2,  1),( -3,  1),( -4,  1),( -5,  2),( -6,  2),( -7,  2),( -8,  2),( -9,  3),(-10,  3),(-11,  3),(-12,  4),(-13,  4),(-14,  4),(-15,  5),(-16,  5),(-17,  5),(-18,  5),(-19,  6),(-20,  6)),
    ((  0,  0),( -1,  0),( -2,  1),( -3,  1),( -4,  1),( -5,  2),( -6,  2),( -7,  2),( -8,  3),( -9,  3),(-10,  4),(-11,  4),(-12,  4),(-13,  5),(-14,  5),(-15,  5),(-16,  6),(-17,  6),(-18,  6),(-19,  7),(-20,  7)),
    ((  0,  0),( -1,  0),( -2,  1),( -3,  1),( -4,  2),( -5,  2),( -6,  2),( -7,  3),( -8,  3),( -9,  4),(-10,  4),(-11,  4),(-12,  5),(-13,  5),(-14,  6),(-15,  6),(-16,  6),(-17,  7),(-18,  7),(-19,  8),(-20,  8)),
    ((  0,  0),( -1,  0),( -2,  1),( -3,  1),( -4,  2),( -5,  2),( -6,  3),( -7,  3),( -8,  4),( -9,  4),(-10,  5),(-11,  5),(-12,  5),(-13,  6),(-14,  6),(-15,  7),(-16,  7),(-17,  8),(-18,  8),(-19,  9),(-20,  9)),
    ((  0,  0),( -1,  1),( -2,  1),( -3,  2),( -4,  2),( -5,  3),( -6,  3),( -7,  4),( -8,  4),( -9,  5),(-10,  5),(-11,  6),(-12,  6),(-13,  7),(-14,  7),(-15,  8),(-16,  8),(-17,  9),(-18,  9),(-19, 10),(-20, 10)),
    ((  0,  0),( -1,  1),( -2,  1),( -3,  2),( -4,  2),( -5,  3),( -6,  3),( -7,  4),( -8,  4),( -9,  5),(-10,  6),(-11,  6),(-12,  7),(-13,  7),(-14,  8),(-15,  8),(-16,  9),(-17,  9),(-18, 10),(-19, 10),(-20, 11)),
    ((  0,  0),( -1,  1),( -2,  1),( -3,  2),( -4,  2),( -5,  3),( -6,  4),( -7,  4),( -8,  5),( -9,  5),(-10,  6),(-11,  7),(-12,  7),(-13,  8),(-14,  8),(-15,  9),(-16, 10),(-17, 10),(-18, 11),(-19, 11),(-20, 12)),
    ((  0,  0),( -1,  1),( -2,  1),( -3,  2),( -4,  3),( -5,  3),( -6,  4),( -7,  5),( -8,  5),( -9,  6),(-10,  7),(-11,  7),(-12,  8),(-13,  8),(-14,  9),(-15, 10),(-16, 10),(-17, 11),(-18, 12),(-19, 12),(-20, 13)),
    ((  0,  0),( -1,  1),( -2,  1),( -3,  2),( -4,  3),( -5,  4),( -6,  4),( -7,  5),( -8,  6),( -9,  6),(-10,  7),(-11,  8),(-12,  8),(-13,  9),(-14, 10),(-15, 11),(-16, 11),(-17, 12),(-18, 13),(-19, 13),(-20, 14)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  2),( -4,  3),( -5,  4),( -6,  5),( -7,  5),( -8,  6),( -9,  7),(-10,  8),(-11,  8),(-12,  9),(-13, 10),(-14, 11),(-15, 11),(-16, 12),(-17, 13),(-18, 14),(-19, 14),(-20, 15)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  2),( -4,  3),( -5,  4),( -6,  5),( -7,  6),( -8,  6),( -9,  7),(-10,  8),(-11,  9),(-12, 10),(-13, 10),(-14, 11),(-15, 12),(-16, 13),(-17, 14),(-18, 14),(-19, 15),(-20, 16)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -4,  3),( -5,  4),( -6,  5),( -7,  6),( -8,  7),( -9,  8),(-10,  9),(-11,  9),(-12, 10),(-13, 11),(-14, 12),(-15, 13),(-16, 14),(-17, 14),(-18, 15),(-19, 16),(-20, 17)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -4,  4),( -5,  5),( -6,  5),( -7,  6),( -8,  7),( -9,  8),(-10,  9),(-11, 10),(-12, 11),(-13, 12),(-14, 13),(-15, 14),(-16, 14),(-17, 15),(-18, 16),(-19, 17),(-20, 18)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -4,  4),( -5,  5),( -6,  6),( -7,  7),( -8,  8),( -9,  9),(-10, 10),(-11, 10),(-12, 11),(-13, 12),(-14, 13),(-15, 14),(-16, 15),(-17, 16),(-18, 17),(-19, 18),(-20, 19)),
    ((  0,  0),( -1,  1),( -2,  2),( -3,  3),( -4,  4),( -5,  5),( -6,  6),( -7,  7),( -8,  8),( -9,  9),(-10, 10),(-11, 11),(-12, 12),(-13, 13),(-14, 14),(-15, 15),(-16, 16),(-17, 17),(-18, 18),(-19, 19),(-20, 20))),
    //47
   (((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4,  0),( -5,  0),( -6,  0),( -7,  0),( -8,  0),( -9,  0),(-10,  0),(-11,  0),(-12,  0),(-13,  0),(-14,  0),(-15,  0),(-16,  0),(-17,  0),(-18,  0),(-19,  0),(-20,  0)),
    ((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4,  0),( -5,  0),( -6,  0),( -7,  0),( -8,  0),( -9,  0),(-10, -1),(-11, -1),(-12, -1),(-13, -1),(-14, -1),(-15, -1),(-16, -1),(-17, -1),(-18, -1),(-19, -1),(-20, -1)),
    ((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4,  0),( -5, -1),( -6, -1),( -7, -1),( -8, -1),( -9, -1),(-10, -1),(-11, -1),(-12, -1),(-13, -1),(-14, -1),(-15, -2),(-16, -2),(-17, -2),(-18, -2),(-19, -2),(-20, -2)),
    ((  0,  0),( -1,  0),( -2,  0),( -3,  0),( -4, -1),( -5, -1),( -6, -1),( -7, -1),( -8, -1),( -9, -1),(-10, -2),(-11, -2),(-12, -2),(-13, -2),(-14, -2),(-15, -2),(-16, -2),(-17, -3),(-18, -3),(-19, -3),(-20, -3)),
    ((  0,  0),( -1,  0),( -2,  0),( -3, -1),( -4, -1),( -5, -1),( -6, -1),( -7, -1),( -8, -2),( -9, -2),(-10, -2),(-11, -2),(-12, -2),(-13, -3),(-14, -3),(-15, -3),(-16, -3),(-17, -3),(-18, -4),(-19, -4),(-20, -4)),
    ((  0,  0),( -1,  0),( -2, -1),( -3, -1),( -4, -1),( -5, -1),( -6, -2),( -7, -2),( -8, -2),( -9, -2),(-10, -3),(-11, -3),(-12, -3),(-13, -3),(-14, -4),(-15, -4),(-16, -4),(-17, -4),(-18, -5),(-19, -5),(-20, -5)),
    ((  0,  0),( -1,  0),( -2, -1),( -3, -1),( -4, -1),( -5, -2),( -6, -2),( -7, -2),( -8, -2),( -9, -3),(-10, -3),(-11, -3),(-12, -4),(-13, -4),(-14, -4),(-15, -5),(-16, -5),(-17, -5),(-18, -5),(-19, -6),(-20, -6)),
    ((  0,  0),( -1,  0),( -2, -1),( -3, -1),( -4, -1),( -5, -2),( -6, -2),( -7, -2),( -8, -3),( -9, -3),(-10, -4),(-11, -4),(-12, -4),(-13, -5),(-14, -5),(-15, -5),(-16, -6),(-17, -6),(-18, -6),(-19, -7),(-20, -7)),
    ((  0,  0),( -1,  0),( -2, -1),( -3, -1),( -4, -2),( -5, -2),( -6, -2),( -7, -3),( -8, -3),( -9, -4),(-10, -4),(-11, -4),(-12, -5),(-13, -5),(-14, -6),(-15, -6),(-16, -6),(-17, -7),(-18, -7),(-19, -8),(-20, -8)),
    ((  0,  0),( -1,  0),( -2, -1),( -3, -1),( -4, -2),( -5, -2),( -6, -3),( -7, -3),( -8, -4),( -9, -4),(-10, -5),(-11, -5),(-12, -5),(-13, -6),(-14, -6),(-15, -7),(-16, -7),(-17, -8),(-18, -8),(-19, -9),(-20, -9)),
    ((  0,  0),( -1, -1),( -2, -1),( -3, -2),( -4, -2),( -5, -3),( -6, -3),( -7, -4),( -8, -4),( -9, -5),(-10, -5),(-11, -6),(-12, -6),(-13, -7),(-14, -7),(-15, -8),(-16, -8),(-17, -9),(-18, -9),(-19,-10),(-20,-10)),
    ((  0,  0),( -1, -1),( -2, -1),( -3, -2),( -4, -2),( -5, -3),( -6, -3),( -7, -4),( -8, -4),( -9, -5),(-10, -6),(-11, -6),(-12, -7),(-13, -7),(-14, -8),(-15, -8),(-16, -9),(-17, -9),(-18,-10),(-19,-10),(-20,-11)),
    ((  0,  0),( -1, -1),( -2, -1),( -3, -2),( -4, -2),( -5, -3),( -6, -4),( -7, -4),( -8, -5),( -9, -5),(-10, -6),(-11, -7),(-12, -7),(-13, -8),(-14, -8),(-15, -9),(-16,-10),(-17,-10),(-18,-11),(-19,-11),(-20,-12)),
    ((  0,  0),( -1, -1),( -2, -1),( -3, -2),( -4, -3),( -5, -3),( -6, -4),( -7, -5),( -8, -5),( -9, -6),(-10, -7),(-11, -7),(-12, -8),(-13, -8),(-14, -9),(-15,-10),(-16,-10),(-17,-11),(-18,-12),(-19,-12),(-20,-13)),
    ((  0,  0),( -1, -1),( -2, -1),( -3, -2),( -4, -3),( -5, -4),( -6, -4),( -7, -5),( -8, -6),( -9, -6),(-10, -7),(-11, -8),(-12, -8),(-13, -9),(-14,-10),(-15,-11),(-16,-11),(-17,-12),(-18,-13),(-19,-13),(-20,-14)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -2),( -4, -3),( -5, -4),( -6, -5),( -7, -5),( -8, -6),( -9, -7),(-10, -8),(-11, -8),(-12, -9),(-13,-10),(-14,-11),(-15,-11),(-16,-12),(-17,-13),(-18,-14),(-19,-14),(-20,-15)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -2),( -4, -3),( -5, -4),( -6, -5),( -7, -6),( -8, -6),( -9, -7),(-10, -8),(-11, -9),(-12,-10),(-13,-10),(-14,-11),(-15,-12),(-16,-13),(-17,-14),(-18,-14),(-19,-15),(-20,-16)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -4, -3),( -5, -4),( -6, -5),( -7, -6),( -8, -7),( -9, -8),(-10, -9),(-11, -9),(-12,-10),(-13,-11),(-14,-12),(-15,-13),(-16,-14),(-17,-14),(-18,-15),(-19,-16),(-20,-17)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -4, -4),( -5, -5),( -6, -5),( -7, -6),( -8, -7),( -9, -8),(-10, -9),(-11,-10),(-12,-11),(-13,-12),(-14,-13),(-15,-14),(-16,-14),(-17,-15),(-18,-16),(-19,-17),(-20,-18)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -4, -4),( -5, -5),( -6, -6),( -7, -7),( -8, -8),( -9, -9),(-10,-10),(-11,-10),(-12,-11),(-13,-12),(-14,-13),(-15,-14),(-16,-15),(-17,-16),(-18,-17),(-19,-18),(-20,-19)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -4, -4),( -5, -5),( -6, -6),( -7, -7),( -8, -8),( -9, -9),(-10,-10),(-11,-11),(-12,-12),(-13,-13),(-14,-14),(-15,-15),(-16,-16),(-17,-17),(-18,-18),(-19,-19),(-20,-20))),
    //78
   (((  0,  0),(  0, -1),(  0, -2),(  0, -3),(  0, -4),(  0, -5),(  0, -6),(  0, -7),(  0, -8),(  0, -9),(  0,-10),(  0,-11),(  0,-12),(  0,-13),(  0,-14),(  0,-15),(  0,-16),(  0,-17),(  0,-18),(  0,-19),(  0,-20)),
    ((  0,  0),(  0, -1),(  0, -2),(  0, -3),(  0, -4),(  0, -5),(  0, -6),(  0, -7),(  0, -8),(  0, -9),( -1,-10),( -1,-11),( -1,-12),( -1,-13),( -1,-14),( -1,-15),( -1,-16),( -1,-17),( -1,-18),( -1,-19),( -1,-20)),
    ((  0,  0),(  0, -1),(  0, -2),(  0, -3),(  0, -4),( -1, -5),( -1, -6),( -1, -7),( -1, -8),( -1, -9),( -1,-10),( -1,-11),( -1,-12),( -1,-13),( -1,-14),( -2,-15),( -2,-16),( -2,-17),( -2,-18),( -2,-19),( -2,-20)),
    ((  0,  0),(  0, -1),(  0, -2),(  0, -3),( -1, -4),( -1, -5),( -1, -6),( -1, -7),( -1, -8),( -1, -9),( -2,-10),( -2,-11),( -2,-12),( -2,-13),( -2,-14),( -2,-15),( -2,-16),( -3,-17),( -3,-18),( -3,-19),( -3,-20)),
    ((  0,  0),(  0, -1),(  0, -2),( -1, -3),( -1, -4),( -1, -5),( -1, -6),( -1, -7),( -2, -8),( -2, -9),( -2,-10),( -2,-11),( -2,-12),( -3,-13),( -3,-14),( -3,-15),( -3,-16),( -3,-17),( -4,-18),( -4,-19),( -4,-20)),
    ((  0,  0),(  0, -1),( -1, -2),( -1, -3),( -1, -4),( -1, -5),( -2, -6),( -2, -7),( -2, -8),( -2, -9),( -3,-10),( -3,-11),( -3,-12),( -3,-13),( -4,-14),( -4,-15),( -4,-16),( -4,-17),( -5,-18),( -5,-19),( -5,-20)),
    ((  0,  0),(  0, -1),( -1, -2),( -1, -3),( -1, -4),( -2, -5),( -2, -6),( -2, -7),( -2, -8),( -3, -9),( -3,-10),( -3,-11),( -4,-12),( -4,-13),( -4,-14),( -5,-15),( -5,-16),( -5,-17),( -5,-18),( -6,-19),( -6,-20)),
    ((  0,  0),(  0, -1),( -1, -2),( -1, -3),( -1, -4),( -2, -5),( -2, -6),( -2, -7),( -3, -8),( -3, -9),( -4,-10),( -4,-11),( -4,-12),( -5,-13),( -5,-14),( -5,-15),( -6,-16),( -6,-17),( -6,-18),( -7,-19),( -7,-20)),
    ((  0,  0),(  0, -1),( -1, -2),( -1, -3),( -2, -4),( -2, -5),( -2, -6),( -3, -7),( -3, -8),( -4, -9),( -4,-10),( -4,-11),( -5,-12),( -5,-13),( -6,-14),( -6,-15),( -6,-16),( -7,-17),( -7,-18),( -8,-19),( -8,-20)),
    ((  0,  0),(  0, -1),( -1, -2),( -1, -3),( -2, -4),( -2, -5),( -3, -6),( -3, -7),( -4, -8),( -4, -9),( -5,-10),( -5,-11),( -5,-12),( -6,-13),( -6,-14),( -7,-15),( -7,-16),( -8,-17),( -8,-18),( -9,-19),( -9,-20)),
    ((  0,  0),( -1, -1),( -1, -2),( -2, -3),( -2, -4),( -3, -5),( -3, -6),( -4, -7),( -4, -8),( -5, -9),( -5,-10),( -6,-11),( -6,-12),( -7,-13),( -7,-14),( -8,-15),( -8,-16),( -9,-17),( -9,-18),(-10,-19),(-10,-20)),
    ((  0,  0),( -1, -1),( -1, -2),( -2, -3),( -2, -4),( -3, -5),( -3, -6),( -4, -7),( -4, -8),( -5, -9),( -6,-10),( -6,-11),( -7,-12),( -7,-13),( -8,-14),( -8,-15),( -9,-16),( -9,-17),(-10,-18),(-10,-19),(-11,-20)),
    ((  0,  0),( -1, -1),( -1, -2),( -2, -3),( -2, -4),( -3, -5),( -4, -6),( -4, -7),( -5, -8),( -5, -9),( -6,-10),( -7,-11),( -7,-12),( -8,-13),( -8,-14),( -9,-15),(-10,-16),(-10,-17),(-11,-18),(-11,-19),(-12,-20)),
    ((  0,  0),( -1, -1),( -1, -2),( -2, -3),( -3, -4),( -3, -5),( -4, -6),( -5, -7),( -5, -8),( -6, -9),( -7,-10),( -7,-11),( -8,-12),( -8,-13),( -9,-14),(-10,-15),(-10,-16),(-11,-17),(-12,-18),(-12,-19),(-13,-20)),
    ((  0,  0),( -1, -1),( -1, -2),( -2, -3),( -3, -4),( -4, -5),( -4, -6),( -5, -7),( -6, -8),( -6, -9),( -7,-10),( -8,-11),( -8,-12),( -9,-13),(-10,-14),(-11,-15),(-11,-16),(-12,-17),(-13,-18),(-13,-19),(-14,-20)),
    ((  0,  0),( -1, -1),( -2, -2),( -2, -3),( -3, -4),( -4, -5),( -5, -6),( -5, -7),( -6, -8),( -7, -9),( -8,-10),( -8,-11),( -9,-12),(-10,-13),(-11,-14),(-11,-15),(-12,-16),(-13,-17),(-14,-18),(-14,-19),(-15,-20)),
    ((  0,  0),( -1, -1),( -2, -2),( -2, -3),( -3, -4),( -4, -5),( -5, -6),( -6, -7),( -6, -8),( -7, -9),( -8,-10),( -9,-11),(-10,-12),(-10,-13),(-11,-14),(-12,-15),(-13,-16),(-14,-17),(-14,-18),(-15,-19),(-16,-20)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -3, -4),( -4, -5),( -5, -6),( -6, -7),( -7, -8),( -8, -9),( -9,-10),( -9,-11),(-10,-12),(-11,-13),(-12,-14),(-13,-15),(-14,-16),(-14,-17),(-15,-18),(-16,-19),(-17,-20)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -4, -4),( -5, -5),( -5, -6),( -6, -7),( -7, -8),( -8, -9),( -9,-10),(-10,-11),(-11,-12),(-12,-13),(-13,-14),(-14,-15),(-14,-16),(-15,-17),(-16,-18),(-17,-19),(-18,-20)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -4, -4),( -5, -5),( -6, -6),( -7, -7),( -8, -8),( -9, -9),(-10,-10),(-10,-11),(-11,-12),(-12,-13),(-13,-14),(-14,-15),(-15,-16),(-16,-17),(-17,-18),(-18,-19),(-19,-20)),
    ((  0,  0),( -1, -1),( -2, -2),( -3, -3),( -4, -4),( -5, -5),( -6, -6),( -7, -7),( -8, -8),( -9, -9),(-10,-10),(-11,-11),(-12,-12),(-13,-13),(-14,-14),(-15,-15),(-16,-16),(-17,-17),(-18,-18),(-19,-19),(-20,-20))));
{$EndIf}
CONSTRUCTOR TLOCWorld.Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MapSizeX:=0;
    MapSizeY:=0;
    OnSelect:=False;
    SetupTileAttribute;

    //Frame tile reference setup
    FillChar(FrameTile,SizeOf(FrameTile),0);
    FrameTile[000]:=0;
    FrameTile[038]:=1;//2+4+32
    FrameTile[054]:=1;//2+4+32+16
    FrameTile[102]:=1;//2+4+32+64
    FrameTile[118]:=1;//2+4+32+16+64
    FrameTile[166]:=1;//2+4+32+128
    FrameTile[174]:=1;//2+4+32+8+128
    FrameTile[167]:=1;//2+4+32+1+128
    FrameTile[190]:=1;//2+4+32+8+128+16
    FrameTile[231]:=1;//2+4+32+1+128+64
    FrameTile[230]:=1;//2+4+32+64+128
    FrameTile[182]:=1;//2+4+32+16+128
    FrameTile[246]:=1;//2+4+32+16+64+128

    FrameTile[076]:=2;//4+8+64
    FrameTile[204]:=2;//4+8+64+128
    FrameTile[108]:=2;//4+8+64+32
    FrameTile[236]:=2;//4+8+64+32+128
    FrameTile[092]:=2;//4+8+64+16
    FrameTile[093]:=2;//4+8+64+16+1
    FrameTile[094]:=2;//4+8+64+16+2
    FrameTile[125]:=2;//4+8+64+16+1+32
    FrameTile[222]:=2;//4+8+64+16+2+128
    FrameTile[220]:=2;//4+8+64+128+16
    FrameTile[124]:=2;//4+8+64+32+16
    FrameTile[252]:=2;//4+8+64+32+128+16

    FrameTile[110]:=3;
    FrameTile[126]:=3;
    FrameTile[238]:=3;
    FrameTile[254]:=3;

    FrameTile[019]:=8;//1+2+16
    FrameTile[147]:=8;//1+2+16+128
    FrameTile[051]:=8;//1+2+16+32
    FrameTile[179]:=8;//1+2+16+32+128
    FrameTile[215]:=8;//1+2+4+16+64+128
    FrameTile[115]:=8;//1+2+16+32+64
    FrameTile[087]:=8;//1+2+4+16+64
    FrameTile[091]:=8;//1+2+8+16+64
    FrameTile[083]:=8;//1+2+16+64
    FrameTile[211]:=8;//1+2+16+64+128
    FrameTile[123]:=8;//1+2+8+16+32+64
    FrameTile[243]:=8;//1+2+16+32+64+128
    //FrameTile[163]:=8;//

    FrameTile[055]:=9;
    FrameTile[183]:=9;
    FrameTile[119]:=9;
    FrameTile[247]:=9;

    FrameTile[095]:=10;
    FrameTile[083]:=8;
    FrameTile[092]:=2;

    FrameTile[127]:=11;

    FrameTile[137]:=16;//1+8+128
    FrameTile[153]:=16;//1+8+16+128
    FrameTile[201]:=16;//1+8+64+128
    FrameTile[217]:=16;//1+8+16+64+128
    FrameTile[189]:=16;//1+4+8+16+32+128
    FrameTile[233]:=16;//1+8+32+64+128
    FrameTile[173]:=16;//1+8+128+4+32
    FrameTile[171]:=16;//1+8+128+2+32
    FrameTile[169]:=16;//1+8+128+32
    FrameTile[185]:=16;//1+8+128+32+16
    FrameTile[235]:=16;//1+8+128+64+32+2
    FrameTile[249]:=16;//1+8+128+64+32+16
  
    //FrameTile[089]:=16;//

    FrameTile[175]:=17;
    FrameTile[166]:=1;
    FrameTile[169]:=16;

    FrameTile[205]:=18;
    FrameTile[221]:=18;
    FrameTile[237]:=18;
    FrameTile[253]:=18;
  
    FrameTile[239]:=19;
  
    FrameTile[155]:=24;
    FrameTile[219]:=24;
    FrameTile[187]:=24;
    FrameTile[251]:=24;

    FrameTile[191]:=25;
    FrameTile[223]:=26;
    FrameTile[255]:=0;
    //
    FrameTile2[00]:=4;
    FrameTile2[01]:=5;
    FrameTile2[02]:=6;
    FrameTile2[03]:=7;
    FrameTile2[04]:=12;
    FrameTile2[05]:=13;
    FrameTile2[06]:=14;
    FrameTile2[07]:=15;
    FrameTile2[08]:=20;
    FrameTile2[09]:=21;
    FrameTile2[10]:=22;
    FrameTile2[11]:=23;
    FrameTile2[12]:=28;
    FrameTile2[13]:=29;
    FrameTile2[14]:=30;
    FrameTile2[15]:=31;
  End;

DESTRUCTOR TLOCWorld.Destroy;
  Begin
    FreeMap;
  End;

PROCEDURE TLOCWorld.FreeMap;
  Begin
    MapSizeX:=0;
    MapSizeY:=0;
    MapTileSizeX:=0;
    MapTileSizeY:=0;
    SetLength(MapTile,0,0);
    SetLength(MapTileFrame,0,0);
    SetLength(MapTileHeight,0,0);
    SetLength(MapAttr,0,0);
    SetLength(MapNum,0,0);
    SetLength(MapTrueSight,0,0);
    SetLength(MapUnitUnderFog,0,0);
    SetLength(AStarMatrix,0);
    SetLength(CloseSet,0);
    SetLength(OpenSet,0);
    SetLength(PathHead,0);
  End;

FUNCTION  TLOCWorld.GetTile(TileX,TileY : FastInt;Level : TMapTile) : Boolean;
  Begin
    If (TileX<0) or (TileX>=MapTileSizeX) or
       (TileY<0) or (TileY>=MapTileSizeY) then Result:=False
    Else Result:=MapTile[TileX,TileY] and TileSetValue[Level]=TileSetValue[Level];
  End;

FUNCTION  TLOCWorld.GetLastTile(TileX,TileY : FastInt) : TMapTile;
  Var Tile : TMapTile;
  Begin
    For Tile:=Ice downto Desert do
      If GetTile(TileX,TileY,Tile) then
        Begin
          Result:=Tile;
          Exit;
        End;
    Result:=Water;
  End;

PROCEDURE TLOCWorld.UpDateTile(TileX,TileY : FastInt);
  Var Tile  : TMapTile;
      Frame : Byte;
  Begin
    Tile:=GetLastTile(TileX,TileY);
    Frame:=GetTileFrame(TileX,TileY,Tile);
    Case Tile of
      Desert :
        Begin
          If Frame=255 then
            Begin
              SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              Exit;
            End;
          Case FrameTile[Frame] of
            01 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            02 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            03 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            08 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            09 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            10 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            11 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            16 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            17 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            18 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            19 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            24 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            25 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            26 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            255 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            Else
              Begin
                ClearTile(TileX,TileY,Tile);
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
          End;
        End;
      Dirt,
      Grass,
      DarkGrass :
        Begin
          If Frame=255 then
            Begin
              SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              Exit;
            End;
          Case FrameTile[Frame] of
            01 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            02 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            03 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            08 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            09 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            10 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            11 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            16 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            17 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            18 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            19 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            24 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            25 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            26 :
              Begin
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
            255 :
              Begin
              End;
            Else
              Begin
                ClearTile(TileX,TileY,Tile);
                {SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);{}
              End;
          End;
        End;
      Rock,DarkRock,Snow,Ice :
        Begin
          If Frame=255 then
            Begin
              SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
              SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              Exit;
            End;
          Case FrameTile[Frame] of
            01 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            02 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            03 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            08 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            09 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            10 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            11 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            16 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            17 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            18 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            19 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            24 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            25 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,True);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            26 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,True);
              End;
            255 :
              Begin
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
            Else
              Begin
                ClearTile(TileX,TileY,Tile);
                SetTileAttr(TileX*2+1,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+1,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+0,TileY*2+0,MapUsedByLandUnit,False);
                SetTileAttr(TileX*2+1,TileY*2+1,MapUsedByLandUnit,False);
              End;
          End;
        End;
      Else
        Begin
        End;
    End;
  End;

PROCEDURE TLOCWorld.SetTileFrame(TileX,TileY : FastInt;TileFrame : TMapTileFrame);
  Begin
    //This safe code because TileFrame limit on 0..15
    MapTileFrame[TileX,TileY]:=TileFrame mod 16;
  End;

PROCEDURE TLOCWorld.SetTileHeight(TileX,TileY : FastInt;TileHeight : TMapTileHeight);
  Begin
    MapTileHeight[TileX,TileY]:=TileHeight;
  End;

PROCEDURE TLOCWorld.SetTile(TileX,TileY : FastInt;Level : TMapTile;TileFrame : TMapTileFrame);
  Begin
    If (TileX<0) or (TileX>=MapTileSizeX) or
       (TileY<0) or (TileY>=MapTileSizeY) then Exit;
    //If MapTile[TileX,TileY] and TileSetValue[Level]<>TileSetValue[Level] then
      MapTile[TileX,TileY]:=MapTile[TileX,TileY] or TileSetValue[Level];
    SetTileFrame(TileX,TileY,TileFrame);
  End;

PROCEDURE TLOCWorld.SetTile(TileX,TileY : FastInt;Level : TMapTile;
                            TileFrame : TMapTileFrame;TileHeight : TMapTileHeight);
  Begin
    If (TileX<0) or (TileX>=MapTileSizeX) or
       (TileY<0) or (TileY>=MapTileSizeY) then Exit;
    //If MapTile[TileX,TileY] and TileSetValue[Level]<>TileSetValue[Level] then
      MapTile[TileX,TileY]:=MapTile[TileX,TileY] or TileSetValue[Level];
    SetTileFrame(TileX,TileY,TileFrame);
    SetTileHeight(TileX,TileY,TileHeight);
  End;
  
PROCEDURE TLOCWorld.ClearTile(TileX,TileY : FastInt);
  Begin
    If (TileX<0) or (TileX>=MapTileSizeX) or
       (TileY<0) or (TileY>=MapTileSizeY) then Exit;
    MapTile[TileX,TileY]:=0;
  End;

PROCEDURE TLOCWorld.ClearTile(TileX,TileY : FastInt;Level : TMapTile);
  Begin
    If (TileX<0) or (TileX>=MapTileSizeX) or
       (TileY<0) or (TileY>=MapTileSizeY) then Exit;
    If MapTile[TileX,TileY] and TileSetValue[Level]=TileSetValue[Level] then
      MapTile[TileX,TileY]:=MapTile[TileX,TileY] xor TileSetValue[Level];
  End;

PROCEDURE TLOCWorld.ClearTileAt(TileX,TileY : FastInt;Level : TMapTile);
  Var Tmp : TMapTile;
  Begin
    If (TileX<0) or (TileX>=MapTileSizeX) or
       (TileY<0) or (TileY>=MapTileSizeY) then Exit;
    For Tmp:=Level to High(TMapTile) do
      If MapTile[TileX,TileY] and TileSetValue[Tmp]=TileSetValue[Tmp] then
        MapTile[TileX,TileY]:=MapTile[TileX,TileY] xor TileSetValue[Tmp];
    //MapTile[TileX,TileY]:=0;
  End;

PROCEDURE TLOCWorld.SetTileAttr(TileX,TileY : FastInt;SetMapAttr : TMapAttr;SwitchOn : Boolean);
  Begin
    If (TileX<0) or (TileX>=MapSizeX) or
       (TileY<0) or (TileY>=MapSizeY) then Exit;
    If SwitchOn then
      Begin
        If MapAttr[TileX,TileY] and SetMapAttr=SetMapAttr then
        Else MapAttr[TileX,TileY]:=MapAttr[TileX,TileY] xor SetMapAttr;
      End
    Else
      Begin
        If MapAttr[TileX,TileY] and SetMapAttr=SetMapAttr then
          MapAttr[TileX,TileY]:=MapAttr[TileX,TileY] xor SetMapAttr;
      End;
  End;

FUNCTION  TLOCWorld.GetTileAttr(TileX,TileY : FastInt;SetMapAttr : TMapAttr) : Boolean;
  Begin
    If (TileX<0) or (TileX>=MapSizeX) or
       (TileY<0) or (TileY>=MapSizeY) then
      Begin
        Result:=False;
        Exit;
      End;
    Result:=MapAttr[TileX,TileY] and SetMapAttr=SetMapAttr;
  End;

PROCEDURE TLOCWorld.SetTrueSight(Clan : TClan;TileX,TileY : FastInt;SwitchOn : Boolean);
  Begin
    If (TileX<0) or (TileX>=MapSizeX) or
       (TileY<0) or (TileY>=MapSizeY) then Exit;
    If SwitchOn then
      Begin
        If MapTrueSight[TileX,TileY] and UnitSawStateMask[Clan]=UnitSawStateMask[Clan] then
        Else MapTrueSight[TileX,TileY]:=MapAttr[TileX,TileY] xor UnitSawStateMask[Clan];
      End
    Else
      Begin
        If MapTrueSight[TileX,TileY] and UnitSawStateMask[Clan]=UnitSawStateMask[Clan] then
          MapTrueSight[TileX,TileY]:=MapAttr[TileX,TileY] xor UnitSawStateMask[Clan];
      End;
  End;

FUNCTION  TLOCWorld.GetTrueSight(Clan : TClan;TileX,TileY : FastInt) : Boolean;
  Begin
    If (TileX<0) or (TileX>=MapSizeX) or
       (TileY<0) or (TileY>=MapSizeY) then
      Begin
        Result:=False;
        Exit;
      End;
    Result:=MapTrueSight[TileX,TileY] and UnitSawStateMask[Clan]=UnitSawStateMask[Clan];
  End;

FUNCTION  TLOCWorld.GetTileFrame(TileX,TileY : FastInt;Level : TMapTile) : Byte;
  Var Return : Byte;
  Begin
    Return:=0;
    If GetTile(TileX,TileY,Level) then
      Begin
        If GetTile(TileX,TileY-1,Level) then Return:=Return or 1;
        If GetTile(TileX+1,TileY,Level) then Return:=Return or 2;
        If GetTile(TileX,TileY+1,Level) then Return:=Return or 4;
        If GetTile(TileX-1,TileY,Level) then Return:=Return or 8;
        If GetTile(TileX+1,TileY-1,Level) then Return:=Return or 16;
        If GetTile(TileX+1,TileY+1,Level) then Return:=Return or 32;
        If GetTile(TileX-1,TileY+1,Level) then Return:=Return or 64;
        If GetTile(TileX-1,TileY-1,Level) then Return:=Return or 128;
      End;
    Result:=Return;
  End;

PROCEDURE TLOCWorld.UpDateTileAttr;
  Var I,J : FastInt;
  Begin
    For I:=0 to MapTileSizeX-1 do
      For J:=0 to MapTileSizeY-1 do UpDateTile(I,J);
  End;

PROCEDURE TLOCWorld.SetupTileAttribute;
  Var Idx : TMapTile;
  Begin
    For Idx:=Low(TMapTile) to
             High(TMapTile) do TileAttribute[Idx]:=[];
    TileAttribute[Desert  ]:=[TileCantStandOn,TileCantBuildOn];
    TileAttribute[Rock    ]:=[TileCantStandOn,TileCantBuildOn];
    TileAttribute[Snow    ]:=[TileCantStandOn,TileCantBuildOn];
    TileAttribute[Ice     ]:=[TileCantStandOn,TileCantBuildOn];
    TileAttribute[Water   ]:=[TileCantStandOn,TileCantBuildOn];
  End;

PROCEDURE TLOCWorld.RestartMapNum;
  Var I,J : FastInt;
  Begin
    For I:=0 to MapSizeX-1 do
      For J:=0 to MapSizeY-1 do
        Begin
          MapNum[I,J]:=0;
          MapCount[I,J]:=0;
        End;
  End;

PROCEDURE TLOCWorld.SetupMapSize(MapSizeX,MapSizeY : FastInt);
  Begin
    If MapSizeX mod 2=1 then Dec(MapSizeX);
    If MapSizeY mod 2=1 then Dec(MapSizeY);
    Self.MapSizeX:=MapSizeX;
    Self.MapSizeY:=MapSizeY;
    //Map size XxY always modulate by two 
    MapTileSizeX:=MapSizeX div 2;
    MapTileSizeY:=MapSizeY div 2;
    //Free dynamic data
    SetLength(MapTile,0,0);
    SetLength(MapTileFrame,0,0);
    SetLength(MapTileHeight,0,0);
    SetLength(MapAttr,0,0);
    SetLength(MapNum,0,0);
    SetLength(MapTrueSight,0,0);
    SetLength(MapUnitUnderFog,0,0);
    SetLength(AStarMatrix,0);
    SetLength(CloseSet,0);
    SetLength(OpenSet,0);
    SetLength(PathHead,0);
    //Set length of dynamic array
    //Because one tile set four real tile on map then MapTile has maximum size:
    //  [MapSizeX div 2+1,MapSizeY div 2+1]
    SetLength(MapTile,MapTileSizeX,MapTileSizeY);
    //Map Tile Frame like Tile
    SetLength(MapTileFrame,MapTileSizeX,MapTileSizeY);
    SetLength(MapTileHeight,MapTileSizeX,MapTileSizeY);
    //
    SetLength(MapAttr,MapSizeX,MapSizeY);
    SetLength(MapNum,MapSizeX,MapSizeY);
    SetLength(MapTrueSight,MapSizeX,MapSizeY);
    SetLength(MapUnitUnderFog,MapSizeX,MapSizeY);
    {$IfDef LimitAirUnitOnTile}
    SetLength(MapCount,MapSizeX,MapSizeY);
    {$EndIf}
    //Safe for game
    RestartMapNum;
    //For map size less than map view div:
    //If MapSizeX-1<MapViewDivX then MapViewDivX:=MapSizeX-1;
    //If MapSizeY-1<MapViewDivY then MapViewDivY:=MapSizeY-1;
    //Setup AStar find path method database
    AStarMatrixSize:=MapSizeX*MapSizeY;
    SetLength(AStarMatrix,AStarMatrixSize);
    SetLength(PathHead,AStarMatrixSize);
    ThresholdCloseSet:=MapSizeX*MapSizeY div MaxCloseSetRatio;
    SetLength(CloseSet,ThresholdCloseSet);
    OpenSetMaxSize:=MapSizeX*MapSizeY div MaxOpenSetRatio;
    SetLength(OpenSet,OpenSetMaxSize);
    NumInCloseSet:=AStarMatrixSize;
    ClearSet;
  End;

PROCEDURE TLOCWorld.RestartMapTile;
  Var I,J : FastInt;
  Begin
    //Current default map is 512x512, then default map tile is 256x256
    For I:=0 to MapSizeX-1 do
      For J:=0 to MapSizeY-1 do
        Begin
          MapAttr[I,J]:=0;
          //All tile can not used to run !
          //SetTileAttr(I,J,MapUsedByLandUnit,True);
          SetTileAttr(I,J,MapDontVisited,True);
          SetTileAttr(I,J,MapDontVisible,True);
        End;
    For I:=0 to MapTileSizeX-1 do
      For J:=0 to MapTileSizeY-1 do
        Begin
          SetTile(I,J,Dirt,Random(16));
        End;
  End;

PROCEDURE TLOCWorld.RandomMapTile;
  Var I,J : FastInt;
  Begin
    For I:=50 to 60 do
      For J:=50 to 60 do SetTile(I,J,Snow,Random(16));
    For I:=60 to 70 do
      For J:=60 to 70 do SetTile(I,J,Snow,Random(16));
    For I:=81 to 140 do
      For J:=50 to 70 do SetTile(I,J,Rock,Random(16));
    For I:=161 to 210 do
      For J:=50 to 70 do SetTile(I,J,Snow,Random(16));
    For I:=231 to 280 do
      For J:=50 to 70 do SetTile(I,J,Dirt,Random(16));
    {For I:=100 to 200 do
      SetTile(I,I,Water,Random(16));{}
    {For I:=1 to 10 do
      Begin
        SetTile(I,10,WallRock,Random(16));
        SetTile(10,I,WallRock,Random(16));
      End;
    For I:=0 to 9 do
      For J:=0 to 9 do
        SetTileHeight(I,J,1);
    For I:=20 to 25 do
      Begin
        SetTile(I,20,Water,Random(16));
        SetTile(20,I,Water,Random(16));
      End;{}
  End;

PROCEDURE TLOCWorld.SetupRandomMap(MapSizeX,MapSizeY : FastInt);
  {$IfNDef TestOneUnit}
  Var Z,I,J    : FastInt;
      Clan     : TClan;
      Typer    : TUnit;
  {$Else}
  Var I,J : FastInt;
  {$EndIf}
  Begin
    With MyUnits do
      Begin
        RandSeed:=11012012;
        FreeMap;
        LoadDefaultSetting;
        //Remember, MapTile and MapNum indexed from 0 to MapSize-1
        SetupMapSize(MapSizeX,MapSizeY);
        RestartMapTile;
        RandomMapTile;
        UpDateTileAttr;
        //Setup for fog...
        RestartWorldVisited;
        RestartWorldFog;
        RestartMapUnitUnderFog;
        //Setup player
        SettingClanDefault;
        HumanControl:=C11;
        //Setup for unit
        {$IfDef TestOneUnit}
        NewUnitAt(HumanControl  ,Grunt              ,001,001);
        NewUnitAt(HumanControl  ,Knight             ,002,002);
        NewUnitAt(HumanControl  ,Dragon             ,003,003);
        NewUnitAt(HumanControl  ,DeathWing          ,003,004);
        NewUnitAt(HumanControl  ,Dwarves            ,003,005);
        NewUnitAt(HumanControl  ,Goblin             ,003,006);
        NewUnitAt(HumanControl  ,Xkeleton           ,003,007);
        NewUnitAt(HumanControl  ,Light              ,003,008);
        NewUnitAt(HumanControl  ,Peasant            ,003,009);
        NewUnitAt(HumanControl  ,Peon               ,030,150);
        NewUnitAt(HumanControl  ,Peon               ,110,110);
        NewUnitAt(C2            ,Critter1           ,004,004);
        NewUnitAt(HumanControl  ,Peon               ,079,079);
        NewUnitAt(HumanControl  ,Peasant            ,078,078);
        NewUnitAt(HumanControl  ,Carrier            ,099,079);
        NewUnitAt(HumanControl  ,Intercept          ,098,079);
        NewUnitAt(HumanControl  ,DarkDaemon         ,110,079);
        NewUnitAt(HumanControl  ,DragonMage         ,113,079);
        NewUnitAt(HumanControl  ,GundamBattleShip1  ,118,070);
        NewUnitAt(HumanControl  ,GundamBattleShip2  ,125,070);
        NewUnitAt(HumanControl  ,GundamBattleShip3  ,130,070);
        NewUnitAt(HumanControl  ,SuperDaemon        ,100,079);
        NewUnitAt(HumanControl  ,DragonRide         ,102,079);
        NewUnitAt(HumanControl  ,OgreMagi           ,104,079);
        NewUnitAt(HumanControl  ,DarkDaemon         ,106,079);
        NewUnitAt(HumanControl  ,Arbiter            ,095,077);
        NewUnitAt(HumanControl  ,Mage               ,076,076);
        NewUnitAt(HumanControl  ,DeathKnight        ,077,077);
        NewUnitAt(Gaia          ,ItemStore          ,190,190);
        NewUnitAt(HumanControl  ,AlienConstruction  ,090,090);
        NewUnitAt(HumanControl  ,StrongHold         ,120,090);
        NewUnitAt(C2,Axethrower ,55,55);
        For I:=60 to 65 do
          For J:=60 to 65 do
            NewUnitAt(HumanControl,Light,I,J);
        //
        NewUnitAt(C2            ,Knight     ,192,190);
        NewUnitAt(C2            ,Berserker  ,193,190);
        NewUnitAt(C2            ,Axethrower ,193,191);
        NewUnitAt(C2            ,Peon       ,194,190);
        NewUnitAt(C2            ,Grunt      ,194,195);
        NewUnitAt(C2            ,Grunt      ,194,201);
        NewUnitAt(C2            ,Grunt      ,194,202);
        NewUnitAt(C2            ,Grunt      ,194,203);
        NewUnitAt(C2            ,Grunt      ,194,204);
        NewUnitAt(C2            ,Grunt      ,194,205);
        NewUnitAt(C2            ,Grunt      ,194,206);
        NewUnitAt(C2            ,Grunt      ,194,207);
        //
        NewUnitAt(C3            ,Knight     ,192,020);
        NewUnitAt(C3            ,Berserker  ,193,020);
        NewUnitAt(C3            ,Axethrower ,193,021);
        NewUnitAt(C3            ,Peon       ,194,020);
        NewUnitAt(C3            ,Grunt      ,194,025);
        NewUnitAt(C3            ,Grunt      ,194,011);
        NewUnitAt(C3            ,Grunt      ,194,012);
        NewUnitAt(C3            ,Grunt      ,194,013);
        NewUnitAt(C3            ,Grunt      ,194,014);
        NewUnitAt(C3            ,Grunt      ,194,015);
        NewUnitAt(C3            ,Grunt      ,194,016);
        NewUnitAt(C3            ,Grunt      ,194,017);
        //
        NewUnitAt(C4            ,Ogre       ,002,190);
        NewUnitAt(C4            ,Ranger     ,003,190);
        NewUnitAt(C4            ,Archer     ,003,191);
        NewUnitAt(C4            ,Peasant    ,004,190);
        NewUnitAt(C4            ,FootMan    ,004,195);
        NewUnitAt(C4            ,FootMan    ,014,201);
        NewUnitAt(C4            ,FootMan    ,014,202);
        NewUnitAt(C4            ,FootMan    ,014,203);
        NewUnitAt(C4            ,FootMan    ,014,204);
        NewUnitAt(C4            ,FootMan    ,014,205);
        NewUnitAt(C4            ,FootMan    ,014,206);
        NewUnitAt(C4            ,FootMan    ,014,207);
        //
        NewUnitAt(C5            ,Ogre       ,302,190);
        NewUnitAt(C5            ,Ranger     ,303,190);
        NewUnitAt(C5            ,Archer     ,303,191);
        NewUnitAt(C5            ,Peasant    ,304,190);
        NewUnitAt(C5            ,FootMan    ,304,195);
        NewUnitAt(C5            ,FootMan    ,314,201);
        NewUnitAt(C5            ,FootMan    ,314,202);
        NewUnitAt(C5            ,FootMan    ,314,203);
        NewUnitAt(C5            ,FootMan    ,314,204);
        NewUnitAt(C5            ,FootMan    ,314,205);
        NewUnitAt(C5            ,FootMan    ,314,206);
        NewUnitAt(C5            ,FootMan    ,314,207);
        //
        NewUnitAt(C6            ,Ogre       ,002,490);
        NewUnitAt(C6            ,Ranger     ,003,490);
        NewUnitAt(C6            ,Archer     ,003,491);
        NewUnitAt(C6            ,Peasant    ,004,490);
        NewUnitAt(C6            ,FootMan    ,004,495);
        NewUnitAt(C6            ,FootMan    ,014,501);
        NewUnitAt(C6            ,FootMan    ,014,502);
        NewUnitAt(C6            ,FootMan    ,014,503);
        NewUnitAt(C6            ,FootMan    ,014,504);
        NewUnitAt(C6            ,FootMan    ,014,505);
        NewUnitAt(C6            ,FootMan    ,014,506);
        NewUnitAt(C6            ,FootMan    ,014,507);
        //
        NewUnitAt('CrazyBabe',C7,Knight,510,510);
        //
        NewGoldMineAt(2000000,220,200);
        NewGoldMineAt(2000000,320,200);
        NewGoldMineAt(2000000,020,480);
        NewGoldMineAt(2000000,220,020);
        NewGoldMineAt(2000000,020,200);
        NewGoldMineAt(2000000,080,080);
        {$Else}
        NewUnitAt(HumanControl,Light,80,80);
        For Z:=50 to 150 do
          Begin
            NewUnitAt(HumanControl,Light,Z,100);
            NewUnitAt(HumanControl,Light,100,Z);
          End;
        For Z:=1 to TestUnits do
          Begin
            I:=Random(MapSizeX);
            J:=Random(MapSizeY);
            {$IfDef AllIsOwnUnit}
            Clan:=HumanControl;
            {$Else}
            Clan:=C1;
            Case Random(5) of
              0 : Clan:=C1;
              1 : Clan:=C2;
              2 : Clan:=C3;
              4 : Clan:=C4;
            End;{}
            {$EndIf}
            Case Random(26) of
              00 : Typer:=Peon;
              01 : Typer:=Peasant;
              03 : Typer:=Footman;
              04 : Typer:=Grunt;
              05 : Typer:=Archer;
              06 : Typer:=Berserker;
              07 : Typer:=Knight;
              08 : Typer:=OgreMage;
              09 : Typer:=Critter1;
              10 : Typer:=Critter2;
              11 : Typer:=Critter3;
              12 : Typer:=Critter4;
              13 : Typer:=Dragon;
              14 : Typer:=DeathWing;
              15 : Typer:=Xkeleton;
              16 : Typer:=Dwarves;
              17 : Typer:=Goblin;
              18 : Typer:=Mage;
              19 : Typer:=DeathKnight;
              20 : Typer:=Ballista;
              21 : Typer:=Catapul;
              22 : Typer:=FlyingMachine;
              23 : Typer:=Zeppelin;
              24 : Typer:=OgreMage;
              25 : Typer:=Paladin;
              Else Typer:=Peon;
            End;
            NewUnitAt(Clan,Typer,I,J);
          End;
        {$EndIf}
        //Place before setting money of unit
        SetupClan(C1          ,'Crazy Orc'    ,Computer,RaceOrc   ,[150000,0,0]);
        SetupClan(C2          ,'Thrall'       ,Computer,RaceOrc   ,[150000,0,0]);
        SetupClan(C3          ,'Orcish'       ,Computer,RaceOrc   ,[150000,0,0]);
        SetupClan(C4          ,'Blood Hunter' ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C5          ,'King'         ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C6          ,'Lian'         ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C7          ,'Haru'         ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C8          ,'Simba'        ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C9          ,'Samon'        ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C10         ,'Demon'        ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(HumanControl,'Namke'        ,Human   ,RaceOrc   ,[30000,0,0]);
        AdjustMapView;
        SetMapView(MapSizeX div 2,MapSizeY div 2);
      End;
  End;

PROCEDURE TLOCWorld.LoadEmptyMap(MapSizeX,MapSizeY : FastInt);
  Begin
    With MyUnits do
      Begin
        MyUnits.RestartGame;
        RandSeed:=11012012;
        FreeMap;
        LoadDefaultSetting;
        //Remember, MapTile and MapNum indexed from 0 to MapSize-1
        SetupMapSize(MapSizeX,MapSizeY);
        RestartMapTile;
        UpDateTileAttr;
        //Setup for fog...
        RestartWorldVisited;
        RestartWorldFog;
        RestartMapUnitUnderFog;
        //Setup player
        SettingClanDefault;
        HumanControl:=C11;
        //Place before setting money of unit
        SetupClan(C1          ,'Crazy Orc'    ,Computer,RaceOrc   ,[150000,0,0]);
        SetupClan(C2          ,'Thrall'       ,Computer,RaceOrc   ,[150000,0,0]);
        SetupClan(C3          ,'Orcish'       ,Computer,RaceOrc   ,[150000,0,0]);
        SetupClan(C4          ,'Blood Hunter' ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C5          ,'King'         ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C6          ,'Lian'         ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C7          ,'Haru'         ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C8          ,'Simba'        ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C9          ,'Samon'        ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(C10         ,'Demon'        ,Computer,RaceHuman ,[150000,0,0]);
        SetupClan(HumanControl,'Namke'        ,Human   ,RaceOrc   ,[30000,0,0]);
        AdjustMapView;
        SetMapView(MapSizeX div 2,MapSizeY div 2);
      End;
  End;

PROCEDURE TLOCWorld.RestartMapUnitUnderFog;
  Var I,J : FastInt;
  Begin
    For I:=0 to MapSizeX-1 do
      For J:=0 to MapSizeY-1 do
        Begin
          MapUnitUnderFog[I,J]._UnitColor:=Gaia;
          MapUnitUnderFog[I,J]._UnitTyper:=NoneUnit;
        End;
  End;

PROCEDURE TLOCWorld.LoadMap(FileName : String);
  Begin
    MyUnits.RestartGame;
    If FileName='' then
      SetupRandomMap(DefaultMapSize,DefaultMapSize)
    Else
      Begin
      End;
  End;

PROCEDURE TLOCWorld.SetMapView(ViewX,ViewY : FastInt);
  Begin
    MapViewX:=ViewX;
    MapViewY:=ViewY;
    //Map alignment
    If MapViewX<0 then MapViewX:=0;
    If MapViewY<0 then MapViewY:=0;
    If MapViewX+DefaultMapViewX>=MapSizeX then MapViewX:=MapSizeX-DefaultMapViewX-1;
    If MapViewY+DefaultMapViewY>=MapSizeY then MapViewY:=MapSizeY-DefaultMapViewY-1;
    //Viewmap alignment
    If MapViewX<MapViewPosX then MapViewPosX:=MapViewX;
    If MapViewY<MapViewPosY then MapViewPosY:=MapViewY;
    If MapViewX+DefaultMapViewX>=MapViewPosX+MapViewDivX then
      MapViewPosX:=MapViewX+DefaultMapViewX-MapViewDivX;
    If MapViewY+DefaultMapViewY>=MapViewPosY+MapViewDivY then
      MapViewPosY:=MapViewY+DefaultMapViewY-MapViewDivY;
  End;

PROCEDURE TLOCWorld.AdjustMapView;
  Begin
    Case MyScreen.VideoMode of
      M800x600 :
        Begin
          MapViewDivX:=159;
          MapViewDivY:=159;
          DefaultMapViewX:=18;
          DefaultMapViewY:=17;
        End;
      M1024x768 :
        Begin
          MapViewDivX:=199;
          MapViewDivY:=199;
          DefaultMapViewX:=24;
          DefaultMapViewY:=22;
        End;
    End;
    With MyScreen do
      Begin
        ViewPosX2OS:=ViewPosXOS+(DefaultMapViewX+1)*DefaultMapTileX-1;
        ViewPosY2OS:=ViewPosYOS+(DefaultMapViewY+1)*DefaultMapTileY-1;
      End;
  End;

FUNCTIOn  TLOCWorld.NewUnitAt(UnitClan : TClan;UnitTyper : TUnit;X,Y : FastInt) : Boolean;
  Var UnitNum : TUnitCount;
      Head    : THeading;
  Begin
    If UnitTyper=GoldMine then
      Begin
        Result:=NewGoldMineAt(DefaultGoldAmound,X,Y);
        Exit;
      End;
    With MyUnits do
      Begin
        Head:=GetRandomHeading;
        If TestTyperUnitPos(UnitClan,UnitTyper,Head,X,Y)<>PlaceOk then
          Begin
            Result:=False;
            Exit;
          End;
        UnitNum:=GetUnusedUnit;
        If UnitNum>0 then
          Begin
            SetUnitToDefault(UnitNum,UnitClan,UnitTyper,X,Y,False);
            PutUnit(UnitNum,True,True);
            UnitUpdatePosition(UnitNum);
            Result:=True;
          End
        Else Result:=False;
        {$IfDef RandomAbility}
        Case Random(10) of
          0 : NewEffect(UnitNum,HeroSign0,0);
          1 : NewEffect(UnitNum,HeroSign1,0);
          2 : NewEffect(UnitNum,HeroSign2,0);
          3 : NewEffect(UnitNum,HeroSign3,0);
          4 : NewEffect(UnitNum,HeroSign4,0);
          5 : NewEffect(UnitNum,HeroSign5,0);
          6 : NewEffect(UnitNum,HeroSign6,0);
          7 : NewEffect(UnitNum,HeroSign7,0);
          8 : NewEffect(UnitNum,HeroSign8,0);
          Else NewEffect(UnitNum,HeroSign9,0);
        End;
        {$EndIf}
      End;
  End;
  
FUNCTIOn  TLOCWorld.NewUnitAt(UnitName : NameString;UnitClan : TClan;
                              UnitTyper : TUnit;X,Y : FastInt) : Boolean;
  Var UnitNum : TUnitCount;
      Head    : THeading;
  Begin
    With MyUnits do
      Begin
        Head:=GetRandomHeading;
        If TestTyperUnitPos(UnitClan,UnitTyper,Head,X,Y)<>PlaceOk then
          Begin
            Result:=False;
            Exit;
          End;
        UnitNum:=GetUnusedUnit;
        If UnitNum>0 then
          Begin
            SetUnitToDefault(UnitName,UnitNum,UnitClan,UnitTyper,X,Y,False);
            PutUnit(UnitNum,True,True);
            UnitUpdatePosition(UnitNum);
            Result:=True;
          End
        Else Result:=False;
        {$IfDef RandomAbility}
        Case Random(10) of
          0 : NewEffect(UnitNum,HeroSign0,0);
          1 : NewEffect(UnitNum,HeroSign1,0);
          2 : NewEffect(UnitNum,HeroSign2,0);
          3 : NewEffect(UnitNum,HeroSign3,0);
          4 : NewEffect(UnitNum,HeroSign4,0);
          5 : NewEffect(UnitNum,HeroSign5,0);
          6 : NewEffect(UnitNum,HeroSign6,0);
          7 : NewEffect(UnitNum,HeroSign7,0);
          8 : NewEffect(UnitNum,HeroSign8,0);
          Else NewEffect(UnitNum,HeroSign9,0);
        End;
        {$EndIf}
      End;
  End;

FUNCTIOn  TLOCWorld.NewGoldMineAt(GoldAmound : LongInt;X,Y : FastInt) : Boolean;
  Var UnitNum : TUnitCount;
      Head    : THeading;
  Begin
    With MyUnits do
      Begin
        Head:=GetRandomHeading;
        If TestTyperUnitPos(Gaia,GoldMine,Head,X,Y)<>PlaceOk then
          Begin
            Result:=False;
            Exit;
          End;
        UnitNum:=GetUnusedUnit;
        If UnitNum>0 then
          Begin
            SetUnitToDefault(UnitNum,Gaia,GoldMine,X,Y);
            Units[UnitNum]._UnitResource._GoldAmound:=GoldAmound;
            PutUnit(UnitNum,True,True);
            UnitUpdatePosition(UnitNum);
            Result:=True;
          End
        Else Result:=False;
      End;
  End;

PROCEDURE TLOCWorld.SetUnitSeeRangeStatus(UnitNum : TUnitCount;Status : TMapAttr;SwitchOn : Boolean);
  Var X1,Y1,X2,Y2,I,J     : FastInt;
      {$IfDef LightOfSight}
      X,Y,XL,YL,XR,YR,L,R : FastInt;
      {$EndIf}
      UnitHeight          : TMapTileHeight;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        {$IfDef LightOfSight}
        //Unit is have sight around !
        If Not (UnitFullSight in UnitsProperty[_UnitClan,UnitTyper].BaseAttribute) then
          Begin
            X1:=Pos.X;X2:=Pos.X+UnitsProperty[_UnitClan,UnitTyper].UnitSizeX;
            Y1:=Pos.Y;Y2:=Pos.Y+UnitsProperty[_UnitClan,UnitTyper].UnitSizeY;
            For X:=X1 to X2 do
              For Y:=Y1 to Y2 do
                SetTileAttr(X,Y,Status,SwitchOn);
            Case Heading of
              H1 :
                Begin
                  L:=7;R:=0;
                  XL:=X1;YL:=Y1;
                  XR:=X2;YR:=Y1;
                End;
              H2 :
                Begin
                  L:=0;R:=1;
                  XL:=X2;YL:=Y1;
                  XR:=X2;YR:=Y1;
                End;
              H3 :
                Begin
                  L:=1;R:=2;
                  XL:=X2;YL:=Y1;
                  XR:=X2;YR:=Y2;
                End;
              H4 :
                Begin
                  L:=2;R:=3;
                  XL:=X2;YL:=Y2;
                  XR:=X2;YR:=Y2;
                End;
              H5 :
                Begin
                  L:=3;R:=4;
                  XL:=X2;YL:=Y2;
                  XR:=X1;YR:=Y2;
                End;
              H6 :
                Begin
                  L:=4;R:=5;
                  XL:=X1;YL:=Y2;
                  XR:=X1;YR:=Y2;
                End;
              H7 :
                Begin
                  L:=5;R:=6;
                  XL:=X1;YL:=Y2;
                  XR:=X1;YR:=Y1;
                End;
              H8 :
                Begin
                  L:=6;R:=7;
                  XL:=X1;YL:=Y1;
                  XR:=X1;YR:=Y1;
                End;
              Else
                Begin
                  L:=0;R:=0;
                  XL:=X1;YL:=Y1;
                  XR:=X1;YR:=Y1;
                End;
            End;
            //Unit is air unit ? No one can hide on the light of sight !
            If UnitIsAirUnit in UnitsProperty[_UnitClan,UnitTyper].BaseAttribute then
              Begin
                For I:=0 to MaxRange do
                  Begin
                    //Left light ? Start by one because zero is current point !
                    J:=1;
                    While J<UnitsProperty[_UnitClan,UnitTyper].SeeRange do
                      Begin
                        X:=XL+LightPos[L,I,J,0];
                        Y:=YL+LightPos[L,I,J,1];
                        Inc(J);
                        SetTileAttr(X,Y,Status,SwitchOn);
                      End;
                    //Right light ? Start by one because zero is current point !
                    J:=1;
                    While J<UnitsProperty[_UnitClan,UnitTyper].SeeRange do
                      Begin
                        X:=XR+LightPos[R,I,J,0];
                        Y:=YR+LightPos[R,I,J,1];
                        Inc(J);
                        SetTileAttr(X,Y,Status,SwitchOn);
                      End;
                  End;
              End
            Else//Unit is land unit, when one the light of sight have a obstacle then
            //light of sight has break off !
              Begin
                For I:=0 to MaxRange do
                  Begin
                    //Left light ? Start by one because zero is current point !
                    J:=1;
                    While J<UnitsProperty[_UnitClan,UnitTyper].SeeRange do
                      Begin
                        //Map used by land unit ? Crashed rountine !
                        X:=XL+LightPos[L,I,J,0];
                        Y:=YL+LightPos[L,I,J,1];
                        If (X<0) or (X>=MapSizeX) or
                           (Y<0) or (Y>=MapSizeY) then Break;
                        Inc(J);
                        SetTileAttr(X,Y,Status,SwitchOn);
                        If GetTileAttr(X,Y,MapUsedByLandUnit) then Break;
                      End;
                    //Right light ? Start by one because zero is current point !
                    J:=1;
                    While J<UnitsProperty[_UnitClan,UnitTyper].SeeRange do
                      Begin
                        //Map used by land unit ? Crashed rountine !
                        X:=XR+LightPos[R,I,J,0];
                        Y:=YR+LightPos[R,I,J,1];
                        If (X<0) or (X>=MapSizeX) or
                           (Y<0) or (Y>=MapSizeY) then Break;
                        Inc(J);
                        SetTileAttr(X,Y,Status,SwitchOn);
                        If GetTileAttr(X,Y,MapUsedByLandUnit) then Break;
                      End;
                  End;
              End;
          End
        Else
        {$EndIf}
          Begin
            If _UnitPos.X<UnitsProperty[_UnitClan,_UnitTyper].SeeRange then X1:=0
            Else X1:=_UnitPos.X-UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
            If _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
               UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>MapSizeX-1 then X2:=MapSizeX-1
            Else X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
                     UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
            If _UnitPos.Y<UnitsProperty[_UnitClan,_UnitTyper].SeeRange then Y1:=0
            Else Y1:=_UnitPos.Y-UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
            If _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
               UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>MapSizeY-1 then Y2:=MapSizeY-1
            Else Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
                     UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            //Get tile height on unit position !
            UnitHeight:=MapTileHeight[_UnitPos.X ShR 1,_UnitPos.Y ShR 1];
            If UnitIsAirUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
              Begin
                For I:=X1 to X2 do
                  For J:=Y1 to Y2 do
                    SetTileAttr(I,J,Status,SwitchOn);
              End
            Else
              Begin
                //Line of sight ?
                For I:=X1 to X2 do
                  For J:=Y1 to Y2 do
                    If MapTileHeight[I ShR 1,J ShR 1]<=UnitHeight then
                      SetTileAttr(I,J,Status,SwitchOn);
              End;
          End;
      End;
  End;

PROCEDURE TLOCWorld.SetUnitTrueSight(UnitNum : TUnitCount);
  Var X1,Y1,X2,Y2,I,J : FastInt;
      UnitHeight      : TMapTileHeight;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitPos.X<UnitsProperty[_UnitClan,_UnitTyper].SeeRange then X1:=0
        Else X1:=_UnitPos.X-UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
        If _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
           UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>MapSizeX-1 then X2:=MapSizeX-1
        Else X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
                 UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
        If _UnitPos.Y<UnitsProperty[_UnitClan,_UnitTyper].SeeRange then Y1:=0
        Else Y1:=_UnitPos.Y-UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
        If _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
           UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>MapSizeY-1 then Y2:=MapSizeY-1
        Else Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+
                 UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
        //Get tile height on unit position !
        UnitHeight:=MapTileHeight[_UnitPos.X ShR 1,_UnitPos.Y ShR 1];
        If UnitIsAirUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=X1 to X2 do
              For J:=Y1 to Y2 do
                SetTrueSight(_UnitClan,I,J);
          End
        Else
          Begin
            //Line of sight ?
            For I:=X1 to X2 do
              For J:=Y1 to Y2 do
                If MapTileHeight[I ShR 1,J ShR 1]<=UnitHeight then
                  SetTrueSight(_UnitClan,I,J);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitUpdatePosition(UnitNum : TUnitCount);
  Var Idx   : TQueueCount;
      Found : Boolean;
  Begin
    With MyScreen,MyUnits do
      Begin
        //All unit have set unit true sight
        If UnitTestBaseAttribute(UnitNum,UnitTrueSight) then
          SetUnitTrueSight(UnitNum);
        //Someone in unit queue is HumanControl ?
        If Units[UnitNum]._UnitClan<>HumanControl then
          Begin
            Found:=False;
            For Idx:=Low(TQueueCount) to High(TQueueCount) do
              If Units[UnitNum]._UnitQueue[Idx]<>0 then
                If Units[Units[UnitNum]._UnitQueue[Idx]]._UnitClan=HumanControl then Found:=True;
            If Not Found then Exit;
          End;
        //Dead unit can't see anything
        If Units[UnitNum]._UnitHitPoint<=0 then Exit;
        SetUnitSeeRangeStatus(UnitNum,MapDontVisited,False);
        If Not CheatStatus[NoFog] then
          Begin
            SetUnitSeeRangeStatus(UnitNum,MapDontVisible,False);
            ClearUnitUnderFogVisible(UnitNum);
          End;
      End;
  End;

FUNCTION  TLOCWorld.TestUnitPos(UnitNum : TUnitCount;PosX,PosY : FastInt) : Integer;
  Var I,J : FastInt;
  Begin
    Result:=PlaceOk;
    With MyUnits,Units[UnitNum] do
      Begin
        If (PosX<0) or (PosY<0) or
           (PosX+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>=MapSizeX) or
           (PosY+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY>=MapSizeY) then
          Begin
            Result:=PlaceError;
            Exit;
          End;
        If UnitIsLandUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If (UnitsProperty[_UnitClan,_UnitTyper].UnitMapped[_UnitHeading,I,J] and
                    UnitMappedUsedLand=UnitMappedUsedLand) and
                   GetTileAttr(I+PosX,J+PosY,MapUsedByLandUnit) then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End
        {$IfDef LimitAirUnitOnTile}
        Else
        If UnitIsAirUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=PosX to PosX+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=PosY to PosY+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If MapCount[I,J]>MaxUnitOnTile then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End;
        {$EndIf}
        //Unit is deposit class ?
        If UnitIsDeposit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If (UnitsProperty[_UnitClan,_UnitTyper].UnitMapped[_UnitHeading,I,J] and
                    UnitMappedUsedLand=UnitMappedUsedLand) and
                   GetTileAttr(I+PosX,J+PosY,MapUsedByGoldMine) then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End;
      End;
  End;

FUNCTION  TLOCWorld.TestUnitPos(UnitNum : TUnitCount;Head : THeading;PosX,PosY : FastInt) : Integer;
  Var I,J : FastInt;
  Begin
    Result:=PlaceOk;
    With MyUnits,Units[UnitNum] do
      Begin
        If (PosX<0) or (PosY<0) or
           (PosX+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>=MapSizeX) or
           (PosY+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY>=MapSizeY) then
          Begin
            Result:=PlaceError;
            Exit;
          End;
        If UnitIsLandUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If (UnitsProperty[_UnitClan,_UnitTyper].UnitMapped[Head,I,J] and
                    UnitMappedUsedLand=UnitMappedUsedLand) and
                   GetTileAttr(I+PosX,J+PosY,MapUsedByLandUnit) then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End
        {$IfDef LimitAirUnitOnTile}
        Else
        If UnitIsAirUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=PosX to PosX+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=PosY to PosY+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If MapCount[I,J]>MaxUnitOnTile then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End;
        {$EndIf}
        //Unit is deposit class ?
        If UnitIsDeposit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If (UnitsProperty[_UnitClan,_UnitTyper].UnitMapped[Head,I,J] and
                    UnitMappedUsedLand=UnitMappedUsedLand) and
                   GetTileAttr(I+PosX,J+PosY,MapUsedByGoldMine) then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End;
      End;
  End;

FUNCTION  TLOCWorld.TestTyperUnitPos(UnitClan : TClan;UnitTyper : TUnit;
                                     Head : THeading;PosX,PosY : FastInt) : Integer;
  Var I,J : FastInt;
  Begin
    Result:=PlaceOk;
    With MyUnits do
      Begin
        If (PosX<0) or (PosY<0) or
           (PosX+UnitsProperty[UnitClan,UnitTyper].UnitSizeX>=MapSizeX) or
           (PosY+UnitsProperty[UnitClan,UnitTyper].UnitSizeY>=MapSizeY) then
          Begin
            Result:=PlaceError;
            Exit;
          End;
        If UnitIsLandUnit in UnitsProperty[UnitClan,UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[UnitClan,UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[UnitClan,UnitTyper].UnitSizeY do
                If (UnitsProperty[UnitClan,UnitTyper].UnitMapped[Head,I,J] and
                    UnitMappedUsedLand=UnitMappedUsedLand) and
                   GetTileAttr(I+PosX,J+PosY,MapUsedByLandUnit) then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End
        {$IfDef LimitAirUnitOnTile}
        Else
        If UnitIsAirUnit in UnitsProperty[UnitClan,UnitTyper].BaseAttribute then
          Begin
            For I:=PosX to PosX+UnitsProperty[UnitClan,UnitTyper].UnitSizeX do
              For J:=PosY to PosY+UnitsProperty[UnitClan,UnitTyper].UnitSizeY do
                If MapCount[I,J]>MaxUnitOnTile then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End;
        {$EndIf}
        //Unit is deposit class ?
        If UnitIsDeposit in UnitsProperty[UnitClan,UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[UnitClan,UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[UnitClan,UnitTyper].UnitSizeY do
                If (UnitsProperty[UnitClan,UnitTyper].UnitMapped[Head,I,J] and
                    UnitMappedUsedLand=UnitMappedUsedLand) and
                   GetTileAttr(I+PosX,J+PosY,MapUsedByGoldMine) then
                  Begin
                    Result:=PlaceError;
                    Exit;
                  End;
          End;
      End;
  End;

PROCEDURE TLOCWorld.PlaceUnit(UnitNum : TUnitCount);
  Var X1,Y1,X2,Y2,I,J : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Unit is land unit, take unit on first unit in this location
        If UnitIsLandUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If UnitsProperty[_UnitClan,_UnitTyper].UnitMapped[_UnitHeading,I,J] and
                   UnitMappedUsedLand=UnitMappedUsedLand then
                  SetTileAttr(_UnitPos.X+I,_UnitPos.Y+J,MapUsedByLandUnit,True);
          End
        //Take unit in location, on last
        Else
          Begin
            {$IfDef LimitAirUnitOnTile}
            If UnitIsAirUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
              For I:=_UnitPos.X to _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
                For J:=_UnitPos.Y to _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do Inc(MapCount[I,J]);
            {$EndIf}
          End;
        //Unit is gold mine class ?
        If UnitIsGoldMine in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            X1:=_UnitPos.X;X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            Y1:=_UnitPos.Y;Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            If X1>DefaultGoldMineFarSize then Dec(X1,DefaultGoldMineFarSize) Else X1:=0;
            If X2+DefaultGoldMineFarSize<=MapSizeX then Inc(X2,DefaultGoldMineFarSize) Else X2:=MapSizeX-1;
            If Y1>DefaultGoldMineFarSize then Dec(Y1,DefaultGoldMineFarSize) Else Y1:=0;
            If Y2+DefaultGoldMineFarSize<=MapSizeY then Inc(Y2,DefaultGoldMineFarSize) Else Y2:=MapSizeY-1;
            For I:=X1 to X2 do
              For J:=Y1 to Y2 do
                SetTileAttr(I,J,MapUsedByGoldMine,True);
          End;
      End;
  End;

PROCEDURE TLOCWorld.PutUnit(UnitNum : TUnitCount;Place,UpdatePos : Boolean);
  //Var TempUnit : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If Place then
          Begin
            PlaceUnit(UnitNum);
            SetUnitAttribute(UnitNum,UnitTakeATile,True);
          End;
        SetUnitAttribute(UnitNum,UnitOnMapNum,True);
        _UnitPrev:=0;
        _UnitNext:=MapNum[_UnitPos.X,_UnitPos.Y];
        MapNum[_UnitPos.X,_UnitPos.Y]:=UnitNum;
        If _UnitNext<>0 then Units[_UnitNext]._UnitPrev:=UnitNum;
      End;
    {$IfDef AttackWhenAlert}
    //Update unit target for all unit around this unit ? Alert all unit in range, also alert him's self
    AlertUnitArea(UnitNum);
    {$EndIf}
    //Also update unit visited and fogging !
    If UpdatePos then
      UnitUpdatePosition(UnitNum);
  End;

PROCEDURE TLOCWorld.AlertUnitArea(UnitNum : TUnitCount);
  Var I,J,X1,Y1,X2,Y2,Num : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        SetUnitAttribute(UnitNum,UnitHasATarget,True);
        If _UnitPos.X<MaxSeeRange then X1:=0
        Else X1:=_UnitPos.X-MaxSeeRange;
        If _UnitPos.X+MaxSeeRange+MaxUnitSizeX>MapSizeX-1 then X2:=MapSizeX-1
        Else X2:=_UnitPos.X+MaxSeeRange+MaxUnitSizeX;
        If _UnitPos.Y<MaxSeeRange then Y1:=0
        Else Y1:=_UnitPos.Y-MaxSeeRange;
        If _UnitPos.Y+MaxSeeRange+MaxUnitSizeX>MapSizeY-1 then Y2:=MapSizeY-1
        Else Y2:=_UnitPos.Y+MaxSeeRange+MaxUnitSizeY;
        For I:=X1 to X2 do
          For J:=Y1 to Y2 do
            Begin
              Num:=MapNum[I,J];
              While Num<>0 do
                Begin
                  If ClanInfo[_UnitClan].Diplomacy[Units[Num]._UnitClan]=Enemy then
                    SetUnitAttribute(Num,UnitHasATarget,True);
                  Num:=Units[Num]._UnitNext;
                End;
            End;
      End;
  End;

PROCEDURE TLOCWorld.SetUnitPos(UnitNum : TUnitCount;PosX,PosY : FastInt);
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        _UnitPos.X:=PosX;
        _UnitPos.Y:=PosY;
        PutUnit(UnitNum,True,True);
      End;
  End;

PROCEDURE TLOCWorld.TakeUnit(UnitNum : TUnitCount);
  Var X1,Y1,X2,Y2,I,J : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If UnitIsLandUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            For I:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If UnitsProperty[_UnitClan,_UnitTyper].UnitMapped[_UnitHeading,I,J] and
                   UnitMappedUsedLand=UnitMappedUsedLand then
                  SetTileAttr(_UnitPos.X+I,_UnitPos.Y+J,MapUsedByLandUnit,False);
          End
        Else
          Begin
            {$IfDef LimitAirUnitOnTile}
            If UnitIsAirUnit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
              For I:=_UnitPos.X to _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
                For J:=_UnitPos.Y to _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do Dec(MapCount[I,J]);
            {$EndIf}
          End;
        //Unit is gold mine class ?
        If UnitIsGoldMine in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          Begin
            X1:=_UnitPos.X;X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            Y1:=_UnitPos.Y;Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            If X1>DefaultGoldMineFarSize then Dec(X1,DefaultGoldMineFarSize) Else X1:=0;
            If X2+DefaultGoldMineFarSize<=MapSizeX then Inc(X2,DefaultGoldMineFarSize) Else X2:=MapSizeX-1;
            If Y1>DefaultGoldMineFarSize then Dec(Y1,DefaultGoldMineFarSize) Else Y1:=0;
            If Y2+DefaultGoldMineFarSize<=MapSizeY then Inc(Y2,DefaultGoldMineFarSize) Else Y2:=MapSizeY-1;
            For I:=X1 to X2 do
              For J:=Y1 to Y2 do
                SetTileAttr(I,J,MapUsedByGoldMine,False);
          End;
      End;
  End;

PROCEDURE TLOCWorld.PickUnit(UnitNum : TUnitCount;Take : Boolean);
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If Take then
          Begin
            TakeUnit(UnitNum);
            SetUnitAttribute(UnitNum,UnitTakeATile,False);
          End;
        SetUnitAttribute(UnitNum,UnitOnMapNum,False);
        If _UnitNext<>0 then Units[_UnitNext]._UnitPrev:=_UnitPrev;
        If _UnitPrev=0 then MapNum[_UnitPos.X,_UnitPos.Y]:=_UnitNext
        Else Units[_UnitPrev]._UnitNext:=_UnitNext;
        _UnitNext:=0;
        _UnitPrev:=0;
      End;
  End;

PROCEDURE TLOCWorld.SelectUnitOnArea(X1,Y1,X2,Y2 : FastInt;AddUnit,SelectBuilding : Boolean);
  Var MX1,MX2,MY1,MY2 : FastInt;
  Begin
    Swap(X1,X2);Swap(Y1,Y2);
    MX1:=X1 div DefaultMapTileX;
    MY1:=Y1 div DefaultMapTileY;
    MX2:=X2 div DefaultMapTileX;
    MY2:=Y2 div DefaultMapTileY;
    SelectUnitOnMap(MX1,MY1,MX2,MY2,AddUnit,SelectBuilding);
  End;

PROCEDURE TLOCWorld.SelectUnitOnMap(X1,Y1,X2,Y2 : FastInt;AddUnit,SelectBuilding : Boolean);
  Var FoundMyUnit,FoundBuilding,FoundNoBuilding,Changes : Boolean;
      I,J,X,Y,RX1,RY1,RX2,RY2                           : FastInt;
      UnitNum                                           : TUnitCount;
      TempGroup                                         : TGroup;
      GeneralClan                                       : TClan;
  Begin
    With MyUnits do
      Begin
        If AddUnit then TempGroup:=SaveGroups[MaxGroup]
        Else FillChar(TempGroup,SizeOf(TempGroup),0);
        RX1:=MapViewX+X1;RX2:=MapViewX+X2;
        RY1:=MapViewY+Y1;RY2:=MapViewY+Y2;
        X1:=MapViewX+X1;Y1:=MapViewY+Y1;
        If RX1>MaxUnitSizeX then Dec(RX1,MaxUnitSizeX) Else RX1:=0;
        If RY1>MaxUnitSizeY then Dec(RY1,MaxUnitSizeY) Else RY1:=0;
        FoundMyUnit:=False;
        FoundBuilding:=False;
        FoundNoBuilding:=False;
        Changes:=False;
        GeneralClan:=Gaia;
        If AddUnit then
          Begin
            //Check only first unit :>
            If TempGroup[Low(TUnitSelectionCount)]<>0 then
              With Units[TempGroup[Low(TUnitSelectionCount)]] do
                Begin
                  GeneralClan:=_UnitClan;
                  FoundMyUnit:=_UnitClan=HumanControl;
                  FoundBuilding:=UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute;
                  FoundNoBuilding:=Not (UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute);
                End;
            If SelectBuilding and Not FoundBuilding then Exit;
          End;
        For I:=RX1 to RX2 do
          Begin
            For J:=RY1 to RY2 do
              Begin
                //If GetTileAttr(I,J,MapDontVisible) then Continue;
                UnitNum:=MapNum[I,J];
                While UnitNum<>0 do
                  With Units[UnitNum] do
                    Begin
                      If CanSeeThisUnit(HumanControl,UnitNum) then
                        Begin
                          If _UnitHitPoint>0 then
                            Begin
                              X:=Units[UnitNum]._UnitPos.X+UnitsProperty[Units[UnitNum]._UnitClan,
                                                                    Units[UnitNum]._UnitTyper].UnitSizeX;
                              Y:=Units[UnitNum]._UnitPos.Y+UnitsProperty[Units[UnitNum]._UnitClan,
                                                                    Units[UnitNum]._UnitTyper].UnitSizeY;
                              If (X>=X1) and (Y>=Y1) then
                                Begin
                                  If GeneralClan=Gaia then
                                    GeneralClan:=Units[UnitNum]._UnitClan;
                                  If UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
                                    FoundBuilding:=True
                                  Else FoundNoBuilding:=True;
                                  If Units[UnitNum]._UnitClan=HumanControl then FoundMyUnit:=True;
                                End;
                            End;
                        End;
                      UnitNum:=Units[UnitNum]._UnitNext;
                    End;
              End;
          End;
        If FoundMyUnit then GeneralClan:=HumanControl;
        If SelectBuilding then
          Begin
            If FoundBuilding=False then Exit;
          End
        Else
          Begin
            If FoundBuilding and
               Not FoundNoBuilding then
              SelectBuilding:=True;
          End;
        //Only select my unit
        For I:=RX1 to RX2 do
          For J:=RY1 to RY2 do
            Begin
              //If GetTileAttr(I,J,MapDontVisible) then Continue;
              UnitNum:=MapNum[I,J];
              While UnitNum<>0 do
                With Units[UnitNum] do
                  Begin
                    If CanSeeThisUnit(HumanControl,UnitNum) then
                      Begin
                        If Not AddUnit then
                          Begin
                            If SelectBuilding and Not (UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) then
                              Begin
                                UnitNum:=_UnitNext;
                                Continue;
                              End
                            Else
                            If Not SelectBuilding and (UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) then
                              Begin
                                UnitNum:=_UnitNext;
                                Continue;
                              End;
                          End;
                        If UnitCanAddToGroup(UnitNum,GeneralClan,TempGroup) then
                          Begin
                            X:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
                            Y:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
                            If (X>=X1) and (Y>=Y1) then
                              Begin
                                AddUnitToGroup(UnitNum,TempGroup);
                                Changes:=True;
                              End;
                          End;
                      End;
                    UnitNum:=_UnitNext;
                  End;
            End;
        If NumberUnitInGroup(TempGroup)<>0 then
          Begin
            CurrentGroup:=MaxGroup;
            UnSelectGroup(MaxGroup);
            SaveGroups[MaxGroup]:=TempGroup;
            SetSelectGroup(MaxGroup)
          End;
        If (Changes and Not AddUnit) or
           (UnitFocus=0) then
          UnitFocus:=SaveGroups[MaxGroup][Low(TUnitSelectionCount)];
      End;
  End;

PROCEDURE TLOCWorld.SelectUnitByMouse(AddUnit,SelectBuilding : Boolean);
  Begin
    With MyScreen,MyUnits do
      Begin
        SelectUnitOnArea(SelectStart.X-ViewPosXOS,
                         SelectStart.Y-ViewPosYOS,
                         SelectEnd.X-ViewPosXOS,
                         SelectEnd.Y-ViewPosYOS,
                         AddUnit,SelectBuilding);
        //Get group skill
        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
        //Set up unit button for group
        SetupGroupSelected(MaxGroup);
      End;
  End;

PROCEDURE TLOCWorld.PlaceUnitInUnderFogMap(UnitNum : TUnitCount);
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If Not (UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) then Exit;
          //If HitPoint>0 then Exit;
        //Unit must alive
        //If HitPoint<=0 then Exit;
        If _UnitHitPoint<0 then Exit;
        //ClearUnitInUnderFogMap(UnitNum);
        MapUnitUnderFog[_UnitPos.X,_UnitPos.Y]._UnitColor:=_UnitColor;
        MapUnitUnderFog[_UnitPos.X,_UnitPos.Y]._UnitTyper:=_UnitTyper;
        MapUnitUnderFog[_UnitPos.X,_UnitPos.Y].Heading:=_UnitHeading;
        MapUnitUnderFog[_UnitPos.X,_UnitPos.Y]._ShiftPX:=_ShiftPX;
        MapUnitUnderFog[_UnitPos.X,_UnitPos.Y]._ShiftPY:=_ShiftPY;
      End;
  End;

PROCEDURE TLOCWorld.ClearUnitInUnderFogMap(UnitNum : TUnitCount);
  Var I,J : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        For I:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
          For J:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
            MapUnitUnderFog[I,J]._UnitTyper:=NoneUnit;
      End;
  End;

PROCEDURE TLOCWorld.ClearUnitUnderFogVisible(UnitNum : TUnitCount);
  Var X1,Y1,X2,Y2,MX1,MY1,MX2,MY2,I,J : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Unit must alive ?
        If _UnitHitPoint<=0 then Exit;
        If _UnitPos.X<UnitsProperty[_UnitClan,_UnitTyper].SeeRange then X1:=0
        Else X1:=_UnitPos.X-UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
        If _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>MapSizeX-1 then X2:=MapSizeX-1
        Else X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
        If _UnitPos.Y<UnitsProperty[_UnitClan,_UnitTyper].SeeRange then Y1:=0
        Else Y1:=_UnitPos.Y-UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
        If _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>MapSizeY-1 then Y2:=MapSizeY-1
        Else Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].SeeRange+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
        If X1>MaxUnitSizeX then MX1:=X1-MaxUnitSizeX Else MX1:=0;
        If Y1>MaxUnitSizeY then MY1:=Y1-MaxUnitSizeY Else MY1:=0;
        MX2:=X2;MY2:=Y2;
        For I:=MX1 to MX2 do
          For J:=MY1 to MY2 do
            If MapUnitUnderFog[I,J]._UnitTyper<>NoneUnit then
              Begin
                If UnitUnderFogVisible(I,J) then
                  MapUnitUnderFog[I,J]._UnitTyper:=NoneUnit;
                {If (I+UnitsProperty[MapUnitUnderFog[I,J]._UnitClan,MapUnitUnderFog[I,J]._UnitTyper].UnitSizeX>=X1) and
                   (J+UnitsProperty[MapUnitUnderFog[I,J]._UnitClan,MapUnitUnderFog[I,J]._UnitTyper].UnitSizeY>=Y1) then
                  MapUnitUnderFog[I,J]._UnitTyper:=NoneUnit;}
              End;
      End;
  End;

FUNCTION  TLOCWorld.UnitUnderFogVisible(X,Y : FastInt) : Boolean;
  Var I,J : FastInt;
  Begin
    Result:=True;
    With MyUnits do
      For I:=X to X+UnitsProperty[MapUnitUnderFog[X,Y]._UnitColor,MapUnitUnderFog[X,Y]._UnitTyper].UnitSizeX do
        For J:=Y to Y+UnitsProperty[MapUnitUnderFog[X,Y]._UnitColor,MapUnitUnderFog[X,Y]._UnitTyper].UnitSizeY do
          If GetTileAttr(I,J,MapDontVisible)=False then Exit;
    Result:=False;
  End;

FUNCTION  TLOCWorld.UnitFindTargetForAttack(UnitNum : TUnitCount;Range,SeeRange : FastInt) : TUnitCount;
  Var I,J,RX1,RY1,RX2,RY2,BestPoint,Point,Distance : FastInt;
      BestTarget,TempUnit                          : TUnitCount;
  Begin
    Result:=0;
    With MyUnits,Units[UnitNum] do
      Begin
        If CheckUnitSkill(UnitNum,CmdAttack)=False then Exit;
        {$IfDef AttackWhenAlert}
        SetUnitAttribute(UnitNum,UnitHasATarget,False);
        {$EndIf}
        RX1:=_UnitPos.X-Range;
        RX2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX+Range;
        RY1:=_UnitPos.Y-Range;
        RY2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY+Range;
        If RX1>MaxUnitSizeX then Dec(RX1,MaxUnitSizeX) Else RX1:=0;
        If RY1>MaxUnitSizeY then Dec(RY1,MaxUnitSizeY) Else RY1:=0;
        If RX2>=MapSizeX then RX2:=MapSizeX-1;
        If RY2>=MapSizeY then RY2:=MapSizeY-1;
        BestTarget:=0;
        BestPoint:=High(FastInt);
        For I:=RX1 to RX2 do
          For J:=RY1 to RY2 do
            Begin
              TempUnit:=MapNum[I,J];
              While TempUnit<>0 do
                Begin
                  //Unit is not enemy clan ?
                  If (ClanInfo[_UnitClan].Diplomacy[Units[TempUnit]._UnitClan]<>Enemy) or
                  //Unit not alive ?
                     (Units[TempUnit]._UnitHitPoint<=0) or
                  //Unit can't CmdAttack this target
                     (UnitCanAttack(UnitNum,TempUnit)<>CanAttack) or
                     Not CanSeeThisUnit(_UnitClan,TempUnit) then
                    Begin
                      //Get next and continue
                      TempUnit:=Units[TempUnit]._UnitNext;
                      Continue;
                    End;
                  Distance:=RangeBetweenUnit(UnitNum,TempUnit);
                  If Distance>=SeeRange then
                    Begin
                      //Get next and continue
                      TempUnit:=Units[TempUnit]._UnitNext;
                      Continue;
                    End;
                  Point:=Distance*100;
                  If Point<BestPoint then
                    Begin
                      BestTarget:=TempUnit;
                      BestPoint:=Point;
                    End;
                  TempUnit:=Units[TempUnit]._UnitNext;
                End;
            End;
      End;
    Result:=BestTarget;
  End;

FUNCTION  TLOCWorld.GetUnitNear(UnitNum : TUnitCount;Find : TUnit;MinRange,MaxRange : FastInt) : TUnitCount;
  Var X1,Y1,X2,Y2,I,J,X,Y,BestRange,OwnRange : FastInt;
      BestTarget,UN                          : TUnitCount;
  Begin
    With MyUnits do
      Begin
        BestRange:=High(FastInt);
        BestTarget:=0;
        With Units[UnitNum] do
          Begin
            X1:=_UnitPos.X;
            X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
            Y1:=_UnitPos.Y;
            Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            If X1>MaxRange then X1:=X1-MaxRange Else X1:=0;
            If X2+MaxRange<=MapSizeX then X2:=X2+MaxRange Else X2:=MapSizeX-1;
            If Y1>MaxRange then Y1:=Y1-MaxRange Else Y1:=0;
            If Y2+MaxRange<=MapSizeY then Y2:=Y2+MaxRange Else Y2:=MapSizeY-1;
            For I:=X1 to X2 do
              For J:=Y1 to Y2 do
                Begin
                  UN:=MapNum[I,J];
                  While UN<>0 do
                    With Units[UN] do
                      Begin
                        If _UnitTyper<>Find then
                          Begin
                            UN:=_UnitNext;
                            Continue;
                          End;
                        X:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
                        Y:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
                        If (X<X1) or (Y<Y1) then
                          Begin
                            UN:=_UnitNext;
                            Continue;
                          End;
                        //Distance between gold mine and current position
                        OwnRange:=RangeBetweenUnit(UnitNum,UN);
                        If (OwnRange>MinRange) and
                           (OwnRange<BestRange) then
                          Begin
                            BestRange:=OwnRange;
                            BestTarget:=UN;
                          End;
                        UN:=_UnitNext;
                      End;
                End;
            Result:=BestTarget;
          End;
      End;
  End;

FUNCTION  TLOCWorld.GetFreePosNear(UnitNum : TUnitCount;MinRange,MaxRange : FastInt;Var X,Y : FastInt) : Boolean;
  Var X1,Y1,X2,Y2,I,J,BestRange,OwnRange : FastInt;
  Begin
    With MyUnits do
      Begin
        BestRange:=High(FastInt);
        With Units[UnitNum] do
          Begin
            X1:=_UnitPos.X;
            X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
            Y1:=_UnitPos.Y;
            Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            If X1>MaxRange then X1:=X1-MaxRange Else X1:=0;
            If X2+MaxRange<=MapSizeX then X2:=X2+MaxRange Else X2:=MapSizeX-1;
            If Y1>MaxRange then Y1:=Y1-MaxRange Else Y1:=0;
            If Y2+MaxRange<=MapSizeY then Y2:=Y2+MaxRange Else Y2:=MapSizeY-1;
            For I:=X1 to X2 do
              For J:=Y1 to Y2 do
                Begin
                  If Not GetTileAttr(I,J,MapUsedByLandUnit) then
                    Begin
                      OwnRange:=RangeBetweenUnit(UnitNum,I,J);
                      If (OwnRange>MinRange) and
                         (OwnRange<BestRange) then
                        Begin
                          BestRange:=OwnRange;
                          X:=I;
                          Y:=J;
                        End;
                    End;
                End;
            Result:=BestRange<High(FastInt);
          End;
      End;
  End;

FUNCTION  TLOCWorld.FindUnitCanSee(Group : TGroup) : Boolean;
  Var Z : FastInt;
  Begin
    Result:=True;
    With MyUnits do
      For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
        If (Group[Z]<>0) and
           Not CanSeeThisUnit(HumanControl,Group[Z]) then Exit;
    Result:=False;
  End;

FUNCTION  TLOCWorld.CanSeeThisUnit(FromClan : TClan;UnitNum : TUnitCount) : Boolean;
  Var I,J : FastInt;
  Begin
    //Result:=MyUnits.GetUnitSawState(UnitNum,FromClan);
    Result:=True;
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitClan=FromClan then Exit;
        If ClanInfo[_UnitClan].SharedVision[FromClan]=FullSharedVision then Exit;
        If GetUnitAttribute(UnitNum,UnitInvisible) then
          Begin
            For I:=_UnitPos.X to _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=_UnitPos.Y to _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                If GetTrueSight(FromClan,I,J) then Exit;
          End
        Else
          Begin
            For I:=_UnitPos.X to _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
              For J:=_UnitPos.Y to _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                Begin
                  If (Not GetTileAttr(I,J,MapDontVisible)) and
                     (Not GetTileAttr(I,J,MapDontVisited)) then Exit;
                End;
          End;
      End;
    Result:=False;
  End;

PROCEDURE TLOCWorld.ClearAllUnitCantSee(Var Group : TGroup);
  Var Found : Boolean;
      Z     : FastInt;
  Begin
    With MyUnits do
      Repeat
        Found:=False;
        For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
          If (Group[Z]<>0) and
             Not CanSeeThisUnit(HumanControl,Group[Z]) then
            Begin
              //Also reset unit in focus ?
              If UnitFocus=Group[Z] then UnitFocus:=0;
              Units[Group[Z]]._UnitGroup:=0;
              ClearUnitInGroup(Group[Z],Group);
              Found:=True;
            End;
      Until Not Found;
  End;

PROCEDURE TLOCWorld.SetGroupCommandCancelBuilding(Group : TGroup;FromClan : TClan);
  Var Idx    : TUnitSelectionCount;
      QueIdx : TQueueCount;
  Begin
    For Idx:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
      If Group[Idx]<>0 then
        With MyUnits,Units[Group[Idx]] do
          Begin
            If CheckClanControlUnit(Group[Idx],FromClan)=False then Exit;
            Case _UnitCmd of
              //When unit build, unload all unit queue and destroy unit !
              CmdStartBuild :
                Begin
                  UnitUnLoadCarrier(Group[Idx]);
                  BringUnitToDeath(Group[Idx]);
                End;
              //Cancel command training:
              Else
                Begin
                  For QueIdx:=High(TQueueCount) downto Low(TQueueCount) do
                    If _UnitQueue[QueIdx]<>0 then
                      Begin
                        //Unit in training: free unit !
                        If Units[_UnitQueue[QueIdx]]._UnitCmd=CmdStartBuild then
                          Begin
                            GetBackMoney(_UnitQueue[QueIdx]);
                            BringUnitToDeath(_UnitQueue[QueIdx]);
                            SetUnitToUnused(_UnitQueue[QueIdx]);
                            _UnitQueue[QueIdx]:=0;
                            ArrangeUnitQueue(Group[Idx]);
                            //Update button
                            If _UnitGroup and 128=128 then
                              Begin
                                GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                                SetupGroupSelected(MaxGroup);
                              End;
                            Break;
                          End;
                      End;
                End;
            End;
          End;
  End;

FUNCTION  TLOCWorld.UnitChangeHeading(UnitNum : TUnitCount;Head : THeading) : Boolean;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Building do not change heading !
        If UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then 
          Begin
            Result:=True;
            Exit;
          End;
        //Current heading ? Stupid !
        If Head=_UnitHeading then
          Begin
            Result:=True;
            Exit;
          End;
        TakeUnit(UnitNum);
        If TestUnitPos(UnitNum,Head,_UnitPos.X,_UnitPos.Y)=PlaceOk then
          Begin
            _UnitHeading:=Head;
            Result:=True;
          End
        Else Result:=False;
        PlaceUnit(UnitNum);
      End;
  End;

FUNCTION  TLOCWorld.UnitGetHeadingToAttack(UnitNum : TUnitCount) : Boolean;
  Var I,J : FastInt;
      H   : THeading;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitPos.X<Units[_UnitTarget]._UnitPos.X then I:=+1 Else
        If _UnitPos.X>Units[_UnitTarget]._UnitPos.X then I:=-1 Else I:=0;
        If _UnitPos.Y<Units[_UnitTarget]._UnitPos.Y then J:=+1 Else
        If _UnitPos.Y>Units[_UnitTarget]._UnitPos.Y then J:=-1 Else J:=0;
        For H:=Low(THeading) to High(THeading) do
          If (Direction[H].X=I) and (Direction[H].Y=J) then
            Begin
              Result:=UnitChangeHeading(UnitNum,H);
              Exit;
            End;
        Result:=False;
      End;
  End;

FUNCTION  TLOCWorld.UnitGetHeadingToAttackNoTarget(UnitNum : TUnitCount) : Boolean;
  Var I,J : FastInt;
      H   : THeading;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitPos.X<_UnitDest.X then I:=+1 Else
        If _UnitPos.X>_UnitDest.X then I:=-1 Else I:=0;
        If _UnitPos.Y<_UnitDest.Y then J:=+1 Else
        If _UnitPos.Y>_UnitDest.Y then J:=-1 Else J:=0;
        If (I=0) and (J=0) then
          Begin
            Result:=True;
            Exit;
          End;
        For H:=Low(THeading) to High(THeading) do
          If (Direction[H].X=I) and (Direction[H].Y=J) then
            Begin
              Result:=UnitChangeHeading(UnitNum,H);
              Exit;
            End;
        Result:=False;
      End;
  End;

FUNCTION  TLOCWorld.UnitCommandBuild(UnitNum : TUnitCount;Typer : TUnit;X,Y : FastInt;FromClan : TClan) : FastInt;
  Var NUnit,Res : FastInt;
  Begin
    Result:=ROk;
    With MyScreen,MyUnits,Units[UnitNum] do
      Begin
        Res:=CheckCreateMoreUnit(_UnitClan,Typer);
        If Res<>ROk then
          Begin
            If FromClan=HumanControl then
              Case Res of
                -1 : SendMessage(NotEnoughFood);
                -2 : SendMessage(NotEnoughResource);
              End;
            Result:=Res;
            Exit;
          End;
        NUnit:=GetUnUsedUnit;
        If NUnit>0 then
          Begin
            SetUnitToStart(NUnit,FromClan,Typer,X,Y,False);
            PutUnit(NUnit,True,True);
            _UnitPrevCmd:=NoCmd;
            _PathUsed:=0;
            Case _UnitCmd of
              NoCmd :
                Begin
                  _UnitFrame:=FrameUnUsed;
                  _UnitCmd:=CmdBuild;
                  _UnitNextCmd:=NoCmd;
                  _UnitPrevCmd:=NoCmd;
                  _UnitTarget:=NUnit;
                End
              Else
                Begin
                  _UnitNextCmd:=CmdBuild;
                  _UnitNextTarget:=NUnit;
                End
            End;
          End
        Else
          Begin
            If FromClan=HumanControl then
              MyScreen.SendMessage(CanNotCreateMoreUnit);
          End;
      End;
  End;

FUNCTION  TLOCWorld.UnitCommandBuild(UnitNum : TUnitCount;Typer : TUnit;Head : THeading;
                                     X,Y : FastInt;FromClan : TClan) : FastInt;
  Var NUnit,Res : FastInt;
  Begin
    Result:=ROk;
    With MyScreen,MyUnits,Units[UnitNum] do
      Begin
        Res:=CheckCreateMoreUnit(_UnitClan,Typer);
        If Res<>ROk then
          Begin
            If FromClan=HumanControl then
              Case Res of
                -1 : SendMessage(NotEnoughFood);
                -2 : SendMessage(NotEnoughResource);
              End;
            Result:=Res;
            Exit;
          End;
        NUnit:=GetUnUsedUnit;
        If NUnit>0 then
          Begin
            SetUnitToStart(NUnit,FromClan,Typer,Head,X,Y,False);
            PutUnit(NUnit,True,True);
            _UnitPrevCmd:=NoCmd;
            _PathUsed:=0;
            Case _UnitCmd of
              NoCmd :
                Begin
                  _UnitFrame:=FrameUnUsed;
                  _UnitCmd:=CmdBuild;
                  _UnitNextCmd:=NoCmd;
                  _UnitPrevCmd:=NoCmd;
                  _UnitTarget:=NUnit;
                End
              Else
                Begin
                  _UnitNextCmd:=CmdBuild;
                  _UnitNextTarget:=NUnit;
                End
            End;
          End
        Else
          Begin
            If FromClan=HumanControl then
              MyScreen.SendMessage(CanNotCreateMoreUnit);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCommandGotoBuild(UnitNum,Target : TUnitCount);
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If Target>0 then
          Begin
            _UnitPrevCmd:=NoCmd;
            _PathUsed:=0;
            Case _UnitCmd of
              NoCmd :
                Begin
                  _UnitFrame:=FrameUnUsed;
                  _UnitCmd:=CmdBuild;
                  _UnitNextCmd:=NoCmd;
                  _UnitPrevCmd:=NoCmd;
                  _UnitTarget:=Target;
                End
              Else
                Begin
                  _UnitNextCmd:=CmdBuild;
                  _UnitNextTarget:=Target;
                End
            End;
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckAttacking(UnitNum : TUnitCount);
  Var Temp : TUnitSetCmdReturn;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitTarget=0 then
          Begin
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
            Exit;
          End;
        //Unit target not in mapnum ?
        If Not GetUnitAttribute(_UnitTarget,UnitOnMapNum) then
          Begin
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
            Exit;
          End;
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Case _UnitCmd of
            CmdAttack :
              Begin
                //Unit still have a weapon ?
                If _UnitItems[WeaponItem].Typer=ItemNone then
                  Begin
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End;
                If Not UnitGetNextCommand(UnitNum) then
                  Begin
                    Temp:=TestUnitAttackRange(UnitNum,_UnitTarget);
                    If Temp=CanAttack then
                      Begin
                        _UnitCmd:=CmdAttacking;
                        _UnitFrame:=FrameUnUsed;
                        _UnitWait:=0;
                        //Reset path used for refinding path if attacking complete
                        _PathUsed:=0;
                        //Unit can get ahead to target ?
                        If Not UnitGetHeadingToAttack(UnitNum) then
                          Begin
                            If Not UnitGetPrevCommand(UnitNum) then
                              If Not UnitGetNextCommand(UnitNum) then
                                UnitResetCommand(UnitNum);
                          End;
                      End
                    Else
                    //Set unit _UnitDest to target target position
                      Begin
                        _UnitDest:=Units[_UnitTarget]._UnitPos;
                      End;
                  End;
              End;
            {CmdAttacking :
              Begin
                If _UnitNextCmd<>NoCmd then
                  Begin
                    _UnitFrame:=FrameUnUsed;
                    _UnitWait:=0;
                    _UnitCmd:=_UnitNextCmd;
                  End
                Else
                If TestUnitAttackRange(UnitNum,_UnitTarget)<>CanAttack then
                  Begin
                    _UnitFrame:=FrameUnUsed;
                    _UnitWait:=0;
                    _UnitCmd:=CmdAttack;
                  End
                Else
                  Begin
                    _UnitFrame:=FrameUnUsed;
                    _UnitWait:=0;
                    UnitGetHeadingToAttack(UnitNum);
                  End;
              End;}
          End
        Else
          Begin
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckCastSpell(UnitNum : TUnitCount);
  Var Temp : TUnitSetCmdReturn;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Castspell to area ?
        If _UnitTarget=0 then
          Begin
            _UnitDest:=_PatrolDest;
            Temp:=TestUnitCastSpellRange(UnitNum,_PatrolDest.X,_PatrolDest.Y,_UnitSpell);
            If Temp=CanAttack then
              Begin
                If Not UnitGetHeadingToAttackNoTarget(UnitNum) then
                  Begin
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End
                Else
                  Begin
                    _UnitCmd:=CmdCastSpelling;
                    _UnitFrame:=FrameUnUsed;
                    _UnitWait:=0;
                    //Reset path used for refinding path if attacking complete
                    _PathUsed:=0;
                  End;
              End
            Else
            //Set unit _UnitDest to target target position, that _PatrolDest !
              Begin
                //_UnitDest:=_PatrolDest;
              End;
            Exit;
          End;
        //Unit target not in mapnum ?
        If Not GetUnitAttribute(_UnitTarget,UnitOnMapNum) then
          Begin
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
            Exit;
          End;
        //Castspell to target ?
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Case _UnitCmd of
            CmdCastSpell :
              Begin
                If _UnitNextCmd<>NoCmd then
                  Begin
                    _UnitCmd:=_UnitNextCmd;
                    _UnitWait:=0;
                    _UnitFrame:=FrameUnUsed;
                  End
                Else
                  Begin
                    //Why not test castspell range ?
                    Temp:=TestUnitCastSpellRange(UnitNum,_UnitTarget,_UnitSpell);
                    If Temp=CanAttack then
                      Begin
                        _UnitCmd:=CmdCastSpelling;
                        _UnitFrame:=FrameUnUsed;
                        _UnitWait:=0;
                        //Reset path used for refinding path if attacking complete
                        _PathUsed:=0;
                        //Unit can get ahead to target ?
                        If Not UnitGetHeadingToAttack(UnitNum) then
                          Begin
                            If Not UnitGetPrevCommand(UnitNum) then
                              If Not UnitGetNextCommand(UnitNum) then
                                UnitResetCommand(UnitNum);
                          End;
                      End
                    Else
                    //Set unit _UnitDest to target target position
                      Begin
                        _UnitDest:=Units[_UnitTarget]._UnitPos;
                      End;
                  End;
              End;
          End
        Else
          Begin
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckBuilding(UnitNum : TUnitCount);
  Var UnitGrouped : Boolean;
      Long        : FastInt;
  Begin
    With MyScreen,MyUnits,Units[UnitNum] do
      Begin
        If (_UnitTarget=0) or
           (Units[_UnitTarget]._UnitCmd<>CmdStartBuild) then
          Begin
            UnitResetCommand(UnitNum);
          End
        Else
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            _UnitDest:=Units[_UnitTarget]._UnitPos;
            Long:=RangeBetweenUnit(UnitNum,_UnitTarget);
            If Long<=DistanceCanBuild then
              Begin
                UnitGrouped:=_UnitGroup and 128=128;
                //Why clear unit queue ?
                //UnitClearQueue(_UnitTarget);
                If AddUnitCarrier(_UnitTarget,UnitNum,False) then
                  Begin
                    _UnitCmd:=CmdBuildWork;
                    If UnitGrouped then
                      Begin
                        If CmdWaitForSelect<>NoCmd then
                          Begin
                            If CmdWaitForSelect=CmdBuild then
                              Begin
                                //Still have a unit can build this unit waiting ?
                                If GetUnitCanBuild(SaveGroups[MaxGroup],HumanControl,UnitWaitForBuild)>0 then
                                  Begin
                                    //Only setup for selected button and item button !
                                    SetupUnitSelectedButtons(SaveGroups[MaxGroup]);
                                    SetupUnitItemButtons(UnitFocus);
                                  End
                                Else//Update group skill
                                  Begin
                                    GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                                    SetupGroupSelected(MaxGroup);
                                  End;
                              End
                            Else
                              Begin
                                //Still have a unit has a skill wait for choosen ?
                                If GetUnitHaveSkill(SaveGroups[MaxGroup],HumanControl,CmdWaitForSelect)>0 then
                                  Begin
                                    //Only setup for selected button and item button !
                                    SetupUnitSelectedButtons(SaveGroups[MaxGroup]);
                                    SetupUnitItemButtons(UnitFocus);
                                  End
                                Else//Update group skill
                                  Begin
                                    GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                                    SetupGroupSelected(MaxGroup);
                                  End;
                              End;
                          End
                        Else
                          Begin
                            GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                            SetupGroupSelected(MaxGroup);
                          End;
                      End
                    Else
                    //Unit target are grouped ? I'm take code here because before few line, I'm call
                    //AddUnitCarrier with no update button !
                    If Units[_UnitTarget]._UnitGroup and 128=128 then
                      Begin
                        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                        SetupGroupSelected(MaxGroup);
                      End;
                  End
                Else UnitResetCommand(UnitNum);
              End;
          End
        Else
          Begin
            _UnitFrame:=FrameUnUsed;
            _UnitTarget:=0;
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckMining(UnitNum : TUnitCount);
  Var UnitGrouped : Boolean;
      Long        : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            If Units[_UnitTarget]._UnitResource._GoldAmound<=0 then
              Begin
                UnitCommandFollow(UnitNum,_UnitTarget,_UnitClan);
                Exit;
              End;
            _UnitDest:=Units[_UnitTarget]._UnitPos;
            Long:=RangeBetweenUnit(UnitNum,_UnitTarget);
            If Long<=DistanceCanMining then
              Begin
                UnitGrouped:=_UnitGroup and 128=128;
                //UnitClearQueue(_UnitTarget);
                If AddUnitCarrier(_UnitTarget,UnitNum) then
                  Begin
                    //Set unit to command mining
                    _UnitCmd:=CmdMining;
                    //Start counting
                    _UnitWait:=0;
                    If UnitGrouped then
                      Begin
                        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                        SetupGroupSelected(MaxGroup);
                      End;
                  End
                Else
                  Begin
                    //UnitCommandWastedTime(UnitNum);
                  End;
              End;
          End
        Else
          Begin
            _UnitFrame:=FrameUnUsed;
            _UnitTarget:=0;
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckReturnGold(UnitNum : TUnitCount);
  Var Long : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitTarget=0 then
          Begin
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End
        Else
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            _UnitDest:=Units[_UnitTarget]._UnitPos;
            Long:=RangeBetweenUnit(UnitNum,_ReturnGoldTarget);
            If Long<=DistanceCanReturnGold then
              Begin
                //Unit return gold ?
                SetUnitReturnGold(UnitNum);
                //So need check unit has command harvest ?
                _UnitCmd:=NoCmd;
                UnitCommandHarvest(UnitNum,_UnitClan);
              End;
          End
        Else
          Begin
            If UnitFindReturnGoldTarget(UnitNum) then
              Begin
                _UnitTarget:=_ReturnGoldTarget;
                _UnitDest:=Units[_UnitTarget]._UnitPos;
                Long:=RangeBetweenUnit(UnitNum,_ReturnGoldTarget);
                If Long<=DistanceCanReturnGold then
                  Begin
                    //Unit return gold ?
                    SetUnitReturnGold(UnitNum);
                    //So need check unit has command harvest ?
                    _UnitCmd:=NoCmd;
                    UnitCommandHarvest(UnitNum,_UnitClan);
                  End;
              End
            Else
              Begin
                _UnitFrame:=FrameUnUsed;
                _UnitTarget:=0;
                If Not UnitGetPrevCommand(UnitNum) then
                  If Not UnitGetNextCommand(UnitNum) then
                    UnitResetCommand(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckPutItem(UnitNum : TUnitCount);
  Var NewUnitNum,Long : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Unit put item to specific land target !
        If _UnitTarget=0 then
          Begin
            Long:=RangeBetweenUnit(UnitNum,_UnitDest.X,_UnitDest.Y);
            If Long<=DistanceCanPutItem then
              Begin
                //Safe code, check slot before put item ! But before set unit command, I'm already
                //check unit slot, that safe for hacked or override data code !
                If _UnitItems[_ItemSlot].Typer<>ItemNone then
                  Begin
                    //New ItemStore and store item in slot to this unit !
                    NewUnitNum:=GetUnusedUnit;
                    If NewUnitNum<>0 then
                      Begin
                        //Unit item store new is gaia unit !
                        SetUnitToDefault(NewUnitNum,Gaia,ItemStore,_UnitDest.X,_UnitDest.Y);
                        PutUnit(NewUnitNum,True,True);
                        Units[NewUnitNum]._UnitItems[Item1]:=_UnitItems[_ItemSlot];
                        _UnitItems[_ItemSlot].Typer:=ItemNone;
                        _UnitItems[_ItemSlot].Number:=0;
                      End;
                    //If unit in focus ? That unit shown item selection,
                    //then reload unit group state !
                    If UnitNum=UnitFocus then
                      SetupGroupSelected(MaxGroup);
                  End;
                If Not UnitGetNextCommand(UnitNum) then
                  UnitResetCommand(UnitNum);
              End;
          End
        Else
        //Put item to specific unit, but unit must alive !
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            _UnitDest:=Units[_UnitTarget]._UnitPos;
            Long:=RangeBetweenUnit(UnitNum,_UnitTarget);
            If Long<=DistanceCanPutItem then
              Begin
                UnitExchangeItem(UnitNum,_UnitTarget,_ItemSlot);
                If (UnitNum=UnitFocus) or
                   (_UnitTarget=UnitFocus) then
                  SetupGroupSelected(MaxGroup);
                If Not UnitGetNextCommand(UnitNum) then
                  UnitResetCommand(UnitNum);
              End;
          End
        Else//Reset unit command !
          Begin
            _UnitFrame:=FrameUnUsed;
            _UnitTarget:=0;
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckPickUpItem(UnitNum : TUnitCount);
  Var Long : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Pick up item from specific item store unit, but unit must alive !
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            _UnitDest:=Units[_UnitTarget]._UnitPos;
            Long:=RangeBetweenUnit(UnitNum,_UnitTarget);
            If Long<=DistanceCanPickItem then
              Begin
                UnitPickUpItem(UnitNum,_UnitTarget);
                If (UnitNum=UnitFocus) or
                   (_UnitTarget=UnitFocus) then
                  SetupGroupSelected(MaxGroup);
                If Not UnitGetNextCommand(UnitNum) then
                  UnitResetCommand(UnitNum);
              End;
          End
        Else//Reset unit command !
          Begin
            _UnitFrame:=FrameUnUsed;
            _UnitTarget:=0;
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

FUNCTION  TLOCWorld.UnitPickUpItem(UnitNum,UnitTarget : TUnitCount) : Boolean;
  Var SlotIdx,SlotTake : TItemCount;
  Begin
    With MyUnits do
      Begin
        For SlotIdx:=Low(TItemCount) to High(TItemCount) do
          If Units[UnitTarget]._UnitItems[SlotIdx].Typer<>ItemNone then
            If GetUnitFitItemSlot(UnitNum,Units[UnitTarget]._UnitItems[SlotIdx],SlotTake) then
              Begin
                UnitAddSlot(UnitNum,SlotTake,Units[UnitTarget]._UnitItems[SlotIdx]);
                UnitClearSlot(UnitTarget,SlotIdx);
              End;
        If UnitCountItem(UnitTarget)=0 then
          Begin
            Result:=True;
            PickUnit(UnitTarget,True);
            BringUnitToDeath(UnitTarget);
            SetUnitToUnUsed(UnitTarget);
          End
        Else Result:=False;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckLoadUnit(UnitNum : TUnitCount);
  Var Long : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Pick up item from specific item store unit, but unit must alive !
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            //Unit not in mapnum, maybe unit into house or someone loaded unit ?
            If Not GetUnitAttribute(_UnitTarget,UnitOnMapNum) then
              Begin
                _UnitFrame:=FrameUnUsed;
                _UnitTarget:=0;
                If Not UnitGetPrevCommand(UnitNum) then
                  If Not UnitGetNextCommand(UnitNum) then
                    UnitResetCommand(UnitNum);
                Exit;
              End;
            _UnitDest:=Units[_UnitTarget]._UnitPos;
            Long:=RangeBetweenUnit(UnitNum,_UnitTarget);
            If Long<=DistanceCanLoadUnit then
              Begin
                AddUnitCarrier(UnitNum,_UnitTarget);
                If Not UnitGetNextCommand(UnitNum) then
                  UnitResetCommand(UnitNum);
              End;
          End
        Else//Reset unit command !
          Begin
            _UnitFrame:=FrameUnUsed;
            _UnitTarget:=0;
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckUnLoadUnit(UnitNum : TUnitCount);
  Var Long : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        Long:=RangeBetweenUnit(UnitNum,_UnitDest.X,_UnitDest.Y);
        If Long<=DistanceCanUnLoadUnit then
          Begin
            UnitUnLoadCarrier(UnitNum);
            If Not UnitGetNextCommand(UnitNum) then
              UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitCheckTransport(UnitNum : TUnitCount);
  Var Long : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Pick up item from specific item store unit, but unit must alive !
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            //Unit not in mapnum, maybe unit into house or someone loaded unit ?
            If Not GetUnitAttribute(_UnitTarget,UnitOnMapNum) then
              Begin
                _UnitFrame:=FrameUnUsed;
                _UnitTarget:=0;
                If Not UnitGetPrevCommand(UnitNum) then
                  If Not UnitGetNextCommand(UnitNum) then
                    UnitResetCommand(UnitNum);
                Exit;
              End;
            _UnitDest:=Units[_UnitTarget]._UnitPos;
            Long:=RangeBetweenUnit(UnitNum,_UnitTarget);
            If Long<=DistanceCanLoadUnit then
              AddUnitCarrier(_UnitTarget,UnitNum);
          End
        Else//Reset unit command !
          Begin
            _UnitFrame:=FrameUnUsed;
            _UnitTarget:=0;
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitTraining(UnitNum : TUnitCount);
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitHitPoint<UnitsProperty[_UnitClan,_UnitTyper].HitPoint then Inc(_UnitHitPoint)
        Else
          Begin
            _UnitCmd:=CmdBuildComplete;
          End;
      End;
  End;

PROCEDURE TLOCWorld.UnitProcessQueue(UnitNum : TUnitCount);
  Var Change : Boolean;
      Z      : TQueueCount;
  Begin
    With MyScreen,MyUnits,Units[UnitNum] do
      Begin
        Change:=False;
        For Z:=Low(TQueueCount) to High(TQueueCount) do
          If _UnitQueue[Z]<>0 then
            Begin
              Case Units[_UnitQueue[Z]]._UnitCmd of
                CmdStartBuild :
                  Begin
                    Change:=True;
                    If Z=Low(TQueueCount) then
                      UnitTraining(_UnitQueue[Z])
                    Else
                    If CheckBaseAttribute(_UnitQueue[Z],UnitFreeTraining) then
                      UnitTraining(_UnitQueue[Z]);
                  End;
                CmdBuildComplete :
                  Begin
                    Change:=True;
                    //Increase food gain ?
                    IncreaseFoodLimit(Units[_UnitQueue[Z]]._UnitClan,0,
                                      UnitsProperty[Units[_UnitQueue[Z]]._UnitClan,
                                                    Units[_UnitQueue[Z]]._UnitTyper].FoodGain,0);
                    //Decrease unit queue counting
                    Dec(ClanInfo[Units[_UnitQueue[Z]]._UnitClan].
                                 UnitInQueue[Units[_UnitQueue[Z]]._UnitTyper]);
                    UnitUnLoadSlot(UnitNum,Z);
                  End;
              End;
            End;
        If (_UnitGroup and 128=128) and
           Change then UpdateToolTip:=True;
      End;
  End;

FUNCTION  TLOCWorld.AddUnitCarrier(UnitNum,Target : TUnitCount;UpdateButton : Boolean = True) : Boolean;
  Var Idx         : TQueueCount;
      UnitGrouped : Boolean;
  Begin
    Result:=False;
    With MyUnits,Units[UnitNum] do
      Begin
        For Idx:=Low(TQueueCount) to High(TQueueCount) do
          If _UnitQueue[Idx]=0 then
            Begin
              _UnitQueue[Idx]:=Target;
              //For safe code !
              If GetUnitAttribute(Target,UnitOnMapNum) then PickUnit(Target,True);
              UnitGrouped:=Units[Target]._UnitGroup and 128=128;
              ClearUnitInAllGroup(Target,UpdateButton);
              Units[Target]._UnitCmd:=NoCmd;
              If (UnitGrouped or (_UnitGroup and 128=128)) and
                 UpdateButton then
                Begin
                  GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                  SetupGroupSelected(MaxGroup);
                End;
              Result:=True;
              Exit;
            End;
      End;
  End;

FUNCTION  TLOCWorld.GetFreeTileAroundUnit(UnitNum,UnitPlace : TUnitCount;Var X,Y : FastInt) : Boolean;
  Var I,J : FastInt;
  Begin
    Result:=False;
    With MyUnits,Units[UnitNum] do
      For I:=_UnitPos.X-1 to _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX+1 do
        For J:=_UnitPos.Y-1 to _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY+1 do
          If TestUnitPos(UnitPlace,I,J)=PlaceOk then
            Begin
              X:=I;Y:=J;
              Result:=True;
              Exit;
            End;
  End;

FUNCTION  TLOCWorld.GetBestFreeTileAroundUnit(UnitNum,UnitPlace,NearUnit : TUnitCount;Var X,Y : FastInt) : Boolean;
  Var I,J,Long,Size : FastInt;
  Begin
    Long:=High(FastInt);
    With MyUnits,Units[UnitNum] do
      For I:=_UnitPos.X-1 to _UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX+1 do
        For J:=_UnitPos.Y-1 to _UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY+1 do
          If TestUnitPos(UnitPlace,I,J)=PlaceOk then
            Begin
              Size:=RangeBetweenUnit(NearUnit,I,J);
              If Size<Long then
                Begin
                  X:=I;Y:=J;
                  Long:=Size;
                End;
            End;
    Result:=Long<High(FastInt);
  End;

FUNCTION  TLOCWorld.UnitUnLoadSlot(UnitNum : TUnitCount;SlotNum : TQueueCount;SendRally : Boolean = True) : Boolean;
  Var X,Y : FastInt;
  Begin
    Result:=False;
    With MyUnits,Units[UnitNum] do
      Begin
        If GetFreeTileAroundUnit(UnitNum,_UnitQueue[SlotNum],X,Y) then
          Begin
            Result:=True;
            //Set unit on slot can self control
            SetUnitAttribute(_UnitQueue[SlotNum],UnitSelfControl,True);
            SetUnitPos(_UnitQueue[SlotNum],X,Y);
            UnitResetCommand(_UnitQueue[SlotNum]);
            If ((_UnitPos.X<>_UnitDest.X) or (_UnitPos.Y<>_UnitDest.Y))
               and SendRally then
              Begin
                If CheckUnitSkill(_UnitQueue[SlotNum],CmdAttack) then
                  UnitCommandAttackAt(_UnitQueue[SlotNum],_UnitDest.X,_UnitDest.Y,_UnitClan)
                Else UnitCommandMove(_UnitQueue[SlotNum],_UnitDest.X,_UnitDest.Y,_UnitClan);
              End;
            _UnitQueue[SlotNum]:=0;
            ArrangeUnitQueue(UnitNum);
            If _UnitGroup and 128=128 then
              SetupGroupSelected(MaxGroup);
          End;
      End;
  End;

FUNCTION  TLOCWorld.UnitUnLoadSlot(UnitNum,NearUnit : TUnitCount;SlotNum : TQueueCount;SendRally : Boolean = True) : Boolean;
  Var X,Y : FastInt;
  Begin
    Result:=False;
    With MyUnits,Units[UnitNum] do
      Begin
        If GetBestFreeTileAroundUnit(UnitNum,_UnitQueue[SlotNum],NearUnit,X,Y) then
          Begin
            Result:=True;
            //Set unit on slot can self control
            SetUnitAttribute(_UnitQueue[SlotNum],UnitSelfControl,True);
            SetUnitPos(_UnitQueue[SlotNum],X,Y);
            UnitResetCommand(_UnitQueue[SlotNum]);
            If ((_UnitPos.X<>_UnitDest.X) or (_UnitPos.Y<>_UnitDest.Y))
               and SendRally then
              Begin
                If CheckUnitSkill(_UnitQueue[SlotNum],CmdAttack) then
                  UnitCommandAttackAt(_UnitQueue[SlotNum],_UnitDest.X,_UnitDest.Y,_UnitClan)
                Else UnitCommandMove(_UnitQueue[SlotNum],_UnitDest.X,_UnitDest.Y,_UnitClan);
              End;
            _UnitQueue[SlotNum]:=0;
            ArrangeUnitQueue(UnitNum);
            If _UnitGroup and 128=128 then
              SetupGroupSelected(MaxGroup);
          End;
      End;
  End;

FUNCTION  TLOCWorld.UnitUnLoad(UnitNum,Target : TUnitCount) : Boolean;
  Var Idx : TQueueCount;
  Begin
    Result:=False;
    With MyUnits,Units[UnitNum] do
      Begin
        For Idx:=Low(TQueueCount) to High(TQueueCount) do
          If _UnitQueue[Idx]=Target then
            Begin
              If UnitUnLoadSlot(UnitNum,Idx) then
                Begin
                  Result:=True;
                  Exit;
                End;
            End;
      End;
  End;

FUNCTION  TLOCWorld.UnitUnLoad(UnitNum,Target,NearUnit : TUnitCount) : Boolean;
  Var Idx : TQueueCount;
  Begin
    Result:=False;
    With MyUnits,Units[UnitNum] do
      Begin
        For Idx:=Low(TQueueCount) to High(TQueueCount) do
          If _UnitQueue[Idx]=Target then
            Begin
              If UnitUnLoadSlot(UnitNum,NearUnit,Idx) then
                Begin
                  Result:=True;
                  Exit;
                End;
            End;
      End;
  End;

PROCEDURE TLOCWorld.UnitUnLoadCarrier(UnitNum : TUnitCount;SendRally : Boolean = True);
  Var Idx   : TQueueCount;
      Found : Boolean;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        Repeat
          Found:=False;
          For Idx:=Low(TQueueCount) to High(TQueueCount) do
            If _UnitQueue[Idx]<>0 then
              Begin
                UnitUnLoadSlot(UnitNum,Idx,SendRally);
                Found:=True;
              End;
        Until Not Found;
      End;
  End;

PROCEDURE TLOCWorld.SendGroupRightClickCommand(X,Y : FastInt);
  Var Z : FastInt;
  Begin
    With MyUnits do
      For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
        If SaveGroups[MaxGroup][Z]<>0 then
          SendUnitRightClickCommand(SaveGroups[MaxGroup][Z],X,Y);
  End;

PROCEDURE TLOCWorld.SendUnitRightClickCommand(UnitNum : TUnitCount;X,Y : FastInt);
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        SetUnitCommand(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].RightCommandNoTarget,X,Y,HumanControl);
      End;
  End;

PROCEDURE TLOCWorld.SendGroupRightClickCommand(Target : TUnitCount);
  Var Z : FastInt;
  Begin
    With MyScreen,MyUnits do
      If UnitFocus<>0 then
        Begin
          //Unit target is item store and unit focus has a item slot, set command to pick up item
          If Units[Target]._UnitTyper=ItemStore then
            Begin
              UnitCommandPickUpItem(UnitFocus,Target,HumanControl);
            End
          Else
          //Command go to building ?
          If (Units[Target]._UnitCmd=CmdStartBuild) and
             (GetUnitCanBuild(SaveGroups[MaxGroup],HumanControl,Units[Target]._UnitTyper)<>0) then
            Begin
              For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
                If SaveGroups[MaxGroup][Z]<>0 then
                  If CheckUnitCanGen(SaveGroups[MaxGroup][Z],Units[Target]._UnitTyper) then
                    UnitCommandGotoBuild(SaveGroups[MaxGroup][Z],Target)
                  Else SendUnitRightClickCommand(SaveGroups[MaxGroup][Z],Target);
            End
          Else
          //Command mining at target !
          If UnitTestBaseAttribute(Target,UnitIsGoldMine) and
             (GetUnitHaveSkill(SaveGroups[MaxGroup],HumanControl,CmdHarvest)<>0) then
            Begin
              For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
                If SaveGroups[MaxGroup][Z]<>0 then
                  If CheckUnitSkill(SaveGroups[MaxGroup][Z],CmdHarvest) then
                    UnitCommandHarvest(SaveGroups[MaxGroup][Z],Target,HumanControl)
                  Else SendUnitRightClickCommand(SaveGroups[MaxGroup][Z],Target);
            End
          Else
          //Comand return gold ?
          If UnitTestBaseAttribute(Target,UnitIsDeposit) then
            Begin
              For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
                If SaveGroups[MaxGroup][Z]<>0 then
                  If UnitHaveAResource(SaveGroups[MaxGroup][Z]) then
                    UnitCommandReturnGold(SaveGroups[MaxGroup][Z],Target,HumanControl)
                  Else SendUnitRightClickCommand(SaveGroups[MaxGroup][Z],Target);
            End
          Else
            Begin
              For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
                If SaveGroups[MaxGroup][Z]<>0 then
                  SendUnitRightClickCommand(SaveGroups[MaxGroup][Z],Target);
            End;
        End
      Else
        Begin
          For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
            If SaveGroups[MaxGroup][Z]<>0 then
              SendUnitRightClickCommand(SaveGroups[MaxGroup][Z],Target);
        End;
  End;

PROCEDURE TLOCWorld.SendUnitRightClickCommand(UnitNum,Target : TUnitCount);
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        //Two unit in same clan
        If (_UnitClan=Units[Target]._UnitClan) then
          Begin
            //UnitNum is transport
            If UnitTestBaseAttribute(UnitNum,UnitIsTransport) and
               //Target can transported
               UnitTestBaseAttribute(Target,UnitCanTransported) then
              Begin
                //Set unit command to load unit and clear
                UnitCommandLoadUnit(UnitNum,Target,HumanControl);
                Exit;
              End;
            //UnitNum can transported
            If UnitTestBaseAttribute(UnitNum,UnitCanTransported) and
               //Target is transport
               UnitTestBaseAttribute(Target,UnitIsTransport) then
              Begin
                UnitCommandGoTransportUnit(UnitNum,Target,HumanControl);
                Exit;
              End;
          End;
        If ClanInfo[_UnitClan].Diplomacy[Units[Target]._UnitClan]=Ally then
          SetUnitCommand(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].RightCommandTargetAlly,Target,HumanControl)
        Else SetUnitCommand(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].RightCommandTargetEnemy,Target,HumanControl);
      End;
  End;

PROCEDURE TLOCWorld.SelectGroup(GroupNum : Byte);
  Begin
    If MyUnits.CurrentGroup=GroupNum then CenterGroup(GroupNum)
    Else MyUnits.LoadGroup(GroupNum);
  End;

PROCEDURE TLOCWorld.CenterGroup(GroupNum : Byte);
  Var Z,X,Y,Count : FastInt;
  Begin
    X:=0;Y:=0;Count:=0;
    With MyUnits do
      For Z:=Low(TUnitSelectionCount) to High(TUnitSelectionCount) do
        If SaveGroups[GroupNum][Z]<>0 then
          Begin
            X:=X+Units[SaveGroups[GroupNum][Z]]._UnitPos.X;
            Y:=Y+Units[SaveGroups[GroupNum][Z]]._UnitPos.Y;
            Inc(Count);
          End;
    If Count<>0 then
      SetMapView((X div Count)-(DefaultMapViewX div 2),
                 (Y div Count)-(DefaultMapViewY div 2));
  End;

PROCEDURE TLOCWorld.GetRealMousePos(Var X,Y,XS,YS : FastInt);
  Begin
    With MyScreen do
      Begin
        X:=(Input.MouseX-ViewPosXOS) div DefaultMapTileX+MapViewX;
        Y:=(Input.MouseY-ViewPosYOS) div DefaultMapTileX+MapViewY;
        XS:=(Input.MouseX-ViewPosXOS) mod DefaultMapTileX;
        YS:=(Input.MouseY-ViewPosYOS) mod DefaultMapTileX;
      End;
  End;

PROCEDURE TLOCWorld.SelectFreeWorker;
  Var Index : TUnitCount;
  Begin
    Index:=MyUnits.FindingFreeWorker;
    If Index<>-1 then
      Begin
        MyUnits.SelectOnlyUnit(Index);
        CenterGroup(MaxGroup);
      End;
  End;

PROCEDURE TLOCWorld.SelectFreeTroop;
  Var Index : TUnitCount;
  Begin
    Index:=MyUnits.FindingFreeTroop;
    If Index<>-1 then
      Begin
        MyUnits.SelectOnlyUnit(Index);
        CenterGroup(MaxGroup);
      End;
  End;

PROCEDURE TLOCWorld.SelectFreeBuilding;
  Var Index : TUnitCount;
  Begin
    Index:=MyUnits.FindingFreeBuilding;
    If Index<>-1 then
      Begin
        MyUnits.SelectOnlyUnit(Index);
        CenterGroup(MaxGroup);
      End;
  End;


FUNCTION  TLOCWorld.CanSeeMissile(MisNum : TMissileCount) : Boolean;
  Var I,J : FastInt;
  Begin
    With MyUnits,Missiles[MisNum] do
      Begin
        If Typer=MissileNone then
          Begin
            Result:=False;
            Exit;
          End;
        //Get real position
        I:=MisPos.X div DefaultMapTileX;
        J:=MisPos.Y div DefaultMapTileY;
        Result:=(I>=MapViewX-1) and (I<=MapViewX+DefaultMapViewX+1) and
                (J>=MapViewY-1) and (J<=MapViewY+DefaultMapViewY+1);
      End;
  End;

PROCEDURE TLOCWorld.RestartWorldVisited;
  Var I,J : FastInt;
  Begin
    For I:=0 to MapSizeX-1 do
      For J:=0 to MapSizeY-1 do
        SetTileAttr(I,J,MapDontVisited,True);
  End;

PROCEDURE TLOCWorld.RestartWorldFog;
  Var I,J : FastInt;
  Begin
    With MyScreen,MyUnits do
      Begin
        //Restart world fog
        If Not CheatStatus[NoFog] then
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Begin
                If MapNum[I,J]<>0 then
                  If CanSeeThisUnit(HumanControl,MapNum[I,J]) then
                    PlaceUnitInUnderFogMap(MapNum[I,J]);
                SetTileAttr(I,J,MapDontVisible,True);
              End;
        //Restart truesight
        For I:=0 to MapSizeX-1 do
          For J:=0 to MapSizeY-1 do
            MapTrueSight[I,J]:=0;
      End;
  End;

PROCEDURE TLOCWorld.UpdateWorldFog;
  Var UpdateSkill : Boolean;
      Z           : FastInt;
  Begin
    RestartWorldFog;
    With MyScreen,MyUnits do
      Begin
        //Recounting unit view size
        For Z:=Low(Units) to High(Units) do
          If (Units[Z]._UnitHitPoint>=0) and
             GetUnitAttribute(Z,UnitOnMapNum) then
            UnitUpdatePosition(Z);
        UpdateSkill:=FindUnitCanSee(SaveGroups[MaxGroup]);
        If UpdateSkill then
          Begin
            ClearAllUnitCantSee(SaveGroups[MaxGroup]);
            GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            SetupGroupSelected(MaxGroup);
          End;
      End;
  End;

PROCEDURE TLOCWorld.OpenWorldMapVisited;
  Var I,J : FastInt;
  Begin
    For I:=0 to MapSizeX-1 do
      For J:=0 to MapSizeY-1 do
        SetTileAttr(I,J,MapDontVisited,False);
    UpdateWorldFog;
  End;

PROCEDURE TLOCWorld.OpenWorldFog;
  Var I,J : FastInt;
  Begin
    With MyScreen do
      Begin
        For I:=0 to MapSizeX-1 do
          For J:=0 to MapSizeY-1 do
            SetTileAttr(I,J,MapDontVisible,False);
        RestartMapUnitUnderFog;
      End;
  End;

PROCEDURE TLOCWorld.WaterUpDate;
  //Var I,J : FastInt;
  Begin
    {For I:=0 to MapTileSizeX-1 do
      For J:=0 to MapTileSizeY-1 do
        Begin
          If MapTileFrame[I,J]<MaxWaterFrame then Inc(MapTileFrame[I,J])
          Else MapTileFrame[I,J]:=0;
        End;{}
  End;

FUNCTION  TLOCWorld.Cost(X1,Y1,X2,Y2 : SmallInt) : Integer;
  Begin
    {If Abs(X1-X2)>Abs(Y1-Y2) then Result:=Abs(X1-X2)
    Else Result:=Abs(Y1-Y2);}
    Result:=Sqr(X1-X2)+Sqr(Y1-Y2);
  End;

PROCEDURE TLOCWorld.AStarRemoveMinimum(Post : Integer);
  {$IfNDef NoCheck}
  Var Z,Min : Integer;
  {$EndIf}
  Begin
    {$IfDef NoCheck}
    Inc(FirstOpenSet);   
    {$Else}
    Min:=MaxCost;
    For Z:=0 to OpenSetSize-1 do
      If OpenSet[Z].Check and (OpenSet[Z].C<Min) then
        Begin
          FirstOpenSet:=Z;
          Min:=OpenSet[Z].C;
        End;
    OpenSet[FirstOpenSet].Check:=False;
    {$EndIf}
  End;

PROCEDURE TLOCWorld.AStarAddNode(X,Y : SmallInt;{$IfNDef NoIndex}O,{$EndIf}Cost : Integer);
  {$IfDef NoCheck}
  Var Tmp,Index : Integer;
  {$EndIf}
  Begin
    //Remove this but grow OpenSetMaxSize large than MaxStepCounter can gen
    // for more speed on this rountine
    //If OpenSetSize=OpenSetMaxSize then Exit;
    {$IfDef NoCheck}
    Index:=OpenSetSize;
    While (Index>FirstOpenSet) and (Cost<OpenSet[Index-1].C) do Dec(Index);
    For Tmp:=OpenSetSize downto Index+1 do OpenSet[Tmp]:=OpenSet[Tmp-1];
    OpenSet[Index].X:=X;
    OpenSet[Index].Y:=Y;
    {$IfNDef NoIndex}
    OpenSet[Index].O:=O;
    {$EndIf}
    OpenSet[Index].C:=Cost;
    Inc(OpenSetSize);
    {$Else}
    OpenSet[OpenSetSize].X:=X;
    OpenSet[OpenSetSize].Y:=Y;
    {$IfNDef NoIndex}
    OpenSet[OpenSetSize].O:=O;
    {$EndIf}
    OpenSet[OpenSetSize].C:=Cost;
    OpenSet[OpenSetSize].Check:=True;
    Inc(OpenSetSize);
    {$EndIf}
  End;

PROCEDURE TLOCWorld.AStarReplaceNode(Node,Cost : Integer);
  Var TmpOpen : TOpen;
      Tmp     : Integer;
  Begin
    OpenSet[Node].C:=Cost;
    Tmp:=Node;
    While Tmp>0 do
      Begin
        If OpenSet[Tmp].C<OpenSet[Tmp-1].C then
          Begin
            TmpOpen:=OpenSet[Tmp];
            OpenSet[Tmp]:=OpenSet[Tmp-1];
            OpenSet[Tmp-1]:=TmpOpen;
            Dec(Tmp);
          End
        Else Break;
      End;
  End;

FUNCTION  TLOCWorld.AStarFindNode(EO : Integer) : Integer;
  {$IfNDef NoIndex}
  Var Z : SmallInt;
  {$EndIf}
  Begin
    {$IfNDef NoIndex}
    For Z:=0 to OpenSetSize-1 do
      If OpenSet[Z].O=EO then
        Begin
          Result:=Z;
          Exit;
        End;
    {$EndIf}
    Result:=-1;
  End;

PROCEDURE TLOCWorld.ClearSet;
  Var I,J : Integer;
  Begin
    {$IfDef SafeClearCloseSet}
    For I:=0 to MapSizeX-1 do
      For J:=0 to MapSizeY-1 do
        Begin
          AStarMatrix[I*MapSizeY+J].CostFromStart:=MaxCost;
          {$IfNDef NoInGoal}
          AStarMatrix[I*MapSizeY+J].InGoal:=0;
          {$EndIf}
        End;
    {$Else}
    If NumInCloseSet=0 then Exit;
    If NumInCloseSet>=ThresholdCloseSet then
      Begin
        For I:=0 to MapSizeX-1 do
          For J:=0 to MapSizeY-1 do
            Begin
              AStarMatrix[I*MapSizeY+J].CostFromStart:=MaxCost;
              {$IfNDef NoInGoal}
              AStarMatrix[I*MapSizeY+J].InGoal:=0;
              {$EndIf}
            End;
      End
    Else
      Begin
        For I:=0 to NumInCloseSet-1 do
          Begin
            AStarMatrix[CloseSet[I]].CostFromStart:=MaxCost;
            {$IfNDef NoInGoal}
            AStarMatrix[CloseSet[I]].InGoal:=0;
            {$EndIf}
          End;
      End;
    {$EndIf}
    NumInCloseSet:=0;
  End;

FUNCTION  TLOCWorld.FindPath(UnitNum : TUnitCount) : Boolean;
  Var X,Y,EX,EY,EO,GX,GY,CX,CY,BestX,BestY,
      BestCostToGoal,NewCost,CostToGoal : Integer;
      {$IfDef NoInGoal}
      RX1,RY1,RX2,RY2                   : Integer;
      {$EndIf}
      HeadTmp                           : THeading;
  Begin
    ClearSet;
    OpenSetSize:=0;
    FirstOpenSet:=0;
    {$IfNDef NoInGoal}
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitTarget<>0 then
          Begin
            EX:=Units[_UnitTarget]._UnitPos.X;
            EY:=Units[_UnitTarget]._UnitPos.Y;
            GX:=Units[_UnitTarget]._UnitPos.X+UnitsProperty[Units[_UnitTarget]._UnitClan,
                                                      Units[_UnitTarget]._UnitTyper].UnitSizeX;
            GY:=Units[_UnitTarget]._UnitPos.Y+UnitsProperty[Units[_UnitTarget]._UnitClan,
                                                      Units[_UnitTarget]._UnitTyper].UnitSizeY;
            For X:=EX to GX do
              For Y:=EY to GY do
                Begin
                  EO:=X*MapSizeY+Y;
                  AStarMatrix[EO].InGoal:=1;
                  If NumInCloseSet<ThresholdCloseSet then
                    Begin
                      CloseSet[NumInCloseSet]:=EO;
                      Inc(NumInCloseSet);
                    End;
                End;
          End
        Else
          Begin
            EX:=_UnitDest.X;
            EY:=_UnitDest.Y;
            EO:=EX*MapSizeY+EY;
            AStarMatrix[EO].InGoal:=1;
            If NumInCloseSet<ThresholdCloseSet then
              Begin
                CloseSet[NumInCloseSet]:=EO;
                Inc(NumInCloseSet);
              End;
          End;
      End;
    {$Else}
    With MyUnits,Units[UnitNum] do
      Begin
        If _UnitTarget<>0 then
          Begin
            RX1:=Units[_UnitTarget]._UnitPos.X;
            RY1:=Units[_UnitTarget]._UnitPos.Y;
            RX2:=RX1+UnitsProperty[Units[_UnitTarget]._UnitClan,
                                   Units[_UnitTarget]._UnitTyper].UnitSizeX;
            RY2:=RY1+UnitsProperty[Units[_UnitTarget]._UnitClan,
                                   Units[_UnitTarget]._UnitTyper].UnitSizeY;
          End
        Else
          Begin
            RX1:=_UnitDest.X;
            RY1:=_UnitDest.Y;
            RX2:=_UnitDest.X;
            RY2:=_UnitDest.Y;
          End;
      End;{}
    {$EndIf}
    CX:=MyUnits.Units[UnitNum]._UnitPos.X;
    CY:=MyUnits.Units[UnitNum]._UnitPos.Y;
    GX:=MyUnits.Units[UnitNum]._UnitDest.X;
    GY:=MyUnits.Units[UnitNum]._UnitDest.Y;
    EO:=CX*MapSizeY+CY;
    AStarMatrix[EO].CostFromStart:=Cost(CX,CY,GX,GY);
    BestCostToGoal:=Cost(CX,CY,GX,GY);
    BestX:=CX;BestY:=CY;EX:=CX;EY:=CY;
    AStarAddNode(CX,CY,{$IfNDef NoIndex}EO,{$EndIf}BestCostToGoal);
    If NumInCloseSet<ThresholdCloseSet then
      Begin
        CloseSet[NumInCloseSet]:=EO;
        Inc(NumInCloseSet);
      End;
    FindPathStepCounter:=DefaultMaxStep;
    {$IfDef FindPathCheckTime}
    StartTimeFindPath:=TimeGetTime;
    {$EndIf}
    While True do
      Begin
        X:=OpenSet[FirstOpenSet].X;
        Y:=OpenSet[FirstOpenSet].Y;
        {$IfNDef NoInGoal}
        EO:=EX*MapSizeY+EY;
        If AStarMatrix[EO].InGoal=1 then
          Begin
            EX:=X;
            EY:=Y;
            Break;
          End;
        {$Else}
        {If (X=GX) and (Y=GY) then
          Begin
            EX:=X;
            EY:=Y;
            Break;
          End;{}
        If (X>=RX1) and (X<=RX2) and
           (Y>=RY1) and (Y<=RY2) then
          Begin
            EX:=X;
            EY:=Y;
            Break;
          End;
        {$EndIf}
        CostToGoal:=OpenSet[FirstOpenSet].C;
        AStarRemoveMinimum(FirstOpenSet);
        If FindPathStepCounter=0 then
          Begin
            EX:=BestX;
            EY:=BestY;
            Break;
          End
        Else Dec(FindPathStepCounter);
        {$IfDef FindPathCheckTime}
        If FindPathStepCounter mod 1000=0 then
          If TimeGetTime-StartTimeFindPath>FindPathTime then
            Begin
              EX:=BestX;
              EY:=BestY;
              Break;
            End;
        {$EndIf}
        If (CostToGoal<BestCostToGoal) then
          Begin
            BestCostToGoal:=CostToGoal;
            BestX:=X;
            BestY:=Y;
          End;
        For HeadTmp:=Low(THeading) to High(THeading) do
          Begin
            EX:=X+Direction[HeadTmp].X;
            EY:=Y+Direction[HeadTmp].Y;
            If (EX<0) or (EX>MapSizeX-1) or
               (EY<0) or (EY>MapSizeY-1) then Continue;
            If TestUnitPos(UnitNum,HeadTmp,EX,EY)<>PlaceOk then Continue;
            EO:=EX*MapSizeY+EY;
            //NewCost:=Cost(EX,EY,GX,GY);
            If //(NewCost<AStarMatrix[EO].CostFromStart) and
               (AStarMatrix[EO].CostFromStart=MaxCost) then
              Begin
                NewCost:=Cost(EX,EY,GX,GY);
                AStarMatrix[EO].CostFromStart:=NewCost;
                AStarMatrix[EO].Direction:=HeadTmp;
                AStarAddNode(EX,EY,{$IfNDef NoIndex}EO,{$EndIf}NewCost);
                If NumInCloseSet<ThresholdCloseSet then
                  Begin
                    CloseSet[NumInCloseSet]:=EO;
                    Inc(NumInCloseSet);
                  End;
              End;
          End;
        If OpenSetSize<=FirstOpenSet then
          Begin
            EX:=BestX;
            EY:=BestY;
            Break;
          End;
      End;
    PathLength:=0;
    While (EX<>CX) or (EY<>CY) do
      Begin
        EO:=EX*MapSizeY+EY;
        HeadTmp:=AStarMatrix[EO].Direction;
        PathHead[PathLength]:=HeadTmp;
        Dec(EX,Direction[HeadTmp].X);
        Dec(EY,Direction[HeadTmp].Y);
        Inc(PathLength);
      End;
    Result:=PathLength<>0;
  End;
{$R-}
FUNCTION  TLOCWorld.SaveToStream(Stream : TStream;Compress : Boolean = True) : Boolean;
  Var BlockID : TBlockID;
  Procedure SaveMapNum(Compress : Boolean);
    Type ArrayMapNum = Array[0..0] of TMapNum;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapNum;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapNum;
      BlockID.Compress:=Compress;
      SizeIn:=MapSizeX*MapSizeY*SizeOf(TMapNum);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapSizeX-1 do
        For J:=0 to MapSizeY-1 do
          Tmp^[I+J*MapSizeX]:=MapNum[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Write(MapNum[I,J],SizeOf(TMapNum));}
        End;
      FreeMem(Tmp);
    End;
  Procedure SaveMapCount(Compress : Boolean);
    Type ArrayMapCount = Array[0..0] of Byte;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapCount;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      {$IfDef LimitAirUnitOnTile}
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapCount;
      BlockID.Compress:=Compress;
      SizeIn:=MapSizeX*MapSizeY*SizeOf(Byte);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapSizeX-1 do
        For J:=0 to MapSizeY-1 do
          Tmp^[I+J*MapSizeX]:=MapCount[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Write(MapCount[I,J],SizeOf(Byte));}
        End;
      FreeMem(Tmp);
      {$EndIf}
    End;
  Procedure SaveMapTile(Compress : Boolean);
    Type ArrayMapTile = Array[0..0] of TMapTileValue;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapTile;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapTile;
      BlockID.Compress:=Compress;
      SizeIn:=MapTileSizeX*MapTileSizeY*SizeOf(TMapTile);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapTileSizeX-1 do
        For J:=0 to MapTileSizeY-1 do
          Tmp^[I+J*MapTileSizeX]:=MapTile[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
          {For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              Stream.Write(MapTile[I,J],SizeOf(TMapTile));}
        End;
      FreeMem(Tmp);
    End;
  Procedure SaveMapTileFrame(Compress : Boolean);
    Type ArrayMapTileFrame = Array[0..0] of TMapTileFrame;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapTileFrame;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapTileFrame;
      BlockID.Compress:=Compress;
      SizeIn:=MapTileSizeX*MapTileSizeY*SizeOf(TMapTileFrame);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapTileSizeX-1 do
        For J:=0 to MapTileSizeY-1 do
          Tmp^[I+J*MapTileSizeX]:=MapTileFrame[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
          {For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              Stream.Write(MapTileFrame[I,J],SizeOf(TMapTileFrame));}
        End;
      FreeMem(Tmp);
    End;
  Procedure SaveMapTileHeight(Compress : Boolean);
    Type ArrayMapTileHeight = Array[0..0] of TMapTileHeight;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapTileHeight;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapTileHeight;
      BlockID.Compress:=Compress;
      SizeIn:=MapTileSizeX*MapTileSizeY*SizeOf(TMapTileHeight);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapTileSizeX-1 do
        For J:=0 to MapTileSizeY-1 do
          Tmp^[I+J*MapTileSizeX]:=MapTileHeight[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
          {For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              Stream.Write(MapTileHeight[I,J],SizeOf(TMapTileHeight));}
        End;
      FreeMem(Tmp);
    End;
  {Procedure SaveMapItem(Compress : Boolean);
    Type ArrayMapItem = Array[0..0] of TItemOnMap;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapItem;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapItem;
      BlockID.Compress:=Compress;
      SizeIn:=MapSizeX*MapSizeY*SizeOf(TItemOnMap);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapSizeX-1 do
        For J:=0 to MapSizeY-1 do
          Tmp^[I+J*MapSizeX]:=MapItem[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
        End;
      FreeMem(Tmp);
    End;}
  Procedure SaveMapAttr(Compress : Boolean);
    Type ArrayMapAttr = Array[0..0] of TMapAttr;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapAttr;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapAttr;
      BlockID.Compress:=Compress;
      SizeIn:=MapSizeX*MapSizeY*SizeOf(TMapAttr);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapSizeX-1 do
        For J:=0 to MapSizeY-1 do
          Tmp^[I+J*MapSizeX]:=MapAttr[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(Tmp);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Write(MapAttr[I,J],SizeOf(TMapAttr));}
        End;
    End;
  Procedure SaveMapUnderFog(Compress : Boolean);
    Type ArrayMapUnderFog = Array[0..0] of TUnitUnderFog;
    Var I,J            : FastInt;
        Tmp            : ^ArrayMapUnderFog;
        SizeIn,SizeOut : LongInt;
        BlockOut       : Pointer;
    Begin
      FillChar(BlockID,SizeOf(BlockID),0);
      BlockID.ID:=EntryMapUnderFog;
      BlockID.Compress:=Compress;
      SizeIn:=MapSizeX*MapSizeY*SizeOf(TUnitUnderFog);
      GetMem(Tmp,SizeIn);
      For I:=0 to MapSizeX-1 do
        For J:=0 to MapSizeY-1 do
          Tmp^[I+J*MapSizeX]:=MapUnitUnderFog[I,J];
      If Compress then
        Begin
          ZCompress(Tmp,SizeIn,BlockOut,SizeOut);
          BlockID.Size:=SizeOut;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockOut);
        End
      Else
        Begin
          BlockID.Size:=SizeIn;
          Stream.Write(BlockID,SizeOf(BlockID));
          Stream.Write(Tmp^,SizeIn);
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Write(MapUnitUnderFog[I,J],SizeOf(TUnitUnderFog));}
        End;
      FreeMem(Tmp);
    End;
  Begin
    //Save world
    FillChar(BlockID,SizeOf(BlockID),0);
    BlockID.ID:=EntryGameWorldInfo;
    BlockID.Compress:=Compress;
    Stream.Write(BlockID,SizeOf(BlockID));
    Stream.Write(MapSizeX,SizeOf(MapSizeX));
    Stream.Write(MapSizeY,SizeOf(MapSizeY));
    Stream.Write(MapViewX,SizeOf(MapViewX));
    Stream.Write(MapViewY,SizeOf(MapViewY));
    {$IfDef SavedMapNum}
    SaveMapNum(Compress);
    SaveMapCount(Compress);
    {$EndIf}
    //SaveMapItem(Compress);
    SaveMapTile(Compress);
    SaveMapTileFrame(Compress);
    SaveMapTileHeight(Compress);
    SaveMapUnderFog(Compress);
    SaveMapAttr(Compress);
    //Write entry end of block saving
    FillChar(BlockID,SizeOf(BlockID),0);
    BlockID.ID:=EntryEndBlock;
    Stream.Write(BlockID,SizeOf(BlockID));
    Result:=True;
  End;

FUNCTION  TLOCWorld.LoadFromStream(Stream : TStream) : Boolean;
  Var BlockID : TBlockID;
  Procedure LoadMapNum;
    Type ArrayMapNum = Array[0..0] of TMapNum;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapNum;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapNum[I,J]:=Tmp^[I+J*MapSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapNum[I,J]:=Tmp^[I+J*MapSizeX];
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Read(MapNum[I,J],SizeOf(TMapNum));}
        End;
      FreeMem(BlockOut);
    End;
  Procedure LoadMapCount;
    Type ArrayMapCount = Array[0..0] of Byte;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapCount;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      {$IfDef LimitAirUnitOnTile}
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapCount[I,J]:=Tmp^[I+J*MapSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapCount[I,J]:=Tmp^[I+J*MapSizeX];
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Read(MapCount[I,J],SizeOf(Byte));}
        End;
      FreeMem(BlockOut);
      {$EndIf}
    End;
  Procedure LoadMapTile;
    Type ArrayMapTile = Array[0..0] of TMapTileValue;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapTile;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              MapTile[I,J]:=Tmp^[I+J*MapTileSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              MapTile[I,J]:=Tmp^[I+J*MapTileSizeX];
          {For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              Stream.Read(MapTile[I,J],SizeOf(TMapTile));}
        End;
      FreeMem(BlockOut);
    End;
  Procedure LoadMapTileFrame;
    Type ArrayMapTileFrame = Array[0..0] of TMapTileFrame;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapTileFrame;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              MapTileFrame[I,J]:=Tmp^[I+J*MapTileSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              MapTileFrame[I,J]:=Tmp^[I+J*MapTileSizeX];
          {For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              Stream.Read(MapTileFrame[I,J],SizeOf(TMapTileFrame));}
        End;
      FreeMem(BlockOut);
    End;
  Procedure LoadMapTileHeight;
    Type ArrayMapTileHeight = Array[0..0] of TMapTileHeight;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapTileHeight;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              MapTileHeight[I,J]:=Tmp^[I+J*MapTileSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              MapTileHeight[I,J]:=Tmp^[I+J*MapTileSizeX];
          {For I:=0 to MapTileSizeX-1 do
            For J:=0 to MapTileSizeY-1 do
              Stream.Read(MapTileHeight[I,J],SizeOf(TMapTileHeight));}
        End;
      FreeMem(BlockOut);
    End;
  {Procedure LoadMapItem;
    Type ArrayMapItem = Array[0..0] of TItemOnMap;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapItem;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapItem[I,J]:=Tmp^[I+J*MapSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapItem[I,J]:=Tmp^[I+J*MapSizeX];
        End;
      FreeMem(BlockOut);
    End;}
  Procedure LoadMapAttr;
    Type ArrayMapAttr = Array[0..0] of TMapAttr;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapAttr;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapAttr[I,J]:=Tmp^[I+J*MapSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapAttr[I,J]:=Tmp^[I+J*MapSizeX];
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Read(MapAttr[I,J],SizeOf(TMapAttr));}
        End;
      FreeMem(BlockOut);
    End;
  Procedure LoadMapUnderFog;
    Type ArrayMapUnderFog = Array[0..0] of TUnitUnderFog;
    Var I,J      : FastInt;
        Tmp      : ^ArrayMapUnderFog;
        SizeOut  : LongInt;
        BlockOut : Pointer;
    Begin
      GetMem(BlockOut,BlockID.Size);
      Stream.Read(BlockOut^,BlockID.Size);
      If BlockID.Compress then
        Begin
          ZDeCompress(BlockOut,BlockID.Size,Pointer(Tmp),SizeOut);
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapUnitUnderFog[I,J]:=Tmp^[I+J*MapSizeX];
          FreeMem(Tmp);
        End
      Else
        Begin
          Tmp:=BlockOut;
          For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              MapUnitUnderFog[I,J]:=Tmp^[I+J*MapSizeX];
          {For I:=0 to MapSizeX-1 do
            For J:=0 to MapSizeY-1 do
              Stream.Read(MapUnitUnderFog[I,J],SizeOf(TUnitUnderFog));}
        End;
      FreeMem(BlockOut);
    End;
  Begin
    //Load world
    Result:=False;
    FreeMap;
    Stream.Read(BlockID,SizeOf(BlockID));
    If BlockID.ID<>EntryGameWorldInfo then Exit;
    Stream.Read(MapSizeX,SizeOf(MapSizeX));
    Stream.Read(MapSizeY,SizeOf(MapSizeY));
    Stream.Read(MapViewX,SizeOf(MapViewX));
    Stream.Read(MapViewY,SizeOf(MapViewY));
    SetupMapSize(MapSizeX,MapSizeY);
    While True do
      Begin
        Stream.Read(BlockID,SizeOf(BlockID));
        Case BlockID.ID of
          EntryMapNum        : LoadMapNum;
          EntryMapCount      : LoadMapCount;
          EntryMapTile       : LoadMapTile;
          EntryMapTileFrame  : LoadMapTileFrame;
          EntryMapTileHeight : LoadMapTileHeight;
          EntryMapAttr       : LoadMapAttr;
          EntryMapUnderFog   : LoadMapUnderFog;
          //EntryMapItem       : LoadMapItem;
          EntryEndBlock      : Break;
        End;
      End;
    Result:=True;
  End;
{$R+}  
END.
