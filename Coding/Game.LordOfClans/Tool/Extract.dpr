USES AvenusBase,AvenusFX,MMSystem,SysUtils;

VAR
  Screen       : TAvenus;
  Buffer,Images,Image       : TAvenusBuffer;
  Input        : TAvenusInput;
  Count,I,J    : Byte;
  Frame,Time   : LongWord;
  S            : String;

BEGIN
  Screen:=TSelfAvenus.Create(800,600,'Crazy Hello !');
  //Screen:=TSelfFullAvenus.Create(800,600,16,'Crazy Hello !');
  Buffer:=TAvenusBuffer.Create(Screen,800,600,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  Image:=TAvenusBuffer.Create(Screen,46,38,False);
  Images:=TAvenusImage.Create(Screen,'Icons.Png',False);
  Count:=0;
  For I:=0 to 4 do
    For J:=0 to 39 do
       Begin
         Str(Count,S);
         Images.BitCopyScale(Image,I*46,J*38,(I+1)*46-1,(J+1)*38-1,0,0,46,37);
         //Imgs.Get(0,Images,I*46,J*38);
         Image.SaveImage('Image\'+S+'.png');
         Inc(Count);
       End;
  Buffer.Free;
  Screen.Free;
END.
