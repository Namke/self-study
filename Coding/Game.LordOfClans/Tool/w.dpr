USES PNGZLib;
{$I-}
VAR
  Screen     : TAvenus;
  Buffer     : TAvenusBuffer;
  Input      : TAvenusInput;
  Images,Img     : TAvenusImage;
  Im : Array[0..4] of TAvenusBuffer;
  Spr  : TAvenusSprite;
  R,G,B,R1,G1,B1  : Byte;
  Count,I,J,C    : LongWord;
  NumFrame : Word;
  Frame : TAvenusSprite;

PROCEDURE UnitAnimationLoad(FileName : String);
  Var ImageFileName     : String;
      X,Y,SizeX,SizeY,Z : Integer;
      ImageTemp         : TAvenusImage;
      F                 : Text;
  Begin
    Assign(F,'GameData\AnimationScript\'+FileName);
    Reset(F);
    If IOResult<>0 then Exit;
    ReadLn(F);//Skip line [FileName]
    ReadLn(F,ImageFileName);
    ReadLn(F);//Skip line [Number of images]
    ReadLn(F,NumFrame);
    ReadLn(F);//Skip line [Images position and images size]
    Frame:=TAvenusSprite.Create(NumFrame);
    ImageTemp:=TAvenusImage.Create(Screen,'GameData\'+ImageFileName,False);
    For Z:=0 to NumFrame-1 do
      Begin
        ReadLn(F,X,Y,SizeX,SizeY);
        Frame.SetSpriteSize(Z,SizeX,SizeY);
        Frame.Get(Z,ImageTemp,X,Y);
      End;
    ImageTemp.Free;
    Close(F);
  End;

PROCEDURE Draw(X,Y : Integer);
  Var R,G,B,R1,G1,B1  : Byte;
      I,J : Integer;
  Begin
    Im[0].CopyAdd(Buffer,I,J);
    //If Count<Frame.SpritesCount then Inc(Count) Else Count:=1;
    //Frame.CopyAdd(Count-1,Buffer,I,J);
    //Im[3].CopyAdd(Buffer,I,J);
    {For I:=0 to Im[0].XMax do
      For J:=0 to Im[0].YMax do
        If Im[0].GetPixel(I,J)<>0 then
          Begin
            LongWord2RGB(Im[0].GetPixel(I,J),R,G,B);
            LongWord2RGB(Buffer.GetPixel(X+I,Y+J),R1,G1,B1);
            //R:=(R+R1) ShR 1;
            //If B>10 then
            R:=0;
            //If G+G1>255 then G:=255 Else G:=(G+G1);
            G:=(G*100+G1*128) div 256;
            B:=(255+B1) div 2;
            Buffer.PutPixel(X+I,Y+J,RGB2LongWord(70,G,B));
          End;{}
        (*If Im[1].GetPixel(I,J)=0 then
          Begin
            {longWord2RGB(Im[0].GetPixel(I,J),R,G,B);
            LongWord2RGB(Buffer.GetPixel(X+I,Y+J),R1,G1,B1);
            If R+R1>255 then R:=255 Else R:=R+R1;
            If G+G1>255 then G:=255 Else G:=G+G1;
            If B+B1>255 then B:=255 Else B:=B+B1;
            Buffer.PutPixel(X+I,Y+J,RGB2LongWord(R,G,B));}
            //Buffer.PutPixel(X+I,Y+J,Im[0].GetPixel(I,J));
          End
        Else
        If Im[0].GetPixel(I,J)<>0 then
          Begin
            LongWord2RGB(Im[0].GetPixel(I,J),R,G,B);
            LongWord2RGB(Buffer.GetPixel(X+I,Y+J),R1,G1,B1);
            //R:=(R+R1) ShR 1;
            //If B>10 then
            R:=0;
            G:=(G+G1) div 2;
            B:=(255+B1) div 2;
            Buffer.PutPixel(X+I,Y+J,RGB2LongWord(0,G,B));
          End;*)
  End;

BEGIN
  Screen:=TSelfAvenus.Create(800,600,'Crazy Hello !');
  Buffer:=TAvenusBuffer.Create(Screen,800,600,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  //UnitAnimationLoad('Peasant.ani');
  Images:=TAvenusImage.Create(Screen,'wc3.jpg',False);
  Spr:=TAvenusSprite.Create(2);
  Spr.SetSpriteSize(1,30,30);
  Spr.Get(1,Images,0,0);
  //Img:=TAvenusImage.Create(Screen,'GameData\TerrainTextures\spell.bmp',False);
  Img:=TAvenusImage.Create(Screen,'GameData\TerrainTextures\spellareaofeffect.bmp',False);
  Im[3]:=TAvenusImage.Create(Screen,'GameData\TerrainTextures\flare1.bmp',False);
  Im[2]:=TAvenusBuffer.Create(Screen,256,256,False);
  Im[1]:=TAvenusBuffer.Create(Screen,256,256,False);
  Im[0]:=TAvenusBuffer.Create(Screen,256,256,False);
  Img.Draw(0,0);
  //Im[0].Get(Screen,0,0);
  Im[0].GetBit(Screen,0,0,256,255,0,0);
  Im[1].GetBit(Screen,0,256,256,512,0,0);
  For I:=0 to Im[0].XMax do
    For J:=0 to Im[0].YMax do
      If Im[0].GetPixel(I,J)=RGB2LongWord(255,0,255) then Im[0].PutPixel(I,J,0);
  {For I:=0 to Im[1].XMax do
    For J:=0 to Im[1].YMax do
      If Im[1].GetPixel(I,J)=RGB2LongWord(255,0,255) then Im[1].PutPixel(I,J,0);
  im[0].Grayscale;
  im[1].Grayscale;
  Im[0].SaveImage('1.bmp');
  Im[1].SaveImage('2.bmp');}
  //Im[0].CopyRedChannel(Im[2],0,0);
  //Im[0].CopyBlueChannel(Im[2],0,0);
  Im[0].CopyGreenChannel(Im[2],0,0);
  //Im[0].Grayscale;
  Buffer.WriteStr(10,500,Format('%d %d %d',[R,G,B]),RGB2LongWord(255,255,255));
  Images.Copy(Buffer,0,0);
  Buffer.Flip(False);
  Count:=0;
  Repeat
    //If Input.M_Left then
      Begin
        Buffer.Fill(0);
        Images.Copy(Buffer,0,0);
        //Img.CopyAlphaSprite(Buffer,Input.M_X,Input.M_Y,128,0);
        I:=Input.M_X;
        J:=Input.M_Y;
        Draw(I,J);
        //Im[0].ClipCopyAlphaSprite(Buffer,I,J,128,0);
        //Im[1].CopyAdd(Buffer,I,J);
        //Im[1].ClipCopyBlendSpriteX(Buffer,I,J,0,0,32,0);
        //Im[0].ClipCopyBlendSpriteX(Buffer,I,J,0,0,64,0);
        //Im[2].ClipCopyBlendSpriteX(Buffer,I,J,0,0,64,0);
        //Im[2].CopyAdd(Buffer,I,J);
        //Im[0].CopyAdd(Buffer,I,J);
        //Im[0].ClipCopyBlendSpriteX(Buffer,I,J,0,32,32,0);
        //Im[0].ClipCopyAlphaSprite(Buffer,I,J,32,0);
        Buffer.Flip(False);
      End;
  Until (Screen.DoEvents=False) or (Input.KeyDown(K_Escape));
  Buffer.Free;
  Screen.Free;
END.
