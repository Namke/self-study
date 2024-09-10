UNIT LOCUnits;
{$Include GlobalDefines.Inc}
INTERFACE

USES Classes,
     SysUtils,
     AvenusBase,
     AvenusCommon,
     Avenus3D,
     PNGZLib,
     LOCBased,
     LOCSCreen,
     LOCShow;

TYPE
//Item property
  TItemProperty = Record
    //Name of item
    ItemName         : NameString;
    ItemAttribute    : TItemAttribute;
    UnitLevelRequire : TLevel;
    Case ItemClass : TItemClass of
      WeaponClass : (
        //Damage add for unit used weapon
        DamageAddOn       : TDamage;
        //Target weapon can be attack
        //If item has a attribute, then item is a weapon, unit can used item to fighting
        WeaponCanTarget   : TWeaponCanTarget;
        //Weapon using missile
        WeaponMissile     : TMissile;
        //Default attack range
        MinRange,MaxRange : TRange;
      );
      MagicClass : (
      );
      ScrollClass : (
      );
      GenerationScrollClass : (
        //Unit item can generation
        ItemGeneration    : TUnit;
      );
      BookClass : (
      );
      OtherClass : (
      );
  End;

TYPE
//Missile property
  TMissileProperty = Record
    //Missile speed
    MissileSpeed     : SmallInt;
    //  Missile attribute, like missile can hit unit when play ? Or missile
    //can hit allies target ? Or something else
    MissileAttribute : TMissileAttribute;
    {$IfDef MissileEffectItSelf}
    //Effect when draw missile ?
    MissileEffect    : Integer;
    AlphaChannel     : LongWord;
    {$EndIf}
    //Draw level of missile
    DrawLevel        : TDrawLevel;
  End;
//Missile type
  TMissileType = Record
    Typer              : TMissile;
    //Position and destination of missile, may be wrong when map size large than 1024x1024
    //because pos and dest multiply real unit position with 32, may be exceed smallint bound
    MisPos,MisDest     : TPoint;
    Step,DX,DY,DXS,DYS : SmallInt;
    MisState           : TMissileState;
    WaitTime           : TFrameWait;
    //Missile damage, this value must saved because source unit can be destroyed when missile still run !
    MisDamage          : TDamage;
    //
    MisClan            : TClan;
    //Heading of missile
    Head               : THeading;
    //Missile frame
    Frame              : TNumFrame;
    //Missile waiting time
    //Wait               : TUnitWait;
    //Target unit
    FromUnit,Target     : TUnitCount;
  End;

TYPE
  TEffectProperty = Record
    EffectKind : TEffectKind;
    DrawLevel  : TDrawLevel;
  End;
  
TYPE
  TUnitProperty = Record
    //Unit available on config file ?
    UnitAvail                     : Boolean;
    //Default unit name
    Name                          : NameString;
    //Default unit hitpoint
    HitPoint                      : THitPoint;
    //Hitpoint grow per game time
    HitPointGrow                  : THitPoint;
    //Default unit see range
    SeeRange                      : TRange;
    //Default unit weapon
    BaseDamage                    : TDamage;
    //Unit item
    BaseItem                      : TUnitItems;
    ItemSlotAvail                 : TItemSlotAvail;
    //Default unit skill
    Skill                         : TUnitSkills;
    //Default unit money
    UnitResource                  : TUnitResources;
    //Point for create unit, 125% point for destroy unit
    Point                         : FastInt;
    //Default unit mana and mana grow per mana rate
    MaxMana,ManaGrow              : FastInt;
    //Default unit size (on map)
    UnitSizeX,UnitSizeY           : Byte;
    UnitMapped                    : Array[THeading,0..MaxUnitSizeX,0..MaxUnitSizeY] of TUnitMapped;
    //Default unit food used and food gain if had unit
    FoodUsed,FoodGain             : Byte;
    //Unit transfer before death
    UnitTransfer                  : TUnit;
    //Unit draw level
    UnitDrawLevel                 : TDrawLevel;
    //Unit attribute
    BaseAttribute                 : TBaseAttribute;
    //List of units current unit can build
    UnitCanGeneration             : Array[TSkillCount] of TUnit;
    //List of spell unit can casting !
    SpellCanCast                  : Array[TSkillCount] of TSpell;
    //List of item unit allowed
    //Why don't used set of TItem ? Because I don't sure total of Items not grow up large than set !
    //Is the furture, when game complete ?
    ItemCanAllow                  : Array[TItem] of Boolean;
    //Hotkey for unit
    HotKey                        : Byte;
    //Cost for unit
    UnitCost                      : TResources;
    //Time cost for training/building unit
    UnitTimeCost                  : FastInt;
    //
    UnitForce                     : TForce;
    //
    RightCommandNoTarget,
    RightCommandTargetAlly,
    RightCommandTargetEnemy : TSkill;
  End;

TYPE
  TSkillProperty = Record
    SkillHotkey  : SmallInt;
    //Cost for using skill
    ResourceCost : Array[TResource] of FastInt;
    ToolTip      : TipString;
    ManaCost     : FastInt;
  End;
  TSpellProperty = Record
    SpellHotkey       : SmallInt;
    //Cost for using spell
    ResourceCost      : Array[TResource] of FastInt;
    ToolTip           : TipString;
    ManaCost          : FastInt;
    SpellAttribute    : TSpellAttribute;
    MaxRange,MinRange : TRange;
    NeedTarget        : Boolean;
  End;

TYPE
  TUnitData = Record
    //Own unit name ?
    _UnitName                            : NameString;
    _UnitTyper                           : TUnit;
    _UnitClan,_UnitColor                 : TClan;
    _UnitHitPoint                        : THitPoint;
    _UnitSeeRange                        : TRange;
    _UnitHeading                         : THeading;
    _UnitLevel                           : TLevel;
    //Unit frame (for counting and drawing)
    _UnitFrame                           : TUnitFrame;
    //Unit waiting step (for unit sleep, is speed of unit)
    //Also using for time counting unit building
    _UnitWait                            : TUnitWait;
    //
    _UnitPrev,_UnitNext                  : TUnitCount;
    //Unit pos and dest command
    _UnitPos,_UnitDest                   : TPoint;
    //Unit skill, I must define UnitSkill because I prepare UnitSkill can change when game play
    //but unit can cast spell that not change ?
    _UnitSkill                           : TUnitSkills;
    //Damage of unit
    _UnitDamage                          : TDamage;
    //Unit attribute
    _UnitAttribute                       : TUnitAttribute;
    //Unit point to effect with unit self
    _UnitEffected                        : TEffectedCount;
    //Group of unit
    _UnitGroup                           : Byte;
    //Unit command and next command
    _UnitCmd,_UnitNextCmd,_UnitPrevCmd   : TSkill;
    //Data for unit castspell, Spell and NextSpell for next spell of queue
    //When unit cast spell, if spell has specific target, that UnitTarget, or if unit
    //cast spell to area (like blizzard) then target has store in PatrolDest - He he, must becareful !
    _UnitSpell,_UnitNextSpell            : TSpell;
    //Unit target for attack, follow, etc
    _UnitTarget,_UnitNextTarget          : TUnitCount;
    //Unit mana
    _UnitMana                            : FastInt;
    {$IfDef RandomUnitPosShift}
    _ShiftPX,_ShiftPY                    : ShortInt;
    {$EndIf}
    //Unit have item ?
    _UnitItems                           : TUnitItems;
    //If unit have training queue, used one, else used two for saving number unit carrier
    //If unit in building command, last of queue used to save typer of unit to build
    _UnitQueue                           : TUnitQueue;
    _PathUsed,_PathSave                  : Byte;
    _PathLine                            : Array[1..MaxUnitSavedPath] of THeading;
    _WastedTimeCount                     : Byte;
    _UnitXP                              : SmallInt;
    //Unit have money
    _UnitResource                        : Record
      Case Byte of
        1 : (
          _NormalRes : TUnitResources;
        );
        2 : (
          _GoldAmound : LongInt;
        );
    End;
    //For reduce size of unit data
    Case Byte of
      //Data used when unit has a patrol command
      1 : (
        //Start and _UnitDest of patrol command
        _PatrolStart,_PatrolDest : TPoint;
      );
      //Data used when unit has a mining command
      2 : (
        //Target for return gold !
        _MineTarget,_ReturnGoldTarget : TUnitCount;
      );
      //Data used when unit has a put item command
      3 : (
        //Target to put item if _UnitTarget is zero
        _ItemSlot : TItemCount;
        _ItemPos  : TPoint;
      );
      4 : (
        //Used for saving prev frame of unit when unit die
        _UnitPrevFrame : TUnitFrame;
      );
  End;

TYPE
  TClanInfo = Record
    ClanName                              : NameString;
    Resource                              : TResources;
    Control                               : TControl;
    ClanRace                              : TRace;
    Diplomacy                             : Array[TClan] of TClanDiplomacy;
    SharedControl                         : Array[TClan] of TSharedControl;
    SharedVision                          : Array[TClan] of TSharedVision;
    AllUnits,FoodUsed,FoodLimit,
    FoodAvail,FoodAvailInFuture           : Integer;
    //  Counting of unit and unit in queue
    //  Unit in queue used when computer wait for build unit, this variable increase when
    //start unit to StartBuild and decrease when unit training complete or build complete
    UnitsCounting,UnitInQueue             : Array[TUnit] of Integer;
    //For unit clicking
    UnitClick                             : TUnitCount;
    ClickCount                            : FastInt;
  End;

TYPE
  PLOCUnits = ^TLOCUnits;
  TLOCUnits = Class
    Public
    MyScreen           : TLOCScreen;
    MyShow             : TLOCShow;
    //Weapon and unit property
    ItemProperty       : Array[TItem] of TItemProperty;
    UnitsProperty      : Array[TClan,TUnit] of TUnitProperty;
    UnitAvailable      : Array[TClan,TUnit] of Boolean;
    SkillProperty      : Array[TSkill] of TSkillProperty;
    SkillAvailable     : Array[TClan,TSkill] of Boolean;
    SpellProperty      : Array[TSpell] of TSpellProperty;
    SpellAvailable     : Array[TClan,TSpell] of Boolean;
    MissileProperty    : Array[TMissile] of TMissileProperty;
    EffectProperty     : Array[TEffected] of TEffectProperty;
    //Counting number of unit for clan
    TotalUnit          : TUnitCount;
    //Units data
    Units              : Array[1..MaxUnits] of TUnitData;
    //TotalMissile : fast check for free missile
    TotalMissile       : TMissileCount;
    //Missile data
    Missiles           : Array[1..MaxMissiles] of TMissileType;
    //Total of effect in used
    TotalEffect        : TMissileCount;
    //Effect data
    Effects            : Array[1..MaxEffects] of TUnitEffected;
    //0 to 9 is group saving can be save & load by keyboard, group 10 is current group
    //For group, program must be always reduce queue to check first cell for group
    //has element or not
    SaveGroups             : Array[1..MaxGroup] of TGroup;
    OldUnitFocus,UnitFocus : TUnitCount;
    CurrentGroup           : Byte;
    //Current skill button for choisen
    CurrentSkillButton : TUnitSkills;
    //Queue must extract here because queue maybe hiden when select group of unit, huh ?
    CurrentSavedQueue  : TSavedUnitQueue;
    //Control for clans
    ClanInfo           : Array[TClan] of TClanInfo;
    //Human control data
    HumanControl       : TClan;
    CurHumanWorkerUnit,
    CurHumanTroopUnit,
    CurHumanBuildingUnit : TUnitCount;
    //AI data place here for some changing of AI data
    AIData             : Array[TClan] of TAIData;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow);
    Destructor Destroy;OverRide;
    Procedure RestartGame;
    Procedure RestartGrouping;
    //Load unit default setting
    Procedure LoadDefaultSetting;
    //Load data default setting
    Procedure DataDefault;
    //Setting all clans diplomacy to enemy
    Procedure SettingClanDefault;
    //Setting for clan
    Procedure SetupClan(Clan : TClan;Name : String;Control : TControl;
                        Race : TRace;Resource : Array of LongInt);
    //Setting clans diplomacy
    Procedure SetupClanDiplomacy(Clan1,Clan2 : TClan;Status : TClanDiplomacy);
    //Setting all clans diplomacy
    Procedure AllClanDiplomacy(Status : TClanDiplomacy);
    //Get force by name
    Function  GetForceByName(Name : String) : TForce;
    //Get unit type by name from DefaultUnitName
    Function  GetUnitTyperByName(Name : String) : TUnit;
    //Get spell type by name from DefaultSpellName
    Function  GetSpellByName(Name : String) : TSpell;
    //Get effect type by name from DefaultSpellName
    Function  GetEffectByName(Name : String) : TEffected;
    //Get clan type by name from DefaultClanName
    Function  GetClanByName(Name : String) : TClan;
    //Get skill type by name from DefaultSkillName
    Function  GetSkillByName(Name : String) : TSkill;
    //Get attribute type by name from DefaultSkillName
    Function  GetAttributeByName(Name : String) : TBaseUnitAttribute;
    //Get item type by name from DefaultItemName
    Function  GetItemByName(Name : String) : TItem;
    //Get missile type by name from DefaultMissileName
    Function  GetMissileByName(Name : String) : TMissile;
    //Get weapon can target type from DefaultWeaponCanTargetName
    Function  GetWeaponTargetByName(Name : String) : TWeaponCanTarget;
    //Get heading by name from DefaultItemName
    Function  GetHeadingByName(Name : String) : THeading;
    //
    Function  GetRandomHeading : THeading;
    //Loading map ability, what needed ? :}
    Procedure LoadMapAbility;
    //Restart all unit to starting
    //Also restart all AI data
    Procedure SetAllUnitsToStart;
    //Load unit setting from file
    Procedure LoadUnitSetting(FileName : String);
    //Load item setting from file
    Procedure LoadItemSetting(FileName : String);
    //Setting for weapon item
    Procedure SetupWeaponItemProperty(Item : TItem;ItemName : NameString;
                                      DamageAddOn : TDamage;
                                      WeaponCanTarget : TWeaponCanTarget;
                                      WeaponMissile : TMissile;
                                      MinAttackRange,MaxAttackRange : TRange);
    Procedure SetupArmorItemProperty(Item : TItem;ItemName : NameString);
    Procedure SetupShieldItemProperty(Item : TItem;ItemName : NameString);
    Procedure SetupHelmItemProperty(Item : TItem;ItemName : NameString);
    Procedure SetupBootItemProperty(Item : TItem;ItemName : NameString);
    Procedure SetupDecorateItemProperty(Item : TItem;ItemName : NameString);
    //Setting item weapon property
    Procedure SetWeaponProperty(Item : TItem;CWeaponCanTarget : TWeaponCanTarget;_On : Boolean);
    //Testing item weapon property
    Function  TestWeaponProperty(Item : TItem;CWeaponCanTarget : TWeaponCanTarget) : Boolean;
    Procedure IncreaseFoodLimit(Clan : TClan;Used,Gain,RealGain : FastInt);
    Procedure DecreaseFoodLimit(Clan : TClan;Used,Gain,RealGain : FastInt);
    //Get unused unit in units queue
    Function  GetUnusedUnit : TUnitCount;
    //
    Function  CrossAt(X,Y : FastInt) : Boolean;
    //
    Procedure ClickAtUnit(Clan : TClan;UnitNum : TUnitCount);
    //New unit: increase unit limit, unit food gain..
    Procedure NewUnit(Clan : TClan;Typer : TUnit;CountFood,CountMoney : Boolean);
    //Dispose unit: reduce unit limit, unit food gain..
    Procedure DisposeUnit(Clan : TClan;Typer : TUnit;CountFood : Boolean);
    //Get back money
    Procedure GetBackMoney(UnitNum : TUnitCount);
    //Only get default skill and default spell skill, not load build skill, this function of button setup
    Procedure GetDefaultUnitSkill(UnitNum : TUnitCount);
    //Set unit to default unit setting
    Procedure ResetDefaultUnitData(UnitNum : TUnitCount);
    //Set unit to default with some start information
    // UnitOnMap on
    // UnitSelfControl on
    //Remember: Set unit data to default, not take unit on map, you must call
    //PutUnit to put unit on map !
    Procedure SetUnitToDefault(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;
                               PosX,PosY : SmallInt;CountMoney : Boolean = True); OverLoad;
    Procedure SetUnitToDefault(Name : NameString;UnitNum : TUnitCount;
                               Clan : TClan;Typer : TUnit;PosX,PosY : SmallInt;CountMoney : Boolean = True); OverLoad;
    //New unit with fixed heading
    Procedure SetUnitToDefault(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;
                               Head : THeading;PosX,PosY : SmallInt;CountMoney : Boolean = True); OverLoad;
    Procedure SetUnitToDefault(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;
                               PosX,PosY,SX,SY : SmallInt;CountMoney : Boolean = True); OverLoad;
    //Set unit to start build state with some start information
    //Also set unit attribute UnitSelfControl off to don't get any command before unit really active
    // UnitOnMap off
    // UnitSelfControl off
    //Remember: Set unit data to default start, not take unit on map, you must call
    //PutUnit to put unit on map !
    Procedure SetUnitToStart(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;
                             PosX,PosY : SmallInt;FoodGain : Boolean); OverLoad;
    Procedure SetUnitToStart(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;Head : THeading;
                             PosX,PosY : SmallInt;FoodGain : Boolean); OverLoad;
    //Set unit to unused unit
    Procedure SetUnitToUnused(UnitNum : TUnitCount);
    //Bring unit to death, remember get all cell unit have
    Procedure BringUnitToDeath(UnitNum : TUnitCount);
    //Check for can get new unit of typer for clan ?
    // 0  - ok
    // -1 - Not enough food
    // -2 - Exceed food limit
    // -3 - Not enough resource
    Function  CheckCreateMoreUnit(Clan : TClan;Typer : TUnit) : FastInt;
    //
    Function  CheckUseSpell(UnitNum : TUnitCount;Spell : TSpell) : FastInt;
    Procedure UnitCostForSpell(UnitNum : TUnitCount;Spell : TSpell);
    //Save group MaxGroup to group 0-9
    Procedure SaveGroup(GroupNum : Byte);
    //Load group MaxGroup from group 0-9
    Procedure LoadGroup(GroupNum : Byte);
    //Unselect all unit in group
    Procedure UnSelectGroup(GroupNum : Byte);
    //Selected all unit in group
    Procedure SetSelectGroup(GroupNum : Byte);
    //Get global skill of group
    Function  CountOfSkill(SkillButton : TUnitSkills) : FastInt;
    Function  AddSkillTo(Var SkillButton : TUnitSkills;Skill : TSkill;
                         _UnitToBorn : TUnit;_SpellToCast : TSpell) : Boolean;
    //Get group skill, store to SkillButton
    //If group skill none, next get group build skill
    //if group only one unit and is building, next get group build skill (add more)
    Procedure GetGroupSkill(Var SkillButton : TUnitSkills;GroupNum : Byte;MyClan : TClan;UpdatedButton : Boolean);
    //Get group build skill (Add or not)
    Procedure GetGroupBuildSkill(Var SkillButton : TUnitSkills;GroupNum : Byte;MyClan : TClan;Add,UpdatedButton : Boolean);
    Procedure GetGroupSpellSkill(Var SkillButton : TUnitSkills;GroupNum : Byte;MyClan : TClan;Add,UpdatedButton : Boolean);
    Procedure SetGroupSkillTo(Var SkillButton : TUnitSkills;Skill : TSkill;UnitToBorn : TUnit);
    //Add more skill button
    Function  AddButtonSkillTo(Var SkillButton : TUnitSkills;Skill : TSkill;UnitToBorn : TUnit;UpdateButton : Boolean) : Boolean;
    //Get unit queue from unitnum store to CurrentUnitQueue
    Procedure GetUnitQueue(UnitNum : TUnitCount);
    //Setup skill button
    Procedure SetupSkillButtons(SkillButton : TUnitSkills);
    //Setup unit items
    Procedure SetupUnitItemButtons(UnitNum : TUnitCount);
    //Seyup unit selected button
    Procedure SetupUnitSelectedButtons(Group : TGroup);
    //Setup unit queue button, must get current save queue first
    Procedure SetupUnitQueueButtons(_UnitQueue : TUnitQueue;Mini : Boolean);
    //Setup for group under selected:
    //  Setup skill button
    //  Setup item button
    //  Setup selected button
    //  If select only one unit >> Get current queue, setup for queue button
    //  Else clear current queue, setup queue button
    //Before calling this function, remember to call get group skill first !
    Procedure SetupGroupSelected(GroupNum : Byte);
    //Checking for unit in group ?
    Function  UnitInGroup(UnitNum : TUnitCount;Group : TGroup) : Boolean;
    //Get number unit in group
    Function  NumberUnitInGroup(Group : TGroup) : Byte;
    //Find unit on Clan in Group
    Function  FindUnitOnClan(Group : TGroup;Clan : TClan) : Boolean;
    //Add unit to group, don't check or sign unit is selected
    Function  AddUnitToGroup(UnitNum : TUnitCount;Var Group : TGroup) : Boolean;
    //Select onlyone unit
    Procedure SelectUnitNum(UnitNum : TUnitCount);
    Procedure UnSelectUnitNum(UnitNum : TUnitCount);
    Procedure SelectOnlyUnit(UnitNum : TUnitCount);
    //Clear unit selection in group
    Procedure ClearUnitInGroup(UnitNum : TUnitCount;GroupNum : Byte); OverLoad;
    Procedure ClearUnitInGroup(UnitNum : TUnitCount;Var Group : TGroup); OverLoad;
    //Clear unit selection in all group saving
    Procedure ClearUnitInAllGroup(UnitNum : TUnitCount;Update : Boolean = True);
    //Arrange all unit in group
    Procedure ArrangeGroup(GroupNum : Byte); OverLoad;
    Procedure ArrangeGroup(Var Group : TGroup); OverLoad;
    Procedure ArrangeUnitQueue(UnitNum : TUnitCount);
    //Test for can add unitnum to group (same clan, same type...)
    Function  UnitCanAddToGroup(UnitNum : TUnitCount;Clan : TClan;Group : TGroup;CheckGroup : Boolean = True) : Boolean;
    //Send current group to death (delete group selection)
    Procedure SendCurrentGroupToDeath;
    //Unit stand over [X,Y]
    Function  UnitStandOver(UnitNum : TUnitCount;X,Y : FastInt) : Boolean;
    //Unit is building ?
    Function  CheckUnitIsBuilding(UnitClan : TClan;UnitTyper : TUnit) : Boolean; OverLoad;
    Function  CheckUnitIsBuilding(UnitNum : TUnitCount) : Boolean; OverLoad;
    Function  CheckBaseAttribute(UnitNum : TUnitCount;Base : TBaseUnitAttribute) : Boolean;
    //Checking for spell attribute
    Function  CheckSpellAttribute(Spell : TSpell;Attribute : TSpellAttribute) : Boolean;
    //Checking for missile attribute
    Function  CheckMissileAttribute(Missile : TMissile;Attribute : TMissileAttribute) : Boolean;
    //Checking skill of unit
    Function  CheckUnitSkill(UnitNum : TUnitCount;SkillTest : TSkill) : Boolean;
    //Checking spell of unit
    Function  CheckUnitHasSpell(UnitNum : TUnitCount;SpellTest : TSpell) : Boolean;
    //Check unit can build
    Function  CheckUnitCanGen(UnitNum : TUnitCount;UnitToBorn : TUnit) : Boolean;
    //Get unit can build in group and unit must not have a build command before
    Function  GetUnitHaveSkill(Group : TGroup;Clan : TClan;Skill : TSkill) : TUnitCount;
    //Get unit can build in group and unit must not have a build command before
    Function  GetUnitCanBuild(Group : TGroup;Clan : TClan;Typer : TUnit) : TUnitCount;
    //Get unit has training unit in queue
    Function  GetUnitHasTraining(Group : TGroup;Clan : TClan) : TUnitCount;
    //Checking for clan can be command this unit
    Function  CheckClanControlUnit(UnitNum : TUnitCount;FromClan : TClan) : Boolean;
    //
    Function  CheckClanCanBuild(Clan : TClan;UnitTyper : TUnit) : Boolean;
    //Finding free unit under human control
    Function  FindingFreeWorker : TUnitCount;
    Function  FindingFreeTroop : TUnitCount;
    Function  FindingFreeBuilding : TUnitCount;
    //Set command to group
    //Set group command to position, like attack, move or patrol
    Procedure SetGroupCommand(Group : TGroup;Cmd : TSkill;X,Y : FastInt;FromClan : TClan); Overload;
    //Set group command to target, like attack or follow...
    Procedure SetGroupCommand(Group : TGroup;Cmd : TSkill;Target : TUnitCount;FromClan : TClan); Overload;
    //Set group command training
    Procedure SetGroupCommand(Group : TGroup;UnitToBorn : TUnit;FromClan : TClan); Overload;
    //Set command to group cast spell
    //Castspell to specific target
    Procedure SetGroupCommand(Group : TGroup;Spell : TSpell;Target : TUnitCount;FromClan : TClan); Overload;
    //Castspell to specific area
    Procedure SetGroupCommand(Group : TGroup;Spell : TSpell;X,Y : FastInt;FromClan : TClan); Overload;
    //Direct castspell
    Procedure SetGroupCommand(Group : TGroup;Spell : TSpell;FromClan : TClan); Overload;
    //Set command to unit
    Procedure SetUnitCommand(UnitNum : TUnitCount;Cmd : TSkill;X,Y : FastInt;FromClan : TClan); Overload;
    Procedure SetUnitCommand(UnitNum : TUnitCount;Cmd : TSkill;Target : TUnitCount;FromClan : TClan); Overload;
    //Toggle on or off attribute UnitAtt of UnitNum
    Procedure SetUnitAttribute(UnitNum : TUnitCount;UnitAtt : TUnitAttribute;_On : Boolean);
    //Test attribute of UnitNum
    Function  GetUnitAttribute(UnitNum : TUnitCount;UnitAtt : TUnitAttribute): Boolean;
    //Clear unit queue
    Procedure UnitClearQueue(UnitNum : TUnitCount);
    //Counting unit queue
    Function  CountUnitQueue(UnitNum : TUnitCount) : TUnitCount;
    //Unit is deposit target ?
    Function  UnitTestBaseAttribute(UnitNum : TUnitCount;Attr : TBaseUnitAttribute) : Boolean;
    //Unit have a resource ?
    Function  UnitHaveAResource(UnitNum : TUnitCount) : Boolean;
    //Check unitnum can attack unitdest ? I only check type of unit _UnitDest and type
    //of target unitnum can be attacked, don't check range between them
    Function  UnitCanAttack(UnitNum,UnitDest : TUnitCount) : TUnitSetCmdReturn;
    //Calculate distance between two unit
    Function  RangeBetweenUnit(UnitNum,UnitDest : TUnitCount) : TRange; OverLoad;
    Function  RangeBetweenUnit(UnitNum,DestX,DestY : TUnitCount) : TRange; OverLoad;
    //Test for unit castspell range
    Function  TestUnitCastSpellRange(UnitNum,UnitDest : TUnitCount;Spell : TSpell) : TUnitSetCmdReturn; OverLoad;
    Function  TestUnitCastSpellRange(UnitNum : TUnitCount;DestX,DestY : FastInt;Spell : TSpell) : TUnitSetCmdReturn; OverLoad;
    //Test for unit attack range
    Function  TestUnitAttackRange(UnitNum,UnitDest : TUnitCount) : TUnitSetCmdReturn; OverLoad;
    Function  TestUnitAttackRange(UnitNum,DestX,DestY : TUnitCount) : TUnitSetCmdReturn; OverLoad;
    //
    Function  UnitFindReturnGoldTarget(UnitNum : TUnitCount) : Boolean;
    //
    Procedure SetUnitReturnGold(UnitNum : TUnitCount);
    //
    Procedure SetUnitHarvest(UnitNum : TUnitCount);
    //Get heading view from [X1,Y1] to [X2,Y2]
    Function  GetHeading(X1,Y1,X2,Y2 : FastInt) : THeading;
    //Unit hit unit's target
    Procedure UnitHit(UnitNum : TUnitCount);
    //Total item unit have
    Function  UnitCountItem(UnitNum : TUnitCount) : FastInt;
    //
    Function  SlotSupportItem(UnitNum : TUnitCount;Slot : TItemCount;Item : TItem) : Boolean;
    //
    Procedure UnitClearSlot(UnitNum : TUnitCount;Slot : TItemCount);
    //
    Function  UnitAddSlot(UnitNum : TUnitCount;Slot : TItemCount;Item : TUnitItem) : Boolean;
    //Switch current item of unit
    Function  UnitSwitchItem(UnitNum : TUnitCount;Slot1,Slot2 : TItemCount) : Boolean; OverLoad;
    Function  UnitSwitchItem(UnitNum : TUnitCount;Slot : TItemCount;Var Item : TUnitItem) : Boolean; OverLoad;
    //Give for unit item
    Function  GiveUnitItem(UnitNum : TUnitCount;Slot : TItemCount;Item : TUnitItem) : Boolean; 
    //Get unit free slot
    Function  GetUnitFreeItemSlot(UnitNum : TUnitCount;Var Slot : TItemCount) : Boolean;
    Function  GetUnitFitItemSlot(UnitNum : TUnitCount;Item : TUnitItem;Var Slot : TItemCount) : Boolean;
    //Get unit used slot
    Function  GetUnitUsedItemSlot(UnitNum : TUnitCount;Var Slot : TItemCount) : Boolean;
    //Exchange item slot from unit num to unit target ! Result true if exchange successful !
    Function  UnitExchangeItem(UnitNum,UnitTarget : TUnitCount;Slot : TItemCount) : Boolean;
    //Decrease unit hitpoint
    Procedure DecUnitHitPoint(UnitNum : TUnitCount;Damage : TDamage);
    //Real unit see range
    Function  RealUnitSeeRange(UnitNum : TUnitCount) : TRange;
    //Real unit attack range
    Function  RealUnitAttackMinRange(UnitNum : TUnitCount) : TRange;
    Function  RealUnitAttackMaxRange(UnitNum : TUnitCount) : TRange;
    //Real unit attack damage
    Function  RealUnitAttackDamage(UnitNum : TUnitCount) : TDamage;
    //Get real unit movement speed
    Function  RealUnitMovementSpeed(UnitNum : TUnitCount) : FastInt;
    //Get real unit attacking speed - this differ from unit movement speed
    Function  RealUnitAttackingSpeed(UnitNum : TUnitCount) : FastInt;
    //Check for unit close on unit target
    Function  UnitCheckTargetClose(UnitNum : TUnitCount) : Boolean;
    //Reset unit command to no command
    Procedure UnitResetCommand(UnitNum : TUnitCount);
    //All the set command method
    //Must check for who are send this command for safe status
    //Set unit command to command move
    Procedure UnitCommandMove(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan);
    //Set unit command to command follow unit
    Procedure UnitCommandFollow(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
    //Set unit command to command patrol
    Procedure UnitCommandPatrol(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan);
    //Set unit command to command stop
    Procedure UnitCommandStop(UnitNum : TUnitCount;FromClan : TClan);
    //Set unit command to command hold position
    Procedure UnitCommandHoldPosition(UnitNum : TUnitCount;FromClan : TClan);
    //Set unit command to command attack unit
    Procedure UnitCommandAttack(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
    Procedure UnitCommandAttackingStand(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
    //Set unit command to command attack area, with this command, _PatrolDest saved target (for come back
    //when unit attack other unit in unit's way)
    Procedure UnitCommandAttackAt(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan);
    //Set unit command to attack from patrol command, but don't check for unit can attack
    Procedure UnitCommandPatrolAttackNoCheck(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
    //Current method no need get command send from who clan, because this method call by
    //process rountine
    Procedure UnitCommandAttackNoCheck(UnitNum : TUnitCount;Target : TUnitCount);
    //Set unit command to attack from patrol command, or attack at command
    Procedure UnitCommandPatrolAttack(UnitNum : TUnitCount;Target : TUnitCount);
    //Swap unit patrol target
    Procedure UnitSwapPatrolTarget(UnitNum : TUnitCount);
    //Set unit command to wasted time (before path finding failed..)
    Procedure UnitCommandWastedTime(UnitNum : TUnitCount);
    //Set unit command training unit typer - differ from set unit to build something
    Function  UnitCommandTrain(UnitNum : TUnitCount;Typer : TUnit;FromClan : TClan) : FastInt;
    //Set unit command cast spell - direct to unit self, like cloak or blood blust
    Procedure UnitCommandDirectCastSpell(UnitNum : TUnitCount;Spell : TSpell;FromClan : TClan);
    //Set unit command cast spell - direct to target, that spell like polymorph...
    Procedure UnitCommandCastSpell(UnitNum,Target : TUnitCount;Spell : TSpell;FromClan : TClan); OverLoad;
    Procedure UnitCommandCastSpell(UnitNum : TUnitCount;DestX,DestY : FastInt;Spell : TSpell;FromClan : TClan); OverLoad;
    //Set unit command put item to fixed position
    Procedure UnitCommandPutItem(UnitNum : TUnitCount;Target : TUnitCount;Slot : TItemCount;FromClan : TClan); OverLoad;
    Procedure UnitCommandPutItem(UnitNum : TUnitCount;DestX,DestY : FastInt;Slot : TItemCount;FromClan : TClan); OverLoad;
    //Set unit command pick item from specific unit target
    Procedure UnitCommandPickUpItem(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
    //Set unit command load specific unit target
    Procedure UnitCommandLoadUnit(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
    Procedure UnitCommandUnLoadAllUnit(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan); OverLoad;
    Procedure UnitCommandGoTransportUnit(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
    //Unit harvest target ?
    Procedure UnitCommandHarvest(UnitNum,Target : TUnitCount;FromClan : TClan); OverLoad;
    Procedure UnitCommandHarvest(UnitNum : TUnitCount;FromClan : TClan); OverLoad;
    //Return gold ?
    Procedure UnitCommandReturnGold(UnitNum,Target : TUnitCount;FromClan : TClan); OverLoad;
    Function  UnitCommandReturnGold(UnitNum : TUnitCount;FromClan : TClan) : Boolean; OverLoad;
    //
    Procedure UnitCommandRallyPoint(UnitNum : TUnitCount;DestX,DestY : FastInt);
    //Unit get next command, return true if unit have next command
    Function  UnitGetNextCommand(UnitNum : TUnitCount) : Boolean;
    //Unit get prev command, return true if unit have prev command
    Function  UnitGetPrevCommand(UnitNum : TUnitCount) : Boolean;
    //
    //Missile method
    //
    Procedure RestartMissileData;
    Procedure InitMissile(MisNum : TMissileCount);
    //Set missile fire from UnitNum to Target, if MissileAround, missile has a shift around target !
    Function  NewMissile(UnitNum,Target : TUnitCount;MisType : TMissile;MissileAround : Boolean = False) : Boolean; OverLoad;
    Function  NewMissile(UnitNum : TUnitCount;TargetX,TargetY : FastInt;
                         MisType : TMissile;MissileAround : Boolean = False) : Boolean; OverLoad;
    Function  NewMissile(StartX,StartY,TargetX,TargetY : FastInt;MisType : TMissile;
                         MissileAround : Boolean = False) : Boolean; OverLoad;
    Function  NewMissile(UnitNum : TUnitCount;StartX,StartY,TargetX,TargetY : FastInt;
                         MisType : TMissile;MissileAround : Boolean = False) : Boolean; OverLoad;
    Function  NewRealMissile(StartX,StartY,TargetX,TargetY : FastInt;MisType : TMissile) : Boolean; OverLoad;
    Procedure ClearMissile(MisNum : TMissileCount);
    Procedure MissileHit(MisNum : TMissileCount);
    Procedure MissileCheckHit(MisNum : TMissileCount);
    //
    //Effect method
    //
    Procedure RestartEffectData;
    Procedure ClearEffect(EffNum : TEffectedCount);
    //Call to clear effect linked, remem to call before call ClearEffect
    Procedure DisposeEffect(EffNum : TEffectedCount);
    Procedure DisposeUnitEffect(UnitNum : TUnitCount);
    Procedure InitEffect(EffNum : TEffectedCount);
    Function  NewEffect(UnitNum : TUnitCount;Typer : TEffected;CountDown : TTimeCount) : Boolean;
    Function  UnitChangesByEffected(UnitNum : TUnitCount;Typer : TEffected) : Boolean;
    Function  UnitUnChangesByEffected(UnitNum : TUnitCount;Typer : TEffected) : Boolean;
    Function  TestUnitEffected(UnitNum : TUnitCount;Typer : TEffected) : Boolean;
    //
    //Support AI
    //
    //Add unit to AI force
    Function  AIAddUnitToForce(AI : TClan;Force : TForce;UnitNum : TUnitCount) : Boolean;
    Function  AIClearUnitFromForce(AI : TClan;Force : TForce;UnitNum : TUnitCount) : Boolean;
    Procedure AIUpdateEnemyTarget(AI : TClan);
    Procedure AIUpdateCommandAvail(AI : TClan);
    //
    //Support script
    //
    //Counting total of enemy's units
    Function  CountOfEnemyUnit(Clan : TClan) : Integer;
    //Finding specific unit by name, if unit has a same name, that return first unit in queue
    //If not found any unit, function return 0.
    Function  FindUnitIDByName(Name : String) : Integer;
    //Get unit hitpoint, if unitnum exceed unit queue limit, return hit point like unit unused!
    Function  GetUnitHitPoint(UnitNum : TUnitCount) : Integer;
    //
    //Save and load unit data with stream
    //
    Function  SaveToStream(Stream : TStream;Compress : Boolean = True) : Boolean;
    Function  LoadFromStream(Stream : TStream) : Boolean;
  End;

VAR
  GameUnits : TLOCUnits;

IMPLEMENTATION

CONSTRUCTOR TLOCUnits.Create(Screen : TLOCScreen;Show : TLOCShow);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
  End;

DESTRUCTOR TLOCUnits.Destroy;
  Begin
  End;

FUNCTION  TLOCUnits.GetForceByName(Name : String) : TForce;
  Var Index : TForce;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TForce) to High(TForce) do
      If DefaultForceName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TForce);
  End;

FUNCTION  TLOCUnits.GetUnitTyperByName(Name : String) : TUnit;
  Var Index : TUnit;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TUnit) to High(TUnit) do
      If DefaultUnitName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TUnit);
  End;

FUNCTION  TLOCUnits.GetSpellByName(Name : String) : TSpell;
  Var Index : TSpell;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TSpell) to High(TSpell) do
      If DefaultSpellName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TSpell);
  End;

FUNCTION  TLOCUnits.GetEffectByName(Name : String) : TEffected;
  Var Index : TEffected;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TEffected) to High(TEffected) do
      If DefaultEffectName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TEffected);
  End;

FUNCTION  TLOCUnits.GetClanByName(Name : String) : TClan;
  Var Index : TClan;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TClan) to High(TClan) do
      If DefaultClanName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TClan);
  End;

FUNCTION  TLOCUnits.GetSkillByName(Name : String) : TSkill;
  Var Index : TSkill;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TSkill) to High(TSkill) do
      If DefaultSkillName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TSkill);
  End;

FUNCTION  TLOCUnits.GetAttributeByName(Name : String) : TBaseUnitAttribute;
  Var Index : TBaseUnitAttribute;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TBaseUnitAttribute) to High(TBaseUnitAttribute) do
      If DefaultBaseUnitAttributeStr[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TBaseUnitAttribute);
  End;

FUNCTION  TLOCUnits.GetItemByName(Name : String) : TItem;
  Var Index : TItem;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TItem) to High(TItem) do
      If DefaultItemName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TItem);
  End;

FUNCTION  TLOCUnits.GetMissileByName(Name : String) : TMissile;
  Var Index : TMissile;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(TMissile) to High(TMissile) do
      If DefaultMissileName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(TMissile);
  End;

FUNCTION TLOCUnits.GetWeaponTargetByName(Name : String) : TWeaponCanTarget;
  Var Index : Byte;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(DefaultWeaponCanTarget) to High(DefaultWeaponCanTarget) do
      If DefaultWeaponCanTarget[Index].Name=Name then
        Begin
          Result:=DefaultWeaponCanTarget[Index].Value;
          Exit;
        End;
    Result:=0;
  End;

FUNCTION TLOCUnits.GetHeadingByName(Name : String) : THeading;
  Var Index : THeading;
  Begin
    StrippedAllSpaceAndUpCase(Name);
    For Index:=Low(THeading) to High(THeading) do
      If DefaultHeadingName[Index]=Name then
        Begin
          Result:=Index;
          Exit;
        End;
    Result:=Low(THeading);
  End;
  
FUNCTION TLOCUnits.GetRandomHeading : THeading;
  Begin
    Result:=THeading(Random(Byte(High(THeading))+1));
    {Case Random(8) of
      0 : Result:=H1;
      1 : Result:=H2;
      2 : Result:=H3;
      3 : Result:=H4;
      4 : Result:=H5;
      5 : Result:=H6;
      6 : Result:=H7;
      Else Result:=H8;
    End;}
  End;

PROCEDURE TLOCUnits.SettingClanDefault;
  Var Z,K : TClan;
  Begin
    For Z:=Low(TClan) to High(TClan) do
      With ClanInfo[Z] do
        Begin
          For K:=Low(TClan) to High(TClan) do
            Begin
              Diplomacy[K]:=Enemy;
              SharedControl[K]:=NoSharedControl;
              SharedVision[K]:=NoSharedVision;
            End;
          //Ally with gaia units
          Diplomacy[Gaia]:=Ally;
          //Ally with self, of course
          Diplomacy[Z]:=Ally;
          SharedControl[Z]:=FullSharedControl;
          SharedVision[Z]:=FullSharedVision;
        End;
    With ClanInfo[Gaia] do
      For Z:=Low(TClan) to High(TClan) do
        Diplomacy[Z]:=Ally;
  End;

PROCEDURE TLOCUnits.SetupClan(Clan : TClan;Name : String;Control : TControl;
                              Race : TRace;Resource : Array of LongInt);
  Var Z : TResource;
  Begin
    ClanInfo[Clan].ClanName:=Name;
    ClanInfo[Clan].Control:=Control;
    ClanInfo[Clan].ClanRace:=Race;
    For Z:=Low(TResource) to High(TResource) do
      ClanInfo[Clan].Resource[Z]:=Resource[Byte(Z)];
  End;

PROCEDURE TLOCUnits.SetupClanDiplomacy(Clan1,Clan2 : TClan;Status : TClanDiplomacy);
  Begin
    ClanInfo[Clan1].Diplomacy[Clan2]:=Status;
    ClanInfo[Clan2].Diplomacy[Clan1]:=Status;
  End;

PROCEDURE TLOCUnits.AllClanDiplomacy(Status : TClanDiplomacy);
  Var C1,C2 : TClan;
  Begin
    For C1:=Low(TClan) to High(TClan) do
      For C2:=Low(TClan) to High(TClan) do
        ClanInfo[C1].Diplomacy[C2]:=Status;
    For C1:=Low(TClan) to High(TClan) do
      ClanInfo[C1].Diplomacy[C1]:=Ally;
  End;

PROCEDURE TLOCUnits.LoadDefaultSetting;
  Var C : TClan;
      U : TUnit;
  Begin
    //
    //Setup weapon item property
    //
    SetupWeaponItemProperty(ItemWeaponPeonAxe        ,'Small axe'          ,01,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    //
    SetupWeaponItemProperty(ItemWeaponBattleAxe      ,'Battle axe'         ,10,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    SetupWeaponItemProperty(ItemWeaponMagicBattleAxe ,'Magic battle axe'   ,05,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    SetupWeaponItemProperty(ItemWeaponSuperBattleAxe ,'Super battle axe'   ,05,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    //
    SetupWeaponItemProperty(ItemWeaponBesAxe         ,'Berserker axe'      ,10,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileAxe,0,4);
    SetupWeaponItemProperty(ItemWeaponLongBesAxe     ,'Long berserker axe' ,10,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileAxe,0,4);
    SetupWeaponItemProperty(ItemWeaponMagicBesAxe    ,'Magic berserker axe',10,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileAxe,0,4);
    //
    SetupWeaponItemProperty(ItemWeaponBlade          ,'Blade'              ,10,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    SetupWeaponItemProperty(ItemWeaponMagicBlade     ,'Magic blade'        ,05,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    SetupWeaponItemProperty(ItemWeaponGunBlade       ,'Gun blade'          ,20,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileDragBull,0,4);
    //
    SetupWeaponItemProperty(ItemWeaponBow            ,'Bow'                ,10,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileArrow,0,4);
    SetupWeaponItemProperty(ItemWeaponMagicBow       ,'Magic bow'          ,05,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileArrow,0,4);
    SetupWeaponItemProperty(ItemWeaponLongBow        ,'Long bow'           ,20,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileArrow,0,4);
    //
    SetupWeaponItemProperty(ItemWeaponHeavySpear     ,'Heavy spear'        ,15,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    SetupWeaponItemProperty(ItemWeaponMagicHeavySpear,'Magic heavy spear'  ,15,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    //
    SetupWeaponItemProperty(ItemWeaponGlove          ,'Glove'              ,15,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    SetupWeaponItemProperty(ItemWeaponMagicGlove     ,'Magic glove'        ,15,WeaponCanTargetLandUnit+WeaponCanTargetBuilding,MissileNone,0,0);
    //
    SetupWeaponItemProperty(ItemWeaponMagicStaff     ,'Magic staff'        ,05,WeaponCanTargetLandUnit+WeaponCanTargetAirUnit,MissileLightning,0,4);
    SetupWeaponItemProperty(ItemWeaponDeathMagicStaff,'Dark magic staff'   ,20,WeaponCanTargetLandUnit+WeaponCanTargetAirUnit,MissileTouchOfDeath,0,4);
    //
    SetupWeaponItemProperty(ItemWeaponBallistaBolt   ,'Ballista bolt'      ,20,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileTouchOfDeath,0,4);
    SetupWeaponItemProperty(ItemWeaponCatapulRock    ,'Catapul rock'       ,20,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileTouchOfDeath,0,4);
    //
    SetupWeaponItemProperty(ItemWeaponHellFire       ,'Hell fire'          ,30,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileNone,0,4);
    SetupWeaponItemProperty(ItemWeaponDragonBreath   ,'Dragon breath'      ,30,WeaponCanTargetLandUnit+WeaponCanTargetBuilding+WeaponCanTargetAirUnit,MissileNone,0,4);
    //Setup armor item property
    SetupArmorItemProperty(ItemArmor1,'Cloak');
    SetupArmorItemProperty(ItemArmor2,'Cloak');
    SetupArmorItemProperty(ItemArmor3,'Cloak');
    SetupArmorItemProperty(ItemArmor4,'Cloak');
    SetupArmorItemProperty(ItemArmor5,'Cloak');
    SetupArmorItemProperty(ItemArmor6,'Cloak');
    //Setup shield item property
    SetupShieldItemProperty(ItemShield1,'Shield');
    SetupShieldItemProperty(ItemShield2,'Shield');
    SetupShieldItemProperty(ItemShield3,'Shield');
    SetupShieldItemProperty(ItemShield4,'Shield');
    SetupShieldItemProperty(ItemShield5,'Shield');
    //Setup helm item property
    SetupHelmItemProperty(ItemHelm1,'Helm');
    SetupHelmItemProperty(ItemHelm2,'Helm');
    //Setup boot item property
    SetupBootItemProperty(ItemBoot1,'Boots');
    SetupBootItemProperty(ItemBoot2,'Boots');
    SetupBootItemProperty(ItemBoot3,'Boots');
    //Setup decorate item property
    SetupDecorateItemProperty(ItemDecoration1,'Decoration');
    SetupDecorateItemProperty(ItemDecoration2,'Decoration');
    SetupDecorateItemProperty(ItemDecoration3,'Decoration');
    SetupDecorateItemProperty(ItemDecoration4,'Decoration');
    SetupDecorateItemProperty(ItemDecoration5,'Decoration');
    SetupDecorateItemProperty(ItemDecoration6,'Decoration');
    SetupDecorateItemProperty(ItemDecoration7,'Decoration');
    SetupDecorateItemProperty(ItemDecoration8,'Decoration');
    SetupDecorateItemProperty(ItemDecoration9,'Decoration');
    //
    //Setup missile property
    //
    FillChar(MissileProperty,SizeOf(MissileProperty),0);
    //Green cross hair
    MissileProperty[MissileGreenCross  ].MissileSpeed:=0;
    MissileProperty[MissileGreenCross  ].MissileAttribute:=0;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileGreenCross  ].MissileEffect:=EffectBlend2;
    MissileProperty[MissileGreenCross  ].AlphaChannel:=$80000000;
    {$EndIf}
    MissileProperty[MissileGreenCross  ].DrawLevel:=0;
    //Arrow
    MissileProperty[MissileArrow       ].MissileSpeed:=2;
    MissileProperty[MissileArrow       ].MissileAttribute:=MissileHasShadow or MissilePointTo;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileArrow       ].MissileEffect:=EffectSrcAlpha;
    {$EndIf}
    MissileProperty[MissileArrow       ].DrawLevel:=3;
    //Berserker axe
    MissileProperty[MissileAxe         ].MissileSpeed:=2;
    MissileProperty[MissileAxe         ].MissileAttribute:=MissileHasShadow or MissilePointTo;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileAxe         ].MissileEffect:=EffectSrcAlpha;
    {$EndIf}
    MissileProperty[MissileAxe         ].DrawLevel:=3;
    //Lighting
    MissileProperty[MissileLightning   ].MissileSpeed:=2;
    MissileProperty[MissileLightning   ].MissileAttribute:=MissileHasShadow or MissilePointTo;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileLightning   ].MissileEffect:=EffectSrcAlpha;
    {$EndIf}
    MissileProperty[MissileLightning   ].DrawLevel:=3;
    //Touch of death
    MissileProperty[MissileTouchOfDeath].MissileSpeed:=2;
    MissileProperty[MissileTouchOfDeath].MissileAttribute:=MissileHasShadow or MissilePointTo;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileTouchOfDeath].MissileEffect:=EffectSrcAlpha;
    {$EndIf}
    MissileProperty[MissileTouchOfDeath].DrawLevel:=3;
    //Drag bull
    MissileProperty[MissileDragBull    ].MissileSpeed:=0;
    MissileProperty[MissileDragBull    ].MissileAttribute:=MissileHasShadow or MissilePointTo;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileDragBull    ].MissileEffect:=EffectBlend2;
    {$EndIf}
    MissileProperty[MissileDragBull    ].DrawLevel:=3;
    //Fire ball
    MissileProperty[MissileFireBall    ].MissileSpeed:=0;
    MissileProperty[MissileFireBall    ].MissileAttribute:=MissilePointTo or
                                                           MissileDamageOnFly or
                                                           MissileDamageFriendly or
                                                           MissileStillFlyBeforeHit;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileFireBall    ].MissileEffect:=EffectBlendColorAlphaChannel;
    MissileProperty[MissileFireBall    ].AlphaChannel:=$80000000;
    {$EndIf}
    MissileProperty[MissileFireBall    ].DrawLevel:=3;
    //Explosion
    MissileProperty[MissileExplode   ].MissileSpeed:=0;
    MissileProperty[MissileExplode   ].MissileAttribute:=0;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileExplode   ].MissileEffect:=EffectBlendColorAlphaChannel;
    MissileProperty[MissileExplode   ].AlphaChannel:=$80000000;
    {$EndIf}
    MissileProperty[MissileExplode   ].DrawLevel:=3;
    //Blizzard
    MissileProperty[MissileBlizzard  ].MissileSpeed:=0;
    MissileProperty[MissileBlizzard  ].MissileAttribute:=MissilePointTo or
                                                         MissileDamageOnExplosion or
                                                         MissileDamageFriendly;
    {$IfDef MissileEffectItSelf}
    MissileProperty[MissileBlizzard  ].MissileEffect:=EffectRealBlend;
    MissileProperty[MissileBlizzard  ].AlphaChannel:=$80000000;
    {$EndIf}
    MissileProperty[MissileBlizzard  ].DrawLevel:=3;
    //
    //Setup effect property
    //
    FillChar(EffectProperty,SizeOf(EffectProperty),0);
    EffectProperty[HeroSign0         ].EffectKind:=EffectKindHeroSignFlashRotate;
    EffectProperty[HeroSign0         ].DrawLevel:=0;
    EffectProperty[HeroSign1         ].EffectKind:=EffectKindHeroSignFlash;
    EffectProperty[HeroSign1         ].DrawLevel:=0;
    EffectProperty[HeroSign2         ].EffectKind:=EffectKindHeroSignFlash;
    EffectProperty[HeroSign2         ].DrawLevel:=0;
    EffectProperty[HeroSign3         ].EffectKind:=EffectKindHeroSignFlash;
    EffectProperty[HeroSign3         ].DrawLevel:=0;
    EffectProperty[HeroSign4         ].EffectKind:=EffectKindHeroSignFlashRotate;
    EffectProperty[HeroSign4         ].DrawLevel:=0;
    EffectProperty[HeroSign5         ].EffectKind:=EffectKindHeroSignFlash;
    EffectProperty[HeroSign5         ].DrawLevel:=0;
    EffectProperty[HeroSign6         ].EffectKind:=EffectKindHeroSignFlash;
    EffectProperty[HeroSign6         ].DrawLevel:=0;
    EffectProperty[HeroSign7         ].EffectKind:=EffectKindHeroSignFlash;
    EffectProperty[HeroSign7         ].DrawLevel:=0;
    EffectProperty[HeroSign8         ].EffectKind:=EffectKindHeroSignFlashRotate;
    EffectProperty[HeroSign8         ].DrawLevel:=0;
    EffectProperty[HeroSign9         ].EffectKind:=EffectKindHeroSignFlash;
    EffectProperty[HeroSign9         ].DrawLevel:=0;
    //
    //Setup skill property
    //
    FillChar(SkillProperty,SizeOf(SkillProperty),0);
    SkillProperty[CmdMove].SkillHotkey:=Key_M;
    SkillProperty[CmdMove].ToolTip:='Move#You can command#your unit move';
    SkillProperty[CmdHoldPosition].SkillHotkey:=Key_H;
    SkillProperty[CmdHoldPosition].ToolTip:='Unit still hold position';
    SkillProperty[CmdStop].SkillHotkey:=Key_S;
    SkillProperty[CmdStop].ToolTip:='Stop';
    SkillProperty[CmdPatrol].SkillHotkey:=Key_P;
    SkillProperty[CmdPatrol].ToolTip:='Patrol';
    SkillProperty[CmdAttack].SkillHotkey:=Key_A;
    SkillProperty[CmdAttack].ToolTip:='Attack';
    SkillProperty[CmdAttackGround].SkillHotkey:=Key_G;
    SkillProperty[CmdAttackGround].ToolTip:='Attack ground';
    SkillProperty[CmdHarvest].SkillHotkey:=Key_H;
    SkillProperty[CmdHarvest].ToolTip:='Harvest';
    SkillProperty[CmdCancelBuilding].SkillHotkey:=Key_Escape;
    SkillProperty[CmdCancelBuilding].ToolTip:='Cancel';
    SkillProperty[CmdCancel].SkillHotkey:=Key_Escape;
    SkillProperty[CmdCancel].ToolTip:='Cancel';
    SkillProperty[CmdBuildingHuman].SkillHotkey:=Key_B;
    SkillProperty[CmdBuildingHuman].ToolTip:='Build human construction';
    SkillProperty[CmdBuildingOrc].SkillHotkey:=Key_B;
    SkillProperty[CmdBuildingOrc].ToolTip:='Build orc construction';
    SkillProperty[CmdBuildingDevil].SkillHotkey:=Key_B;
    SkillProperty[CmdBuildingDevil].ToolTip:='Build devil construction';
    SkillProperty[CmdUnLoadUnit].SkillHotkey:=Key_U;
    SkillProperty[CmdUnLoadUnit].ToolTip:='Unload all unit in transporter';
    //
    //Setup default skill avail
    //
    FillChar(SkillAvailable,SizeOf(SkillAvailable),False);
    //Basic skill always available, except specific campaign
    For C:=Low(TClan) to High(TClan) do
      Begin
        //Skill avail for setup button, not for used
        //Why need this ? :>>
        SkillAvailable[C,CmdMove          ]:=True;
        SkillAvailable[C,CmdHoldPosition  ]:=True;
        SkillAvailable[C,CmdStop          ]:=True;
        SkillAvailable[C,CmdPatrol        ]:=True;
        SkillAvailable[C,CmdAttack        ]:=True;
        SkillAvailable[C,CmdAttacking     ]:=True;
        SkillAvailable[C,CmdAttackGround  ]:=True;
        SkillAvailable[C,CmdHarvest       ]:=True;
        SkillAvailable[C,CmdCancel        ]:=True;
        SkillAvailable[C,CmdCancelBuilding]:=True;
        SkillAvailable[C,CmdBuildingHuman ]:=True;
        SkillAvailable[C,CmdBuildingOrc   ]:=True;
        SkillAvailable[C,CmdBuildingDevil ]:=True;
        SkillAvailable[C,CmdUnLoadUnit    ]:=True;
      End;
    //
    //Setup default spell property
    //
    FillChar(SpellProperty,SizeOf(SpellProperty),0);
    //
    SpellProperty[SpellFireBall    ].SpellHotkey:=Key_F;
    SpellProperty[SpellFireBall    ].ToolTip:='Fireball at every where you want !';
    SpellProperty[SpellFireBall    ].MinRange:=0;
    SpellProperty[SpellFireBall    ].MaxRange:=15;
    SpellProperty[SpellFireBall    ].NeedTarget:=False;
    SpellProperty[SpellFireBall    ].ManaCost:=50;
    //
    SpellProperty[SpellInvisibility].SpellHotkey:=Key_I;
    SpellProperty[SpellInvisibility].ToolTip:='Transform unit to invisible';
    SpellProperty[SpellInvisibility].MinRange:=0;
    SpellProperty[SpellInvisibility].MaxRange:=5;
    SpellProperty[SpellInvisibility].NeedTarget:=True;
    SpellProperty[SpellInvisibility].ManaCost:=50;
    //
    SpellProperty[SpellHaste       ].SpellHotkey:=Key_H;
    SpellProperty[SpellHaste       ].ToolTip:='Make your unit faster 200% !';
    SpellProperty[SpellHaste       ].MinRange:=0;
    SpellProperty[SpellHaste       ].MaxRange:=5;
    SpellProperty[SpellHaste       ].NeedTarget:=True;
    SpellProperty[SpellHaste       ].ManaCost:=50;
    //
    SpellProperty[SpellDecay       ].SpellHotkey:=Key_D;
    SpellProperty[SpellDecay       ].ToolTip:='Decay';
    SpellProperty[SpellDecay       ].SpellAttribute:=SpellHasACycles;
    SpellProperty[SpellDecay       ].MinRange:=0;
    SpellProperty[SpellDecay       ].MaxRange:=5;
    SpellProperty[SpellDecay       ].NeedTarget:=False;
    SpellProperty[SpellDecay       ].ManaCost:=50;
    //
    SpellProperty[SpellLightning   ].SpellHotkey:=Key_L;
    SpellProperty[SpellLightning   ].ToolTip:='Lighting bolt !';
    SpellProperty[SpellLightning   ].SpellAttribute:=SpellHasACycles+SpellDirective;
    SpellProperty[SpellLightning   ].MinRange:=0;
    SpellProperty[SpellLightning   ].MaxRange:=5;
    SpellProperty[SpellLightning   ].NeedTarget:=False;
    SpellProperty[SpellLightning   ].ManaCost:=50;
    //
    SpellProperty[SpellBloodLust   ].SpellHotkey:=Key_B;
    SpellProperty[SpellBloodLust   ].ToolTip:='BloodLust#Your unit come #faster and stronger';
    SpellProperty[SpellBloodLust   ].SpellAttribute:=SpellHasACycles;
    SpellProperty[SpellBloodLust   ].MinRange:=0;
    SpellProperty[SpellBloodLust   ].MaxRange:=5;
    SpellProperty[SpellBloodLust   ].NeedTarget:=True;
    SpellProperty[SpellBloodLust   ].ManaCost:=50;
    //
    SpellProperty[SpellBlizzard    ].SpellHotkey:=Key_B;
    SpellProperty[SpellBlizzard    ].ToolTip:='Blizzard';
    SpellProperty[SpellBlizzard    ].SpellAttribute:=SpellHasACycles;
    SpellProperty[SpellBlizzard    ].MinRange:=0;
    SpellProperty[SpellBlizzard    ].MaxRange:=5;
    SpellProperty[SpellBlizzard    ].NeedTarget:=False;
    SpellProperty[SpellBlizzard    ].ManaCost:=50;
    //Setup default spell avail
    FillChar(SpellAvailable,SizeOf(SpellAvailable),False);
    //Basic skill always available, except specific campaign
    For C:=Low(TClan) to High(TClan) do
      Begin
        SpellAvailable[C,SpellInvisibility]:=True;
        SpellAvailable[C,SpellHaste       ]:=True;
        SpellAvailable[C,SpellDecay       ]:=True;
        SpellAvailable[C,SpellLightning   ]:=True;
        SpellAvailable[C,SpellBloodLust   ]:=True;
        SpellAvailable[C,SpellFireBall    ]:=True;
        SpellAvailable[C,SpellBlizzard    ]:=True;
      End;
    //
    //Setup for unit available
    //
    FillChar(UnitAvailable,SizeOf(UnitAvailable),False);
    //Basic unit always available, except specific campaign
    For C:=Low(TClan) to High(TClan) do
      Begin
        //Unit
        UnitAvailable[C,Peon             ]:=True;
        UnitAvailable[C,Peasant          ]:=True;
        UnitAvailable[C,Grunt            ]:=True;
        UnitAvailable[C,Footman          ]:=True;
        //Building
        UnitAvailable[C,GreatHall        ]:=True;
        UnitAvailable[C,TownHall         ]:=True;
        UnitAvailable[C,HumanFarm        ]:=True;
        UnitAvailable[C,OrcFarm          ]:=True;
        UnitAvailable[C,HumanBarrack     ]:=True;
        UnitAvailable[C,OrcBarrack       ]:=True;
        UnitAvailable[C,HumanBlackSmith  ]:=True;
        UnitAvailable[C,OrcBlackSmith    ]:=True;
        UnitAvailable[C,ElvenLumberMill  ]:=True;
        UnitAvailable[C,TrollLumberMill  ]:=True;
        UnitAvailable[C,HumanScoutTower  ]:=True;
        UnitAvailable[C,OrcWatchTower    ]:=True;
        UnitAvailable[C,Stables          ]:=True;
        UnitAvailable[C,OgreMound        ]:=True;
        UnitAvailable[C,MageTower        ]:=True;
        UnitAvailable[C,TempleOfTheDamned]:=True;
        UnitAvailable[C,GnomishInventor  ]:=True;
        UnitAvailable[C,GoblinAlchemist  ]:=True;
        UnitAvailable[C,Church           ]:=True;
        UnitAvailable[C,AltarOfStorm     ]:=True;
      End;
    //
    //Setup unit property
    //
    For C:=Low(TClan) to High(TClan) do
      Begin
        For U:=Low(TUnit) to High(TUnit) do
          FillChar(UnitsProperty[C][U],Sizeof(UnitsProperty[C][U]),0);
        //Setup for critter unit
        With UnitsProperty[C][Critter1] do
          Begin
            Name:='Critter';
            HitPoint:=10;
            SeeRange:=2;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdMove;
            RightCommandTargetEnemy:=CmdMove;
            HotKey:=Key_C;
          End;
        //Setup for critter unit
        With UnitsProperty[C][Critter2] do
          Begin
            Name:='Critter';
            HitPoint:=10;
            SeeRange:=2;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdMove;
            RightCommandTargetEnemy:=CmdMove;
            HotKey:=Key_C;
          End;
        //Setup for critter unit
        With UnitsProperty[C][Critter3] do
          Begin
            Name:='Critter';
            HitPoint:=10;
            SeeRange:=2;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdMove;
            RightCommandTargetEnemy:=CmdMove;
            HotKey:=Key_C;
          End;
        //Setup for critter unit
        With UnitsProperty[C][Critter4] do
          Begin
            Name:='Critter';
            HitPoint:=10;
            SeeRange:=2;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdMove;
            RightCommandTargetEnemy:=CmdMove;
            HotKey:=Key_C;
          End;
        //Setup for peasant unit
        With UnitsProperty[C][Peasant] do
          Begin
            Name:='Peasant';
            HitPoint:=100;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            Skill[5].Skill:=CmdHarvest;
            Skill[6].Skill:=CmdBuildingHuman;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_P;
          End;
        //Setup for peon unit
        With UnitsProperty[C][Peon] do
          Begin
            Name:='Peon';
            HitPoint:=100;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            Skill[5].Skill:=CmdHarvest;
            Skill[6].Skill:=CmdBuildingOrc;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_P;
          End;
        //Setup for footman unit
        With UnitsProperty[C][FootMan] do
          Begin
            Name:='Footman';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_F;
          End;
        //Setup for grunt unit
        With UnitsProperty[C][Grunt] do
          Begin
            Name:='Grunt';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit,UnitFreeTraining];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_G;
          End;
        //Setup for archer unit
        With UnitsProperty[C][Archer] do
          Begin
            Name:='Archer';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_A;
          End;
        //Setup for berserker unit
        With UnitsProperty[C][Berserker] do
          Begin
            Name:='Besenker';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_B;
          End;
        //Setup for knight unit
        With UnitsProperty[C][Knight] do
          Begin
            Name:='Knight';
            HitPoint:=2000;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_K;
          End;
        //Setup for ogre unit
        With UnitsProperty[C][Ogre] do
          Begin
            Name:='Ogre';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_O;
          End;
        //Setup for dragon unit
        With UnitsProperty[C][Dragon] do
          Begin
            Name:='Dragon';
            HitPoint:=2000;
            SeeRange:=5;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=1;
            UnitSizeY:=1;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsAirUnit];
            UnitDrawLevel:=2;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_D;
          End;
        //Setup for deathwing unit
        With UnitsProperty[C][DeathWing] do
          Begin
            Name:='DeathWing';
            HitPoint:=20000;
            SeeRange:=5;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=1;
            UnitSizeY:=1;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsAirUnit];
            UnitDrawLevel:=2;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_D;
          End;
        //Setup for gryphon unit
        With UnitsProperty[C][Gryphon] do
          Begin
            Name:='Gryphon';
            HitPoint:=2000;
            SeeRange:=5;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=1;
            UnitSizeY:=1;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsAirUnit];
            UnitDrawLevel:=2;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_G;
          End;
        //Setup for dwarves unit
        With UnitsProperty[C][Dwarves] do
          Begin
            Name:='Dwarves';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_D;
          End;
        //Setup for goblin unit
        With UnitsProperty[C][Goblin] do
          Begin
            Name:='Goblin';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_G;
          End;
        //Setup for xkeleton unit
        With UnitsProperty[C][Xkeleton] do
          Begin
            Name:='Xkeleton';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_X;
          End;
        //Setup for light unit
        With UnitsProperty[C][Light] do
          Begin
            Name:='Light';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_L;
          End;
        //Setup for commander unit
        With UnitsProperty[C][Commander] do
          Begin
            Name:='Commander';
            HitPoint:=200;
            SeeRange:=4;
            BaseDamage:=10;
            Skill[1].Skill:=CmdMove;
            Skill[2].Skill:=CmdStop;
            Skill[3].Skill:=CmdAttack;
            Skill[4].Skill:=CmdPatrol;
            UnitSizeX:=0;
            UnitSizeY:=0;
            FoodUsed:=1;
            BaseAttribute:=[UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdMove;
            RightCommandTargetAlly:=CmdFollow;
            RightCommandTargetEnemy:=CmdAttack;
            HotKey:=Key_L;
          End;
        //Setup for human farm unit
        With UnitsProperty[C][HumanFarm] do
          Begin
            Name:='Human Farm';
            HitPoint:=200;
            SeeRange:=2;
            UnitSizeX:=1;
            UnitSizeY:=1;
            BaseAttribute:=[UnitIsBuilding,UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdRallyPoint;
            RightCommandTargetAlly:=CmdRallyPoint;
            RightCommandTargetEnemy:=CmdRallyPoint;
            HotKey:=Key_F;
          End;
        //Setup for orc farm unit
        With UnitsProperty[C][OrcFarm] do
          Begin
            Name:='Orc Farm';
            HitPoint:=200;
            SeeRange:=2;
            UnitSizeX:=1;
            UnitSizeY:=1;
            BaseAttribute:=[UnitIsBuilding,UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdRallyPoint;
            RightCommandTargetAlly:=CmdRallyPoint;
            RightCommandTargetEnemy:=CmdRallyPoint;
            HotKey:=Key_F;
          End;
        //Setup for human barrack unit
        With UnitsProperty[C][HumanBarrack] do
          Begin
            Name:='Human Barrack';
            HitPoint:=200;
            SeeRange:=4;
            UnitSizeX:=2;
            UnitSizeY:=2;
            BaseAttribute:=[UnitIsBuilding,UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdRallyPoint;
            RightCommandTargetAlly:=CmdRallyPoint;
            RightCommandTargetEnemy:=CmdRallyPoint;
            HotKey:=Key_B;
          End;
        //Setup for orc barrack unit
        With UnitsProperty[C][OrcBarrack] do
          Begin
            Name:='Orc Barrack';
            HitPoint:=200;
            SeeRange:=4;
            UnitSizeX:=2;
            UnitSizeY:=2;
            BaseAttribute:=[UnitIsBuilding,UnitIsLandUnit];
            UnitDrawLevel:=1;
            FillChar(UnitMapped,SizeOf(UnitMapped),1);
            RightCommandNoTarget:=CmdRallyPoint;
            RightCommandTargetAlly:=CmdRallyPoint;
            RightCommandTargetEnemy:=CmdRallyPoint;
            HotKey:=Key_B;
          End;
      End;
    LoadUnitSetting(GameDataDir+UnitSettingFileName);
    LoadItemSetting(GameDataDir+ItemSettingFileName);
  End;

PROCEDURE TLOCUnits.DataDefault;
  Begin
  End;

PROCEDURE TLOCUnits.LoadMapAbility;
  Begin
  End;

PROCEDURE TLOCUnits.SetAllUnitsToStart;
  Var Clan  : TClan;
      Z     : TUnitCount;
  Begin
    TotalUnit:=0;
    UnitFocus:=0;
    OldUnitFocus:=0;
    CurHumanWorkerUnit:=0;
    CurHumanTroopUnit:=0;
    CurHumanBuildingUnit:=0;
    FillChar(CurrentSkillButton,SizeOf(CurrentSkillButton),0);
    FillChar(CurrentSavedQueue,SizeOf(CurrentSavedQueue),0);
    FillChar(SaveGroups,SizeOf(SaveGroups),0);
    FillChar(ClanInfo,SizeOf(ClanInfo),0);
    //Give all units to unused
    For Z:=Low(Units) to High(Units) do
      Units[Z]._UnitHitPoint:=UnitUnUsedConst;
    //Clear AI data
    For Clan:=Low(TCLan) to High(TClan) do
      With AIData[Clan] do
        Begin
          CurrentEnemy:=Gaia;
          AIOwnTownUnderAttack:=False;
          AIMainTown:=0;
          AIMainGoldMine:=0;
          AIRallyPoint.X:=0;
          AIRallyPoint.Y:=0;
          AIOwnTownUnderAttack:=False;
          AIFoundEnemyAt.X:=0;
          AIFoundEnemyAt.Y:=0;
          WaitForAttackComplete:=False;
          FillChar(AICmdAvail,SizeOf(AICmdAvail),False);
          FillChar(AICmdComplete,SizeOf(AICmdComplete),True);
          FillChar(AICmdSleep,SizeOf(AICmdSleep),0);
          FillChar(ForceCount,SizeOf(ForceCount),0);
          FillChar(UnitNeed,SizeOf(UnitNeed),0);
          FillChar(UnitNeedForAttack,SizeOf(UnitNeedForAttack),0);
          FillChar(UnitCanBuild,SizeOf(UnitCanBuild),NoneUnit);
          FillChar(AIForce,SizeOf(AIForce),0);
        End;
  End;

PROCEDURE TLOCUnits.LoadUnitSetting(FileName : String);
  Var St,Sub,Sub2      : String;
      UnitType,UnitTmp : TUnit;
      CC1,CC2          : TClan;
      SkillCount       : TSkillCount;
      SkillTmp         : TSkill;
      AttrTmp          : TBaseUnitAttribute;
      Spell            : TSpell;
      I,J,Index        : FastInt;
      ResIdx           : TResource;
      SlotIdx          : TItemCount;
      Head             : THeading;
      F                : Text;
  Begin
    Assign(F,FileName);
    Reset(F);
    If IOResult<>0 then Exit;
    While Not EoF(F) do
      Begin
        ReadLn(F,St);
        If St='' then Continue;
        If St[1]=SkipSymbol then Continue;
        Sub:=GetFirstComment(St);
        StrippedAllSpaceAndUpCase(Sub);
        //Setting for unit specific
        //Like : "Setting for unit : Unit type : Unit clan"
        If Sub=SettingForUnitStr then
          Begin
            Sub:=GetFirstComment(St);
            StrippedAllSpaceAndUpCase(Sub);
            //Get unit type by name
            UnitType:=GetUnitTyperByName(Sub);
            Sub:=GetFirstComment(St);
            StrippedAllSpaceAndUpCase(Sub);
            //Get unit clan by name
            CC1:=GetClanByName(Sub);
            With UnitsProperty[CC1,UnitType] do
              While Not EoF(F) do
                Begin
                  UnitAvail:=True;
                  ReadLn(F,St);
                  If St='' then Continue;
                  If St[1]=SkipSymbol then Continue;
                  Sub:=GetFirstComment(St);
                  StrippedAllSpaceAndUpCase(Sub);
                  //Get unit name
                  If Sub=NameStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      //Unit name
                      Name:=Sub;
                    End
                  Else
                  //Get unit hit point
                  If Sub=HitPointStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      //Unit hitpoint
                      If ToInt(Sub)>High(THitPoint) then
                        HitPoint:=High(THitPoint)
                      Else HitPoint:=ToInt(Sub);
                    End
                  Else
                  //Get unit see range
                  If Sub=UnitSeeRangeStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      //Unit seerange
                      SeeRange:=ToInt(Sub);
                    End
                  Else
                  //Get unit base damage
                  If Sub=UnitBaseDamageStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      BaseDamage:=ToInt(Sub);
                    End
                  Else
                  //Get unit base item
                  If Sub=UnitBaseItemStr then
                    Begin
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          Sub2:=GetFirstComment(St);
                          StrippedAllSpaceAndUpCase(Sub);
                          StrippedAllSpaceAndUpCase(Sub2);
                          For SlotIdx:=Low(TItemCount) to High(TItemCount) do
                            If Sub=DefaultSlotName[SlotIdx] then
                              Begin
                                BaseItem[SlotIdx].Typer:=GetItemByName(Sub2);
                                BaseItem[SlotIdx].Number:=1;
                              End;
                        End;
                    End
                  Else
                  //Get unit base item
                  If Sub=UnitItemSlotAvail then
                    Begin
                      FillChar(ItemSlotAvail,SizeOf(ItemSlotAvail),False);
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          StrippedAllSpaceAndUpCase(Sub);
                          If Sub=AllStr then
                            Begin
                              FillChar(ItemSlotAvail,SizeOf(ItemSlotAvail),True);
                            End
                          Else
                          For SlotIdx:=Low(TItemCount) to High(TItemCount) do
                            If Sub=DefaultSlotName[SlotIdx] then
                              ItemSlotAvail[SlotIdx]:=True;
                        End;
                    End
                  Else
                  //Get unit food used
                  If Sub=UnitFoodUsedStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      FoodUsed:=ToInt(Sub);
                    End
                  Else
                  //Get unit food gain
                  If Sub=UnitFoodGainStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      FoodGain:=ToInt(Sub);
                    End
                  Else
                  //Get unit money
                  If Sub=UnitMoneyStr then
                    Begin
                      {Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      Money:=ToInt(Sub);}
                    End
                  Else
                  //Get unit point
                  If Sub=UnitPointStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      Point:=ToInt(Sub);
                    End
                  Else
                  //Get unit cost
                  If Sub=UnitCostStr then
                    Begin
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          Sub2:=GetFirstComment(St);
                          StrippedAllSpaceAndUpCase(Sub);
                          StrippedAllSpaceAndUpCase(Sub2);
                          For ResIdx:=Low(TResource) to High(TResource) do
                            If Sub=DefaultResourceName[ResIdx] then
                              UnitCost[ResIdx]:=ToInt(Sub2);
                        End;
                    End
                  Else
                  //Get unit time training
                  If Sub=UnitTimeCostStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      UnitTimeCost:=ToInt(Sub);
                    End
                  Else
                  //Get unit max mana
                  If Sub=UnitManaMaxStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      MaxMana:=ToInt(Sub);
                    End
                  Else
                  //Get unit mana grow
                  If Sub=UnitManaGrowStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      ManaGrow:=ToInt(Sub);
                    End
                  Else
                  //Get unit hit point grow
                  If Sub=UnitHitPointGrowStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      HitPointGrow:=ToInt(Sub);
                    End
                  Else
                  //Get unit size
                  If Sub=UnitSizeStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      UnitSizeX:=ToInt(Sub);
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      UnitSizeY:=ToInt(Sub);
                    End
                  Else
                  //Get unit mapped in map
                  If Sub=UnitMappedStr then
                    Begin
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          StrippedAllSpaceAndUpCase(Sub);
                          If Sub=UnitMappedBlankStr then
                            Begin
                              FillChar(UnitMapped,SizeOf(UnitMapped),0);
                            End
                          Else
                          If Sub=UnitMappedFillStr then
                            Begin
                              FillChar(UnitMapped,SizeOf(UnitMapped),1);
                            End
                          Else
                            Begin
                              Index:=1;
                              Head:=GetHeadingByName(Sub);
                              Sub:=GetFirstComment(St);
                              StrippedAllSpaceAndUpCase(Sub);
                              If Sub=UnitMappedBlankStr then
                                Begin
                                  FillChar(UnitMapped[Head],SizeOf(UnitMapped[Head]),0);
                                End
                              Else
                              If Sub=UnitMappedFillStr then
                                Begin
                                  FillChar(UnitMapped[Head],SizeOf(UnitMapped[Head]),1);
                                End
                              Else
                                Begin
                                  For J:=0 to UnitSizeY do
                                    For I:=0 to UnitSizeX do
                                      Begin
                                        If Sub[Index]='1' then UnitMapped[Head,I,J]:=1
                                        Else UnitMapped[Head,I,J]:=0;
                                        Inc(Index);
                                      End;
                                End;
                            End;
                        End;
                    End
                  Else
                  //Get unit hotkey
                  If Sub=UnitHotkeyStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      //Unit hotkey
                      Hotkey:=MyScreen.GetHotKeyByName(Sub);
                    End
                  Else
                  //Get unit skill
                  If Sub=UnitSkillStr then
                    Begin
                      FillChar(Skill,SizeOf(Skill),Low(TSkill));
                      SkillCount:=Low(TSkillCount);
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          SkillTmp:=GetSkillByName(Sub);
                          If SkillTmp<>NoCmd then
                            Begin
                              Skill[SkillCount].Skill:=SkillTmp;
                              If SkillCount=High(TSkillCount) then Break
                              Else Inc(SkillCount);
                            End;
                        End;
                    End
                  Else
                  //Get unit attribute
                  If Sub=UnitAttributeStr then
                    Begin 
                      BaseAttribute:=[];
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          AttrTmp:=GetAttributeByName(Sub);
                          If AttrTmp<>AttributeNone then
                            Include(BaseAttribute,AttrTmp);
                        End;
                    End
                  Else
                  //Get unit draw level
                  If Sub=UnitDrawLevelStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      UnitDrawLevel:=ToInt(Sub);
                    End
                  Else
                  //Get unit transfer before death
                  If Sub=UnitTransferBeforeDeathStr then
                    Begin
                      //??
                    End
                  Else
                  //Get unit can build list
                  If Sub=UnitCanBuildStr then
                    Begin
                      FillChar(UnitCanGeneration,SizeOf(UnitCanGeneration),Low(TUnit));
                      SkillCount:=Low(TSkillCount);
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          UnitTmp:=GetUnitTyperByName(Sub);
                          If UnitTmp<>NoneUnit then
                            Begin
                              UnitCanGeneration[SkillCount]:=UnitTmp;
                              If SkillCount=High(TSkillCount) then Break
                              Else Inc(SkillCount);
                            End;
                        End;
                    End
                  Else
                  //Get list of spell unit can casting
                  If Sub=UnitCanCastStr then
                    Begin
                      FillChar(SpellCanCast,SizeOf(SpellCanCast),Low(TSpell));
                      SkillCount:=Low(TSkillCount);
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          Spell:=GetSpellByName(Sub);
                          If Spell<>SpellNone then
                            Begin
                              SpellCanCast[SkillCount]:=Spell;
                              If SkillCount=High(TSkillCount) then Break
                              Else Inc(SkillCount);
                            End;
                        End;
                    End
                  Else
                  //Get unit can train
                  If Sub=UnitCanTrainStr then
                    Begin
                      //??
                    End
                  Else
                  //Get unit draw level
                  If Sub=UnitForceStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      UnitForce:=GetForceByName(Sub);
                    End
                  Else
                  If Sub=UnitTimeCostStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      UnitTimeCost:=ToInt(Sub);
                    End
                  Else
                  //Get unit command right mouse click - no target
                  If Sub=UnitCmdRightMouseClickNoTargetStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      RightCommandNoTarget:=GetSkillByName(Sub);
                    End
                  Else
                  //Get unit command right mouse click - target ally
                  If Sub=UnitCmdRightMouseClickTargetAllyStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      RightCommandTargetAlly:=GetSkillByName(Sub);
                    End
                  Else
                  //Get unit command right mouse click - target enemy
                  If Sub=UnitCmdRightMouseClickTargetEnemyStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      RightCommandTargetEnemy:=GetSkillByName(Sub);
                    End
                  Else
                  //Unit like other unit ?
                  If Sub=LikeStr then 
                    Begin
                      Sub:=GetFirstComment(St);
                      UnitTmp:=GetUnitTyperByName(Sub);
                      If UnitTmp<>NoneUnit then
                        UnitsProperty[CC1,UnitType]:=UnitsProperty[CC1,UnitTmp];
                    End
                  Else
                  //End unit setting
                  If Sub=EndSettingForUnitStr then Break
                  Else
                    Begin
                    End;
                End;
          End
        Else
        If Sub=EveryUnitInClansSameClanStr then
          Begin
            //Set all unit property in all clans to like clan CC1
            Sub:=GetFirstComment(St);
            StrippedAllSpaceAndUpCase(Sub);
            CC1:=GetClanByName(Sub);
            For CC2:=Low(TClan) to High(TClan) do
              UnitsProperty[CC2]:=UnitsProperty[CC1];
          End;
      End;
    Close(F);
  End;

PROCEDURE TLOCUnits.LoadItemSetting(FileName : String);
  Var St,Sub    : String;
      ItemIndex : TItem;
      WCT       : TWeaponCanTarget;
      F         : Text;
  Begin
    Assign(F,FileName);
    Reset(F);
    If IOResult<>0 then Exit;
    While Not EoF(F) do
      Begin
        ReadLn(F,St);
        If St[1]=SkipSymbol then Continue;
        Sub:=GetFirstComment(St);
        StrippedAllSpaceAndUpCase(Sub);
        //Like "Item setting : Item name"
        If Sub=ItemSettingStr then
          Begin
            Sub:=GetFirstComment(St);
            StrippedAllSpaceAndUpCase(Sub);
            //Get unit type by name
            ItemIndex:=GetItemByName(Sub);
            With ItemProperty[ItemIndex] do
              While Not EoF(F) do
                Begin
                  ReadLn(F,St);
                  If St[1]=SkipSymbol then Continue;
                  Sub:=GetFirstComment(St);
                  StrippedAllSpaceAndUpCase(Sub);
                  If Sub=ItemNameStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      ItemName:=Sub;
                    End
                  Else
                  If Sub=ItemDamageAddOnStr then 
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      DamageAddOn:=ToInt(Sub);
                    End
                  Else
                  If Sub=ItemMaxRangeStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      MaxRange:=ToInt(Sub);
                    End
                  Else
                  If Sub=ItemMinRangeStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      MinRange:=ToInt(Sub);
                    End
                  Else
                  If Sub=ItemMissileStr then
                    Begin
                      Sub:=GetFirstComment(St);
                      StrippedFirstLastSpace(Sub);
                      WeaponMissile:=GetMissileByName(Sub);
                    End
                  Else
                  If Sub=ItemCanTarget then
                    Begin
                      WeaponCanTarget:=0;
                      While St<>'' do
                        Begin
                          Sub:=GetFirstComment(St);
                          StrippedFirstLastSpace(Sub);
                          WCT:=GetWeaponTargetByName(Sub);
                          SetWeaponProperty(ItemIndex,WCT,True);
                        End;
                    End
                  Else
                  If Sub=ItemToolTipStr then
                    Begin
                    End
                  Else
                  {If Sub= then
                    Begin
                    End
                  Else}
                  If Sub=EndItemSettingStr then Break
                  Else
                    Begin
                    End;
                End;
          End
        Else
          Begin
          End;
      End;
  End;

PROCEDURE TLOCUnits.SetupWeaponItemProperty(Item : TItem;ItemName : NameString;
                                            DamageAddOn : TDamage;
                                            WeaponCanTarget : TWeaponCanTarget;
                                            WeaponMissile : TMissile;
                                            MinAttackRange,MaxAttackRange : TRange);
  Begin
    ItemProperty[Item].ItemClass:=WeaponClass;
    ItemProperty[Item].ItemName:=ItemName;
    ItemProperty[Item].DamageAddOn:=DamageAddOn;
    ItemProperty[Item].WeaponCanTarget:=WeaponCanTarget;
    ItemProperty[Item].WeaponMissile:=WeaponMissile;
    ItemProperty[Item].MinRange:=MinAttackRange;
    ItemProperty[Item].MaxRange:=MaxAttackRange;
  End;

PROCEDURE TLOCUnits.SetupArmorItemProperty(Item : TItem;ItemName : NameString);
  Begin
    ItemProperty[Item].ItemClass:=ArmorClass;
    ItemProperty[Item].ItemName:=ItemName;
  End;

PROCEDURE TLOCUnits.SetupShieldItemProperty(Item : TItem;ItemName : NameString);
  Begin
    ItemProperty[Item].ItemClass:=ShieldClass;
    ItemProperty[Item].ItemName:=ItemName;
  End;

PROCEDURE TLOCUnits.SetupHelmItemProperty(Item : TItem;ItemName : NameString);
  Begin
    ItemProperty[Item].ItemClass:=HelmClass;
    ItemProperty[Item].ItemName:=ItemName;
  End;

PROCEDURE TLOCUnits.SetupBootItemProperty(Item : TItem;ItemName : NameString);
  Begin
    ItemProperty[Item].ItemClass:=BootClass;
    ItemProperty[Item].ItemName:=ItemName;
  End;

PROCEDURE TLOCUnits.SetupDecorateItemProperty(Item : TItem;ItemName : NameString);
  Begin
    ItemProperty[Item].ItemClass:=DecorateClass;
    ItemProperty[Item].ItemName:=ItemName;
  End;

PROCEDURE TLOCUnits.SetWeaponProperty(Item : TItem;CWeaponCanTarget : TWeaponCanTarget;_On : Boolean);
  Begin
    With ItemProperty[Item] do
      Begin
        If _On then
          Begin
            If WeaponCanTarget and CWeaponCanTarget=CWeaponCanTarget then
            Else WeaponCanTarget:=WeaponCanTarget xor CWeaponCanTarget;
          End
        Else
          Begin
            If WeaponCanTarget and CWeaponCanTarget=CWeaponCanTarget then
              WeaponCanTarget:=WeaponCanTarget xor CWeaponCanTarget;
          End
      End;
  End;

FUNCTION  TLOCUnits.TestWeaponProperty(Item : TItem;CWeaponCanTarget : TWeaponCanTarget) : Boolean;
  Begin
    Result:=ItemProperty[Item].WeaponCanTarget and CWeaponCanTarget=CWeaponCanTarget;
  End;

PROCEDURE TLOCUnits.IncreaseFoodLimit(Clan : TClan;Used,Gain,RealGain : FastInt);
  Begin
    Inc(ClanInfo[Clan].FoodUsed,Used);
    Inc(ClanInfo[Clan].FoodAvail,Gain);
    Inc(ClanInfo[Clan].FoodAvailInFuture,RealGain);
    If ClanInfo[Clan].FoodAvail>LimitUnitsPerClan then
      ClanInfo[Clan].FoodLimit:=LimitUnitsPerClan
    Else ClanInfo[Clan].FoodLimit:=ClanInfo[Clan].FoodAvail;
  End;

PROCEDURE TLOCUnits.DecreaseFoodLimit(Clan : TClan;Used,Gain,RealGain : FastInt);
  Begin
    Dec(ClanInfo[Clan].FoodUsed,Used);
    Dec(ClanInfo[Clan].FoodAvail,Gain);
    Dec(ClanInfo[Clan].FoodAvailInFuture,RealGain);
    If ClanInfo[Clan].FoodAvail>LimitUnitsPerClan then
      ClanInfo[Clan].FoodLimit:=LimitUnitsPerClan
    Else ClanInfo[Clan].FoodLimit:=ClanInfo[Clan].FoodAvail;
  End;

PROCEDURE TLOCUnits.RestartGame;
  Begin
    SetAllUnitsToStart;
    RestartMissileData;
    RestartEffectData;
    RestartGrouping;
  End;

PROCEDURE TLOCUnits.RestartGrouping;
  Begin
    FillChar(SaveGroups,SizeOf(SaveGroups),0);
    //SetupGroupSelected(MaxGroup);
  End;

FUNCTION TLOCUnits.GetUnusedUnit : TUnitCount;
  Var Z : TUnitCount;
  Begin
    Result:=0;
    For Z:=Low(Units) to High(Units) do
      If Units[Z]._UnitHitPoint=UnitUnUsedConst then
        Begin
          Result:=Z;
          Exit;
        End;
  End;

FUNCTION TLOCUnits.CrossAt(X,Y : FastInt) : Boolean;
  Begin
    Result:=True;
    NewMissile(X,Y,X,Y,MissileGreenCross);
  End;

PROCEDURE TLOCUnits.ClickAtUnit(Clan : TClan;UnitNum : TUnitCount);
  Begin
    ClanInfo[Clan].UnitClick:=UnitNum;
    ClanInfo[Clan].ClickCount:=0;
  End;

PROCEDURE TLOCUnits.NewUnit(Clan : TClan;Typer : TUnit;CountFood,CountMoney : Boolean);
  Var ResIdx : TResource;
  Begin
    With MyScreen do
      Begin
        //Increcment unit counting for clan of unit
        Inc(TotalUnit);
        Inc(ClanInfo[Clan].UnitsCounting[Typer]);
        Inc(ClanInfo[Clan].AllUnits);
        //Gaia clan no cost for everything !
        If Clan<>Gaia then
          Begin
            If CountFood then
              IncreaseFoodLimit(Clan,UnitsProperty[Clan,Typer].FoodUsed,
                                     UnitsProperty[Clan,Typer].FoodGain,
                                     UnitsProperty[Clan,Typer].FoodGain)
            Else
              IncreaseFoodLimit(Clan,UnitsProperty[Clan,Typer].FoodUsed,
                                     0,
                                     UnitsProperty[Clan,Typer].FoodGain);
            If Not CheatStatus[NoCost] and CountMoney then
              For ResIdx:=Low(TResource) to High(TResource) do
                Dec(ClanInfo[Clan].Resource[ResIdx],
                    UnitsProperty[Clan,Typer].UnitCost[ResIdx]);
          End;
        //Also update something
        Case Typer of
          TrollLumberMill :
            Begin
              UnitAvailable[Clan,Axethrower]:=True;
              UnitAvailable[Clan,Berserker]:=True;
            End;
          OgreMound :
            Begin
              UnitAvailable[Clan,Ogre]:=True;
            End;
          ElvenLumberMill :
            Begin
              UnitAvailable[Clan,Archer]:=True;
              UnitAvailable[Clan,Ranger]:=True;
            End;
          Stables :
            Begin
              UnitAvailable[Clan,Knight]:=True;
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnits.DisposeUnit(Clan : TClan;Typer : TUnit;CountFood : Boolean);
  Var CC : TClan;
  Begin
    With MyScreen do
      Begin
        //Gaia clan no cost for everything !
        If Clan<>Gaia then
          Begin
            If CountFood then
              DecreaseFoodLimit(Clan,UnitsProperty[Clan,Typer].FoodUsed,
                                     UnitsProperty[Clan,Typer].FoodGain,
                                     UnitsProperty[Clan,Typer].FoodGain)
            Else
              DecreaseFoodLimit(Clan,UnitsProperty[Clan,Typer].FoodUsed,
                                     0,
                                     UnitsProperty[Clan,Typer].FoodGain);
          End;
        Dec(ClanInfo[Clan].UnitsCounting[Typer]);
        Dec(ClanInfo[Clan].AllUnits);
        If ClanInfo[Clan].UnitsCounting[Typer]<=0 then
          Case Typer of
            TrollLumberMill :
              Begin
                UnitAvailable[Clan,Axethrower]:=False;
                UnitAvailable[Clan,Berserker]:=False;
              End;
            OgreMound :
              Begin
                UnitAvailable[Clan,Ogre]:=False;
              End;
            ElvenLumberMill :
              Begin
                UnitAvailable[Clan,Archer]:=False;
                UnitAvailable[Clan,Ranger]:=False;
              End;
            Stables :
              Begin
                UnitAvailable[Clan,Knight]:=False;
              End;
          End;
        //AI helper
        If ClanInfo[Clan].AllUnits<=0 then
          Begin
            SendMessage(Format('%s was eliminated !',[ClanInfo[Clan].ClanName]));
            For CC:=Low(TClan) to High(TClan) do
              Begin
                AIUpdateEnemyTarget(CC);
                AIUpdateCommandAvail(CC);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnits.GetBackMoney(UnitNum : TUnitCount);
  Var ResIdx : TResource;
  Begin
    With MyScreen,Units[UnitNum] do
      Begin
        For ResIdx:=Low(TResource) to High(TResource) do
          Inc(ClanInfo[_UnitClan].Resource[ResIdx],
              UnitsProperty[_UnitClan,_UnitTyper].UnitCost[ResIdx]);
      End;
  End;
PROCEDURE TLOCUnits.GetDefaultUnitSkill(UnitNum : TUnitCount);
  Var Idx : TSkillCount;
  Begin
    With Units[UnitNum] do
      Begin
        _UnitSkill:=UnitsProperty[_UnitClan,_UnitTyper].Skill;
        For Idx:=Low(TSkillCount) to High(TSkillCount) do
          If UnitsProperty[_UnitClan,_UnitTyper].SpellCanCast[Idx]<>SpellNone then
            AddSkillTo(_UnitSkill,CmdCastSpell,NoneUnit,
                       UnitsProperty[_UnitClan,_UnitTyper].SpellCanCast[Idx]);
      End;
  End;

PROCEDURE TLOCUnits.ResetDefaultUnitData(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      Begin
        _UnitName:=UnitsProperty[_UnitClan,_UnitTyper].Name;
        _UnitColor:=_UnitClan;
        _UnitHitPoint:=UnitsProperty[_UnitClan,_UnitTyper].HitPoint;
        _UnitSeeRange:=UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
        _UnitHeading:=GetRandomHeading;
        GetDefaultUnitSkill(UnitNum);
        _UnitItems:=UnitsProperty[_UnitClan,_UnitTyper].BaseItem;
        _UnitDamage:=UnitsProperty[_UnitClan,_UnitTyper].BaseDamage;
        _UnitAttribute:=UnitNoAttribute;
        _UnitEffected:=0;
        _UnitFrame:=0;
        _UnitWait:=0;
        _UnitCmd:=NoCmd;
        _UnitNextCmd:=NoCmd;
        _WastedTimeCount:=0;
        _UnitMana:=UnitsProperty[_UnitClan,_UnitTyper].MaxMana div DefaultManaFactor;
        _UnitResource._NormalRes:=UnitsProperty[_UnitClan,_UnitTyper].UnitResource;
        _UnitLevel:=1;
        _UnitXP:=0;
        {$IfDef RandomAbility}
        {$EndIf}
        {$IfDef RandomUnitPosShift}
        If _UnitTyper=ItemStore then
          Begin
            If Random(2)=0 then _ShiftPX:=Random(ShiftRandomItem)
            Else _ShiftPX:=-Random(ShiftRandomItem);
            If Random(2)=0 then _ShiftPY:=Random(ShiftRandomItem)
            Else _ShiftPY:=-Random(ShiftRandomItem);
          End
        Else
          Begin
            If Random(2)=0 then _ShiftPX:=Random(ShiftRandom)
            Else _ShiftPX:=-Random(ShiftRandom);
            If Random(2)=0 then _ShiftPY:=Random(ShiftRandom)
            Else _ShiftPY:=-Random(ShiftRandom);
          End;
        {$EndIf}
        //Setting unit attribute
        SetUnitAttribute(UnitNum,UnitTakeATile,True);
        SetUnitAttribute(UnitNum,UnitOnMapNum,True);//Unit always on map num on start, huh ?
        SetUnitAttribute(UnitNum,UnitSelfControl,True);//Unit always self control, why ?
        If UnitIsInvisible in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
          SetUnitAttribute(UnitNum,UnitInvisible,True);
        _PathUsed:=0;
      End;
  End;

PROCEDURE TLOCUnits.SetUnitToDefault(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;
                                     PosX,PosY : SmallInt;CountMoney : Boolean = True);
  Begin
    With Units[UnitNum] do
      Begin
        NewUnit(Clan,Typer,True,CountMoney);
        FillChar(Units[UnitNum],SizeOf(TUnitData),0);
        _UnitTyper:=Typer;
        _UnitClan:=Clan;
        _UnitPos.X:=PosX;
        _UnitPos.Y:=PosY;
        _UnitDest:=_UnitPos;
        ResetDefaultUnitData(UnitNum);
        //Also rechange some thing in AI data
        AIAddUnitToForce(Clan,UnitsProperty[Clan,Typer].UnitForce,UnitNum);
      End;
  End;

PROCEDURE TLOCUnits.SetUnitToDefault(Name : NameString;UnitNum : TUnitCount;
                                     Clan : TClan;Typer : TUnit;PosX,PosY : SmallInt;CountMoney : Boolean = True);
  Begin
    With Units[UnitNum] do
      Begin
        NewUnit(Clan,Typer,True,CountMoney);
        FillChar(Units[UnitNum],SizeOf(TUnitData),0);
        _UnitTyper:=Typer;
        _UnitClan:=Clan;
        _UnitPos.X:=PosX;
        _UnitPos.Y:=PosY;
        _UnitDest:=_UnitPos;
        ResetDefaultUnitData(UnitNum);
        _UnitName:=Name;
        //Also rechange some thing in AI data
        AIAddUnitToForce(Clan,UnitsProperty[Clan,Typer].UnitForce,UnitNum);
      End;
  End;

PROCEDURE TLOCUnits.SetUnitToDefault(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;Head : THeading;
                                     PosX,PosY : SmallInt;CountMoney : Boolean = True);
  Begin
    With Units[UnitNum] do
      Begin
        NewUnit(Clan,Typer,True,CountMoney);
        FillChar(Units[UnitNum],SizeOf(TUnitData),0);
        _UnitTyper:=Typer;
        _UnitClan:=Clan;
        _UnitPos.X:=PosX;
        _UnitPos.Y:=PosY;
        _UnitDest:=_UnitPos;
        ResetDefaultUnitData(UnitNum);
        _UnitHeading:=Head;
        //Also rechange some thing in AI data
        AIAddUnitToForce(Clan,UnitsProperty[Clan,Typer].UnitForce,UnitNum);
      End;
  End;

PROCEDURE TLOCUnits.SetUnitToDefault(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;
                                     PosX,PosY,SX,SY : SmallInt;CountMoney : Boolean = True);
  Begin
    With Units[UnitNum] do
      Begin
        NewUnit(Clan,Typer,True,CountMoney);
        FillChar(Units[UnitNum],SizeOf(TUnitData),0);
        _UnitTyper:=Typer;
        _UnitClan:=Clan;
        _UnitPos.X:=PosX;
        _UnitPos.Y:=PosY;
        _UnitDest:=_UnitPos;
        ResetDefaultUnitData(UnitNum);
        {$IfDef RandomUnitPosShift}
        _ShiftPX:=SX;
        _ShiftPY:=SY;
        {$EndIf}
        //Also rechange some thing in AI data
        AIAddUnitToForce(Clan,UnitsProperty[Clan,Typer].UnitForce,UnitNum);
      End;
  End;

PROCEDURE TLOCUnits.SetUnitToStart(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;
                                   PosX,PosY : SmallInt;FoodGain : Boolean);
  Begin
    With Units[UnitNum] do
      Begin
        NewUnit(Clan,Typer,FoodGain,True);
        FillChar(Units[UnitNum],SizeOf(TUnitData),0);
        _UnitTyper:=Typer;
        _UnitClan:=Clan;
        _UnitPos.X:=PosX;
        _UnitPos.Y:=PosY;
        _UnitDest:=_UnitPos;
        ResetDefaultUnitData(UnitNum);
        _UnitHitPoint:=HitPointStart;
        _UnitCmd:=CmdStartBuild;
        SetUnitAttribute(UnitNum,UnitSelfControl,False);
        SetUnitAttribute(UnitNum,UnitOnMapNum,False);
        //Also rechange some thing in AI data
        AIAddUnitToForce(Clan,UnitsProperty[Clan,Typer].UnitForce,UnitNum);
        //Increase unit queue counting
        Inc(ClanInfo[Clan].UnitInQueue[Typer]);
      End;
  End;

PROCEDURE TLOCUnits.SetUnitToStart(UnitNum : TUnitCount;Clan : TClan;Typer : TUnit;Head : THeading;
                                   PosX,PosY : SmallInt;FoodGain : Boolean);
  Begin
    With Units[UnitNum] do
      Begin
        NewUnit(Clan,Typer,FoodGain,True);
        FillChar(Units[UnitNum],SizeOf(TUnitData),0);
        _UnitTyper:=Typer;
        _UnitClan:=Clan;
        _UnitPos.X:=PosX;
        _UnitPos.Y:=PosY;
        _UnitDest:=_UnitPos;
        ResetDefaultUnitData(UnitNum);
        _UnitHeading:=Head;
        _UnitHitPoint:=HitPointStart;
        _UnitCmd:=CmdStartBuild;
        SetUnitAttribute(UnitNum,UnitSelfControl,False);
        SetUnitAttribute(UnitNum,UnitOnMapNum,False);
        //Also rechange some thing in AI data
        AIAddUnitToForce(Clan,UnitsProperty[Clan,Typer].UnitForce,UnitNum);
        //Increase unit queue counting
        Inc(ClanInfo[Clan].UnitInQueue[Typer]);
      End;
  End;

PROCEDURE TLOCUnits.SetUnitToUnused(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      Begin
        Dec(TotalUnit);
        _UnitHitPoint:=UnitUnUsedConst;//Unit unused
      End;
  End;

PROCEDURE TLOCUnits.BringUnitToDeath(UnitNum : TUnitCount);
  Var Grouped : Boolean;
      Idx     : TQueueCount;
      Number  : TUnitCount;
  Begin
    //Unit death but not unused, unit used for corpse
    With Units[UnitNum] do
      Begin
        //Set unit back to real type
        {$IfDef SwitchPeonType}
        Case _UnitTyper of
          PeonWithGold    : _UnitTyper:=Peon;
          PeasantWithGold : _UnitTyper:=Peasant;
        End;
        {$EndIf}
        If _UnitHitPoint=0 then Exit;
        //AI helper
        AIClearUnitFromForce(_UnitClan,UnitsProperty[_UnitClan,_UnitTyper].UnitForce,UnitNum);
        If _UnitCmd<>CmdStartBuild then
          DisposeUnit(_UnitClan,_UnitTyper,True)
        Else DisposeUnit(_UnitClan,_UnitTyper,True);
        _UnitHitPoint:=0;//Unit death
        _UnitWait:=0;
        _UnitPrevCmd:=_UnitCmd;
        _UnitPrevFrame:=_UnitFrame;
        _UnitFrame:=FrameUnUsed;
        _UnitCmd:=CmdDead;
        //Dispose all effect link to this unit !
        DisposeUnitEffect(UnitNum);
        //Unit queue ?
        For Idx:=Low(TQueueCount) to High(TQueueCount) do
          If _UnitQueue[Idx]<>0 then
            Begin
              //Clear queue before calling BringToDeath,
              //except case two unit have cycles queue
              Number:=_UnitQueue[Idx];
              _UnitQueue[Idx]:=0;
              //Bring unit to death
              BringUnitToDeath(Number);
              //And set unit to unused for not conflict with other unit
              //Because unit died, not gen a corpse !
              SetUnitToUnused(Number);
            End;
        {$IfDef SafeClearTargetWhenUnitDied}
        //Clear all unit target point to UnitNum
        //That safe code but take a few of time !
        //All unit have target is UnitNum ?
        For Number:=Low(Units) to High(Units) do
          //Unit must alive
          If Units[Number]._UnitHitPoint>0 then
            Begin
              If Units[Number]._UnitTarget=UnitNum then
                Begin
                  Case Units[Number]._UnitCmd of
                    CmdReturnGold,CmdMining,CmdAttackAt,CmdAttack,
                    CmdAttacking,CmdAttackingStand,CmdHoldPosition :
                      Begin
                        Units[Number]._UnitTarget:=0;
                        Units[Number]._UnitDest.X:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX div 2;
                        Units[Number]._UnitDest.Y:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY div 2;
                      End;
                    Else
                      Begin
                        If Not UnitGetNextCommand(Number) then
                          If Not UnitGetPrevCommand(Number) then
                            UnitCommandStop(Number,Units[Number]._UnitClan);
                      End;
                  End;{}
                End;
            End;
        {$EndIf}
        //Unit grouped ?
        Grouped:=_UnitGroup and 128=128;
        ClearUnitInAllGroup(UnitNum);
        If Grouped then
          Begin
            GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
            SetupGroupSelected(MaxGroup);
          End;
      End;
  End;

FUNCTION  TLOCUnits.CheckCreateMoreUnit(Clan : TClan;Typer : TUnit) : FastInt;
  Var ResIdx : TResource;
  Begin
    With MyScreen do
      Begin
        Result:=ROk;
        //Food limit ?
        If Not CheatStatus[NoFoodLimit] and
          (UnitsProperty[Clan,Typer].FoodUsed<>0) and
          (UnitsProperty[Clan,Typer].FoodUsed+ClanInfo[Clan].FoodUsed>ClanInfo[Clan].FoodLimit) then
          Begin
            Result:=RNotEnoughFood;
            Exit;
          End;
        For ResIdx:=Low(TResource) to High(TResource) do
          If UnitsProperty[Clan,Typer].UnitCost[ResIdx]>ClanInfo[Clan].Resource[ResIdx] then
            Begin
              Result:=RNotEnoughResource;
              Exit;
            End;
      End;
  End;

FUNCTION  TLOCUnits.CheckUseSpell(UnitNum : TUnitCount;Spell : TSpell) : FastInt;
  Var ResIdx : TResource;
  Begin
    With Units[UnitNum] do
      Begin
        Result:=ROk;
        For ResIdx:=Low(TResource) to High(TResource) do
          If SpellProperty[Spell].ResourceCost[ResIdx]>ClanInfo[_UnitClan].Resource[ResIdx] then
            Begin
              Result:=RNotEnoughResource;
              Exit;
            End;
        If SpellProperty[Spell].ManaCost>_UnitMana then
          Begin
            Result:=RNotEnoughResource;
            Exit;
          End;
      End;
  End;
  
PROCEDURE TLOCUnits.UnitCostForSpell(UnitNum : TUnitCount;Spell : TSpell);
  Var ResIdx : TResource;
  Begin
    With Units[UnitNum] do
      Begin
        For ResIdx:=Low(TResource) to High(TResource) do
          ClanInfo[_UnitClan].Resource[ResIdx]:=ClanInfo[_UnitClan].Resource[ResIdx]-
                                               SpellProperty[Spell].ResourceCost[ResIdx];
        _UnitMana:=_UnitMana-SpellProperty[Spell].ManaCost;
      End;
  End;

PROCEDURE TLOCUnits.SaveGroup(GroupNum : Byte);
  Var Z : TUnitSelectionCount;
  Begin
    //Check group saving
    If SaveGroups[MaxGroup][Low(TUnitSelectionCount)]<>0 then
      Begin
        UnSelectGroup(MaxGroup);
        //Clear all unit num in this save group
        For Z:=Low(TUnitSelectionCount) to
               High(TUnitSelectionCount) do
          If SaveGroups[GroupNum][Z]<>0 then
            Units[SaveGroups[GroupNum][Z]]._UnitGroup:=0;
        //Save group 10 to group num
        SaveGroups[GroupNum]:=SaveGroups[MaxGroup];
        //Set all unit group in group 10 to group num
        For Z:=Low(TUnitSelectionCount) to
               High(TUnitSelectionCount) do
          If SaveGroups[GroupNum][Z]<>0 then
            Begin
              If Units[SaveGroups[GroupNum][Z]]._UnitGroup<>GroupNum then
                ClearUnitInGroup(SaveGroups[GroupNum][Z],
                                 Units[SaveGroups[GroupNum][Z]]._UnitGroup);
              Units[SaveGroups[GroupNum][Z]]._UnitGroup:=GroupNum;
            End;
        SetSelectGroup(MaxGroup);
        CurrentGroup:=GroupNum;
      End;
  End;

PROCEDURE TLOCUnits.LoadGroup(GroupNum : Byte);
  Begin
    //Check group loading
    If SaveGroups[GroupNum][Low(TUnitSelectionCount)]<>0 then
      Begin
        //Reset unit focus to first unit on group
        UnitFocus:=SaveGroups[GroupNum][Low(TUnitSelectionCount)];
        //Loading group
        CurrentGroup:=GroupNum;
        UnSelectGroup(MaxGroup);
        SaveGroups[MaxGroup]:=SaveGroups[GroupNum];
        SetSelectGroup(MaxGroup);
        //Get group skill
        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
        //Setup button for this group
        SetupGroupSelected(MaxGroup);
      End;
  End;

PROCEDURE TLOCUnits.UnSelectGroup(GroupNum : Byte);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If SaveGroups[GroupNum][Z]<>0 then
        If Units[SaveGroups[GroupNum][Z]]._UnitGroup and 128=128 then
          Begin
            If Units[SaveGroups[GroupNum][Z]]._UnitGroup and MaxGroup=MaxGroup then
              Units[SaveGroups[GroupNum][Z]]._UnitGroup:=0
            Else Units[SaveGroups[GroupNum][Z]]._UnitGroup:=Units[SaveGroups[GroupNum][Z]]._UnitGroup xor 128;
          End;
  End;

PROCEDURE TLOCUnits.SetSelectGroup(GroupNum : Byte);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If SaveGroups[GroupNum][Z]<>0 then
        If Units[SaveGroups[GroupNum][Z]]._UnitGroup=0 then
          Units[SaveGroups[GroupNum][Z]]._UnitGroup:=GroupNum or 128
        Else
          Begin
            If Units[SaveGroups[GroupNum][Z]]._UnitGroup and 128<>128 then
              Units[SaveGroups[GroupNum][Z]]._UnitGroup:=Units[SaveGroups[GroupNum][Z]]._UnitGroup or 128;
          End;
  End;

FUNCTION  TLOCUnits.CountOfSkill(SkillButton : TUnitSkills) : FastInt;
  Var K      : TSkillCount;
      Return : FastInt;
  Begin
    Return:=0;
    For K:=Low(TSkillCount) to High(TSkillCount) do
      If SkillButton[K].Skill<>NoCmd then Inc(Return);
    Result:=Return;
  End;

FUNCTION  TLOCUnits.AddSkillTo(Var SkillButton : TUnitSkills;Skill : TSkill;
                               _UnitToBorn : TUnit;_SpellToCast : TSpell) : Boolean;
  Var K : TSkillCount;
  Begin
    Result:=True;
    For K:=Low(TSkillCount) to High(TSkillCount) do
      If SkillButton[K].Skill=NoCmd then
        Begin
          SkillButton[K].Skill:=Skill;
          Case Skill of
            CmdBuild     : SkillButton[K].UnitToBorn:=_UnitToBorn;
            CmdCastSpell : SkillButton[K].SpellToCast:=_SpellToCast;
          End;
          Exit;
        End;
    Result:=False;
  End;

PROCEDURE TLOCUnits.GetGroupSkill(Var SkillButton : TUnitSkills;GroupNum : Byte;MyClan : TClan;UpdatedButton : Boolean);
  Var Avail                                            : Array[TSkill] of FastInt;
      Z                                                : TUnitSelectionCount;
      {$IfDef ShowGlobalGroupSkill}UnitCount           : TUnitCount;{$EndIf}
      K                                                : TSkillCount;
      S                                                : TSkill;
  Begin
    If NumberUnitInGroup(SaveGroups[GroupNum])=0 then
      Begin
        //Reset wait command because group is none ?
        MyScreen.CmdWaitForSelect:=NoCmd;
        MyScreen.UnitWaitForBuild:=NoneUnit;
        FillChar(SkillButton,SizeOf(SkillButton),NoCmd);
        If UpDatedButton then
          SetupSkillButtons(SkillButton);
        Exit;
      End;
    {$IfDef ShowGlobalGroupSkill}UnitCount:=0;{$EndIf}
    FillChar(Avail,SizeOf(Avail),0);
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If SaveGroups[GroupNum][Z]<>0 then
        Begin
          If ClanInfo[Units[SaveGroups[GroupNum][Z]]._UnitClan].SharedControl[MyClan]<>FullSharedControl then Break;
          If GetUnitAttribute(SaveGroups[GroupNum][Z],UnitSelfControl)=False then
            Begin
              If Units[SaveGroups[GroupNum][Z]]._UnitCmd=CmdStartBuild then
                Inc(Avail[CmdCancelBuilding]);
            End;
          If (CountUnitQueue(SaveGroups[GroupNum][Z])>0) and
             (UnitTestBaseAttribute(SaveGroups[GroupNum][Z],UnitIsTransport)) then
            Inc(Avail[CmdUnLoadUnit]);
          {$IfDef ShowGlobalGroupSkill}Inc(UnitCount);{$EndIf}
          For K:=Low(TSkillCount) to High(TSkillCount) do
            If (Units[SaveGroups[GroupNum][Z]]._UnitSkill[K].Skill<>NoCmd) and
               (Units[SaveGroups[GroupNum][Z]]._UnitSkill[K].Skill<>CmdBuild) and
               (Units[SaveGroups[GroupNum][Z]]._UnitSkill[K].Skill<>CmdCastSpell) then
              Inc(Avail[Units[SaveGroups[GroupNum][Z]]._UnitSkill[K].Skill]);
        End;
    FillChar(SkillButton,SizeOf(SkillButton),NoCmd);
    K:=Low(TSkillCount);
    For S:=Low(TSkill) to High(TSkill) do
      {$IfDef ShowGlobalGroupSkill}
      If (Avail[S]=UnitCount) and (K<=High(TSkillCount)) then
      {$Else ShowAllGroupSkill}
      If (Avail[S]<>0) and (K<=High(TSkillCount)) then
      {$EndIf}
        Begin
          SkillButton[K].Skill:=S;
          SkillButton[K].UnitToBorn:=NoneUnit;
          Inc(K);
        End;
    //Not needed ?
    //Get spell skill with add more button and no updated skill button !
    GetGroupSpellSkill(SkillButton,GroupNum,MyClan,True,False);
    If CountOfSkill(SkillButton)=0 then
      GetGroupBuildSkill(SkillButton,GroupNum,MyClan,False,False)
    Else
      Begin
        If NumberUnitInGroup(SaveGroups[MaxGroup])=1 then
          If CheckUnitIsBuilding(SaveGroups[MaxGroup][Low(TUnitSelectionCount)]) then
            GetGroupBuildSkill(SkillButton,GroupNum,MyClan,True,False);
      End;
    If GetUnitHasTraining(SaveGroups[GroupNum],HumanControl)>0 then
      AddButtonSkillTo(SkillButton,CmdCancelBuilding,NoneUnit,False);
    If UpDatedButton then
      SetupSkillButtons(SkillButton);
  End;

PROCEDURE TLOCUnits.GetGroupBuildSkill(Var SkillButton : TUnitSkills;GroupNum : Byte;MyClan : TClan;Add,UpdatedButton : Boolean);
  Var Avail                                            : Array[TUnit] of FastInt;
      Z                                                : TUnitSelectionCount;
      {$IfDef ShowGlobalGroupSkill}UnitCount           : TUnitCount;{$EndIf}
      K                                                : TSkillCount;
      FoundFree                                        : Boolean;
      S                                                : TUnit;
      FoundBuilding                                    : Boolean;
  Begin
    {$IfDef ShowGlobalGroupSkill}UnitCount:=0;{$EndIf}
    FillChar(Avail,SizeOf(Avail),0);
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If SaveGroups[GroupNum][Z]<>0 then
        With Units[SaveGroups[GroupNum][Z]] do
          Begin
            If ClanInfo[Units[SaveGroups[GroupNum][Z]]._UnitClan].SharedControl[MyClan]<>FullSharedControl then Break;
            If GetUnitAttribute(SaveGroups[GroupNum][Z],UnitSelfControl)=False then Continue;
            {$IfDef ShowGlobalGroupSkill}Inc(UnitCount);{$EndIf}
            For K:=Low(TSkillCount) to High(TSkillCount) do
              If UnitsProperty[_UnitClan,_UnitTyper].UnitCanGeneration[K]<>NoneUnit then
                Inc(Avail[UnitsProperty[_UnitClan,_UnitTyper].UnitCanGeneration[K]]);
          End;
    If Add=False then
      FillChar(SkillButton,SizeOf(SkillButton),NoCmd);
    FoundBuilding:=False;
    For S:=Low(TUnit) to High(TUnit) do
      {$IfDef ShowGlobalGroupSkill}
      If Avail[S]=UnitCount) then
      {$Else ShowAllGroupSkill}
      If Avail[S]<>0 then
      {$EndIf}
        Begin
          FoundFree:=False;
          For K:=Low(TSkillCount) to High(TSkillCount) do
            If SkillButton[K].Skill=NoCmd then
              Begin
                FoundFree:=True;
                Break;
              End;
          If FoundFree then
            Begin
              SkillButton[K].Skill:=CmdBuild;
              SkillButton[K].UnitToBorn:=S;
              If UnitIsBuilding in UnitsProperty[MyClan,S].BaseAttribute then FoundBuilding:=True;
            End
          Else Break
        End;
    //If found building in current skill button, I'm add more cancel button
    If FoundBuilding then
      AddButtonSkillTo(SkillButton,CmdCancel,NoneUnit,False);
    If UpDatedButton then
      SetupSkillButtons(SkillButton);
  End;

PROCEDURE TLOCUnits.GetGroupSpellSkill(Var SkillButton : TUnitSkills;GroupNum : Byte;MyClan : TClan;Add,UpdatedButton : Boolean);
  Var Avail                                            : Array[TSpell] of FastInt;
      Z                                                : TUnitSelectionCount;
      {$IfDef ShowGlobalGroupSkill}UnitCount           : TUnitCount;{$EndIf}
      K                                                : TSkillCount;
      FoundFree                                        : Boolean;
      S                                                : TSpell;
  Begin
    {$IfDef ShowGlobalGroupSkill}UnitCount:=0;{$EndIf}
    FillChar(Avail,SizeOf(Avail),0);
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If SaveGroups[GroupNum][Z]<>0 then
        With Units[SaveGroups[GroupNum][Z]] do
          Begin
            If ClanInfo[Units[SaveGroups[GroupNum][Z]]._UnitClan].SharedControl[MyClan]<>FullSharedControl then Break;
            If GetUnitAttribute(SaveGroups[GroupNum][Z],UnitSelfControl)=False then Continue;
            {$IfDef ShowGlobalGroupSkill}Inc(UnitCount);{$EndIf}
            {For K:=Low(TSkillCount) to High(TSkillCount) do
              If UnitsProperty[_UnitClan,_UnitTyper].SpellCanCast[K]<>SpellNone then
                Inc(Avail[UnitsProperty[_UnitClan,_UnitTyper].SpellCanCast[K]]);}
            For K:=Low(TSkillCount) to High(TSkillCount) do
              If Units[SaveGroups[GroupNum][Z]]._UnitSkill[K].Skill=CmdCastSpell then
                Inc(Avail[Units[SaveGroups[GroupNum][Z]]._UnitSkill[K].SpellToCast]);
          End;
    If Add=False then
      FillChar(SkillButton,SizeOf(SkillButton),NoCmd);
    For S:=Low(TSpell) to High(TSpell) do
      {$IfDef ShowGlobalGroupSkill}
      If Avail[S]=UnitCount) then
      {$Else ShowAllGroupSkill}
      If Avail[S]<>0 then
      {$EndIf}
        Begin
          FoundFree:=False;
          For K:=Low(TSkillCount) to High(TSkillCount) do
            If SkillButton[K].Skill=NoCmd then
              Begin
                FoundFree:=True;
                Break;
              End;
          If FoundFree then
            Begin
              SkillButton[K].Skill:=CmdCastSpell;
              SkillButton[K].SpellToCast:=S;
            End
          Else Break;
        End;
    If UpDatedButton then
      SetupSkillButtons(SkillButton);
  End;

PROCEDURE TLOCUnits.SetGroupSkillTo(Var SkillButton : TUnitSkills;Skill : TSkill;UnitToBorn : TUnit);
  Begin
    FillChar(SkillButton,SizeOf(SkillButton),NoCmd);
    SkillButton[Low(TSkillCount)].Skill:=Skill;
    SkillButton[Low(TSkillCount)].UnitToBorn:=UnitToBorn;
    SetupSkillButtons(SkillButton);
  End;

FUNCTION  TLOCUnits.AddButtonSkillTo(Var SkillButton : TUnitSkills;Skill : TSkill;UnitToBorn : TUnit;UpdateButton : Boolean) : Boolean;
  Var Tmp : TSkillCount;
  Begin
    Result:=False;
    For Tmp:=Low(TSkillCount) to High(TSkillCount) do
      If SkillButton[Tmp].Skill=NoCmd then
        Begin
          SkillButton[Tmp].Skill:=Skill;
          SkillButton[Tmp].UnitToBorn:=UnitToBorn;
          Result:=True;
          Exit;
        End;
    If UpdateButton then
      SetupSkillButtons(SkillButton);
  End;

PROCEDURE TLOCUnits.GetUnitQueue(UnitNum : TUnitCount);
  Begin
    If UnitNum<=0 then
      Begin
        CurrentSavedQueue.FromUnit:=0;
        FillChar(CurrentSavedQueue.Queue,SizeOf(CurrentSavedQueue.Queue),0);
        Exit;
      End;
    With Units[UnitNum] do
      Begin
        If _UnitHitPoint<=0 then Exit;
        CurrentSavedQueue.Queue:=_UnitQueue;
        CurrentSavedQueue.FromUnit:=UnitNum;
      End;
  End;

PROCEDURE TLOCUnits.SetupSkillButtons(SkillButton : TUnitSkills);
  Var Z  : TSkillCount;
      {$IfDef NewInsertButton}
      NB : Integer;
      {$EndIf}
  Begin
    With MyScreen do
      For Z:=Low(TSkillCount) to
             High(TSkillCount) do
        {$IfDef NewInsertButton}
        If SkillButton[Z].Skill<>NoCmd then
          Begin
            NB:=NewButton;
            If NB=0 then Exit;
            With GameButtons[NB] do
              Begin
                Used:=True;
                PosX1:=SkillPosX+SkillButtonPos[Z].X*SkillButtonSizeX;
                PosY1:=SkillPosY+SkillButtonPos[Z].Y*SkillButtonSizeY;
                PosX2:=PosX1+SkillButtonSizeX-1;
                PosY2:=PosY1+SkillButtonSizeY-1;
                Pressed:=False;
                Caption:='';
                HoldKey:=0;
                Case SkillButton[Z].Skill of
                  //Building command ?
                  CmdBuild :
                    Begin
                      HotKey:=UnitsProperty[HumanControl,SkillButton[Z].UnitToBorn].Hotkey;
                      //If unit available : set button to active
                      Active:=UnitAvailable[HumanControl,SkillButton[Z].UnitToBorn];
                    End;
                  //Cast spell command ?
                  CmdCastSpell :
                    Begin
                      HotKey:=SpellProperty[SkillButton[Z].SpellToCast].SpellHotkey;
                      //If spell available : set button to active
                      Active:=SpellAvailable[HumanControl,SkillButton[Z].SpellToCast];
                    End;
                  Else
                    Begin
                      HotKey:=SkillProperty[SkillButton[Z].Skill].SkillHotkey;
                      //If skill available : set button to active
                      Active:=SkillAvailable[HumanControl,SkillButton[Z].Skill];
                    End;
                End;
                Typer:=ButtonUnitCommand;
                UnitSkill:=SkillButton[Z];
                AllowRightClick:=False;
              End
          End;
        {$Else}
        With GameButtons[CUnitCommandStart+Byte(Z)] do
          If SkillButton[Z].Skill<>NoCmd then
            Begin
              Used:=True;
              PosX1:=SkillPosX+SkillButtonPos[Z].X*SkillButtonSizeX;
              PosY1:=SkillPosY+SkillButtonPos[Z].Y*SkillButtonSizeY;
              PosX2:=PosX1+SkillButtonSizeX-1;
              PosY2:=PosY1+SkillButtonSizeY-1;
              Pressed:=False;
              Caption:='';
              HoldKey:=0;
              Case SkillButton[Z].Skill of
                //Building command ?
                CmdBuild :
                  Begin
                    HotKey:=UnitsProperty[HumanControl,SkillButton[Z].UnitToBorn].Hotkey;
                    //If unit available : set button to active
                    Active:=UnitAvailable[HumanControl,SkillButton[Z].UnitToBorn];
                  End;
                //Cast spell command ?
                CmdCastSpell :
                  Begin
                    HotKey:=SpellProperty[SkillButton[Z].SpellToCast].SpellHotkey;
                    //If spell available : set button to active
                    Active:=SpellAvailable[HumanControl,SkillButton[Z].SpellToCast];
                  End;
                Else
                  Begin
                    HotKey:=SkillProperty[SkillButton[Z].Skill].SkillHotkey;
                    //If skill available : set button to active
                    Active:=SkillAvailable[HumanControl,SkillButton[Z].Skill];
                  End;
              End;
              Typer:=ButtonUnitCommand;
              UnitSkill:=SkillButton[Z];
              AllowRightClick:=False;
            End
          Else
            Begin
              Used:=False;
            End;
        {$EndIf}
  End;

PROCEDURE TLOCUnits.SetupUnitItemButtons(UnitNum : TUnitCount);
  Var Z  : TItemCount;
      {$IfDef NewInsertButton}
      NB : Integer;
      {$EndIf}
  Begin
    {$IfNDef NewInsertButton}
    If UnitNum<=0 then
      Begin
        For Z:=Low(TItemCount) to
               High(TItemCount) do
          MyScreen.GameButtons[CUnitItemStart+Byte(Z)].Used:=False;
        Exit;
      End;
    {$EndIf}
    With MyScreen do
      Begin
        For Z:=Item1 to Item9 do
          {$IfDef NewInsertButton}
          If UnitsProperty[Units[UnitNum]._UnitClan,
                           Units[UnitNum]._UnitTyper].ItemSlotAvail[Z] then
            Begin
              NB:=NewButton;
              If NB=0 then Exit;
              With GameButtons[NB] do
                Begin
                  Used:=True;
                  PosX1:=ItemPosX+UnitItemPos[Z].X*ItemButtonSizeX;
                  PosY1:=ItemPosY+UnitItemPos[Z].Y*ItemButtonSizeY;
                  PosX2:=PosX1+ItemButtonSizeX-1;
                  PosY2:=PosY1+ItemButtonSizeY-1;
                  Pressed:=False;
                  Caption:='';
                  HoldKey:=0;
                  HotKey:=0;
                  Typer:=ButtonUnitItem;
                  UnitItem:=Units[UnitNum]._UnitItems[Z];
                  ItemSlot:=Z;
                  //Active:=UnitItem.Typer<>ItemNone;
                  //Active:=True;
                  Active:=ClanInfo[HumanControl].SharedControl[Units[UnitNum]._UnitClan]=FullSharedControl;
                  AllowRightClick:=True;
                End;
              End;
          {$Else}
          With GameButtons[CUnitItemStart+Byte(Z)] do
            If UnitsProperty[Units[UnitNum]._UnitClan,
                             Units[UnitNum]._UnitTyper].ItemSlotAvail[Z] then
              Begin
                Used:=True;
                PosX1:=ItemPosX+UnitItemPos[Z].X*ItemButtonSizeX;
                PosY1:=ItemPosY+UnitItemPos[Z].Y*ItemButtonSizeY;
                PosX2:=PosX1+ItemButtonSizeX-1;
                PosY2:=PosY1+ItemButtonSizeY-1;
                Pressed:=False;
                Caption:='';
                HoldKey:=0;
                HotKey:=0;
                Typer:=ButtonUnitItem;
                UnitItem:=Units[UnitNum]._UnitItems[Z];
                ItemSlot:=Z;
                //Active:=UnitItem.Typer<>ItemNone;
                //Active:=True;
                Active:=ClanInfo[HumanControl].SharedControl[Units[UnitNum]._UnitClan]=FullSharedControl;
                AllowRightClick:=True;
              End
            Else
              Begin
                Used:=False;
              End;
          {$EndIf}
        //Set up item weapon, armor, shield...
        For Z:=WeaponItem to DecorateItem do
          {$IfDef NewInsertButton}
          If UnitsProperty[Units[UnitNum]._UnitClan,
                           Units[UnitNum]._UnitTyper].ItemSlotAvail[Z] then
            Begin
              NB:=NewButton;
              If NB=0 then Exit;
              With GameButtons[NB] do
                Begin
                  Used:=True;
                  PosX1:=ItemPosX+(UnitItemPos2[Z].X+3)*ItemButtonSizeX+UnitItemPos2X[Z].X+4;
                  PosY1:=ItemPosY+UnitItemPos2[Z].Y*ItemButtonSizeY+UnitItemPos2X[Z].Y;
                  PosX2:=PosX1+ItemButtonSizeX-1;
                  PosY2:=PosY1+ItemButtonSizeY-1;
                  Pressed:=False;
                  Caption:='';
                  HoldKey:=0;
                  HotKey:=0;
                  Typer:=ButtonUnitItem;
                  UnitItem:=Units[UnitNum]._UnitItems[Z];
                  ItemSlot:=Z;
                  //Active:=UnitItem.Typer<>ItemNone;
                  //Active:=True;
                  Active:=ClanInfo[HumanControl].SharedControl[Units[UnitNum]._UnitClan]=FullSharedControl;
                  AllowRightClick:=True;
                End
              End;
          {$Else}
          With GameButtons[CUnitItemStart+Byte(Z)] do
            If UnitsProperty[Units[UnitNum]._UnitClan,
                             Units[UnitNum]._UnitTyper].ItemSlotAvail[Z] then
              Begin
                Used:=True;
                PosX1:=ItemPosX+(UnitItemPos2[Z].X+3)*ItemButtonSizeX+UnitItemPos2X[Z].X+4;
                PosY1:=ItemPosY+UnitItemPos2[Z].Y*ItemButtonSizeY+UnitItemPos2X[Z].Y;
                PosX2:=PosX1+ItemButtonSizeX-1;
                PosY2:=PosY1+ItemButtonSizeY-1;
                Pressed:=False;
                Caption:='';
                HoldKey:=0;
                HotKey:=0;
                Typer:=ButtonUnitItem;
                UnitItem:=Units[UnitNum]._UnitItems[Z];
                ItemSlot:=Z;
                //Active:=UnitItem.Typer<>ItemNone;
                //Active:=True;
                Active:=ClanInfo[HumanControl].SharedControl[Units[UnitNum]._UnitClan]=FullSharedControl;
                AllowRightClick:=True;
              End
            Else
              Begin
                Used:=False;
              End;
          {$EndIf}
      End;
  End;

PROCEDURE TLOCUnits.SetupUnitSelectedButtons(Group : TGroup);
  Var Z  : TUnitSelectionCount;
      {$IfDef NewInsertButton}
      NB : Integer;
      {$EndIf}
  Begin
    With MyScreen do
      For Z:=Low(TUnitSelectionCount) to
             High(TUnitSelectionCount) do
        {$IfDef NewInsertButton}
        If Group[Z]<>0 then
          Begin
            NB:=NewButton;
            If NB=0 then Exit;
            With GameButtons[NB] do
              Begin
                Used:=True;
                PosX1:=SelectionPosX1+UnitButtonPos[Z].X*SelectionButtonSizeX;
                PosY1:=SelectionPosY1+UnitButtonPos[Z].Y*SelectionButtonSizeY;
                PosX2:=PosX1+SelectionButtonSizeX-1;
                PosY2:=PosY1+SelectionButtonSizeY-1;
                Pressed:=False;
                Caption:='';
                HoldKey:=0;
                HotKey:=0;
                Typer:=ButtonUnitSelected;
                UnitNumRef:=Group[Z];
                Active:=True;
                AllowRightClick:=False;
              End;
          End;
        {$Else}
        With GameButtons[CUnitSelectedStart+Byte(Z)] do
          If Group[Z]<>0 then
            Begin
              Used:=True;
              PosX1:=SelectionPosX1+UnitButtonPos[Z].X*SelectionButtonSizeX;
              PosY1:=SelectionPosY1+UnitButtonPos[Z].Y*SelectionButtonSizeY;
              PosX2:=PosX1+SelectionButtonSizeX-1;
              PosY2:=PosY1+SelectionButtonSizeY-1;
              Pressed:=False;
              Caption:='';
              HoldKey:=0;
              HotKey:=0;
              Typer:=ButtonUnitSelected;
              UnitNumRef:=Group[Z];
              Active:=True;
              AllowRightClick:=False;
            End
          Else
            Begin
              Used:=False;
            End;
        {$EndIf}
  End;

PROCEDURE TLOCUnits.SetupUnitQueueButtons(_UnitQueue : TUnitQueue;Mini : Boolean);
  Var Z  : TQueueCount;
      {$IfDef NewInsertButton}
      NB : Integer;
      {$EndIf}
  Begin
    With MyScreen do
      For Z:=Low(TQueueCount) to High(TQueueCount) do
        {$IfDef NewInsertButton}
        If _UnitQueue[Z]<>0 then
          Begin
            NB:=NewButton;
            If NB=0 then Exit;
            With GameButtons[NB] do
              Begin
                Used:=True;
                PosX1:=QueuePosX+UnitQueuePos[Z].X*QueueButtonSizeX;
                PosY1:=QueuePosY+UnitQueuePos[Z].Y*QueueButtonSizeY;
                PosX2:=PosX1+QueueButtonSizeX-1;
                PosY2:=PosY1+QueueButtonSizeY-1;
                Pressed:=False;
                Caption:='';
                HoldKey:=0;
                HotKey:=0;
                Typer:=ButtonUnitQueue;
                UnitNumRef:=_UnitQueue[Z];
                //Active:=True;
                Active:=ClanInfo[HumanControl].SharedControl[Units[_UnitQueue[Z]]._UnitClan]=FullSharedControl;
              End
            End;
        {$Else}
        With GameButtons[CUnitQueueStart+Byte(Z)] do
          If _UnitQueue[Z]<>0 then
            Begin
              Used:=True;
              PosX1:=QueuePosX+UnitQueuePos[Z].X*QueueButtonSizeX;
              PosY1:=QueuePosY+UnitQueuePos[Z].Y*QueueButtonSizeY;
              PosX2:=PosX1+QueueButtonSizeX-1;
              PosY2:=PosY1+QueueButtonSizeY-1;
              Pressed:=False;
              Caption:='';
              HoldKey:=0;
              HotKey:=0;
              Typer:=ButtonUnitQueue;
              UnitNumRef:=_UnitQueue[Z];
              //Active:=True;
              Active:=ClanInfo[HumanControl].SharedControl[Units[_UnitQueue[Z]]._UnitClan]=FullSharedControl;
            End
          Else
            Begin
              Used:=False;
            End;
        {$EndIf}
  End;

PROCEDURE TLOCUnits.SetupGroupSelected(GroupNum : Byte);
  Begin
    //Clear command waiting
    If UnitFocus<>OldUnitFocus then
      Begin
        MyScreen.CmdWaitForSelect:=NoCmd;
        OldUnitFocus:=UnitFocus;
      End;
    GetGroupSkill(CurrentSkillButton,GroupNum,HumanControl,True);
    //Setup button for group
    {$IfDef NewInsertButton}
    MyScreen.RestartButtons;
    MyScreen.SetupButtonMenu;
    MyScreen.SetupButtonPause;
    MyScreen.SetupButtonDiplomacy;
    {$EndIf}
    SetupSkillButtons(CurrentSkillButton);
    SetupUnitSelectedButtons(SaveGroups[GroupNum]);
    SetupUnitItemButtons(UnitFocus);
    If NumberUnitInGroup(SaveGroups[GroupNum])=1 then
      Begin
        GetUnitQueue(UnitFocus);
        SetupUnitQueueButtons(CurrentSavedQueue.Queue,True)
      End
    Else
      Begin
        GetUnitQueue(0);
        SetupUnitQueueButtons(CurrentSavedQueue.Queue,True)
      End;
  End;

FUNCTION  TLOCUnits.UnitInGroup(UnitNum : TUnitCount;Group : TGroup) : Boolean;
  Var Z : TUnitSelectionCount;
  Begin
    Result:=True;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]=UnitNum then Exit;
    Result:=False;
  End;

FUNCTION  TLOCUnits.NumberUnitInGroup(Group : TGroup) : Byte;
  Var Z     : TUnitSelectionCount;
      Count : Byte;
  Begin
    Count:=0;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then Inc(Count);
    Result:=Count;
  End;

FUNCTION  TLOCUnits.FindUnitOnClan(Group : TGroup;Clan : TClan) : Boolean;
  Var Z : TUnitSelectionCount;
  Begin
    Result:=False;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        If Units[Group[Z]]._UnitClan=Clan then
          Begin
            Result:=True;
            Exit;
          End;
  End;

FUNCTION  TLOCUnits.AddUnitToGroup(UnitNum : TUnitCount;Var Group : TGroup) : Boolean;
  Var Z : TUnitSelectionCount;
  Begin
    Result:=True;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]=0 then
        Begin
          Group[Z]:=UnitNum;
          Exit;
        End;
    Result:=False;
  End;

PROCEDURE TLOCUnits.SelectUnitNum(UnitNum : TUnitCount);
  Begin
    If UnitFocus=UnitNum then
      Begin
        UnSelectGroup(MaxGroup);
        FillChar(SaveGroups[MaxGroup],SizeOf(SaveGroups[MaxGroup]),0);
        SaveGroups[MaxGroup][1]:=UnitNum;
        SetSelectGroup(MaxGroup);
        CurrentGroup:=0;
      End
    Else UnitFocus:=UnitNum;
    GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
    SetupGroupSelected(MaxGroup);
  End;

PROCEDURE TLOCUnits.UnSelectUnitNum(UnitNum : TUnitCount);
  Begin
    UnSelectGroup(MaxGroup);
    ClearUnitInGroup(UnitNum,MaxGroup);
    SetSelectGroup(MaxGroup);
    If UnitFocus=UnitNum then
      UnitFocus:=SaveGroups[MaxGroup][Low(TUnitSelectionCount)];
    GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
    SetupGroupSelected(MaxGroup);
    CurrentGroup:=0;
  End;

PROCEDURE TLOCUnits.SelectOnlyUnit(UnitNum : TUnitCount);
  Begin
    UnitFocus:=UnitNum;
    CurrentGroup:=0;
    //Clear current selected group !
    UnSelectGroup(MaxGroup);
    //Clear group info
    FillChar(SaveGroups[MaxGroup],SizeOf(SaveGroups[MaxGroup]),0);
    //Add unit to group !
    SaveGroups[MaxGroup][1]:=UnitNum;
    SetSelectGroup(MaxGroup);
    //Set unit selected !
    SetSelectGroup(MaxGroup);
    //Get group skill
    GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
    //Set up unit button for group
    SetupGroupSelected(MaxGroup);
  End;

PROCEDURE TLOCUnits.ClearUnitInGroup(UnitNum : TUnitCount;GroupNum : Byte);
  Var Z : TUnitSelectionCount;
  Begin
    If GroupNum and 128=128 then GroupNum:=GroupNum xor 128;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If SaveGroups[GroupNum][Z]=UnitNum then
        Begin
          SaveGroups[GroupNum][Z]:=0;
          ArrangeGroup(GroupNum);
          Exit;
        End;
  End;

PROCEDURE TLOCUnits.ClearUnitInGroup(UnitNum : TUnitCount;Var Group : TGroup);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]=UnitNum then
        Begin
          Group[Z]:=0;
          ArrangeGroup(Group);
          Exit;
        End;
  End;

PROCEDURE TLOCUnits.ClearUnitInAllGroup(UnitNum : TUnitCount;Update : Boolean = True);
  Begin
    If Units[UnitNum]._UnitGroup<>0 then
      Begin
        //Clear unit in unit group
        ClearUnitInGroup(UnitNum,Units[UnitNum]._UnitGroup);
        //Clear unit in current selection group
        //If Units[UnitNum]._UnitGroup<>MaxGroup then ClearUnitInGroup(UnitNum,MaxGroup);
        If Units[UnitNum]._UnitGroup and 128=128 then
          Begin
            ClearUnitInGroup(UnitNum,MaxGroup);
            If UnitFocus=UnitNum then
              Begin
                UnitFocus:=SaveGroups[MaxGroup][Low(TUnitSelectionCount)];
                //SetupUnitItemButtons(UnitFocus);
              End;
            If UpDate then
              SetupGroupSelected(MaxGroup);
          End;
        //Unit group assign to zero
        Units[UnitNum]._UnitGroup:=0;
      End;
  End;

PROCEDURE TLOCUnits.ArrangeGroup(GroupNum : Byte);
  Var Z,K : TUnitSelectionCount;
  Begin
    //Because I know group loss only one unit then I do this way
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount)-1 do
      If SaveGroups[GroupNum][Z]=0 then
        Begin
          For K:=Z to High(TUnitSelectionCount)-1 do
            SaveGroups[GroupNum][K]:=SaveGroups[GroupNum][K+1];
          SaveGroups[GroupNum][High(TUnitSelectionCount)]:=0;
          Exit;
        End;
  End;

PROCEDURE TLOCUnits.ArrangeGroup(Var Group : TGroup);
  Var Z,K : TUnitSelectionCount;
  Begin
    //Because I know group loss only one unit then I do this way
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount)-1 do
      If Group[Z]=0 then
        Begin
          For K:=Z to High(TUnitSelectionCount)-1 do Group[K]:=Group[K+1];
          Group[High(TUnitSelectionCount)]:=0;
          Exit;
        End;
  End;

PROCEDURE TLOCUnits.ArrangeUnitQueue(UnitNum : TUnitCount);
  Var Z,K : TQueueCount;
  Begin
    With Units[UnitNum] do
      For Z:=Low(TQueueCount) to High(TQueueCount)-1 do
        If _UnitQueue[Z]=0 then
          Begin
            For K:=Z to High(TQueueCount)-1 do _UnitQueue[K]:=_UnitQueue[K+1];
            _UnitQueue[High(TQueueCount)]:=0;
            Exit;
          End;
  End;

FUNCTION  TLOCUnits.UnitCanAddToGroup(UnitNum : TUnitCount;Clan : TClan;Group : TGroup;CheckGroup : Boolean = True) : Boolean;
  Var FoundBuilding,MeIsBuilding : Boolean;
  Begin
    Result:=False;
    With Units[UnitNum] do
      Begin
        If _UnitHitPoint<=0 then Exit;
        If _UnitClan<>Clan then Exit;
        If CheckGroup then
          If UnitInGroup(UnitNum,Group) then Exit;
        If Group[Low(TUnitSelectionCount)]<>0 then
          Begin
            With Units[Group[Low(TUnitSelectionCount)]] do
              FoundBuilding:=UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute;
            MeIsBuilding:=UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute;
            If (Not MeIsBuilding and FoundBuilding) or
               (MeIsBuilding and Not FoundBuilding) then Exit;
          End;
      End;
    Result:=True;
  End;

PROCEDURE TLOCUnits.SendCurrentGroupToDeath;
  Begin
    While SaveGroups[MaxGroup][Low(TUnitSelectionCount)]<>0 do
      BringUnitToDeath(SaveGroups[MaxGroup][Low(TUnitSelectionCount)]);
  End;

FUNCTION  TLOCUnits.UnitStandOver(UnitNum : TUnitCount;X,Y : FastInt) : Boolean;
  Begin
    With Units[UnitNum] do
      Result:=(_UnitPos.X<=X) and (_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX>=X) and
              (_UnitPos.Y>=Y) and (_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY>=Y);
  End;

FUNCTION  TLOCUnits.CheckUnitIsBuilding(UnitClan : TClan;UnitTyper : TUnit) : Boolean;
  Begin
    Result:=UnitIsBuilding in UnitsProperty[UnitClan,UnitTyper].BaseAttribute;
  End;

FUNCTION  TLOCUnits.CheckUnitIsBuilding(UnitNum : TUnitCount) : Boolean;
  Begin
    With Units[UnitNum] do
      Result:=UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute;
  End;

FUNCTION  TLOCUnits.CheckBaseAttribute(UnitNum : TUnitCount;Base : TBaseUnitAttribute) : Boolean;
  Begin
    With Units[UnitNum] do
      Result:=Base in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute;
  End;

FUNCTION  TLOCUnits.CheckSpellAttribute(Spell : TSpell;Attribute : TSpellAttribute) : Boolean;
  Begin
    Result:=SpellProperty[Spell].SpellAttribute and Attribute=Attribute;
  End;

FUNCTION  TLOCUnits.CheckMissileAttribute(Missile : TMissile;Attribute : TMissileAttribute) : Boolean;
  Begin
    Result:=MissileProperty[Missile].MissileAttribute and Attribute=Attribute;
  End;

FUNCTION  TLOCUnits.CheckUnitSkill(UnitNum : TUnitCount;SkillTest : TSkill) : Boolean;
  Var Index : TSkillCount;
  Begin
    Result:=True;
    With Units[UnitNum] do
      For Index:=Low(TSkillCount) to High(TSkillCount) do
        If _UnitSkill[Index].Skill=SkillTest then Exit;
    Result:=False;
  End;

FUNCTION  TLOCUnits.CheckUnitHasSpell(UnitNum : TUnitCount;SpellTest : TSpell) : Boolean;
  Var Index : TSkillCount;
  Begin
    Result:=True;
    With Units[UnitNum],UnitsProperty[_UnitClan,_UnitTyper] do
      For Index:=Low(TSkillCount) to High(TSkillCount) do
        If (_UnitSkill[Index].Skill=CmdCastSpell) and
           (_UnitSkill[Index].SpellToCast=SpellTest) then Exit;
    Result:=False;
  End;

FUNCTION  TLOCUnits.CheckUnitCanGen(UnitNum : TUnitCount;UnitToBorn : TUnit) : Boolean;
  Var K : TSkillCount;
  Begin
    Result:=False;
    With Units[UnitNum] do
      Begin
        For K:=Low(TSkillCount) to High(TSkillCount) do
          If UnitsProperty[_UnitClan,_UnitTyper].UnitCanGeneration[K]=UnitToBorn then
            Begin
              Result:=True;
              Exit;
            End;
      End;
  End;

FUNCTION  TLOCUnits.GetUnitHaveSkill(Group : TGroup;Clan : TClan;Skill : TSkill) : TUnitCount;
  Var Z : TUnitSelectionCount;
      K : TSkillCount;
  Begin
    Result:=-1;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        With Units[Group[Z]] do
          Begin
            If _UnitClan<>Clan then Continue;
            For K:=Low(TSkillCount) to High(TSkillCount) do
              If _UnitSkill[K].Skill=Skill then
                Begin
                  Result:=Group[Z];
                  Exit;
                End;
          End;
  End;

FUNCTION  TLOCUnits.GetUnitCanBuild(Group : TGroup;Clan : TClan;Typer : TUnit) : TUnitCount;
  Var Z : TUnitSelectionCount;
      K : TSkillCount;
  Begin
    Result:=-1;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        With Units[Group[Z]] do
          Begin
            If _UnitClan<>Clan then Continue;
            If _UnitCmd=CmdBuild then Continue;
            For K:=Low(TSkillCount) to High(TSkillCount) do
              If UnitsProperty[_UnitClan,_UnitTyper].UnitCanGeneration[K]=Typer then
                Begin
                  Result:=Group[Z];
                  Exit;
                End;
          End;
  End;

FUNCTION  TLOCUnits.GetUnitHasTraining(Group : TGroup;Clan : TClan) : TUnitCount;
  Var Z   : TUnitSelectionCount;
      Idx : TQueueCount;
  Begin
    Result:=-1;
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        With Units[Group[Z]] do
          Begin
            If _UnitClan<>Clan then Exit;
            For Idx:=Low(TQueueCount) to High(TQueueCount) do
              If _UnitQueue[Idx]<>0 then
                If Units[_UnitQueue[Idx]]._UnitCmd=CmdStartBuild then
                  Begin
                    Result:=Group[Z];
                    Exit;
                  End;
          End;
  End;
  
FUNCTION  TLOCUnits.CheckClanControlUnit(UnitNum : TUnitCount;FromClan : TClan) : Boolean;
  Begin
    Result:=ClanInfo[Units[UnitNum]._UnitClan].SharedControl[FromClan]=FullSharedControl;
  End;

FUNCTION  TLOCUnits.CheckClanCanBuild(Clan : TClan;UnitTyper : TUnit) : Boolean;
  Begin
    Result:=UnitAvailable[Clan,UnitTyper];
  End;

FUNCTION  TLOCUnits.FindingFreeWorker : TUnitCount;
  Var Z : Integer;
  Begin
    Result:=-1;
    For Z:=CurHumanWorkerUnit+1 to High(Units) do
      If (Units[Z]._UnitHitPoint>UnitDead) and
         (Units[Z]._UnitClan=HumanControl) and
         (UnitsProperty[Units[Z]._UnitClan,
                        Units[Z]._UnitTyper].UnitForce=WorkerForce) and
         (Units[Z]._UnitCmd=NoCmd) then
        Begin
          Result:=Z;
          CurHumanWorkerUnit:=Z;
          Exit;
        End;
    For Z:=Low(Units) to CurHumanWorkerUnit do
      If (Units[Z]._UnitHitPoint>UnitDead) and
         (Units[Z]._UnitClan=HumanControl) and
         (UnitsProperty[Units[Z]._UnitClan,
                        Units[Z]._UnitTyper].UnitForce=WorkerForce) and
         (Units[Z]._UnitCmd=NoCmd) then
        Begin
          Result:=Z;
          CurHumanWorkerUnit:=Z;
          Exit;
        End;
  End;

FUNCTION  TLOCUnits.FindingFreeTroop : TUnitCount;
  Var Z : Integer;
  Begin
    Result:=-1;
    For Z:=CurHumanTroopUnit+1 to High(Units) do
      If (Units[Z]._UnitHitPoint>UnitDead) and
         (Units[Z]._UnitClan=HumanControl) and
         (UnitsProperty[Units[Z]._UnitClan,
                        Units[Z]._UnitTyper].UnitForce in
          [AttackForce,DefenceForce,FindingForce]) and
         (Units[Z]._UnitCmd=NoCmd) then
        Begin
          Result:=Z;
          CurHumanTroopUnit:=Z;
          Exit;
        End;
    For Z:=Low(Units) to CurHumanTroopUnit do
      If (Units[Z]._UnitHitPoint>UnitDead) and
         (Units[Z]._UnitClan=HumanControl) and
         (UnitsProperty[Units[Z]._UnitClan,
                        Units[Z]._UnitTyper].UnitForce in
          [AttackForce,DefenceForce,FindingForce]) and
         (Units[Z]._UnitCmd=NoCmd) then
        Begin
          Result:=Z;
          CurHumanTroopUnit:=Z;
          Exit;
        End;
  End;

FUNCTION  TLOCUnits.FindingFreeBuilding : TUnitCount;
  Var Z : Integer;
  Begin
    Result:=-1;
    For Z:=CurHumanBuildingUnit+1 to High(Units) do
      If (Units[Z]._UnitHitPoint>UnitDead) and
         (Units[Z]._UnitClan=HumanControl) and
         (UnitsProperty[Units[Z]._UnitClan,
                        Units[Z]._UnitTyper].UnitForce in
          [BuildingTownForce,BuildingTrainingForce]) and
         (Units[Z]._UnitCmd=NoCmd) then
        Begin
          Result:=Z;
          CurHumanBuildingUnit:=Z;
          Exit;
        End;
    For Z:=Low(Units) to CurHumanBuildingUnit do
      If (Units[Z]._UnitHitPoint>UnitDead) and
         (Units[Z]._UnitClan=HumanControl) and
         (UnitsProperty[Units[Z]._UnitClan,
                        Units[Z]._UnitTyper].UnitForce in
          [BuildingTownForce,BuildingTrainingForce]) and
         (Units[Z]._UnitCmd=NoCmd) then
        Begin
          Result:=Z;
          CurHumanBuildingUnit:=Z;
          Exit;
        End;
  End;

PROCEDURE TLOCUnits.SetGroupCommand(Group : TGroup;Cmd : TSkill;X,Y : FastInt;FromClan : TClan);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        SetUnitCommand(Group[Z],Cmd,X,Y,FromClan);
  End;

PROCEDURE TLOCUnits.SetGroupCommand(Group : TGroup;Cmd : TSkill;Target : TUnitCount;FromClan : TClan);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        SetUnitCommand(Group[Z],Cmd,Target,FromClan);
  End;

PROCEDURE TLOCUnits.SetGroupCommand(Group : TGroup;UnitToBorn : TUnit;FromClan : TClan);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        UnitCommandTrain(Group[Z],UnitToBorn,FromClan);
  End;

PROCEDURE TLOCUnits.SetGroupCommand(Group : TGroup;Spell : TSpell;Target : TUnitCount;FromClan : TClan);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        UnitCommandCastSpell(Group[Z],Target,Spell,FromClan);
  End;

PROCEDURE TLOCUnits.SetGroupCommand(Group : TGroup;Spell : TSpell;X,Y : FastInt;FromClan : TClan);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        UnitCommandCastSpell(Group[Z],X,Y,Spell,FromClan);
  End;

PROCEDURE TLOCUnits.SetGroupCommand(Group : TGroup;Spell : TSpell;FromClan : TClan);
  Var Z : TUnitSelectionCount;
  Begin
    For Z:=Low(TUnitSelectionCount) to
           High(TUnitSelectionCount) do
      If Group[Z]<>0 then
        UnitCommandDirectCastSpell(Group[Z],Spell,FromClan);
  End;

PROCEDURE TLOCUnits.SetUnitCommand(UnitNum : TUnitCount;Cmd : TSkill;X,Y : FastInt;FromClan : TClan);
  Begin
    Case Cmd of
      CmdStop :
        Begin
          UnitCommandStop(UnitNum,FromClan);
        End;
      CmdHoldPosition :
        Begin
          UnitCommandHoldPosition(UnitNum,FromClan);
        End;
      CmdMove :
        Begin
          UnitCommandMove(UnitNum,X,Y,FromClan);
        End;
      CmdPatrol :
        Begin
          UnitCommandPatrol(UnitNum,X,Y,FromClan);
        End;
      CmdAttack,CmdAttackAt :
        Begin
          UnitCommandAttackAt(UnitNum,X,Y,FromClan);
        End;
      CmdRallyPoint  :
        Begin
          UnitCommandRallyPoint(UnitNum,X,Y);
        End;
      CmdUnLoadUnit :
        Begin
          UnitCommandUnLoadAllUnit(UnitNum,X,Y,FromClan);
        End;
    End;
  End;

PROCEDURE TLOCUnits.SetUnitCommand(UnitNum : TUnitCount;Cmd : TSkill;Target : TUnitCount;FromClan : TClan);
  Var Temp : TUnitSetCmdReturn;
  Begin
    //Safe code
    {$IfDef SafeCode}
    If Target<=0 then Exit;
    {$EndIf}
    Case Cmd of
      CmdMove :
        Begin
          //UnitCommandMove(UnitNum,Units[Target]._UnitPos.X,Units[Target]._UnitPos.Y,FromClan);
          UnitCommandFollow(UnitNum,Target,FromClan);
        End;
      CmdPatrol :
        Begin
          UnitCommandPatrol(UnitNum,Units[Target]._UnitPos.X,Units[Target]._UnitPos.Y,FromClan);
        End;
      CmdAttack :
        Begin
          If FromClan=HumanControl then
            Begin
              Temp:=TestUnitAttackRange(UnitNum,Target);
              If Temp=TargetTooNear then
                Begin
                  MyScreen.SendMessage(CmdMessage[Temp]);
                  Exit;
                End;
            End;
          UnitCommandAttack(UnitNum,Target,FromClan);
        End;
      CmdHarvest :
        Begin
          UnitCommandHarvest(UnitNum,Target,FromClan);
        End;
      CmdRallyPoint :
        Begin
          UnitCommandRallyPoint(UnitNum,Units[Target]._UnitPos.X,Units[Target]._UnitPos.Y);
        End;
      CmdUnLoadUnit :
        Begin
          UnitCommandUnLoadAllUnit(UnitNum,Units[Target]._UnitPos.X,Units[Target]._UnitPos.Y,FromClan);
        End;
    End;
  End;

PROCEDURE TLOCUnits.SetUnitAttribute(UnitNum : TUnitCount;UnitAtt : TUnitAttribute;_On : Boolean);
  Begin
    With Units[UnitNum] do
      Begin
        If _On then
          Begin
            If _UnitAttribute and UnitAtt=UnitAtt then
            Else _UnitAttribute:=_UnitAttribute xor UnitAtt;
          End
        Else
          Begin
            If _UnitAttribute and UnitAtt=UnitAtt then
              _UnitAttribute:=_UnitAttribute xor UnitAtt;
          End
      End;
  End;

FUNCTION  TLOCUnits.GetUnitAttribute(UnitNum : TUnitCount;UnitAtt : TUnitAttribute): Boolean;
  Begin
    With Units[UnitNum] do
      Result:=_UnitAttribute and UnitAtt=UnitAtt;
  End;

PROCEDURE TLOCUnits.UnitClearQueue(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      FillChar(_UnitQueue,SizeOf(_UnitQueue),0);
  End;

FUNCTION  TLOCUnits.CountUnitQueue(UnitNum : TUnitCount) : TUnitCount;
  Var QueIdx : TQueueCount;
      Return : TUnitCount;
  Begin
    Return:=0;
    With Units[UnitNum] do
      For QueIdx:=Low(TQueueCount) to High(TQueueCount) do
        If _UnitQueue[QueIdx]<>0 then Inc(Return);
    Result:=Return;
  End;

FUNCTION  TLOCUnits.UnitTestBaseAttribute(UnitNum : TUnitCount;Attr : TBaseUnitAttribute) : Boolean;
  Begin
    With Units[UnitNum] do
      Result:=Attr in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute;
  End;

FUNCTION  TLOCUnits.UnitHaveAResource(UnitNum : TUnitCount) : Boolean;
  Var ResIdx : TResource;
  Begin
    With Units[UnitNum] do
      For ResIdx:=Low(TResource) to High(TResource) do
        If _UnitResource._NormalRes[ResIdx]>0 then
          Begin
            Result:=True;
            Exit;
          End;
    Result:=False;
  End;

FUNCTION  TLOCUnits.UnitCanAttack(UnitNum,UnitDest : TUnitCount) : TUnitSetCmdReturn;
  Var TempBaseAtt : TBaseAttribute;
  Begin
    Result:=IDontKnow;
    With Units[UnitNum] do
      Begin
        If _UnitItems[WeaponItem].Typer=ItemNone then
          Begin
            Result:=UnitNotHasWeapon;
            Exit;
          End;
        TempBaseAtt:=UnitsProperty[Units[UnitDest]._UnitClan,Units[UnitDest]._UnitTyper].BaseAttribute;
        If UnitInvulnerable in TempBaseAtt then
          Begin
            Result:=CantAttackInvulnerableTarget;
            Exit;
          End;
        If (UnitIsLandUnit in TempBaseAtt) and
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetLandUnit)=False) then
          Begin
            Result:=CantAttackLandUnit;
            Exit;
          End;
        If (UnitIsAirUnit in TempBaseAtt) and
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetAirUnit)=False) then
          Begin
            Result:=CantAttackAirUnit;
            Exit;
          End;
        If (UnitIsMechanic in TempBaseAtt) and
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetMechanicUnit)=False) then
          Begin
            Result:=CantAttackMechanicUnit;
            Exit;
          End;
        If (UnitIsBuilding in TempBaseAtt) and
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetBuilding)=False) then
          Begin
            Result:=CantAttackBuilding;
            Exit;
          End;
        If (UnitIsUndergroundUnit in TempBaseAtt) and
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetUnderGround)=False) then
          Begin
            Result:=CantAttackUnderground;
            Exit;
          End;
        If (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetLandUnit) and
            (UnitIsLandUnit in TempBaseAtt)) or
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetAirUnit) and
            (UnitIsAirUnit in TempBaseAtt)) or
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetBuilding) and
            (UnitIsBuilding in TempBaseAtt)) or
           (TestWeaponProperty(_UnitItems[WeaponItem].Typer,WeaponCanTargetUnderGround) and
            (UnitIsUndergroundUnit in TempBaseAtt)) then
          Begin
            Result:=CanAttack;
            Exit;
          End;
      End;
  End;

FUNCTION  TLOCUnits.RangeBetweenUnit(UnitNum,UnitDest : TUnitCount) : TRange;
  Var SX1,SX2,SY1,SY2,DX1,DX2,DY1,DY2 : FastInt;
  Begin
    With Units[UnitNum] do
      Begin
        SX1:=_UnitPos.X;
        SY1:=_UnitPos.Y;
        SX2:=SX1+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
        SY2:=SY1+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
      End;
    With Units[UnitDest] do
      Begin
        DX1:=_UnitPos.X;
        DY1:=_UnitPos.Y;
        DX2:=DX1+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
        DY2:=DY1+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
      End;
    If (DX2<=SX1) or ((DX2>=SX1) and (DX2<=SX2)) then DX1:=DX2;
    If (DY2<=SY1) or ((DY2>=SY1) and (DY2<=SY2)) then DY1:=DY2;
    If DX1<SX1 then DX2:=SX1-DX1 Else
    If DX1>SX2 then DX2:=DX1-SX2 Else DX2:=0;
    If DY1<SY1 then DY2:=SY1-DY1 Else
    If DY1>SY2 then DY2:=DY1-SY2 Else DY2:=0;
    If DX2<DY2 then DX2:=DY2;
    Dec(DX2);
    //This a little cheating, if two unit have same position, rountine return -1,
    //that value maybe except because min CmdAttack range of unit then I return 0 for range
    //between them.
    If DX2<0 then Result:=0
    Else Result:=DX2;
  End;

FUNCTION  TLOCUnits.RangeBetweenUnit(UnitNum,DestX,DestY : TUnitCount) : TRange;
  Var SX1,SX2,SY1,SY2,DX1,DX2,DY1,DY2 : FastInt;
  Begin
    With Units[UnitNum] do
      Begin
        SX1:=_UnitPos.X;
        SY1:=_UnitPos.Y;
        SX2:=SX1+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
        SY2:=SY1+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
      End;
    DX1:=DestX;
    DY1:=DestY;
    DX2:=DestX;
    DY2:=DestY;
    If (DX2<=SX1) or ((DX2>=SX1) and (DX2<=SX2)) then DX1:=DX2;
    If (DY2<=SY1) or ((DY2>=SY1) and (DY2<=SY2)) then DY1:=DY2;
    If DX1<SX1 then DX2:=SX1-DX1 Else
    If DX1>SX2 then DX2:=DX1-SX2 Else DX2:=0;
    If DY1<SY1 then DY2:=SY1-DY1 Else
    If DY1>SY2 then DY2:=DY1-SY2 Else DY2:=0;
    If DX2<DY2 then DX2:=DY2;
    Dec(DX2);
    //This a little cheating, if two unit have same position, rountine return -1,
    //that value maybe except because min CmdAttack range of unit then I return 0 for range
    //between them.
    If DX2<0 then Result:=0
    Else Result:=DX2;
  End;

FUNCTION  TLOCUnits.TestUnitCastSpellRange(UnitNum,UnitDest : TUnitCount;Spell : TSpell) : TUnitSetCmdReturn;
  Var Distance : TRange;
  Begin
    Distance:=RangeBetweenUnit(UnitNum,UnitDest);
    With Units[UnitNum],UnitsProperty[_UnitClan,_UnitTyper] do
      Begin
        If _UnitItems[WeaponItem].Typer=ItemNone then Result:=UnitNotHasWeapon Else
        If Distance<SpellProperty[Spell].MinRange then Result:=TargetTooNear Else
        If Distance>SpellProperty[Spell].MaxRange then Result:=TargetTooFar
        Else Result:=CanAttack;
      End;
  End;

FUNCTION  TLOCUnits.TestUnitCastSpellRange(UnitNum : TUnitCount;DestX,DestY : FastInt;Spell : TSpell) : TUnitSetCmdReturn;
  Var Distance : TRange;
  Begin
    Distance:=RangeBetweenUnit(UnitNum,DestX,DestY);
    With Units[UnitNum],UnitsProperty[_UnitClan,_UnitTyper] do
      Begin
        If Distance<SpellProperty[Spell].MinRange then Result:=TargetTooNear Else
        If Distance>SpellProperty[Spell].MaxRange then Result:=TargetTooFar
        Else Result:=CanAttack;
      End;
  End;

FUNCTION  TLOCUnits.TestUnitAttackRange(UnitNum,UnitDest : TUnitCount) : TUnitSetCmdReturn;
  Var Distance : TRange;
  Begin
    Distance:=RangeBetweenUnit(UnitNum,UnitDest);
    With Units[UnitNum],UnitsProperty[_UnitClan,_UnitTyper] do
      Begin
        If Distance<ItemProperty[_UnitItems[WeaponItem].Typer].MinRange then Result:=TargetTooNear Else
        If Distance>ItemProperty[_UnitItems[WeaponItem].Typer].MaxRange then Result:=TargetTooFar
        Else Result:=CanAttack;
      End;
  End;

FUNCTION  TLOCUnits.TestUnitAttackRange(UnitNum,DestX,DestY : TUnitCount) : TUnitSetCmdReturn;
  Var Distance : TRange;
  Begin
    Distance:=RangeBetweenUnit(UnitNum,DestX,DestY);
    With Units[UnitNum],UnitsProperty[_UnitClan,_UnitTyper] do
      Begin
        If Distance<ItemProperty[_UnitItems[WeaponItem].Typer].MinRange then Result:=TargetTooNear Else
        If Distance>ItemProperty[_UnitItems[WeaponItem].Typer].MaxRange then Result:=TargetTooFar
        Else Result:=CanAttack;
      End;
  End;

FUNCTION  TLOCUnits.UnitFindReturnGoldTarget(UnitNum : TUnitCount) : Boolean;
  Var Z,Best   : TUnitCount;
      Long,Tmp : TRange;
  Begin
    //Quite search, for testing !
    Best:=0;
    Long:=High(FastInt);
    With Units[UnitNum] do
      Begin
        For Z:=Low(Units) to High(Units) do
          //Unit in same clan with source unit ?
          If (_UnitClan=Units[Z]._UnitClan) and
             //Unit is a deposit target ? :>
             (UnitIsDeposit in UnitsProperty[Units[Z]._UnitClan,Units[Z]._UnitTyper].BaseAttribute) and
             //Unit alive ?
             (Units[Z]._UnitHitPoint>0) and
             //Unit no under construction ?
             (Units[Z]._UnitCmd<>CmdStartBuild) and
             //Unit on map num ?
             GetUnitAttribute(UnitNum,UnitOnMapNum) then
            Begin
              Tmp:=RangeBetweenUnit(UnitNum,Z);
              If Tmp<=Long then
                Begin
                  Long:=Tmp;
                  Best:=Z;
                End;
            End;
        _ReturnGoldTarget:=Best;
        Result:=Best<>0;
      End;
  End;

PROCEDURE TLOCUnits.SetUnitReturnGold(UnitNum : TUnitCount);
  Var ResIdx : TResource;
  Begin
    With Units[UnitNum] do
      Begin
        {$IfDef SwitchPeonType}
        Case _UnitTyper of
          PeonWithGold    : _UnitTyper:=Peon;
          PeasantWithGold : _UnitTyper:=Peasant;
        End;
        {$EndIf}
        For ResIdx:=Low(TResource) to High(TResource) do
          Begin
            Inc(ClanInfo[_UnitClan].Resource[ResIdx],_UnitResource._NormalRes[ResIdx]);
            _UnitResource._NormalRes[ResIdx]:=0;
          End;
      End;
  End;

PROCEDURE TLOCUnits.SetUnitHarvest(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      Begin
        Inc(_UnitResource._NormalRes[ResGold],DefaultGoldCollect);
        If Units[_MineTarget]._UnitTyper=GoldMine then
          Dec(Units[_MineTarget]._UnitResource._GoldAmound,DefaultGoldCollect)
        Else Dec(Units[_MineTarget]._UnitResource._NormalRes[ResGold],DefaultGoldCollect);
      End;
  End;

FUNCTION  TLOCUnits.GetHeading(X1,Y1,X2,Y2 : FastInt) : THeading;
  Var I,J : FastInt;
      H   : THeading;
  Begin
    If X1<X2 then I:=+1 Else
    If X1>X2 then I:=-1 Else I:=0;
    If Y1<Y2 then J:=+1 Else
    If Y1>Y2 then J:=-1 Else J:=0;
    For H:=Low(THeading) to High(THeading) do
      If (Direction[H].X=I) and (Direction[H].Y=J) then
        Begin
          Result:=H;
          Exit;
        End;
    Result:=Low(THeading);
  End;

PROCEDURE TLOCUnits.UnitHit(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      Begin
        {$IfDef SafeCode}
        If _UnitTarget<=0 then Exit;
        {$EndIf}
        //Unit target not in mapnum ?
        If Not GetUnitAttribute(_UnitTarget,UnitOnMapNum) then
          Begin
            If Not UnitGetPrevCommand(UnitNum) then
              If Not UnitGetNextCommand(UnitNum) then
                UnitResetCommand(UnitNum);
            Exit;
          End;
        If Units[_UnitTarget]._UnitHitPoint>0 then
          Begin
            DecUnitHitPoint(_UnitTarget,RealUnitAttackDamage(UnitNum));
            {$IfDef AttackWhenAlert}
            SetUnitAttribute(_UnitTarget,UnitHasATarget,True);
            {$EndIf}
          End
        Else
          Begin
            //Increase unit XP
            _UnitXP:=_UnitXP+UnitsProperty[Units[_UnitTarget]._UnitClan,Units[_UnitTarget]._UnitTyper].Point;
            _UnitTarget:=0;
          End;
      End;
  End;

FUNCTION  TLOCUnits.UnitCountItem(UnitNum : TUnitCount) : FastInt;
  Var SlotIdx : TItemCount;
  Begin
    Result:=0;
    For SlotIdx:=Low(TItemCount) to High(TItemCount) do
      If Units[UnitNum]._UnitItems[SlotIdx].Typer<>ItemNone then Inc(Result);
  End;

FUNCTION  TLOCUnits.SlotSupportItem(UnitNum : TUnitCount;Slot : TItemCount;Item : TItem) : Boolean;
  Begin
    Result:=UnitsProperty[Units[UnitNum]._UnitClan,Units[UnitNum]._UnitTyper].ItemSlotAvail[Slot] and
            ((SlotSupport[Slot]=OtherClass) or
             (SlotSupport[Slot]=ItemProperty[Item].ItemClass));
  End;

PROCEDURE TLOCUnits.UnitClearSlot(UnitNum : TUnitCount;Slot : TItemCount);
  Begin
    Units[UnitNum]._UnitItems[Slot].Typer:=ItemNone;
    Units[UnitNum]._UnitItems[Slot].Number:=0;
  End;

FUNCTION  TLOCUnits.UnitAddSlot(UnitNum : TUnitCount;Slot : TItemCount;Item : TUnitItem) : Boolean;
  Begin
    With Units[UnitNum] do
      If _UnitItems[Slot].Typer=Item.Typer then
        Begin
          _UnitItems[Slot].Number:=_UnitItems[Slot].Number+Item.Number;
          Result:=True;
        End
      Else
      If _UnitItems[Slot].Typer=ItemNone then
        Begin
          _UnitItems[Slot]:=Item;
          Result:=True;
        End
      Else Result:=False;
  End;

FUNCTION  TLOCUnits.UnitSwitchItem(UnitNum : TUnitCount;Slot1,Slot2 : TItemCount) : Boolean;
  Var Tmp : TUnitItem;
  Begin
    With Units[UnitNum] do
      Begin
        If (Not SlotSupportItem(UnitNum,Slot1,_UnitItems[Slot2].Typer)) or
           (Not SlotSupportItem(UnitNum,Slot2,_UnitItems[Slot1].Typer)) then
          Begin
            Result:=False;
            Exit;
          End;
        Result:=True;
        Tmp:=_UnitItems[Slot1];
        _UnitItems[Slot1]:=_UnitItems[Slot2];
        _UnitItems[Slot2]:=Tmp;
      End;
  End;

FUNCTION  TLOCUnits.UnitSwitchItem(UnitNum : TUnitCount;Slot : TItemCount;Var Item : TUnitItem) : Boolean;
  Var Tmp : TUnitItem;
  Begin
    With Units[UnitNum] do
      Begin
        If Not SlotSupportItem(UnitNum,Slot,Item.Typer) then
          Begin
            Result:=False;
            Exit;
          End;
        Result:=True;
        Tmp:=_UnitItems[Slot];
        _UnitItems[Slot]:=Item;
        Item:=Tmp;
      End;
  End;
  
FUNCTION  TLOCUnits.GiveUnitItem(UnitNum : TUnitCount;Slot : TItemCount;Item : TUnitItem) : Boolean;
  Begin
    With Units[UnitNum] do
      Begin
        If Not SlotSupportItem(UnitNum,Slot,Item.Typer) then
          Begin
            Result:=False;
            Exit;
          End;
        Result:=True;
        _UnitItems[Slot]:=Item;
      End;
  End;
  
FUNCTION  TLOCUnits.GetUnitFreeItemSlot(UnitNum : TUnitCount;Var Slot : TItemCount) : Boolean;
  Var SlotIdx : TItemCount;
  Begin
    Result:=True;
    For SlotIdx:=Low(TItemCount) to High(TItemCount) do
      If Units[UnitNum]._UnitItems[SlotIdx].Typer=ItemNone then
        Begin
          Slot:=SlotIdx;
          Exit;
        End;
    Result:=False;
  End;
  
FUNCTION  TLOCUnits.GetUnitFitItemSlot(UnitNum : TUnitCount;Item : TUnitItem;Var Slot : TItemCount) : Boolean;
  Var SlotIdx : TItemCount;
  Begin
    Result:=True;
    For SlotIdx:=Low(TItemCount) to High(TItemCount) do
      If (Units[UnitNum]._UnitItems[SlotIdx].Typer=ItemNone) and
         SlotSupportItem(UnitNum,SlotIdx,Item.Typer) then
        Begin
          Slot:=SlotIdx;
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCUnits.GetUnitUsedItemSlot(UnitNum : TUnitCount;Var Slot : TItemCount) : Boolean;
  Var SlotIdx : TItemCount;
  Begin
    Result:=True;
    For SlotIdx:=Low(TItemCount) to High(TItemCount) do
      If Units[UnitNum]._UnitItems[SlotIdx].Typer<>ItemNone then
        Begin
          Slot:=SlotIdx;
          Exit;
        End;
    Result:=False;
  End;

FUNCTION  TLOCUnits.UnitExchangeItem(UnitNum,UnitTarget : TUnitCount;Slot : TItemCount) : Boolean;
  Var SlotIdx : TItemCount;
  Begin
    Result:=False;
    //Unit slot is empty ?
    If Units[UnitNum]._UnitItems[Slot].Typer=ItemNone then Exit;
    //Unit target full item slot ? Or not free slot fit for item ?
    If Not GetUnitFitItemSlot(UnitTarget,Units[UnitNum]._UnitItems[Slot],SlotIdx) then Exit;
    //Exchange unit item
    UnitAddSlot(UnitTarget,SlotIdx,Units[UnitNum]._UnitItems[Slot]);
    UnitClearSlot(UnitNum,Slot);
  End;

PROCEDURE TLOCUnits.DecUnitHitPoint(UnitNum : TUnitCount;Damage : TDamage);
  Begin
    With Units[UnitNum] do
      Begin
        If Damage>=_UnitHitPoint then
          Begin
            BringUnitToDeath(UnitNum)
          End
        Else Dec(_UnitHitPoint,Damage);
      End;
  End;

FUNCTION  TLOCUnits.RealUnitSeeRange(UnitNum : TUnitCount) : TRange;
  Begin
    With Units[UnitNum] do
      Begin
        //Result:=UnitsProperty[_UnitClan,_UnitTyper].SeeRange;
        Result:=_UnitSeeRange;
      End;
  End;

FUNCTION  TLOCUnits.RealUnitAttackMinRange(UnitNum : TUnitCount) : TRange;
  Begin
    With Units[UnitNum] do
      Begin
        Result:=ItemProperty[_UnitItems[WeaponItem].Typer].MinRange;
      End;
  End;

FUNCTION  TLOCUnits.RealUnitAttackMaxRange(UnitNum : TUnitCount) : TRange;
  Begin
    With Units[UnitNum] do
      Begin
        Result:=ItemProperty[_UnitItems[WeaponItem].Typer].MaxRange;
      End;
  End;

FUNCTION  TLOCUnits.RealUnitAttackDamage(UnitNum : TUnitCount) : TDamage;
  Begin
    With Units[UnitNum] do
      Begin
        If _UnitItems[WeaponItem].Typer=ItemNone then Result:=0
        Else Result:=_UnitDamage+ItemProperty[_UnitItems[WeaponItem].Typer].DamageAddOn;
      End;
  End;

FUNCTION  TLOCUnits.RealUnitMovementSpeed(UnitNum : TUnitCount) : FastInt;
  Begin
    With Units[UnitNum] do
      Begin
        If GetUnitAttribute(UnitNum,UnitHaste) then
          Result:=DefaultUnitSpeedDecrease ShL 1
        Else Result:=DefaultUnitSpeedDecrease;
      End;
  End;

FUNCTION  TLOCUnits.RealUnitAttackingSpeed(UnitNum : TUnitCount) : FastInt;
  Begin
    With Units[UnitNum] do
      Begin
        If GetUnitAttribute(UnitNum,UnitHaste) then
          Result:=DefaultUnitSpeedDecrease ShL 1
        Else Result:=DefaultUnitSpeedDecrease;
      End;
  End;

FUNCTION  TLOCUnits.UnitCheckTargetClose(UnitNum : TUnitCount) : Boolean;
  Begin
    Result:=True;
    With Units[UnitNum] do
      //If unit close to target, then toggle to wasted time state
      If RangeBetweenUnit(UnitNum,_UnitTarget)<=DefaultTargetClose then
        Begin
          //Must reset wasted time first because may be wasted time count crash my operation
          _WastedTimeCount:=0;
          UnitCommandWastedTime(UnitNum);
          Exit;
        End;
    Result:=False;
  End;

PROCEDURE TLOCUnits.UnitResetCommand(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      Begin
        _UnitCmd:=NoCmd;
        _UnitNextCmd:=NoCmd;
        _UnitPrevCmd:=NoCmd;
        _UnitTarget:=0;
        _UnitNextTarget:=0;
        _PathUsed:=0;
        _UnitDest:=_UnitPos;
        //_PatrolDest:=_UnitPos;
        _UnitWait:=0;
        _UnitFrame:=FrameUnUsed;
        _WastedTimeCount:=0;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandMove(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for valid unit skill
    If CheckUnitSkill(UnitNum,CmdMove)=False then Exit;
    With Units[UnitNum] do
      Begin
        //Unit no need to back to last command then I reset UnitPrevCommand
        _UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdMove;
              _UnitNextCmd:=NoCmd;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
            End;
          CmdMove :
            Begin
              _UnitNextCmd:=NoCmd;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
            End
          Else
            Begin
              _UnitNextCmd:=CmdMove;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandFollow(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for valid unit skill
    If CheckUnitSkill(UnitNum,CmdMove)=False then Exit;
    With Units[UnitNum] do
      Begin
        //Unit no need to back to last command then I reset UnitPrevCommand
        _UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitTarget:=Target;
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdFollow;
              _UnitNextCmd:=NoCmd;
              _UnitDest:=Units[_UnitTarget]._UnitPos;
            End;
          CmdFollow :
            Begin
              _UnitTarget:=Target;
              _UnitNextCmd:=NoCmd;
              _UnitDest:=Units[_UnitTarget]._UnitPos;
            End
          Else
            Begin
              _UnitNextCmd:=CmdFollow;
              _UnitNextTarget:=Target;
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandPatrol(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for valid unit skill
    If CheckUnitSkill(UnitNum,CmdPatrol)=False then Exit;
    With Units[UnitNum] do
      Begin
        //Unit no need to back to last command then I reset UnitPrevCommand
        _UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdPatrol;
              _UnitNextCmd:=NoCmd;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
              _PatrolStart:=_UnitPos;
              _PatrolDest:=_UnitDest;
            End;
          CmdMove :
            Begin
              _UnitCmd:=CmdPatrol;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
              _PatrolStart:=_UnitPos;
              _PatrolDest:=_UnitDest;
            End
          Else
            Begin
              _UnitNextCmd:=CmdPatrol;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
              _PatrolStart:=_UnitPos;
              _PatrolDest:=_UnitDest;
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandStop(UnitNum : TUnitCount;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for valid unit skill
    If CheckUnitSkill(UnitNum,CmdStop)=False then Exit;
    With Units[UnitNum] do
      Begin
        //Unit no need to back to last command then I reset UnitPrevCommand
        _UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitCmd:=NoCmd;
              _UnitNextCmd:=NoCmd;
              _UnitNextTarget:=0;
              _UnitTarget:=0;
              //_UnitFrame:=0;
            End
          Else
            Begin
              _UnitNextCmd:=CmdStop;
              _UnitNextTarget:=0;
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandHoldPosition(UnitNum : TUnitCount;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for valid unit skill
    If CheckUnitSkill(UnitNum,CmdHoldPosition)=False then Exit;
    With Units[UnitNum] do
      Begin
        //Unit no need to back to last command then I reset UnitPrevCommand
        _UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdHoldPosition;
              _UnitNextCmd:=NoCmd;
              _UnitNextTarget:=0;
              _UnitTarget:=0;
            End
          Else
            Begin
              _UnitNextCmd:=CmdHoldPosition;
              _UnitNextTarget:=0;
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandAttack(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
  Var Temp : TUnitSetCmdReturn;
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for valid unit skill
    //Unit no CmdAttack skill
    If CheckUnitSkill(UnitNum,CmdAttack)=False then Exit;
    //Unit can't CmdAttack it self
    If Target=UnitNum then Exit;
    //Unit can't CmdAttack this target
    Temp:=UnitCanAttack(UnitNum,Target);
    If Temp<>CanAttack then
      Begin
        If FromClan=HumanControl then
          MyScreen.SendMessage(CmdMessage[Temp]);
        Exit;
      End;
    With Units[UnitNum] do
      Begin
        //Unit need to back to last command then I no reset UnitPrevCommand
        //_UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdAttack;
              _UnitNextCmd:=NoCmd;
              _UnitPrevCmd:=NoCmd;
              _UnitTarget:=Target;
            End
          Else
            Begin
              _UnitNextCmd:=CmdAttack;
              _UnitNextTarget:=Target;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandAttackingStand(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
  Var Temp : TUnitSetCmdReturn;
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Unit can't CmdAttack it self
    If Target=UnitNum then Exit;
    //Unit can't CmdAttack this target
    Temp:=UnitCanAttack(UnitNum,Target);
    If Temp<>CanAttack then
      Begin
        //  Because unit auto set this command then
        //never this message can be shown
        {If FromClan=HumanControl then
          MyScreen.SendMessage(CmdMessage[Temp]);{}
        Exit;
      End;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdAttackingStand;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
            End
          Else
            Begin
              _UnitNextCmd:=CmdAttackingStand;
              _UnitNextTarget:=Target;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandAttackAt(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for valid unit skill
    If CheckUnitSkill(UnitNum,CmdAttack)=False then Exit;
    With Units[UnitNum] do
      Begin
        //Unit need to back to last command then I not reset UnitPrevCommand
        //_UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdAttackAt;
              _UnitNextCmd:=NoCmd;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
              _PatrolDest:=_UnitDest;
            End;
          CmdAttackAt :
            Begin
              _UnitNextCmd:=NoCmd;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
              _PatrolDest:=_UnitDest;
            End
          Else
            Begin
              _UnitNextCmd:=CmdAttackAt;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
              _PatrolDest:=_UnitDest;
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandAttackNoCheck(UnitNum : TUnitCount;Target : TUnitCount);
  Begin
    //Unit can't CmdAttack it self
    If Target=UnitNum then Exit;
    With Units[UnitNum] do
      Begin
        _UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdAttack;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
            End
          Else
            Begin
              _UnitNextCmd:=CmdAttack;
              _UnitNextTarget:=Target;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandPatrolAttack(UnitNum : TUnitCount;Target : TUnitCount);
  Var Temp : TUnitSetCmdReturn;
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid unit skill maybe unit no had CmdAttack skill
    If CheckUnitSkill(UnitNum,CmdAttack)=False then Exit;
    //Unit can't CmdAttack it self
    If Target=UnitNum then Exit;
    //Unit can't CmdAttack this target
    Temp:=UnitCanAttack(UnitNum,Target);
    If Temp<>CanAttack then
      Begin
        //If FromClan=HumanControl then
        //  MyScreen.SendMessage(CmdMessage[Temp]);
        Exit;
      End;
    With Units[UnitNum] do
      Begin
        _UnitFrame:=FrameUnUsed;
        _UnitPrevCmd:=_UnitCmd;
        _UnitCmd:=CmdAttack;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitTarget:=Target;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandPatrolAttackNoCheck(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
  Begin
    //Unit can't CmdAttack it self
    If Target=UnitNum then Exit;
    With Units[UnitNum] do
      Begin
        _UnitFrame:=FrameUnUsed;
        _UnitPrevCmd:=_UnitCmd;
        _UnitCmd:=CmdAttack;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitTarget:=Target;
      End;
  End;

PROCEDURE TLOCUnits.UnitSwapPatrolTarget(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      Begin
        _UnitDest:=_PatrolStart;
        _PatrolStart:=_PatrolDest;
        _PatrolDest:=_UnitDest;
        //_UnitDest:=_PatrolDest;
        //_PatrolDest:=_UnitPos;
        _PathUsed:=0;
        //If _UnitPos and CmdPatrol _UnitDest be the same, unit don't need to CmdPatrol
        If (_UnitPos.X=_UnitDest.X) and (_UnitPos.Y=_UnitDest.Y) then _UnitCmd:=NoCmd;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandWastedTime(UnitNum : TUnitCount);
  Begin
    With Units[UnitNum] do
      Begin
        Inc(_WastedTimeCount);
        {$IfDef DontStopWhenHarvest}
        Case _UnitCmd of
          CmdHarvest :
            Begin
              //With command harvest, wasted time count can be increase
              If _WastedTimeCount>=WastedTimeLimit*2 then
                Begin
                  UnitResetCommand(UnitNum);
                  Exit;
                End;
            End;
          Else
            Begin
        {$EndIf}
              If _WastedTimeCount>=WastedTimeLimit then
                Begin
                  Case _UnitCmd of
                    //Swap patrol command target
                    CmdPatrol :
                      Begin
                        _UnitFrame:=FrameUnUsed;
                        _WastedTimeCount:=0;
                        UnitSwapPatrolTarget(UnitNum);
                      End
                    Else//Reset unit command to none
                      UnitResetCommand(UnitNum);
                  End;
                  Exit;
                End;
        {$IfDef DontStopWhenHarvest}
            End;
          End;
        {$EndIf}
        {_UnitPrevCmd:=_UnitCmd;
        _UnitNextCmd:=NoCmd;}
        _UnitNextCmd:=_UnitCmd;
        _UnitCmd:=CmdWasted;
        _UnitNextSpell:=_UnitSpell;
        _UnitNextTarget:=_UnitTarget;
        _UnitWait:=0;
        _PathUsed:=0;
        _UnitFrame:=FrameUnUsed;
      End;
  End;

FUNCTION  TLOCUnits.UnitCommandTrain(UnitNum : TUnitCount;Typer : TUnit;FromClan : TClan) : FastInt;
  Var Idx : TQueueCount;
      Res : FastInt;
  Begin
    Result:=ROk;
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check unit can train this unit ?
    If Not CheckUnitCanGen(UnitNum,Typer) then Exit;
    With MyScreen,Units[UnitNum] do
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
        For Idx:=Low(TQueueCount) to High(TQueueCount) do
          If _UnitQueue[Idx]=0 then
            Begin
              _UnitQueue[Idx]:=GetUnusedUnit;
              If _UnitQueue[Idx]=0 then
                Begin
                  Result:=RCanNotCreateMoreUnit;
                  If FromClan=HumanControl then
                    SendMessage(CanNotCreateMoreUnit);
                End
              Else
                Begin
                  Result:=ROk;
                  SetUnitToStart(_UnitQueue[Idx],_UnitClan,Typer,_UnitPos.X,_UnitPos.Y,False);
                  If _UnitGroup and 128=128 then
                    Begin
                      GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                      SetupGroupSelected(MaxGroup);
                    End;
                End;
              Exit;
            End;
        If FromClan=HumanControl then
          Begin
            Result:=RQueueFull;
            SendMessage(UnitQueueIsFull);
          End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandDirectCastSpell(UnitNum : TUnitCount;Spell : TSpell;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for unit can cast this spell ?
    If CheckUnitHasSpell(UnitNum,Spell)=False then Exit;
    //Unit enogh mana for use spell ?
    If CheckUseSpell(UnitNum,Spell)<>ROk then
      Begin
        If FromClan=HumanControl then
          MyScreen.SendMessage(NotEnoughMana);      
        Exit;
      End;
    With Units[UnitNum] do
      Begin
        _UnitPrevCmd:=NoCmd;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdCastSpell;
              _UnitSpell:=Spell;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=0;
              _UnitDest:=_UnitPos;
              _PatrolDest:=_UnitPos;
            End
          Else
            Begin
              _UnitNextCmd:=CmdCastSpell;
              _UnitNextTarget:=0;
              _PatrolDest:=_UnitPos;
              _UnitNextSpell:=Spell;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandCastSpell(UnitNum,Target : TUnitCount;Spell : TSpell;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for unit can cast this spell ?
    If CheckUnitHasSpell(UnitNum,Spell)=False then Exit;
    If Units[UnitNum]._UnitItems[WeaponItem].Typer=ItemNone then
      Begin
        If FromClan=HumanControl then
          MyScreen.SendMessage(CmdMessage[UnitNotHasWeapon]);
        Exit;
      End;
    //Unit enogh mana for use spell ?
    If CheckUseSpell(UnitNum,Spell)<>ROk then
      Begin
        If FromClan=HumanControl then
          MyScreen.SendMessage(NotEnoughMana);      
        Exit;
      End;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdCastSpell;
              _UnitSpell:=Spell;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
              _PatrolDest:=Units[Target]._UnitPos;
            End
          Else
            Begin
              _UnitNextCmd:=CmdCastSpell;
              _UnitNextTarget:=Target;
              _UnitNextSpell:=Spell;
              _PatrolDest:=Units[Target]._UnitPos;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandCastSpell(UnitNum : TUnitCount;DestX,DestY : FastInt;Spell : TSpell;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for unit can cast this spell ?
    If CheckUnitHasSpell(UnitNum,Spell)=False then Exit;
    //Spell needed target ?
    If SpellProperty[Spell].NeedTarget then Exit;
    //Unit not had a weapon to castspell ?
    If Units[UnitNum]._UnitItems[WeaponItem].Typer=ItemNone then
      Begin
        If FromClan=HumanControl then
          MyScreen.SendMessage(CmdMessage[UnitNotHasWeapon]);
        Exit;
      End;
    //Unit enogh mana for use spell ?
    If CheckUseSpell(UnitNum,Spell)<>ROk then
      Begin
        If FromClan=HumanControl then
          MyScreen.SendMessage(NotEnoughMana);      
        Exit;
      End;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdCastSpell;
              _UnitSpell:=Spell;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=0;
              _PatrolDest.X:=DestX;
              _PatrolDest.Y:=DestY;
            End
          Else
            Begin
              _UnitNextCmd:=CmdCastSpell;
              _UnitNextTarget:=0;
              _UnitNextSpell:=Spell;
              _PatrolDest.X:=DestX;
              _PatrolDest.Y:=DestY;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandPutItem(UnitNum : TUnitCount;DestX,DestY : FastInt;Slot : TItemCount;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    With Units[UnitNum] do
      Begin
        If _UnitItems[Slot].Typer=ItemNone then Exit;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdPutItem;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=0;
              _UnitNextTarget:=0;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
              _ItemSlot:=Slot;
            End
          Else
            Begin
              _UnitNextCmd:=CmdPutItem;
              _UnitNextTarget:=0;
              _ItemPos.X:=DestX;
              _ItemPos.Y:=DestY;
              _ItemSlot:=Slot;
            End
        End;
      End;
  End;
  
PROCEDURE TLOCUnits.UnitCommandPutItem(UnitNum : TUnitCount;Target : TUnitCount;Slot : TItemCount;FromClan : TClan);
  Begin
    If UnitNum=Target then Exit;
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    With Units[UnitNum] do
      Begin
        If _UnitItems[Slot].Typer=ItemNone then Exit;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdPutItem;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
              _UnitNextTarget:=0;
              _ItemSlot:=Slot;
            End
          Else
            Begin
              _UnitNextCmd:=CmdPutItem;
              _UnitNextTarget:=Target;
              _ItemSlot:=Slot;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandPickUpItem(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
  Begin
    If UnitNum=Target then Exit;
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdPickItem;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
              _UnitNextTarget:=0;
            End
          Else
            Begin
              _UnitNextCmd:=CmdPickItem;
              _UnitNextTarget:=Target;
            End
        End;
      End;
  End;
  
PROCEDURE TLOCUnits.UnitCommandLoadUnit(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
  Begin
    If UnitNum=Target then Exit;
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdLoadUnit;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
              _UnitNextTarget:=0;
            End
          Else
            Begin
              _UnitNextCmd:=CmdLoadUnit;
              _UnitNextTarget:=Target;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandUnLoadAllUnit(UnitNum : TUnitCount;DestX,DestY : FastInt;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdUnLoadUnit;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=0;
              _UnitNextTarget:=0;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
            End
          Else
            Begin
              _UnitNextCmd:=CmdUnLoadUnit;
              _UnitNextTarget:=0;
              _UnitDest.X:=DestX;
              _UnitDest.Y:=DestY;
            End
        End;
      End;
  End;
  
PROCEDURE TLOCUnits.UnitCommandGoTransportUnit(UnitNum : TUnitCount;Target : TUnitCount;FromClan : TClan);
  Begin
    If UnitNum=Target then Exit;
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdGoTransport;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
              _UnitNextTarget:=0;
            End
          Else
            Begin
              _UnitNextCmd:=CmdGoTransport;
              _UnitNextTarget:=Target;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandHarvest(UnitNum,Target : TUnitCount;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for unit can harvest ? :>
    If CheckUnitSkill(UnitNum,CmdHarvest)=False then Exit;
    //Check target is gold mine ?
    If Not (UnitIsGoldMine in UnitsProperty[Units[Target]._UnitClan,
                                            Units[Target]._UnitTyper].BaseAttribute) then Exit;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdHarvest;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=Target;
              _UnitNextTarget:=0;
              _MineTarget:=Target;
              UnitFindReturnGoldTarget(UnitNum);
            End
          Else
            Begin
              _UnitNextCmd:=CmdHarvest;
              _UnitNextTarget:=Target;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandHarvest(UnitNum : TUnitCount;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Check for unit can harvest ? :>
    If CheckUnitSkill(UnitNum,CmdHarvest)=False then Exit;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdHarvest;
              _UnitNextCmd:=NoCmd;
              _UnitTarget:=_MineTarget;
              _UnitNextTarget:=0;
            End
          Else
            Begin
              _UnitNextCmd:=CmdHarvest;
              _UnitNextTarget:=_MineTarget;
            End
        End;
      End;
  End;

PROCEDURE TLOCUnits.UnitCommandReturnGold(UnitNum,Target : TUnitCount;FromClan : TClan);
  Begin
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    //Target is not a gold deposit ?
    If Not UnitTestBaseAttribute(Target,UnitIsDeposit) then Exit;
    With Units[UnitNum] do
      Begin
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdReturnGold;
              _UnitNextCmd:=NoCmd;
              _UnitNextTarget:=0;
              _ReturnGoldTarget:=Target;
              _UnitTarget:=_ReturnGoldTarget;
            End
          Else
            Begin
              _ReturnGoldTarget:=Target;
              _UnitNextCmd:=CmdReturnGold;
              _UnitNextTarget:=_ReturnGoldTarget;
            End
        End;
      End;
  End;

FUNCTION  TLOCUnits.UnitCommandReturnGold(UnitNum : TUnitCount;FromClan : TClan) : Boolean;
  Begin
    Result:=False;
    //Check for unit can self control, why unit can't get a command ? Crazy
    If GetUnitAttribute(UnitNum,UnitSelfControl)=False then Exit;
    //Check for valid clan send command
    If CheckClanControlUnit(UnitNum,FromClan)=False then Exit;
    With Units[UnitNum] do
      Begin
        //  If unit deposit target default is death and transfer to other unit, I'm recheck
        //it and reset command. But maybe gen a error when new unit is deposit target !
        If _ReturnGoldTarget=0 then Exit;
        If Units[_ReturnGoldTarget]._UnitClan<>Units[UnitNum]._UnitClan then Exit;
        If Units[_ReturnGoldTarget]._UnitHitPoint<=0 then Exit;
        If Not UnitTestBaseAttribute(_ReturnGoldTarget,UnitIsDeposit) then Exit;
        _PathUsed:=0;
        _WastedTimeCount:=0;
        _UnitPrevCmd:=NoCmd;
        Case _UnitCmd of
          NoCmd,CmdWasted :
            Begin
              _UnitFrame:=FrameUnUsed;
              _UnitCmd:=CmdReturnGold;
              _UnitNextCmd:=NoCmd;
              _UnitNextTarget:=0;
              _UnitTarget:=_ReturnGoldTarget;
            End
          Else
            Begin
              _UnitNextCmd:=CmdReturnGold;
              _UnitNextTarget:=_ReturnGoldTarget;
            End
        End;
      End;
    Result:=True;
  End;

PROCEDURE TLOCUnits.UnitCommandRallyPoint(UnitNum : TUnitCount;DestX,DestY : FastInt);
  Begin
    With Units[UnitNum] do
      Begin
        _UnitDest.X:=DestX;
        _UnitDest.Y:=DestY;
      End;
  End;

FUNCTION  TLOCUnits.UnitGetNextCommand(UnitNum : TUnitCount) : Boolean;
  Begin
    With Units[UnitNum] do
      Begin
        If _UnitNextCmd=NoCmd then
          Begin
            Result:=False;
            Exit;
          End
        Else Result:=True;
        _UnitCmd:=_UnitNextCmd;
        _UnitNextCmd:=NoCmd;
        //_UnitPrevCmd:=NoCmd;
        _UnitFrame:=FrameUnUsed;
        _UnitWait:=0;
        _PathUsed:=0;
        _UnitTarget:=_UnitNextTarget;
        _UnitSpell:=_UnitNextSpell;//Needed for cast spell skill ?
        _UnitNextTarget:=0;
        Case _UnitCmd of
          CmdAttack :
            Begin
              //Safe code
              If _UnitTarget<>0 then
                _UnitDest:=Units[_UnitTarget]._UnitPos;
            End;
          CmdAttackAt :
            Begin
              _UnitTarget:=0;
              //Loading destination from next command (is AttackAt)
              _UnitDest:=_PatrolDest;
            End;
          CmdCastSpell :
            Begin
              If _UnitTarget=0 then _UnitDest:=_PatrolDest
              Else _UnitDest:=Units[_UnitTarget]._UnitPos;
            End;
          CmdHarvest :
            Begin
              _MineTarget:=_UnitTarget;
              UnitFindReturnGoldTarget(UnitNum);
            End;
          CmdPutItem :
            Begin
              If _UnitTarget<>0 then
                Begin
                  _UnitDest:=Units[_UnitTarget]._UnitPos;
                End
              Else
                Begin
                  _UnitDest:=_ItemPos;
                End;
            End;
          CmdHoldPosition :
            Begin
              _UnitTarget:=0;
            End;
        End;
      End;
  End;

FUNCTION  TLOCUnits.UnitGetPrevCommand(UnitNum : TUnitCount) : Boolean;
  Begin
    With Units[UnitNum] do
      Begin
        If _UnitPrevCmd=NoCmd then
          Begin
            Result:=False;
            Exit;
          End
        Else Result:=True;
        _UnitCmd:=_UnitPrevCmd;
        _UnitFrame:=FrameUnUsed;
        _UnitPrevCmd:=NoCmd;
        _UnitWait:=0;
        _PathUsed:=0;
        Case _UnitCmd of
          CmdAttack :
            Begin
              If _UnitTarget<>0 then
                _UnitDest:=Units[_UnitTarget]._UnitPos;
            End;
          CmdAttackAt :
            Begin
              _UnitTarget:=0;
              //Loading old destination from last command (is AttackAt)
              _UnitDest:=_PatrolDest;
            End;
          CmdCastSpell :
            Begin
              If _UnitTarget=0 then _UnitDest:=_PatrolDest
              Else _UnitDest:=Units[_UnitTarget]._UnitPos;
            End;
          CmdHoldPosition :
            Begin
              _UnitTarget:=0;
            End;
        End;
      End;
  End;

FUNCTION  TLOCUnits.CountOfEnemyUnit(Clan : TClan) : Integer;
  Var Z : TClan;
      R : Integer;
  Begin
    R:=0;
    For Z:=Low(TClan) to High(TClan) do
      If ClanInfo[Clan].Diplomacy[Z]=Enemy then
        R:=R+ClanInfo[Z].AllUnits;
    Result:=R;
  End;

FUNCTION  TLOCUnits.FindUnitIDByName(Name : String) : Integer;
  Var Z : Integer;
  Begin
    Name:=UpperCase(Name);
    For Z:=Low(Units) to High(Units) do
      If (Units[Z]._UnitHitPoint<>UnitUnUsedConst) and
         (Name=UpperCase(Units[Z]._UnitName)) then
        Begin
          Result:=Z;
          Exit;
        End;
    Result:=0;
  End;

FUNCTION  TLOCUnits.GetUnitHitPoint(UnitNum : TUnitCount) : Integer;
  Begin
    If (UnitNum<Low(Units)) or
       (UnitNum>High(Units)) then Result:=UnitUnUsedConst
    Else Result:=Units[UnitNum]._UnitHitPoint;
  End;

PROCEDURE TLOCUnits.RestartMissileData;
  Var Z : TMissileCount;
  Begin
    //Why total missile = 0 ? This for clear missile increcment total missisle !
    TotalMissile:=0;
    For Z:=Low(Missiles) to High(Missiles) do ClearMissile(Z);
    FillChar(Missiles,SizeOf(Missiles),0);
  End;

PROCEDURE TLOCUnits.InitMissile(MisNum : TMissileCount);
  Begin
    With Missiles[MisNum] do
      Begin
        //Missile flying from unit num to unit target !
        //Calculate point for flying
        If MissileProperty[Typer].MissileAttribute and
           MissilePointTo=MissilePointTo then
          Begin
            If MisPos.X>MisDest.X then
              Begin
                DXS:=-DefaultBaseMissileSpeed;
                DX:=MisPos.X-MisDest.X;
              End
            Else
            If MisPos.X<MisDest.X then
              Begin
                DXS:=+DefaultBaseMissileSpeed;
                DX:=MisDest.X-MisPos.X;
              End
            Else
              Begin
                DXS:=0;
                DX:=0;
              End;
            If MisPos.Y>MisDest.Y then
              Begin
                DYS:=-DefaultBaseMissileSpeed;
                DY:=MisPos.Y-MisDest.Y;
              End
            Else
            If MisPos.Y<MisDest.Y then
              Begin
                DYS:=+DefaultBaseMissileSpeed;
                DY:=MisDest.Y-MisPos.Y;
              End
            Else
              Begin
                DYS:=0;
                DY:=0;
              End;
            If DX<DY then
              Begin
                Step:=DY-1;
                DX:=DX*2;
                DY:=DY*2;
              End
            Else
            If DX>DY then
              Begin
                Step:=DX-1;
                DX:=DX*2;
                DY:=DY*2;
              End
          End
        Else
          Begin
            DX:=0;
            DY:=0;
            DXS:=0;
            DYS:=0;
            Step:=0;
          End;
        Case Typer of
          MissileExplode :
            Begin
              MisState:=Explosion;
              Head:=GetRandomHeading;
            End;
          MissileBlizzard :
            Begin
              Head:=GetRandomHeading;
            End;
          Else
            Begin
              Head:=GetHeading(MisPos.X,MisPos.Y,MisDest.X,MisDest.Y);
            End;
        End;
      End;
  End;

FUNCTION TLOCUnits.NewMissile(UnitNum,Target : TUnitCount;MisType : TMissile;MissileAround : Boolean = False) : Boolean;
  Var Z     : TMissileCount;
      Typer : TUnit;
      Clan  : TClan;
  Begin
    If TotalMissile=0 then
      Begin
        Result:=False;
        Exit;
      End
    Else
      Begin
        Dec(TotalMissile);
        Result:=True;
      End;
    //Get unused missile and assign for this missle
    For Z:=Low(Missiles) to High(Missiles) do
      If Missiles[Z].Typer=MissileNone then
        Begin
          Missiles[Z].Typer:=MisType;
          Missiles[Z].FromUnit:=UnitNum;
          Missiles[Z].Target:=Target;
          Clan:=Units[UnitNum]._UnitClan;
          Typer:=Units[UnitNum]._UnitTyper;
          Missiles[Z].MisPos.X:=Units[UnitNum]._UnitPos.X*DefaultMapTileX+
                                (UnitsProperty[Clan,Typer].UnitSizeX+1)*DefaultMapTileX div 2;
          Missiles[Z].MisPos.Y:=Units[UnitNum]._UnitPos.Y*DefaultMapTileY+
                                (UnitsProperty[Clan,Typer].UnitSizeY+1)*DefaultMapTileY div 2;
          Clan:=Units[Target]._UnitClan;
          Typer:=Units[Target]._UnitTyper;
          If MissileAround then
            Begin
              Missiles[Z].MisDest.X:=Units[Target]._UnitPos.X*DefaultMapTileX+
                                     Random((UnitsProperty[Clan,Typer].UnitSizeX+1)*DefaultMapTileX);
              Missiles[Z].MisDest.Y:=Units[Target]._UnitPos.Y*DefaultMapTileY+
                                     Random((UnitsProperty[Clan,Typer].UnitSizeY+1)*DefaultMapTileY);
            End
          Else
            Begin
              Missiles[Z].MisDest.X:=Units[Target]._UnitPos.X*DefaultMapTileX+
                                     (UnitsProperty[Clan,Typer].UnitSizeX+1)*DefaultMapTileX div 2;
              Missiles[Z].MisDest.Y:=Units[Target]._UnitPos.Y*DefaultMapTileY+
                                     (UnitsProperty[Clan,Typer].UnitSizeY+1)*DefaultMapTileY div 2;
            End;
          Missiles[Z].MisDamage:=RealUnitAttackDamage(UnitNum);
          Missiles[Z].MisClan:=Units[UnitNum]._UnitClan;
          Missiles[Z].Frame:=0;//Frame start with zero
          Missiles[Z].MisState:=Flying;
          Missiles[Z].WaitTime:=-1;
          InitMissile(Z);
          Exit;
        End;
  End;

FUNCTION TLOCUnits.NewMissile(UnitNum : TUnitCount;TargetX,TargetY : FastInt;
                              MisType : TMissile;MissileAround : Boolean = False) : Boolean;
  Var Z     : TMissileCount;
      Typer : TUnit;
      Clan  : TClan;
  Begin
    If TotalMissile=0 then
      Begin
        Result:=False;
        Exit;
      End
    Else
      Begin
        Dec(TotalMissile);
        Result:=True;
      End;
    //Get unused missile and assign for this missle
    For Z:=Low(Missiles) to High(Missiles) do
      If Missiles[Z].Typer=MissileNone then
        Begin
          Missiles[Z].Typer:=MisType;
          Missiles[Z].FromUnit:=UnitNum;
          //Unit not target ?
          Missiles[Z].Target:=0;
          Clan:=Units[UnitNum]._UnitClan;
          Typer:=Units[UnitNum]._UnitTyper;
          Missiles[Z].MisPos.X:=Units[UnitNum]._UnitPos.X*DefaultMapTileX+
                                (UnitsProperty[Clan,Typer].UnitSizeX+1)*DefaultMapTileX div 2;
          Missiles[Z].MisPos.Y:=Units[UnitNum]._UnitPos.Y*DefaultMapTileY+
                                (UnitsProperty[Clan,Typer].UnitSizeY+1)*DefaultMapTileY div 2;
          Missiles[Z].MisDest.X:=TargetX*DefaultMapTileX+DefaultMapTileX div 2;
          Missiles[Z].MisDest.Y:=TargetY*DefaultMapTileY+DefaultMapTileY div 2;
          If MissileAround then
            Begin
              Missiles[Z].MisDest.X:=TargetX*DefaultMapTileX+Random(DefaultMapTileX);
              Missiles[Z].MisDest.Y:=TargetY*DefaultMapTileY+Random(DefaultMapTileY);
            End
          Else
            Begin
              Missiles[Z].MisDest.X:=TargetX*DefaultMapTileX+DefaultMapTileX div 2;
              Missiles[Z].MisDest.Y:=TargetY*DefaultMapTileY+DefaultMapTileY div 2;
            End;
          Missiles[Z].MisDamage:=RealUnitAttackDamage(UnitNum);
          Missiles[Z].MisClan:=Units[UnitNum]._UnitClan;
          Missiles[Z].Frame:=0;//Frame start with zero
          Missiles[Z].MisState:=Flying;
          Missiles[Z].WaitTime:=-1;
          InitMissile(Z);
          Exit;
        End;
  End;

FUNCTION TLOCUnits.NewMissile(StartX,StartY,TargetX,TargetY : FastInt;MisType : TMissile;
                              MissileAround : Boolean = False) : Boolean;
  Var Z : TMissileCount;
  Begin
    If TotalMissile=0 then
      Begin
        Result:=False;
        Exit;
      End
    Else
      Begin
        Dec(TotalMissile);
        Result:=True;
      End;
    //Get unused missile and assign for this missle
    For Z:=Low(Missiles) to High(Missiles) do
      If Missiles[Z].Typer=MissileNone then
        Begin
          Missiles[Z].Typer:=MisType;
          //Unit no parent ?
          Missiles[Z].FromUnit:=0;
          //Unit not target ?
          Missiles[Z].Target:=0;
          Missiles[Z].MisPos.X:=StartX*DefaultMapTileX+DefaultMapTileX div 2;
          Missiles[Z].MisPos.Y:=StartY*DefaultMapTileY+DefaultMapTileY div 2;
          If MissileAround then
            Begin
              Missiles[Z].MisDest.X:=TargetX*DefaultMapTileX+Random(DefaultMapTileX);
              Missiles[Z].MisDest.Y:=TargetY*DefaultMapTileY+Random(DefaultMapTileY);
            End
          Else
            Begin
              Missiles[Z].MisDest.X:=TargetX*DefaultMapTileX+DefaultMapTileX div 2;
              Missiles[Z].MisDest.Y:=TargetY*DefaultMapTileY+DefaultMapTileY div 2;
            End;
          Missiles[Z].MisDamage:=0;
          Missiles[Z].MisClan:=Gaia;
          Missiles[Z].Frame:=0;//Frame start with zero
          Missiles[Z].MisState:=Flying;
          Missiles[Z].WaitTime:=-1;
          InitMissile(Z);
          Exit;
        End;
  End;
  
FUNCTION TLOCUnits.NewMissile(UnitNum : TUnitCount;StartX,StartY,TargetX,TargetY : FastInt;
                              MisType : TMissile;MissileAround : Boolean = False) : Boolean;
  Var Z : TMissileCount;
  Begin
    If TotalMissile=0 then
      Begin
        Result:=False;
        Exit;
      End
    Else
      Begin
        Dec(TotalMissile);
        Result:=True;
      End;
    //Get unused missile and assign for this missle
    For Z:=Low(Missiles) to High(Missiles) do
      If Missiles[Z].Typer=MissileNone then
        Begin
          Missiles[Z].Typer:=MisType;
          //Unit parent ?
          Missiles[Z].FromUnit:=UnitNum;
          //Unit not target ?
          Missiles[Z].Target:=0;
          Missiles[Z].MisPos.X:=StartX*DefaultMapTileX+DefaultMapTileX div 2;
          Missiles[Z].MisPos.Y:=StartY*DefaultMapTileY+DefaultMapTileY div 2;
          If MissileAround then
            Begin
              Missiles[Z].MisDest.X:=TargetX*DefaultMapTileX+Random(DefaultMapTileX);
              Missiles[Z].MisDest.Y:=TargetY*DefaultMapTileY+Random(DefaultMapTileY);
            End
          Else
            Begin
              Missiles[Z].MisDest.X:=TargetX*DefaultMapTileX+DefaultMapTileX div 2;
              Missiles[Z].MisDest.Y:=TargetY*DefaultMapTileY+DefaultMapTileY div 2;
            End;
          Missiles[Z].MisDamage:=RealUnitAttackDamage(UnitNum);
          Missiles[Z].MisClan:=Units[UnitNum]._UnitClan;
          Missiles[Z].Frame:=0;//Frame start with zero
          Missiles[Z].MisState:=Flying;
          Missiles[Z].WaitTime:=-1;
          InitMissile(Z);
          Exit;
        End;
  End;
  
FUNCTION TLOCUnits.NewRealMissile(StartX,StartY,TargetX,TargetY : FastInt;MisType : TMissile) : Boolean;
  Var Z : TMissileCount;
  Begin
    If TotalMissile=0 then
      Begin
        Result:=False;
        Exit;
      End
    Else
      Begin
        Dec(TotalMissile);
        Result:=True;
      End;
    //Get unused missile and assign for this missle
    For Z:=Low(Missiles) to High(Missiles) do
      If Missiles[Z].Typer=MissileNone then
        Begin
          Missiles[Z].Typer:=MisType;
          //Unit no parent ?
          Missiles[Z].FromUnit:=0;
          //Unit not target ?
          Missiles[Z].Target:=0;
          Missiles[Z].MisPos.X:=StartX;
          Missiles[Z].MisPos.Y:=StartY;
          Missiles[Z].MisDest.X:=TargetX;
          Missiles[Z].MisDest.Y:=TargetY;
          Missiles[Z].MisDamage:=0;
          Missiles[Z].MisClan:=Gaia;
          Missiles[Z].Frame:=0;//Frame start with zero
          Missiles[Z].MisState:=Flying;
          Missiles[Z].WaitTime:=-1;
          InitMissile(Z);
          Exit;
        End;
  End;
  
PROCEDURE TLOCUnits.ClearMissile(MisNum : TMissileCount);
  Begin
    If (MisNum<Low(Missiles)) or
       (MisNum>High(Missiles)) then
      Begin
        Exit;
      End;
    With Missiles[MisNum] do
      Begin
        Inc(TotalMissile);
        Typer:=MissileNone;
      End;
  End;

PROCEDURE TLOCUnits.MissileHit(MisNum : TMissileCount);
  Begin
    With Missiles[MisNum] do
      Begin
        If (Target>=Low(Units)) and
           (Target<=High(Units)) then
          Begin
            //Unit target not in mapnum ?
            If Not GetUnitAttribute(Target,UnitOnMapNum) then
              Begin
                Exit;
              End;
            If CheckBaseAttribute(Target,UnitInvulnerable) then
              Begin
                Exit;
              End;
            If Units[Target]._UnitHitPoint>0 then
               DecUnitHitPoint(Target,MisDamage);
            //Before missile hit, some missile take a effect like fireball or blizzard.. ?
          End;
      End;
  End;

PROCEDURE TLOCUnits.MissileCheckHit(MisNum : TMissileCount);
  Begin
    With Missiles[MisNum] do
      Begin
      End;
  End;

PROCEDURE TLOCUnits.RestartEffectData;
  Var Z : TEffectedCount;
  Begin
    //Why total missile = 0 ? This for clear missile increcment total missisle !
    TotalEffect:=0;
    For Z:=Low(Effects) to High(Effects) do ClearEffect(Z);
    FillChar(Effects,SizeOf(Effects),0);
  End;
  
PROCEDURE TLOCUnits.ClearEffect(EffNum : TEffectedCount);
  Begin
    With Effects[EffNum] do
      Begin
        Inc(TotalEffect);
        Typer:=NoEffected;
        NextEffect:=0;
        PrevEffect:=0;
        LinkToUnit:=0;
      End;
  End;

PROCEDURE TLOCUnits.DisposeEffect(EffNum : TEffectedCount);
  Begin
    With Effects[EffNum] do
      Begin
        If LinkToUnit<>0 then
          Begin
            UnitUnChangesByEffected(LinkToUnit,Typer);
            If Units[LinkToUnit]._UnitEffected=EffNum then
              Begin
                Units[LinkToUnit]._UnitEffected:=NextEffect;
                Effects[NextEffect].PrevEffect:=0;
              End
            Else
              Begin
                If PrevEffect<>0 then
                  Effects[PrevEffect].NextEffect:=NextEffect;
                If NextEffect<>0 then
                  Effects[NextEffect].PrevEffect:=PrevEffect;
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnits.DisposeUnitEffect(UnitNum : TUnitCount);
  Var EffNum,EffSave : TEffectedCount;
  Begin
    With Units[UnitNum] do
      Begin
        If _UnitEffected=0 then Exit;
        EffSave:=_UnitEffected;
        Repeat
          EffNum:=EffSave;
          UnitUnChangesByEffected(UnitNum,Effects[EffNum].Typer);
          EffSave:=Effects[EffSave].NextEffect;
          ClearEffect(EffNum);
        Until EffSave=0;
        _UnitEffected:=0;
      End;
  End;

PROCEDURE TLOCUnits.InitEffect(EffNum : TEffectedCount);
  Begin
    With Effects[EffNum] do
      Begin
        Case Typer of
          HeroSign0..HeroSign9 :
            Begin
              Angle:=0;
              TransLevel:=RandomRange(MinTransparent div DefaultTransparentSpeed+1,
                                      MaxTransparent div DefaultTransparentSpeed-1)*DefaultTransparentSpeed;
              TransIncrease:=DefaultTransparentSpeed;
              TimeCountDown:=EffectInfinite;
            End;
        End;
      End;
  End;

FUNCTION  TLOCUnits.NewEffect(UnitNum : TUnitCount;Typer : TEffected;CountDown : TTimeCount) : Boolean;
  Var EffNum : TEffectedCount;
  Begin
    //When unit have this effect ?
    With Units[UnitNum] do
      Begin
        EffNum:=_UnitEffected;
        While EffNum<>0 do
          Begin
            //Effect has link to unit and same typer ?
            If Effects[EffNum].Typer=Typer then
              Begin
                //Updated countdown and exit now !
                Effects[EffNum].TimeCountDown:=CountDown;
                Result:=True;
                Exit;
              End;
            EffNum:=Effects[EffNum].NextEffect;
          End;
      End;
    If TotalEffect=0 then
      Begin
        Result:=False;
        Exit;
      End
    Else
      Begin
        Dec(TotalEffect);
        Result:=True;
      End;
    For EffNum:=Low(Effects) to High(Effects) do
      If Effects[EffNum].Typer=NoEffected then
        Begin
          //Unit effected data setup
          Effects[EffNum].Typer:=Typer;
          Effects[EffNum].TimeCountDown:=CountDown;
          //Unit effected linked list:
          Effects[EffNum].LinkToUnit:=UnitNum;
          Effects[EffNum].PrevEffect:=0;
          Effects[EffNum].NextEffect:=Units[UnitNum]._UnitEffected;
          Units[UnitNum]._UnitEffected:=EffNum;
          InitEffect(EffNum);
          UnitChangesByEffected(UnitNum,Typer);
          Exit;
        End;
  End;
  
FUNCTION  TLOCUnits.UnitChangesByEffected(UnitNum : TUnitCount;Typer : TEffected) : Boolean;
  Begin
    With Units[UnitNum] do
      Case Typer of
        Invisible :
          Begin
            SetUnitAttribute(UnitNum,UnitInvisible,True);
            Result:=True;
          End;
        BloodBlust :
          Begin
            //Unit damage multiply by 2 !
            _UnitDamage:=_UnitDamage ShL 1;
            Result:=True;
          End;
        Haste :
          Begin
            SetUnitAttribute(UnitNum,UnitHaste,True);
            Result:=True;
          End;
        Else
          Begin
            Result:=False;
          End;
      End;
  End;

FUNCTION  TLOCUnits.UnitUnChangesByEffected(UnitNum : TUnitCount;Typer : TEffected) : Boolean;
  Begin
    With Units[UnitNum] do
      Case Typer of
        Invisible :
          Begin
            SetUnitAttribute(UnitNum,UnitInvisible,False);
            Result:=True;
          End;
        BloodBlust :
          Begin
            //Unit damage division by 2 !
            _UnitDamage:=_UnitDamage ShR 1;
            Result:=True;
          End;
        Haste :
          Begin
            SetUnitAttribute(UnitNum,UnitHaste,False);
            Result:=True;
          End;
        Else
          Begin
            Result:=False;
          End;
      End;
  End;

FUNCTION  TLOCUnits.TestUnitEffected(UnitNum : TUnitCount;Typer : TEffected) : Boolean;
  Var EffNum : TEffectedCount;
  Begin
    With Units[UnitNum] do
      Begin
        EffNum:=_UnitEffected;
        While EffNum<>0 do
          Begin
            If Effects[EffNum].Typer=Typer then
              Begin
                Result:=True;
                Exit;
              End;
            EffNum:=Effects[EffNum].NextEffect;
          End;
        Result:=False;
      End;
  End;

FUNCTION  TLOCUnits.AIAddUnitToForce(AI : TClan;Force : TForce;UnitNum : TUnitCount) : Boolean;
  Var Z : FastInt;
  Begin
    With AIData[AI] do
      For Z:=Low(AIForce[Force]) to High(AIForce[Force]) do
        If AIForce[Force][Z]=0 then
          Begin
            AIForce[Force][Z]:=UnitNum;
            Inc(ForceCount[Force]);
            Result:=True;
            Exit;
          End;
    Result:=False;
  End;

FUNCTION  TLOCUnits.AIClearUnitFromForce(AI : TClan;Force : TForce;UnitNum : TUnitCount) : Boolean;
  Var Z : FastInt;
  Begin
    Result:=False;
    With AIData[AI] do
      Begin
        //Reset main town
        If AIMainTown=UnitNum then AIMainTown:=0;
        //Clear unit num from force
        For Z:=Low(AIForce[Force]) to High(AIForce[Force]) do
          If AIForce[Force][Z]=UnitNum then
            Begin
              AIForce[Force][Z]:=0;
              Dec(ForceCount[Force]);
              Result:=True;
              //Exit;
            End;
      End;
  End;

PROCEDURE TLOCUnits.AIUpdateEnemyTarget(AI : TClan);
  Var CC : TClan;
  Begin
    With AIData[AI] do
      Begin
        //Calculate clans enemy :> that can be get on MyUnits structure
        If ClanInfo[AI].Diplomacy[HumanControl]=Enemy then
          CurrentEnemy:=HumanControl;
        For CC:=Low(TCLan) to High(TClan) do
          If (ClanInfo[AI].Diplomacy[CC]=Enemy) and
             (ClanInfo[CC].AllUnits>0) and
             (Random(3)=1) then CurrentEnemy:=CC;
      End;
  End;
  
PROCEDURE TLOCUnits.AIUpdateCommandAvail(AI : TClan);
  Begin
    With AIData[AI] do
      Begin
        //AI active ?
        AIActive:=(ClanInfo[AI].Control=Computer) and
                  (ClanInfo[AI].AllUnits>0);
        //AI can build ?
        AICmdAvail[CompCmdBuild]:=ForceCount[WorkerForce]>0;
        //AI can worker ?
        AICmdAvail[CompCmdWorker]:=ForceCount[WorkerForce]>0;
        //AI can train ?
        AICmdAvail[CompCmdTrain]:=(ForceCount[BuildingTownForce]>0) or
                                  (ForceCount[BuildingTrainingForce]>0);
        //AI can attack ?
        AICmdAvail[CompCmdAttack]:=ForceCount[AttackForce]>0;
        //AI can finding ?
        AICmdAvail[CompCmdFinding]:=ForceCount[FindingForce]>0;
      End;
  End;
{$R-}
FUNCTION  TLOCUnits.SaveToStream(Stream : TStream;Compress : Boolean = True) : Boolean;
  Var BlockID,EntryID  : TBlockID;
      BlockIn,BlockOut : Pointer;
      SizeIn,SizeOut   : LongInt;
  Procedure SaveItemProperty(Compress : Boolean);
    Begin
      //Save item property
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntryItemProperty;
      EntryID.Compress:=Compress;
      If Compress then
        Begin
          SizeIn:=SizeOf(ItemProperty);
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Move(ItemProperty,BlockIn^,SizeIn);
          PNGZLib.ZCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          EntryID.Size:=SizeOut;
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else
        Begin
          EntryID.Size:=SizeOf(ItemProperty);
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(ItemProperty,SizeOf(ItemProperty));
        End;
    End;
  Procedure SaveUnitProperty(Compress : Boolean);
    Begin
      //Save unit property
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntryUnitProperty;
      EntryID.Compress:=Compress;
      If Compress then
        Begin
          SizeIn:=SizeOf(UnitsProperty);
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Move(UnitsProperty,BlockIn^,SizeIn);
          PNGZLib.ZCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          EntryID.Size:=SizeOut;
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else
        Begin
          EntryID.Size:=SizeOf(UnitsProperty);
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(UnitsProperty,SizeOf(UnitsProperty));
        End;
    End;
  Procedure SaveSkillProperty(Compress : Boolean);
    Begin
      //Save skill property
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntrySkillProperty;
      EntryID.Compress:=Compress;
      If Compress then
        Begin
          SizeIn:=SizeOf(SkillProperty);
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Move(SkillProperty,BlockIn^,SizeIn);
          PNGZLib.ZCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          EntryID.Size:=SizeOut;
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else
        Begin
          EntryID.Size:=SizeOf(SkillProperty);
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(SkillProperty,SizeOf(SkillProperty));
        End;
    End;
  Procedure SaveSkillAvail(Compress : Boolean);
    Begin
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntrySkillAvail;
      EntryID.Compress:=Compress;
      If Compress then
        Begin
          SizeIn:=SizeOf(SkillAvailable);
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Move(SkillAvailable,BlockIn^,SizeIn);
          PNGZLib.ZCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          EntryID.Size:=SizeOut;
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else
        Begin
          EntryID.Size:=SizeOf(SkillAvailable);
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(SkillAvailable,SizeOf(SkillAvailable));
        End;
    End;
  Procedure SaveTotalUnit(Compress : Boolean);
    Begin
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntryTotalUnit;
      EntryID.Compress:=False;
      Stream.Write(EntryID,SizeOf(EntryID));
      Stream.Write(TotalUnit,SizeOf(TotalUnit));
    End;
  Procedure SaveUnits(Compress : Boolean);
    Begin
      //Save units
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntryUnits;
      EntryID.Compress:=Compress;
      If Compress then
        Begin
          SizeIn:=SizeOf(Units);
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Move(Units,BlockIn^,SizeIn);
          PNGZLib.ZCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          EntryID.Size:=SizeOut;
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else
        Begin
          EntryID.Size:=SizeOf(Units);
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(Units,SizeOf(Units));
        End;
    End;
  Procedure SaveMissiles(Compress : Boolean);
    Begin
      //Save missiles
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntryMissiles;
      EntryID.Compress:=Compress;
      If Compress then
        Begin
          SizeIn:=SizeOf(Missiles);
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Move(Missiles,BlockIn^,SizeIn);
          PNGZLib.ZCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          EntryID.Size:=SizeOut;
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else
        Begin
          EntryID.Size:=SizeOf(Missiles);
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(Missiles,SizeOf(Missiles));
        End;
    End;
  Procedure SaveGroupInfo(Compress : Boolean);
    Begin
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntryGroupInfo;
      EntryID.Compress:=False;
      Stream.Write(EntryID,SizeOf(EntryID));
      Stream.Write(SaveGroups,SizeOf(SaveGroups));
      Stream.Write(CurrentGroup,SizeOf(CurrentGroup));
      Stream.Write(CurrentSkillButton,SizeOf(CurrentSkillButton));
    End;
  Procedure SaveClanInfo(Compress : Boolean);
    Begin
      FillChar(EntryID,SizeOf(EntryID),0);
      EntryID.ID:=EntryClanInfo;
      EntryID.Compress:=Compress;
      If Compress then
        Begin
          SizeIn:=SizeOf(ClanInfo);
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Move(ClanInfo,BlockIn^,SizeIn);
          PNGZLib.ZCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          EntryID.Size:=SizeOut;
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(BlockOut^,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else
        Begin
          EntryID.Size:=SizeOf(ClanInfo);
          Stream.Write(EntryID,SizeOf(EntryID));
          Stream.Write(ClanInfo,SizeOf(ClanInfo));
        End;
    End;
  Begin
    //Compress:=False;
    FillChar(BlockID,SizeOf(BlockID),0);
    BlockID.ID:=EntryGameUnitInfo;
    BlockID.Compress:=Compress;
    Stream.Write(BlockID,SizeOf(BlockID));
    SaveItemProperty(Compress);
    SaveUnitProperty(Compress);
    SaveSkillProperty(Compress);
    SaveSkillAvail(Compress);
    SaveTotalUnit(Compress);
    SaveUnits(Compress);
    SaveMissiles(Compress);
    SaveGroupInfo(Compress);
    SaveClanInfo(Compress);
    //Write an entry for end of record
    FillChar(EntryID,SizeOf(EntryID),0);
    EntryID.ID:=EntryEndBlock;
    EntryID.Compress:=False;
    Stream.Write(EntryID,SizeOf(EntryID));
    Result:=True;
  End;

FUNCTION  TLOCUnits.LoadFromStream(Stream : TStream) : Boolean;
  Var BlockID,EntryID  : TBlockID;
      BlockIn,BlockOut : Pointer;
      SizeIn,SizeOut   : LongInt;
  Procedure ReadItemProperty;
    Begin
      //Load item property
      If EntryID.Compress then
        Begin
          SizeIn:=EntryID.Size;
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Stream.Read(BlockIn^,SizeIn);
          PNGZLib.ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          If SizeOut<>SizeOf(ItemProperty) then
            MyScreen.ErrorMessage('Loading item property data failed !');
          Move(BlockOut^,ItemProperty,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else Stream.Read(ItemProperty,SizeOf(ItemProperty));
    End;
  Procedure ReadUnitProperty;
    Begin
      //Load unit property
      If EntryID.Compress then
        Begin
          SizeIn:=EntryID.Size;
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Stream.Read(BlockIn^,SizeIn);
          PNGZLib.ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          If SizeOut<>SizeOf(UnitsProperty) then
            MyScreen.ErrorMessage('Loading unit property data failed !');
          Move(BlockOut^,UnitsProperty,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else Stream.Read(UnitsProperty,SizeOf(UnitsProperty));
    End;
  Procedure ReadSkillProperty;
    Begin
      //Load skill property
      If EntryID.Compress then
        Begin
          SizeIn:=EntryID.Size;
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Stream.Read(BlockIn^,SizeIn);
          PNGZLib.ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          If SizeOut<>SizeOf(SkillProperty) then
            MyScreen.ErrorMessage('Loading skill property data failed !');
          Move(BlockOut^,SkillProperty,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else Stream.Read(SkillProperty,SizeOf(SkillProperty));
    End;
  Procedure ReadSkillAvail;
    Begin
      //Load skill available
      If EntryID.Compress then
        Begin
          SizeIn:=EntryID.Size;
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Stream.Read(BlockIn^,SizeIn);
          PNGZLib.ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          If SizeOut<>SizeOf(SkillAvailable) then
            MyScreen.ErrorMessage('Loading skill available data failed !');
          Move(BlockOut^,SkillAvailable,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else Stream.Read(SkillAvailable,SizeOf(SkillAvailable));
    End;
  Procedure ReadTotalUnit;
    Begin
      //Load total unit
      Stream.Read(TotalUnit,SizeOf(TotalUnit));
    End;
  Procedure ReadUnits;
    Begin
      //Load units
      If EntryID.Compress then
        Begin
          SizeIn:=EntryID.Size;
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Stream.Read(BlockIn^,SizeIn);
          PNGZLib.ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          If SizeOut<>SizeOf(Units) then
            MyScreen.ErrorMessage('Loading units data failed !');
          Move(BlockOut^,Units,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else Stream.Read(Units,SizeOf(Units));
    End;
  Procedure ReadMissiles;
    Begin
      //Load units
      If EntryID.Compress then
        Begin
          SizeIn:=EntryID.Size;
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Stream.Read(BlockIn^,SizeIn);
          PNGZLib.ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          If SizeOut<>SizeOf(Missiles) then
            MyScreen.ErrorMessage('Loading missiles data failed !');
          Move(BlockOut^,Missiles,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else Stream.Read(Missiles,SizeOf(Missiles));
    End;
  Procedure ReadGroupInfo;
    Begin
      Stream.Read(SaveGroups,SizeOf(SaveGroups));
      Stream.Read(CurrentGroup,SizeOf(CurrentGroup));
      Stream.Read(CurrentSkillButton,SizeOf(CurrentSkillButton));
    End;
  Procedure ReadClanInfo;
    Begin
      If EntryID.Compress then
        Begin
          SizeIn:=EntryID.Size;
          BlockIn:=Nil;BlockOut:=Nil;
          GetMem(BlockIn,SizeIn);
          Stream.Read(BlockIn^,SizeIn);
          PNGZLib.ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
          If SizeOut<>SizeOf(ClanInfo) then
            MyScreen.ErrorMessage('Loading clans info data failed !');
          Move(BlockOut^,ClanInfo,SizeOut);
          FreeMem(BlockIn);BlockIn:=Nil;
          FreeMem(BlockOut);BlockOut:=Nil;
        End
      Else Stream.Read(ClanInfo,SizeOf(ClanInfo));
    End;
  Begin
    Result:=False;
    BlockIn:=Nil;
    BlockOut:=Nil;
    Stream.Read(BlockID,SizeOf(BlockID));
    If BlockID.ID<>EntryGameUnitInfo then Exit;
    While True do
      Begin
        Stream.Read(EntryID,SizeOf(EntryID));
        Case EntryID.ID of
          EntryItemProperty  : ReadItemProperty;
          EntryUnitProperty  : ReadUnitProperty;
          EntrySkillProperty : ReadSkillProperty;
          EntrySkillAvail    : ReadSkillAvail;
          EntryTotalUnit     : ReadTotalUnit;
          EntryUnits         : ReadUnits;
          EntryMissiles      : ReadMissiles;
          EntryGroupInfo     : ReadGroupInfo;
          EntryClanInfo      : ReadClanInfo;
          Else Break;
        End;
      End;
    Result:=True;
  End;
{$R+}  
END.
