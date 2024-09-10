USES Windows,Classes,VFW,MMSystem,SysUtils,DirectShow,DirectDraw,
     AvenusBase,AvenusFX,AvenusMedia,PNGZLib,WaveLetCompress,JPEG;
{$AppType GUI}
CONST
  ScrW = 640;
  ScrH = 480;

TYPE
  ArrayWord = Array[0..0] of Word;

VAR
  Screen                     : TAvenus;
  Input                      : TAvenusInput;
  Buffer                     : TAvenusBuffer;
  Img                        : TAvenusImage;
  F                          : TStream;
  BlockIn,BlockOut           : Pointer;
  SizeIn,SizeOut,SizeX,SizeY : Integer;

PROCEDURE Save(SF,DF : String);
  Begin
    Img:=TAvenusImage.Create(Screen,SF,False);
    F:=TFileStream.Create(DF,FMCreate);
    SizeX:=Img.XSize;
    SizeY:=Img.YSize;
    SizeIn:=SizeX*SizeY*Img.BytePerPixel;
    GetMem(BlockIn,SizeIn);
    Move(Img.Ptr^,BlockIn^,SizeIn);
    ZCompress(BlockIn,SizeIn,BlockOut,SizeOut,ZCMax);
    F.Write(SizeX,SizeOf(SizeX));
    F.Write(SizeY,SizeOf(SizeY));
    F.Write(SizeOut,SizeOf(SizeOut));
    F.Write(BlockOut^,SizeOut);
    FreeMem(BlockIn);
    FreeMem(BlockOut);
    F.Free;
  End;

PROCEDURE Load(FN : String);
  Begin
    F:=TFileStream.Create(FN,FMOpenRead);
    F.Read(SizeX,SizeOf(SizeX));
    F.Read(SizeY,SizeOf(SizeY));
    F.Read(SizeIn,SizeOf(SizeIn));
    GetMem(BlockIn,SizeIn);
    F.Read(BlockIn^,SizeIn);
    ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
    Img:=TAvenusImage.Create(Screen,SizeX,SizeY,False);
    Move(BlockOut^,Img.Ptr^,SizeOut);
    FreeMem(BlockIn);
    FreeMem(BlockOut);
    Img.Draw(0,0);
    Img.Free;
    F.Free;
    Repeat Until Input.KeyDown(K_Escape) or (Screen.DoEvents=False);
  End;

PROCEDURE SaveWaveLet(SF,DF : String);
  Var WLR,WLG,WLB : PIArray;
      Z           : Integer;
      R,G,B       : Byte;
  Begin
    Img:=TAvenusImage.Create(Screen,SF,False);
    SizeX:=Img.XSize;
    SizeY:=Img.YSize;
    SizeIn:=SizeX*SizeY;
    GetMem(WLR,SizeIn);
    GetMem(WLG,SizeIn);
    GetMem(WLB,SizeIn);
    For Z:=0 to SizeIn do
      Begin
        LongWord2RGB(ArrayWord(Img.Ptr^)[Z],R,G,B);

      End;
    FreeMem(WLR);
    FreeMem(WLG);
    FreeMem(WLB);
  End;

BEGIN
  Screen:=TSelfAvenus.Create(ScrW,ScrH,'Crazy babe');
  Buffer:=TAvenusBuffer.Create(Screen,ScrW,ScrH,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  Save('Knight.png','Sun.ZLib');
  Load('Sun.ZLib');
  Input.Free;
  Buffer.Free;
  Screen.Free;
END.

