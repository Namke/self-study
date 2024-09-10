UNIT LOCBased;
{$Include GlobalDefines.Inc}
INTERFACE

USES SysUtils,
     Avenus3D;

CONST
  GameID        = 'Warcraft: New Generation [C] 2002-2003 CrAzyߪbe :")';
  GameCaption   = 'Warcraft: New Generation';
  GameVersion   = '0.1.2003.01.11';
  GameProduct   = 'K-Outertainment';
  GameCopyright = 'CrAzyߪbe';

CONST
  GameDataDir              = 'GameData\';
  ImagesDir                = 'Images\';
  GameTexturesDir          = 'Textures\';
  GameTerrainTexturesDir   = 'TerrainTextures\';
  GameAnimationScriptDir   = 'AnimationScript\';
  GameScriptDir            = 'Script\';
  GameInfoFileName         = 'GameInfo.2012';
  UnitSettingFileName      = 'UnitSetting.2012';
  ItemSettingFileName      = 'ItemSetting.2012';
  UnitIconsFileName        = 'UnitIcons.2012';
  SkillIconsFileName       = 'SkillIcons.2012';
  SpellIconsFileName       = 'SpellIcons.2012';
  ItemIconsFileName        = 'ItemIcons.2012';
  MissileSettingFileName   = 'Missile.2012';
  EffectedImageFileName    = 'EffectedImage.2012';
  TilesFileName            = 'Tile.2012';
  DefaultQuickSavedName    = 'QuickSave.lms';
  DefaultLogFileName       = 'CrazyBabe.Log';
  GraphicDataFileName      = 'GraphicData.2012';
  SoundDataFileName        = 'SoundData.2012';
  MovieDataFileName        = 'MovieData.2012';
//Types used for game
TYPE
  TInt           = SmallInt;
  FastInt        = SmallInt;
  FastInt2       = SmallInt;
  TUnitCount     = SmallInt;
  TMissileCount  = SmallInt;
  TEffectedCount = SmallInt;
  TRange         = SmallInt;
  TTimeCount     = SmallInt;
  NameString     = String[22];
  TipString      = String[255];

TYPE
  TEntryID = (
    EntryEndBlock,
    EntryGameWorldInfo,
    EntryGameUnitInfo,
    EntryItemProperty,
    EntryUnitProperty,
    EntrySkillProperty,
    EntrySkillAvail,
    EntryTotalUnit,
    EntryUnits,
    EntryMissiles,
    EntryGroupInfo,
    EntryClanInfo,
    EntryMapNum,
    EntryMapCount,
    EntryMapTile,
    EntryMapTileFrame,
    EntryMapTileHeight,
    EntryMapAttr,
    EntryMapUnderFog,
    EntryMapItem);

TYPE
//Block ID 12 byte size for block code
  TBlockID = Record
    ID       : TEntryID;
    Compress : Boolean;
    Size     : LongInt;
    Unused   : Array[1..7] of Byte;
  End;
//Define screen mode
TYPE
  TVideoMode = (M1024x768,M800x600);
//Constant default for color depth
CONST
  ColorDepth = BitDepthLow;
//Position type
TYPE
  TPoint = Record
    X,Y : FastInt;
  End;
//Race type
TYPE
  TRace = (RaceHuman,
           RaceOrc,
           RaceDevil,
           RaceGaia);

TYPE
  TDayTime = (
    Noon,    //07h-18h
    Dusk,    //18h-22h
    MidNight,//22h-04h
    Dawn     //04h-07h
  );

CONST
  TimePerHour  = 60;
  MinutePerDay = TimePerHour*24;
//Clan type, support for 16 player
TYPE
  TClan = (C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Gaia);

CONST
  DefaultClanName : Array[TClan] of NameString =
    ('CLAN1','CLAN2','CLAN3','CLAN4','CLAN5','CLAN6','CLAN7','CLAN8','CLAN9',
     'CLAN10','CLAN11','CLAN12','CLAN13','CLAN14','CLAN15','GAIA');

TYPE
  TClanDiplomacy = (Enemy,Ally,Neutral);
  TSharedControl = (NoSharedControl,FullSharedControl);
  TSharedVision  = (NoSharedVision,FullSharedVision);
//Heading type
TYPE
  THeading = (H1,H2,H3,H4,H5,H6,H7,H8);

CONST
  DefaultHeadingName : Array[THeading] of NameString = (
    'H1','H2','H3','H4','H5','H6','H7','H8');

CONST
  Direction : Array[THeading] of TPoint =
             ((X:+0;Y:-1),(X:+1;Y:-1),(X:+1;Y:+0),(X:+1;Y:+1),
              (X:+0;Y:+1),(X:-1;Y:+1),(X:-1;Y:+0),(X:-1;Y:-1));
//Units type
//Place peon before place peon with gold because I'm take UnitCanBuild in one queue
//Peon and peasant must add at last of queue !
TYPE
  TUnit = (NoneUnit,
           ItemStore,
           Corpse,
           Critter1,
           Critter2,
           Critter3,
           Critter4,
           PeasantWithGold,
           PeonWithGold,
           Peasant,
           Peon,
           Footman,
           Grunt,
           Archer,
           Axethrower,
           Ranger,
           Berserker,
           Knight,
           Ogre,
           Paladin,
           OgreMage,
           Mage,
           DeathKnight,
           Gryphon,
           Dragon,
           Dwarves,
           Goblin,
           Ballista,
           Catapul,
           FlyingMachine,
           Zeppelin,
           Light,
           Daemon,
           DarkDaemon,
           SuperDaemon,
           Xkeleton,
           DeathWing,//Dragon hero
           DragonRide,
           DragonMage,
           OgreMagi,
           Commander,
           Arbiter,
           Carrier,
           Intercept,
           GundamBattleShip1,
           GundamBattleShip2,
           GundamBattleShip3,
           //Building
           ConstructionLand,
           GoldMine,
           DarkPortal,
           TownHall,
           GreatHall,
           Keep,
           StrongHold,
           Castle,
           Fortress,
           HumanFarm,
           OrcFarm,
           HumanBarrack,
           OrcBarrack,
           HumanBlackSmith,
           OrcBlackSmith,
           ElvenLumberMill,
           TrollLumberMill,
           GnomishInventor,
           GoblinAlchemist,
           Stables,
           OgreMound,
           Church,
           AltarOfStorm,
           MageTower,
           TempleOfTheDamned,
           GryphonAviary,
           DragonRoost,
           HumanScoutTower,
           OrcWatchTower,
           HumanGuardTower,
           OrcGuardTower,
           HumanCannonTower,
           OrcCannonTower,
           AlienConstruction,           
           //Undefine
           Undefine0,
           Undefine1,
           Undefine2,
           Undefine3,
           Undefine4,
           Undefine5,
           Undefine6,
           Undefine7,
           Undefine8,
           Undefine9,
           Undefine10,
           Undefine11,
           Undefine12,
           Undefine13,
           Undefine14,
           Undefine15,
           Undefine16,
           Undefine17,
           Undefine18,
           Undefine19,
           Undefine20,
           Undefine21,
           Undefine22,
           Undefine23,
           Undefine24,
           Undefine25,
           Undefine26,
           Undefine27,
           Undefine28,
           Undefine29);

CONST
  DefaultUnitName : Array[TUnit] of NameString =
  ('NONE',
   'ITEMSTORE',
   'CORPSE',
   'CRITTER1',
   'CRITTER2',
   'CRITTER3',
   'CRITTER4',
   'PEASANTWITHGOLD',
   'PEONWITHGOLD',
   'PEASANT',
   'PEON',
   'FOOTMAN',
   'GRUNT',
   'ARCHER',
   'AXETHROWER',
   'RANGER',
   'BERSERKER',
   'KNIGHT',
   'OGRE',
   'PALADIN',
   'OGREMAGE',
   'MAGE',
   'DEATHKNIGHT',
   'GRYPHON',
   'DRAGON',
   'DWARVES',
   'GOBLIN',
   'BALLISTA',
   'CATAPUL',
   'FLYINGMACHINE',
   'ZEPPELIN',
   'LIGHT',
   'DAEMON',
   'DARKDAEMON',
   'SUPERDAEMON',
   'XKELETON',
   'DEATHWING',
   'DRAGONRIDE',
   'DRAGONMAGE',
   'OGREMAGI',
   'COMMANDER',
   'ARBITER',
   'CARRIER',
   'INTERCEPT',
   'GUNDAMBATTLESHIPONE',
   'GUNDAMBATTLESHIPTWO',
   'GUNDAMBATTLESHIPTHREE',
   //Building name
   'CONSTRUCTIONLAND',
   'GOLDMINE',
   'DARKPORTAL',
   'TOWNHALL',
   'GREATHALL',
   'KEEP',
   'STRONGHOLD',
   'CASTLE',
   'FORTRESS',
   'HUMANFARM',
   'ORCFARM',
   'HUMANBARRACK',
   'ORCBARRACK',
   'HUMANBLACKSMITH',
   'ORCBLACKSMITH',
   'ELVENLUMBERMILL',
   'TROLLLUMBERMILL',
   'GNOMISHINVENTOR',
   'GOBLINALCHEMIST',
   'STABLES',
   'OGREMOUND',
   'CHURCH',
   'ALTAROFSTORM',
   'MAGETOWER',
   'TEMPLEOFTHEDAMNED',
   'GRYPHONAVIARY',
   'DRAGONROOST',
   'HUMANSCOUTTOWER',
   'ORCWATCHTOWER',
   'HUMANGUARDTOWER',
   'ORCGUARDTOWER',
   'HUMANCANNONTOWER',
   'ORCCANNONTOWER',
   'ALIENCONSTRUCTION',
   //Undefined
   'UNDEFINE0',
   'UNDEFINE1',
   'UNDEFINE2',
   'UNDEFINE3',
   'UNDEFINE4',
   'UNDEFINE5',
   'UNDEFINE6',
   'UNDEFINE7',
   'UNDEFINE8',
   'UNDEFINE9',
   'UNDEFINE10',
   'UNDEFINE11',
   'UNDEFINE12',
   'UNDEFINE13',
   'UNDEFINE14',
   'UNDEFINE15',
   'UNDEFINE16',
   'UNDEFINE17',
   'UNDEFINE18',
   'UNDEFINE19',
   'UNDEFINE20',
   'UNDEFINE21',
   'UNDEFINE22',
   'UNDEFINE23',
   'UNDEFINE24',
   'UNDEFINE25',
   'UNDEFINE26',
   'UNDEFINE27',
   'UNDEFINE28',
   'UNDEFINE29');
//Control type
TYPE
  TControl = (NoBody,Human,Computer,NetworkPlayer);

TYPE
  TMissile = (MissileNone,
              MissileGreenCross,
              MissileArrow,
              MissileAxe,
              MissileLightning,
              MissileTouchOfDeath,
              MissileDragBull,
              MissileFireBall,
              MissileBlizzard,
              MissileMagicBoom,
              MissileExplode
              );

CONST
  DefaultMissileName : Array[TMissile] of NameString = (
    '',
    '',
    'ARROW',
    'AXE',
    'LIGHTNING',
    'TOUCHOFDEATH',
    'DRAGBULL',
    'FIREBALL',
    'BLIZZARD',
    'MAGICBOOM',
    ''
    );

TYPE
  TMissileAttribute = Byte;
  TMissileState     = (
    //Missile point to target !
    Flying,
    //Missile explosion
    Explosion);

CONST
  MissileDamageFriendly    = $01;
  MissileDamageOnFly       = $02;
  MissileDamageOnExplosion = $04;
  MissileHasShadow         = $08;
//Missile point to exact target and explosion on it
  MissilePointTo           = $10;
  MissileStillFlyBeforeHit = $20;
  DefaultBaseMissileSpeed  = 4;

TYPE
  TLevel = Byte;

TYPE
  TItemAttribute = Byte;

CONST
  ItemUsedDirective = $01;

TYPE
  TSpellAttribute = Byte;

CONST
  SpellHasACycles = $01;
  SpellDirective  = $02;

TYPE
  TItem = (ItemNone,
           //
           //Weapon item class
           //
           //Worker class weapon
           ItemWeaponPeonAxe,
           //Foot man class weapon
           ItemWeaponBlade,
           ItemWeaponMagicBlade,
           ItemWeaponGunBlade,
           //Archer class weapon
           ItemWeaponBow,
           ItemWeaponLongBow,
           ItemWeaponMagicBow,
           //Berserker class weapon
           ItemWeaponBesAxe,
           ItemWeaponLongBesAxe,
           ItemWeaponMagicBesAxe,
           //
           ItemWeaponSpear,
           ItemWeaponMagicSpear,
           ItemWeaponSuperSpear,           
           //Grunt class weapon
           ItemWeaponBattleAxe,
           ItemWeaponMagicBattleAxe,
           ItemWeaponSuperBattleAxe,
           //Knight class weapon
           ItemWeaponHeavySpear,
           ItemWeaponMagicHeavySpear,
           //Ogre class weapon
           ItemWeaponGlove,
           ItemWeaponMagicGlove,
           //Mage class weapon
           ItemWeaponMagicStaff,
           //DeathKnight class weapon
           ItemWeaponDeathMagicStaff,
           //Ballista and catapul class weapon
           ItemWeaponBallistaBolt,
           ItemWeaponCatapulRock,
           //
           ItemWeaponHellFire,
           ItemWeaponDragonBreath,
           ItemWeaponGryphonHammer,
           //
           //Armor item class
           //
           ItemArmor1,
           ItemArmor2,
           ItemArmor3,
           ItemArmor4,
           ItemArmor5,
           ItemArmor6,
           //
           //Shield item class
           //
           ItemShield1,
           ItemShield2,
           ItemShield3,
           ItemShield4,
           ItemShield5,
           //
           //Helm item class
           //
           ItemHelm1,
           ItemHelm2,
           //
           //Boot item class
           //
           ItemBoot1,
           ItemBoot2,
           ItemBoot3,
           //
           //Decorate item class
           //
           ItemDecoration1,
           ItemDecoration2,
           ItemDecoration3,
           ItemDecoration4,
           ItemDecoration5,
           ItemDecoration6,
           ItemDecoration7,
           ItemDecoration8,
           ItemDecoration9,
           //
           ItemBansheeAdept,
           ItemBansheeMaster,
           ItemBookManual,
           ItemBookManual2,
           ItemBookManual3,
           ItemBookOfSummoning,
           ItemBookOfTheDead,
           ItemNecromancerAdept,
           ItemNecromancerMaster,
           ItemOrb,
           ItemOrbOfFire,
           ItemOrbOfFrost,
           ItemOrbOfLightning,
           ItemPotionBlue,
           ItemPotionBlueBig,
           ItemPotionBlueSmall,
           ItemPotionGreen,
           ItemPotionGreenSmall,
           ItemPotionPurple,
           ItemPotionRed,
           ItemScroll,
           ItemScrollOfHealing,
           ItemScrollOfProtection,
           ItemScrollOfTownPortal,
           ItemScrollUber,
           ItemSnazzyPotion,
           ItemSnazzyScroll,
           ItemSnazzyScrollGreen,
           ItemSnazzyScrollPurple,
           ItemSorceressAdept,
           ItemSorceressMaster,
           ItemSoulGem,
           ItemTome,
           ItemTomeBrown,
           ItemTomeRed
           );

CONST
  DefaultItemName : Array[TItem] of NameString = (
    'NONE',
    //Worker class weapon
    'WEAPONPEONAXE',
    //Foot man class weapon
    'WEAPONBLADE',
    'WEAPONMAGICBLADE',
    'WEAPONGUNBLADE',
    //Archer class weapon
    'WEAPONBOW',
    'WEAPONLONGBOW',
    'WEAPONMAGICBOW',
    //Berserker class weapon
    'WEAPONBESAXE',
    'WEAPONLONGBESAXE',
    'WEAPONMAGICBESAXE',
    //
    'WEAPONSPEAR',
    'WEAPONMAGICSPEAR',
    'WEAPONSUPERSPEAR',
    //Grunt class weapon
    'WEAPONBATTLEAXE',
    'WEAPONMAGICBATTLEAXE',
    'WEAPONSUPERBATTLEAXE',
    //Knight class weapon
    'WEAPONHEAVYSPEAR',
    'WEAPONMAGICHEAVYSPEAR',
    //Ogre class weapon
    'WEAPONGLOVE',
    'WEAPONMAGICGLOVE',
    //Mage class weapon
    'WEAPONMAGICSTAFF',
    //DeathKnight class weapon
    'WEAPONDEATHMAGICSTAFF',
    //Ballista and catapul class weapon
    'WEAPONBALLISTABOLT',
    'WEAPONCATAPULROCK',
    //
    'WEAPONHELLFIRE',
    'WEAPONDRAGONBREATH',
    'WEAPONGRYPHONHAMMER',
    //
    'ARMOR1',
    'ARMOR2',
    'ARMOR3',
    'ARMOR4',
    'ARMOR5',
    'ARMOR6',
    'SHIELD1',
    'SHIELD2',
    'SHIELD3',
    'SHIELD4',
    'SHIELD5',
    'HELM1',
    'HELM2',
    'BOOT1',
    'BOOT2',
    'BOOT3',
    'DECORATION1',
    'DECORATION2',
    'DECORATION3',
    'DECORATION4',
    'DECORATION5',
    'DECORATION6',
    'DECORATION7',
    'DECORATION8',
    'DECORATION9',
    //
    'BANSHEEADEPT',
    'BANSHEEMASTER',
    'BOOKMANUAL',
    'BOOKMANUAL2',
    'BOOKMANUAL3',
    'BOOKOFSUMMONING',
    'BOOKOFTHEDEAD',
    'NECROMANCERADEPT',
    'NECROMANCERMASTER',
    'ORB',
    'ORBOFFIRE',
    'ORBOFFROST',
    'ORBOFLIGHTNING',
    'POTIONBLUE',
    'POTIONBLUEBIG',
    'POTIONBLUESMALL',
    'POTIONGREEN',
    'POTIONGREENSMALL',
    'POTIONPURPLE',
    'POTIONRED',
    'SCROLL',
    'SCROLLOFHEALING',
    'SCROLLOFPROTECTION',
    'SCROLLOFTOWNPORTAL',
    'SCROLLUBER',
    'SNAZZYPOTION',
    'SNAZZYSCROLL',
    'SNAZZYSCROLLGREEN',
    'SNAZZYSCROLLPURPLE',
    'SORCERESSADEPT',
    'SORCERRSSMASTER',
    'SOULGEM',
    'TOME',
    'TOMEBROWN',
    'TOMERED');
//Item class
TYPE
  TItemClass = (OtherClass,
                //Class unit used to wearing
                WeaponClass,
                ArmorClass,
                ShieldClass,
                HelmClass,
                BootClass,
                DecorateClass,
                //Class which unit used for something
                MagicClass,
                ScrollClass,
                GenerationScrollClass,
                BookClass);

CONST
  ItemClassName : Array[TITemClass] of NameString = (
    '',
    'weapon item',
    'armor item',
    'shield item',
    'helm item',
    'boot item',
    'decorate item',
    'magic item',
    'scroll item',
    'generation scroll item',
    'book item');

//Skill of unit
TYPE
  TSkillCount    = 1..16;
  TQueueCount    = 1..8;
  TItemCount     = (WeaponItem,
                    ArmorItem,
                    ShieldItem,
                    HelmItem,
                    BootItem,
                    DecorateItem,
                    Item1,
                    Item2,
                    Item3,
                    Item4,
                    Item5,
                    Item6,
                    Item7,
                    Item8,
                    Item9);
  //Skill of orc and human are process same, but differ by icon
  TSkill         = (
    NoCmd,                    //Unit no have a command
    //Command never show at control
    CmdStanding1,             //Unit standing 1
    CmdStanding2,             //Unit standing 2
    CmdWasted,                //Unit wasted time
    CmdStartBuild,            //Unit in start build (wait for worker)
    CmdBuildComplete,         //Unit build complete
    CmdBuildWork,             //Unit underconstruction
    //Common skill
    CmdDead,                  //Unit dead
    CmdMove,                  //Unit in moving
    CmdFollow,                //Unit following other unit
    CmdStop,                  //Unit stop
    CmdHoldPosition,          //Unit holdposition
    CmdAttack,                //Unit going to attack
    CmdAttacking,             //Unit attacking
    CmdAttackingStand,        //Unit attacking but must standing
    CmdAttackGround,          //Unit attackground
    CmdAttackAt,              //Unit attack at (no where)
    CmdPatrol,                //Unit in patrol
    CmdHarvest,               //Unit harvest mine
    CmdMining,                //Unit in mine
    CmdReturnGold,            //Unit return gold to main hall
    CmdRallyPoint,            //Unit set rally point
    CmdPutItem,               //Unit put item
    CmdPickItem,              //Unit pick item
    CmdLoadUnit,              //Unit load unit
    CmdUnloadUnit,            //Unit unload unit
    CmdGoTransport,           //Unit go to transport
    //Building skill
    CmdBuildingHuman,         //Unit to building human struct
    CmdBuildingOrc,           //Unit to building orc struct
    CmdBuildingDevil,         //Unit to building devil struct
    CmdTrain,                 //Unit training
    CmdBuild,                 //Unit building
    CmdCastSpell,             //UnitCastSpell to other or using spell for self
    CmdCastSpelling,          //Unit while cast spell to other !
    CmdCancelBuilding,        //Command cancel when building
    CmdCancel,                //Command cancel, always last command
    //Editor command
    CmdPlaceUnit,             //Place unit
    CmdRemoveUnit,            //Remove unit
    CmdMoveUnit,              //Move unit selection
    CmdPlaceSmallTerrain,     //Place small terrain pattern
    CmdPlaceNormalTerrain,    //Place normal terrain pattern
    CmdPlaceHugeTerrain       //Place huge terrain pattern
    );
    
TYPE
  TSpell = (
    SpellNone,
    SpellGodMode,
    SpellFireBall,
    SpellLightning,
    SpellInvisibility,
    SpellHaste,
    SpellHealing,
    SpellUndead,
    SpellDecay,
    SpellBlizzard,
    SpellMoving,
    SpellCloak,
    SpellBloodLust,
    SpellExorcism
  );
//Skill for unit
TYPE
  TUnitSkill = Record
    Case Skill : TSkill of
      CmdBuild : (
       //If skill are train or build, unit to born is unit to building or training
       UnitToBorn   : TUnit;
      );
      CmdCastSpell : (
        SpellToCast : TSpell;
      );
  End;
  TUnitSkills = Array[TSkillCount] of TUnitSkill;
  
TYPE
//Type of effected to unit
  TEffected = (
    NoEffected,
    BloodBlust,
    Haste,
    LifeCountDown,
    Shield,
    Invisible,
    HeroSign0,
    HeroSign1,
    HeroSign2,
    HeroSign3,
    HeroSign4,
    HeroSign5,
    HeroSign6,
    HeroSign7,
    HeroSign8,
    HeroSign9
  );

CONST
  DefaultEffectName : Array[TEffected] of NameString = (
    'NOEFFECTED',
    'BLOODBLUST',
    'HASTE',
    'LIFECOUNTDOWN',
    'SHIELD',
    'INVISIBLE',
    'HEROSIGN0',
    'HEROSIGN1',
    'HEROSIGN2',
    'HEROSIGN3',
    'HEROSIGN4',
    'HEROSIGN5',
    'HEROSIGN6',
    'HEROSIGN7',
    'HEROSIGN8',
    'HEROSIGN9'
    );

TYPE
  TEffectKind = (
    EffectKindNone,
    EffectKindHeroSignFlash,
    EffectKindHeroSignFlashRotate,
    EffectKindHeroSignRotate,
    EffectKindHeroSignRotateZoom,
    EffectKindHeroSignZoom,
    EffectKindHeroSignZoomFlash,
    EffectKindHeroBurn
  );

CONST
  EffectInfinite     = -1;
  EffectNotEffective = 0;
//Unit effected by magic or oath
TYPE
  TUnitEffected = Record
    PrevEffect,NextEffect : TEffectedCount;
    LinkToUnit            : TUnitCount;
    TimeCountDown         : TTimeCount;
    Case Typer : TEffected of
      HeroSign0,
      HeroSign1,
      HeroSign2,
      HeroSign3,
      HeroSign4,
      HeroSign5,
      HeroSign6,
      HeroSign7,
      HeroSign8,
      HeroSign9 : (
        Angle,TransLevel : Byte;
        TransIncrease    : ShortInt;
      );
  End;
  TUnitItem = Record
    Typer  : TItem;
    Number : Byte;
  End;
  TUnitItems = Array[TItemCount] of TUnitItem;
  TItemSlotAvail = Array[TItemCount] of Boolean;

TYPE
  TUnitSawState = Word;

CONST
  UnitSawStateMask : Array[TClan] of TUnitSawState = (
    $0001,
    $0002,
    $0004,
    $0008,
    $0010,
    $0020,
    $0040,
    $0080,
    $0100,
    $0200,
    $0400,
    $0800,
    $1000,
    $2000,
    $4000,
    $8000);
  UnitSawStateMaskAll = $FFFF;

CONST
  DefaultSkillName : Array[TSkill] of NameString =
   ('',                     //No command
    '',                     //Standing1
    '',                     //Standing2
    '',                     //Wasted
    '',                     //StartBuild
    '',                     //BuildComplete
    '',                     //BuildWork
    '',                     //Dead
    'MOVE',
    '',                     //Follow
    'STOP',
    'HOLDPOSITION',
    'ATTACK',
    '',                     //Attacking
    '',                     //AttackingStand
    'ATTACKGROUND',
    '',                     //AttackAt
    'PATROL',
    'HARVEST',
    '',                     //Mining
    '',                     //ReturnGold
    'RALLYPOINT',
    '',                     //PutItem
    '',                     //PickItem
    '',                     //LoadUnit
    'UNLOAD',               //UnLoadAllUnit
    '',
    'BUILDHUMAN',
    'BUILDORC',
    'BUILDDEVIL',
    '',                     //Train
    '',                     //Build
    '',                     //CastSpell
    '',                     //CastSpelling
    'CANCELBUILDING',       //Cancel building
    'CANCEL',               //Cancel
    '',                     //Place unit
    '',                     //Remove unit
    '',                     //Move unit
    '',
    '',
    ''
    );

CONST
  DefaultSpellName : Array[TSpell] of NameString = (
    '',
    'GODMODE',
    'FIREBALL',
    'LIGHTNING',
    'INVISIBILITY',
    'HASTE',
    'HEALING',
    'UNDEAD',
    'DECAY',
    'BLIZZARD',
    'MOVING',
    'CLOAK',
    'BLOODLUST',
    'EXORCISM'
  );

TYPE
  TEditorCommand = (
    ECNone,
    ECTerrain,
    ECSelectUnit,
    ECNextUnit,
    ECPrevUnit,
    ECPlaceUnit,
    ECRemoveUnit,
    ECSelectClan,
    ECNextClan,
    ECPrevClan,
    ECSmallTerrain,
    ECNormalTerrain,
    ECHugeTerrain,
    ECSelectTerrain,
    ECNextTerrain,
    ECPrevTerrain
  );

TYPE
  TNumFrame   = Word;
  TFrameWait  = SmallInt;//Support for 3276 wait step (32767 div 10) too much !
  TFrameShift = Byte;
  TFrameStyle = Byte;
  TDamage     = SmallInt;//Damage type

TYPE
//Hitpoint type, 0 is dead, greater is active, -1 is dead, -2 is unit used to back
  THitPoint   = SmallInt;

CONST
  UnitDead           = 0;
  UnitUnUsedConst    = -1;
  UnitUsedToCallBack = -2;
  HitPointStart      = 1;

TYPE
  TUnitFrame  = ShortInt;//Unit frame type

CONST
  FrameUnUsed = -1;

TYPE
  TUnitWait      = TFrameWait;
  TDrawLevel     = 0..10;
  TLandSiteLevel = 1..2;

CONST
  DefaultUnitSpeedDecrease = 10;//Default unit speed decrase for unit wait
  DefaultComputerRangeInc  = 2;
  HasteTimeDefault         = 32000;
  BloodBlustTimeDefault    = 32000;
  UnitMiningTimeDefault    = 200;

//Unit animation frame option
CONST
  FrameMirrorH = 1;
  FrameHit     = 2;

TYPE
  TWeaponCanTarget = Byte;
//Support for weapon can target
CONST
  WeaponCanTargetLandUnit     = $0001;
  WeaponCanTargetAirUnit      = $0002;
  WeaponCanTargetMechanicUnit = $0004;
  WeaponCanTargetBuilding     = $0008;
  WeaponCanTargetUnderground  = $0010;//Now current value are in byte range

CONST
  DefaultWeaponCanTarget : Array[1..5] of Record
    Name  : NameString;
    Value : TWeaponCanTarget;
  End = (
    (Name:'LAND'       ;Value:WeaponCanTargetLandUnit),
    (Name:'AIR'        ;Value:WeaponCanTargetAirUnit),
    (Name:'MECHANIC'   ;Value:WeaponCanTargetMechanicUnit),
    (Name:'BUILDING'   ;Value:WeaponCanTargetBuilding),
    (Name:'UNDERGROUND';Value:WeaponCanTargetUnderground)
    );

CONST
//Some effected to unit gen unit attribute for faster checking
  UnitNoAttribute          = $00;
  UnitOnMapNum             = $01;//Unit place on mapnum
  UnitSelfControl          = $02;//Unit can self control, can be get a command
  UnitTakeATile            = $04;//Unit take a tile on map
  UnitInvisible            = $08;//Unit has a cloak, unit invisible
  UnitHaste                = $10;//Unit has a cloak, unit invisible
  UnitHasATarget           = $40;//Unit maybe has a target in range ?
  UnitDontEffectedByMagic  = $80;//Unit don't effected by damage magic

TYPE
  TUnitAttribute = Byte;

TYPE
  TBaseUnitAttribute = (
    AttributeNone,
    UnitIsHero,
    UnitIsInvisible,
    UnitIsLandUnit,
    UnitIsAirUnit,
    UnitIsUnderGroundUnit,
    UnitIsMechanic,
    UnitIsBuilding,
    UnitIsMonster,
    UnitHadMana,
    //Unit can have only one of two attribute, if unit can training, unit can't
    //carrier and if unit can carrier, unit can training !
    {UnitHadTrainingQueue,
    UnitHadCarrierQueue,}
    //Unit can training no need at first queue
    UnitFreeTraining,
    UnitCanSelectOnlyOne,
    UnitHasShadow,
    UnitInvulnerable,
    UnitIsDeposit,
    UnitIsGoldMine,
    UnitIsTransport,
    UnitCanTransported,
    UnitChangeShift,
    UnitTrueSight,
    UnitFullSight
    );
  TBaseAttribute = Set of TBaseUnitAttribute;

CONST
  DefaultBaseUnitAttributeStr : Array[TBaseUnitAttribute] of String = (
    '',
    'HERO',
    'INVISIBLE',
    'LANDUNIT',
    'AIRUNIT',
    'UNDERGROUNDUNIT',
    'MECHANICUNIT',
    'BUILDING',
    'MONSTER',
    'HADMANA',
    {'TRAININGQUEUE',
    'CARRIERQUEUE',}
    'FREETRAINING',
    'SELECTONLYONE',
    'UNITHASSHADOW',
    'INVULNERABLE',
    'UNITISDEPOSIT',
    'UNITISGOLDMINE',
    'UNITISTRANSPORT',
    'UNITCANTRANSPORTED',
    'UNITCHANGESHIFT',
    'UNITTRUESIGHT',
    'UNITFULLSIGHT'
  );

TYPE
  TCommonMessage = (
    CommonChat,
    CanNotCreateMoreUnit,
    CanNotPlaceBuildingHere,
    NotEnoughFood,
    NotEnoughResource,
    NotEnoughMana,
    UnitQueueIsFull,
    UnitCarrierIsFull,
    //Message from unit set command return
    MsgIDontKnow,
    MsgCanAttack,
    MsgTargetTooFar,
    MsgTargetTooNear,
    MsgUnitNotHasWeapon,
    MsgCantAttackInvulnerableTarget,
    MsgCantAttackLandUnit,
    MsgCantAttackAirUnit,
    MsgCantAttackMechanicUnit,
    MsgCantAttackBuilding,
    MsgCantAttackUnderground,
    MsgCantAttackNeutral,
    MsgCantCastSpellToUnit
  );

CONST
  CommonMessage : Array[TCommonMessage] of String = (
    '',
    'Can''t create more unit !',
    'Can''t place building here !',
    'Not enough food, build more farm !',
    'Not enough resource !',
    'Not enough mana !',
    'Unit queue is full !',
    'Unit carrier is full !',
    //
    'I don''t know !',
    '',
    'Target too far !',
    'Target too near !',
    'Unit not has a weapon !',
    'Can''t attack invulnerable target !',
    'Can''t attack land unit !',
    'Can''t attack air unit !',
    'Can''t attack mechanic unit !',
    'Can''t attack building !',
    'Can''t attack underground unit !',
    'Can''t attack neutral unit !',
    'Can''t cast spell to unit !'
  );
  
TYPE
  TUnitSetCmdReturn = (
    IDontKnow,
    CanAttack,
    TargetTooFar,
    TargetTooNear,
    UnitNotHasWeapon,
    CantAttackInvulnerableTarget,
    CantAttackLandUnit,
    CantAttackAirUnit,
    CantAttackMechanicUnit,
    CantAttackBuilding,
    CantAttackUnderground,
    CantAttackNeutral,
    CantCastSpellToUnit
  );

CONST
  CmdMessage : Array[TUnitSetCmdReturn] of TCommonMessage = (
    MsgIDontKnow,
    MsgCanAttack,
    MsgTargetTooFar,
    MsgTargetTooNear,
    MsgUnitNotHasWeapon,
    MsgCantAttackInvulnerableTarget,
    MsgCantAttackLandUnit,
    MsgCantAttackAirUnit,
    MsgCantAttackMechanicUnit,
    MsgCantAttackBuilding,
    MsgCantAttackUnderground,
    MsgCantAttackNeutral,
    MsgCantCastSpellToUnit
  );
//Definition for check gen new unit result
CONST
  ROk                   = 0;
  RNotEnoughFood        = -1;
  RNotEnoughResource    = -2;
  RCanNotCreateMoreUnit = -3;
  RQueueFull            = -4;

//Definition for group of units select
CONST
  MaxGroup         = 11;
  MaxUnitSelection = 16;
  SelectionButtonX = 4;
  SelectionButtonY = 4;
  SkillButtonX     = 4;//SkillButtonX*SkillButtonY = Counting of skill
  SkillButtonY     = 4;//
  ButtonReduceSize = 2;
  {$IfDef RandomUnitPosShift}
  ShiftRandom      = 3;
  ShiftRandomItem  = 16;
  {$EndIf}
  MaxWaterFrame    = 44;
//For unit shadow shifting when appear on screen
  ShadowShiftX     = 3;
  ShadowShiftY     = 48;
//Missile unit shadow shifting when appear on screen  
  MisShadowShiftX  = 3;
  MisShadowShiftY  = 8;

TYPE
  TUnitSelectionCount = 1..MaxUnitSelection;

CONST
  //Tool tips shifting with view screen left coord when show on screen
  ToolTipShiftX = 10;

CONST
  CommandLineLengthMax = 200;
  CommandLineSymbol    = '\';
  SeperatorSymbol      = ': ';
  MaxMessage           = 20;

TYPE
  TGroup = Array[TUnitSelectionCount] of TUnitCount;

TYPE
  TUnitQueue = Array[TQueueCount] of TUnitCount;
  TSavedUnitQueue = Record
    FromUnit : TUnitCount;
    Queue    : TUnitQueue;
  End;

TYPE
  TMouseStatus = (SNone,SSelection);

TYPE
  TResource  = (ResGold,ResTree,ResSpirit);
  TResources = Array[TResource] of LongInt;
  TUnitResources = Array[TResource] of SmallInt;

CONST
  DefaultResourceName : Array[TResource] of NameString= ('GOLD','TREE','SPIRIT');
  ResourceName        : Array[TResource] of NameString= ('Gold','Tree','Spirit');

//Constant for max units support on game
CONST
//Limit unit per clans, that food limit, not real unit counter limit
  LimitUnitsPerClan      = 90;
//Limit unit of force AI player can control
  LimitUnitsAICanControl = 50;
//Max units on game, can't exceed FastInt range because when type variable I'm always used FastInt
  MaxUnits               = 10000;
//Max missile on game
  MaxMissiles            = MaxUnits*3 div 2;
//Max effect on game
  MaxEffects             = MaxUnits*3;
  TestUnits              = 5000;
  DefaultGoldAmound      = 60000000;
//Unit saved path
  MaxUnitSavedPath          = 32;
  DistanceCanBuild          = 0;
  DistanceCanMining         = 0;
  DistanceCanReturnGold     = 0;
  DistanceCanPutItem        = 0;
  DistanceCanPickItem       = 0;
  DistanceCanLoadUnit       = 0;
  DistanceCanUnLoadUnit     = 0;
  DistanceCanRestartPatrol  = 4;
  DefaultGoldCollect        = 100;
//For path finding data variable
CONST
  MaxCloseSetRatio = 8;
  MaxOpenSetRatio  = 4;//4;
  DefaultMaxStep   : Integer = 500;//500;
  DefaultCrossWait = 20;
  MaxCost          = High(Integer);
  
TYPE
  TNode = Record
    Direction     : THeading;
    CostFromStart : Integer;
    {$IfNDef NoInGoal}
    InGoal        : Byte;
    {$EndIf}
  End;
  TOpen = Record
    X,Y    : SmallInt;
    {$IfNDef NoIndex}O,{$EndIf}
    C      : Integer;
    {$IfNDef NoCheck}
    Check  : Boolean;
    {$EndIf}
  End;

CONST
  FixedUnitSizeOnMiniMap    = 1;
  DefaultMapSize            = 512;
  DefaultMapTileX           = 32;
  DefaultMapTileY           = 32;
  //One tile saved four real tile
  LandTileSizeX             = DefaultMapTileX*2;
  LandTileSizeY             = DefaultMapTileY*2;
  MaxUnitSizeX              = 7;
  MaxUnitSizeY              = 7;
  MaxSeeRange               = 10;
  DefaultGoldMineFarSize    = 6;
  DefaultGoldMineAroundSize = 10;
  DefaultMinAIBuildRange    = 5;
  DefaultMaxAIBuildRange    = 30;
//Max unit frame animation  
  MaxUnitFrame           = 16;
  WastedTimeLimit        = 4;
{$IfDef LimitAirUnitOnTile}
//Max unit can stand in one tile
  MaxUnitOnTile          = 8;
{$EndIf}
  DefaultManaFactor      = 4;
TYPE
  TUnitMapped = Byte;

CONST
  UnitMappedUsedLand  = $01;
  UnitMappedUsedBuild = $02;

CONST
  PlaceOk    = 0;
  PlaceError = -1;

CONST
//Color value for show shadow, lighting, dark...
  Shadow50PercentValue = $80FFFFFF;
  ButtonInActiveColor  = $FFA0A0A0;

//Skill button position
CONST
  SkillButtonPos : Array[TSkillCount] of Record
    X,Y : Byte;
  End = ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:3;Y:0),
         (X:0;Y:1),(X:1;Y:1),(X:2;Y:1),(X:3;Y:1),
         (X:0;Y:2),(X:1;Y:2),(X:2;Y:2),(X:3;Y:2),
         (X:0;Y:3),(X:1;Y:3),(X:2;Y:3),(X:3;Y:3));
  UnitButtonPos : Array[TUnitSelectionCount] of Record
    X,Y : Byte;
  End = ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:3;Y:0),
         (X:0;Y:1),(X:1;Y:1),(X:2;Y:1),(X:3;Y:1),
         (X:0;Y:2),(X:1;Y:2),(X:2;Y:2),(X:3;Y:2),
         (X:0;Y:3),(X:1;Y:3),(X:2;Y:3),(X:3;Y:3));
  UnitQueuePos : Array[TQueueCount] of Record
    X,Y : Byte;
  End = ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:3;Y:0),
         (X:0;Y:1),(X:1;Y:1),(X:2;Y:1),(X:3;Y:1));
  UnitItemPos : Array[Item1..Item9] of Record
    X,Y : Byte;
  End = ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),
         (X:0;Y:1),(X:1;Y:1),(X:2;Y:1),
         (X:0;Y:2),(X:1;Y:2),(X:2;Y:2));
  UnitItemPos2 : Array[WeaponItem..DecorateItem] of Record
    X,Y : Byte;
  End = ((X:0;Y:0),  //Weapon
         (X:1;Y:1),  //Armor
         (X:2;Y:0),  //Shield
         (X:1;Y:0),  //Helmet
         (X:1;Y:2),  //Boot
         (X:2;Y:1)); //Decorate
  UnitItemPos2X : Array[WeaponItem..DecorateItem] of Record
    X,Y : FastInt;
  End = ((X:00;Y:16),  //Weapon
         (X:00;Y:00),  //Armor
         (X:00;Y:16),  //Shield
         (X:00;Y:00),  //Helmet
         (X:00;Y:00),  //Boot
         (X:00;Y:16)); //Decorate
//Which unit slot support for item class
CONST
  SlotSupport : Array[TItemCount] of TItemClass = (
    WeaponClass,  //Support WeaponClass
    ArmorClass,   //Support ArmorClass
    ShieldClass,  //Support ShieldClass
    HelmClass,    //Support HelmClass
    BootClass,    //Support BootClass
    DecorateClass,//Support DecorateClass
    OtherClass,   //Support all
    OtherClass,   //Support all
    OtherClass,   //Support all
    OtherClass,   //Support all
    OtherClass,   //Support all
    OtherClass,   //Support all
    OtherClass,   //Support all
    OtherClass,   //Support all
    OtherClass);  //Support all
  SlotName : Array[TItemCount] of NameString = (
    'Weapon slot',
    'Armor slot',
    'Shield slot',
    'Helm slot',
    'Boot slot',
    'Decorate slot',
    'Item slot 1',
    'Item slot 2',
    'Item slot 3',
    'Item slot 4',
    'Item slot 5',
    'Item slot 6',
    'Item slot 7',
    'Item slot 8',
    'Item slot 9');
  DefaultSlotName : Array[TItemCount] of NameString = (
    'WEAPON',
    'ARMOR',
    'SHIELD',
    'HELM',
    'BOOTS',
    'DECORATE',
    'ITEM1',
    'ITEM2',
    'ITEM3',
    'ITEM4',
    'ITEM5',
    'ITEM6',
    'ITEM7',
    'ITEM8',
    'ITEM9');

TYPE
  TMapTile = (
    Desert,
    Dirt,
    Grass,
    DarkGrass,
    Rock,
    DarkRock,
    Snow,
    Ice,
    Water
    );
  TMapTileValue  = Byte;
  TMapTileFrame  = Byte;
  TMapTileHeight = Byte;

CONST
  DefaultTileName : Array[TMapTile] of String[20] = (
    'DESERT',
    'DIRT',
    'GRASS',
    'DARKGRASS',
    'ROCK',
    'DARKROCK',
    'SNOW',
    'ICE',
    'WATER'
    );
    
CONST
  TileSetValue : Array[TMapTile] of Byte = (
    $01,
    $02,
    $04,
    $08,
    $10,
    $20,
    $40,
    $80,
    $00);

TYPE
  TAICheckResult = (
    AIOk,
    AINotEnoughArmy
  );

TYPE
  TForce = (
    FreedomForce,
    WorkerForce,
    AttackForce,
    DefenceForce,
    FindingForce,
    BuildingTownForce,
    BuildingTrainingForce,
    BuildingDefenceForce
  );

CONST
  DefaultForceName : Array[TForce] of NameString = (
    'FREEDOM',
    'WORKER',
    'ATTACKER',
    'DEFENCE',
    'FINDING',
    'BUILDINGTOWN',
    'BUILDINGTRAINING',
    'BUILDINGDEFENCE'
  );

TYPE
  TComputerCommandStatus = (
    CompCmdNone,
    CompCmdAttack,
    CompCmdBuild,
    CompCmdTrain,
    CompCmdFinding,
    CompCmdUpGrade,
    CompCmdWorker
  );

TYPE
  TUnitForce = Array[1..LimitUnitsAICanControl] of TUnitCount;

TYPE
//Counting of AI main town, support for three main town !  
  TAITownCounter = (Town1,Town2,Town3);
  TAIUnitLinkCount = (Link1,Link2,Link3);

TYPE
  TAIAttackStyle = (
    AttackStyle0,
    AttackStyle1,
    AttackStyle2,
    AttackStyle3,
    AttackStyle4,
    AttackStyle5,
    AttackStyle6,
    AttackStyle7,
    AttackStyle8,
    AttackStyle9
  );

CONST
  DefaultAISleep       = 200;
  DefaultAIAttackSleep = 2000;

TYPE
  TAIData = Record
    //AI active now ?
    AIActive                          : Boolean;
    //AI command available
    AICmdAvail,AICmdComplete          : Array[TComputerCommandStatus] of Boolean;
    //AI command sleeping
    AICmdSleep                        : Array[TComputerCommandStatus] of LongInt;
    //AI main town
    AIMainTown                        : TUnitCount;
    AIMainGoldMine                    : TUnitCount;
    AIRallyPoint                      : TPoint;
    //My town under attack ! SHIT !!!!!
    AIOwnTownUnderAttack              : Boolean;
    AIFoundEnemyAt                    : TPoint;
    //Waiting for ?
    WaitForAttackComplete             : Boolean;
    //
    AIAttackStyle                     : TAIAttackStyle;
    //Now who enemy ?
    CurrentEnemy                      : TClan;
    //How many unit needed ?
    UnitNeed,UnitNeedForAttack        : Array[TUnit] of FastInt;
    //Which unit can build own unit ? This back reference.
    UnitCanBuild                      : Array[TAIUnitLinkCount,TUnit] of TUnit;
    //Force of AI ?
    AIForce                           : Array[TForce] of TUnitForce;
    ForceCount                        : Array[TForce] of TUnitCount;
  End;

CONST
  AIPlaceDistance = 3;

TYPE
  TMapNum  = TUnitCount;
  TMapAttr = Byte;

TYPE
  TTileAttribute = Set of (TileCantStandOn,TileCantBuildOn);

CONST
  CaptionSize         = 26;
  MainMenuSizeX       = 400;
  MainMenuSizeY       = 350;
  MainMenuButtonSizeX = 250;
  MainMenuButtonSizeY = 30;
  GameMenuSizeX       = 300;
  GameMenuSizeY       = 350;
  GameMenuButtonSizeX = 250;
  GameMenuButtonSizeY = 30;
  GameMenuQuitSizeX   = 300;
  GameMenuQuitSizeY   = 200;
  GameMessageSizeX    = 350;
  GameMessageSizeY    = 120;
  GameSaveLoadSizeX   = 350;
  GameSaveLoadSizeY   = 420;
  HealthBarHeight     = 3;
  ToolTipFadeStart    = 0;
  ToolTipFadeEnd      = 128;
  ToolTipFadeSpeed    = 8;
  MessageFadeSpeed    = 8;

TYPE
  TMenuSelectResult = (
    //Mainmenu
    MenuPlaySingle,
    MenuPlayMulti,
    MenuGameOption,
    MenuGameEditor,
    MenuGameInfo,
    MenuQuitGame,
    //Play single menu
    MenuPlayCampaign,
    MenuPlayCustom,
    MenuLoadGame,
    MenuReviewgame,
    //Play multi
    //On game menu
    MenuOGReturnToGame,
    MenuOGPauseGame,
    MenuOGSaveGame,
    MenuOGLoadGame,
    MenuOGGameOption,
    MenuOGQuitGame,
    MenuOGQuitGameToMainMenu,
    MenuOGQuitGameToOS,
    MenuOGQuitGameCancel,
    //Save slot
    MenuOGSaveSlot1,
    MenuOGSaveSlot2,
    MenuOGSaveSlot3,
    MenuOGSaveSlot4,
    MenuOGSaveSlot5,
    MenuOGSaveSlot6,
    MenuOGSaveSlot7,
    MenuOGSaveSlot8,
    //Load slot
    MenuOGLoadSlot1,
    MenuOGLoadSlot2,
    MenuOGLoadSlot3,
    MenuOGLoadSlot4,
    MenuOGLoadSlot5,
    MenuOGLoadSlot6,
    MenuOGLoadSlot7,
    MenuOGLoadSlot8,
    MenuNone);
  TMenuAttr = (MenuCheckBound,MenuCheckPoint);
  TGameResult = (
    NoResult,
    QuitByMenu,
    Surrender,
    RestartGame,
    Lost,
    Victory
  );

CONST
  MenuStr      = 'Menu';
  PauseStr     = 'Pause';
  DiplomacyStr = 'Diplomacy';

TYPE
  TGameButtonTyper = (
    ButtonMenu,
    ButtonUnitSelected,
    ButtonUnitCommand,
    ButtonUnitItem,
    ButtonUnitQueue,
    ButtonEditorCommand,
    ButtonEditorUnit
  );

TYPE
  TButtonMenuTyper = (
    GameButtonMenu,
    GameButtonPause,
    GameButtonDiplomacy);
  TLoadScriptRes = (
    LoadScriptSuccessful,
    CantLocateScriptFile,
    CantCompileScriptFile,
    CantExportCompileCode,
    CantImportCompileCode
  );
{CONST
  TileCatchLandUnit = $01;}

CONST
//Land unit on map
  MapUsedByLandUnit = $01;
//Land unit on map
  MapUsedByGoldMine = $02;
//Map don't visited
  MapDontVisited    = $04;
//Map don't visible
  MapDontVisible    = $08;
//Time process rating
CONST
  InputTimeRate                              = 10;
  MessageBoardTimeRate                       = 40;
  FogUpdateTimeRate                          = 3000;
  WaterUpDateTimeRate                        = 100;
  ScreenTimeRate                             : FastInt = 33;//40;
  MaxScreenTimeRate                          = 50;
  MinScreenTimeRate                          = -1;
  UnitRate                                   : FastInt = 16;//10;//20;
  MaxUnitRate                                = 50;
  MinUnitRate                                = -1;
  FindPathTime                               = 13;
  MapKeyScrollSpeed                          = 1;
  //Range defined is a close range between two unit
  DefaultTargetClose                         = 0;
  MinTransparent                             = 48;
  MaxTransparent                             = 252;
  DefaultTransparentSpeed                    = 4;
  FrameBuildRate                             = 20;
  FrameManaGrowRate                          = 40;
  FrameHitpointGrowRate                      = 40;
  FrameFindTargetRate                        = 100;
  FrameChangeHeadingRate                     = 100;
  FrameTimeGrowRate                          = 40;
  FrameScriptCheckGameCondition              = 1000;
//String constant for animation script loading
CONST
  UnitHaveMaskStr             = '[UNITHAVEMASK]';
  UnitMaskStr                 = '[UNITMASK]';
  UsingSameOtherUnitStr       = '[USINGSAME]';
  UsingFromListFileStr        = '[USINGLIST]';
  UsingFromFileStr            = '[USINGFILE]';
  TransparentColorStr         = '[TRANSPARENTCOLORRGB]';
  ImageInfoStr                = '[IMAGEINFO]';
  StandScriptStr              = '[[STANDSCRIPT]]';    //'[[Stand script]]';
  Stand1ScriptStr             = '[[STAND1SCRIPT]]';   //'[[Stand1 script]]';
  Stand2ScriptStr             = '[[STAND2SCRIPT]]';   //'[[Stand2 script]]';
  WastedScriptStr             = '[[WASTEDSCRIPT]]';   //'[[Wasted script]]';
  CastSpellScriptStr          = '[[CASTSPELLSCRIPT]]';//'[[Castspell script]]';
  RunScriptStr                = '[[RUNSCRIPT]]';      //'[[Run script]]';
  AttackScriptStr             = '[[ATTACKSCRIPT]]';   //'[[Attack script]]';
  Attack2ScriptStr            = '[[ATTACK2SCRIPT]]';  //'[[Attack2 script]]';
  DeadScriptStr               = '[[DEADSCRIPT]]';     //'[[Dead script]]';
  FlyingScriptStr             = '[[FLYINGSCRIPT]]';
  ExplosionScriptStr          = '[[EXPLOSIONSCRIPT]]';
////For setting in UnitSetting
CONST
//For begin configure unit property
  SettingForUnitStr                    = 'SETTINGFORUNIT';//
//For end setting unit
  EndSettingForUnitStr                 = 'ENDSETTING';//
//For setting name of unit
  NameStr                              = 'NAME';//
//For setting hit point of unit
  HitPointStr                          = 'HITPOINT';//
//For setting see range of unit
  UnitSeeRangeStr                      = 'SEERANGE';//
//For setting base damage of unit
  UnitBaseDamageStr                    = 'BASEDAMAGE';//
//For setting base item of unit
  UnitBaseItemStr                      = 'BASEITEM';//
//For setting base slot avail of unit
  UnitItemSlotAvail                    = 'ITEMSLOTAVAIL';
//For setting unit food used
  UnitFoodUsedStr                      = 'FOODUSED';//
//For setting unit food gain
  UnitFoodGainStr                      = 'FOODGAIN';//
//For setting unit have money
  UnitMoneyStr                         = 'MONEY';//
//For setting unit point
  UnitPointStr                         = 'POINT';//
//For setting unit cost for build
  UnitCostStr                          = 'COST';//
//For setting unit time cost for build
  UnitTimeCostStr                      = 'TIMECOST';//
//For setting unit max mana
  UnitManaMaxStr                       = 'MAXMANA';//
//For setting unit mana grow per game time, not percent
  UnitManaGrowStr                      = 'MANAGROW';//
//For setting unit hitpoint grow per game time, not percent
  UnitHitPointGrowStr                  = 'HITPOINTGROW';//
//For setting unit size
  UnitSizeStr                          = 'SIZE';//
//For mapped array
  UnitMappedStr                        = 'UNITMAP';
  UnitMappedBlankStr                   = 'BLANK';
  UnitMappedFillStr                    = 'FILL';
//For setting unit hotkey
  UnitHotKeyStr                        = 'HOTKEY';//
//For setting unit skill
  UnitSkillStr                         = 'SKILL';//
//For setting unit attribute
  UnitAttributeStr                     = 'ATTRIBUTE';//
//For unit transfer before death
  UnitTransferBeforeDeathStr           = 'BEFOREDEATH';//
//For setting can build and trainning
  UnitCanBuildStr                      = 'CANBUILD';
  UnitCanCastStr                       = 'CANCASTSPELL';
  UnitCanTrainStr                      = 'CANTRAIN';
//For setting unit draw level
  UnitDrawLevelStr                     = 'DRAWLEVEL';
//For setting unit force
  UnitForceStr                         = 'FORCE';
//For setting unit command when mouse click
  UnitCmdRightMouseClickNoTargetStr    = 'COMMANDRIGHTMOUSENOTARGET';
  UnitCmdRightMouseClickTargetAllyStr  = 'COMMANDRIGHTMOUSETARGETALLY';
  UnitCmdRightMouseClickTargetEnemyStr = 'COMMANDRIGHTMOUSETARGETENEMY';
//For unit tooltip, unit tooltip less than 255 characters !
  UnitToolTipStr                       = 'TOOLTIP';
//For take all unit property in all clans like unit in on clan
  EveryUnitInClansSameClanStr          = 'EVERYUNITINCLANSSAMECLAN';
////For setting in ItemSetting
CONST
  ItemSettingStr     = 'ITEMSETTING';
  EndItemSettingStr  = 'ENDSETTING';
  ItemNameStr        = 'NAME';
  ItemToolTipStr     = 'TOOLTIP';
  ItemCanTarget      = 'CANTARGET';
  ItemMissileStr     = 'MISSILE';
  ItemMaxRangeStr    = 'MAXRANGE';
  ItemMinRangeStr    = 'MINRANGE';
  ItemDamageAddOnStr = 'DAMAGE';
  AllStr             = 'ALL';
  LikeStr            = 'LIKE';
////For setting in unit icon and skill icon
CONST
  UnitNameStr        = 'UNIT';
  SkillNameStr       = 'SKILL';
  SpellNameStr       = 'SPELL';
  ItemsNameStr       = 'ITEM';
  EffectNameStr      = 'EFFECT';
  FileNameStr        = 'FILENAME';
  ImageFileStr       = 'IMAGEFILE';
  AtStr              = 'AT';
////For setting in tile frames and land site...
CONST
  TileStr            = 'TILE';
  ConstructorLandStr = 'LANDSITE';

CONST
  SeparatorSymbol = ':';
  SkipSymbol      = '#';

CONST
  LoadingFailedStr = 'Loading failed ';

TYPE
  TCheatStatus = (
    NoFog,
    OnScreen,
    NoFoodLimit,
    NoCost
  );
{$IfDef Debug}
TYPE
  TDebugStatus = (
    ShowVideoInfo,
    ShowClanInfo,
    ShowMapInfo,
    ShowGameInfo,
    ShowUnitInfo,
    ShowScriptDebug
  );
{$EndIf}
TYPE
  TSelectedDraw       = (
    Rect,
    AlphaRect
  );
  TSelectedAroundUnit = (
    Square,
    Ellipse
  );
  TMiniMapDraw        = (
    ShowPixel,
    ShowRect
  );
  TStyle = (
    StyleLeftText,
    StyleCenterText,
    StyleRightText
  );

CONST
  TmpSizeX = 256;
  TmpSizeY = 256;
//Editor constant
CONST
  PatternSmallSize  = 1;
  PatternNormalSize = 3;
  PatternHugeSize   = 5;

CONST
  MsgCanPutBackItem   = '%s not support %s, can''t put back item !';
  MsgNotSupport       = '%s not support %s';
  MsgWeaponItemHint   = 'Weapon unit used#Only support weapon class';
  MsgArmorItemHint    = 'Armor unit wear#Only support armor class';
  MsgShieldItemHint   = 'Shield unit used#Only support shield class';
  MsgHelmItemHint     = 'Helm unit used#Only support helm class';
  MsgBootItemHint     = 'Boots unit used#Only support helm class';
  MsgDecorateItemHint = 'Decoration for unit#Only support decoration class';
  MsgFreeItemHint     = 'Free item slot#You can put your item here';

CONST
  SinglePlayStr       = 'Single play';
  MultiPlayStr        = 'Multi play';
  OptionsStr          = 'Options';
  EditorStr           = 'Editor';
  CreditStr           = 'Credits';
  QuitStr             = 'Quit game';
  QuitToMenuStr       = 'Quit to main menu';
  QuitToOSStr         = 'Quit to OS';
  CancelStr           = 'Cancel';
  ReturnToGameStr     = 'Return to game';
  PauseGameStr        = 'Pause game';
  LoadGameStr         = 'Load game';
  SaveGameStr         = 'Save game';
  VictoryStr          = 'You are victory !';
  SaveStr             = 'Save Game';
  LoadStr             = 'Load Game';
  OkStr               = 'Ok';
  ContinueGameStr     = 'Continue game';
  DoYouWantToQuitStr  = 'Do you want to quit ?';
  Slot1Str            = 'Slot 1';
  Slot2Str            = 'Slot 2';
  Slot3Str            = 'Slot 3';
  Slot4Str            = 'Slot 4';
  Slot5Str            = 'Slot 5';
  Slot6Str            = 'Slot 6';
  Slot7Str            = 'Slot 7';
  Slot8Str            = 'Slot 8';

FUNCTION  InRange(X,Y,X1,Y1,X2,Y2 : Integer) : Boolean;
PROCEDURE ReduceToRange(Var X : Word;X1,X2 : Integer); Overload;
PROCEDURE ReduceToRange(Var X : SmallInt;X1,X2 : Integer); Overload;
PROCEDURE ReduceToRange(Var X : Integer;X1,X2 : Integer); Overload;
PROCEDURE Swap(Var X1,X2 : FastInt);
FUNCTION  UpCaseStr(St : String) : String;
FUNCTION  GetFirstComment(Var St : String) : String;
FUNCTION  GetNumber(Var St : String) : Integer;
FUNCTION  StrippedFirstLastSpace(Var St : String) : String;
FUNCTION  StrippedAllSpace(Var St : String) : String;
FUNCTION  StrippedAllSpaceAndUpCase(Var St : String) : String;
FUNCTION  ToInt(St : String) : Integer;
FUNCTION  RandomRange(Min,Max : Integer) : Integer;
FUNCTION  FileExist(FileName : String) : Boolean;

IMPLEMENTATION

FUNCTION  InRange(X,Y,X1,Y1,X2,Y2 : Integer) : Boolean;
  Begin
    Result:=(X>=X1) and (Y>=Y1) and (X<=X2) and (Y<=Y2);
  End;

PROCEDURE ReduceToRange(Var X : Word;X1,X2 : Integer);
  Begin
    If X<X1 then X:=X1;
    If X>X2 then X:=X2;
  End;

PROCEDURE ReduceToRange(Var X : SmallInt;X1,X2 : Integer);
  Begin
    If X<X1 then X:=X1;
    If X>X2 then X:=X2;
  End;

PROCEDURE ReduceToRange(Var X : Integer;X1,X2 : Integer);
  Begin
    If X<X1 then X:=X1;
    If X>X2 then X:=X2;
  End;

PROCEDURE Swap(Var X1,X2 : FastInt);
  Var Temp : FastInt;
  Begin
    If X1>X2 then
      Begin
        Temp:=X1;
        X1:=X2;
        X2:=Temp;
      End;
  End;

FUNCTION UpCaseStr(St : String) : String;
  Var Z : Byte;
  Begin
    For Z:=1 to Length(St) do St[Z]:=UpCase(St[Z]); 
    Result:=St;
  End;

FUNCTION  GetFirstComment(Var St : String) : String;
  Var Str : String;
  Begin
    If System.Pos(SeparatorSymbol,St)>0 then
      Begin
        Str:=Copy(St,1,System.Pos(SeparatorSymbol,St)-1);
        Delete(St,1,System.Pos(SeparatorSymbol,St));
      End
    Else
      Begin
        Str:=St;
        St:='';
      End;
    Result:=Str;
  End;

FUNCTION  GetNumber(Var St : String) : Integer;
  Var Num,Code : Integer;
      Sub      : String;
  Begin
    Sub:=GetFirstComment(St);
    Val(Sub,Num,Code);
    If Code<>0 then Result:=-1
    Else Result:=Num;
  End;

FUNCTION  StrippedFirstLastSpace(Var St : String) : String;
  Begin
    While St[1]=' ' do Delete(St,1,1);
    While St[Length(St)]=' ' do Delete(St,Length(St),1);
    Result:=St;
  End;

FUNCTION  StrippedAllSpace(Var St : String) : String;
  Begin
    While System.Pos(' ',St)>0 do
      Delete(St,System.Pos(' ',St),1);
    Result:=St;
  End;

FUNCTION  StrippedAllSpaceAndUpCase(Var St : String) : String;
  Var Z : Byte;
  Begin
    While System.Pos(' ',St)>0 do
      Delete(St,System.Pos(' ',St),1);
    For Z:=1 to Length(St) do St[Z]:=UpCase(St[Z]);
    Result:=St;
  End;

FUNCTION  ToInt(St : String) : Integer;
  Begin
    Result:=StrToInt(St);
  End;
  {Var Temp,Code : Integer;
  Begin
    Val(St,Temp,Code);
    If Code<>0 then Result:=0
    Else Result:=Temp;
  End;}

FUNCTION  RandomRange(Min,Max : Integer) : Integer;
  Begin
    Result:=Random(Max-Min)+Min;
  End;
  
FUNCTION  FileExist(FileName : String) : Boolean;
  Var F : File;
  Begin
    Assign(F,FileName);
    Reset(F,1);
    Result:=IOResult=0;
    Close(F);
  End;

INITIALIZATION
  RandSeed:=11012012;
END.