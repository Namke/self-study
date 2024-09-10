USES AvenusBase,AvenusFX,AvenusMedia,MMSystem,SysUtils;

VAR
  Screen     : TAvenus;
  Buffer     : TAvenusBuffer;
  Input      : TAvenusInput;
  Images,Img     : TAvenusImage;
  R,G,B,R1,G1,B1  : Byte;
  Count,I,J,C    : LongWord;

BEGIN
  Screen:=TSelfAvenus.Create(800,600,'Crazy Hello !');
  Buffer:=TAvenusBuffer.Create(Screen,800,600,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  //Images:=TAvenusImage.Create(Screen,'GameData\TerrainTextures\Lords_grass.png',False);
  Images:=TAvenusImage.Create(Screen,'GameData\TerrainTextures\spellareaofeffect.bmp',False);
  Img:=TAvenusImage.Create(Screen,'GameData\TerrainTextures\spell.bmp',False);
  //Images.Copy(Buffer,0,0);
  //Images.CopyGreenChannel(Buffer,0,0);
  //Images.CopyBlueChannel(Buffer,0,0);
  Images.CopyRedChannel(Buffer,0,0);
  For I:=0 to Images.XMax do
    For J:=0 to Images.YMax do
      Begin
        C:=Images.GetPixel(I,J);
        LongWord2RGB(C,R,G,B);
        If (R=0) and (B=0) then Buffer.PutPixel(I,J,0)
        Else Buffer.PutPixel(I,J,C);
      End;
  Buffer.WriteStr(10,500,Format('%d %d %d',[R,G,B]),RGB2LongWord(255,255,255));
  Buffer.Flip(False);
  Repeat
    If Input.M_Left then
      Begin
        Buffer.Fill(0);
        //Images.CopyRedChannel(Buffer,0,0);
        I:=Input.M_X;J:=Input.M_Y;
        Images.Copy(Buffer,0,0);
        //Img.CopyAlpha(Buffer,100,100,128);
        Img.CopyAdd(Buffer,100,100);
        C:=Images.GetPixel(I,J);
        LongWord2RGB(C,R,G,B);
        Buffer.WriteStr(10,500,Format('%d %d %d',[R,G,B]),RGB2LongWord(255,255,255));
        C:=Images.GetPixel(I,J-64);
        LongWord2RGB(C,R1,G1,B1);
        Buffer.WriteStr(10,520,Format('%d %d %d',[R1,G1,B1]),RGB2LongWord(255,255,255));
        Buffer.WriteStr(10,540,Format('%d %d %d',[R-R1,G-G1,B-B1]),RGB2LongWord(255,255,255));
        Buffer.Flip(False);
      End;
  Until (Screen.DoEvents=False) or (Input.KeyDown(K_Escape));
  Buffer.Free;
  Screen.Free;
END.
