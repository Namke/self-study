USES AvenusBase,AvenusFX,MMSystem,SysUtils;

VAR
  Screen    : TAvenus;
  Buffer    : TAvenusBuffer;
  Input     : TAvenusInput;
  Imgs      : TAvenusSprite;
  Images    : TAvenusImage;
  Count,I,J : Byte;
  Frame,Time : LongWord;
  S          : String;

BEGIN
  Screen:=TSelfAvenus.Create(800,600,'Crazy Hello !');
  Buffer:=TAvenusBuffer.Create(Screen,800,600,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  Imgs:=TAvenusSprite.Create(45);
  Images:=TAvenusImage.Create(Screen,'icons.png',False);
  Imgs.CreateNewSprite(46,38);
  Count:=0;
  For I:=0 to 4 do
    For J:=0 to 39 do
      Begin
        Str(Count,S);
        Imgs.Get(0,Images,I*46,J*38);
        Imgs.SaveImage(0,Name+'.bmp');
      End;
  Buffer.Free;
  Screen.Free;
END.
