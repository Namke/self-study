USES SysUtils,MMSystem,AvenusBase,AvenusMedia,DirectInput8;
{$AppType GUI}
{$Define OneRow}
CONST
  SizeX    = 128;
  SizeY    = 128;
  FrameX   = 5;
  FrameY   = 6;
  FrameDie = 0;
  {$IfDef OneRow}
  ScrW     = SizeX;
  ScrH     = SizeY*(FrameY*FrameX+FrameDie);
  {$Else}
  {$EndIf}
  DirName  = 'DragonMage';
  FileName = 'DragonMage';

VAR
  Screen         : TAvenus;
  Buffer         : TAvenusBuffer;
  //Img          : Array[1..10,1..10] of TAvenusBuffer;
  Img            : TAvenusBuffer;
  Input          : TAvenusInput;
  Count,I,J      : Integer;

FUNCTION  Name(I,J : Integer) : String;
  Begin
    If J<10 then Result:=Format(DirName+'\H%d\'+FileName+'0%d.Bmp',[I,J])
    Else Result:=Format(DirName+'\H%d\'+FileName+'%d.Bmp',[I,J]);
  End;

FUNCTION  NameDie(I : Integer) : String;
  Begin
    If I<10 then Result:=Format(DirName+'\Die\'+FileName+'0%d.Bmp',[I])
    Else Result:=Format(DirName+'\Die\'+FileName+'%d.Bmp',[I]);
  End;

BEGIN
  //Screen:=TSelfFullAvenus.Create(ScrW,ScrH,32,'Crazy babe');
  Screen:=TSelfAvenus.Create(320,200,'Crazy babe');
  Buffer:=TAvenusBuffer.Create(Screen,ScrW,ScrH,False);
  Buffer.SetClipWindow(0,0,Buffer.XMax,Buffer.YMax);
  Input:=TAvenusInput.Create(Screen.Handle);
  Count:=0;
  For J:=1 to FrameY do
    For I:=1 to FrameX do
      Begin
        Img:=TAvenusImage.Create(Screen,Name(I,J-1),False);
        {$IfDef OneRow}
        Img.Copy(Buffer,0,Count*SizeY);
        {$Else}
        Img.Copy(Buffer,(I-1)*SizeX,(J-1)*SizeY);
        {$EndIf}
        Inc(Count);
        Img.Free;
      End;
  For I:=1 to FrameDie do
    Begin
      Img:=TAvenusImage.Create(Screen,NameDie(I-1),False);
      Img.Copy(Buffer,0,Count*SizeY);
      Inc(Count);
      Img.Free;
    End;
  Buffer.SaveImage('_1_.Png');
  Input.Free;
  Buffer.Free;
  Screen.Free;
END.
