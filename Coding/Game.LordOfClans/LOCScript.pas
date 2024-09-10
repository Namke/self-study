UNIT LOCScript;
{$Include GlobalDefines.Inc}
INTERFACE

USES Classes,
     SysUtils,
     LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCMenu,
     LOCDraw,
     LOCUnitProcess,
     LOCPlayer,
     LOCAIPlayer,
     //Pascal Skate Script
     PSSUtils,
     PSS,
     PSSComp;

TYPE
  TLOCScript = Class
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
    //Pascal Skate Script variable
    PSSCompiler   : TPSSPascalCompiler;
    PSSExecute    : TPSSMultiScriptExec;
    LoadScriptRes : TLoadScriptRes;
    ScriptAvail   : Boolean;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                       Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess;
                       Player : TLOCPlayer;AIPLayer : TLOCAIPlayer);
    Destructor Destroy;OverRide;
    Procedure RemoveAllScript;
    Procedure PrepareAddOn;
    Function  LoadScript(FileName : String) : Boolean;
    Procedure PrepareRun;
    Procedure DoneRun;
    Procedure ScriptRun;
    Procedure CheckGameCondition;
    //
    //Function  _GameCount(Caller : TPSSExec;P : PIFProcRec;Global,Stack : TIFList) : Boolean;
  End;

VAR
  GameScript : TLOCScript;

IMPLEMENTATION
//External function for import to script compiler !
FUNCTION  _GameCount(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    LSetInt(Stack,Stack.Count-1,GameScreen.GameFrame);
    Result:=True;
  End;

FUNCTION  _HumanControl(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    LSetInt(Stack,Stack.Count-1,Integer(GameUnits.HumanControl));
    {$IfDef DebugScript}
    If GameScreen.DebugStatus[ShowScriptDebug] then
      GameScreen.SendMessage('Script call HumanControl !');
    {$EndIf}
    Result:=True;
  End;

FUNCTION  _Random(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    LSetInt(Stack,Stack.Count-1,Random(LGetInt(Stack,Stack.Count-2)));
    {$IfDef DebugScript}
    If GameScreen.DebugStatus[ShowScriptDebug] then
      GameScreen.SendMessage('Script call Random !');
    {$EndIf}
    Result:=True;
  End;

FUNCTION  _Message(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Var S : String;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    S:=LGetStr(Stack,Stack.Count-1);
    GameScreen.SendMessage(S);
    Result:=True;
  End;

FUNCTION  _YouVictory(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    With GameScreen do
      Begin
        GameResult:=Victory;
        SendMessage('You are victory !');
      End;
    Result:=True;
  End;

FUNCTION  _CountOfEnemyUnit(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Var Clan : TClan;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    Clan:=TClan(LGetInt(Stack,Stack.Count-2));
    LSetInt(Stack,Stack.Count-1,GameUnits.CountOfEnemyUnit(Clan));
    Result:=True;
  End;

FUNCTION  _FindUnitIDByName(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    LSetInt(Stack,Stack.Count-1,GameUnits.FindUnitIDByName(LGetStr(Stack,Stack.Count-2)));
    Result:=True;
  End;

FUNCTION  _GetUnitHitPoint(Caller : TPSSExec;P : PPSProcRec;Global,Stack : TPSList) : Boolean;
  Begin
    If Global=Nil then
      Begin
        Result:=False;
        Exit;
      End;
    LSetInt(Stack,Stack.Count-1,GameUnits.GetUnitHitPoint(LGetInt(Stack,Stack.Count-2)));
    Result:=True;
  End;
//
//Script class coding
//
CONSTRUCTOR TLOCScript.Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                              Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess;
                              Player : TLOCPlayer;AIPLayer : TLOCAIPlayer);
  Begin
    ScriptAvail:=False;
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    MyMenu:=Menu;
    MyDraw:=Draw;
    MyUnitProcess:=UnitProcess;
    MyPlayer:=Player;
    MyAIPlayer:=AIPlayer;
    //Setup script compiler and execute
    PSSCompiler:=TPSSPascalCompiler.Create;
    PSSExecute:=TPSSMultiScriptExec.Create;
    PrepareAddOn;
  End;

DESTRUCTOR TLOCScript.Destroy;
  Begin
    PSSCompiler.Free;
    PSSExecute.Free;
  End;

FUNCTION  MyOnUses(Sender : TPSSPascalCompiler;Const Name : String) : Boolean;
  Begin
    If Name='SYSTEM' then
      Begin
        //TPSSPascalCompiler(Sender).FreeAll;
        With TPSSPascalCompiler(Sender) do
          Begin
            AddConstantN('UnitDead'              ,'Integer').Value.TS32:=0;
            AddConstantN('UnitUnUsedConst'       ,'Integer').Value.TS32:=-1;
            AddConstantN('UnitUsedToCallBack'    ,'Integer').Value.TS32:=-2;
            AddTypeS('TClan','(C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,Gaia)');
            AddTypeS('TUnitCount','SmallInt');
            AddFunction('Function  GameCount : Integer;');
            AddFunction('Function  HumanControl : TClan;');
            AddFunction('Procedure YouVictory;');
            AddFunction('Procedure Message(Msg : String);');
            AddFunction('Function  Random(Rand : Integer) : Integer;');
            AddFunction('Function  CountOfEnemyUnit(Clan : TClan) : Integer;');
            AddFunction('Function  FindUnitIDByName(Name : String) : Integer;');
            AddFunction('Function  GetUnitHitPoint(UnitNum : TUnitCount) : Integer;');
          End;
        Result:=True;
      End
    Else Result:=False;
  End;

PROCEDURE TLOCScript.PrepareAddOn;
  Begin
    //PSSCompiler register
    PSSCompiler.OnUses:=MyOnUses;
    //PSSExecute register
    PSSExecute.RegisterStandardProcs;
    PSSExecute.RegisterFunctionName('GAMECOUNT'          ,_GameCount           ,Nil,Nil);
    PSSExecute.RegisterFunctionName('HUMANCONTROL'       ,_HumanControl        ,Nil,Nil);
    PSSExecute.RegisterFunctionName('YOUVICTORY'         ,_YouVictory          ,Nil,Nil);
    PSSExecute.RegisterFunctionName('MESSAGE'            ,_Message             ,Nil,Nil);
    PSSExecute.RegisterFunctionName('RANDOM'             ,_Random              ,Nil,Nil);
    PSSExecute.RegisterFunctionName('COUNTOFENEMYUNIT'   ,_CountOfEnemyUnit    ,Nil,Nil);
    PSSExecute.RegisterFunctionName('FINDUNITIDBYNAME'   ,_FindUnitIDByName    ,Nil,Nil);
    PSSExecute.RegisterFunctionName('GETUNITHITPOINT'    ,_GetUnitHitPoint     ,Nil,Nil);
    {$IfDef FullLog}
    MyScreen.Log('Setup script runtime engine successful.');
    {$EndIf}
  End;

PROCEDURE TLOCScript.RemoveAllScript;
  Begin
    PSSExecute.RemoveAll;
  End;

FUNCTION  TLOCScript.LoadScript(FileName : String) : Boolean;
  Var Stream : TFileStream;
      S      : PChar;
      D      : String;
      Size   : Integer;
  Begin
    Result:=False;
    Stream:=TFileStream.Create(FileName,FMOpenRead);
    If Stream=Nil then
      Begin
        LoadScriptRes:=CantLocateScriptFile;
        {$IfDef FullLog}
        MyScreen.Log('Can''t locate script file '+FileName+'.');
        {$EndIf}
        Exit;
      End;
    Size:=Stream.Size;
    GetMem(S,Size);
    Stream.Read(S^,Size);
    Stream.Free;
    PSSCompiler.PrepareCompiler;
    If Not PSSCompiler.Compile(S) then
      Begin
        //Can't compiler that source ?
        LoadScriptRes:=CantCompileScriptFile;
        {$IfDef FullLog}
        MyScreen.Log('Can''t compile script file '+FileName+'.');
        {$EndIf}
        Exit;
      End;
    If Not PSSCompiler.GetOutput(D) then
      Begin
        //Could't get data ?
        LoadScriptRes:=CantExportCompileCode;
        {$IfDef FullLog}
        MyScreen.Log('Can''t export compile code from file '+FileName+'.');
        {$EndIf}
        Exit;
      End
    Else
      Begin
        If PSSExecute.AddScript('',D)=0 then
          Begin
            //Could't get compile code ?
            LoadScriptRes:=CantImportCompileCode;
            {$IfDef FullLog}
            MyScreen.Log('Can''t import compile code from file '+FileName+'.');
            {$EndIf}
            Exit;
          End;
      End;
    FreeMem(S,Size);
    LoadScriptRes:=LoadScriptSuccessful;
    ScriptAvail:=True;
    {$IfDef FullLog}
    MyScreen.Log('Complete compile file '+FileName+', script loading successful.');
    {$EndIf}
    Result:=True;
    {$IfDef DebugScript}
    If GameScreen.DebugStatus[ShowScriptDebug] then
      MyScreen.SendMessage('Script building complete !');
    {$EndIf}
  End;

PROCEDURE TLOCScript.PrepareRun;
  Begin
    If ScriptAvail then PSSExecute.PrepareToRun;
    {$IfDef FullLog}
    MyScreen.Log('Start script runing.');
    {$EndIf}
  End;

PROCEDURE TLOCScript.DoneRun;
  Begin
    If ScriptAvail then
      Begin
        PSSExecute.RunScriptDone;
        ScriptAvail:=False;
      End;
    {$IfDef FullLog}
    MyScreen.Log('Run script done.');
    {$EndIf}
  End;

PROCEDURE TLOCScript.ScriptRun;
  Begin
    If ScriptAvail then
      Begin
        If Not PSSExecute.RunScriptStep then DoneRun;
      End;
  End;

PROCEDURE TLOCScript.CheckGameCondition;
  Var Clan  : TClan;
      Found : Boolean;
  Begin
    With MyScreen,MyUnits do
      Begin
        If ClanInfo[HumanControl].AllUnits=0 then
          Begin
            EndGame:=True;
            GameResult:=Lost;
            Exit;
          End;
        Found:=False;
        For Clan:=Low(TClan) to High(TClan) do
          If (ClanInfo[HumanControl].Diplomacy[Clan]=Enemy) and
             (ClanInfo[Clan].AllUnits>0) then Found:=True;
        If Not Found then
          Begin
            {EndGame:=True;
            GameResult:=Victory;
            Exit;{}
          End;
      End;
  End;
END.
