USES AvenusBase,AvenusFX,AvenusMedia,MMSystem,SysUtils;

VAR
  Screen     : TAvenus;
  Buffer     : TAvenusBuffer;
  Input      : TAvenusInput;
  Imgs       : TAvenusSprite;
  Images     : TAvenusImage;
  Count,I,J  : Byte;
  Frame,Time : LongWord;
  Video      : TAvenusVideoExpansion;

BEGIN
  Screen:=TSelfAvenus.Create(800,600,'Crazy Hello !');
  Buffer:=TAvenusBuffer.Create(Screen,800,600,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  Imgs:=TAvenusSprite.Create(45);
  Video:=TAvenusVideoExpansion.Create(Screen,'D:\TEMP\SNAG-0001.AVI',False,False);
  Repeat
    Video.UpdateFrame;
    Video.Frame.Draw(0,0);
  Until (Screen.DoEvents=False) or (Input.KeyDown(K_Escape));
  Buffer.Free;
  Screen.Free;
END.
