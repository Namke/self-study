USES SysUtils,MMSystem,AvenusBase,AvenusMedia,DirectInput8;
{$AppType GUI}
{ $Define VideoEx}
CONST
  SizeX  = 176;
  SizeY  = 176;
  FrameX = 5;
  ScrW   = SizeX;
  ScrH   = SizeY*FrameX;
  St     = 'GC9\BattleShip';

VAR
  Screen               : TAvenus;
  Buffer               : TAvenusBuffer;
  Img                  : TAvenusBuffer;
  Input                : TAvenusInput;
  I,J            : Integer;

BEGIN
  Screen:=TSelfAvenus.Create(320,200,'Crazy babe');
  Buffer:=TAvenusBuffer.Create(Screen,ScrW,ScrH,False);
  Buffer.SetClipWindow(0,0,Buffer.XMax,Buffer.YMax);
  Input:=TAvenusInput.Create(Screen.Handle);
  For I:=1 to FrameX do
    Begin
      If I<10 then Img:=TAvenusImage.Create(Screen,Format(St+'0%d.Bmp',[I-1]),False)
      Else Img:=TAvenusImage.Create(Screen,Format(St+'%d.Bmp',[I-1]),False);
      Img.Copy(Buffer,0,(I-1)*SizeY);
      Img.Free;
    End;
  Buffer.SaveImage('_1_.Png');
  Input.Free;
  Buffer.Free;
  Screen.Free;
END.
