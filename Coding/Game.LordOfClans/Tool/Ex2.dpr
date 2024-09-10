USES Types,Graphics,PNGImage;

VAR
  Image,Img : TPNGImage;
  I,J,Count,K : Integer;
  A         : Array[0..10000] of Byte;
  S         : String;

BEGIN
  Img:=TPNGImage.Create;
  Image:=TPNGImage.Create;
  Image.LoadFromFile('Icons.png');
  Img.PixelFormat:=Image.PixelFormat;
  Img.Width:=46;
  Img.Height:=38;
  Img.Palette:=Image.Palette;
  Count:=0;
  For I:=0 to 4 do
    For J:=0 to 39 do
       Begin
         Str(Count,S);
         While Length(S)<3 do S:='0'+S;
         For K:=0 to 37 do
           Begin
             Move(Image.ScanLine[(K+J*38)]^,A,Image.Width);
             Move(A[I*46],Img.ScanLine[K]^,46);
           End;
         Img.SaveToFile('Image\'+S+'.png');
         Inc(Count);
       End;
  Image.SaveToFile(S);
END.
