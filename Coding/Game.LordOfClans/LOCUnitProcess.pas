UNIT LOCUnitProcess;
{$Include GlobalDefines.Inc}
INTERFACE

USES LOCBased,
     LOCScreen,
     LOCShow,
     LOCUnits,
     LOCWorld,
     LOCMenu,
     LOCDraw;

TYPE
  TLOCUnitProcess = Class
    Public
    MyScreen : TLOCScreen;
    MyShow   : TLOCShow;
    MyUnits  : TLOCUnits;
    MyWorld  : TLOCWorld;
    MyMenu   : TLOCMenu;
    MyDraw   : TLOCDraw;
    Constructor Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                       Menu : TLOCMenu;Draw : TLOCDraw);
    Destructor Destroy;OverRide;
    //
    //Unit process function
    //
    Procedure SetUnitSpell(UnitNum : TUnitCount);
    //Finding path for unit moving, patrol or going to nearby unit attack target
    //Must sure before call this function, unit has been complete run or attack step
    //Support for unit CmdMove, CmdPatrol, CmdAttack, CmdBuild !
    Procedure UnitFindPath(UnitNum : TUnitCount);
    Procedure UnitFindTarget(UnitNum : TUnitCount);
    Procedure UnitIdle(UnitNum : TUnitCount);
    Procedure UnitHoldPosition(UnitNum : TUnitCount);
    Procedure UnitStop(UnitNum : TUnitCount);
    Procedure UnitMove(UnitNum : TUnitCount);
    Procedure UnitFollow(UnitNum : TUnitCount);
    Procedure UnitPatrol(UnitNum : TUnitCount);
    Procedure UnitAttack(UnitNum : TUnitCount);
    Procedure UnitAttackAt(UnitNum : TUnitCount);
    Procedure UnitAttacking(UnitNum : TUnitCount);
    Procedure UnitAttackingStand(UnitNum : TUnitCount);
    Procedure UnitCastSpell(UnitNum : TUnitCount);
    Procedure UnitCastSpelling(UnitNum : TUnitCount);
    Procedure UnitWastedTime(UnitNum : TUnitCount);
    Procedure UnitDead(UnitNum : TUnitCount);
    //Unit go to building UnitTarget
    Procedure UnitBuild(UnitNum : TUnitCount);
    //Unit on building target
    Procedure UnitBuildWork(UnitNum : TUnitCount);
    //On mining and return gold command, this command has specific MineTarget and ReturnGoldTarget
    //has been calculating when unit start get a command
    //Unit go to harvest from MineTarget
    Procedure UnitHarvest(UnitNum : TUnitCount);
    //Unit mining on MineTarget
    Procedure UnitMining(UnitNum : TUnitCount);
    //Unit return gold to ReturnGoldTarget and back to mining from MineTarget
    Procedure UnitReturnGold(UnitNum : TUnitCount);
    //If UnitTarget is not zero, unit has a put item command to other unit (TargetUnit) else
    //unit has a put item command to specific target, is [ItemPos] position 
    Procedure UnitPutItem(UnitNum : TUnitCount);
    //Unit pick item from specific item store on map
    Procedure UnitPickItem(UnitNum : TUnitCount);
    //Unit load unit
    Procedure UnitLoadUnit(UnitNum : TUnitCount);
    //Unit unload unit
    Procedure UnitUnLoadUnit(UnitNum : TUnitCount);
    //Unit go to transport unit
    Procedure UnitGoTransport(UnitNum : TUnitCount);
    //Unit global action
    Procedure UnitAction(UnitNum : TUnitCount);
    //Unit idle action
    Procedure UnitIdleAction(UnitNum : TUnitCount);
    //  I'm must place this function here because TLOCWorld don't know TLOCDraw, but
    //when checked point click I'm must using game image data
    Procedure SelectUnitClick(AddUnit : Boolean);
    Procedure UnSelectUnitClick(AddUnit : Boolean);
    //Get unit on tile [X,Y] and click on [XS,YS]
    Procedure SelectUnitOnMapPointClick(X,Y,XS,YS : FastInt;AddUnit,Clear : Boolean);
    //Get unit on tile [X,Y] and click on [XS,YS]
    //Unit must be active - not died
    Function  GetUnitOnMapPointClick(X,Y,XS,YS : FastInt) : TUnitCount;
    //
    //Missile process function
    //
    //Missile flying like arrow or besenker axe, this function not optimizing
    Procedure MissileFlying(MissileNum : TMissileCount);
    Procedure MissileStand(MissileNum : TMissileCount);
    Function  CheckMissileHit(MissileNum : TMissileCount) : Boolean;
    Function  CheckMissileExpHit(MissileNum : TMissileCount) : Boolean;
    Procedure MissileExplosion(MissileNum : TMissileCount);
    Procedure MissileAction(MissileNum : TMissileCount);
    //
    //Effective process function
    //
    Procedure EffectAction(EffectNum : TEffectedCount);
    Procedure EffectActionHeroSignFlash(EffectNum : TEffectedCount);
    Procedure EffectActionHeroSignFlashRotate(EffectNum : TEffectedCount);
  End;

VAR
  GameUnitProcess : TLOCUnitProcess;

IMPLEMENTATION

CONSTRUCTOR TLOCUnitProcess.Create(Screen : TLOCScreen;Show : TLOCShow;Units : TLOCUnits;World : TLOCWorld;
                                   Menu : TLOCMenu;Draw : TLOCDraw);
  Begin
    MyScreen:=Screen;
    MyShow:=Show;
    MyUnits:=Units;
    MyWorld:=World;
    MyMenu:=Menu;
    MyDraw:=Draw;
  End;

DESTRUCTOR TLOCUnitProcess.Destroy;
  Begin
  End;

PROCEDURE TLOCUnitProcess.SetUnitSpell(UnitNum : TUnitCount);
  Var I,J,K : FastInt;
  Begin
    With MyUnits,Units[UnitNum] do
      Begin
        UnitCostForSpell(UnitNum,_UnitSpell);
        Case _UnitSpell of
          SpellInvisibility :
            Begin
              //Cast spell to target
              If _UnitTarget<>0 then
                Begin
                  NewEffect(_UnitTarget,Invisible,32000);
                End
              //Cast spell to area
              Else
                Begin
                End;
            End;
          SpellHaste :
            Begin
              //Cast spell to target
              If _UnitTarget<>0 then
                Begin
                  NewEffect(_UnitTarget,Haste,2000);
                End
              //Cast spell to area
              Else
                Begin
                End;
            End;
          SpellDecay :
            Begin
              //Cast spell to target
              If _UnitTarget<>0 then
                Begin
                  For I:=1 to 10 do
                    NewMissile(UnitNum,_UnitTarget,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile,True);
                End
              //Cast spell to area
              Else
                Begin
                End;
            End;
          SpellFireBall :
            Begin
              //Cast spell to target
              If _UnitTarget<>0 then
                Begin
                  For I:=1 to 4 do
                    NewMissile(UnitNum,_UnitTarget,MissileFireBall,True)
                End
              //Cast spell to area
              Else
                Begin
                  For I:=1 to 4 do
                    NewMissile(UnitNum,_UnitDest.X,_UnitDest.Y,MissileFireBall,True)
                End;
            End;
          SpellLightning :
            Begin
              For I:=-5 to 5 do
                Begin
                  {NewMissile(UnitNum,Pos.X-6,Pos.Y+Z,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile);
                  NewMissile(UnitNum,Pos.X+6,Pos.Y+Z,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile);
                  NewMissile(UnitNum,Pos.X+Z,Pos.Y-6,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile);
                  NewMissile(UnitNum,Pos.X+Z,Pos.Y+6,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile);}
                  NewMissile(UnitNum,_UnitPos.X-6,_UnitPos.Y+I,MissileFireBall);
                  NewMissile(UnitNum,_UnitPos.X+6,_UnitPos.Y+I,MissileFireBall);
                  NewMissile(UnitNum,_UnitPos.X+I,_UnitPos.Y-6,MissileFireBall);
                  NewMissile(UnitNum,_UnitPos.X+I,_UnitPos.Y+6,MissileFireBall);
                End;
            End;
          SpellBlizzard :
            Begin
              For K:=1 to 4 do
                For I:=-2 to 2 do
                  For J:=-2 to 2 do
                    NewMissile(UnitNum,_PatrolDest.X+I-1,_PatrolDest.Y+J-K,
                                       _PatrolDest.X+I,_PatrolDest.Y+J,MissileBlizzard,True);
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitFindPath(UnitNum : TUnitCount);
  Var {$IfNDef NoFindingPoorWay}
      H1,H2  : THeading;
      {$EndIf}
      K      : FastInt;
      Target : TUnitCount;
      Change : Boolean;
  Begin
    With MyUnits,Units[UnitNum],MyWorld do
      Begin
        _UnitFrame:=0;
        //If unit in final _UnitDest
        If (_UnitPos.X=_UnitDest.X) and (_UnitPos.Y=_UnitDest.Y) then
          Begin
            If Not UnitGetNextCommand(UnitNum) then
              Case _UnitCmd of
                CmdPatrol ://Toggle CmdPatrol _UnitDest and position
                  Begin
                    UnitSwapPatrolTarget(UnitNum);
                  End;
                Else
                  Begin
                    _UnitCmd:=NoCmd;
                    _PathUsed:=0;
                    //Get previous command
                    If _UnitPrevCmd<>NoCmd then
                      Begin
                        UnitGetPrevCommand(UnitNum);
                      End
                    Else//Or get next command ?
                      Begin
                        UnitGetNextCommand(UnitNum);
                      End;
                  End;
              End;
          End
        Else
          Begin
            //UnitGetNextCommand(UnitNum);
          End;
        Case _UnitCmd of
          CmdMove,CmdFollow,CmdPatrol,CmdAttack,CmdAttackAt,CmdBuild,CmdCastSpell,
          CmdHarvest,CmdReturnGold,CmdPutItem,CmdPickItem,CmdLoadUnit,CmdUnLoadUnit,
          CmdGoTransport :
            Begin
              Case _UnitCmd of
                CmdFollow :
                  Begin
                    //Get unit destination
                    //_UnitDest:=Units[_UnitTarget]._UnitPos;
                    {$IfDef AttackWhenAlert}
                    If GetUnitAttribute(UnitNum,UnitHasATarget) then
                    {$EndIf}
                      Begin
                        Case ClanInfo[_UnitClan].Control of
                          Human : Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange,
                                                                          RealUnitSeeRange(UnitNum));
                          Else Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange+DefaultComputerRangeInc,
                                                                       RealUnitSeeRange(UnitNum)+DefaultComputerRangeInc);
                        End;
                        If Target<>0 then
                          Begin
                            UnitCommandPatrolAttack(UnitNum,Target);
                            Exit;
                          End
                        Else _UnitDest:=Units[_UnitTarget]._UnitPos;
                      End
                    {$IfDef AttackWhenAlert}
                    Else _UnitDest:=Units[_UnitTarget]._UnitPos;
                    {$EndIf}
                  End;
                CmdPatrol :
                  Begin
                    {$IfDef AttackWhenAlert}
                    If GetUnitAttribute(UnitNum,UnitHasATarget) then
                    {$EndIf}
                      Begin
                        Case ClanInfo[_UnitClan].Control of
                          Human : Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange,
                                                                          RealUnitSeeRange(UnitNum));
                          Else Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange+DefaultComputerRangeInc,
                                                                       RealUnitSeeRange(UnitNum)+DefaultComputerRangeInc);
                        End;
                        If Target<>0 then
                          Begin
                            UnitCommandPatrolAttack(UnitNum,Target);
                            Exit;
                          End;
                      End;
                  End;
                CmdAttackAt :
                  Begin
                    {$IfDef AttackWhenAlert}
                    If GetUnitAttribute(UnitNum,UnitHasATarget) then
                    {$EndIf}
                      Begin
                        Case ClanInfo[_UnitClan].Control of
                          Human : Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange,
                                                                          RealUnitSeeRange(UnitNum));
                          Else Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange+DefaultComputerRangeInc,
                                                                       RealUnitSeeRange(UnitNum)+DefaultComputerRangeInc);
                        End;
                        If Target<>0 then
                          Begin
                            UnitCommandPatrolAttack(UnitNum,Target);
                            Exit;
                          End;
                      End;
                  End;
              End;
              //Checking for unit skill, exam: Tower can CmdAttack but can't moving
              If CheckUnitSkill(UnitNum,CmdMove)=False then
                Begin
                  UnitResetCommand(UnitNum);
                  Exit;
                End;
              //Unit CmdMove to target
              PickUnit(UnitNum,True);
              Change:=False;
              If _PathUsed=0 then
                Begin
                  If FindPath(UnitNum) then
                    Begin
                      If PathLength>1 then
                        Begin
                          _PathSave:=0;
                          K:=PathLength-2;
                          _PathUsed:=1;
                          While (_PathSave<MaxUnitSavedPath) and (K>=0) do
                            Begin
                              Inc(_PathSave);
                              _PathLine[_PathSave]:=PathHead[K];
                              Dec(K);
                            End;
                        End
                      Else
                        Begin
                          _PathSave:=0;
                          _PathUsed:=0;
                        End;
                      _UnitHeading:=PathHead[PathLength-1];
                      _UnitPos.X:=_UnitPos.X+Direction[_UnitHeading].X;
                      _UnitPos.Y:=_UnitPos.Y+Direction[_UnitHeading].Y;
                      Change:=True;
                      //Found way, reset wasted time counting
                      _WastedTimeCount:=0;
                    End
                  Else
                    Begin
                      {$IfDef ResetPatrolWhenNotPath}
                      If (_UnitCmd=CmdPatrol) and
                         (RangeBetweenUnit(UnitNum,_UnitDest.X,_UnitDest.Y)<DistanceCanRestartPatrol) then
                        UnitSwapPatrolTarget(UnitNum);
                      //Else
                      {$EndIf}
                      //Send unit for wasted time wait for next resolution
                      UnitCommandWastedTime(UnitNum);
                    End;
                End
              Else
                Begin
                  //Get current save heading on queue
                  _UnitHeading:=_PathLine[_PathUsed];
                  //If can go follow heading, then going and set _PathUsed for next point
                  If TestUnitPos(UnitNum,_UnitPos.X+Direction[_UnitHeading].X,
                                         _UnitPos.Y+Direction[_UnitHeading].Y)=PlaceOk then
                    Begin
                      _UnitPos.X:=_UnitPos.X+Direction[_UnitHeading].X;
                      _UnitPos.Y:=_UnitPos.Y+Direction[_UnitHeading].Y;
                      Change:=True;
                      If _PathUsed<_PathSave then Inc(_PathUsed) Else _PathUsed:=0;
                    End
                  Else
                  //Else finding new way for unit
                    Begin
                      {$IfNDef NoFindingPoorWay}
                      //If unit can't go follow heading then I take unit go follow near by heading
                      //That solve may be wrong
                      If Heading=High(THeading) then H1:=Low(THeading) Else H1:=THeading(Byte(Heading)+1);
                      If Heading=Low(THeading) then H2:=High(THeading) Else H2:=THeading(Byte(Heading)-1);
                      If TestUnitPos(UnitNum,_UnitPos.X+Direction[H1].X,_UnitPos.Y+Direction[H1].Y)=PlaceOk then
                        Begin
                          _UnitPos.X:=_UnitPos.X+Direction[H1].X;
                          _UnitPos.Y:=_UnitPos.Y+Direction[H1].Y;
                          Change:=True;
                          Heading:=H1;
                          If _PathUsed<_PathSave then Inc(_PathUsed) Else _PathUsed:=0;
                          //Found way, reset wasted time counting
                          _WastedTimeCount:=0;
                        End
                      Else
                      If TestUnitPos(UnitNum,_UnitPos.X+Direction[H2].X,_UnitPos.Y+Direction[H2].Y)=PlaceOk then
                        Begin
                          _UnitPos.X:=_UnitPos.X+Direction[H2].X;
                          _UnitPos.Y:=_UnitPos.Y+Direction[H2].Y;
                          Change:=True;
                          Heading:=H2;
                          If _PathUsed<_PathSave then Inc(_PathUsed) Else _PathUsed:=0;
                          //Found way, reset wasted time counting
                          _WastedTimeCount:=0;
                        End
                      Else
                      {$EndIf}
                      If FindPath(UnitNum) then
                        Begin
                          If PathLength>1 then
                            Begin
                              _PathSave:=0;
                              K:=PathLength-2;
                              _PathUsed:=1;
                              While (_PathSave<MaxUnitSavedPath) and (K>=0) do
                                Begin
                                  Inc(_PathSave);
                                  _PathLine[_PathSave]:=PathHead[K];
                                  Dec(K);
                                End;
                            End
                          Else
                            Begin
                              _PathSave:=0;
                              _PathUsed:=0;
                            End;
                          _UnitHeading:=PathHead[PathLength-1];
                          _UnitPos.X:=_UnitPos.X+Direction[_UnitHeading].X;
                          _UnitPos.Y:=_UnitPos.Y+Direction[_UnitHeading].Y;
                          Change:=True;
                          //Found way, reset wasted time counting
                          _WastedTimeCount:=0;
                        End
                      Else
                        Begin
                          {$IfDef ResetPatrolWhenNotPath}
                          If (_UnitCmd=CmdPatrol) and
                             (RangeBetweenUnit(UnitNum,_UnitDest.X,_UnitDest.Y)<DistanceCanRestartPatrol) then
                            UnitSwapPatrolTarget(UnitNum);
                          //Else
                          {$EndIf}
                          //Send unit for wasted time wait for next resolution
                          UnitCommandWastedTime(UnitNum);
                        End;
                    End;
                End;
              PutUnit(UnitNum,True,Change);
            End;
        End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitFindTarget(UnitNum : TUnitCount);
  Var Target : TUnitCount;
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum],MyWorld do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            If _UnitFrame<UnitAnimations[_UnitTyper].StandScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].StandScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else
              Begin
                _UnitFrame:=0;
                Inc(_UnitWait,UnitAnimations[_UnitTyper].StandScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End;
          End;
        //Now do something when stand ?
        If UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
        Else
          Begin
            If IsChangeHeadingFrame and (Random(10)=0) then
              If UnitChangeHeading(UnitNum,GetRandomHeading) then
                {$IfDef LightOfSight}
                UnitUpdatePosition(UnitNum);
                {$EndIf}
          End;
        {$IfNDef AttackWhenAlert}
        If IsFindTargetFrame then
        {$Else}
        If GetUnitAttribute(UnitNum,UnitHasATarget) then
        {$EndIf}
          Begin
            //Unit can movement
            If CheckUnitSkill(UnitNum,CmdMove) then
              Begin
                Case ClanInfo[_UnitClan].Control of
                  Human : Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange,
                                                                  RealUnitSeeRange(UnitNum));
                  Else Target:=UnitFindTargetForAttack(UnitNum,UnitsProperty[_UnitClan,_UnitTyper].SeeRange+DefaultComputerRangeInc,
                                                               RealUnitSeeRange(UnitNum)+DefaultComputerRangeInc);
                End;
                If Target<>0 then
                  Begin
                    UnitCommandAttackAt(UnitNum,_UnitPos.X,_UnitPos.Y,_UnitClan);
                    UnitCommandPatrolAttack(UnitNum,Target);
                  End;
              End
            Else//Unit must be standtill ?
              Begin
                Case ClanInfo[_UnitClan].Control of
                  Human : Target:=UnitFindTargetForAttack(UnitNum,RealUnitAttackMaxRange(UnitNum),
                                                                  RealUnitAttackMaxRange(UnitNum));
                  Else Target:=UnitFindTargetForAttack(UnitNum,RealUnitAttackMaxRange(UnitNum),
                                                               RealUnitAttackMaxRange(UnitNum));
                End;
                If Target<>0 then
                  UnitCommandAttackingStand(UnitNum,Target,_UnitClan);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitIdle(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum],MyWorld do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            If _UnitFrame<UnitAnimations[_UnitTyper].StandScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].StandScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else
              Begin
                _UnitFrame:=0;
                Inc(_UnitWait,UnitAnimations[_UnitTyper].StandScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End;
          End;
        //Now do something when stand ?
        If UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
        Else
          Begin
            If IsChangeHeadingFrame and (Random(10)=0) then
              If UnitChangeHeading(UnitNum,GetRandomHeading) then
                {$IfDef LightOfSight}
                UnitUpdatePosition(UnitNum);
                {$EndIf}
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitHoldPosition(UnitNum : TUnitCount);
  Var Target : TUnitCount;
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum],MyWorld do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            If _UnitFrame<UnitAnimations[_UnitTyper].StandScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].StandScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else
              Begin
                _UnitFrame:=0;
                Inc(_UnitWait,UnitAnimations[_UnitTyper].StandScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
                If UnitGetPrevCommand(UnitNum) then Exit;
                If UnitGetNextCommand(UnitNum) then Exit;
              End;
          End;
        //Now do something when stand ?
        //Now do something when stand ?
        If UnitIsBuilding in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute then
        Else
          Begin
            If IsChangeHeadingFrame and (Random(10)=0) then
              If UnitChangeHeading(UnitNum,GetRandomHeading) then
                {$IfDef LightOfSight}
                UnitUpdatePosition(UnitNum);
                {$EndIf}
          End;
        {$IfNDef AttackWhenAlert}
        If IsFindTargetFrame then
        {$Else}
        If GetUnitAttribute(UnitNum,UnitHasATarget) then
        {$EndIf}
          Begin
            //Find unit target in attack range !
            Case ClanInfo[_UnitClan].Control of
              Human : Target:=UnitFindTargetForAttack(UnitNum,RealUnitAttackMaxRange(UnitNum),
                                                              RealUnitAttackMaxRange(UnitNum));
              Else Target:=UnitFindTargetForAttack(UnitNum,RealUnitAttackMaxRange(UnitNum),
                                                           RealUnitAttackMaxRange(UnitNum));
            End;
            If Target<>0 then
              Begin
                _UnitPrevCmd:=_UnitCmd;
                _UnitCmd:=NoCmd;
                UnitCommandAttackingStand(UnitNum,Target,_UnitClan);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitStop(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum] do
      Begin
        _UnitCmd:=NoCmd;
        _UnitNextCmd:=NoCmd;
        _UnitTarget:=0;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitMove(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
                //_UnitWait:=UnitAnimations[_UnitTyper].RunScript.Script[Heading,_UnitFrame].FrameWait;
              End
            Else//End moving, continue unit process
              Begin
                If Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitFollow(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                If UnitCheckTargetClose(UnitNum) then _UnitFrame:=0
                Else UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                If UnitCheckTargetClose(UnitNum) then _UnitFrame:=0
                Else UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitPatrol(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum],MyWorld do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                If Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitAttack(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum],MyWorld do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitCheckAttacking(UnitNum);
                If (_UnitCmd=CmdAttack) then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                //If unit can CmdAttack (too near target), set unit to attacking status
                UnitCheckAttacking(UnitNum);
                If (_UnitCmd=CmdAttack) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitAttackAt(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum],MyWorld do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                If Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitAttacking(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitAttackingSpeed(UnitNum));
          End
        Else
          Begin
            //If _UnitFrame=FrameUnUsed then _UnitFrame:=0;
            If _UnitFrame<UnitAnimations[_UnitTyper].AttackScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].AttackScript.Script[_UnitHeading,_UnitFrame].FrameWait);
                //If this frame to hit, hit unit ?
                If UnitAnimations[_UnitTyper].AttackScript.
                   Script[_UnitHeading,_UnitFrame].FrameStyle and FrameHit=FrameHit then
                  Begin
                    //Unit lost target ?
                    If _UnitTarget=0 then
                      Begin
                        If ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile<>MissileNone then
                          NewMissile(UnitNum,_UnitDest.X,_UnitDest.Y,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile)
                      End
                    Else
                      Begin
                        If ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile<>MissileNone then
                          NewMissile(UnitNum,_UnitTarget,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile)
                        Else UnitHit(UnitNum);
                      End;
                  End;
              End
            Else//Unit complete attacking motion, going to damage or missile CmdAttack!
              Begin
                _UnitFrame:=0;
                //Unit lost target ?
                If _UnitTarget=0 then
                  Begin
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End
                Else
                If Units[_UnitTarget]._UnitHitPoint<=0 then
                  Begin
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End
                Else
                  Begin
                    _UnitFrame:=FrameUnUsed;
                    If Not UnitGetNextCommand(UnitNum) then
                      Begin
                        _UnitCmd:=CmdAttack;
                        //Reset wasted time count before set wasted time command because this not case unit can't
                        //find way, that unit wait for return combat, maybe must change with other command
                        _WastedTimeCount:=0;
                        UnitCommandWastedTime(UnitNum);
                      End;
                  End;
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitAttackingStand(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyWorld,MyUnits,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitAttackingSpeed(UnitNum));
          End
        Else
          Begin
            If _UnitFrame=FrameUnUsed then
              Begin
                //When unit is building, function unit change heading auto stoped change heading
                //Building unit never change heading ! This function maybe optimize but why needed this ?
                UnitGetHeadingToAttack(UnitNum);
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].AttackScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
                //If this frame to hit, hit unit ?
                If UnitAnimations[_UnitTyper].AttackScript.
                   Script[_UnitHeading,_UnitFrame].FrameStyle and FrameHit=FrameHit then
                  Begin
                    //Unit lost target ?
                    If _UnitTarget=0 then
                      Begin
                        If ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile<>MissileNone then
                          NewMissile(UnitNum,_UnitDest.X,_UnitDest.Y,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile)
                      End
                    Else
                      Begin
                        If ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile<>MissileNone then
                          NewMissile(UnitNum,_UnitTarget,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile)
                        Else UnitHit(UnitNum);
                      End;
                  End;
              End
            Else
            If _UnitFrame<UnitAnimations[_UnitTyper].AttackScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].AttackScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
                //If this frame to hit, hit unit ?
                If UnitAnimations[_UnitTyper].AttackScript.
                   Script[_UnitHeading,_UnitFrame].FrameStyle and FrameHit=FrameHit then
                  Begin
                    If ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile<>MissileNone then
                      NewMissile(UnitNum,_UnitTarget,ItemProperty[_UnitItems[WeaponItem].Typer].WeaponMissile)
                    Else UnitHit(UnitNum);
                  End;
              End
            Else//Unit complete attacking motion, going to damage or missile CmdAttack!
              Begin
                _UnitFrame:=0;
                //Unit lost target ?
                If _UnitTarget=0 then
                  Begin
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End
                Else
                If Units[_UnitTarget]._UnitHitPoint<=0 then
                  Begin
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End
                Else
                  Begin
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End;
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitCastSpell(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum],MyWorld do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                UnitCheckCastSpell(UnitNum);
                If _UnitCmd=CmdCastSpell then UnitFindPath(UnitNum);
              End
            Else//Next frame generation, maybe change to cast spell animation ?
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                //If unit can CmdAttack (too near target), set unit to attacking status
                UnitCheckCastSpell(UnitNum);
                If (_UnitTarget<>0) and
                   (Units[_UnitTarget]._UnitHitPoint<=0) then
                  Begin
                    If Not UnitGetNextCommand(UnitNum) then
                      UnitResetCommand(UnitNum);
                  End;
                If _UnitCmd=CmdCastSpell then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitCastSpelling(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitAttackingSpeed(UnitNum));
          End
        Else
          Begin
            //If _UnitFrame=FrameUnUsed then _UnitFrame:=0;
            If _UnitFrame<UnitAnimations[_UnitTyper].AttackScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].AttackScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
                //If this frame to hit, hit unit ?
                If UnitAnimations[_UnitTyper].AttackScript.
                   Script[_UnitHeading,_UnitFrame].FrameStyle and FrameHit=FrameHit then
                  Begin
                    SetUnitSpell(UnitNum);
                  End;
              End
            Else//Unit complete cast spell, wasted time ?
              Begin
                _UnitFrame:=0;
                If (_UnitTarget<>0) and 
                   (Units[_UnitTarget]._UnitHitPoint<=0) then
                  Begin
                    _UnitTarget:=0;
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        UnitResetCommand(UnitNum);
                  End
                Else
                  Begin
                    _UnitFrame:=FrameUnUsed;
                    //Get next unit command, if unit next command, why unit not has a wasted time ?
                    //Maybe error here
                    If Not UnitGetPrevCommand(UnitNum) then
                      If Not UnitGetNextCommand(UnitNum) then
                        Begin
                          //If cast spell command not a cycles, reset command before set unit to
                          //command wasted time
                          If CheckSpellAttribute(_UnitSpell,SpellHasACycles) then
                            //Back to castspell command ?
                            Begin
                              If CheckUseSpell(UnitNum,_UnitSpell)=ROk then _UnitCmd:=CmdCastSpell
                              Else UnitResetCommand(UnitNum);
                            End
                          Else UnitResetCommand(UnitNum);
                          //Reset wasted time count before set wasted time command because this not case unit can't
                          //find way, that unit wait for return combat, maybe must change with other command
                          _WastedTimeCount:=0;
                          UnitCommandWastedTime(UnitNum);
                        End;
                  End;
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitWastedTime(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            {If _UnitFrame=FrameUnUsed then
              Begin
                Inc(_WastedTimeCount);
                If _WastedTimeCount>=WastedTimeLimit then
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].WastedScript.Script[Heading,_UnitFrame].FrameWait);
              End
            Else}
            If _UnitFrame<UnitAnimations[_UnitTyper].WastedScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].WastedScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else
              Begin
                //Get next command first
                If _UnitNextCmd<>NoCmd then UnitGetNextCommand(UnitNum)
                //Get prev command if not has a next command, Yeah hooh !!!!
                Else UnitGetPrevCommand(UnitNum);
                //If _UnitCmd=CmdWasted then Inc(_WastedTimeCount);
                _UnitFrame:=FrameUnUsed;
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitDead(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            If _UnitFrame=FrameUnUsed then
              Begin
                TakeUnit(UnitNum);
                {$IfDef RandomUnitPosShift}
                Case _UnitPrevCmd of 
                  CmdPatrol,CmdMove,CmdFollow,CmdAttack,CmdAttackAt,CmdBuild,CmdCastSpell,
                  CmdHarvest,CmdReturnGold,CmdPutItem,CmdPickItem :
                    Begin
                      _ShiftPX:=_ShiftPX-Direction[_UnitHeading].X*
                                       (DefaultMapTileX-UnitAnimations[_UnitTyper].RunScript.
                                                        Script[_UnitHeading,_UnitPrevFrame].FrameShift);
                      _ShiftPY:=_ShiftPY-Direction[_UnitHeading].Y*
                                       (DefaultMapTileY-UnitAnimations[_UnitTyper].RunScript.
                                                        Script[_UnitHeading,_UnitPrevFrame].FrameShift);
                    End;
                End;
                {$EndIf}
                //Unit not dead animation ?
                If UnitAnimations[_UnitTyper].DeadScript.Leng[_UnitHeading]<=0 then
                  Begin
                    PickUnit(UnitNum,False);
                    SetUnitToUnused(UnitNum);
                    Exit;
                  End;
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].DeadScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else
            If _UnitFrame<UnitAnimations[_UnitTyper].DeadScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].DeadScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else
              Begin
                PickUnit(UnitNum,False);
                SetUnitToUnused(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitBuild(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                UnitCheckBuilding(UnitNum);
                If _UnitCmd=CmdBuild then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                //If unit can CmdAttack (too near target), set unit to attacking status
                UnitCheckBuilding(UnitNum);
                If _UnitCmd=CmdBuild then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitBuildWork(UnitNum : TUnitCount);
  Var Grouped   : Boolean;
      CostTime  : Integer;
      HitInc    : THitPoint;
      OldTarget : TUnitCount;
  Begin
    With MyScreen,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If Not IsBuildFrame then Exit;
        //Building work
        If Units[_UnitTarget]._UnitWait<UnitsProperty[Units[_UnitTarget]._UnitClan,
           Units[_UnitTarget]._UnitTyper].UnitTimeCost then
          Begin
            Inc(Units[_UnitTarget]._UnitWait);
            CostTime:=UnitsProperty[Units[_UnitTarget]._UnitClan,Units[_UnitTarget]._UnitTyper].UnitTimeCost;
            HitInc:=1+(UnitsProperty[Units[_UnitTarget]._UnitClan,Units[_UnitTarget]._UnitTyper].HitPoint div CostTime);
            If Units[_UnitTarget]._UnitHitPoint+HitInc<UnitsProperty[Units[_UnitTarget]._UnitClan,
               Units[_UnitTarget]._UnitTyper].HitPoint then Inc(Units[_UnitTarget]._UnitHitPoint,HitInc)
            Else Units[_UnitTarget]._UnitHitPoint:=UnitsProperty[Units[_UnitTarget]._UnitClan,Units[_UnitTarget]._UnitTyper].HitPoint;
          End
        Else
        //Build complete
          Begin
            //Must written like that because after unit target unload all
            // then _UnitTarget has been clear to zero !
            OldTarget:=_UnitTarget;
            SetUnitAttribute(_UnitTarget,UnitSelfControl,True);
            //That function must place before unit unload because when unload, unit target
            // maybe replace by zero, then I can't get number of unit target, heh ?
            Grouped:=Units[_UnitTarget]._UnitGroup and 128=128;
            Units[_UnitTarget]._UnitCmd:=NoCmd;
            //Recounting food gain
            IncreaseFoodLimit(Units[_UnitTarget]._UnitClan,0,
                              UnitsProperty[Units[_UnitTarget]._UnitClan,
                                            Units[_UnitTarget]._UnitTyper].FoodGain,0);
            //Decrease unit queue counting
            Dec(ClanInfo[Units[_UnitTarget]._UnitClan].
                         UnitInQueue[Units[_UnitTarget]._UnitTyper]);
            //Unload all unit carrier
            UnitUnLoadCarrier(_UnitTarget);
            //AI helper: Auto set rallypoint
            If AIData[_UnitClan].AIActive then
              Begin
                UnitCommandRallyPoint(OldTarget,AIData[_UnitClan].AIRallyPoint.X,
                                                AIData[_UnitClan].AIRallyPoint.Y);
              End;
            If Grouped then
              Begin
                GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                SetupGroupSelected(MaxGroup);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitHarvest(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                {$IfDef DontStopWhenHarvest}
                _WastedTimeCount:=0;
                {$EndIf}
                UnitCheckMining(UnitNum);
                If _UnitCmd=CmdHarvest then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                {$IfDef DontStopWhenHarvest}
                _WastedTimeCount:=0;
                {$EndIf}
                UnitCheckMining(UnitNum);
                If _UnitCmd=CmdHarvest then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitMining(UnitNum : TUnitCount);
  Var Grouped : Boolean;
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        //_UnitWait now is unit mining time counting
        If _UnitWait<UnitMiningTimeDefault then
          Begin
            Inc(_UnitWait);
          End
        Else
        If _UnitWait=UnitMiningTimeDefault then
          Begin
            Inc(_UnitWait);
            SetUnitHarvest(UnitNum);
          End
        Else
          Begin
            Grouped:=Units[_MineTarget]._UnitGroup and 128=128;
            If _ReturnGoldTarget<>0 then
              Begin
                //Unload unit at nearby tile with target return gold of unit
                If UnitUnLoad(_MineTarget,UnitNum,_ReturnGoldTarget) then
                  Begin
                    If Grouped then
                      Begin
                        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                        SetupGroupSelected(MaxGroup);
                      End;
                    UnitResetCommand(UnitNum);
                    //Current return gold target is destroyed
                    If Not UnitCommandReturnGold(UnitNum,_UnitClan) then
                      Begin
                        //Find new target
                        If UnitFindReturnGoldTarget(UnitNum) then
                          //Set return gold command, yeah !!!!!
                          UnitCommandReturnGold(UnitNum,_UnitClan);
                      End;
                    {$IfDef SwitchPeonType}
                    Case _UnitTyper of
                      Peon    : _UnitTyper:=PeonWithGold;
                      Peasant : _UnitTyper:=PeasantWithGold;
                    End;
                    {$EndIf}
                  End;
              End
            Else
              Begin
                //Unit unit at once
                If UnitUnLoad(_MineTarget,UnitNum) then
                  Begin
                    If Grouped then
                      Begin
                        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
                        SetupGroupSelected(MaxGroup);
                      End;
                    UnitResetCommand(UnitNum);
                    {$IfDef SwitchPeonType}
                    Case _UnitTyper of
                      Peon    : _UnitTyper:=PeonWithGold;
                      Peasant : _UnitTyper:=PeasantWithGold;
                    End;
                    {$EndIf}
                  End;
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitReturnGold(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                UnitCheckReturnGold(UnitNum);
                If _UnitCmd=CmdReturnGold then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                If UnitGetNextCommand(UnitNum) then Exit;
                //If unit can CmdAttack (too near target), set unit to attacking status
                UnitCheckReturnGold(UnitNum);
                If _UnitCmd=CmdReturnGold then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitPutItem(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitCheckPutItem(UnitNum);
                If (_UnitCmd=CmdPutItem) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                //If unit can CmdAttack (too near target), set unit to attacking status
                UnitCheckPutItem(UnitNum);
                If (_UnitCmd=CmdPutItem) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitPickItem(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitCheckPickUpItem(UnitNum);
                If (_UnitCmd=CmdPickItem) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                //If unit can CmdAttack (too near target), set unit to attacking status
                UnitCheckPickUpItem(UnitNum);
                If (_UnitCmd=CmdPickItem) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitLoadUnit(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitCheckLoadUnit(UnitNum);
                If (_UnitCmd=CmdLoadUnit) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                UnitCheckLoadUnit(UnitNum);
                If (_UnitCmd=CmdLoadUnit) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitUnLoadUnit(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitCheckUnLoadUnit(UnitNum);
                If (_UnitCmd=CmdUnLoadUnit) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                UnitCheckUnLoadUnit(UnitNum);
                If (_UnitCmd=CmdUnLoadUnit) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitGoTransport(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyUnits,MyWorld,Units[UnitNum] do
      Begin
        If _UnitWait>0 then
          Begin
            Dec(_UnitWait,RealUnitMovementSpeed(UnitNum));
          End
        Else
          Begin
            //Unit start moving
            If _UnitFrame=FrameUnUsed then
              Begin
                UnitCheckTransport(UnitNum);
                If (_UnitCmd=CmdGoTransport) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End
            Else//Next frame generation
            If _UnitFrame<UnitAnimations[_UnitTyper].RunScript.Leng[_UnitHeading]-1 then
              Begin
                Inc(_UnitFrame);
                Inc(_UnitWait,UnitAnimations[_UnitTyper].RunScript.
                             Script[_UnitHeading,_UnitFrame].FrameWait);
              End
            Else//End moving, continue unit process
              Begin
                UnitCheckTransport(UnitNum);
                If (_UnitCmd=CmdGoTransport) and
                   Not UnitGetNextCommand(UnitNum) then UnitFindPath(UnitNum);
              End;
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.UnitAction(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyWorld,MyUnits,Units[UnitNum] do
      Begin
        //Unit unused, quit
        If _UnitHitPoint<0 then Exit;
        //Unit alive
        If _UnitHitPoint>0 then
          Begin
          End;
        //I'm must checking here because maybe unit going to death in con-current
        //process and generation an error if I don't CmdStop while that thing occur
        If _UnitHitPoint<0 then Exit;
        //If this mana grow frame ?
        If IsManaGrowFrame and
           (UnitsProperty[_UnitClan,_UnitTyper].ManaGrow>0) then
          Begin
            If UnitsProperty[_UnitClan,_UnitTyper].ManaGrow+_UnitMana>UnitsProperty[_UnitClan,_UnitTyper].MaxMana then
              _UnitMana:=UnitsProperty[_UnitClan,_UnitTyper].MaxMana
            Else _UnitMana:=_UnitMana+UnitsProperty[_UnitClan,_UnitTyper].ManaGrow;
            //If unit on selected, update tool tip ?
            If _UnitGroup and 128=128 then UpdateToolTip:=True;
          End;
        //If this hitpoint grow frame ?
        If IsHitpointGrowFrame and
           (UnitsProperty[_UnitClan,_UnitTyper].HitPointGrow>0) then
          Begin
            If UnitsProperty[_UnitClan,_UnitTyper].HitPointGrow+_UnitHitPoint>
               UnitsProperty[_UnitClan,_UnitTyper].HitPoint then
              _UnitHitPoint:=UnitsProperty[_UnitClan,_UnitTyper].HitPoint
            Else _UnitHitPoint:=_UnitHitPoint+UnitsProperty[_UnitClan,_UnitTyper].HitPointGrow;
            //If unit on selected, update tool tip ?
            If _UnitGroup and 128=128 then UpdateToolTip:=True;
          End;
        //Process queue : traning units
        UnitProcessQueue(UnitNum);
        {$IfDef RandomUnitPosShift}
        If GameFrame mod 8=0 then
          If UnitTestBaseAttribute(UnitNum,UnitChangeShift) then
            Begin
              If (GameFrame div 8) mod 2=0 then Inc(_ShiftPY)
              Else Dec(_ShiftPY);
            End;{}
        {$EndIf}
        //Update unit view range (for sepecific unit has attribute like truesight-view invisible target)
        //UnitUpdateUnitView(UnitNum);
        //All command here must checked in draw unit method for fixed lost vision of unit
        //on this command occur
        Case _UnitCmd of
          //If unit no have specific command, I'm take unit to finding other work
          NoCmd                      : UnitFindTarget(UnitNum);
          //Unit in dead status
          CmdDead                    : UnitDead(UnitNum);
          //Unit in stoping
          CmdStop                    : UnitStop(UnitNum);
          //Unit in moving
          CmdMove                    : UnitMove(UnitNum);
          //Unit in following other
          CmdFollow                  : UnitFollow(UnitNum);
          //Unit in CmdPatrol
          CmdPatrol                  : UnitPatrol(UnitNum);
          //Unit in CmdAttack, I'm finding way to unit CmdAttack's target
          CmdAttack                  : UnitAttack(UnitNum);
          //Unit in CmdAttackAt
          CmdAttackAt                : UnitAttackAt(UnitNum);
          //Unit in attacking
          CmdAttacking               : UnitAttacking(UnitNum);
          //Unit in attacking in standing mode
          CmdAttackingStand          : UnitAttackingStand(UnitNum);
          //
          CmdCastSpell               : UnitCastSpell(UnitNum);
          //
          CmdCastSpelling            : UnitCastSpelling(UnitNum);
          //Go to gold mine
          CmdHarvest                 : UnitHarvest(UnitNum);
          //Unit mining on target
          CmdMining                  : UnitMining(UnitNum);
          //Unit return gold to town
          CmdReturnGold              : UnitReturnGold(UnitNum);
          //Unit put unit to specific land or other unit
          CmdPutItem                 : UnitPutItem(UnitNum);
          //Unit pick item from specific unit on map
          CmdPickItem                : UnitPickItem(UnitNum);
          //Unit go to load unit
          CmdLoadUnit                : UnitLoadUnit(UnitNum);
          //Unit go to unload unit
          CmdUnLoadUnit              : UnitUnLoadUnit(UnitNum);
          //Unit go to transport unit
          CmdGoTransport             : UnitGoTransport(UnitNum);
          //Unit hold position ?
          CmdHoldPosition            : UnitHoldPosition(UnitNum);
          //Unit wasted time
          CmdWasted                  : UnitWastedTime(UnitNum);
          //Unit going building
          CmdBuild                   : UnitBuild(UnitNum);
          CmdBuildWork               : UnitBuildWork(UnitNum);
        End;
      End;
  End;
  
PROCEDURE TLOCUnitProcess.UnitIdleAction(UnitNum : TUnitCount);
  Begin
    With MyScreen,MyDraw,MyWorld,MyUnits,Units[UnitNum] do
      Begin
        //Unit unused, quit
        If _UnitHitPoint<0 then Exit;
        //Unit alive
        If _UnitHitPoint>0 then
          Begin
          End;
        //I'm must checking here because maybe unit going to death in con-current
        //process and generation an error if I don't CmdStop while that thing occur
        If _UnitHitPoint<0 then Exit;
        //If this mana grow frame ?
        If IsManaGrowFrame and
           (UnitsProperty[_UnitClan,_UnitTyper].ManaGrow>0) then
          Begin
            If UnitsProperty[_UnitClan,_UnitTyper].ManaGrow+_UnitMana>UnitsProperty[_UnitClan,_UnitTyper].MaxMana then
              _UnitMana:=UnitsProperty[_UnitClan,_UnitTyper].MaxMana
            Else _UnitMana:=_UnitMana+UnitsProperty[_UnitClan,_UnitTyper].ManaGrow;
            //If unit on selected, update tool tip ?
            If _UnitGroup and 128=128 then UpdateToolTip:=True;
          End;
        //If this hitpoint grow frame ?
        If IsHitpointGrowFrame and
           (UnitsProperty[_UnitClan,_UnitTyper].HitPointGrow>0) then
          Begin
            If UnitsProperty[_UnitClan,_UnitTyper].HitPointGrow+_UnitHitPoint>
               UnitsProperty[_UnitClan,_UnitTyper].HitPoint then
              _UnitHitPoint:=UnitsProperty[_UnitClan,_UnitTyper].HitPoint
            Else _UnitHitPoint:=_UnitHitPoint+UnitsProperty[_UnitClan,_UnitTyper].HitPointGrow;
            //If unit on selected, update tool tip ?
            If _UnitGroup and 128=128 then UpdateToolTip:=True;
          End;
        //Process queue : traning units
        UnitProcessQueue(UnitNum);
        {$IfDef RandomUnitPosShift}
        If GameFrame mod 8=0 then
          If UnitTestBaseAttribute(UnitNum,UnitChangeShift) then
            Begin
              If (GameFrame div 8) mod 2=0 then Inc(_ShiftPY)
              Else Dec(_ShiftPY);
            End;{}
        {$EndIf}
        UnitIdle(UnitNum);
      End;
  End;

PROCEDURE TLOCUnitProcess.SelectUnitOnMapPointClick(X,Y,XS,YS : FastInt;AddUnit,Clear : Boolean);
  Var I,J,RX1,RY1,RX2,RY2             : FastInt;
      UnitNum,UnitNumSaved            : TUnitCount;
      DrawLevelMax,MyUnitDrawLevelMax : TDrawLevel;
      TempGroup                       : TGroup;
      FoundMyUnit,Changes             : Boolean;
      GeneralClan                     : TClan;
  Begin
    With MyScreen,MyUnits,MyWorld,MyDraw do
      Begin
        If AddUnit then TempGroup:=SaveGroups[MaxGroup]
        Else FillChar(TempGroup,SizeOf(TempGroup),0);
        RX1:=X;RX2:=X;RY1:=Y;RY2:=Y;
        If GetTileAttr(X,Y,MapDontVisible) then Exit;
        If RX1>MaxUnitSizeX then Dec(RX1,MaxUnitSizeX) Else RX1:=0;
        If RY1>MaxUnitSizeX then Dec(RY1,MaxUnitSizeY) Else RY1:=0;
        If RX2<MapSizeX-1 then Inc(RX2);
        If RY2<MapSizeY-1 then Inc(RY2);
        FoundMyUnit:=False;
        Changes:=False;
        GeneralClan:=Gaia;
        If AddUnit then
          For I:=Low(TempGroup) to High(TempGroup) do
            If TempGroup[I]<>0 then
              Begin
                GeneralClan:=Units[TempGroup[I]]._UnitClan;
                FoundMyUnit:=True;
                Break;
              End;
        DrawLevelMax:=Low(TDrawLevel);
        MyUnitDrawLevelMax:=Low(TDrawLevel);
        If FoundMyUnit=False then
          Begin
            For I:=RX1 to RX2 do
              Begin
                For J:=RY1 to RY2 do
                  Begin
                    UnitNum:=MapNum[I,J];
                    While UnitNum<>0 do
                      With Units[UnitNum] do
                        Begin
                          If CanSeeThisUnit(HumanControl,UnitNum) then
                            Begin
                              If (_UnitHitPoint>0) and
                                 UnitCheckedPoint(UnitNum,XS,YS,X,Y) then
                                Begin
                                  If GeneralClan=Gaia then
                                    GeneralClan:=Units[UnitNum]._UnitClan;
                                  If UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel>DrawLevelMax then
                                    DrawLevelMax:=UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel;
                                  If Units[UnitNum]._UnitClan=HumanControl then
                                    Begin
                                      FoundMyUnit:=True;
                                      If UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel>MyUnitDrawLevelMax then
                                        MyUnitDrawLevelMax:=UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel;
                                    End;
                                End;
                            End;
                          UnitNum:=Units[UnitNum]._UnitNext;
                        End;
                  End;
                  //If FoundMyUnit then Break;
                End;
            If FoundMyUnit then
              Begin
                GeneralClan:=HumanControl;
                DrawLevelMax:=MyUnitDrawLevelMax;
              End;
          End;
        UnitNumSaved:=0;
        For I:=RX1 to RX2 do
          For J:=RY1 to RY2 do
            Begin
              UnitNum:=MapNum[I,J];
              While UnitNum<>0 do
                With Units[UnitNum] do
                  Begin
                    If CanSeeThisUnit(HumanControl,UnitNum) then
                      Begin
                        If UnitCheckedPoint(UnitNum,XS,YS,X,Y) and
                           UnitCanAddToGroup(UnitNum,GeneralClan,TempGroup,False) then
                          Begin
                            If UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel>=DrawLevelMax then
                              Begin
                                UnitNumSaved:=UnitNum;
                                DrawLevelMax:=UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel;
                              End;
                          End;
                      End;
                    UnitNum:=_UnitNext;
                  End;
            End;
        If UnitNumSaved>0 then
          Begin
            Changes:=True;
            If Clear then
              Begin
                //Unit already grouped, clear unit from group
                If Units[UnitNumSaved]._UnitGroup and 128=128 then
                  ClearUnitInGroup(UnitNumSaved,TempGroup)
                Else
                  Begin
                    If UnitCanAddToGroup(UnitNumSaved,GeneralClan,TempGroup) then
                      AddUnitToGroup(UnitNumSaved,TempGroup);
                  End;
              End
            Else
              Begin
                If UnitCanAddToGroup(UnitNumSaved,GeneralClan,TempGroup) then
                  AddUnitToGroup(UnitNumSaved,TempGroup);
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
           (Clear and (UnitFocus=UnitNumSaved)) then
          UnitFocus:=SaveGroups[MaxGroup][Low(TUnitSelectionCount)];
      End;
  End;

FUNCTION  TLOCUnitProcess.GetUnitOnMapPointClick(X,Y,XS,YS : FastInt) : TUnitCount;
  Var I,J,RX1,RY1,RX2,RY2  : FastInt;
      UnitNum,UnitNumSaved : TUnitCount;
      DrawLevelMax         : TDrawLevel;
  Begin
    With MyScreen,MyUnits,MyWorld,MyDraw do
      Begin
        RX1:=X;RX2:=X;RY1:=Y;RY2:=Y;
        If RX1>MaxUnitSizeX then Dec(RX1,MaxUnitSizeX) Else RX1:=0;
        If RY1>MaxUnitSizeX then Dec(RY1,MaxUnitSizeY) Else RY1:=0;
        If RX2<MapSizeX-1 then Inc(RX2);
        If RY2<MapSizeY-1 then Inc(RY2);
        DrawLevelMax:=Low(TDrawLevel);
        UnitNumSaved:=0;
        For I:=RX1 to RX2 do
          For J:=RY1 to RY2 do
            Begin
              UnitNum:=MapNum[I,J];
              While UnitNum<>0 do
                With Units[UnitNum] do
                  Begin
                    If CanSeeThisUnit(HumanControl,UnitNum) then
                      Begin
                        If (_UnitHitPoint>0) and
                           UnitCheckedPoint(UnitNum,XS,YS,X,Y) then
                          Begin
                            If (UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel>=DrawLevelMax) or
                               (UnitNumSaved=0) then
                              Begin
                                UnitNumSaved:=UnitNum;
                                DrawLevelMax:=UnitsProperty[_UnitClan,_UnitTyper].UnitDrawLevel;
                              End;
                          End;
                      End;
                    UnitNum:=_UnitNext;
                  End;
            End;
        Result:=UnitNumSaved;
      End;
  End;

PROCEDURE TLOCUnitProcess.SelectUnitClick(AddUnit : Boolean);
  Var MX1,MX2,MY1,MY2 : FastInt;
  Begin
    With MyScreen,MyUnits,MyWorld do
      Begin
        MX1:=SelectStart.X-ViewPosXOS;
        MY1:=SelectStart.Y-ViewPosYOS;
        MX1:=MX1 div DefaultMapTileX;
        MY1:=MY1 div DefaultMapTileY;
        MX2:=SelectStart.X-ViewPosXOS-MX1*DefaultMapTileX;
        MY2:=SelectStart.Y-ViewPosYOS-MY1*DefaultMapTileY;
        SelectUnitOnMapPointClick(MX1+MapViewX,MY1+MapViewY,MX2,MY2,AddUnit,False);
        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
        SetupGroupSelected(MaxGroup);
      End;
  End;

PROCEDURE TLOCUnitProcess.UnSelectUnitClick(AddUnit : Boolean);
  Var MX1,MX2,MY1,MY2 : FastInt;
  Begin
    With MyScreen,MyUnits,MyWorld do
      Begin
        MX1:=SelectStart.X-ViewPosXOS;
        MY1:=SelectStart.Y-ViewPosYOS;
        MX1:=MX1 div DefaultMapTileX;
        MY1:=MY1 div DefaultMapTileY;
        MX2:=SelectStart.X-ViewPosXOS-MX1*DefaultMapTileX;
        MY2:=SelectStart.Y-ViewPosYOS-MY1*DefaultMapTileY;
        SelectUnitOnMapPointClick(MX1+MapViewX,MY1+MapViewY,MX2,MY2,True,True);
        GetGroupSkill(CurrentSkillButton,MaxGroup,HumanControl,True);
        SetupGroupSelected(MaxGroup);
      End;
  End;

FUNCTION  TLOCUnitProcess.CheckMissileHit(MissileNum : TMissileCount) : Boolean;
  Var I,J,UX,UY,X,Y,RX1,RY1,RX2,RY2 : FastInt;
      UnitNum                       : TUnitCount;
  Begin
    Result:=True;
    With MyUnits,MyWorld,Missiles[MissileNum] do
      Begin
        //Missile can not hit other unit when flying ?
        If Not CheckMissileAttribute(Typer,MissileDamageOnFly) then
          Begin
            Result:=False;
            Exit;
          End;
        X:=MisPos.X div DefaultMapTileX;
        Y:=MisPos.Y div DefaultMapTileY;
        RX1:=X;RX2:=X;
        RY1:=Y;RY2:=Y;
        If RX1>MaxUnitSizeX then Dec(RX1,MaxUnitSizeX) Else RX1:=0;
        If RY1>MaxUnitSizeY then Dec(RY1,MaxUnitSizeY) Else RY1:=0;
        If (X<0) or (X>=MapSizeX) or
           (Y<0) or (Y>=MapSizeY) then Exit;
        For I:=RX1 to RX2 do
          Begin
            For J:=RY1 to RY2 do
              Begin
                UnitNum:=MapNum[I,J];
                While UnitNum<>0 do
                  With Units[UnitNum] do
                    Begin
                      //Missile can't damage owner and not damaged for died unit ?
                      //Not damaged for invulnerable target, of course
                      If (UnitNum<>FromUnit) and
                         (Not (UnitInvulnerable in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute)) and
                         (_UnitHitPoint>0) then
                        Begin
                          UX:=Units[UnitNum]._UnitPos.X+UnitsProperty[Units[UnitNum]._UnitClan,Units[UnitNum]._UnitTyper].UnitSizeX;
                          UY:=Units[UnitNum]._UnitPos.Y+UnitsProperty[Units[UnitNum]._UnitClan,Units[UnitNum]._UnitTyper].UnitSizeY;
                          If (UX>=X) and (UY>=Y) then
                            Begin
                              If ClanInfo[MisClan].Diplomacy[_UnitClan]=Enemy then
                                Begin
                                  Target:=UnitNum;
                                  Exit;
                                End
                              Else
                              If CheckMissileAttribute(Typer,MissileDamageFriendly) then
                                Begin
                                  Target:=UnitNum;
                                  Exit;
                                End;
                            End;
                        End;
                      UnitNum:=_UnitNext;
                    End;
              End;
          End;
      End;
    Result:=False;
  End;

FUNCTION  TLOCUnitProcess.CheckMissileExpHit(MissileNum : TMissileCount) : Boolean;
  Var I,J,UX,UY,X,Y,RX1,RY1,RX2,RY2 : FastInt;
      UnitNum                       : TUnitCount;
  Begin
    Result:=True;
    With MyUnits,MyWorld,Missiles[MissileNum] do
      Begin
        //Missile can not hit other unit when explosion ?
        If Not CheckMissileAttribute(Typer,MissileDamageOnExplosion) then
          Begin
            Result:=False;
            Exit;
          End;
        X:=MisPos.X div DefaultMapTileX;
        Y:=MisPos.Y div DefaultMapTileY;
        RX1:=X;RX2:=X;
        RY1:=Y;RY2:=Y;
        If RX1>MaxUnitSizeX then Dec(RX1,MaxUnitSizeX) Else RX1:=0;
        If RY1>MaxUnitSizeY then Dec(RY1,MaxUnitSizeY) Else RY1:=0;
        If (X<0) or (X>=MapSizeX) or
           (Y<0) or (Y>=MapSizeY) then Exit;
        For I:=RX1 to RX2 do
          Begin
            For J:=RY1 to RY2 do
              Begin
                UnitNum:=MapNum[I,J];
                While UnitNum<>0 do
                  With Units[UnitNum] do
                    Begin
                      //Missile can't damage owner and not damaged for died unit ?
                      //Not damaged for invulnerable target, of course
                      If (UnitNum<>FromUnit) and
                         (Not (UnitInvulnerable in UnitsProperty[_UnitClan,_UnitTyper].BaseAttribute)) and
                         (_UnitHitPoint>0) then
                        Begin
                          UX:=Units[UnitNum]._UnitPos.X+UnitsProperty[Units[UnitNum]._UnitClan,Units[UnitNum]._UnitTyper].UnitSizeX;
                          UY:=Units[UnitNum]._UnitPos.Y+UnitsProperty[Units[UnitNum]._UnitClan,Units[UnitNum]._UnitTyper].UnitSizeY;
                          If (UX>=X) and (UY>=Y) then
                            Begin
                              //Target is enemy or neural ?
                              If ClanInfo[MisClan].Diplomacy[_UnitClan]<>Ally then
                                Begin
                                  Target:=UnitNum;
                                  Exit;
                                End
                              Else
                              If CheckMissileAttribute(Typer,MissileDamageFriendly) then
                                Begin
                                  Target:=UnitNum;
                                  Exit;
                                End;
                            End;
                        End;
                      UnitNum:=_UnitNext;
                    End;
              End;
          End;
      End;
    Result:=False;
  End;

PROCEDURE TLOCUnitProcess.MissileFlying(MissileNum : TMissileCount);
  Var Count : Integer;
  Begin
    With MyUnits,Missiles[MissileNum] do
      Begin
        If WaitTime<0 then
          Begin
            Frame:=0;
            WaitTime:=MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameWait;
            {$IfDef MissileExplosionWhenFlying}
            If MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameStyle and
               FrameHit=FrameHit then
              Begin
                WaitTime:=-1;
                MisState:=Explosion;
                Exit;
              End;
            {$EndIf}
          End
        Else
        If WaitTime=0 then
          Begin
            For Count:=0 to MissileProperty[Typer].MissileSpeed do
              Begin
                If DX=0 then
                  Begin
                    MisPos.Y:=MisPos.Y+DYS;
                  End
                Else
                If DY=0 then
                  Begin
                    MisPos.X:=MisPos.X+DXS;
                  End
                Else
                If DX<DY then
                  Begin
                    MisPos.Y:=MisPos.Y+DYS;
                    Step:=Step-DX;
                    If Step<0 then
                      Begin
                        Step:=Step+DY;
                        MisPos.X:=MisPos.X+DXS;
                      End;
                  End
                Else
                If DX>DY then
                  Begin
                    MisPos.X:=MisPos.X+DXS;
                    Step:=Step-DY;
                    If Step<0 then
                      Begin
                        Step:=Step+DX;
                        MisPos.Y:=MisPos.Y+DYS;
                      End;
                  End
                Else
                  Begin
                    MisPos.X:=MisPos.X+DXS;
                    MisPos.Y:=MisPos.Y+DYS;
                  End;
                If CheckMissileHit(MissileNum) then
                  Begin
                    If MissileProperty[Typer].MissileAttribute and
                       MissileStillFlyBeforeHit=MissileStillFlyBeforeHit then
                      Begin
                        MissileHit(MissileNum);
                      End
                    Else
                      Begin
                        WaitTime:=-1;
                        MisState:=Explosion;
                        Exit;
                      End;
                  End;
                If (Abs(MisPos.X-MisDest.X)<=DefaultBaseMissileSpeed) and
                   (Abs(MisPos.Y-MisDest.Y)<=DefaultBaseMissileSpeed) then
                  Begin
                    WaitTime:=-1;
                    MisState:=Explosion;
                    Exit;
                  End;
              End;
            Case Typer of
              MissileFireBall :
                Begin
                  If Frame=MyDraw.MissileAnimations[Typer].FlyingScript.FrameLeng[Head]-1 then
                    NewRealMissile(MisPos.X,MisPos.Y,MisPos.X,MisPos.Y,MissileExplode);
                End;
            End;
            If Frame<MyDraw.MissileAnimations[Typer].FlyingScript.FrameLeng[Head]-1 then
              Begin
                Inc(Frame);
                {$IfDef MissileExplosionWhenFlying}
                If MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameStyle and
                   FrameHit=FrameHit then
                  Begin
                    WaitTime:=-1;
                    MisState:=Explosion;
                    Exit;
                  End;
                {$EndIf}
              End
            Else Frame:=0;
            WaitTime:=MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameWait;
          End
        Else
          Begin
            Dec(WaitTime);
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.MissileStand(MissileNum : TMissileCount);
  Begin
    With MyUnits,Missiles[MissileNum] do
      Begin
        If WaitTime<0 then
          Begin
            Frame:=0;
            WaitTime:=MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameWait;
            {$IfDef MissileExplosionWhenFlying}
            If MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameStyle and
               FrameHit=FrameHit then
              Begin
                WaitTime:=-1;
                MisState:=Explosion;
                Exit;
              End;
            {$EndIf}
          End
        Else
        If WaitTime=0 then
          Begin
            If Frame<MyDraw.MissileAnimations[Typer].FlyingScript.FrameLeng[Head]-1 then
              Begin
                Inc(Frame);
                {$IfDef MissileExplosionWhenFlying}
                If MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameStyle and
                   FrameHit=FrameHit then
                  Begin
                    WaitTime:=-1;
                    MisState:=Explosion;
                    Exit;
                  End;
                {$EndIf}
              End
            Else
              Begin
                Frame:=0;
              End;
            WaitTime:=MyDraw.MissileAnimations[Typer].FlyingScript.FramePos[Head,Frame].FrameWait;
          End
        Else
          Begin
            Dec(WaitTime);
          End;
      End;
  End;

PROCEDURE TLOCUnitProcess.MissileExplosion(MissileNum : TMissileCount);
  Begin
    With MyUnits,Missiles[MissileNum] do
      Begin
        If WaitTime=-1 then
          Begin
            Frame:=0;
            WaitTime:=MyDraw.MissileAnimations[Typer].ExplosionScript.FramePos[Head,Frame].FrameWait;
            If MyDraw.MissileAnimations[Typer].ExplosionScript.FramePos[Head,Frame].FrameStyle and
               FrameHit=FrameHit then
              Begin
                If Target=0 then
                  Begin
                    If CheckMissileExpHit(MissileNum) then
                      MissileHit(MissileNum);
                  End
                Else MissileHit(MissileNum);
              End;
          End
        Else
        If WaitTime=0 then
          Begin
            If Frame<MyDraw.MissileAnimations[Typer].ExplosionScript.FrameLeng[Head]-1 then
              Begin
                Inc(Frame);
                If MyDraw.MissileAnimations[Typer].ExplosionScript.FramePos[Head,Frame].FrameStyle and
                   FrameHit=FrameHit then
                  Begin
                    If Target=0 then
                      Begin
                        If CheckMissileExpHit(MissileNum) then
                          MissileHit(MissileNum);
                      End
                    Else MissileHit(MissileNum);
                  End;
                WaitTime:=MyDraw.MissileAnimations[Typer].ExplosionScript.FramePos[Head,Frame].FrameWait;
              End
            Else
              Begin
                Frame:=0;
                ClearMissile(MissileNum);
              End;
          End
        Else Dec(WaitTime);
      End;
  End;

PROCEDURE TLOCUnitProcess.MissileAction(MissileNum : TMissileCount);
  Begin
    With MyUnits,Missiles[MissileNum] do
      Begin
        //Typer = MNone, missile unused !
        If Typer=MissileNone then Exit;
        Case MisState of
          Flying :
            Begin
              If MissileProperty[Typer].MissileAttribute and
                 MissilePointTo=MissilePointTo then MissileFlying(MissileNum)
              Else MissileStand(MissileNum);
            End;
          Explosion :
            Begin
              MissileExplosion(MissileNum);
            End;
        End;
      End;
  End;
  
PROCEDURE TLOCUnitProcess.EffectActionHeroSignFlash(EffectNum : TEffectedCount);
  Begin
    With MyUnits,Effects[EffectNum] do
      Begin
        If (TransLevel<=MinTransparent) or
           (TransLevel>=MaxTransparent) then
          TransIncrease:=-TransIncrease;
        TransLevel:=TransLevel+TransIncrease;
      End;
  End;

PROCEDURE TLOCUnitProcess.EffectActionHeroSignFlashRotate(EffectNum : TEffectedCount);
  Begin
    With MyUnits,Effects[EffectNum] do
      Begin
        If Angle<255 then Inc(Angle) Else Angle:=0;
        If (TransLevel<=032) or
           (TransLevel>=252) then
          TransIncrease:=-TransIncrease;
        TransLevel:=TransLevel+TransIncrease;
      End;
  End;

PROCEDURE TLOCUnitProcess.EffectAction(EffectNum : TEffectedCount);
  Begin
    With MyUnits,Effects[EffectNum] do
      Begin
        If Typer=NoEffected then Exit;
        If TimeCountDown>EffectNotEffective then
          Begin
            Dec(TimeCountDown);
          End
        Else
        If TimeCountDown=EffectNotEffective then
          Begin
            DisposeEffect(EffectNum);
            ClearEffect(EffectNum);
            Exit;
          End;
        Case EffectProperty[Typer].EffectKind of
          EffectKindHeroSignFlash :
            EffectActionHeroSignFlash(EffectNum);
          EffectKindHeroSignFlashRotate :
            EffectActionHeroSignFlashRotate(EffectNum);
        End;
      End;
  End;
END.
