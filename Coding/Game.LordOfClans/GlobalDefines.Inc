///                     Warcraft new generation : The book of shadow                        \\\

//Show more information for debuging. Ex: Framerate, unit count...
{$Define Debug}

//Debug a script runtime ?
{$Define DebugScript}

//Define for show AI debuging (Message, target, status etc...)
//{$Define DebugAI}

//Written safest coding !
{$Define SafeCode}

//On screen when start game
//{$Define TestOnScreen}

//All is your unit ?
//{$Define AllIsOwnUnit}

{$Define TestOneUnit}

//Load little of unit for fastest testing
//{$Define LoadLittle}

//Define for random ability (for tested)
//{$Define RandomAbility}

//Define for show only skill all unit in group can be use
//{$Define ShowGlobalGroupSkill}

//
{$Define RandomUnitPosShift}

//Show window cursor
{$Define WinCursor}

//
//{$Define AutoCropImageOnLoading}

//Check number of unit in on tile
{$Define LimitAirUnitOnTile}

//{$Define OldMapPickUp}

//For check time limit on findpath method
{$Define FindPathCheckTime}

//Process per time
//{$Define ProcessPerTime}

//{$Define SafeClearCloseSet}
{$Define DeadUnitCanSeeUnderFog}

//Lock and Unlock texture before access !
{$Define SafeLockAndUnLockTexture}

//Saved all map num and map count >> don't update put unit when loading saved file
//{$Define SavedMapNum}

//For clipping object
{$Define FullClip}

//Don't try to finding poor way !
{$Define NoFindingPoorWay}

//Define for no use InGoal in path search method
{$Define NoInGoal}

{$Define NoIndex}

{$Define NoCheck}

{$Define ApplyLightning}

//  When unit changes position, I'm check all unit in unit's range and tick that "Alert ! Now you have a
//target" by UnitHasATarget attribute, and when unit still or unit patrol, if unit have that attribute,
//I take unit to find target, that a simple way for reduce times of finding target of unit , he he..
//That error when unit complete attack at unit !
//{$Define AttackWhenAlert}

//Clear all unit target point to UnitNum when unit set to die
//That safe code but take a rich moment of time ! Maybe I'm changing that method in future !
{$Define SafeClearTargetWhenUnitDied}

//Switch peon to peonwithgold while unit has a resource ?
{$Define SwitchPeonType}

//When lost pathfinding and unit nearby patrol target, unit can restart patrol command
{$Define ResetPatrolWhenNotPath}

//AI player place they building with fixed distance
{$Define PlaceFixedDistance}

//Unit no stop when can't reach the path for harvest
//{$Define DontStopWhenHarvest}

//Show water ?
//{$Define ShowWater}

//Shown tooltip as fade table
//{$Define ToolTipFade}

//Missile maybe explosion when flying by FrameStyle has FrameHit
{$Define MissileExplosionWhenFlying}

//Missile owner effect
{$Define MissileEffectItSelf}

//Support light of sight ?
//{$Define LightOfSight}

//Full loging ?
{$Define FullLog}

//Loading from database file
{$Define LoadOnDataBase}

//Command directive for compiling
//New insert button method while play game, error !
//{$Define NewInsertButton}

//New insert button method for editor compatiable
{$Define NewInsertButtonEditor}
