UNIT LOCDraw;
{$Include GlobalDefines.Inc}
{$Define SafeLockMiniMap}
INTERFACE

USES Windows,
     MMSystem,
     SysUtils,
     DirectXGraphics,
     AvenusBase,
     Avenus3D,
     FireStormDLL,
     LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCEditor,
     LOCMenu;
//PalSwitch type
TYPE
  PPalSwitch = ^TPalSwitch;
  TPalSwitch = Array[1..12] of Word;
//PalSwitch constant
CONST
  PalSwitch : Array[TClan] of TPalSwitch =
              ((40960,44032,48128,53248,0,0,0,0,0,0,0,0),//C1
               (32777,32846,32948,34105,0,0,0,0,0,0,0,0),//C2
               (32929,33093,35339,38610,0,0,0,0,0,0,0,0),//C3
               (37925,43081,47312,52534,0,0,0,0,0,0,0,0),//C4
               (46209,52450,57698,64002,0,0,0,0,0,0,0,0),//C5
               (33826,34884,35941,38055,0,0,0,0,0,0,0,0),//C6
               (37033,43344,52854,62364,0,0,0,0,0,0,0,0),//C7
               (44224,46336,48448,50561,0,0,0,0,0,0,0,0),//C8
               //Unsolve
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C9
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C10
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C11
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C12
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C13
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C14
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C15
               //(32777,32845,32914,33016,0,0,0,0,0,0,0,0),//C16
               (32777,32845,32914,33016,0,0,0,0,0,0,0,0));//Gaia
  TerrainBaseColor : Array[TMapTile,1..3] of Byte =
    ((132,065,000),//Desert
     (126,088,049),//Dirt
     (000,192,000),//Grass
     (000,128,000),//DarkGrass
     (255,255,255),//Rock
     (255,255,255),//DarkRock
     (140,142,156),//Snow
     (148,150,165),//Ice
     (000,000,000) //Water
     );
//RLESprite type, for fill change color of units
TYPE
  TRLESprite = Record
    DataSize : Integer;
    Data     : Pointer;
  End;
  TData = Word;

//Images frame of unit
TYPE
  TAnimationScript = Record
    FrameNum   : TNumFrame;
    FrameWait  : TFrameWait;
    FrameShift : TFrameShift;
    FrameStyle : TFrameStyle;
  End;
  TAniScript = Record
    Script  : Array[THeading] of Array of TAnimationScript;
    Leng    : Array[THeading] of Word;
  End;
  TUnitAnimation = Record
    NumofFrame                        : TNumFrame;
    ShiftX,ShiftY,SizeX,SizeY         : SmallInt;
    TransparentColor                  : LongWord;
    MaskColor                         : Word;
    UnitHaveMask                      : Boolean;
    Images                            : TAvenusTextureImages;
    Sprites                           : Array of TRLESprite;
    {$IfDef Debug}
    MemUsed                           : Integer;
    {$EndIf}
    {$IfDef AutoCropImageOnLoading}
    ImagesShiftX,ImagesShiftY         : Array[0..MaxUnitFrame] of SmallInt;
    {$EndIf}
    StandScript,StandScript1,StandScript2,WastedScript,CastSpellScript,
    RunScript,AttackScript,Attack2Script,DeadScript : TAniScript;
  End;
  TUnitAnimations = Array[TUnit] of TUnitAnimation;
  TUnitIcons = Record
    Images  : TAvenusTextureImages;
    IconNum : Array[TUnit] of Integer;
    Sprites : Array[TUnit] of TRLESprite;
  End;
  TSkillIcons = Record
    Images  : TAvenusTextureImages;
    IconNum : Array[TSkill] of Integer;
    //Skill no need for transfer color ?
    //Sprites : Array[TSkill] of TRLESprite;
  End;
  TItemIcons = Record
    Images  : TAvenusTextureImages;
    IconNum : Array[TItem] of Integer;
  End;
  TSpellIcons = Record
    Images  : TAvenusTextureImages;
    IconNum : Array[TSpell] of Integer;
    //Skill no need for transfer color ?
    //Sprites : Array[TSkill] of TRLESprite;
  End;
  TEffectedImages = Record
    Images   : TAvenusTextureImages;
    ImageNum : Array[TEffected] of Integer;
  End;
  TTerrainImages = Record
    Images              : TAvenusTextureImages;
    FramePos,FrameCount : Array[TMapTile] of Integer;
    //WaterImages         : TAvenusTextureImages;
  End;
  TMissileScript = Record
    FramePos  : Array[THeading] of Array of Record
      FrameNum   : TNumFrame;
      FrameWait  : TFrameWait;
      FrameStyle : TFrameStyle;
    End;
    FrameLeng : Array[THeading] of Word;
  End;
  TMissileImage = Record
    Images                       : TAvenusTextureImages;
    NumFrame,SizeX,SizeY,
    ShiftX,ShiftY                : SmallInt;
    MaskColor                    : Word;
    TransColor                   : LongWord;
    FlyingScript,ExplosionScript : TMissileScript;
  End;
  TMissileAnimations = Array[TMissile] of TMissileImage;

TYPE
  TLOCDraw = Class
    Public
    MyScreen                        : TLOCScreen;
    MyShow                          : TLOCShow;
    MyUnits                         : TLOCUnits;
    MyWorld                         : TLOCWorld;
    MyMenu                          : TLOCMenu;
    MyEditor                        : TLOCEditor;
    //Color for clan signal in map
    ClansColor,ClansColor32         : Array[TClan] of LongWord;
    //Color for terrain signal in map
    UnitDraw                        : Array[1..MaxUnits] of Boolean;
    //Unit animation script
    UnitAnimations                  : TUnitAnimations;
    //Missile animation
    MissileAnimations               : TMissileAnimations;
    //Unit icons
    UnitIcons                       : TUnitIcons;
    //Skill icons
    SkillIcons       : TSkillIcons;
    //Item icons
    ItemIcons        : TItemIcons;
    //Spell icons
    SpellIcons       : TSpellIcons;
    //Effected images
    EffectedImages   : TEffectedImages;
    //Terrain images
    TerrainImages    : TTerrainImages;
    WaterAlpha       : LongWord;
    //Other frames
    OtherImage       : TAvenusTextureImages;
    //Draw style
    MouseSelectStyle : TSelectedDraw;
    UnitSelectStyle  : TSelectedAroundUnit;
    MiniMapStyle     : TMiniMapDraw;
    MiniMapImage     : TAvenusTextureImages;
    MiniMapColor,MiniMapDarkColor : Array of Array of LongWord;
    DefaultPal : TPalSwitch;
    //
    TempImage        : TAvenusTextureImages;
    //
    {$IfDef Debug}
    DebugLinePos     : FastInt;
    AniScriptMemUsed : Integer;
    {$EndIf}
    //Remember ColorLightning never had Alpha bit !
    //And shadow no need to calculate lightning !
    ColorLightning    : Array[TDayTime] of LongWord;
    ColorAlphaBlend   : LongWord;
    Constructor Create(Screen : TLOCScreen;
                       Show : TLOCShow;
                       Units : TLOCUnits;
                       World : TLOCWorld;
                       Editor : TLOCEditor;
                       Menu : TLOCMenu);
    Destructor Destroy;OverRide;
    Procedure RestartData;
    Procedure RefreshMiniMap; OverLoad;
    Procedure RefreshMiniMap(X1,Y1,X2,Y2 : Integer); OverLoad;
    //Setup all data
    Procedure SetupData;
    //Loading images data
    Procedure LoadingData;
    Procedure LoadUnitData;
    Procedure LoadTerrainData;
    //Terrain render method
    Procedure RenderTile(X,Y,TileX,TileY : Integer);
    Procedure TerrainRender;
    //Render effective
    Procedure DrawEffect(EffNum : TEffectedCount);
    Procedure GetRealUnitPos(UnitNum : TUnitCount;Var DX,DY : Integer);
    //Draw specific unit
    Procedure DrawUnit(UnitNum : TUnitCount);
    Procedure DrawUnitSelected(UnitNum : TUnitCount);
    Function  UnitCheckedPoint(UnitNum : TUnitCount;X,Y,MX,MY : FastInt) : Boolean;
    Procedure DrawAllUnitLevel(PosX,PosY : FastInt;Level : TDrawLevel);
    //Draw all unit selected, also draw a part of effective link to this unit
    Procedure DrawAllUnitSelectedLevel(PosX,PosY : FastInt;Level : TDrawLevel);
    //Draw missiles
    Procedure DrawMissile(MissileNum : TMissileCount);
    //Draw unit under fog on tile
    Procedure DrawUnitUnderFog(PosX,PosY : FastInt);
    //Draw viewmap (mini map)
    Procedure DrawViewMap;
    //Draw fog
    Procedure DrawFogMap;
    //Draw view screen
    Procedure DrawViewScreen;
    Procedure DrawUserInterface;
    Procedure DrawGameButton;
    Procedure DrawGameMenuButton(Button : TGameButton);
    Procedure DrawGameCommandButton(Button : TGameButton);
    Procedure DrawUnitSelectButton(Button : TGameButton);
    Procedure DrawUnitQueueButton(Button : TGameButton);
    Procedure DrawUnitItemButton(Button : TGameButton);
    Procedure DrawEditorCommandButton(Button : TGameButton);
    //
    Procedure DrawUnitButton(UnitNum : FastInt;ButtonNum : FastInt);
    Procedure DrawUnitInfo(UnitNum : FastInt);
    Procedure DrawResourceButton;
    Procedure DrawWeaponButton;
    Procedure DrawItemButton;
    Procedure DrawToolTips(X,Y : Integer;Text : Array of String);
    //Draw button
    Procedure DrawButton;
    //Draw button tool tips
    Procedure DrawButtonToolTips;
    //Draw commandline
    Procedure DrawCommandLine;
    //Draw mouse
    Procedure DrawMouse;
    {$IfDef Debug}
    //Show debug information
    Procedure DebugLine(Msg : String;Color : LongWord);
    Procedure ShowDebug(Times,Frames : Integer);
    Procedure DrawDebug;
    {$EndIf}
    //
    Procedure DrawScreen;
    //Image data loading
    Function  GetTileByName(Name : String) : TMapTile;
    Procedure UnitAnimationLoad(UnitType : TUnit;FileName : String);
    Procedure UnitIconLoad(FileName : String);
    Procedure SkillIconLoad(FileName : String);
    Procedure SpellIconLoad(FileName : String);
    Procedure ItemIconLoad(FileName : String);
    Procedure MissileAnimationLoad(Typer : TMissile;FileName : String);
    Procedure EffectedAnimationLoad(FileName : String);
    //Only work with textures 16 bit
    Function  ReadPixel(Sprite : TAvenusTextureImages;SprNum,X,Y : Integer;DefaultColor : LongWord) : LongWord;
    Procedure ErrorMessage(Msg : String);
  End;
//Never used color 0, 0 be to 1
//Only support 16bit image
PROCEDURE MakeRLE(Var Sprite : TRLESprite;Buffer : Pointer;BufferSize : Integer;
                  MC : LongWord;PalSwitch : TPalSwitch);
PROCEDURE PasterSprite(Src,Dst : Pointer;Size : Integer;Mask : Word;Pal : PPalSwitch);  

VAR
  GameDraw : TLOCDraw;
  
IMPLEMENTATION

PROCEDURE MakeRLE(Var Sprite : TRLESprite;Buffer : Pointer;BufferSize : Integer;
                  MC : LongWord;PalSwitch : TPalSwitch);
  Type ArrayofSmallInt = Array[0..1000000] of TData;
  Var I,Z,Run,Size,TmpSize : Integer;
      Tmp                  : ^ArrayofSmallInt;
      Color,Index          : LongWord;
  Begin
    With Sprite do
      Begin
        //MaskColor:=MC;
        Size:=0;
        TmpSize:=BufferSize;
        GetMem(Tmp,TmpSize*SizeOf(TData));
        FillChar(Tmp^,TmpSize*SizeOf(TData),0);
        Run:=-1;
        For I:=0 to BufferSize-1 do
          Begin
            Color:=ArrayofSmallInt(Buffer^)[I];
            Index:=MC;
            For Z:=Low(TPalSwitch) to High(TPalSwitch) do
              If (Color=PalSwitch[Z]) and
                 (Color and $7FFF<>0) then
                Begin
                  Index:=Z;
                  Break;
                End;
            If Index=MC then
              Begin
                If Run>0 then Inc(Tmp^[Run])
                Else
                  Begin
                    Tmp^[Size]:=Index;
                    Tmp^[Size+1]:=1;
                    Run:=Size+1;
                    Inc(Size,2);
                  End
              End
            Else
              Begin
                Run:=-1;
                Tmp^[Size]:=Index;
                Inc(Size);
              End;
          End;
        DataSize:=SizeOf(TData)*Size;
        GetMem(Data,DataSize);
        Move(Tmp^,Data^,DataSize);
        FreeMem(Tmp);
      End;
  End;

PROCEDURE PasterSprite(Src,Dst : Pointer;Size : Integer;Mask : Word;Pal : PPalSwitch);
  Asm
    Cmp          ECX,0
    JZ           @Exit
    Push         EDI
    Push         ESI
    Push         EBX
    Mov          ESI,Src
    Mov          EDI,Dst
    Mov          EBX,Pal
    Sub          EBX,2
    Xor          EAX,EAX
    Xor          EDX,EDX
    @Loop:
    Mov          AX,[ESI]
    Cmp          AX,Mask
    JZ           @NoPoint
    @Loop2:
    Mov          AX,[EBX+EAX*2]
    Mov          [EDI],AX
    Add          ESI,2
    Add          EDI,2
    Dec          ECX
    JnZ          @Loop
    @NoPoint:
    Mov          DX,[ESI+2]
    Add          EDI,EDX
    Add          EDI,EDX
    Add          ESI,4
    Sub          ECX,2
    //Change jump not zero by jump if greater !
    //JnZ          @Loop
    JG          @Loop
    Pop          EBX
    Pop          ESI
    Pop          EDI
    @Exit:
  End;

CONSTRUCTOR TLOCDraw.Create(Screen : TLOCScreen;
                            Show : TLOCShow;
                            Units : TLOCUnits;
                            World : TLOCWorld;
                            Editor : TLOCEditor;
                            Menu : TLOCMenu);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    MyEditor:=Editor;
    MyMenu:=Menu;
    SetupData;
    LoadingData;
  End;

DESTRUCTOR TLOCDraw.Destroy;
  Begin
  End;

PROCEDURE TLOCDraw.RestartData;
  Begin
    With MyScreen,MyWorld do
      Begin
        If MiniMapImage<>Nil then
          Begin
            MiniMapImage.Free;
            MiniMapImage:=Nil;
          End;
        MiniMapImage:=TAvenusTextureImages.Create;
        MiniMapImage.Initialize(Screen.D3DDevice8,MapViewDivX+3,MapViewDivY+3,1,D3DFMT_A1R5G5B5);
        If MiniMapColor<>Nil then
          SetLength(MiniMapColor,0,0);
        If MiniMapDarkColor<>Nil then
          SetLength(MiniMapDarkColor,0,0);
        SetLength(MiniMapColor,MapTileSizeX,MapTileSizeY);
        SetLength(MiniMapDarkColor,MapTileSizeX,MapTileSizeY);
        RefreshMiniMap;
      End;
  End;

PROCEDURE TLOCDraw.RefreshMiniMap;
  Const RGBDec = 20;
  Var I,J,X,Y : Integer;
      R,G,B   : LongWord;
  Begin
    With MyScreen,MyWorld do
      Begin
        For I:=0 to MapTileSizeX-1 do
          For J:=0 to MapTileSizeY-1 do
            Begin
              X:=I;Y:=J;
              R:=(TerrainBaseColor[GetLastTile(X,Y),1]+
                  TerrainBaseColor[GetLastTile(X-1,Y-1),1]+
                  TerrainBaseColor[GetLastTile(X-1,Y),1]+
                  TerrainBaseColor[GetLastTile(X-1,Y+1),1]+
                  TerrainBaseColor[GetLastTile(X,Y+1),1]+
                  TerrainBaseColor[GetLastTile(X,Y-1),1]+
                  TerrainBaseColor[GetLastTile(X+1,Y-1),1]+
                  TerrainBaseColor[GetLastTile(X+1,Y),1]+
                  TerrainBaseColor[GetLastTile(X+1,Y+1),1]) div 9;
              G:=(TerrainBaseColor[GetLastTile(X,Y),2]+
                  TerrainBaseColor[GetLastTile(X-1,Y-1),2]+
                  TerrainBaseColor[GetLastTile(X-1,Y),2]+
                  TerrainBaseColor[GetLastTile(X-1,Y+1),2]+
                  TerrainBaseColor[GetLastTile(X,Y+1),2]+
                  TerrainBaseColor[GetLastTile(X,Y-1),2]+
                  TerrainBaseColor[GetLastTile(X+1,Y-1),2]+
                  TerrainBaseColor[GetLastTile(X+1,Y),2]+
                  TerrainBaseColor[GetLastTile(X+1,Y+1),2]) div 9;
              B:=(TerrainBaseColor[GetLastTile(X,Y),3]+
                  TerrainBaseColor[GetLastTile(X-1,Y-1),3]+
                  TerrainBaseColor[GetLastTile(X-1,Y),3]+
                  TerrainBaseColor[GetLastTile(X-1,Y+1),3]+
                  TerrainBaseColor[GetLastTile(X,Y+1),3]+
                  TerrainBaseColor[GetLastTile(X,Y-1),3]+
                  TerrainBaseColor[GetLastTile(X+1,Y-1),3]+
                  TerrainBaseColor[GetLastTile(X+1,Y),3]+
                  TerrainBaseColor[GetLastTile(X+1,Y+1),3]) div 9;
              MiniMapColor[X,Y]:=Color24To15(RGBToLongWord(R,G,B));
              If R>RGBDec then Dec(R,RGBDec);
              If G>RGBDec then Dec(G,RGBDec);
              If B>RGBDec then Dec(B,RGBDec);
              MiniMapDarkColor[X,Y]:=Color24To15(RGBToLongWord(R,G,B));
            End;{}
      End;
  End;

PROCEDURE TLOCDraw.RefreshMiniMap(X1,Y1,X2,Y2 : Integer);
  Const RGBDec = 20;
  Var I,J,X,Y : Integer;
      R,G,B   : LongWord;
  Begin
    With MyScreen,MyWorld do
      Begin
        If X1>X2 then
          Begin
            X:=X1;
            X1:=X2;
            X2:=X;
          End;
        If Y1>Y2 then
          Begin
            Y:=Y1;
            Y1:=Y2;
            Y2:=Y;
          End;
        If X1<0 then X1:=0;
        If X2>MapTileSizeX-1 then X2:=MapTileSizeX-1;
        If Y1<0 then Y1:=0;
        If Y2>MapTileSizeY-1 then Y2:=MapTileSizeY-1;
        For I:=X1 to X2 do
          For J:=Y1 to Y2 do
            Begin
              X:=I;Y:=J;
              R:=(TerrainBaseColor[GetLastTile(X,Y),1]+
                  TerrainBaseColor[GetLastTile(X-1,Y-1),1]+
                  TerrainBaseColor[GetLastTile(X-1,Y),1]+
                  TerrainBaseColor[GetLastTile(X-1,Y+1),1]+
                  TerrainBaseColor[GetLastTile(X,Y+1),1]+
                  TerrainBaseColor[GetLastTile(X,Y-1),1]+
                  TerrainBaseColor[GetLastTile(X+1,Y-1),1]+
                  TerrainBaseColor[GetLastTile(X+1,Y),1]+
                  TerrainBaseColor[GetLastTile(X+1,Y+1),1]) div 9;
              G:=(TerrainBaseColor[GetLastTile(X,Y),2]+
                  TerrainBaseColor[GetLastTile(X-1,Y-1),2]+
                  TerrainBaseColor[GetLastTile(X-1,Y),2]+
                  TerrainBaseColor[GetLastTile(X-1,Y+1),2]+
                  TerrainBaseColor[GetLastTile(X,Y+1),2]+
                  TerrainBaseColor[GetLastTile(X,Y-1),2]+
                  TerrainBaseColor[GetLastTile(X+1,Y-1),2]+
                  TerrainBaseColor[GetLastTile(X+1,Y),2]+
                  TerrainBaseColor[GetLastTile(X+1,Y+1),2]) div 9;
              B:=(TerrainBaseColor[GetLastTile(X,Y),3]+
                  TerrainBaseColor[GetLastTile(X-1,Y-1),3]+
                  TerrainBaseColor[GetLastTile(X-1,Y),3]+
                  TerrainBaseColor[GetLastTile(X-1,Y+1),3]+
                  TerrainBaseColor[GetLastTile(X,Y+1),3]+
                  TerrainBaseColor[GetLastTile(X,Y-1),3]+
                  TerrainBaseColor[GetLastTile(X+1,Y-1),3]+
                  TerrainBaseColor[GetLastTile(X+1,Y),3]+
                  TerrainBaseColor[GetLastTile(X+1,Y+1),3]) div 9;
              MiniMapColor[X,Y]:=Color24To15(RGBToLongWord(R,G,B));
              If R>RGBDec then Dec(R,RGBDec);
              If G>RGBDec then Dec(G,RGBDec);
              If B>RGBDec then Dec(B,RGBDec);
              MiniMapDarkColor[X,Y]:=Color24To15(RGBToLongWord(R,G,B));
            End;{}
      End;
  End;

PROCEDURE TLOCDraw.SetupData;
  Var C : TClan;
  Begin
    //Unit transfer color
    //Default palette for unit of WarcraftII
    DefaultPal[01]:=RGBToWord(000,000,000) or $8000;
    DefaultPal[02]:=RGBToWord(000,000,000) or $8000;
    DefaultPal[03]:=RGBToWord(000,004,076) or $8000;
    DefaultPal[04]:=RGBToWord(000,020,116) or $8000;
    DefaultPal[05]:=RGBToWord(004,040,160) or $8000;
    DefaultPal[06]:=RGBToWord(012,072,204) or $8000;
    DefaultPal[07]:=RGBToWord(000,000,000) or $8000;
    DefaultPal[08]:=RGBToWord(000,000,000) or $8000;
    DefaultPal[09]:=RGBToWord(000,000,000) or $8000;
    DefaultPal[10]:=RGBToWord(000,000,000) or $8000;
    DefaultPal[11]:=RGBToWord(000,000,000) or $8000;
    DefaultPal[12]:=RGBToWord(000,000,000) or $8000;
    //Clan 1: Red color
    ClansColor32[C1]:=RGBToLongWord(123,000,000);
    PalSwitch[C1,01]:=RGBToWord(026,000,000) or $8000;
    PalSwitch[C1,02]:=RGBToWord(057,000,000) or $8000;
    PalSwitch[C1,03]:=RGBToWord(091,000,000) or $8000;
    PalSwitch[C1,04]:=RGBToWord(123,000,000) or $8000;
    PalSwitch[C1,05]:=RGBToWord(155,000,000) or $8000;
    PalSwitch[C1,06]:=RGBToWord(189,000,000) or $8000;
    PalSwitch[C1,07]:=RGBToWord(221,000,000) or $8000;
    PalSwitch[C1,08]:=RGBToWord(255,000,000) or $8000;
    PalSwitch[C1,09]:=RGBToWord(221,000,000) or $8000;
    PalSwitch[C1,10]:=RGBToWord(108,000,000) or $8000;
    PalSwitch[C1,11]:=RGBToWord(168,000,000) or $8000;
    PalSwitch[C1,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 2: Blue color
    ClansColor32[C2]:=RGBToLongWord(000,013,123);
    PalSwitch[C2,01]:=RGBToWord(000,002,026) or $8000;
    PalSwitch[C2,02]:=RGBToWord(000,005,057) or $8000;
    PalSwitch[C2,03]:=RGBToWord(000,010,091) or $8000;
    PalSwitch[C2,04]:=RGBToWord(000,013,123) or $8000;
    PalSwitch[C2,05]:=RGBToWord(000,016,155) or $8000;
    PalSwitch[C2,06]:=RGBToWord(000,019,189) or $8000;
    PalSwitch[C2,07]:=RGBToWord(000,022,221) or $8000;
    PalSwitch[C2,08]:=RGBToWord(000,026,255) or $8000;
    PalSwitch[C2,09]:=RGBToWord(065,074,156) or $8000;
    PalSwitch[C2,10]:=RGBToWord(025,033,081) or $8000;
    PalSwitch[C2,11]:=RGBToWord(048,055,120) or $8000;
    PalSwitch[C2,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 3: Green color
    ClansColor32[C3]:=RGBToLongWord(016,123,000);
    PalSwitch[C3,01]:=RGBToWord(003,026,000) or $8000;
    PalSwitch[C3,02]:=RGBToWord(007,057,000) or $8000;
    PalSwitch[C3,03]:=RGBToWord(012,091,000) or $8000;
    PalSwitch[C3,04]:=RGBToWord(016,123,000) or $8000;
    PalSwitch[C3,05]:=RGBToWord(019,155,000) or $8000;
    PalSwitch[C3,06]:=RGBToWord(023,189,000) or $8000;
    PalSwitch[C3,07]:=RGBToWord(028,221,000) or $8000;
    PalSwitch[C3,08]:=RGBToWord(032,255,000) or $8000;
    PalSwitch[C3,09]:=RGBToWord(077,156,065) or $8000;
    PalSwitch[C3,10]:=RGBToWord(034,081,028) or $8000;
    PalSwitch[C3,11]:=RGBToWord(057,120,048) or $8000;
    PalSwitch[C3,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 4:
    ClansColor32[C4]:=RGBToLongWord(000,089,123);
    PalSwitch[C4,01]:=RGBToWord(000,018,026) or $8000;
    PalSwitch[C4,02]:=RGBToWord(000,041,057) or $8000;
    PalSwitch[C4,03]:=RGBToWord(000,066,091) or $8000;
    PalSwitch[C4,04]:=RGBToWord(000,089,123) or $8000;
    PalSwitch[C4,05]:=RGBToWord(000,113,155) or $8000;
    PalSwitch[C4,06]:=RGBToWord(000,137,189) or $8000;
    PalSwitch[C4,07]:=RGBToWord(000,160,221) or $8000;
    PalSwitch[C4,08]:=RGBToWord(000,185,255) or $8000;
    PalSwitch[C4,09]:=RGBToWord(065,131,156) or $8000;
    PalSwitch[C4,10]:=RGBToWord(028,066,081) or $8000;
    PalSwitch[C4,11]:=RGBToWord(048,106,120) or $8000;
    PalSwitch[C4,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 5:
    ClansColor32[C5]:=RGBToLongWord(123,114,000);
    PalSwitch[C5,01]:=RGBToWord(026,023,000) or $8000;
    PalSwitch[C5,02]:=RGBToWord(057,053,000) or $8000;
    PalSwitch[C5,03]:=RGBToWord(091,085,000) or $8000;
    PalSwitch[C5,04]:=RGBToWord(123,114,000) or $8000;
    PalSwitch[C5,05]:=RGBToWord(155,143,000) or $8000;
    PalSwitch[C5,06]:=RGBToWord(189,175,000) or $8000;
    PalSwitch[C5,07]:=RGBToWord(221,204,000) or $8000;
    PalSwitch[C5,08]:=RGBToWord(255,236,000) or $8000;
    PalSwitch[C5,09]:=RGBToWord(156,150,065) or $8000;
    PalSwitch[C5,10]:=RGBToWord(081,077,028) or $8000;
    PalSwitch[C5,11]:=RGBToWord(120,115,048) or $8000;
    PalSwitch[C5,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 6:
    ClansColor32[C6]:=RGBToLongWord(122,062,001);
    PalSwitch[C6,01]:=RGBToWord(026,013,000) or $8000;
    PalSwitch[C6,02]:=RGBToWord(057,029,000) or $8000;
    PalSwitch[C6,03]:=RGBToWord(090,046,001) or $8000;
    PalSwitch[C6,04]:=RGBToWord(122,062,001) or $8000;
    PalSwitch[C6,05]:=RGBToWord(154,078,001) or $8000;
    PalSwitch[C6,06]:=RGBToWord(188,095,001) or $8000;
    PalSwitch[C6,07]:=RGBToWord(220,111,001) or $8000;
    PalSwitch[C6,08]:=RGBToWord(254,128,001) or $8000;
    PalSwitch[C6,09]:=RGBToWord(220,111,001) or $8000;
    PalSwitch[C6,10]:=RGBToWord(185,054,023) or $8000;
    PalSwitch[C6,11]:=RGBToWord(132,084,036) or $8000;
    PalSwitch[C6,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 7:
    ClansColor32[C7]:=RGBToLongWord(061,061,061);
    PalSwitch[C7,01]:=RGBToWord(012,012,012) or $8000;
    PalSwitch[C7,02]:=RGBToWord(028,028,028) or $8000;
    PalSwitch[C7,03]:=RGBToWord(045,045,045) or $8000;
    PalSwitch[C7,04]:=RGBToWord(061,061,061) or $8000;
    PalSwitch[C7,05]:=RGBToWord(077,077,077) or $8000;
    PalSwitch[C7,06]:=RGBToWord(094,094,094) or $8000;
    PalSwitch[C7,07]:=RGBToWord(110,110,110) or $8000;
    PalSwitch[C7,08]:=RGBToWord(127,127,127) or $8000;
    PalSwitch[C7,09]:=RGBToWord(110,110,110) or $8000;
    PalSwitch[C7,10]:=RGBToWord(054,054,054) or $8000;
    PalSwitch[C7,11]:=RGBToWord(083,083,083) or $8000;
    PalSwitch[C7,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 8:
    ClansColor32[C8]:=RGBToLongWord(018,066,105);
    PalSwitch[C8,01]:=RGBToWord(003,014,022) or $8000;
    PalSwitch[C8,02]:=RGBToWord(009,031,049) or $8000;
    PalSwitch[C8,03]:=RGBToWord(013,049,079) or $8000;
    PalSwitch[C8,04]:=RGBToWord(018,066,105) or $8000;
    PalSwitch[C8,05]:=RGBToWord(022,083,133) or $8000;
    PalSwitch[C8,06]:=RGBToWord(028,101,162) or $8000;
    PalSwitch[C8,07]:=RGBToWord(032,118,189) or $8000;
    PalSwitch[C8,08]:=RGBToWord(036,137,219) or $8000;
    PalSwitch[C8,09]:=RGBToWord(032,118,189) or $8000;
    PalSwitch[C8,10]:=RGBToWord(016,058,092) or $8000;
    PalSwitch[C8,11]:=RGBToWord(024,090,143) or $8000;
    PalSwitch[C8,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 9:
    ClansColor32[C9]:=RGBToLongWord(189,189,189);
    PalSwitch[C9,01]:=RGBToWord(140,140,140) or $8000;
    PalSwitch[C9,02]:=RGBToWord(156,156,156) or $8000;
    PalSwitch[C9,03]:=RGBToWord(173,173,173) or $8000;
    PalSwitch[C9,04]:=RGBToWord(189,189,189) or $8000;
    PalSwitch[C9,05]:=RGBToWord(205,205,205) or $8000;
    PalSwitch[C9,06]:=RGBToWord(222,222,222) or $8000;
    PalSwitch[C9,07]:=RGBToWord(238,238,238) or $8000;
    PalSwitch[C9,08]:=RGBToWord(255,255,255) or $8000;
    PalSwitch[C9,09]:=RGBToWord(238,238,238) or $8000;
    PalSwitch[C9,10]:=RGBToWord(182,182,182) or $8000;
    PalSwitch[C9,11]:=RGBToWord(211,211,211) or $8000;
    PalSwitch[C9,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 10:
    ClansColor32[C10]:=RGBToLongWord(124,000,124);
    PalSwitch[C10,01]:=RGBToWord(025,000,025) or $8000;
    PalSwitch[C10,02]:=RGBToWord(058,000,058) or $8000;
    PalSwitch[C10,03]:=RGBToWord(091,000,091) or $8000;
    PalSwitch[C10,04]:=RGBToWord(124,000,124) or $8000;
    PalSwitch[C10,05]:=RGBToWord(156,000,156) or $8000;
    PalSwitch[C10,06]:=RGBToWord(189,000,189) or $8000;
    PalSwitch[C10,07]:=RGBToWord(222,000,222) or $8000;
    PalSwitch[C10,08]:=RGBToWord(255,000,255) or $8000;
    PalSwitch[C10,09]:=RGBToWord(136,064,136) or $8000;
    PalSwitch[C10,10]:=RGBToWord(072,028,080) or $8000;
    PalSwitch[C10,11]:=RGBToWord(104,048,120) or $8000;
    PalSwitch[C10,12]:=RGBToWord(000,000,000) or $8000;
    //Clan 11:
    ClansColor32[C11]:=RGBToLongWord(123,123,000);
    PalSwitch[C11,01]:=RGBToWord(026,026,000) or $8000;
    PalSwitch[C11,02]:=RGBToWord(057,057,000) or $8000;
    PalSwitch[C11,03]:=RGBToWord(091,091,000) or $8000;
    PalSwitch[C11,04]:=RGBToWord(123,123,000) or $8000;
    PalSwitch[C11,05]:=RGBToWord(155,155,000) or $8000;
    PalSwitch[C11,06]:=RGBToWord(189,189,000) or $8000;
    PalSwitch[C11,07]:=RGBToWord(221,221,000) or $8000;
    PalSwitch[C11,08]:=RGBToWord(255,255,000) or $8000;
    PalSwitch[C11,09]:=RGBToWord(156,156,065) or $8000;
    PalSwitch[C11,10]:=RGBToWord(081,081,028) or $8000;
    PalSwitch[C11,11]:=RGBToWord(120,120,048) or $8000;
    PalSwitch[C11,12]:=RGBToWord(000,000,000) or $8000;
    //Clan Gaia: ? color
    ClansColor32[Gaia]:=RGBToLongWord(000,000,000);
    PalSwitch[Gaia,01]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,02]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,03]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,04]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,05]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,06]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,07]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,08]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,09]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,10]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,11]:=RGBToWord(000,000,000) or $8000;
    PalSwitch[Gaia,12]:=RGBToWord(000,000,000) or $8000;

    //Night lightning
    //ColorLightning:=$808080;
    //Day lightning
    //ColorLightning:=$FFFFFF;
    //Test
    ColorLightning[Noon    ]:=$FFFFFF;
    ColorLightning[Dusk    ]:=$AFAFAF;
    ColorLightning[MidNight]:=$909090;
    ColorLightning[Dawn    ]:=$F0F0F0;
    ColorAlphaBlend:=$A0A0A0;
    //Setup clans color
    For C:=Low(TClan) to High(TClan) do
      ClansColor[C]:=PalSwitch[C,4];
    //
    MouseSelectStyle:=Rect;
    UnitSelectStyle:=Square;
    MiniMapStyle:=ShowRect;
    WaterAlpha:=$FF808080;
  End;

PROCEDURE TLOCDraw.LoadingData;
  Var TempImage : TAvenusTextureImages;
      {$IfDef Debug}
      Time      : Integer;
      {$EndIf}
  Begin
    {$IfDef Debug}
    AniScriptMemUsed:=0;
    {$EndIf}
    //
    With MyScreen do
      Begin
        TempImage:=TAvenusTextureImages.Create;
        {$IfDef LoadOnDataBase}
        If TempImage.LoadFromPackFile(GraphicDataFile,Screen.D3DDevice8,GameDataDir+ImagesDir+'ScreenStart.jpg',
                                  0,0,D3DFMT_R5G6B5)=0 then
        {$Else}
        If TempImage.LoadFromFile(Screen.D3DDevice8,GameDataDir+ImagesDir+'ScreenStart.jpg',
                                  0,0,D3DFMT_R5G6B5)=0 then
        {$EndIf}
          Begin
            Screen.Clear(0);
            Screen.BeginScene;
            Screen.RenderEffect(TempImage,0,0,0,EffectNone);
            Screen.RenderBuffer;
            StrDraw(50,Screen.YMax-50,White,'Please wait for loading data...');
            Screen.EndScene;
            Screen.Present;
          End;
        TempImage.Free;
      End;
    //First setup for other images
    OtherImage:=TAvenusTextureImages.Create;
    LoadUnitData;
    LoadTerrainData;
    {$IfDef Debug}
    With MyScreen do
      Begin
        Time:=Integer(TimeGetTime)-GameTimeStart;
        SendMessage(Format('Game loading in %d milisecond',[Time]));
      End;
    {$EndIf}
  End;

PROCEDURE TLOCDraw.LoadUnitData;
  Var TmpUnit : TUnit;
      TmpMis  : TMissile;
  Begin
    //Unit icons loading
    UnitIconLoad(GameDataDir+UnitIconsFileName);
    //Skill icons loading
    SkillIconLoad(GameDataDir+SkillIconsFileName);
    //Spell icons loading
    SpellIconLoad(GameDataDir+SpellIconsFileName);
    //Item icons loading
    ItemIconLoad(GameDataDir+ItemIconsFileName);
    {$IfDef FullLog}
    MyScreen.Log('Load icons done.');
    {$EndIf}
    //Missile animation loading
    MissileAnimationLoad(MissileGreenCross  ,GameDataDir+GameAnimationScriptDir+'GreenCross.Ani');
    MissileAnimationLoad(MissileArrow       ,GameDataDir+GameAnimationScriptDir+'Arrow.Ani');
    MissileAnimationLoad(MissileAxe         ,GameDataDir+GameAnimationScriptDir+'BesAxe.Ani');
    MissileAnimationLoad(MissileLightning   ,GameDataDir+GameAnimationScriptDir+'Lightning.Ani');
    MissileAnimationLoad(MissileTouchOfDeath,GameDataDir+GameAnimationScriptDir+'TouchOfDeath.Ani');
    MissileAnimationLoad(MissileDragBull    ,GameDataDir+GameAnimationScriptDir+'DragBull.Ani');
    MissileAnimationLoad(MissileFireBall    ,GameDataDir+GameAnimationScriptDir+'FireBall.Ani');
    MissileAnimationLoad(MissileExplode     ,GameDataDir+GameAnimationScriptDir+'Explosion.Ani');
    MissileAnimationLoad(MissileBlizzard    ,GameDataDir+GameAnimationScriptDir+'Blizzard.Ani');
    {$IfDef FullLog}
    MyScreen.Log('Load missile animation done.');
    {$EndIf}
    For TmpMis:=Low(TMissile) to High(TMissile) do
      If MissileAnimations[TmpMis].NumFrame=0 then
        MissileAnimations[TmpMis]:=MissileAnimations[MissileArrow];
    //Effected animation loading
    EffectedAnimationLoad(GameDataDir+EffectedImageFileName);
    {$IfDef FullLog}
    MyScreen.Log('Load effected animation done.');
    {$EndIf}
    //Unit animations loading
    {$IfDef LoadLittle}
    UnitAnimationLoad(Peasant     ,GameDataDir+GameAnimationScriptDir+'Peasant.Ani');
    UnitAnimationLoad(Peon        ,GameDataDir+GameAnimationScriptDir+'Peon.Ani');
    UnitAnimationLoad(Footman     ,GameDataDir+GameAnimationScriptDir+'Footman.Ani');
    UnitAnimationLoad(Grunt       ,GameDataDir+GameAnimationScriptDir+'Grunt.Ani');
    {$Else}
    UnitAnimationLoad(ItemStore          ,GameDataDir+GameAnimationScriptDir+'ItemStore.Ani');
    UnitAnimationLoad(Critter1           ,GameDataDir+GameAnimationScriptDir+'Critter1.Ani');
    UnitAnimationLoad(Critter2           ,GameDataDir+GameAnimationScriptDir+'Critter2.Ani');
    UnitAnimationLoad(Critter3           ,GameDataDir+GameAnimationScriptDir+'Critter3.Ani');
    UnitAnimationLoad(Critter4           ,GameDataDir+GameAnimationScriptDir+'Critter4.Ani');
    UnitAnimationLoad(Peasant            ,GameDataDir+GameAnimationScriptDir+'Peasant.Ani');
    UnitAnimationLoad(Peon               ,GameDataDir+GameAnimationScriptDir+'Peon.Ani');
    UnitAnimationLoad(PeasantWithGold    ,GameDataDir+GameAnimationScriptDir+'PeasantWithGold.Ani');
    UnitAnimationLoad(PeonWithGold       ,GameDataDir+GameAnimationScriptDir+'PeonWithGold.Ani');
    UnitAnimationLoad(Footman            ,GameDataDir+GameAnimationScriptDir+'Footman.Ani');
    UnitAnimationLoad(Grunt              ,GameDataDir+GameAnimationScriptDir+'Grunt.Ani');
    UnitAnimationLoad(Archer             ,GameDataDir+GameAnimationScriptDir+'Archer.Ani');
    UnitAnimationLoad(Axethrower         ,GameDataDir+GameAnimationScriptDir+'Axethrower.Ani');
    UnitAnimationLoad(Ranger             ,GameDataDir+GameAnimationScriptDir+'Ranger.Ani');
    UnitAnimationLoad(Berserker          ,GameDataDir+GameAnimationScriptDir+'Berserker.Ani');
    UnitAnimationLoad(Knight             ,GameDataDir+GameAnimationScriptDir+'Knight.Ani');
    UnitAnimationLoad(Ogre               ,GameDataDir+GameAnimationScriptDir+'Ogre.Ani');
    UnitAnimationLoad(Paladin            ,GameDataDir+GameAnimationScriptDir+'Paladin.Ani');
    UnitAnimationLoad(OgreMage           ,GameDataDir+GameAnimationScriptDir+'OgreMage.Ani');
    UnitAnimationLoad(Mage               ,GameDataDir+GameAnimationScriptDir+'Mage.Ani');
    UnitAnimationLoad(DeathKnight        ,GameDataDir+GameAnimationScriptDir+'DeathKnight.Ani');
    UnitAnimationLoad(Ballista           ,GameDataDir+GameAnimationScriptDir+'Ballista.Ani');
    UnitAnimationLoad(Catapul            ,GameDataDir+GameAnimationScriptDir+'Catapul.Ani');
    UnitAnimationLoad(Dwarves            ,GameDataDir+GameAnimationScriptDir+'Dwarven.Ani');
    UnitAnimationLoad(Goblin             ,GameDataDir+GameAnimationScriptDir+'Goblin.Ani');
    UnitAnimationLoad(FlyingMachine      ,GameDataDir+GameAnimationScriptDir+'FlyingMachine.Ani');
    UnitAnimationLoad(Zeppelin           ,GameDataDir+GameAnimationScriptDir+'Zeppelin.Ani');
    UnitAnimationLoad(Dragon             ,GameDataDir+GameAnimationScriptDir+'Dragon.Ani');
    UnitAnimationLoad(DeathWing          ,GameDataDir+GameAnimationScriptDir+'DeathWing.Ani');
    UnitAnimationLoad(DragonRide         ,GameDataDir+GameAnimationScriptDir+'DragonRide.Ani');
    UnitAnimationLoad(DragonMage         ,GameDataDir+GameAnimationScriptDir+'DragonMage.Ani');
    UnitAnimationLoad(Xkeleton           ,GameDataDir+GameAnimationScriptDir+'Xkeleton.Ani');
    UnitAnimationLoad(OgreMagi           ,GameDataDir+GameAnimationScriptDir+'OgreMagi.Ani');
    UnitAnimationLoad(SuperDaemon        ,GameDataDir+GameAnimationScriptDir+'SuperDaemon.Ani');
    UnitAnimationLoad(DarkDaemon         ,GameDataDir+GameAnimationScriptDir+'DarkDaemon.Ani');
    UnitAnimationLoad(Commander          ,GameDataDir+GameAnimationScriptDir+'Commander.Ani');
    UnitAnimationLoad(GundamBattleShip1  ,GameDataDir+GameAnimationScriptDir+'GundamBattleShip1.Ani');
    UnitAnimationLoad(GundamBattleShip2  ,GameDataDir+GameAnimationScriptDir+'GundamBattleShip2.Ani');
    UnitAnimationLoad(GundamBattleShip3  ,GameDataDir+GameAnimationScriptDir+'GundamBattleShip3.Ani');
    UnitAnimationLoad(Arbiter            ,GameDataDir+GameAnimationScriptDir+'Arbiter.Ani');
    UnitAnimationLoad(Carrier            ,GameDataDir+GameAnimationScriptDir+'Carrier.Ani');
    UnitAnimationLoad(Intercept          ,GameDataDir+GameAnimationScriptDir+'Intercept.Ani');
    {$EndIf}
    //UnitAnimationLoad(Light       ,GameDataDir+GameAnimationScriptDir+'Light.Ani');
    //Loading building animations
    UnitAnimationLoad(ConstructionLand  ,GameDataDir+GameAnimationScriptDir+'ConstructionLand.Ani');
    UnitAnimationLoad(GoldMine          ,GameDataDir+GameAnimationScriptDir+'GoldMine.Ani');
    UnitAnimationLoad(DarkPortal        ,GameDataDir+GameAnimationScriptDir+'DarkPortal.Ani');
    UnitAnimationLoad(HumanFarm         ,GameDataDir+GameAnimationScriptDir+'HumanFarm.Ani');
    UnitAnimationLoad(OrcFarm           ,GameDataDir+GameAnimationScriptDir+'OrcFarm.Ani');
    UnitAnimationLoad(TownHall          ,GameDataDir+GameAnimationScriptDir+'TownHall.Ani');
    UnitAnimationLoad(GreatHall         ,GameDataDir+GameAnimationScriptDir+'GreatHall.Ani');
    UnitAnimationLoad(Keep              ,GameDataDir+GameAnimationScriptDir+'Keep.Ani');
    UnitAnimationLoad(StrongHold        ,GameDataDir+GameAnimationScriptDir+'StrongHold.Ani');
    UnitAnimationLoad(Castle            ,GameDataDir+GameAnimationScriptDir+'Castle.Ani');
    UnitAnimationLoad(Fortress          ,GameDataDir+GameAnimationScriptDir+'Fortress.Ani');
    UnitAnimationLoad(HumanBarrack      ,GameDataDir+GameAnimationScriptDir+'HumanBarrack.Ani');
    UnitAnimationLoad(OrcBarrack        ,GameDataDir+GameAnimationScriptDir+'OrcBarrack.Ani');
    UnitAnimationLoad(HumanBlackSmith   ,GameDataDir+GameAnimationScriptDir+'HumanBlackSmith.Ani');
    UnitAnimationLoad(OrcBlackSmith     ,GameDataDir+GameAnimationScriptDir+'OrcBlackSmith.Ani');
    UnitAnimationLoad(ElvenLumberMill   ,GameDataDir+GameAnimationScriptDir+'ElvenLumberMill.Ani');
    UnitAnimationLoad(TrollLumberMill   ,GameDataDir+GameAnimationScriptDir+'TrollLumberMill.Ani');
    UnitAnimationLoad(GnomishInventor   ,GameDataDir+GameAnimationScriptDir+'GnomishInventor.Ani');
    UnitAnimationLoad(GoblinAlchemist   ,GameDataDir+GameAnimationScriptDir+'GoblinAlchemist.Ani');
    UnitAnimationLoad(Stables           ,GameDataDir+GameAnimationScriptDir+'Stables.Ani');
    UnitAnimationLoad(OgreMound         ,GameDataDir+GameAnimationScriptDir+'OgreMound.Ani');
    UnitAnimationLoad(Church            ,GameDataDir+GameAnimationScriptDir+'Church.Ani');
    UnitAnimationLoad(AltarOfStorm      ,GameDataDir+GameAnimationScriptDir+'AltarOfStorm.Ani');
    UnitAnimationLoad(MageTower         ,GameDataDir+GameAnimationScriptDir+'MageTower.Ani');
    UnitAnimationLoad(TempleOfTheDamned ,GameDataDir+GameAnimationScriptDir+'TempleOfTheDamned.Ani');
    UnitAnimationLoad(GryphonAviary     ,GameDataDir+GameAnimationScriptDir+'GryphonAviary.Ani');
    UnitAnimationLoad(DragonRoost       ,GameDataDir+GameAnimationScriptDir+'DragonRoost.Ani');
    UnitAnimationLoad(HumanScoutTower   ,GameDataDir+GameAnimationScriptDir+'HumanScoutTower.Ani');
    UnitAnimationLoad(OrcWatchTower     ,GameDataDir+GameAnimationScriptDir+'OrcWatchTower.Ani');
    UnitAnimationLoad(HumanGuardTower   ,GameDataDir+GameAnimationScriptDir+'HumanGuardTower.Ani');
    UnitAnimationLoad(OrcGuardTower     ,GameDataDir+GameAnimationScriptDir+'OrcGuardTower.Ani');
    UnitAnimationLoad(HumanCannonTower  ,GameDataDir+GameAnimationScriptDir+'HumanCannonTower.Ani');
    UnitAnimationLoad(OrcCannonTower    ,GameDataDir+GameAnimationScriptDir+'OrcCannonTower.Ani');
    UnitAnimationLoad(AlienConstruction ,GameDataDir+GameAnimationScriptDir+'AlienConstruction.Ani');
    //
    For TmpUnit:=Low(TUnit) to High(TUnit) do
      If UnitAnimations[TmpUnit].NumofFrame=0 then
        UnitAnimations[TmpUnit]:=UnitAnimations[Peon];
    {$IfDef FullLog}
    MyScreen.Log('Load unit animation done.');
    {$EndIf}
  End;

PROCEDURE TLOCDraw.LoadTerrainData;
  Const TerrainName : Array[TMapTile] of String = (
          'Barrens_Desert.png',
          'LordS_DirtRough.png',
          'LordS_Grass.png',
          'LordS_GrassDark.png',
          'Ashen_Rock.png',
          'Lords_Blight.png',
          'LordW_Snow.png',
          'North_Snow.png',
          '');
        TerrainWaterName : Array[0..MaxWaterFrame] of String = (
          'A_Water00.jpg',
          'A_Water01.jpg',
          'A_Water02.jpg',
          'A_Water03.jpg',
          'A_Water04.jpg',
          'A_Water05.jpg',
          'A_Water06.jpg',
          'A_Water07.jpg',
          'A_Water08.jpg',
          'A_Water09.jpg',
          'A_Water10.jpg',
          'A_Water11.jpg',
          'A_Water12.jpg',
          'A_Water13.jpg',
          'A_Water14.jpg',
          'A_Water15.jpg',
          'A_Water16.jpg',
          'A_Water17.jpg',
          'A_Water18.jpg',
          'A_Water19.jpg',
          'A_Water20.jpg',
          'A_Water21.jpg',
          'A_Water22.jpg',
          'A_Water23.jpg',
          'A_Water24.jpg',
          'A_Water25.jpg',
          'A_Water26.jpg',
          'A_Water27.jpg',
          'A_Water28.jpg',
          'A_Water29.jpg',
          'A_Water30.jpg',
          'A_Water31.jpg',
          'A_Water32.jpg',
          'A_Water33.jpg',
          'A_Water34.jpg',
          'A_Water35.jpg',
          'A_Water36.jpg',
          'A_Water37.jpg',
          'A_Water38.jpg',
          'A_Water39.jpg',
          'A_Water40.jpg',
          'A_Water41.jpg',
          'A_Water42.jpg',
          'A_Water43.jpg',
          'A_Water44.jpg');
  Var Index : TMapTile;
      Z     : Integer;
  Begin
    With MyScreen,TerrainImages do
      Begin
        Images:=TAvenusTextureImages.Create;
        //WaterImages:=TAvenusTextureImages.Create;
        For Index:=Low(TMapTile) to High(TMapTile) do
          Begin
            FramePos[Index]:=0;
            FrameCount[Index]:=0;
          End;
        {$IfDef LoadOnDataBase}
        With Images do
          Begin
            For Index:=Desert to Ice do
              If LoadFromFileAlpha1Bit(GraphicDataFile,MyScreen.Screen.D3DDevice8,
                                       GameDataDir+GameTerrainTexturesDir+TerrainName[Index],
                                       64,64,0,FramePos[Index],FrameCount[Index])<>0 then
                ErrorMessage(LoadingFailedStr+GameTerrainTexturesDir+TerrainName[Index])
              Else Log('Loading file '+GameDataDir+GameTerrainTexturesDir+
                       TerrainName[Index]+' from database complete');
            FramePos[Water]:=Images.CountTextures;
            For Z:=Low(TerrainWaterName) to High(TerrainWaterName) do
              If LoadFromPackFile(GraphicDataFile,MyScreen.Screen.D3DDevice8,
                                  GameDataDir+GameTerrainTexturesDir+TerrainWaterName[Z],64,64,D3DFMT_R5G6B5)<>0 then
                ErrorMessage(LoadingFailedStr+GameTerrainTexturesDir+TerrainWaterName[Z])
              Else Log('Loading file '+GameDataDir+GameTerrainTexturesDir+
                       TerrainWaterName[Z]+' from database complete');
          End;
        {$Else}
        With Images do
          Begin
            For Index:=Desert to Ice do
              If LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,
                                       GameDataDir+GameTerrainTexturesDir+TerrainName[Index],
                                       64,64,0,FramePos[Index],FrameCount[Index])<>0 then
                ErrorMessage(LoadingFailedStr+GameTerrainTexturesDir+TerrainName[Index])
              Else Log('Loading file '+GameDataDir+GameTerrainTexturesDir+
                       TerrainName[Index]+' complete');
            FramePos[Water]:=Images.CountTextures;
            For Z:=Low(TerrainWaterName) to High(TerrainWaterName) do
              If LoadFromFile(MyScreen.Screen.D3DDevice8,
                              GameDataDir+GameTerrainTexturesDir+TerrainWaterName[Z],64,64,D3DFMT_R5G6B5)<>0 then
                ErrorMessage(LoadingFailedStr+GameTerrainTexturesDir+TerrainWaterName[Z])
              Else Log('Loading file '+GameDataDir+GameTerrainTexturesDir+
                       TerrainWaterName[Z]+' complete');
            {LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'Barrens_Desert.Png',
                                64,64,0,FramePos[Desert],FrameCount[Desert]);
            LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'LordS_DirtRough.Png',
                                64,64,0,FramePos[Dirt],FrameCount[Dirt]);
            LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'LordS_Grass.Png',
                                64,64,0,FramePos[Grass],FrameCount[Grass]);
            LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'LordS_GrassDark.Png',
                                64,64,0,FramePos[DarkGrass],FrameCount[DarkGrass]);
            LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'Ashen_Rock.Png',
                                64,64,0,FramePos[Rock],FrameCount[Rock]);
            LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'Lords_Blight.Png',
                                64,64,0,FramePos[DarkRock],FrameCount[DarkRock]);
            LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'LordW_Snow.Png',
                                64,64,0,FramePos[Snow],FrameCount[Snow]);
            LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'North_Snow.Png',
                                64,64,0,FramePos[Ice],FrameCount[Ice]);
            FramePos[Water]:=Images.CountTextures;
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water00.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water01.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water02.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water03.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water04.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water05.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water06.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water07.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water08.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water09.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water10.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water11.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water12.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water13.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water14.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water15.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water16.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water17.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water18.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water19.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water20.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water21.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water22.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water23.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water24.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water25.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water26.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water27.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water28.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water29.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water30.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water31.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water32.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water33.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water34.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water35.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water36.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water37.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water38.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water39.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water40.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water41.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water42.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water43.Jpg',64,64,D3DFMT_R5G6B5);
            LoadFromFile(MyScreen.Screen.D3DDevice8,GameDataDir+GameTerrainTexturesDir+'A_Water44.Jpg',64,64,D3DFMT_R5G6B5);}
          End;
        {$EndIf}
        FrameCount[Water]:=Images.CountTextures-FramePos[Water];
      End;
  End;
{$IfDef Debug}
PROCEDURE TLOCDraw.DebugLine(Msg : String;Color : LongWord);
  Begin
    With MyScreen do
      StrDraw(20,DebugLinePos,Color,Msg);
    Inc(DebugLinePos,20);
  End;

PROCEDURE TLOCDraw.ShowDebug(Times,Frames : Integer);
  Var C : TClan;
  Begin
    With MyScreen,MyWorld,MyUnits do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(0,0,ScreenWidth,ScreenHeight);
        {$EndIf}
        DebugLinePos:=20;
        //DebugLine('Debug infomation',Red);
        If DebugStatus[ShowVideoInfo] then
          Begin
            If Times>0 then
              Begin
                DebugLine(Format('Video mode: %dx%dx16bit color',[ScreenWidth,ScreenHeight]),White);
                DebugLine(Format('Screen frame rate: %0.2f',[Frames/Times*1000]),White);
                DebugLine(Format('Game frame rate: %0.2f',[GameFrame/Times*1000]),White);
                DebugLine(Format('Game frame : %d',[GameFrame]),White);
                DebugLine(Format('TotalMissiles : %d',[TotalMissile]),White);
              End;
          End;
        If DebugStatus[ShowGameInfo] then
          Begin
            DebugLine(Format('Total unit active: %d',[TotalUnit]),White);
            //Size of data for world map 
            DebugLine(Format('TWorldMapNum size: %d KB',[SizeOf(TMapNum)*MapSizeX*MapSizeY div 1024]),White);
            DebugLine(Format('TWorldMapTile size: %d KB',[SizeOf(TMapTile)*MapSizeX*MapSizeY div 1024]),White);
            DebugLine(Format('TWorldMapTrueSight size: %d KB',[SizeOf(TUnitSawState)*MapSizeX*MapSizeY div 1024]),White);
            DebugLine(Format('TWorldMapAttr size: %d KB',[SizeOf(TMapAttr)*MapSizeX*MapSizeY div 1024]),White);
            DebugLine(Format('TWorldMapUnitUnderFog size: %d KB',[SizeOf(TUnitUnderFog)*MapSizeX*MapSizeY div 1024]),White);
            DebugLine(Format('Total for world map: %d KB',[(SizeOf(TMapNum)+SizeOf(TMapTile)+
                                                            SizeOf(TMapAttr)+SizeOf(TUnitSawState)+
                                                            SizeOf(TUnitUnderFog))*MapSizeX*MapSizeY div 1024]),White);
            //Size of data for AStar path finding method
            DebugLine(Format('AStarMatrix size: %d KB',[SizeOf(TNode)*AStarMatrixSize div 1024]),White);
            DebugLine(Format('AStarPath size: %d KB',[SizeOf(THeading)*AStarMatrixSize div 1024]),White);
            DebugLine(Format('AStarCloseSet size: %d KB',[SizeOf(Integer)*ThresholdCloseSet div 1024]),White);
            DebugLine(Format('AStarOpenSet size: %d KB',[SizeOf(TOpen)*OpenSetMaxSize div 1024]),White);
            //Size of data for units
            DebugLine(Format('TUnitData size: %d KB',[SizeOf(MyUnits.Units) div 1024]),White);
            DebugLine(Format('TUnitProp size: %d KB',[SizeOf(MyUnits.UnitsProperty) div 1024]),White);
            DebugLine(Format('TMissiles size: %d KB',[SizeOf(MyUnits.Missiles) div 1024]),White);
            DebugLine(Format('TEffected size: %d KB',[SizeOf(MyUnits.Effects) div 1024]),White);
            DebugLine(Format('TAnimation size: %d KB',[SizeOf(UnitAnimations) div 1024]),White);
            DebugLine(Format('TAnimation alloc size: %d bytes',[AniScriptMemUsed]),White);
          End;
        If DebugStatus[ShowMapInfo] then
          Begin
            DebugLine(Format('MapSize: %dx%d',[MapSizeX,MapSizeY]),White);
            DebugLine(Format('MapViewPos: %dx%d',[MapViewPosX+MapViewDivX,MapViewPosY+MapViewDivY]),White);
            DebugLine(Format('MapViewAt: %dx%d',[MapViewX,MapViewY]),White);
          End;
        If DebugStatus[ShowClanInfo] then
          Begin
            For C:=Low(TClan) to High(TClan) do
              If ClanInfo[C].Control<>NoBody then
                DebugLine(Format('[%s] Gold: %d Lumber: %d Food: %d/%d/%d %d',
                          [ClanInfo[C].ClanName,
                           ClanInfo[C].Resource[ResGold],
                           ClanInfo[C].Resource[ResTree],
                           ClanInfo[C].FoodUsed,
                           ClanInfo[C].FoodAvail,
                           ClanInfo[C].FoodAvailInFuture,
                           ClanInfo[C].AllUnits]),Red);
          End;
        If DebugStatus[ShowUnitInfo] then
          Begin
            If SaveGroups[MaxGroup][Low(TUnitSelectionCount)]<>0 then
              Begin
                DebugLine(Format('%d',[Units[SaveGroups[MaxGroup][Low(TUnitSelectionCount)]]._UnitTarget]),White);
                DebugLine(Format('%d',[SaveGroups[MaxGroup][Low(TUnitSelectionCount)]]),White);
                DebugLine(Format('%d %d %d',[Units[Units[SaveGroups[MaxGroup][Low(TUnitSelectionCount)]]._UnitTarget]._UnitHitPoint,
                                             Byte(Units[SaveGroups[MaxGroup][Low(TUnitSelectionCount)]]._UnitCmd),
                                             Byte(Units[SaveGroups[MaxGroup][Low(TUnitSelectionCount)]]._UnitPrevCmd)]),White);
              End;
          End;
      End;
  End;
{$EndIf}
PROCEDURE TLOCDraw.TerrainRender;
  Var I,J,X,Y,X1,Y1,X2,Y2,II,JJ : Integer;
  Begin
    With MyScreen,MyWorld do
      Begin
        X1:=MapViewX div 2;
        Y1:=MapViewY div 2;
        X2:=(MapViewX+DefaultMapViewX) div 2+1;
        Y2:=(MapViewY+DefaultMapViewY) div 2+1;
        {If X1<0 then X1:=0;
        If Y1<0 then Y1:=0;}
        If X2>MapTileSizeX then X2:=MapTileSizeX;
        If Y2>MapTileSizeY then Y2:=MapTileSizeY;
        II:=MapViewX mod 2;
        JJ:=MapViewY mod 2;
        For I:=X1 to X2 do
          For J:=Y1 to Y2 do
            Begin
              X:=ViewPosXOS+(2-II)*DefaultMapTileX+(I-X1-1)*LandTileSizeX;
              Y:=ViewPosYOS+(2-JJ)*DefaultMapTileY+(J-Y1-1)*LandTileSizeX;
              RenderTile(X,Y,I,J);
            End;
        {For I:=X1 to X2 do
          For J:=Y1 to Y2 do
            If WaterMap[I,J]=Water then
              RenderTile(I-X1,J-Y1,I,J,Water,False);{}
        //RenderTile(3,3,2,2,Water,False);
      End;
  End;

PROCEDURE TLOCDraw.RenderTile(X,Y,TileX,TileY : Integer);
  (*Var X1,Y1,X2,Y2,X5,Y5 : Integer;
      {$IfDef ApplyLightning}
      Color             : LongWord;
      {$EndIf}
  Begin
    X5:=X;Y5:=Y;
    X1:=X5-LandTileSizeX;
    Y1:=Y5-LandTileSizeY;
    X2:=X5+LandTileSizeX;
    Y2:=Y5+LandTileSizeY;
    With MyScreen,Screen,TerrainImages do
      Begin
        {$IfDef ApplyLightning}
        If Tile=Water then
          Begin
            Color:=WaterAlpha;
            TextureCol(Images,X1,Y1,X5,Y1,X5,Y5,X1,Y5,$00,$00,Color,$00,FramePos[Tile]+Frame*4+0,EffectAdd);
            TextureCol(Images,X5,Y1,X2,Y1,X2,Y5,X5,Y5,$00,$00,$00,Color,FramePos[Tile]+Frame*4+1,EffectAdd);
            TextureCol(Images,X5,Y5,X2,Y5,X2,Y2,X5,Y2,Color,$00,$00,$00,FramePos[Tile]+Frame*4+3,EffectAdd);
            TextureCol(Images,X1,Y5,X5,Y5,X5,Y2,X1,Y2,$00,Color,$00,$00,FramePos[Tile]+Frame*4+2,EffectAdd);
          End
        Else
        If Tile=WallRock then
          Begin
            TextureCol(Images,X1,Y1,X5,Y1,X5,Y5,X1,Y5,
                       $FF101010,$FF101010,$FF606060,$FF101010,FramePos[Rock]+Frame,EffectAdd);
            TextureCol(Images,X5,Y1,X2,Y1,X2,Y5,X5,Y5,
                       $FF101010,$FF101010,$FF101010,$FF606060,FramePos[Rock]+Frame,EffectAdd);
            TextureCol(Images,X5,Y5,X2,Y5,X2,Y2,X5,Y2,
                       $FF606060,$FF101010,$FF101010,$FF101010,FramePos[Rock]+Frame,EffectAdd);
            TextureCol(Images,X1,Y5,X5,Y5,X5,Y2,X1,Y2,
                       $FF101010,$FF606060,$FF101010,$FF101010,FramePos[Rock]+Frame,EffectAdd);
          End
        Else
          Begin
            Color:=ColorLightning[DayTime]+$FF000000;
            TextureCol(Images,X1,Y1,X5,Y1,X5,Y5,X1,Y5,
                       $FF000000,$FF000000,Color,$FF000000,FramePos[Tile]+Frame,EffectAdd);
            TextureCol(Images,X5,Y1,X2,Y1,X2,Y5,X5,Y5,
                       $FF000000,$FF000000,$FF000000,Color,FramePos[Tile]+Frame,EffectAdd);
            TextureCol(Images,X5,Y5,X2,Y5,X2,Y2,X5,Y2,
                       Color,$FF000000,$FF000000,$FF000000,FramePos[Tile]+Frame,EffectAdd);
            TextureCol(Images,X1,Y5,X5,Y5,X5,Y2,X1,Y2,
                       $FF000000,Color,$FF000000,$FF000000,FramePos[Tile]+Frame,EffectAdd);
          End;
        {$Else}
        If Tile=Water then
          Begin
            TextureCol(Images,X1,Y1,X5,Y1,X5,Y5,X1,Y5,$00,$00,WaterAlpha,$00,FramePos[Tile]+Frame*4+0,EffectAdd);
            TextureCol(Images,X5,Y1,X2,Y1,X2,Y5,X5,Y5,$00,$00,$00,WaterAlpha,FramePos[Tile]+Frame*4+1,EffectAdd);
            TextureCol(Images,X5,Y5,X2,Y5,X2,Y2,X5,Y2,WaterAlpha,$00,$00,$00,FramePos[Tile]+Frame*4+3,EffectAdd);
            TextureCol(Images,X1,Y5,X5,Y5,X5,Y2,X1,Y2,$00,WaterAlpha,$00,$00,FramePos[Tile]+Frame*4+2,EffectAdd);
          End
        Else
        If Tile=WallRock then
          Begin
            TextureCol(Images,X1,Y1,X5,Y1,X5,Y5,X1,Y5,
                       $FF101010,$FF101010,$FF606060,$FF101010,FramePos[Rock]+Frame,EffectAdd);
            TextureCol(Images,X5,Y1,X2,Y1,X2,Y5,X5,Y5,
                       $FF101010,$FF101010,$FF101010,$FF606060,FramePos[Rock]+Frame,EffectAdd);
            TextureCol(Images,X5,Y5,X2,Y5,X2,Y2,X5,Y2,
                       $FF606060,$FF101010,$FF101010,$FF101010,FramePos[Rock]+Frame,EffectAdd);
            TextureCol(Images,X1,Y5,X5,Y5,X5,Y2,X1,Y2,
                       $FF101010,$FF606060,$FF101010,$FF101010,FramePos[Rock]+Frame,EffectAdd);
          End
        Else
          Begin
            //If MyWorld.GetTile(TileX+1,TileY)=WallRock then X2:=X5+LandTileSizeX*3 div 2;
            TextureCol(Images,X1,Y1,X5,Y1,X5,Y5,X1,Y5,
                       $FF000000,$FF000000,$FFFFFFFF,$FF000000,FramePos[Tile]+Frame,EffectAdd);
            TextureCol(Images,X5,Y1,X2,Y1,X2,Y5,X5,Y5,
                       $FF000000,$FF000000,$FF000000,$FFFFFFFF,FramePos[Tile]+Frame,EffectAdd);
            TextureCol(Images,X5,Y5,X2,Y5,X2,Y2,X5,Y2,
                       $FFFFFFFF,$FF000000,$FF000000,$FF000000,FramePos[Tile]+Frame,EffectAdd);
            TextureCol(Images,X1,Y5,X5,Y5,X5,Y2,X1,Y2,
                       $FF000000,$FFFFFFFF,$FF000000,$FF000000,FramePos[Tile]+Frame,EffectAdd);
          End;
        {$EndIf}
      End;
  End;*)
  Var CTile,Tile : TMapTile;
      Frame      : Array[TMapTile] of Byte;
      Draw       : Array[TMapTile] of Boolean;
      {$IfDef ShowWater}
      ShowWater  : Boolean;
      {$EndIf}
      {$IfDef ApplyLightning}
      Color      : LongWord;
      {$EndIf}
  Begin
    With MyScreen,MyWorld,TerrainImages do
      Begin
        {$IfDef ShowWater}
        ShowWater:=False;
        {$EndIf}
        //FillChar(Draw,SizeOf(Draw),False);
        //Calculate frame to draw
        For Tile:=Ice downto Desert do
          If GetTile(TileX,TileY,Tile) then
            Begin
              Frame[Tile]:=GetTileFrame(TileX,TileY,Tile);
              Draw[Tile]:=True;
            End
          Else Draw[Tile]:=False;
        //Recude frame to draw
        For Tile:=Ice downto Desert do
          If GetTile(TileX,TileY,Tile) then
            Begin
              If FrameTile[Frame[Tile]]=0 then
                Begin
                  For CTile:=Tile downto Desert do Draw[CTile]:=False;
                  Draw[Tile]:=True;
                  {$IfDef ShowWater}
                  ShowWater:=True;
                  {$EndIf}
                  Break;
                End
              Else
                Begin
                  {For CTile:=Tile downto Low(TTerrain) do
                    If (Tile<>CTile) and Draw[CTile] and
                       (FrameTile[Frame[Tile]]=FrameTile[Frame[CTile]]) then
                      Draw[CTile]:=False;}
                End;
            End;
        {$IfDef ApplyLightning}
        Color:=ColorLightning[DayTime] or $FF000000;
        {$EndIf}
        For Tile:=Desert to Ice do
          If Draw[Tile] then
            Begin
              If FrameTile[Frame[Tile]]<>0 then
                Begin
                  {$IfDef ShowWater}
                  If Not ShowWater then
                    Screen.RenderEffect(Images,X,Y,FramePos[Water]+WaterFrame,EffectNone);
                  {$EndIf}
                  {$IfNDef ApplyLightning}
                  Screen.RenderEffect(Images,X,Y,
                                      FramePos[Tile]+FrameTile[Frame[Tile]],EffectSrcAlpha);
                  {$Else}
                  Screen.RenderEffectCol(Images,X,Y,Color,
                                         FramePos[Tile]+FrameTile[Frame[Tile]],EffectSrcAlpha);
                  {$EndIf}
                  {$IfDef ShowWater}
                  ShowWater:=True;
                  {$EndIf}
                End
              Else
                Begin
                  {$IfNDef ApplyLightning}
                  Screen.RenderEffect(Images,X,Y,
                                      FramePos[Tile]+FrameTile2[MapTileFrame[TileX,TileY]],EffectNone);
                  {$Else}
                  Screen.RenderEffectCol(Images,X,Y,Color,
                                         FramePos[Tile]+FrameTile2[MapTileFrame[TileX,TileY]],EffectNone);
                  {$EndIf}
                End;
            End;
        {If Not ShowWater then
          Screen.RenderEffect(WaterImage[WaterFrame],X,Y,
                              (TileX mod 2)+(TileY mod 2)*2,EffectNone);{}
      End;
  End;

PROCEDURE TLOCDraw.DrawEffect(EffNum : TEffectedCount);
  Var DX,DY : Integer;
      Color : LongWord;
  Begin
    With MyUnits,MyScreen,MyWorld,Effects[EffNum],EffectedImages do
      Begin
        Case EffectProperty[Typer].EffectKind of
          EffectKindHeroSignFlash :
            Begin
              //That kind of effect must be need target to some unit !
              If LinkToUnit<>0 then
                Begin
                  //Get [DX,DY] to center of unit link !
                  GetRealUnitPos(LinkToUnit,DX,DY);
                  With Units[LinkToUnit] do
                    Begin
                      DX:=DX+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeX)*DefaultMapTileX ShR 1-
                              Images.TextureWidth[ImageNum[Typer]] ShR 1;
                      DY:=DY+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeY)*DefaultMapTileY ShR 1-
                              Images.TextureHeight[ImageNum[Typer]] ShR 1;
                    End;
                  Color:=(TransLevel ShL 16) or (TransLevel ShL 8) or TransLevel;
                  Screen.RenderEffectCol(Images,DX,DY,Color,ImageNum[Typer],EffectAdd);
                End;
            End;
          EffectKindHeroSignFlashRotate :
            Begin
              //That kind of effect must be need target to some unit !
              If LinkToUnit<>0 then
                Begin
                  //Get [DX,DY] to center of unit link !
                  GetRealUnitPos(LinkToUnit,DX,DY);
                  With Units[LinkToUnit] do
                    Begin
                      DX:=DX+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeX)*DefaultMapTileX ShR 1;
                      DY:=DY+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeY)*DefaultMapTileY ShR 1;
                    End;
                  Color:=(TransLevel ShL 16) or (TransLevel ShL 8) or TransLevel;
                  Screen.RotateEffect(Images,DX,DY,Angle,256,Color,ImageNum[Typer],EffectAdd);
                End;
            End;
        End;
      End;
  End;

PROCEDURE TLOCDraw.GetRealUnitPos(UnitNum : TUnitCount;Var DX,DY : Integer);
  Var CmdDraw : TSkill;
  Begin
    With MyUnits,MyScreen,MyWorld do
      Begin
        If UnitNum=0 then Exit;
        With Units[UnitNum],UnitAnimations[_UnitTyper] do
          Begin
            If _UnitFrame=FrameUnUsed then CmdDraw:=NoCmd
            Else CmdDraw:=_UnitCmd;
            DX:=ViewPosXOS+(_UnitPos.X-MapViewX)*DefaultMapTileX
                {$IfDef RandomUnitPosShift}+_ShiftPX{$EndIf};
            DY:=ViewPosYOS+(_UnitPos.Y-MapViewY)*DefaultMapTileY
                {$IfDef RandomUnitPosShift}+_ShiftPY{$EndIf};
            Case CmdDraw of
              //Draw unit no command / stand script
              NoCmd,CmdStop :
                Begin
                End;
              //Draw unit stand after attack, castspell...
              CmdWasted,CmdHoldPosition :
                Begin
                End;
              //Draw unit in moving to attack, patrol, move ... / run script
              CmdPatrol,CmdMove,CmdFollow,CmdAttack,CmdAttackAt,CmdBuild,CmdCastSpell,
              CmdHarvest,CmdReturnGold,CmdPutItem,CmdPickItem,CmdLoadUnit,CmdUnLoadUnit,
              CmdGoTransport :
                Begin
                  DX:=DX-Direction[_UnitHeading].X*(DefaultMapTileX-
                                                    RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
                  DY:=DY-Direction[_UnitHeading].Y*(DefaultMapTileY-
                                                    RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
                End;
              CmdAttacking,CmdAttackingStand :
                Begin
                End;
              CmdCastSpelling :
                Begin
                End;
              CmdStartBuild :
                Begin
                End;
            End;
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawUnit(UnitNum : TUnitCount);
  Var DrawFrame    : TUnitFrame;
      Frame2Draw   : TNumFrame;
      FrameStyle   : TFrameStyle;
      ImagesToDraw : TAvenusTextureImages;
      DX,DY        : Integer;
      CmdDraw      : TSkill;
  Begin
    With MyUnits,MyScreen,MyWorld do
      Begin
        If (UnitNum=0) or UnitDraw[UnitNum] then Exit;
        //Draw all unit dead.. except unit alive and can't see this
        {$IfDef DeadUnitCanSeeUnderFog}
        If Units[UnitNum]._UnitHitPoint>0 then
        {$EndIf}
        If Not CanSeeThisUnit(HumanControl,UnitNum) then Exit;
        UnitDraw[UnitNum]:=True;
        With Units[UnitNum],UnitAnimations[_UnitTyper] do
          Begin
            If _UnitFrame=FrameUnUsed then
              Begin
                DrawFrame:=0;
                CmdDraw:=NoCmd;
              End
            Else
              Begin
                DrawFrame:=_UnitFrame;
                CmdDraw:=_UnitCmd;
              End;
            FrameStyle:=0;
            Frame2Draw:=0;
            ImagesToDraw:=Images;
            DX:=ViewPosXOS+(_UnitPos.X-MapViewX)*DefaultMapTileX
                {$IfDef RandomUnitPosShift}+_ShiftPX{$EndIf}+ShiftX;
            DY:=ViewPosYOS+(_UnitPos.Y-MapViewY)*DefaultMapTileY
                {$IfDef RandomUnitPosShift}+_ShiftPY{$EndIf}+ShiftY;
            {$IfNDef SwitchPeonType}
            Case _UnitTyper of
              Peon :
                Begin
                  If UnitResource.NormalRes[ResGold]>0 then
                    ImagesToDraw:=UnitAnimations[PeonWithGold].Images;
                End;
              Peasant :
                Begin
                  If UnitResource.NormalRes[ResGold]>0 then
                    ImagesToDraw:=UnitAnimations[Peasant].Images;
                End;
            End;
            {$EndIf}
            Case CmdDraw of
              //Draw unit no command / stand script
              NoCmd,CmdStop :
                Begin
                  Frame2Draw:=StandScript.Script[_UnitHeading,DrawFrame].FrameNum;
                  FrameStyle:=StandScript.Script[_UnitHeading,DrawFrame].FrameStyle;
                End;
              //Draw unit stand after attack, castspell...
              CmdWasted,CmdHoldPosition :
                Begin
                  Frame2Draw:=WastedScript.Script[_UnitHeading,DrawFrame].FrameNum;
                  FrameStyle:=WastedScript.Script[_UnitHeading,DrawFrame].FrameStyle;
                End;
              //Draw unit in moving to attack, patrol, move ... / run script
              CmdPatrol,CmdMove,CmdFollow,CmdAttack,CmdAttackAt,CmdBuild,CmdCastSpell,
              CmdHarvest,CmdReturnGold,CmdPutItem,CmdPickItem,CmdLoadUnit,CmdUnLoadUnit,
              CmdGoTransport :
                Begin
                  DX:=DX-Direction[_UnitHeading].X*(DefaultMapTileX-
                                                    RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
                  DY:=DY-Direction[_UnitHeading].Y*(DefaultMapTileY-
                                                    RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
                  Frame2Draw:=RunScript.Script[_UnitHeading,DrawFrame].FrameNum;
                  FrameStyle:=RunScript.Script[_UnitHeading,DrawFrame].FrameStyle;
                End;
              CmdAttacking,CmdAttackingStand :
                Begin
                  Frame2Draw:=AttackScript.Script[_UnitHeading,DrawFrame].FrameNum;
                  FrameStyle:=AttackScript.Script[_UnitHeading,DrawFrame].FrameStyle;
                End;
              CmdCastSpelling :
                Begin
                  Frame2Draw:=AttackScript.Script[_UnitHeading,DrawFrame].FrameNum;
                  FrameStyle:=AttackScript.Script[_UnitHeading,DrawFrame].FrameStyle;
                End;
              CmdDead :
                Begin
                  Frame2Draw:=DeadScript.Script[_UnitHeading,DrawFrame].FrameNum;
                  FrameStyle:=DeadScript.Script[_UnitHeading,DrawFrame].FrameStyle;
                End;
              CmdStartBuild :
                Begin
                  Frame2Draw:=0;
                  FrameStyle:=0;
                  ImagesToDraw:=UnitAnimations[ConstructionLand].Images;
                  DX:=DX+((1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeX)*DefaultMapTileX-
                          ImagesToDraw.TextureWidth[Frame2Draw]) div 2-ShiftX;
                  DY:=DY+((1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeY)*DefaultMapTileY-
                          ImagesToDraw.TextureHeight[Frame2Draw]) div 2-ShiftY;
                End;
            End;
            //Unit has a shadow, I draw unit shadow first !
            If UnitHasShadow in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
              Begin
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(ImagesToDraw,DX+ShadowShiftX,DY+ShadowShiftY,Shadow50PercentValue,Frame2Draw,EffectShadow+EffectMirror)
                Else Screen.RenderEffectCol(ImagesToDraw,DX+ShadowShiftX,DY+ShadowShiftY,Shadow50PercentValue,Frame2Draw,EffectShadow);
                Screen.RenderBuffer;
              End;
            //Get real unit color
            If ImagesToDraw=Images then
              Begin
                If UnitHaveMask then
                  Begin
                    {$IfDef SafeLockAndUnLockTexture}
                    ImagesToDraw.Lock(Frame2Draw,ImagesToDraw.Ptr[Frame2Draw]);
                    {$EndIf}
                    PasterSprite(Sprites[Frame2Draw].Data,ImagesToDraw.Ptr[Frame2Draw].pBits,
                                 Sprites[Frame2Draw].DataSize div 2,MaskColor,@PalSwitch[_UnitColor]);
                    {$IfDef SafeLockAndUnLockTexture}
                    ImagesToDraw.UnLock(Frame2Draw);
                    {$EndIf}
                  End;
              End;
            //Draw unit
            If GetUnitAttribute(UnitNum,UnitInvisible) then
            //If TestUnitEffected(UnitNum,Invisible) then
              //Unit invisible ?
              Begin
                //Draw shadow first, this the chick for draw invisible unit perfectly
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(ImagesToDraw,DX,DY,Shadow50PercentValue,Frame2Draw,EffectShadow+EffectMirror)
                Else Screen.RenderEffectCol(ImagesToDraw,DX,DY,Shadow50PercentValue,Frame2Draw,EffectShadow);
                Screen.RenderBuffer;
                {$IfDef ApplyLightning}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(ImagesToDraw,DX,DY,
                                         ColorAlphaBlend,Frame2Draw,EffectBlendColor+EffectMirror)
                Else Screen.RenderEffectCol(ImagesToDraw,DX,DY,
                                            ColorAlphaBlend,Frame2Draw,EffectBlendColor);
                {$Else}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffect(ImagesToDraw,DX,DY,Frame2Draw,EffectBlend1+EffectMirror)
                Else Screen.RenderEffect(ImagesToDraw,DX,DY,Frame2Draw,EffectBlend1);
                {$EndIf}
              End
            Else
              Begin
                {$IfDef ApplyLightning}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(ImagesToDraw,DX,DY,
                                         ColorLightning[DayTime],Frame2Draw,EffectSrcAlpha+EffectMirror)
                Else Screen.RenderEffectCol(ImagesToDraw,DX,DY,
                                            ColorLightning[DayTime],Frame2Draw,EffectSrcAlpha);
                {$Else}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffect(ImagesToDraw,DX,DY,Frame2Draw,EffectSrcAlpha+EffectMirror)
                Else Screen.RenderEffect(ImagesToDraw,DX,DY,Frame2Draw,EffectSrcAlpha);
                {$EndIf}
              End;
            Screen.RenderBuffer;
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawUnitSelected(UnitNum : TUnitCount);
  Var DX,DY   : Integer;
      CmdDraw : TSkill;
      Color   : LongWord;
  Begin
    With MyUnits,MyScreen,MyWorld do
      Begin
        If UnitNum=0 then Exit;
        //Draw all unit dead.. except unit alive and can't see this
        {$IfDef DeadUnitCanSeeUnderFog}
        If Units[UnitNum]._UnitHitPoint>0 then
        {$EndIf}
        If Not CanSeeThisUnit(HumanControl,UnitNum) then Exit;
        With Units[UnitNum],UnitAnimations[_UnitTyper] do
          Begin
            //Unit has selected or command wait is command for building
            //If (Not (UnitGroup and 128=128)) and (CmdWaitForSelect<>CmdBuild) then Exit;
            If (Not (_UnitGroup and 128=128)) and
               (Not (ClanInfo[HumanControl].UnitClick=UnitNum)) then Exit;
            If (ClanInfo[HumanControl].UnitClick=UnitNum) and
               ((ClanInfo[HumanControl].ClickCount div 4) mod 2<>0) then Exit;
            If _UnitFrame=FrameUnUsed then CmdDraw:=NoCmd
            Else CmdDraw:=_UnitCmd;
            DX:=ViewPosXOS+(_UnitPos.X-MapViewX)*DefaultMapTileX
                {$IfDef RandomUnitPosShift}+_ShiftPX{$EndIf};
            DY:=ViewPosYOS+(_UnitPos.Y-MapViewY)*DefaultMapTileY
                {$IfDef RandomUnitPosShift}+_ShiftPY{$EndIf};
            Case CmdDraw of
              //Draw unit no command / stand script
              NoCmd,CmdStop :
                Begin
                End;
              //Draw unit stand after attack, castspell...
              CmdWasted,CmdHoldPosition :
                Begin
                End;
              //Draw unit in moving to attack, patrol, move ... / run script
              CmdPatrol,CmdMove,CmdFollow,CmdAttack,CmdAttackAt,CmdBuild,CmdCastSpell,
              CmdHarvest,CmdReturnGold,CmdPutItem,CmdPickItem,CmdLoadUnit,CmdUnLoadUnit,
              CmdGoTransport :
                Begin
                  DX:=DX-Direction[_UnitHeading].X*(DefaultMapTileX-
                                                    RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
                  DY:=DY-Direction[_UnitHeading].Y*(DefaultMapTileY-
                                                    RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
                End;
              CmdAttacking,CmdAttackingStand :
                Begin
                End;
              CmdCastSpelling :
                Begin
                End;
              CmdStartBuild :
                Begin
                End;
            End;
            If _UnitClan=HumanControl then Color:=Green
            Else
              Begin
                Case ClanInfo[HumanControl].Diplomacy[_UnitClan] of
                  Ally,Neutral : Color:=Yellow;
                  Enemy        : Color:=Red;
                  Else Color:=Green;
                End;
              End;
            Case UnitSelectStyle of
              Square :
                Screen.Rect(DX,DY,
                            DX+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeX)*DefaultMapTileX,
                            DY+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeY)*DefaultMapTileY,
                            Color,EffectNone);
              Ellipse :
                {Screen.Ellipse(DX+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeX)*DefaultMapTileX div 2,
                               DY+(1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeY)*DefaultMapTileY div 2,
                               18,14,Green);}
            End;
          End;
      End;
  End;

FUNCTION  TLOCDraw.UnitCheckedPoint(UnitNum : TUnitCount;X,Y,MX,MY : FastInt) : Boolean;
  Var DrawFrame    : TUnitFrame;
      DX,DY        : Integer;
      Frame2Draw   : TNumFrame;
      FrameStyle   : TFrameStyle;
      ImagesToDraw : TAvenusTextureImages;
      Color        : LongWord;
      CmdDraw      : TSkill;
  Begin
    Result:=True;
    With MyScreen,MyUnits,MyWorld,Units[UnitNum],UnitAnimations[_UnitTyper] do
      Begin
        If _UnitFrame=FrameUnUsed then
          Begin
            DrawFrame:=0;
            CmdDraw:=NoCmd;
          End
        Else
          Begin
            DrawFrame:=_UnitFrame;
            CmdDraw:=_UnitCmd;
          End;
        X:=X+(MX-_UnitPos.X)*DefaultMapTileX;
        Y:=Y+(MY-_UnitPos.Y)*DefaultMapTileY;
        //Color:=TransparentColor;
        FrameStyle:=0;
        Frame2Draw:=0;
        ImagesToDraw:=Images;
        DX:={$IfDef RandomUnitPosShift}+_ShiftPX{$EndIf}+ShiftX;
        DY:={$IfDef RandomUnitPosShift}+_ShiftPY{$EndIf}+ShiftY;
        Case CmdDraw of
          //Draw unit no command / stand script
          NoCmd,CmdStop :
            Begin
              Frame2Draw:=StandScript.Script[_UnitHeading,DrawFrame].FrameNum;
              FrameStyle:=StandScript.Script[_UnitHeading,DrawFrame].FrameStyle;
            End;
          //Draw unit stand after attack, castspell...
          CmdWasted,CmdHoldPosition :
            Begin
              Frame2Draw:=WastedScript.Script[_UnitHeading,DrawFrame].FrameNum;
              FrameStyle:=WastedScript.Script[_UnitHeading,DrawFrame].FrameStyle;
            End;
          //Draw unit in moving to attack, patrol, move ... / run script
          CmdPatrol,CmdMove,CmdFollow,CmdAttack,CmdAttackAt,CmdBuild,CmdCastSpell,
          CmdHarvest,CmdReturnGold,CmdPutItem,CmdPickItem,CmdLoadUnit,CmdUnLoadUnit,
          CmdGoTransport :
            Begin
              DX:=DX-Direction[_UnitHeading].X*(DefaultMapTileX-
                                                RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
              DY:=DY-Direction[_UnitHeading].Y*(DefaultMapTileY-
                                                RunScript.Script[_UnitHeading,_UnitFrame].FrameShift);
              Frame2Draw:=RunScript.Script[_UnitHeading,DrawFrame].FrameNum;
              FrameStyle:=RunScript.Script[_UnitHeading,DrawFrame].FrameStyle;
            End;
          CmdAttacking,CmdAttackingStand :
            Begin
              Frame2Draw:=AttackScript.Script[_UnitHeading,DrawFrame].FrameNum;
              FrameStyle:=AttackScript.Script[_UnitHeading,DrawFrame].FrameStyle;
            End;
          CmdDead :
            Begin
              Frame2Draw:=DeadScript.Script[_UnitHeading,DrawFrame].FrameNum;
              FrameStyle:=DeadScript.Script[_UnitHeading,DrawFrame].FrameStyle;
            End;
          CmdStartBuild :
            Begin
              Frame2Draw:=0;
              FrameStyle:=0;
              ImagesToDraw:=UnitAnimations[ConstructionLand].Images;
              DX:=DX+((1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeX)*DefaultMapTileX-
                      ImagesToDraw.TextureWidth[Frame2Draw]) div 2-ShiftX;
              DY:=DY+((1+UnitsProperty[_UnitColor,_UnitTyper].UnitSizeY)*DefaultMapTileY-
                      ImagesToDraw.TextureHeight[Frame2Draw]) div 2-ShiftY;
            End;
        End;
        If FrameStyle and FrameMirrorH=FrameMirrorH then
          Color:=ReadPixel(ImagesToDraw,Frame2Draw,
                           ImagesToDraw.TextureWidth[Frame2Draw]-(X-DX),Y-DY,0)
        Else Color:=ReadPixel(ImagesToDraw,Frame2Draw,X-DX,Y-DY,0);
        If Color<>0 then Exit;
      End;
    Result:=False;
  End;

PROCEDURE TLOCDraw.DrawAllUnitLevel(PosX,PosY : FastInt;Level : TDrawLevel);
  Var UnitNum : FastInt;
  Begin
    With MyUnits,MyScreen,MyWorld do
      Begin
        UnitNum:=MapNum[PosX,PosY];
        While UnitNum<>0 do
          With Units[UnitNum] do
            Begin
              If _UnitHitPoint=0 then
                Begin
                  If Level=0 then DrawUnit(UnitNum);
                End
              Else
              If UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel=Level then DrawUnit(UnitNum);
              UnitNum:=_UnitNext;
            End;
      End;
  End;

PROCEDURE TLOCDraw.DrawAllUnitSelectedLevel(PosX,PosY : FastInt;Level : TDrawLevel);
  Var UnitNum,EffNum : FastInt;
  Begin
    With MyUnits,MyScreen,MyWorld do
      Begin
        UnitNum:=MapNum[PosX,PosY];
        While UnitNum<>0 do
          With Units[UnitNum] do
            Begin
              If _UnitHitPoint=0 then
                Begin
                  If Level=0 then DrawUnitSelected(UnitNum);
                End
              Else
              If UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel=Level then
                Begin
                  DrawUnitSelected(UnitNum);
                  //Draw all effected level 0 link to this unit ?
                  EffNum:=_UnitEffected;
                  While EffNum<>0 do
                    Begin
                      If EffectProperty[Effects[EffNum].Typer].DrawLevel=0 then
                        DrawEffect(EffNum);
                      EffNum:=Effects[EffNum].NextEffect;
                    End;
                End;
              UnitNum:=_UnitNext;
            End;
      End;
  End;

PROCEDURE TLOCDraw.DrawUnitUnderFog(PosX,PosY : FastInt);
  Var DrawFrame : TUnitFrame;
      DX,DY     : Integer;
      _UnitTyper : TUnit;
      Heading   : THeading;
  Begin
    With MyUnits,MyScreen,MyWorld do
      Begin
        _UnitTyper:=MapUnitUnderFog[PosX,PosY]._UnitTyper;
        If _UnitTyper=NoneUnit then Exit;
        //If UnitUnderFogVisible(PosX,PosY) then Exit;
        DrawFrame:=0;
        Heading:=MapUnitUnderFog[PosX,PosY].Heading;
        DX:=ViewPosXOS+(PosX-MapViewX)*DefaultMapTileX
            {$IfDef RandomUnitPosShift}+MapUnitUnderFog[PosX,PosY]._ShiftPX{$EndIf};
        DY:=ViewPosYOS+(PosY-MapViewY)*DefaultMapTileY
            {$IfDef RandomUnitPosShift}+MapUnitUnderFog[PosX,PosY]._ShiftPY{$EndIf};
        With UnitAnimations[_UnitTyper] do
          Begin
            If UnitHaveMask then
              Begin
                {$IfDef SafeLockAndUnLockTexture}
                Images.Lock(DrawFrame,Images.Ptr[DrawFrame]);
                {$EndIf}
                PasterSprite(Sprites[DrawFrame].Data,Images.Ptr[DrawFrame].PBits,
                             Sprites[DrawFrame].DataSize div 2,MaskColor,
                             @PalSwitch[MapUnitUnderFog[PosX,PosY]._UnitColor]);
                {$IfDef SafeLockAndUnLockTexture}
                Images.UnLock(DrawFrame);
                {$EndIf}
              End;
            {$IfDef ApplyLightning}
            If StandScript.Script[Heading,DrawFrame].FrameStyle and FrameMirrorH=FrameMirrorH then
              Screen.RenderEffectCol(Images,DX+ShiftX,DY+ShiftY,ColorLightning[DayTime],
                                    StandScript.Script[Heading,DrawFrame].FrameNum,EffectSrcAlpha+EffectMirror)
            Else Screen.RenderEffectCol(Images,DX+ShiftX,DY+ShiftY,ColorLightning[DayTime],
                                        StandScript.Script[Heading,DrawFrame].FrameNum,EffectSrcAlpha);
            {$Else}
            If StandScript.Script[Heading,DrawFrame].FrameStyle and FrameMirrorH=FrameMirrorH then
              Screen.RenderEffect(Images,DX+ShiftX,DY+ShiftY,
                                  StandScript.Script[Heading,DrawFrame].FrameNum,EffectSrcAlpha+EffectMirror)
            Else Screen.RenderEffect(Images,DX+ShiftX,DY+ShiftY,
                                     StandScript.Script[Heading,DrawFrame].FrameNum,EffectSrcAlpha);
            {$EndIf}
          End;
        Screen.RenderBuffer;
      End;
  End;

PROCEDURE TLOCDraw.DrawMissile(MissileNum : TMissileCount);
  Var X,Y,XS,YS  : Integer;
      FrameStyle : TFrameStyle;
      FrameNum   : TNumFrame;
  Begin
    With MyScreen,MyUnits,MyWorld,Missiles[MissileNum] do
      Begin
        With MissileAnimations[Typer] do
          Begin
            X:=MisPos.X div DefaultMapTileX-MapViewX+ShiftX;
            Y:=MisPos.Y div DefaultMapTileY-MapViewY+ShiftY;
            Case MisState of
              Flying :
                Begin
                  FrameStyle:=FlyingScript.FramePos[Head][Frame].FrameStyle;
                  FrameNum:=FlyingScript.FramePos[Head][Frame].FrameNum;
                End;
              Explosion :
                Begin
                  FrameStyle:=ExplosionScript.FramePos[Head][Frame].FrameStyle;
                  FrameNum:=ExplosionScript.FramePos[Head][Frame].FrameNum;
                End
              Else
                Begin
                  FrameStyle:=0;
                  FrameNum:=0;
                End;
            End;
            XS:=ViewPosXOS+X*DefaultMapTileX+MisPos.X mod DefaultMapTileX
                -Images.TextureWidth[FrameNum] div 2;
            YS:=ViewPosYOS+Y*DefaultMapTileY+MisPos.Y mod DefaultMapTileY
                -Images.TextureHeight[FrameNum] div 2;
            //Missile shadow ?
            If MissileProperty[Typer].MissileAttribute and MissileHasShadow=MissileHasShadow then
              Begin
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(Images,XS+MisShadowShiftX,YS+MisShadowShiftY,
                                         Shadow50PercentValue,FrameNum,EffectShadow+EffectMirror)
                Else Screen.RenderEffectCol(Images,XS+MisShadowShiftX,YS+MisShadowShiftY,
                                            Shadow50PercentValue,FrameNum,EffectShadow);
                Screen.RenderBuffer;
              End;
            //Draw missile
            If MissileProperty[Typer].MissileEffect=EffectRealBlend then
              Begin
                {$IfDef MissileEffectItSelf}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(Images,XS,YS,
                                         Shadow50PercentValue,FrameNum,EffectShadow+EffectMirror)
                Else Screen.RenderEffectCol(Images,XS,YS,
                                            Shadow50PercentValue,FrameNum,EffectShadow);
                Screen.RenderBuffer;
                {$IfDef ApplyLightning}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(Images,XS,YS,
                                         ColorLightning[DayTime] or MissileProperty[Typer].AlphaChannel,
                                         FrameNum,EffectBlendColor+EffectMirror)
                Else Screen.RenderEffectCol(Images,XS,YS,
                                            ColorLightning[DayTime] or MissileProperty[Typer].AlphaChannel,
                                            FrameNum,EffectBlendColor);
                {$Else}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffect(Images,XS,YS,FrameNum,EffectBlendColor+EffectMirror)
                Else Screen.RenderEffect(Images,XS,YS,FrameNum,EffectBlendColor);
                {$EndIf}
                {$Else}
                {$IfDef ApplyLightning}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(Images,XS,YS,ColorLightning[DayTime],
                                         FrameNum,EffectSrcAlpha+EffectMirror)
                Else Screen.RenderEffectCol(Images,XS,YS,ColorLightning[DayTime],
                                            FrameNum,EffectSrcAlpha);
                {$Else}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffect(Images,XS,YS,FrameNum,EffectSrcAlpha+EffectMirror)
                Else Screen.RenderEffect(Images,XS,YS,FrameNum,EffectSrcAlpha);
                {$EndIf}
                {$EndIf}
                Screen.RenderBuffer;
              End
            Else
              Begin
                {$IfDef MissileEffectItSelf}
                {$IfDef ApplyLightning}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(Images,XS,YS,
                                         ColorLightning[DayTime] or MissileProperty[Typer].AlphaChannel,
                                         FrameNum,MissileProperty[Typer].MissileEffect+EffectMirror)
                Else Screen.RenderEffectCol(Images,XS,YS,
                                            ColorLightning[DayTime] or MissileProperty[Typer].AlphaChannel,
                                            FrameNum,MissileProperty[Typer].MissileEffect);
                {$Else}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffect(Images,XS,YS,FrameNum,MissileProperty[Typer].MissileEffect+EffectMirror)
                Else Screen.RenderEffect(Images,XS,YS,FrameNum,MissileProperty[Typer].MissileEffect);
                {$EndIf}
                {$Else}
                {$IfDef ApplyLightning}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffectCol(Images,XS,YS,ColorLightning[DayTime],
                                         FrameNum,EffectSrcAlpha+EffectMirror)
                Else Screen.RenderEffectCol(Images,XS,YS,ColorLightning[DayTime],
                                            FrameNum,EffectSrcAlpha);
                {$Else}
                If FrameStyle and FrameMirrorH=FrameMirrorH then
                  Screen.RenderEffect(Images,XS,YS,FrameNum,EffectSrcAlpha+EffectMirror)
                Else Screen.RenderEffect(Images,XS,YS,FrameNum,EffectSrcAlpha);
                {$EndIf}
                {$EndIf}
                Screen.RenderBuffer;
              End;
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawViewMap;
  Var I,J,X,Y,UnitNum : FastInt;
      Color           : LongWord;
      Clan            : TClan;
      Typer           : TUnit;
  Begin
    With MyScreen,MyUnits,MyWorld do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(0,0,ScreenWidth,ScreenHeight);
        {$EndIf}
        With MiniMapImage do
          Begin
            {$IfDef SafeLockAndUnLockTexture}
            Lock(0,Ptr[0]);
            {$Else}
            {$IfDef SafeLockMiniMap}
            Lock(0,Ptr[0]);
            {$EndIf}
            {$EndIf}
            Clear(0,0);
            //Show terrain
            For I:=0 to MapViewDivX do
              For J:=0 to MapViewDivY do
                If Not GetTileAttr(MapViewPosX+I,MapViewPosY+J,MapDontVisited) then
                  Begin
                    If GetTileAttr(MapViewPosX+I,MapViewPosY+J,MapDontVisible) then
                      Color:=MiniMapDarkColor[(MapViewPosX+I) ShR 1,(MapViewPosY+J) ShR 1]
                    Else Color:=MiniMapColor[(MapViewPosX+I) ShR 1,(MapViewPosY+J) ShR 1];
                    PutPixel(0,I+1,J+1,Color);
                  End;
            //Show unit
            For I:=0 to MapViewDivX do
              For J:=0 to MapViewDivY do
                Begin
                  If MapNum[MapViewPosX+I,MapViewPosY+J]<>0 then
                    Begin
                      UnitNum:=MapNum[MapViewPosX+I,MapViewPosY+J];
                      //Unit alive and player Humancontrol can see this unit ?
                      //If (Units[UnitNum].HitPoint>0) then
                      If (Units[UnitNum]._UnitHitPoint>0) and
                         CanSeeThisUnit(HumanControl,UnitNum) then
                        With Units[UnitNum] do
                          Case MiniMapStyle of
                            ShowPixel :
                              Begin                                   
                                For X:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
                                  For Y:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                                    PutPixel(0,I+1+X,J+1+Y,ClansColor[_UnitColor]);
                              End;
                            ShowRect :
                              Begin
                                FillRect(0,I+1-FixedUnitSizeOnMiniMap,
                                           J+1-FixedUnitSizeOnMiniMap,
                                           I+1+FixedUnitSizeOnMiniMap+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX,
                                           J+1+FixedUnitSizeOnMiniMap+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY,
                                           ClansColor[_UnitColor]);
                              End;
                          End;
                    End;
                  //Apply unit under fog
                  Typer:=MapUnitUnderFog[MapViewPosX+I,MapViewPosY+J]._UnitTyper;
                  If Typer<>NoneUnit then
                    Begin
                      Clan:=MapUnitUnderFog[MapViewPosX+I,MapViewPosY+J]._UnitColor;
                      Case MiniMapStyle of
                        ShowPixel :
                          Begin
                            For X:=0 to UnitsProperty[Clan,Typer].UnitSizeX do
                              For Y:=0 to UnitsProperty[Clan,Typer].UnitSizeY do
                                PutPixel(0,I+1+X,J+1+Y,ClansColor[Clan]);
                          End;
                        ShowRect :
                          Begin
                            FillRect(0,I+1-FixedUnitSizeOnMiniMap,
                                       J+1-FixedUnitSizeOnMiniMap,
                                       I+1+FixedUnitSizeOnMiniMap+UnitsProperty[Clan,Typer].UnitSizeX,
                                       J+1+FixedUnitSizeOnMiniMap+UnitsProperty[Clan,Typer].UnitSizeY,
                                       ClansColor[Clan]);
                          End;
                      End;
                    End;
                End;
            Rect(0,MapViewX-MapViewPosX,
                   MapViewY-MapViewPosY,
                   MapViewX+DefaultMapViewX-MapViewPosX+2,
                   MapViewY+DefaultMapViewY-MapViewPosY+2,65535);
            Rect(0,0,0,MapViewDivX+2,MapViewDivY+2,65535);
            {$IfDef SafeLockAndUnLockTexture}
            UnLock(0);
            {$Else}
            {$IfDef SafeLockMiniMap}
            UnLock(0);
            {$EndIf}
            {$EndIf}
          End;
        Screen.RenderEffect(MiniMapImage,MapViewPosXOS,MapViewPosYOS,0,EffectNone);
        Screen.RenderBuffer;
        {}
        {Screen.Bar(MapViewPosXOS-1,
                   MapViewPosYOS-1,
                   MapViewDivX+1,
                   MapViewDivY+1,0,EffectNone);
        //Show terrain
        For I:=0 to MapViewDivX do
          For J:=0 to MapViewDivY do
            Begin
              Case MapTile[(MapViewPosX+I) ShR 1,(MapViewPosY+J) ShR 1] of
                WallRock : Color:=23423;
                Else Color:=$FFFFFF;
              End;
              //Screen.FillRect(MapViewPosXOS+I div 2,MapViewPosYOS+J div 2,2,2,Color,EffectNone);
              //Screen.PutPixel(MapViewPosXOS+I,MapViewPosYOS+J,Color,EffectNone);
            End;
        //Show units
        For I:=0 to MapViewDivX do
          For J:=0 to MapViewDivY do
            If MapNum[MapViewPosX+I,MapViewPosY+J]<>0 then
              Begin
                UnitNum:=MapNum[MapViewPosX+I,MapViewPosY+J];
                If CanSeeThisUnit(UnitNum) then
                  With Units[UnitNum] do
                    Case MiniMapStyle of
                      ShowPixel :
                        Begin
                          For X:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX do
                            For Y:=0 to UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY do
                              Screen.PutPixel(MapViewPosXOS+I+X,MapViewPosYOS+J+Y,ClansColor[_UnitColor],EffectNone);
                              //Screen.PutPixel(MapViewPosXOS+I+X,MapViewPosYOS+J+Y,PalSwitch[_UnitColor,1],EffectNone);
                        End;
                      ShowRect :
                        Begin
                          Screen.Bar(MapViewPosXOS+I-FixedUnitSizeOnMiniMap,
                                     MapViewPosYOS+J-FixedUnitSizeOnMiniMap,
                                     MapViewPosXOS+I+FixedUnitSizeOnMiniMap+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX,
                                     MapViewPosYOS+J+FixedUnitSizeOnMiniMap+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY,
                                     ClansColor[_UnitColor],EffectNone);
                        End;
                    End;
              End;
        Screen.Rect(MapViewPosXOS-1,
                    MapViewPosYOS-1,
                    MapViewPosXOS+MapViewDivX+1,
                    MapViewPosYOS+MapViewDivY+1,White,EffectNone);
        Screen.Rect(MapViewPosXOS+MapViewX-MapViewPosX,
                    MapViewPosYOS+MapViewY-MapViewPosY,
                    MapViewPosXOS+MapViewX+DefaultMapViewX-MapViewPosX,
                    MapViewPosYOS+MapViewY+DefaultMapViewY-MapViewPosY,White,EffectNone);
        {}
      End;
  End;

PROCEDURE TLOCDraw.DrawFogMap;
  Var I,J : FastInt;
  Begin
    With MyScreen,MyWorld do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(ViewPosXOS,ViewPosYOS,ViewPosX2OS,ViewPosY2OS);
        {$EndIf}
        For I:=0 to DefaultMapViewX do
          For J:=0 to DefaultMapViewY do
            Begin
              If GetTileAttr(MapViewX+I,MapViewY+J,MapDontVisited)=True then
                Begin
                  Screen.Bar(ViewPosXOS+I*DefaultMapTileX,
                             ViewPosYOS+J*DefaultMapTileY,
                             ViewPosXOS+(I+1)*DefaultMapTileX,
                             ViewPosYOS+(J+1)*DefaultMapTileY,0,EffectNone);
                End
              Else
              If GetTileAttr(MapViewX+I,MapViewY+J,MapDontVisible)=True then
                Begin
                  Screen.Bar(ViewPosXOS+I*DefaultMapTileX,
                             ViewPosYOS+J*DefaultMapTileY,
                             ViewPosXOS+(I+1)*DefaultMapTileX,
                             ViewPosYOS+(J+1)*DefaultMapTileY,$808080,EffectInvSrcColor);
                End
            End;
      End;
  End;

PROCEDURE TLOCDraw.DrawViewScreen;
  Var X1,Y1,X2,Y2,I,J : FastInt;
      Level           : TDrawLevel;            
  Begin
    FillChar(UnitDraw,SizeOf(UnitDraw),False);
    With MyScreen,MyUnits,MyWorld do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(ViewPosXOS-1,ViewPosYOS-1,
                           ViewPosX2OS+1,ViewPosY2OS+1);
        {$EndIf}
        Screen.Rect(ViewPosXOS-1,ViewPosYOS-1,
                    ViewPosX2OS+1,ViewPosY2OS+1,White,EffectNone);
        {$IfDef FullClip}
        Screen.SetClipRect(ViewPosXOS,ViewPosYOS,
                           ViewPosX2OS,ViewPosY2OS);
        {$EndIf}
        X1:=MapViewX-MaxUnitSizeX;
        X2:=MapViewX+DefaultMapViewX+MaxUnitSizeX;
        Y1:=MapViewY-MaxUnitSizeY;
        Y2:=MapViewY+DefaultMapViewY+MaxUnitSizeY;
        If X1<0 then X1:=0;
        If Y1<0 then Y1:=0;
        If X2>=MapSizeX then X2:=MapSizeX-1;
        If Y2>=MapSizeY then Y2:=MapSizeY-1;
        //Draw map tile
        TerrainRender;
        //Draw unit under fog - old vision
        For J:=Y1 to Y2 do
          For I:=X1 to X2 do DrawUnitUnderFog(I,J);
        //Draw unit
        For Level:=Low(TDrawLevel) to High(TDrawLevel) do
          Begin
            For J:=Y1 to Y2 do
              For I:=X1 to X2 do DrawAllUnitSelectedLevel(I,J,Level);
            For J:=Y1 to Y2 do
              For I:=X1 to X2 do DrawAllUnitLevel(I,J,Level);
          End;
        //Draw missiles
        For I:=Low(Missiles) to High(Missiles) do
          If CanSeeMissile(I) and (Missiles[I].Typer<>MissileGreenCross) then DrawMissile(I);
        DrawFogMap;
        //Draw green cross
        For I:=Low(Missiles) to High(Missiles) do
          If CanSeeMissile(I) and (Missiles[I].Typer=MissileGreenCross) then DrawMissile(I);
        {Screen.RenderEffect(UnitAnimations[GundamBattleShip1].Images,300,300,0,EffectSrcAlpha);
        Screen.RenderBuffer;{}
      End;
  End;

PROCEDURE TLOCDraw.DrawUserInterface;
  Begin
    With MyScreen do
      Begin
      End;
  End;

PROCEDURE TLOCDraw.DrawGameButton;
  Var Index : TGameButtonCount;
  Begin
    With MyScreen,MyWorld,MyUnits do
      Begin
        For Index:=Low(TGameButtonCount) to High(TGameButtonCount) do
          With GameButtons[Index] do
            If Used then
              Case Typer of
                ButtonMenu :
                  Begin
                    DrawGameMenuButton(GameButtons[Index]);
                  End;
                ButtonUnitSelected :
                  Begin
                    DrawUnitSelectButton(GameButtons[Index]);
                  End;
                ButtonUnitCommand :
                  Begin
                    DrawGameCommandButton(GameButtons[Index]);
                  End;
                ButtonUnitItem :
                  Begin
                    DrawUnitItemButton(GameButtons[Index]);
                  End;
                ButtonUnitQueue :
                  Begin
                    DrawUnitQueueButton(GameButtons[Index]);
                  End;
                ButtonEditorCommand :
                  Begin
                    DrawEditorCommandButton(GameButtons[Index]);
                  End;
              End;
      End;
  End;

PROCEDURE TLOCDraw.DrawGameMenuButton(Button : TGameButton);
  Begin
    With MyScreen,MyWorld,MyUnits,Button do
      Begin
        If Pressed then
          Begin
            Screen.Bar(PosX1,PosY1,PosX2,PosY2,SeaBlue,EffectNone);
            Screen.Rect(PosX1,PosY1,PosX2,PosY2,White,EffectNone);
            StrDraw(PosX1+(PosX2-PosX1-Length(Caption)*Font.Width) div 2,
                    PosY1+(PosY2-PosY1-Font.Height) div 2,White,Caption);
          End
        Else
          Begin
            Screen.Bar(PosX1,PosY1,PosX2,PosY2,0,EffectNone);
            Screen.Rect(PosX1,PosY1,PosX2,PosY2,White,EffectNone);
            StrDraw(PosX1+(PosX2-PosX1-Length(Caption)*Font.Width) div 2,
                    PosY1+(PosY2-PosY1-Font.Height) div 2,White,Caption);
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawGameCommandButton(Button : TGameButton);
  Var X1,Y1,X2,Y2 : Integer;
  Begin
    With MyScreen,MyWorld,MyUnits,Button do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(PosX1,PosY1,PosX2,PosY2);
        {$EndIf}
        If Not Pressed then
          Begin
            X1:=PosX1;
            Y1:=PosY1;
            X2:=PosX2;
            Y2:=PosY2;
          End
        Else
          Begin
            X1:=PosX1+ButtonReduceSize;
            Y1:=PosY1+ButtonReduceSize;
            X2:=PosX2-ButtonReduceSize;
            Y2:=PosY2-ButtonReduceSize;
          End;
        Case UnitSkill.Skill of
          CmdBuild :
            Begin
              With UnitIcons do
                Begin
                  //If UnitHaveMask then
                    Begin
                      {$IfDef SafeLockAndUnLockTexture}
                      Images.Lock(IconNum[UnitSkill.UnitToBorn],Images.Ptr[IconNum[UnitSkill.UnitToBorn]]);
                      {$EndIf}
                      PasterSprite(Sprites[UnitSkill.UnitToBorn].Data,
                                   Images.Ptr[IconNum[UnitSkill.UnitToBorn]].pBits,
                                   Sprites[UnitSkill.UnitToBorn].DataSize div 2,0,
                                   @PalSwitch[HumanControl]);
                      {$IfDef SafeLockAndUnLockTexture}
                      Images.UnLock(IconNum[UnitSkill.UnitToBorn]);
                      {$EndIf}
                    End;
                  If Not Active then
                    Begin
                      Screen.RenderEffectCol(Images,X1,Y1,X2,Y2,ButtonInActiveColor,
                                             IconNum[UnitSkill.UnitToBorn],EffectNone);
                    End
                  Else
                    Begin
                      Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                          IconNum[UnitSkill.UnitToBorn],EffectNone);
                    End;
                End;
            End;
          CmdCastSpell :
            Begin
              With SpellIcons do
                Begin
                  If Not Active then
                    Begin
                      Screen.RenderEffectCol(Images,X1,Y1,X2,Y2,ButtonInActiveColor,
                                             IconNum[UnitSkill.SpellToCast],EffectNone);
                    End
                  Else
                    Begin
                      Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                          IconNum[UnitSkill.SpellToCast],EffectNone);
                    End;
                End;
            End;
          Else
            Begin
              With SkillIcons do
                Begin
                  {PasterSprite(Sprites[UnitSkill.Skill].Data,
                               Images.Ptr[IconNum[UnitSkill.Skill]].pBits,
                               Sprites[UnitSkill.Skill].DataSize div 2,0,
                               @PalSwitch[HumanControl]);}
                  If Not Active then
                    Begin
                      Screen.RenderEffectCol(Images,X1,Y1,X2,Y2,ButtonInActiveColor,
                                             IconNum[UnitSkill.Skill],EffectNone);
                    End
                  Else
                    Begin
                      Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                          IconNum[UnitSkill.Skill],EffectNone);
                    End;
                End;
            End;
        End;
      End;
  End;
  
PROCEDURE TLOCDraw.DrawUnitButton(UnitNum : FastInt;ButtonNum : FastInt);
  Var Percent : FastInt;
  Begin
    With MyScreen,MyWorld,MyUnits,Units[UnitNum] do
      Begin
        //Set clipping
        {$IfDef FullClip}
        Screen.SetClipRect(SelectionPosX1+UnitButtonPos[ButtonNum].X*SelectionButtonSizeX,
                           SelectionPosY1+UnitButtonPos[ButtonNum].Y*SelectionButtonSizeY,
                           SelectionPosX1+(UnitButtonPos[ButtonNum].X+1)*SelectionButtonSizeX,
                           SelectionPosY1+(UnitButtonPos[ButtonNum].Y+1)*SelectionButtonSizeY);
        {$EndIf}
        //Draw unit icon
        //Unsolve
        {UnitIcons.Images.ClipCopy(UnitIcons.IconNum[Units[UnitNum]._UnitTyper],Screen,
                                  SelectionPosX1+UnitButtonPos[ButtonNum].X*SelectionButtonSizeX,
                                  SelectionPosY1+UnitButtonPos[ButtonNum].Y*SelectionButtonSizeY);}
        //Draw unit health bar
        If Not (UnitInvulnerable in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) then
          Begin
            Percent:=Round((_UnitHitPoint/UnitsProperty[_UnitClan,_UnitTyper].HitPoint)*SelectionButtonSizeX);
            Screen.Bar(SelectionPosX1+UnitButtonPos[ButtonNum].X*SelectionButtonSizeX,
                       SelectionPosY1+(UnitButtonPos[ButtonNum].Y+1)*SelectionButtonSizeY-HealthBarHeight,
                       SelectionPosX1+(UnitButtonPos[ButtonNum].X+1)*SelectionButtonSizeX,
                       SelectionPosY1+(UnitButtonPos[ButtonNum].Y+1)*SelectionButtonSizeY,Red,EffectNone);
            Screen.Bar(SelectionPosX1+UnitButtonPos[ButtonNum].X*SelectionButtonSizeX,
                       SelectionPosY1+(UnitButtonPos[ButtonNum].Y+1)*SelectionButtonSizeY-HealthBarHeight,
                       SelectionPosX1+UnitButtonPos[ButtonNum].X*SelectionButtonSizeX+Percent,
                       SelectionPosY1+(UnitButtonPos[ButtonNum].Y+1)*SelectionButtonSizeY,DarkGreen,EffectNone);
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawUnitInfo(UnitNum : FastInt);
  Begin
    With MyScreen,MyWorld,MyUnits,Units[UnitNum] do
      Begin
        StrDraw(SelectionPosX1+NamePosX,SelectionPosY1+NamePosY,White,_UnitName);
      End;
  End;

PROCEDURE TLOCDraw.DrawUnitSelectButton(Button : TGameButton);
  Var X1,Y1,X2,Y2,Percent : Integer;
  Begin
    With MyScreen,MyWorld,MyUnits,Button,Units[UnitNumRef] do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(PosX1,PosY1,PosX2,PosY2);
        {$EndIf}
        If Not Pressed then
          Begin
            X1:=PosX1;
            Y1:=PosY1;
            X2:=PosX2;
            Y2:=PosY2;
          End
        Else
          Begin
            X1:=PosX1+ButtonReduceSize;
            Y1:=PosY1+ButtonReduceSize;
            X2:=PosX2-ButtonReduceSize;
            Y2:=PosY2-ButtonReduceSize;
          End;
        With UnitIcons do
          Begin
            //If UnitHaveMask then
              Begin
                {$IfDef SafeLockAndUnLockTexture}
                Images.Lock(IconNum[_UnitTyper],Images.Ptr[IconNum[_UnitTyper]]);
                {$EndIf}
                PasterSprite(Sprites[_UnitTyper].Data,
                             Images.Ptr[IconNum[_UnitTyper]].PBits,
                             Sprites[_UnitTyper].DataSize div 2,0,
                             @PalSwitch[_UnitColor]);
                {$IfDef SafeLockAndUnLockTexture}
                Images.UnLock(IconNum[_UnitTyper]);
                {$EndIf}
              End;
            If Active then
              Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                  IconNum[_UnitTyper],EffectNone)
            Else
              Screen.RenderEffectCol(Images,X1,Y1,X2,Y2,ButtonInActiveColor,
                                     IconNum[_UnitTyper],EffectNone);
            If UnitFocus=UnitNumRef then
              Begin
                Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                    IconNum[_UnitTyper],EffectAdd);
              End;
          End;
        {If _UnitCmd=CmdStartBuild then
          Begin
            //Draw unit time build complete
            Percent:=Round((UnitWait/UnitsProperty[_UnitClan,_UnitTyper].UnitTimeCost)*(PosX2-PosX1));
            Screen.Bar(PosX1,PosY2-HealthBarHeight,PosX1,PosY2,Red,EffectNone);
            Screen.Bar(PosX1+Percent,PosY2-HealthBarHeight,PosX1,PosY2,DarkGreen,EffectNone);
          End
        Else}
        If Not (UnitInvulnerable in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) then
          Begin
            //Draw unit health bar
            Percent:=Round((_UnitHitPoint/UnitsProperty[_UnitClan,_UnitTyper].HitPoint)*(PosX2-PosX1));
            Screen.Bar(PosX1,PosY2-HealthBarHeight,PosX1,PosY2,Red,EffectNone);
            Screen.Bar(PosX1+Percent,PosY2-HealthBarHeight,PosX1,PosY2,DarkGreen,EffectNone);
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawUnitQueueButton(Button : TGameButton);
  Var X1,Y1,X2,Y2,Percent : Integer;
  Begin
    With MyScreen,MyWorld,MyUnits,Button,Units[UnitNumRef] do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(PosX1,PosY1,PosX2,PosY2);
        {$EndIf}
        If Not Pressed then
          Begin
            X1:=PosX1;
            Y1:=PosY1;
            X2:=PosX2;
            Y2:=PosY2;
          End
        Else
          Begin
            X1:=PosX1+ButtonReduceSize;
            Y1:=PosY1+ButtonReduceSize;
            X2:=PosX2-ButtonReduceSize;
            Y2:=PosY2-ButtonReduceSize;
          End;
        With UnitIcons do
          Begin
            //If UnitHaveMask then
              Begin
                {$IfDef SafeLockAndUnLockTexture}
                Images.Lock(IconNum[_UnitTyper],Images.Ptr[IconNum[_UnitTyper]]);
                {$EndIf}
                PasterSprite(Sprites[_UnitTyper].Data,
                             Images.Ptr[IconNum[_UnitTyper]].PBits,
                             Sprites[_UnitTyper].DataSize div 2,0,
                             @PalSwitch[_UnitColor]);
                {$IfDef SafeLockAndUnLockTexture}
                Images.UnLock(IconNum[_UnitTyper]);
                {$EndIf}
              End;
            If Active then
              Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                  IconNum[_UnitTyper],EffectNone)
            Else
              Screen.RenderEffectCol(Images,X1,Y1,X2,Y2,ButtonInActiveColor,
                                     IconNum[_UnitTyper],EffectNone);
            Screen.RenderBuffer;
          End;
        //Draw unit health bar
        If Not (UnitInvulnerable in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) then
          Begin
            Percent:=Round((_UnitHitPoint/UnitsProperty[_UnitClan,_UnitTyper].HitPoint)*(PosX2-PosX1));
            Screen.Bar(PosX1,PosY2-HealthBarHeight,PosX1,PosY2,Red,EffectNone);
            Screen.Bar(PosX1+Percent,PosY2-HealthBarHeight,PosX1,PosY2,DarkGreen,EffectNone);
          End;
        Case _UnitCmd of
          CmdStartBuild :
            Begin
            End;
          //Unit while mining gold
          CmdMining :
            Begin
              Percent:=Round((_UnitWait/UnitMiningTimeDefault)*(PosX2-PosX1));
              Screen.Bar(PosX1,PosY2-HealthBarHeight*2,PosX1,PosY2-HealthBarHeight,Red,EffectNone);
              Screen.Bar(PosX1+Percent,PosY2-HealthBarHeight*2,PosX1,PosY2-HealthBarHeight,DarkGreen,EffectNone);
            End;
        End;
      End;
  End;

PROCEDURE TLOCDraw.DrawUnitItemButton(Button : TGameButton);
  Var X1,Y1,X2,Y2 : Integer;
  Begin
    With MyScreen,MyWorld,MyUnits,Button do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(PosX1,PosY1,PosX2,PosY2);
        {$EndIf}
        If (Not Pressed) or
           (UnitItem.Typer=ItemNone) then
          Begin
            X1:=PosX1;
            Y1:=PosY1;
            X2:=PosX2;
            Y2:=PosY2;
          End
        Else
          Begin
            X1:=PosX1+ButtonReduceSize;
            Y1:=PosY1+ButtonReduceSize;
            X2:=PosX2-ButtonReduceSize;
            Y2:=PosY2-ButtonReduceSize;
          End;
        If UnitItem.Typer<>ItemNone then
          Begin
            With ItemIcons do
              Begin
                If Active then
                  Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                      IconNum[UnitItem.Typer],EffectNone)
                Else
                  Screen.RenderEffectCol(Images,X1,Y1,X2,Y2,ButtonInActiveColor,
                                         IconNum[UnitItem.Typer],EffectNone);
                Screen.RenderBuffer;
              End;
          End
        Else
          Begin
            Screen.Rect(X1,Y1,X2,Y2,$FFFFFF,EffectNone);
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawEditorCommandButton(Button : TGameButton);
  Var X,Y,X1,Y1,X2,Y2 : Integer;
  Begin
    With MyScreen,MyWorld,MyUnits,MyEditor,Button do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(PosX1,PosY1,PosX2,PosY2);
        {$EndIf}
        If (Not Pressed) then
          Begin
            X1:=PosX1;
            Y1:=PosY1;
            X2:=PosX2;
            Y2:=PosY2;
          End
        Else
          Begin
            X1:=PosX1+ButtonReduceSize;
            Y1:=PosY1+ButtonReduceSize;
            X2:=PosX2-ButtonReduceSize;
            Y2:=PosY2-ButtonReduceSize;
          End;
        Case EditorCommand of
          ECNextUnit,ECPrevUnit,
          ECPlaceUnit,ECRemoveUnit,
          ECNextClan,ECPrevClan,
          ECSmallTerrain,ECNormalTerrain,ECHugeTerrain,
          ECNextTerrain,ECPrevTerrain :
            Begin
              Screen.Rect(X1,Y1,X2,Y2,$FFFFFF,EffectNone);
            End;
          ECSelectUnit :
            Begin
              With UnitIcons do
                Begin
                  //If UnitHaveMask then
                    Begin
                      {$IfDef SafeLockAndUnLockTexture}
                      Images.Lock(IconNum[CurrentEditorUnit],Images.Ptr[IconNum[CurrentEditorUnit]]);
                      {$EndIf}
                      PasterSprite(Sprites[CurrentEditorUnit].Data,
                                   Images.Ptr[IconNum[CurrentEditorUnit]].PBits,
                                   Sprites[CurrentEditorUnit].DataSize div 2,0,
                                   @PalSwitch[CurrentEditorClan]);
                      {$IfDef SafeLockAndUnLockTexture}
                      Images.UnLock(IconNum[CurrentEditorUnit]);
                      {$EndIf}
                    End;
                  If Active then
                    Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                        IconNum[CurrentEditorUnit],EffectNone)
                  Else
                    Screen.RenderEffectCol(Images,X1,Y1,X2,Y2,ButtonInActiveColor,
                                           IconNum[CurrentEditorUnit],EffectNone);
                  Screen.RenderBuffer;
                End;
            End;
          ECSelectClan :
            Begin
              Screen.FillRect(X1,Y1,X2,Y2,ClansColor32[CurrentEditorClan],EffectNone);
              Screen.Rect(X1,Y1,X2,Y2,White,EffectNone);
            End;
          ECSelectTerrain :
            Begin
              With TerrainImages do
                Screen.RenderEffect(Images,X1,Y1,X2,Y2,
                                    FramePos[CurrentEditorTerrain],EffectNone);
              Screen.RenderBuffer;
            End;
        End;
        If Caption<>'' then
          Begin
            X:=X1+(X2-X1-Font.Width*Length(Caption)) div 2;
            Y:=Y1+(Y2-Y1-Font.Height) div 2;
            Font.TextOut(X,Y,Caption,White);
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawResourceButton;
  Begin
    With MyScreen,MyWorld,MyUnits do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(ResourcePosX,ResourcePosY,Screen.XMax,ResourcePosY+20);
        {$EndIf}
        StrDraw(ResourcePosX,ResourcePosY,White,
                Format('%s: %d %s: %d %s: %d Unit: %d/%d Time: %d:%d',
                [ResourceName[ResGold],
                 ClanInfo[HumanControl].Resource[ResGold],
                 ResourceName[ResTree],
                 ClanInfo[HumanControl].Resource[ResTree],
                 ResourceName[ResSpirit],
                 ClanInfo[HumanControl].Resource[ResSpirit],
                 ClanInfo[HumanControl].FoodUsed,
                 ClanInfo[HumanControl].FoodLimit,
                 Hour,Minute]));
      End;
  End;

PROCEDURE TLOCDraw.DrawWeaponButton;
  Begin
    With MyScreen,MyWorld,MyUnits do
      Begin
      End;
  End;

PROCEDURE TLOCDraw.DrawItemButton;
  Begin
    With MyScreen,MyWorld,MyUnits do
      Begin
      End;
  End;

PROCEDURE TLOCDraw.DrawToolTips(X,Y : Integer;Text : Array of String);
  Var Width,Height,Z,Count,Max : Integer;
      Sub,Sub2                 : String;
      {$IfDef ToolTipFade}
      Color                    : LongWord;
      {$EndIf}
  Begin
    With MyScreen do
      Begin
        Max:=0;Count:=0;
        //Get count of message and max length of message
        For Z:=Low(Text) to High(Text) do
          Begin
            Sub:=Text[Z];
            While Sub<>'' do
              Begin
                If System.Pos('#',Sub)>0 then
                  Begin
                    Sub2:=Copy(Sub,1,System.Pos('#',Sub)-1);
                    Delete(Sub,1,System.Pos('#',Sub));
                  End
                Else
                  Begin
                    Sub2:=Sub;
                    Sub:='';
                  End;
                If Sub2<>'' then
                  Begin
                    If Length(Sub2)>Max then Max:=Length(Sub2);
                    Inc(Count);
                  End;
              End;
          End;
        Width:=Max*Font.Width+8;
        Height:=Count*Font.Height+10;
        {$IfDef ToolTipFade}
        If ToolTipFade<ToolTipFadeEnd then Inc(ToolTipFade,ToolTipFadeSpeed)
        Else ToolTipFade:=ToolTipFadeEnd;
        Color:=ToolTipFade ShL 16+ToolTipFade ShL 8+ToolTipFade;
        Screen.FillRect(X,Y,Width,Height,Color,EffectInvSrcColor);
        Screen.FrameRect(X,Y,Width,Height,Color,EffectAdd);
        {$Else}
        Screen.FillRect(X,Y,Width,Height,$808080,EffectInvSrcColor);
        Screen.FrameRect(X,Y,Width,Height,$808080,EffectAdd);
        {$EndIf}
        Count:=0;
        //Show message
        For Z:=Low(Text) to High(Text) do
          Begin
            Sub:=Text[Z];
            While Sub<>'' do
              Begin
                If System.Pos('#',Sub)>0 then
                  Begin
                    Sub2:=Copy(Sub,1,System.Pos('#',Sub)-1);
                    Delete(Sub,1,System.Pos('#',Sub));
                  End
                Else
                  Begin
                    Sub2:=Sub;
                    Sub:='';
                  End;
                If Sub2<>'' then
                  Begin
                    //StrDraw(X+4,Y+Count*Font.Height+5,(ToolTipFade ShR 24) or White,Sub2);
                    {$IfDef ToolTipFade}
                    StrDraw(X+4,Y+Count*Font.Height+5,Color+$707070,Sub2,EffectSrcAlpha);
                    {$Else}
                    StrDraw(X+4,Y+Count*Font.Height+5,White,Sub2,EffectSrcAlpha);
                    {$EndIf}
                    Inc(Count);
                  End;
              End;
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawButton;
  Begin
    With MyScreen,MyWorld,MyUnits do
      Begin
        {$IfDef FullClip}
        Screen.SetClipRect(0,0,ScreenWidth,ScreenHeight);
        {$EndIf}
        //Draw game button : grouped all button here ,ha ha  :/
        DrawGameButton;
        DrawResourceButton;
      End;
  End;

PROCEDURE TLOCDraw.DrawButtonToolTips;
  Var CostStr   : String;
      ResIdx    : TResource;
  Begin
    With MyScreen,MyWorld,MyUnits do
      Begin
        If Not MouseInButton then Exit;
        Case MouseIn of
          MIGameButton :
            Begin
              With GameButtons[ButtonInRange] do
                Case Typer of
                  ButtonMenu :
                    Begin
                      Case MenuTyper of
                        GameButtonMenu :
                          Begin
                          End;
                        GameButtonPause :
                          Begin
                          End;
                        GameButtonDiplomacy :
                          Begin
                          End;
                      End;
                    End;
                  ButtonUnitSelected :
                    Begin
                      If UpDateToolTip then
                        With Units[UnitNumRef] do
                          Begin
                            UpDateToolTip:=False;
                            CostStr:='';
                            Case _UnitCmd of
                              CmdStartBuild :
                                Begin
                                  CostStr:='Building '+
                                           Format('%d%% complete',[Round(_UnitHitPoint/UnitsProperty[_UnitClan,_UnitTyper].HitPoint*100)]);
                                End
                              Else;
                                Begin
                                  If Not (UnitInvulnerable in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) and
                                     (_UnitHitPoint>0) then
                                    CostStr:=CostStr+'#'+Format('HitPoint: %d',[_UnitHitPoint]);
                                  If RealUnitAttackDamage(UnitNumRef)>0 then
                                    CostStr:=CostStr+'#'+Format('Damage: %d',[RealUnitAttackDamage(UnitNumRef)]);
                                  If _UnitMana>0 then
                                    CostStr:=CostStr+'#'+Format('Mana: %d',[_UnitMana]);
                                  If _UnitXP>0 then
                                    CostStr:=CostStr+'#'+Format('XP: %d',[_UnitXP]);
                                  If _UnitTyper=GoldMine then
                                  //Unit only have gold amound ?
                                    Begin
                                      CostStr:=CostStr+'#'+Format('Gold amound: %d',[_UnitResource._GoldAmound]);
                                    End
                                  Else
                                    Begin
                                      For ResIdx:=Low(TResource) to High(TResource) do
                                        If _UnitResource._NormalRes[ResIdx]>0 then
                                          CostStr:=CostStr+'#'+Format('%d',[_UnitResource._NormalRes[ResIdx]]);
                                    End;
                                End;
                            End;
                            ToolTip:=Format('%s',[_UnitName])+'#'+CostStr;
                          End;
                      DrawToolTips(ViewPosXOS+ToolTipShiftX,SelectionPosY1,[ToolTip]);
                    End;
                  ButtonUnitCommand :
                    Begin
                      If UpDateToolTip then
                        Begin
                          Case UnitSkill.Skill of
                            CmdBuild :
                              Begin
                                CostStr:='';
                                If UnitsProperty[HumanControl,UnitSkill.UnitToBorn].FoodUsed>0 then
                                  CostStr:=' '+Format('%d',[UnitsProperty[HumanControl,UnitSkill.UnitToBorn].FoodUsed])+' Food';
                                For ResIdx:=Low(TResource) to High(TResource) do
                                  If UnitsProperty[HumanControl,UnitSkill.UnitToBorn].UnitCost[ResIdx]>0 then
                                    CostStr:=CostStr+' '+Format('%d',[UnitsProperty[HumanControl,UnitSkill.UnitToBorn].UnitCost[ResIdx]])+' '+ResourceName[ResIdx];
                                ToolTip:=Format('%s',[UnitsProperty[HumanControl,UnitSkill.UnitToBorn].Name])+'#'+CostStr;
                                If UnitsProperty[HumanControl,UnitSkill.UnitToBorn].HotKey<>0 then
                                  ToolTip:=ToolTip+'#Hotkey '+HotKeyName(0,UnitsProperty[HumanControl,UnitSkill.UnitToBorn].HotKey);
                              End;
                            CmdCastSpell :
                              Begin
                                CostStr:='';
                                For ResIdx:=Low(TResource) to High(TResource) do
                                  If SpellProperty[UnitSkill.SpellToCast].ResourceCost[ResIdx]>0 then
                                    CostStr:=CostStr+' '+Format('%d',[SpellProperty[UnitSkill.SpellToCast].ResourceCost[ResIdx]])+' '+ResourceName[ResIdx];
                                ToolTip:=SpellProperty[UnitSkill.SpellToCast].ToolTip+'#'+CostStr;
                                If SpellProperty[UnitSkill.SpellToCast].SpellHotkey<>0 then
                                  ToolTip:=ToolTip+'#Hotkey '+HotKeyName(0,SpellProperty[UnitSkill.SpellToCast].SpellHotkey);
                              End;
                            Else
                              Begin
                                ToolTip:=SkillProperty[UnitSkill.Skill].ToolTip;
                                If SkillProperty[UnitSkill.Skill].SkillHotkey<>0 then
                                  ToolTip:=ToolTip+'#Hotkey '+HotKeyName(0,SkillProperty[UnitSkill.Skill].SkillHotkey);
                              End;
                          End;
                          UpDateToolTip:=False;
                        End;
                      DrawToolTips(ViewPosXOS+ToolTipShiftX,SkillPosY,[ToolTip]);
                    End;
                  ButtonUnitItem :
                    Begin
                      If UpDateToolTip then
                        Begin
                          UpDateToolTip:=False;
                          If UnitItem.Typer<>ItemNone then
                            Begin
                              ToolTip:=ItemProperty[UnitItem.Typer].ItemName;
                              If UnitItem.Number>1 then
                                ToolTip:=Format('%d ',[UnitItem.Number])+ToolTip;
                              ToolTip:=ToolTip+'#'+ItemClassName[ItemProperty[UnitItem.Typer].ItemClass];
                            End
                          Else
                            Begin
                              //This a little code to reduce size of message string
                              //because I don't used array of string here
                              Case SlotSupport[ItemSlot] of
                                WeaponClass   : ToolTip:=MsgWeaponItemHint;
                                ArmorClass    : ToolTip:=MsgArmorItemHint;
                                ShieldClass   : ToolTip:=MsgShieldItemHint;
                                HelmClass     : ToolTip:=MsgHelmItemHint;
                                BootClass     : ToolTip:=MsgBootItemHint;
                                DecorateClass : ToolTip:=MsgDecorateItemHint;
                                OtherClass    : ToolTip:=MsgFreeItemHint;
                              End;
                            End;
                        End;
                      DrawToolTips(ViewPosXOS+ToolTipShiftX,ItemPosY,[ToolTip]);
                    End;
                  ButtonUnitQueue :
                    Begin
                      With Units[UnitNumRef] do
                        If UpDateToolTip then
                          Begin
                            Case _UnitCmd of
                              CmdStartBuild :
                                Begin
                                  ToolTip:='Unit in training '+
                                           Format('%d%% complete',[Round(_UnitHitPoint/UnitsProperty[_UnitClan,_UnitTyper].HitPoint*100)]);
                                End
                              Else
                                Begin
                                  CostStr:='';
                                  If Not (UnitInvulnerable in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) and
                                     (_UnitHitPoint>0) then
                                    CostStr:=CostStr+'#'+Format('HitPoint: %d',[_UnitHitPoint]);
                                  If RealUnitAttackDamage(UnitNumRef)>0 then
                                    CostStr:=CostStr+'#'+Format('Damage: %d',[RealUnitAttackDamage(UnitNumRef)]);
                                  If _UnitMana>0 then
                                    CostStr:=CostStr+'#'+Format('Mana: %d',[_UnitMana]);
                                  If _UnitXP>0 then
                                    CostStr:=CostStr+'#'+Format('XP: %d',[_UnitXP]);
                                  ToolTip:=Format('%s',[_UnitName])+'#'+CostStr;
                                End;
                            End;
                            UpDateToolTip:=False;
                          End;
                      DrawToolTips(ViewPosXOS+ToolTipShiftX,QueuePosY,[ToolTip]);
                    End;
                  ButtonEditorCommand :
                    Begin
                      Case EditorCommand of
                        ECNextUnit :
                          Begin
                            ToolTip:='Select next unit';
                          End;
                        ECPrevUnit :
                          Begin
                            ToolTip:='Select prev unit';
                          End;
                        ECPlaceUnit :
                          Begin
                            ToolTip:='Place unit';
                          End;
                        ECRemoveUnit :
                          Begin
                            ToolTip:='Remove unit';
                          End;
                        ECSelectClan :
                          Begin
                            ToolTip:='Current select '+DefaultClanName[MyEditor.CurrentEditorClan];
                          End;
                        ECNextClan :
                          Begin
                            ToolTip:='Select next clan';
                          End;
                        ECPrevClan :
                          Begin
                            ToolTip:='Select prev clan';
                          End;
                        ECSmallTerrain :
                          Begin
                            ToolTip:='Choisen small terrain pattern';
                          End;
                        ECNormalTerrain :
                          Begin
                            ToolTip:='Choisen normal terrain pattern';
                          End;
                        ECHugeTerrain :
                          Begin
                            ToolTip:='Choisen huge terrain pattern';
                          End;
                        ECSelectTerrain :
                          Begin
                            ToolTip:='Current select '+DefaultTileName[MyEditor.CurrentEditorTerrain];
                          End;
                        ECNextTerrain :
                          Begin
                            ToolTip:='Select next terrain type';
                          End;
                        ECPrevTerrain :
                          Begin
                            ToolTip:='Select prev terrain type';
                          End;
                        ECSelectUnit :
                          Begin
                            CostStr:='';
                            With MyEditor,UnitsProperty[CurrentEditorClan,CurrentEditorUnit] do
                              Begin
                                If Not (UnitInvulnerable in BaseAttribute) and
                                   (HitPoint>0) then
                                  CostStr:=CostStr+'#'+Format('HitPoint: %d',[HitPoint]);
                                If RealUnitAttackDamage(UnitNumRef)>0 then
                                  CostStr:=CostStr+'#'+Format('Damage: %d',[BaseDamage]);
                                If MaxMana>0 then
                                  CostStr:=CostStr+'#'+Format('Mana: %d',[MaxMana]);
                                ToolTip:=Format('%s',[Name])+'#'+CostStr;
                              End;
                          End;
                      End;
                      DrawToolTips(ViewPosXOS+ToolTipShiftX,QueuePosY,[ToolTip]);
                    End;
                End;
            End;
          MIGameMiniMap :
            Begin
            End;
        End;
      End;
  End;

PROCEDURE TLOCDraw.DrawCommandLine;
  Var Color1,Color2 : LongWord;
      Z             : FastInt;
  Begin
    With MyScreen,MyWorld do
      Begin
        //Show command line while enter ?
        If CmdLineEnter then
          Begin
            {$IfDef FullClip}
            Screen.SetClipRect(CmdLinePosX,CmdLinePosY,CmdLinePosX+CmdLineSizeX,CmdLinePosY+CmdLineSizeY);
            {$EndIf}
            Screen.FillRect(CmdLinePosX,CmdLinePosY,CmdLineSizeX,CmdLineSizeY,$808080,EffectInvSrcColor);
            Screen.FrameRect(CmdLinePosX,CmdLinePosY,CmdLineSizeX,CmdLineSizeY,$808080,EffectAdd);
            StrDraw(CmdLinePosX+8,CmdLinePosY+4,White,CommandLine);
          End;
        {$IfDef FullClip}
        Screen.SetClipRect(ViewPosXOS,ViewPosYOS,ViewPosX2OS,ViewPosY2OS);
        {$EndIf}
        If LastestMsg<>0 then
          Begin
            For Z:=1 to LastestMsg do
              Begin
                If MessageBoardData[Z].FadeStart>255 then
                  Begin
                    StrDraw(MsgBoardPosX,MsgBoardPosY-(LastestMsg-Z)*Font.Height,White,MessageBoard[Z]);
                  End
                Else
                  Begin
                    Color1:=MessageBoardData[Z].FadeStart;
                    If MessageBoardData[Z].FadeEnd>255 then Color2:=255
                    Else Color2:=MessageBoardData[Z].FadeEnd;
                    Color1:=Color1 ShL 16+Color1 ShL 8+Color1;
                    Color2:=Color2 ShL 16+Color2 ShL 8+Color2;
                    StrDraw(MsgBoardPosX,MsgBoardPosY-(LastestMsg-Z)*Font.Height,
                            Color1,Color2,MessageBoard[Z],EffectBlendColor);
                  End;
              End;
          End;
      End;
  End;

PROCEDURE TLOCDraw.DrawMouse;
  Var DX,DY,I,J,PosX,PosY,
      X1,Y1,X2,Y2 : Integer;
      X,Y,XS,YS   : FastInt;
      DrawFrame   : TUnitFrame;
      Frame2Draw  : TNumFrame;
  Begin
    With MyScreen,MyMenu,MyUnits,MyWorld do
      Begin
        If Not MenuActive then
          Begin
            {$IfDef FullClip}
            Screen.SetClipRect(ViewPosXOS,ViewPosYOS,
                               ViewPosX2OS,ViewPosY2OS);
            {$EndIf}
            If LeftMouseStatus=SSelection then
              Begin
                Case MouseSelectStyle of
                  AlphaRect :
                    Begin
                      Screen.Bar(SelectStart.X,SelectStart.Y,
                                 SelectEnd.X,SelectEnd.Y,RGBToLongWord(0,200,200),EffectNone);
                      Screen.Rect(SelectStart.X,SelectStart.Y,
                                  SelectEnd.X,SelectEnd.Y,White,EffectNone);
                    End;
                  Rect :
                    Screen.Rect(SelectStart.X,SelectStart.Y,
                                SelectEnd.X,SelectEnd.Y,White,EffectNone);
                End;
              End;
            Case CmdWaitForSelect of
              CmdBuild :
                Begin
                  If UnitWaitForBuild=NoneUnit then Exit;
                  If Not InRange(Input.MouseX,Input.MouseY,
                                 ViewPosXOS,ViewPosYOS,
                                 ViewPosX2OS,ViewPosY2OS) then Exit;
                  DrawFrame:=0;
                  PosX:=(Input.MouseX-ViewPosXOS) div DefaultMapTileX;
                  PosY:=(Input.MouseY-ViewPosYOS) div DefaultMapTileY;
                  With UnitAnimations[UnitWaitForBuild] do
                    Begin
                      DX:=ViewPosXOS+PosX*DefaultMapTileX+ShiftX;
                      DY:=ViewPosYOS+PosY*DefaultMapTileY+ShiftY;
                      Frame2Draw:=StandScript.Script[HeadWaitForBuild,DrawFrame].FrameNum;
                      If UnitHaveMask then
                        Begin
                          {$IfDef SafeLockAndUnLockTexture}
                          Images.Lock(Frame2Draw,Images.Ptr[Frame2Draw]);
                          {$EndIf}
                          PasterSprite(Sprites[Frame2Draw].Data,Images.Ptr[Frame2Draw].PBits,
                                       Sprites[Frame2Draw].DataSize div 2,MaskColor,@PalSwitch[HumanControl]);
                          {$IfDef SafeLockAndUnLockTexture}
                          Images.UnLock(Frame2Draw);
                          {$EndIf}
                        End;
                      If StandScript.Script[HeadWaitForBuild,DrawFrame].FrameStyle and FrameMirrorH=FrameMirrorH then
                        Screen.RenderEffectCol(Images,DX,DY,Shadow50PercentValue,
                                               Frame2Draw,EffectShadow+EffectMirror)
                      Else Screen.RenderEffectCol(Images,DX,DY,Shadow50PercentValue,
                                                  Frame2Draw,EffectShadow);
                      If StandScript.Script[HeadWaitForBuild,DrawFrame].FrameStyle and FrameMirrorH=FrameMirrorH then
                        Screen.RenderEffectCol(Images,DX,DY,
                                               ColorAlphaBlend,Frame2Draw,EffectBlendColor+EffectMirror)
                      Else Screen.RenderEffectCol(Images,DX,DY,
                                                  ColorAlphaBlend,Frame2Draw,EffectBlendColor);
                      For I:=0 to UnitsProperty[HumanControl,UnitWaitForBuild].UnitSizeX do
                        For J:=0 to UnitsProperty[HumanControl,UnitWaitForBuild].UnitSizeY do
                          Begin
                            //This mapped tile ?
                            If (UnitsProperty[HumanControl,UnitWaitForBuild].UnitMapped[HeadWaitForBuild,I,J] and
                                UnitMappedUsedLand=UnitMappedUsedLand) and
                               //And tile has been used by land unit ?
                               (GetTileAttr(I+PosX+MapViewX,J+PosY+MapViewY,MapUsedByLandUnit) or
                               //Or want build deposit building and tile has been used by gold mine ?
                                ((UnitIsDeposit in UnitsProperty[HumanControl,UnitWaitForBuild].BaseAttribute) and
                                 GetTileAttr(I+PosX+MapViewX,J+PosY+MapViewY,MapUsedByGoldMine))) then
                              Screen.FillRect(ViewPosXOS+(I+PosX)*DefaultMapTileX,
                                              ViewPosYOS+(J+PosY)*DefaultMapTileY,
                                              DefaultMapTileX,DefaultMapTileY,
                                              $80FF0000,EffectAdd);
                          End;
                      Screen.RenderBuffer;
                    End;
                End;
              CmdPlaceUnit :
                Begin
                  If Not InRange(Input.MouseX,Input.MouseY,
                                 ViewPosXOS,ViewPosYOS,
                                 ViewPosX2OS,ViewPosY2OS) then Exit;
                  DrawFrame:=0;
                  PosX:=(Input.MouseX-ViewPosXOS) div DefaultMapTileX;
                  PosY:=(Input.MouseY-ViewPosYOS) div DefaultMapTileY;
                  With MyEditor,UnitAnimations[CurrentEditorUnit] do
                    Begin
                      DX:=ViewPosXOS+PosX*DefaultMapTileX+ShiftX;
                      DY:=ViewPosYOS+PosY*DefaultMapTileY+ShiftY;
                      Frame2Draw:=StandScript.Script[HeadWaitForBuild,DrawFrame].FrameNum;
                      If UnitHaveMask then
                        Begin
                          {$IfDef SafeLockAndUnLockTexture}
                          Images.Lock(Frame2Draw,Images.Ptr[Frame2Draw]);
                          {$EndIf}
                          PasterSprite(Sprites[Frame2Draw].Data,Images.Ptr[Frame2Draw].PBits,
                                       Sprites[Frame2Draw].DataSize div 2,MaskColor,@PalSwitch[CurrentEditorClan]);
                          {$IfDef SafeLockAndUnLockTexture}
                          Images.UnLock(Frame2Draw);
                          {$EndIf}
                        End;
                      If StandScript.Script[HeadWaitForBuild,DrawFrame].FrameStyle and FrameMirrorH=FrameMirrorH then
                        Screen.RenderEffectCol(Images,DX,DY,Shadow50PercentValue,
                                               Frame2Draw,EffectShadow+EffectMirror)
                      Else Screen.RenderEffectCol(Images,DX,DY,Shadow50PercentValue,
                                                  Frame2Draw,EffectShadow);
                      If StandScript.Script[HeadWaitForBuild,DrawFrame].FrameStyle and FrameMirrorH=FrameMirrorH then
                        Screen.RenderEffectCol(Images,DX,DY,
                                               ColorAlphaBlend,Frame2Draw,EffectBlendColor+EffectMirror)
                      Else Screen.RenderEffectCol(Images,DX,DY,
                                                  ColorAlphaBlend,Frame2Draw,EffectBlendColor);
                      If UnitIsLandUnit in UnitsProperty[HumanControl,CurrentEditorUnit].BaseAttribute then
                        For I:=0 to UnitsProperty[HumanControl,CurrentEditorUnit].UnitSizeX do
                          For J:=0 to UnitsProperty[HumanControl,CurrentEditorUnit].UnitSizeY do
                            Begin
                              //This mapped tile ?
                              If (UnitsProperty[HumanControl,CurrentEditorUnit].UnitMapped[HeadWaitForBuild,I,J] and
                                  UnitMappedUsedLand=UnitMappedUsedLand) and
                                 //And tile has been used by land unit ?
                                 (GetTileAttr(I+PosX+MapViewX,J+PosY+MapViewY,MapUsedByLandUnit) or
                                 //Or want build deposit building and tile has been used by gold mine ?
                                  ((UnitIsDeposit in UnitsProperty[HumanControl,CurrentEditorUnit].BaseAttribute) and
                                   GetTileAttr(I+PosX+MapViewX,J+PosY+MapViewY,MapUsedByGoldMine))) then
                                Screen.FillRect(ViewPosXOS+(I+PosX)*DefaultMapTileX,
                                                ViewPosYOS+(J+PosY)*DefaultMapTileY,
                                                DefaultMapTileX,DefaultMapTileY,
                                                $80FF0000,EffectAdd);
                            End;
                      Screen.RenderBuffer;
                    End;
                End;
              CmdPutItem :
                Begin
                  With ItemIcons do
                    Screen.RenderEffect(Images,
                                        Input.MouseX,Input.MouseY,
                                        Input.MouseX+ItemButtonSizeX,
                                        Input.MouseY+ItemButtonSizeY,
                                        IconNum[ItemWaitToPut.Typer],EffectNone);
                  Screen.RenderBuffer;
                End;
              CmdPlaceSmallTerrain :
                Begin
                  GetRealMousePos(X,Y,XS,YS);
                  PosX:=(X div 2)*2-MapViewX;
                  PosY:=(Y div 2)*2-MapViewY;
                  X1:=ViewPosXOS+(PosX+1)*DefaultMapTileX;
                  Y1:=ViewPosYOS+(PosY+1)*DefaultMapTileY;
                  X2:=ViewPosXOS+(PosX+(PatternSmallSize)*2+1)*DefaultMapTileX;
                  Y2:=ViewPosYOS+(PosY+(PatternSmallSize)*2+1)*DefaultMapTileY;
                  Screen.Rect(X1,Y1,X2,Y2,$80FF0000,EffectAdd);
                End;
              CmdPlaceNormalTerrain :
                Begin
                  GetRealMousePos(X,Y,XS,YS);
                  PosX:=(X div 2)*2-MapViewX;
                  PosY:=(Y div 2)*2-MapViewY;
                  X1:=ViewPosXOS+(PosX+1)*DefaultMapTileX;
                  Y1:=ViewPosYOS+(PosY+1)*DefaultMapTileY;
                  X2:=ViewPosXOS+(PosX+(PatternNormalSize)*2+1)*DefaultMapTileX;
                  Y2:=ViewPosYOS+(PosY+(PatternNormalSize)*2+1)*DefaultMapTileY;
                  Screen.Rect(X1,Y1,X2,Y2,$80FF0000,EffectAdd);
                End;
              CmdPlaceHugeTerrain :
                Begin
                  GetRealMousePos(X,Y,XS,YS);
                  PosX:=(X div 2)*2-MapViewX;
                  PosY:=(Y div 2)*2-MapViewY;
                  X1:=ViewPosXOS+(PosX+1)*DefaultMapTileX;
                  Y1:=ViewPosYOS+(PosY+1)*DefaultMapTileY;
                  X2:=ViewPosXOS+(PosX+(PatternHugeSize)*2+1)*DefaultMapTileX;
                  Y2:=ViewPosYOS+(PosY+(PatternHugeSize)*2+1)*DefaultMapTileY;
                  Screen.Rect(X1,Y1,X2,Y2,$80FF0000,EffectAdd);
                End;
            End;
          End;
      End;
  End;
{$IfDef Debug}
PROCEDURE TLOCDraw.DrawDebug;
  Begin
    With MyScreen do
      ShowDebug(GameTime-GameTimeStart,ScreenFrame);
  End;
{$EndIf}
PROCEDURE TLOCDraw.DrawScreen;
  Begin
    //If this time equal to time rate for update screen
    With MyScreen,MyMenu do
      If GameTime-ScreenUpdateSavedTime>ScreenTimeRate then
        Begin
          Inc(ScreenFrame);
          ScreenUpdateSavedTime:=GameTime;
          Screen.Clear(0);
          Screen.BeginScene;
          DrawUserInterface;
          DrawViewMap;
          DrawViewScreen;
          DrawButton;
          DrawCommandLine;
          {$IfDef FullClip}
          Screen.SetClipRect(0,0,Screen.XMax,Screen.YMax);
          {$EndIf}
          DrawButtonToolTips;
          If MenuActive then
            MyMenu.MainMenuUpdate(False,False,False);
          DrawMouse;
          {$IfDef Debug}
          DrawDebug;
          {$EndIf}
          Screen.EndScene;
          Screen.Present;
        End;
  End;

FUNCTION  TLOCDraw.GetTileByName(Name : String) : TMapTile;
  Var Z : TMapTile;
  Begin
    For Z:=Low(TMapTile) to High(TMapTile) do
      If Name=DefaultTileName[Z] then
        Begin
          Result:=Z;
          Exit;
        End;
    Result:=Low(TMapTile);
  End;

PROCEDURE TLOCDraw.UnitAnimationLoad(UnitType : TUnit;FileName : String);
  Var ImageFileName,St   : String;
      X,Y,Z,K,BufferSize : Integer;
      _UnitTyper          : TUnit;
      Pal                : TPalSwitch;
      F                  : Text;
  Procedure LoadingScript(Var Script : TAniScript);
    Var Z : SmallInt;
        H : THeading;
    Begin
      For H:=Low(THeading) to High(THeading) do
        Begin
          ReadLn(F);//Skip [Heading #]
          ReadLn(F,Script.Leng[H]);
          {$IfDef Debug}
          Inc(UnitAnimations[UnitType].MemUsed,Script.Leng[H]*SizeOf(TAnimationScript));
          {$EndIf}
          SetLength(Script.Script[H],Script.Leng[H]);
          For Z:=0 to Script.Leng[H]-1 do
            Begin
              ReadLn(F,Script.Script[H,Z].FrameNum,
                       Script.Script[H,Z].FrameWait,
                       Script.Script[H,Z].FrameShift,
                       Script.Script[H,Z].FrameStyle);
              Script.Script[H,Z].FrameWait:=Script.Script[H,Z].FrameWait*DefaultUnitSpeedDecrease;
            End;
        End;
    End;
  Begin
    With MyScreen,UnitAnimations[UnitType] do
      Begin
        {$IfDef Debug}
        MemUsed:=0;
        {$EndIf}
        Assign(F,FileName);
        Reset(F);
        If IOResult<>0 then Exit;
        UnitHaveMask:=False;
        {Pal[01]:=RGBToWord(000,000,000) or $8000;
        Pal[02]:=RGBToWord(000,004,076) or $8000;
        Pal[03]:=RGBToWord(000,000,000) or $8000;
        Pal[04]:=RGBToWord(000,020,116) or $8000;
        Pal[05]:=RGBToWord(004,040,160) or $8000;
        Pal[06]:=RGBToWord(000,000,000) or $8000;
        Pal[07]:=RGBToWord(012,072,204) or $8000;
        Pal[08]:=RGBToWord(000,000,000) or $8000;
        Pal[09]:=RGBToWord(000,000,000) or $8000;
        Pal[10]:=RGBToWord(000,000,000) or $8000;
        Pal[11]:=RGBToWord(000,000,000) or $8000;
        Pal[12]:=RGBToWord(000,000,000) or $8000;}
        //Default palette transfered
        Pal:=DefaultPal;
        While Not EoF(F) do
          Begin
            ReadLn(F,St);
            StrippedAllSpaceAndUpCase(St);
            If (St[1]=SkipSymbol) or
               (Length(St)=0) then Continue;
            If UsingSameOtherUnitStr=St then
              Begin
                ReadLn(F,St);
                StrippedAllSpaceAndUpCase(St);
                _UnitTyper:=MyUnits.GetUnitTyperByName(St);
                UnitAnimations[UnitType]:=UnitAnimations[_UnitTyper];
              End
            Else
            If UnitHaveMaskStr=St then
              Begin
                UnitHaveMask:=True;
              End
            Else
            If UnitMaskStr=St then
              Begin
                For K:=Low(Pal) to High(Pal) do
                  Begin
                    ReadLn(F,X,Y,Z);
                    Pal[K]:=RGBToWord(X,Y,Z) or $8000;
                  End;
              End
            Else
            If ImageInfoStr=St then
              Begin
                ReadLn(F,NumOfFrame,ShiftX,ShiftY,SizeX,SizeY);
              End
            Else
            If TransparentColorStr=St then
              Begin
                ReadLn(F,X,Y,Z);
                TransparentColor:=RGBToLongWord(X,Y,Z);
                MaskColor:=RGBToWord(X,Y,Z) or $8000;
              End
            Else
            If UsingFromListFileStr=St then
              Begin
                Images:=TAvenusTextureImages.Create;
                If UnitHaveMask then
                  SetLength(Sprites,NumOfFrame);
                For Z:=0 to NumOfFrame-1 do
                  Begin
                    ReadLn(F,ImageFileName);
                    {$IfDef LoadOnDataBase}
                    If Images.LoadFromFileAlpha1Bit(GraphicDataFile,Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                    SizeX,SizeY,TransparentColor)<>0 then
                      ErrorMessage(LoadingFailedStr+ImageFileName)
                    Else Log('Loading file '+GameDataDir+ImageFileName+' from database complete');
                    {$Else}
                    If Images.LoadFromFileAlpha1Bit(Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                    SizeX,SizeY,TransparentColor)<>0 then
                      ErrorMessage(LoadingFailedStr+ImageFileName)
                    Else Log('Loading file '+GameDataDir+ImageFileName+' complete');
                    {$EndIf}
                    If UnitHaveMask then
                      Begin
                        //Make a transfer color sprite
                        BufferSize:=Images.TextureWidth[Z]*Images.TextureHeight[Z];
                        MakeRLE(Sprites[Z],Images.Ptr[Z].PBits,BufferSize,MaskColor,Pal);
                      End;
                  End;
              End
            Else//Reading images frame from file
            If UsingFromFileStr=St then
              Begin
                ReadLn(F,ImageFileName);
                Images:=TAvenusTextureImages.Create;
                {$IfDef LoadOnDataBase}
                If Images.LoadFromFileAlpha1Bit(GraphicDataFile,Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                SizeX,SizeY,TransparentColor)<>0 then
                  ErrorMessage(LoadingFailedStr+ImageFileName)
                Else Log('Loading file '+GameDataDir+ImageFileName+' from database complete');
                {$Else}
                If Images.LoadFromFileAlpha1Bit(Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                SizeX,SizeY,TransparentColor)<>0 then
                  ErrorMessage(LoadingFailedStr+ImageFileName)
                Else Log('Loading file '+GameDataDir+ImageFileName+' complete');
                {$EndIf}
                NumOfFrame:=Images.CountTextures;
                If UnitHaveMask then
                  Begin
                    SetLength(Sprites,NumOfFrame);
                    //Make a transfer color sprite
                    For K:=0 to NumOfFrame-1 do
                      Begin
                        BufferSize:=Images.TextureWidth[K]*Images.TextureHeight[K];
                        MakeRLE(Sprites[K],Images.Ptr[K].PBits,BufferSize,MaskColor,Pal);
                      End;
                  End;
              End
            Else
            If St=StandScriptStr     then LoadingScript(StandScript) Else
            If St=Stand1ScriptStr    then LoadingScript(StandScript1) Else
            If St=Stand2ScriptStr    then LoadingScript(StandScript2) Else
            If St=WastedScriptStr    then LoadingScript(WastedScript) Else
            If St=CastSpellScriptStr then LoadingScript(CastSpellScript) Else
            If St=RunScriptStr       then LoadingScript(RunScript) Else
            If St=AttackScriptStr    then LoadingScript(AttackScript) Else
            If St=Attack2ScriptStr   then LoadingScript(Attack2Script) Else
            If St=DeadScriptStr      then LoadingScript(DeadScript);
          End;
        Close(F);
        {$IfDef Debug}
        Inc(AniScriptMemUsed,MemUsed);
        {$EndIf}
      End;
  End;

PROCEDURE TLOCDraw.UnitIconLoad(FileName : String);
  Var St,Sub           : String;
      BufferSize,Count : Integer;
      _UnitTyper        : TUnit;
      Pal              : TPalSwitch;
      F                : Text;
  Begin
    With MyScreen,UnitIcons do
      Begin
        For _UnitTyper:=Low(TUnit) to High(TUnit) do
          Begin
            IconNum[_UnitTyper]:=0;
            Sprites[_UnitTyper].DataSize:=0;
            Sprites[_UnitTyper].Data:=Nil;
          End;
        Assign(F,FileName);
        Reset(F);
        Images:=TAvenusTextureImages.Create;
        Pal:=DefaultPal;
        While Not EoF(F) do
          Begin
            ReadLn(F,St);
            If St[1]=SkipSymbol then Continue;
            _UnitTyper:=Low(TUnit);
            While St<>'' do
              Begin
                Sub:=GetFirstComment(St);
                StrippedAllSpaceAndUpCase(Sub);
                If Sub=UnitNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    _UnitTyper:=MyUnits.GetUnitTyperByName(Sub);
                  End
                Else
                If Sub=FileNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    //StrippedAllSpaceAndUpCase(Sub);
                    {$IfDef LoadOnDataBase}
                    If Images.LoadFromPackFile(GraphicDataFile,Screen.D3DDevice8,GameDataDir+Sub,
                                               0,0,D3DFMT_A1R5G5B5,IconNum[_UnitTyper],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' from database complete');
                    {$Else}
                    If Images.LoadFromFile(Screen.D3DDevice8,GameDataDir+Sub,
                                           0,0,D3DFMT_A1R5G5B5,IconNum[_UnitTyper],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' complete');
                    {$EndIf}
                    Images.Set1BitAlpha(IconNum[_UnitTyper],0);
                    BufferSize:=Images.TextureWidth[IconNum[_UnitTyper]]*
                                Images.TextureHeight[IconNum[_UnitTyper]];
                    MakeRLE(Sprites[_UnitTyper],Images.Ptr[IconNum[_UnitTyper]].PBits,BufferSize,0,Pal);
                  End
                Else
                If Sub=AtStr then
                  Begin
                    //Not support
                    {Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,X,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,Y,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,SizeX,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,SizeY,Code);
                    IconNum[_UnitTyper]:=Images.CreateNewSprite(SizeX,SizeY);
                    Images.Get(IconNum[_UnitTyper],ImageTemp,X,Y);}
                  End;
              End;
          End;
        Close(F);
      End;
  End;

PROCEDURE TLOCDraw.SkillIconLoad(FileName : String);
  Var St,Sub           : String;
      {BufferSize,}Count : Integer;
      Skill            : TSkill;
      F                : Text;
  Begin
    With MyScreen,SkillIcons do
      Begin
        FillChar(IconNum,SizeOf(IconNum),0);
        Assign(F,FileName);
        Reset(F);
        Images:=TAvenusTextureImages.Create;
        While Not EoF(F) do
          Begin
            ReadLn(F,St);
            If St[1]=SkipSymbol then Continue;
            Skill:=Low(TSkill);
            While St<>'' do
              Begin
                Sub:=GetFirstComment(St);
                StrippedAllSpaceAndUpCase(Sub);
                If Sub=SkillNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Skill:=MyUnits.GetSkillByName(Sub);
                  End
                Else
                If Sub=FileNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    //StrippedAllSpaceAndUpCase(Sub);
                    {$IfDef LoadOnDataBase}
                    If Images.LoadFromPackFile(GraphicDataFile,Screen.D3DDevice8,GameDataDir+Sub,
                                            0,0,D3DFMT_A1R5G5B5,IconNum[Skill],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' from database complete');
                    {$Else}
                    If Images.LoadFromFile(Screen.D3DDevice8,GameDataDir+Sub,
                                           0,0,D3DFMT_A1R5G5B5,IconNum[Skill],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' complete');
                    {$EndIf}
                    {BufferSize:=Images.TextureWidth[IconNum[Skill]]*
                                Images.TextureHeight[IconNum[Skill]];
                    MakeRLE(Sprites[Skill],Images.Ptr[IconNum[Skill]].PBits,BufferSize,0);}
                  End
                Else
                If Sub=AtStr then
                  Begin
                    //Not support load from clip of image
                    {Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,X,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,Y,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,SizeX,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,SizeY,Code);
                    IconNum[Skill]:=Images.CreateNewSprite(SizeX,SizeY);
                    Images.Get(IconNum[Skill],ImageTemp,X,Y);}
                  End;
              End;
          End;
        Close(F);
      End;
  End;

PROCEDURE TLOCDraw.SpellIconLoad(FileName : String);
  Var St,Sub           : String;
      {BufferSize,}Count : Integer;
      Spell            : TSpell;
      F                : Text;
  Begin
    With MyScreen,SpellIcons do
      Begin
        FillChar(IconNum,SizeOf(IconNum),0);
        Assign(F,FileName);
        Reset(F);
        Images:=TAvenusTextureImages.Create;
        While Not EoF(F) do
          Begin
            ReadLn(F,St);
            If St[1]=SkipSymbol then Continue;
            Spell:=Low(TSpell);
            While St<>'' do
              Begin
                Sub:=GetFirstComment(St);
                StrippedAllSpaceAndUpCase(Sub);
                If Sub=SpellNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Spell:=MyUnits.GetSpellByName(Sub);
                  End
                Else
                If Sub=FileNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    //StrippedAllSpaceAndUpCase(Sub);
                    {$IfDef LoadOnDataBase}
                    If Images.LoadFromPackFile(GraphicDataFile,Screen.D3DDevice8,GameDataDir+Sub,
                                               0,0,D3DFMT_A1R5G5B5,IconNum[Spell],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' from database complete');
                    {$Else}
                    If Images.LoadFromFile(Screen.D3DDevice8,GameDataDir+Sub,
                                           0,0,D3DFMT_A1R5G5B5,IconNum[Spell],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' complete');
                    {$EndIf}
                    {BufferSize:=Images.TextureWidth[IconNum[Skill]]*
                                Images.TextureHeight[IconNum[Skill]];
                    MakeRLE(Sprites[Skill],Images.Ptr[IconNum[Skill]].PBits,BufferSize,0);}
                  End
                Else
                If Sub=AtStr then
                  Begin
                    //Not support load from clip of image
                    {Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,X,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,Y,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,SizeX,Code);
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Val(Sub,SizeY,Code);
                    IconNum[Skill]:=Images.CreateNewSprite(SizeX,SizeY);
                    Images.Get(IconNum[Skill],ImageTemp,X,Y);}
                  End;
              End;
          End;
        Close(F);
      End;
  End;

PROCEDURE TLOCDraw.ItemIconLoad(FileName : String);
  Var St,Sub : String;
      Count  : Integer;
      Item   : TItem;
      F      : Text;
  Begin
    With MyScreen,ItemIcons do
      Begin
        FillChar(IconNum,SizeOf(IconNum),0);
        Assign(F,FileName);
        Reset(F);
        Images:=TAvenusTextureImages.Create;
        While Not EoF(F) do
          Begin
            ReadLn(F,St);
            If St[1]=SkipSymbol then Continue;
            Item:=Low(TItem);
            While St<>'' do
              Begin
                Sub:=GetFirstComment(St);
                StrippedAllSpaceAndUpCase(Sub);
                If Sub=ItemsNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Item:=MyUnits.GetItemByName(Sub);
                  End
                Else
                If Sub=FileNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    //StrippedAllSpaceAndUpCase(Sub);
                    {$IfDef LoadOnDataBase}
                    If Images.LoadFromPackFile(GraphicDataFile,Screen.D3DDevice8,GameDataDir+Sub,
                                               0,0,D3DFMT_A1R5G5B5,IconNum[Item],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' from database complete');
                    {$Else}
                    If Images.LoadFromFile(Screen.D3DDevice8,GameDataDir+Sub,
                                           0,0,D3DFMT_A1R5G5B5,IconNum[Item],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' complete');
                    {$EndIf}
                  End
                Else
                If Sub=AtStr then
                  Begin
                  End;
              End;
          End;
        Close(F);
      End;
  End;

PROCEDURE TLOCDraw.MissileAnimationLoad(Typer : TMissile;FileName : String);
  Var ImageFileName,St : String;
      X,Y,Z            : Integer;
      H                : THeading;
      F                : Text;
  Begin
    With MyScreen,MissileAnimations[Typer] do
      Begin
        Assign(F,FileName);
        Reset(F);
        While Not EoF(F) do
          Begin
            ReadLn(F,St);
            StrippedAllSpaceAndUpCase(St);
            If ImageInfoStr=St then
              Begin
                ReadLn(F,NumFrame,SizeX,SizeY,ShiftX,ShiftY);
              End
            Else
            If TransparentColorStr=St then
              Begin
                ReadLn(F,X,Y,Z);
                MaskColor:=RGBToWord(X,Y,Z) or $8000;
                TransColor:=RGBToLongWord(X,Y,Z);
              End
            Else
            If St=UsingFromListFileStr then
              Begin
                Images:=TAvenusTextureImages.Create;
                For Z:=1 to NumFrame do
                  Begin
                    ReadLn(F,ImageFileName);
                    {$IfDef LoadOnDataBase}
                    If Images.LoadFromFileAlpha1Bit(GraphicDataFile,MyScreen.Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                    SizeX,SizeY,TransColor)<>0 then
                      ErrorMessage(LoadingFailedStr+ImageFileName)
                    Else Log('Loading file '+GameDataDir+ImageFileName+' from database complete');
                    {$Else}
                    If Images.LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                    SizeX,SizeY,TransColor)<>0 then
                      ErrorMessage(LoadingFailedStr+ImageFileName)
                    Else Log('Loading file '+GameDataDir+ImageFileName+' complete');
                    {$EndIf}
                  End;
              End
            Else
            If St=UsingFromFileStr then
              Begin
                ReadLn(F,ImageFileName);
                Images:=TAvenusTextureImages.Create;
                {$IfDef LoadOnDataBase}
                If Images.LoadFromFileAlpha1Bit(GraphicDataFile,MyScreen.Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                SizeX,SizeY,TransColor)<>0 then
                  ErrorMessage(LoadingFailedStr+ImageFileName)
                Else Log('Loading file '+GameDataDir+ImageFileName+' from database complete');
                {$Else}
                If Images.LoadFromFileAlpha1Bit(MyScreen.Screen.D3DDevice8,GameDataDir+ImageFileName,
                                                SizeX,SizeY,TransColor)<>0 then
                  ErrorMessage(LoadingFailedStr+ImageFileName)
                Else Log('Loading file '+GameDataDir+ImageFileName+' complete');
                {$EndIf}
              End
            Else
            If St=FlyingScriptStr then
              Begin
                For H:=Low(THeading) to High(THeading) do
                  Begin
                    ReadLn(F);//Skip [Heading #]
                    ReadLn(F,FlyingScript.FrameLeng[H]);
                    SetLength(FlyingScript.FramePos[H],FlyingScript.FrameLeng[H]);
                    For Z:=1 to FlyingScript.FrameLeng[H] do
                      ReadLn(F,FlyingScript.FramePos[H][Z-1].FrameNum,
                               FlyingScript.FramePos[H][Z-1].FrameWait,
                               FlyingScript.FramePos[H][Z-1].FrameStyle);
                  End;
              End
            Else
            If St=ExplosionScriptStr then
              Begin
                For H:=Low(THeading) to High(THeading) do
                  Begin
                    ReadLn(F);//Skip [Heading #]
                    ReadLn(F,ExplosionScript.FrameLeng[H]);
                    SetLength(ExplosionScript.FramePos[H],ExplosionScript.FrameLeng[H]);
                    For Z:=1 to ExplosionScript.FrameLeng[H] do
                      ReadLn(F,ExplosionScript.FramePos[H][Z-1].FrameNum,
                               ExplosionScript.FramePos[H][Z-1].FrameWait,
                               ExplosionScript.FramePos[H][Z-1].FrameStyle);
                  End;
              End;
          End;
        Close(F);
      End;
  End;

PROCEDURE TLOCDraw.EffectedAnimationLoad(FileName : String);
  Var St,Sub : String;
      Count  : Integer;
      Typer  : TEffected;
      F      : Text;
  Begin
    With MyScreen,EffectedImages do
      Begin
        For Typer:=Low(TEffected) to
                   High(TEffected) do ImageNum[Typer]:=0;
        Assign(F,FileName);
        Reset(F);
        Images:=TAvenusTextureImages.Create;
        While Not EoF(F) do
          Begin
            ReadLn(F,St);
            If St[1]=SkipSymbol then Continue;
            Typer:=Low(TEffected);
            While St<>'' do
              Begin
                Sub:=GetFirstComment(St);
                StrippedAllSpaceAndUpCase(Sub);
                If Sub=EffectNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    StrippedAllSpaceAndUpCase(Sub);
                    Typer:=MyUnits.GetEffectByName(Sub);
                  End
                Else
                If Sub=FileNameStr then
                  Begin
                    Sub:=GetFirstComment(St);
                    //StrippedAllSpaceAndUpCase(Sub);
                    {$IfDef LoadOnDataBase}
                    If Images.LoadFromPackFile(GraphicDataFile,Screen.D3DDevice8,GameDataDir+Sub,
                                               0,0,D3DFMT_A1R5G5B5,ImageNum[Typer],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' from database complete');
                    {$Else}
                    If Images.LoadFromFile(Screen.D3DDevice8,GameDataDir+Sub,
                                           0,0,D3DFMT_A1R5G5B5,ImageNum[Typer],Count)<>0 then
                      ErrorMessage(LoadingFailedStr+Sub)
                    Else Log('Loading file '+GameDataDir+Sub+' complete');
                    {$EndIf}
                    Images.Set1BitAlpha(ImageNum[Typer],0);
                  End
                Else
                If Sub=AtStr then
                  Begin
                    //Not support
                  End;
              End;
          End;
        Close(F);
      End;
  End;
  
FUNCTION  TLOCDraw.ReadPixel(Sprite : TAvenusTextureImages;SprNum,X,Y : Integer;DefaultColor : LongWord) : LongWord;
  Var LRect :  TD3DLocked_Rect;
      DstP   : Pointer;
      Return : Word;
  Begin
    With Sprite do
      Begin
        Result:=DefaultColor;
        If Format[SprNum]<>D3DFMT_A1R5G5B5 then Exit;
        //If Lock(SprNum,LRect)<>0 then Exit;
        LRect:=Ptr[SprNum];
        If (X<0) or (X>TextureWidth[SprNum]) or
           (Y<0) or (Y>TextureHeight[SprNum]) then Exit;
        Integer(DstP):=Integer(LRect.PBits)+Y*LRect.Pitch+X*2;
        Return:=Word(DstP^) and $7FFF;
        //UnLock(SprNum);
        Result:=Color24To15(Return);
      End;
  End;

PROCEDURE TLOCDraw.ErrorMessage(Msg : String);
  Begin
    Raise Exception.Create('Error: '+Msg);
  End;
END.
