USES MMSystem,SysUtils,Types,Graphics,PNGImage,AvenusBase;

VAR
  Image     : TAvenusImage;
  Img       : TBitmap;
  Screen    : TAvenus;
  Buffer    : TAvenusBuffer;
  Input     : TAvenusInput;
  Color     : LongWord;
  A         : Array[0..10000] of Byte;

BEGIN
  Screen:=TSelfAvenus.Create(800,800,'');
  Buffer:=TAvenusBuffer.Create(Screen,800,800,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  Image:=TAvenusImage.Create(Screen,'Ogre.png',False);
  Repeat
    //Image.Copy(Buffer,0,0);
    Image.CopyScale(Buffer,0,0,4000,4000);
    If Input.M_Left then
      Color:=Buffer.GetPixel(Input.M_X,Input.M_Y);
    Buffer.WriteStr(0,0,Format('%d',[Color]),$0);
    Buffer.Flip(False);
  Until Screen.DoEvents=False;
  Screen.Free;
END.
