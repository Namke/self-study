USES SysUtils,MMSystem,AvenusBase,AvenusMedia,DirectInput8;
{$AppType GUI}
{ $Define VideoEx}
CONST
  ScrW = 800;
  ScrH = 600;

VAR
  Screen               : TAvenus;
  Buffer               : TAvenusBuffer;
  Input                : TAvenusInput;
  FinishGame           : Boolean;
  {$IfDef VideoEx}
  Video                : TVideoEx64;
  {$Else}
  Video                : TVideo64;
  {$EndIf}
  Time,TimeStart,Frame : Cardinal;
  Count                : SmallInt;

BEGIN
  Screen:=TSelfFullAvenus.Create(ScrW,ScrH,32,'Crazy babe');
  Buffer:=TAvenusBuffer.Create(Screen,ScrW,ScrH,False);
  Buffer.SetClipWindow(0,0,Buffer.XMax,Buffer.YMax);
  Input:=TAvenusInput.Create(Screen.Handle);
  {$IfDef VideoEx}
  Video:=TVideoEx64.Create(Screen,'D:\VIDEO\KillerBean\KB2.avi',True,False);
  {$Else}
  //Video:=TVideo64.Create(Screen,'D:\TEMP\SNAG-0001.avi',True);
  Video:=TVideo64.Create(Screen,'D:\VIDEO\KillerBean\KB2.avi',True);
  {$EndIf}
  Buffer.Flip(False);
  FinishGame:=False;
  TimeStart:=MMSystem.TimeGetTime;
  Time:=TimeStart;
  Buffer.ChangeFont('Times.Ttf',20);
  Frame:=0;
  Video.Play;
  //If Video.Audio then
  Repeat
    Video.UpdateFrame;
    Video.Frame.Draw(0,80);
    //Video.Frame.Flip(False);
    If Input.KeyDown(K_Escape) then FinishGame:=True;
  Until FinishGame or (Screen.DoEvents=False);
  Video.Free;
  Input.Free;
  Buffer.Free;
  Screen.Free;
END.


