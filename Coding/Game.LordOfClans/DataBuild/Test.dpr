{$AppType GUI}
USES Classes,SysUtils,DirectXGraphics,AvenusCommon,Avenus3D,KPF;

VAR
  DataFile : TKPF;
  Key      : TRecordKey;
  Image    : TAvenusTextureImages;
  Screen   : TAvenus3D;
  Input    : TAvenusInput;

BEGIN
  DataFile:=TKPF.Create;
  DataFile.OpenMode:=OpenReadOnly;
  DataFile.FileName:='DataBase.2012';
  If DataFile.Initialize<>0 then
    Begin
      DataFile.Free;
      Exit;
    End;
  Screen:=TSelfAvenus3D.Create(400,400,'Ha ha I''m CrazyBabe !!!');
  Input:=TAvenusInput.Create(Screen.Handle);
  Image:=TAvenusTextureImages.Create;
  //Key:='GameData\Images\ScreenStart.jpg';
  Key:='GameData\Images\Units\Ogre.png';
  Image.LoadFromPackFile(DataFile,Screen.D3DDevice8,Key,0,0,D3DFMT_R5G6B5);
  //Image.LoadFromFile(Screen.D3DDevice8,Key,0,0,D3DFMT_R5G6B5);
  Repeat
    Screen.BeginScene;
    Screen.RenderEffect(Image,0,0,0,EffectNone);
    Screen.EndScene;
    Screen.Present;
  Until Input.KeyDown(Key_Escape) or Not Screen.DoEvents;
  Input.Free;
  Screen.Free;
END.
