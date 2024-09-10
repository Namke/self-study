USES MMSystem,SysUtils,Types,Graphics,PNGImage,AvenusBase;

VAR
  Image     : TPNGImage;
  Img       : TBitmap;
  I,J,Color : Integer;
  Screen    : TAvenus;
  Buffer    : TAvenusBuffer;
  A         : Array[0..10000] of Byte;

BEGIN
  Screen:=TSelfAvenus.Create(300,300,'');
  Buffer:=TAvenusBuffer.Create(Screen,300,300,False);
  Image:=TPNGImage.Create;
  Img:=TBitmap.Create;
  Image.LoadFromFile('Ogre.png');
  Img.Width:=Image.Width;
  Img.Height:=Image.Height;
  Img.PixelFormat:=Image.PixelFormat;
  For J:=0 to Image.Height-1 do
    Begin
      Move(Image.ScanLine[J]^,A,Image.Width);
      For I:=0 to Image.Width-1 do
        Begin
          Color:=A[I];
          If (Color>=208) and (Color<=211) then A[I]:=A[I]+4;
          Buffer.PutPixel(I,J,Color);
        End;
      Move(A,Image.ScanLine[J]^,Image.Width);
    End;
  Image.SaveToFile('1.png');
  Buffer.Flip(False);
  Repeat
  Until Screen.DoEvents=False;
  Screen.Free;
END.
