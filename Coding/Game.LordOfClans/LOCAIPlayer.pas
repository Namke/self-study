//  Simple AI player, player with simple plan: army rush !
//  Construction must place for other unit can pass over easy !
//
//
UNIT LOCAIPlayer;
{$Include GlobalDefines.Inc}
INTERFACE

USES LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCMenu,
     LOCDraw,
     LOCUnitProcess,
     LOCPlayer;

TYPE
  TLOCAIPlayer = Class
    Public
    MyScreen      : TLOCScreen;
    MyShow        : TLOCShow;
    MyUnits       : TLOCUnits;
    MyWorld       : TLOCWorld;
    MyMenu        : TLOCMenu;
    MyDraw        : TLOCDraw;
    MyUnitProcess : TLOCUnitProcess;
    MyPlayer      : TLOCPlayer;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                       Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess;
                       Player : TLOCPlayer);
    Destructor Destroy;OverRide;
    //Restart all data of all AI player
    Procedure AIRestartData;
    //Prepare for AI player
    Procedure AIPlayerPrepare;
    //AI running
    Procedure AIPlayerRun;
    //Refesh all unit in all force of AI
    Procedure AIRefeshForce(AI : TClan);
    //Process for AI player
    Procedure ProcessAIPlayer(AI : TClan);
    //Check AI enough unit for attack ?
    Function  AICheckArmy(AI : TClan) : TAICheckResult;
    //Set AI player to attack status
    Function  AIPlayerAttack(AI : TClan) : FastInt;
    Procedure AISendForceToDefenceTown(AI : TClan;Force : TForce);
    Procedure AIPlayerGetMainTown(AI : TClan);
    //Set AI to building town, AI work with fixed town are:
    //  Town Hall, Great Hall, Keep, String Hall, Castle, Fortress
    Function  AIPlayerBuildTown(AI : TClan) : Boolean;
    //
    Function  AIPlayerBuildFarm(AI : TClan) : Boolean;
    //AI player go to build
    Function  AIPlayerBuild(AI : TClan;UnitTyper : TUnit) : Boolean;
    //AI player go to training
    Function  AIPlayerTrain(AI : TClan;UnitTyper : TUnit) : Boolean;
    //Get free worker can build target
    Function  AIGetUnitCanBuild(AI : TClan;BuildTarget : TUnit) : FastInt;
    //Get free building can training
    Function  AIGetUnitCanTrain(AI : TClan;TrainTarget : TUnit) : FastInt;
    //Set unit go to training
    Function  AITrainingCommand(AI : TClan;UnitNum : TUnitCount;UnitTyper : TUnit) : FastInt;
    //AI finding target to build best constructor near Target
    Function  AIBuildingNear(AI : TClan;UnitNum : TUnitCount;
                             BuildTarget : TUnit;Target : FastInt;MinRange,MaxRange : FastInt) : Boolean;
    //Place town hall at :
    //   Nearby some gold mine
    //   No enemy unit nearby
    //   No own town nearby
    Function  AIPlaceTown(AI : TClan;UnitNum : TUnitCount;TownType : TUnit) : Boolean;
    //AI player send force command
    Procedure AISendForceCmd(AI : TClan;Force : TForce;Cmd : TSkill;X,Y : FastInt);
    Procedure AISendFreeForceCmd(AI : TClan;Force : TForce;Cmd : TSkill;X,Y : FastInt);
    Function  AISendAllWorkerToWork(AI : TClan) : Boolean;
  End;

VAR
  GameAI : TLOCAIPlayer;  

IMPLEMENTATION

CONSTRUCTOR TLOCAIPlayer.Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                                Menu : TLOCMenu;Draw : TLOCDraw;UnitProcess : TLOCUnitProcess;
                                Player : TLOCPlayer);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    MyMenu:=Menu;
    MyDraw:=Draw;
    MyUnitProcess:=UnitProcess;
    MyPlayer:=Player;
  End;

DESTRUCTOR TLOCAIPlayer.Destroy;
  Begin
  End;

PROCEDURE TLOCAIPlayer.AIRestartData;
  Var Clan  : TClan;
  Begin
    For Clan:=Low(TCLan) to High(TClan) do
      With MyUnits,AIData[Clan] do
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

PROCEDURE TLOCAIPlayer.AIPlayerPrepare;
  Var Clan : TClan;
      U    : TUnit;
      S    : TSkillCount;
      Link : TAIUnitLinkCount;
  Begin
    With MyUnits do
      Begin
        //  Run before add AI force because I want to cal some AI infomation with
        //result of counting unit in AI force
        For Clan:=Low(TClan) to High(TClan) do
          With AIData[Clan] do
            Begin
              //Calculate which unit can build other unit
              For U:=Low(TUnit) to High(TUnit) do
                For S:=Low(TSkillCount) to High(TSkillCount) do
                  If UnitsProperty[Clan,U].UnitCanGeneration[S]<>NoneUnit then
                    Begin
                      For Link:=Low(TAIUnitLinkCount) to High(TAIUnitLinkCount) do
                        If UnitCanBuild[Link,UnitsProperty[Clan,U].UnitCanGeneration[S]]=NoneUnit then
                          Begin
                            UnitCanBuild[Link,UnitsProperty[Clan,U].UnitCanGeneration[S]]:=U;
                            Break;//Yeah !!!!
                          End;
                    End;
              AIUpdateEnemyTarget(Clan);
              AIUpdateCommandAvail(Clan);
              AIAttackStyle:=AttackStyle1;
              Case ClanInfo[Clan].ClanRace of
                RaceOrc :
                  Begin
                    UnitNeed[Peon              ]:=10;
                    UnitNeed[Grunt             ]:=20;
                    UnitNeed[Axethrower        ]:=10;
                    UnitNeed[Ogre              ]:=10;
                    UnitNeed[OrcBarrack        ]:=3;
                    UnitNeed[OrcBlackSmith     ]:=1;
                    UnitNeed[TrollLumberMill   ]:=1;
                    UnitNeed[OgreMound         ]:=1;
                    UnitNeed[OrcWatchTower     ]:=20;
                    //
                    UnitNeedForAttack[Grunt             ]:=15;
                    UnitNeedForAttack[Axethrower        ]:=10;
                    UnitNeedForAttack[Ogre              ]:=10;
                  End;
                RaceHuman :
                  Begin
                    UnitNeed[Peasant           ]:=10;
                    UnitNeed[FootMan           ]:=20;
                    UnitNeed[Archer            ]:=10;
                    UnitNeed[Knight            ]:=10;
                    UnitNeed[HumanBarrack      ]:=3;
                    UnitNeed[HumanBlackSmith   ]:=1;
                    UnitNeed[ElvenLumberMill   ]:=1;
                    UnitNeed[Stables           ]:=1;
                    UnitNeed[HumanScoutTower   ]:=20;
                    //
                    UnitNeedForAttack[FootMan           ]:=15;
                    UnitNeedForAttack[Archer            ]:=10;
                    UnitNeedForAttack[Knight            ]:=10;
                  End;
              End;
              AIPlayerGetMainTown(Clan);
              If (AIMainTown<>0) and
                 (Clan<>HumanControl) then
                Begin
                  AISendForceToDefenceTown(Clan,AttackForce);
                End;
            End;
      End;
  End;

PROCEDURE TLOCAIPlayer.AIPlayerRun;
  Var Clan  : TClan;
  Begin
    For Clan:=Low(TCLan) to High(TClan) do
      If MyUnits.AIData[Clan].AIActive then
        ProcessAIPlayer(Clan);
  End;
  
PROCEDURE TLOCAIPlayer.AIRefeshForce(AI : TClan);
  Var Force : TForce;
      Z     : FastInt;
  Begin
    With MyUnits,AIData[AI] do
      For Force:=Low(TForce) to High(TForce) do
        For Z:=Low(AIForce[Force]) to High(AIForce[Force]) do
          If AIForce[Force][Z]<>0 then
            Begin
              If Units[AIForce[Force][Z]]._UnitHitPoint<=0 then
                Begin
                  AIForce[Force][Z]:=0;
                  Dec(ForceCount[Force]);
                End;
              Exit;
            End;
  End;

PROCEDURE TLOCAIPlayer.ProcessAIPlayer(AI : TClan);
  Var CCSIdx  : TComputerCommandStatus;
      UnitIdx : TUnit;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        If ClanInfo[AI].AllUnits=0 then
          Begin
            Exit;
          End;
        //Dec AI command sleeping !
        For CCSIdx:=Low(TComputerCommandStatus) to
                    High(TComputerCommandStatus) do
          If AICmdSleep[CCSIdx]>0 then Dec(AICmdSleep[CCSIdx]);
        //AIRefeshForce(AI);
        //Process AI command building:
        If AICmdAvail[CompCmdBuild] and
          (AICmdSleep[CompCmdBuild]=0) then
          Begin
            //No main town hall ? Build this
            If ForceCount[BuildingTownForce]=0 then
              Begin
                If AIPlayerBuildTown(AI) then
                  Begin
                    AIPlayerGetMainTown(AI);
                    AISendForceToDefenceTown(AI,AttackForce);
                  End
                Else AICmdSleep[CompCmdBuild]:=DefaultAISleep;
              End
            Else
            //Building more farm ?
            If (ClanInfo[AI].FoodUsed>=ClanInfo[AI].FoodAvailInFuture) and
               (ClanInfo[AI].FoodAvailInFuture<LimitUnitsPerClan) then
              Begin
                If AIPlayerBuildFarm(AI) then
                  Begin
                  End
                //Else AICmdSleep[CompCmdBuild]:=DefaultAISleep;
              End
            //Build constructor can build unit
            Else
              Begin
                {For UnitIdx:=Low(TUnit) to High(TUnit) do
                  If (UnitNeed[UnitIdx]>0) and
                     (ClanInfo[AI].UnitsCounting[UnitCanBuild[UnitIdx]]=0) then
                    Begin
                      If AIPlayerBuild(AI,UnitCanBuild[UnitIdx]) then
                      Else AICmdSleep[CompCmdBuild]:=DefaultAISleep;
                    End;}
                For UnitIdx:=Low(TUnit) to High(TUnit) do
                  //Need more building ?
                  If (UnitNeed[UnitIdx]>ClanInfo[AI].UnitsCounting[UnitIdx]) and
                  //Building in queue is zero ?
                     (ClanInfo[AI].UnitInQueue[UnitIdx]<3) then
                    Begin
                      If UnitIsBuilding in UnitsProperty[AI,UnitIdx].BaseAttribute then
                        Begin
                          AIPlayerBuild(AI,UnitIdx);
                        End
                      Else
                        Begin
                        End;
                    End;
              End;
          End;
        //AI command training/building
        If (ClanInfo[AI].FoodUsed<ClanInfo[AI].FoodLimit) then
          For UnitIdx:=Low(TUnit) to High(TUnit) do
            //Need more unit training ?
            If (UnitNeed[UnitIdx]>ClanInfo[AI].UnitsCounting[UnitIdx]) and
               //Unit in queue is zero ?
               (ClanInfo[AI].UnitInQueue[UnitIdx]<3) then
              Begin
                If UnitIsBuilding in UnitsProperty[AI,UnitIdx].BaseAttribute then
                  Begin
                    //Is CompCmdBuild work !
                  End
                Else
                  Begin
                    AIPlayerTrain(AI,UnitIdx);
                  End;
              End;
        //AI command for worker ?
        If AICmdAvail[CompCmdWorker] and
          (AICmdSleep[CompCmdWorker]=0) then
          Begin
            If AISendAllWorkerToWork(AI) then
            Else AICmdSleep[CompCmdWorker]:=DefaultAISleep;
          End;
        If AICmdAvail[CompCmdAttack] and
          (AICmdSleep[CompCmdAttack]=0) then
          Begin
            AICmdSleep[CompCmdAttack]:=2000;
            If AIPlayerAttack(AI)=0 then
              AICmdSleep[CompCmdAttack]:=10000;
              //Hmm, clear command can attack !
              //AICmdAvail[CompCmdAttack]:=False;
          End;
      End;
  End;

FUNCTION  TLOCAIPlayer.AICheckArmy(AI : TClan) : TAICheckResult;
  Var Typer : TUnit;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        For Typer:=Low(TUnit) to High(TUnit) do
          If ClanInfo[AI].UnitsCounting[Typer]<UnitNeedForAttack[Typer] then
            Begin
              Result:=AINotEnoughArmy;
              Exit;
            End;
        Result:=AIOk;
      End;
  End;

FUNCTION  TLOCAIPlayer.AIPlayerAttack(AI : TClan) : FastInt;
  Var TargetPos   : TPoint;
      FoundTarget : Boolean;
      Z           : FastInt;
  Begin
    Result:=-1;
    With MyUnits,AIData[AI] do
      Begin
        If CurrentEnemy=Gaia then Exit;
        If AICheckArmy(AI)<>AIOk then Exit;
        FoundTarget:=False;
        For Z:=Low(Units) to High(Units) do
          If (Units[Z]._UnitHitPoint>0) and
             (Units[Z]._UnitClan=CurrentEnemy) then
            Begin
              FoundTarget:=True;
              TargetPos:=Units[Z]._UnitPos;
              Break;
            End;
        If FoundTarget then
          Begin
            Result:=0;
            {$IfDef DebugAI}
            MyPlayer.PlayerSay(AI,'Attack !');
            {$EndIf}
            WaitForAttackComplete:=True;
            //AISendForceCmd(AI,AttackForce,CmdAttackAt,TargetPos.X,TargetPos.Y);
            AISendFreeForceCmd(AI,AttackForce,CmdAttackAt,TargetPos.X,TargetPos.Y);
          End;
      End;
  End;

PROCEDURE TLOCAIPlayer.AIPlayerGetMainTown(AI : TClan);
  Var Z : FastInt;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        //Main town already has ?
        If AIMainTown<>0 then Exit;
        For Z:=Low(AIForce[BuildingTownForce]) to
               High(AIForce[BuildingTownForce]) do
          If AIForce[BuildingTownForce][Z]<>0 then
            Begin
              AIMainTown:=AIForce[BuildingTownForce][Z];
              Exit;
            End;
      End;
  End;

PROCEDURE TLOCAIPlayer.AISendForceToDefenceTown(AI : TClan;Force : TForce);
  Var X,Y : FastInt;
  Begin
    With MyUnits,AIData[AI],MyWorld do
      Begin
        //Not main town ?
        If AIMainTown<=0 then Exit;
        If GetFreePosNear(AIMainTown,12,20,X,Y) then
          Begin
            AIRallyPoint.X:=X;
            AIRallyPoint.Y:=Y;
            AISendForceCmd(AI,Force,CmdAttackAt,AIRallyPoint.X,AIRallyPoint.Y);
          End;
      End;
  End;

FUNCTION  TLOCAIPlayer.AIPlayerBuildTown(AI : TClan) : Boolean;
  Var UnitNum   : FastInt;
      UnitTyper : TUnit;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        UnitTyper:=NoneUnit;
        Case ClanInfo[AI].ClanRace of
          RaceHuman :
            Begin
              If CheckClanCanBuild(AI,Castle) then UnitTyper:=Castle Else
              If CheckClanCanBuild(AI,Keep) then UnitTyper:=Keep
              Else UnitTyper:=TownHall;
            End;
          RaceOrc :
            Begin
              If CheckClanCanBuild(AI,Fortress) then UnitTyper:=Fortress Else
              If CheckClanCanBuild(AI,StrongHold) then UnitTyper:=StrongHold
              Else UnitTyper:=GreatHall;
            End;
        End;
        If UnitTyper<>NoneUnit then
          Begin
            UnitNum:=AIGetUnitCanBuild(AI,UnitTyper);
            If UnitNum<>0 then
              Begin
                {$IfDef DebugAI}
                MyPlayer.PlayerSay(AI,'No town hall ! Now build ?');
                {$EndIf}
                Result:=AIPlaceTown(AI,UnitNum,UnitTyper); 
              End
            Else Result:=False;
          End
        Else Result:=False;
      End;
  End;

FUNCTION  TLOCAIPlayer.AIPlayerBuildFarm(AI : TClan) : Boolean;
  Var UnitNum   : FastInt;
      UnitTyper : TUnit;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        UnitTyper:=NoneUnit;
        Case ClanInfo[AI].ClanRace of
          RaceHuman :
            Begin
              UnitTyper:=HumanFarm;
            End;
          RaceOrc :
            Begin
              UnitTyper:=OrcFarm;
            End;
        End;
        If UnitTyper<>NoneUnit then
          Begin
            UnitNum:=AIGetUnitCanBuild(AI,UnitTyper);
            If UnitNum>0 then
              Begin
                Result:=AIBuildingNear(AI,UnitNum,UnitTyper,AIMainTown,
                                       DefaultGoldMineFarSize,
                                       DefaultMaxAIBuildRange);
                {$IfDef DebugAI}
                If Result then
                  MyPlayer.PlayerSay(AI,'I build farm !');
                {$EndIf}
              End
            Else Result:=False;
          End
        Else Result:=False;
      End;
  End;
  
FUNCTION  TLOCAIPlayer.AIPlayerBuild(AI : TClan;UnitTyper : TUnit) : Boolean;
  Var UnitNum   : FastInt;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        If UnitTyper<>NoneUnit then
          Begin
            UnitNum:=AIGetUnitCanBuild(AI,UnitTyper);
            If UnitNum>0 then
              Begin
                //Little hack for building tower
                Case UnitTyper of
                  HumanScoutTower,OrcWatchTower :
                    Result:=AIBuildingNear(AI,UnitNum,UnitTyper,AIMainTown,
                                           DefaultMinAIBuildRange-2,
                                           DefaultMaxAIBuildRange);
                  Else
                    Result:=AIBuildingNear(AI,UnitNum,UnitTyper,AIMainTown,
                                           DefaultMinAIBuildRange,
                                           DefaultMaxAIBuildRange);
                End;
                {$IfDef DebugAI}
                If Result then
                  MyPlayer.PlayerSay(AI,'I start building ! He he !');
                {$EndIf}
              End
            Else Result:=False;
          End
        Else Result:=False;
      End;
  End;

FUNCTION  TLOCAIPlayer.AIPlayerTrain(AI : TClan;UnitTyper : TUnit) : Boolean;
  Var UnitNum : TUnitCount;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        If UnitTyper<>NoneUnit then
          Begin
            UnitNum:=AIGetUnitCanTrain(AI,UnitTyper);
            If UnitNum>0 then
              Begin
                Result:=AITrainingCommand(AI,UnitNum,UnitTyper)=0;
                {$IfDef DebugAI}
                If Result then
                  MyPlayer.PlayerSay(AI,'I start training ! He he !');
                {$EndIf}
              End
            Else Result:=False;
          End
        Else Result:=False;
      End;
  End;

FUNCTION  TLOCAIPlayer.AIGetUnitCanBuild(AI : TClan;BuildTarget : TUnit) : FastInt;
  Var TyperCanBuild : TUnit;
      TyperForce    : TForce;
      Z             : FastInt;
      Link          : TAIUnitLinkCount;
  Begin
    Result:=0;
    With MyUnits,AIData[AI] do
      Begin
        For Link:=Low(TAIUnitLinkCount) to High(TAIUnitLinkCount) do
          Begin
            TyperCanBuild:=UnitCanBuild[Link,BuildTarget];
            If TyperCanBuild=NoneUnit then Continue;
            TyperForce:=UnitsProperty[AI,TyperCanBuild].UnitForce;
            For Z:=Low(AIForce[TyperForce]) to High(AIForce[TyperForce]) do
              If AIForce[TyperForce][Z]<>0 then
                //This unit can build ?
                If (Units[AIForce[TyperForce][Z]]._UnitTyper=TyperCanBuild) and
                   //Unit is free command ?
                   (Units[AIForce[TyperForce][Z]]._UnitCmd in [NoCmd,CmdHarvest,CmdReturnGold,
                       {CmdWasted,}CmdMove,CmdPatrol,CmdAttack,CmdAttackAt]) and
                   //Unit next commmand free ?
                   (Units[AIForce[TyperForce][Z]]._UnitNextCmd in [NoCmd,CmdHarvest,CmdReturnGold,
                       {CmdWasted,}CmdMove,CmdPatrol,CmdAttack,CmdAttackAt]) and
                   //Unit prev commmand free ?
                   (Units[AIForce[TyperForce][Z]]._UnitPrevCmd in [NoCmd,CmdHarvest,CmdReturnGold,
                       {CmdWasted,}CmdMove,CmdPatrol,CmdAttack,CmdAttackAt]) then
                  Begin
                    Result:=AIForce[TyperForce][Z];
                    Exit;
                  End;
            //Not include CmdWasted, that maybe occur when unit stand while not
            //finding path for goto doing something !
          End;
      End;
  End;

FUNCTION  TLOCAIPlayer.AIGetUnitCanTrain(AI : TClan;TrainTarget : TUnit) : FastInt;
  Var TyperCanBuild : TUnit;
      TyperForce    : TForce;
      Z             : FastInt;
      Link          : TAIUnitLinkCount;
  Begin
    Result:=0;
    With MyUnits,AIData[AI] do
      Begin
        For Link:=Low(TAIUnitLinkCount) to High(TAIUnitLinkCount) do
          Begin
            TyperCanBuild:=UnitCanBuild[Link,TrainTarget];
            If TyperCanBuild=NoneUnit then Continue;
            TyperForce:=UnitsProperty[AI,TyperCanBuild].UnitForce;
            For Z:=Low(AIForce[TyperForce]) to High(AIForce[TyperForce]) do
              If AIForce[TyperForce][Z]<>0 then
                //This unit can build ?
                If (Units[AIForce[TyperForce][Z]]._UnitTyper=TyperCanBuild) and
                   (Units[AIForce[TyperForce][Z]]._UnitCmd<>CmdStartBuild) and
                   (CountUnitQueue(AIForce[TyperForce][Z])=0) then
                  Begin
                    Result:=AIForce[TyperForce][Z];
                    Exit;
                  End;
          End;
      End;
  End;

FUNCTION  TLOCAIPlayer.AITrainingCommand(AI : TClan;UnitNum : TUnitCount;UnitTyper : TUnit) : FastInt;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        Result:=UnitCommandTrain(UnitNum,UnitTyper,AI);
        {$IfDef DebugAI}
        Case Result of
          RNotEnoughFood     : MyPlayer.PlayerSay(AI,'I''m not enough food !');
          RNotEnoughResource : MyPlayer.PlayerSay(AI,'I''m not enough money !');
        End;
        {$EndIf}
      End;
  End;

PROCEDURE TLOCAIPlayer.AISendForceCmd(AI : TClan;Force : TForce;Cmd : TSkill;X,Y : FastInt);
  Var Z : FastInt;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        For Z:=Low(AIForce[Force]) to High(AIForce[Force]) do
          If AIForce[Force][Z]<>0 then
            SetUnitCommand(AIForce[Force][Z],Cmd,X,Y,AI);
      End;
  End;

PROCEDURE TLOCAIPlayer.AISendFreeForceCmd(AI : TClan;Force : TForce;Cmd : TSkill;X,Y : FastInt);
  Var Z : FastInt;
  Begin
    With MyUnits,AIData[AI] do
      Begin
        For Z:=Low(AIForce[Force]) to High(AIForce[Force]) do
          If (AIForce[Force][Z]<>0) and
             (Units[AIForce[Force][Z]]._UnitCmd in [NoCmd,CmdWasted]) and
             (Units[AIForce[Force][Z]]._UnitNextCmd in [NoCmd,CmdWasted]) and
             (Units[AIForce[Force][Z]]._UnitPrevCmd in [NoCmd,CmdWasted]) then
            SetUnitCommand(AIForce[Force][Z],Cmd,X,Y,AI);
      End;
  End;

FUNCTION  TLOCAIPlayer.AIBuildingNear(AI : TClan;UnitNum : TUnitCount;
                                      BuildTarget : TUnit;Target : FastInt;
                                      MinRange,MaxRange : FastInt) : Boolean;
  Var X1,Y1,X2,Y2,I,J,X,Y,
      BestRange,OwnRange : FastInt;
      Head               : THeading;
  Begin
    Result:=True;
    With MyUnits,AIData[AI],MyWorld do
      Begin
        Head:=GetRandomHeading;
        BestRange:=High(FastInt);
        X:=0;Y:=0;
        With Units[Target] do
          Begin
            X1:=_UnitPos.X;
            X2:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
            Y1:=_UnitPos.Y;
            Y2:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
            If X1>MaxRange then X1:=X1-MaxRange Else X1:=0;
            If X2+MaxRange<MapSizeX then X2:=X2+MaxRange Else X2:=MapSizeX-1;
            If Y1>MaxRange then Y1:=Y1-MaxRange Else Y1:=0;
            If Y2+MaxRange<MapSizeY then Y2:=Y2+MaxRange Else Y2:=MapSizeY-1;
            For I:=X1 to X2 do
              For J:=Y1 to Y2 do
                {$IfDef PlaceFixedDistance}
                If (I mod AIPlaceDistance=0) and (J mod AIPlaceDistance=0) then
                {$EndIf}
                If TestTyperUnitPos(AI,BuildTarget,Head,I,J)=PlaceOk then
                  Begin
                    //Distance between gold mine and current position
                    OwnRange:=RangeBetweenUnit(Target,I,J);
                    If OwnRange>MinRange then
                      Begin
                        If OwnRange<BestRange then
                          Begin
                            BestRange:=OwnRange;
                            X:=I;
                            Y:=J;
                          End
                        Else
                        If (OwnRange=BestRange) and (Random(50)<20) then
                          Begin
                            BestRange:=OwnRange;
                            X:=I;
                            Y:=J;
                          End;
                      End;
                  End;
            //Found target for building ?
            If BestRange<>High(FastInt) then
              Begin
                UnitCommandBuild(UnitNum,BuildTarget,X,Y,AI);
              End
            Else Result:=False;
          End;
      End;
  End;

FUNCTION  TLOCAIPlayer.AIPlaceTown(AI : TClan;UnitNum : TUnitCount;TownType : TUnit) : Boolean;
  Var X1,Y1,X2,Y2,I,J,UN,Z,X,Y,BestRange,OwnRange,BestMine : FastInt;
      CanSelectThisGoldMine                                : Boolean;
  Begin
    With MyUnits,AIData[AI],MyWorld do
      Begin
        BestMine:=0;
        BestRange:=High(FastInt);
        //With all gold mine type ?
        For Z:=Low(Units) to High(Units) do
          If (UnitIsGoldMine in UnitsProperty[Units[Z]._UnitClan,
                                              Units[Z]._UnitTyper].BaseAttribute) and
             (Units[Z]._UnitHitPoint>0) then
            Begin
              CanSelectThisGoldMine:=True;
              X1:=Units[Z]._UnitPos.X;
              X2:=Units[Z]._UnitPos.X+UnitsProperty[Units[Z]._UnitClan,
                                               Units[Z]._UnitTyper].UnitSizeX;
              Y1:=Units[Z]._UnitPos.Y;
              Y2:=Units[Z]._UnitPos.Y+UnitsProperty[Units[Z]._UnitClan,
                                               Units[Z]._UnitTyper].UnitSizeY;
              If X1>DefaultGoldMineAroundSize then
                X1:=X1-DefaultGoldMineAroundSize
              Else X1:=0;
              If X2+DefaultGoldMineAroundSize<MapSizeX then
                X2:=X2+DefaultGoldMineAroundSize
              Else X2:=MapSizeX-1;
              If Y1>DefaultGoldMineAroundSize then
                Y1:=Y1-DefaultGoldMineAroundSize
              Else Y1:=0;
              If Y2+DefaultGoldMineAroundSize<MapSizeY then
                Y2:=Y2+DefaultGoldMineAroundSize
              Else Y2:=MapSizeY-1;
              For I:=X1 to X2 do
                Begin
                  For J:=Y1 to Y2 do
                    Begin
                      UN:=MapNum[I,J];
                      While UN<>0 do
                        With Units[UN] do
                          Begin
                            X:=_UnitPos.X+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeX;
                            Y:=_UnitPos.Y+UnitsProperty[_UnitClan,_UnitTyper].UnitSizeY;
                            //Unit not in range ? Or unit is same clan ?
                            If (X<X1) or (Y<Y1) then
                              Begin
                                UN:=_UnitNext;
                                Continue;
                              End;
                            //Enemy unit nearby this gold mine ?
                            If ClanInfo[AI].Diplomacy[_UnitClan]=Enemy then
                              Begin
                                CanSelectThisGoldMine:=False;
                                Break;
                              End;
                            //Own town nearby this gold mine ?
                            If (_UnitClan=AI) and
                               (UnitIsDeposit in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute) then
                              Begin
                                CanSelectThisGoldMine:=False;
                                Break;
                              End;
                            UN:=_UnitNext;
                          End;
                    End;
                  If Not CanSelectThisGoldMine then Break;
                End;
              If CanSelectThisGoldMine then
                Begin
                  //Choose mine has min distance to unit
                  OwnRange:=RangeBetweenUnit(UnitNum,Z);
                  If OwnRange<BestRange then
                    Begin
                      BestRange:=OwnRange;
                      BestMine:=Z;
                    End;
                End;
            End;
        //Alright, now I have a best mine target ? Can I building this ?
        If BestMine>0 then
          Begin
            Result:=AIBuildingNear(AI,UnitNum,TownType,BestMine,
                                   0,DefaultGoldMineAroundSize);
          End
        //I can't find mine target for build
        Else Result:=False;
      End;
  End;

FUNCTION  TLOCAIPlayer.AISendAllWorkerToWork(AI : TClan) : Boolean;
  Var Z,UnitTarget : FastInt;
  Begin
    With MyUnits,AIData[AI],MyWorld do
      Begin
        Result:=False;
        If AIMainTown=0 then Exit;
        UnitTarget:=0;
        For Z:=Low(AIForce[WorkerForce]) to High(AIForce[WorkerForce]) do
          //Force slot used ?
          If AIForce[WorkerForce][Z]<>0 then
            //Unit slot no command ?
            If Units[AIForce[WorkerForce][Z]]._UnitCmd=NoCmd then
              Begin
                If UnitTarget=0 then
                  UnitTarget:=GetUnitNear(AIMainTown,GoldMine,0,10);
                If UnitTarget<>0 then
                  UnitCommandHarvest(AIForce[WorkerForce][Z],UnitTarget,AI);
              End;
        Result:=True;
      End;
  End;
END.
