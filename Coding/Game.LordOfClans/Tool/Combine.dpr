USES SysUtils,MMSystem,AvenusBase,AvenusMedia,DirectInput8;
{$AppType GUI}
{ $Define VideoEx}
CONST
  SizeX  = 128;
  SizeY  = 128;
  FrameX = 5;
  FrameY = 7;
  ScrW   = SizeX*FrameX;
  ScrH   = SizeY*FrameY;

VAR
  Screen               : TAvenus;
  Buffer               : TAvenusBuffer;
  //Img                  : Array[1..10,1..10] of TAvenusBuffer;
  Img                  : TAvenusBuffer;
  Input                : TAvenusInput;
  I,J            : Integer;

BEGIN
  //Screen:=TSelfFullAvenus.Create(ScrW,ScrH,32,'Crazy babe');
  Screen:=TSelfAvenus.Create(ScrW,ScrH,'Crazy babe');
  Buffer:=TAvenusBuffer.Create(Screen,ScrW,ScrH,False);
  Buffer.SetClipWindow(0,0,Buffer.XMax,Buffer.YMax);
  Input:=TAvenusInput.Create(Screen.Handle);
  For I:=1 to FrameX do
    For J:=1 to FrameY do
      Begin
        {Img[I,J]:=TAvenusImage.Create(Screen,Format('DragonRide\H%d\DragonRide%d.Bmp',[I,J-1]),False);
        Img[I,J].Copy(Buffer,(I-1)*SizeX,(J-1)*SizeY);}
        Img:=TAvenusImage.Create(Screen,Format('DragonRide\H%d\DragonRide%d.Bmp',[I,J-1]),False);
        Img.Copy(Buffer,(I-1)*SizeX,(J-1)*SizeY);
        Img.Free;
      End;
  Buffer.SaveImage('_1_.Png');
{  Img[1,1]:=TAvenusImage.Create(Screen,'TidusOgre\H1\OgreMagi0.Bmp',False);
  Img[1,2]:=TAvenusImage.Create(Screen,'TidusOgre\H1\OgreMagi1.Bmp',False);
  Img[1,3]:=TAvenusImage.Create(Screen,'TidusOgre\H1\OgreMagi2.Bmp',False);
  Img[1,4]:=TAvenusImage.Create(Screen,'TidusOgre\H1\OgreMagi3.Bmp',False);
  Img[2,1]:=TAvenusImage.Create(Screen,'TidusOgre\H2\OgreMagi0.Bmp',False);
  Img[2,2]:=TAvenusImage.Create(Screen,'TidusOgre\H2\OgreMagi1.Bmp',False);
  Img[2,3]:=TAvenusImage.Create(Screen,'TidusOgre\H2\OgreMagi2.Bmp',False);
  Img[2,4]:=TAvenusImage.Create(Screen,'TidusOgre\H2\OgreMagi3.Bmp',False);
  Img[3,1]:=TAvenusImage.Create(Screen,'TidusOgre\H3\OgreMagi0.Bmp',False);
  Img[3,2]:=TAvenusImage.Create(Screen,'TidusOgre\H3\OgreMagi1.Bmp',False);
  Img[3,3]:=TAvenusImage.Create(Screen,'TidusOgre\H3\OgreMagi2.Bmp',False);
  Img[3,4]:=TAvenusImage.Create(Screen,'TidusOgre\H3\OgreMagi3.Bmp',False);
  Img[4,1]:=TAvenusImage.Create(Screen,'TidusOgre\H4\OgreMagi0.Bmp',False);
  Img[4,2]:=TAvenusImage.Create(Screen,'TidusOgre\H4\OgreMagi1.Bmp',False);
  Img[4,3]:=TAvenusImage.Create(Screen,'TidusOgre\H4\OgreMagi2.Bmp',False);
  Img[4,4]:=TAvenusImage.Create(Screen,'TidusOgre\H4\OgreMagi3.Bmp',False);
  Img[5,1]:=TAvenusImage.Create(Screen,'TidusOgre\H5\OgreMagi0.Bmp',False);
  Img[5,2]:=TAvenusImage.Create(Screen,'TidusOgre\H5\OgreMagi1.Bmp',False);
  Img[5,3]:=TAvenusImage.Create(Screen,'TidusOgre\H5\OgreMagi2.Bmp',False);
  Img[5,4]:=TAvenusImage.Create(Screen,'TidusOgre\H5\OgreMagi3.Bmp',False);}
  {Repeat
    Buffer.Flip(False);
  Until Screen.DoEvents=False;}
  Input.Free;
  Buffer.Free;
  Screen.Free;
END.
