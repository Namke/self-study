USES AvenusBase,AvenusFX,AvenusMedia,MMSystem,SysUtils;
{$I-}
VAR
  Screen      : TAvenus;
  Buffer      : TAvenusBuffer;
  Input       : TAvenusInput;
  Images,Img  : TAvenusImage;
  Count,I,J,C : LongWord;

PROCEDURE Draw(X,Y : Integer);
  Var R,G,B,R1,G1,B1  : Byte;
      I,J : Integer;
  Begin
    //Img.CopyAdd(Buffer,I,J);
    //Img.CopyXor(Buffer,I,J);
    Img.CopyDif(Buffer,I,J);
  End;

BEGIN
  Screen:=TSelfAvenus.Create(800,600,'Crazy Hello !');
  Buffer:=TAvenusBuffer.Create(Screen,800,600,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  Images:=TAvenusImage.Create(Screen,'wc3.jpg',False);
  Img:=TAvenusImage.Create(Screen,'2.png',False);
  //Img.Negative;
  Repeat
    //If Input.M_Left then
      Begin
        Buffer.Fill(0);
        Images.Copy(Buffer,0,0);
        I:=Input.M_X;
        J:=Input.M_Y;
        Draw(I,J);
        Buffer.Flip(False);
      End;
  Until (Screen.DoEvents=False) or (Input.KeyDown(K_Escape));
  Buffer.Free;
  Screen.Free;
END.
