USES MMSystem,SysUtils,Types,Convert,AvenusBase,Avenus3D,KPF,DirectXGraphics,PNGImage,AvenusFX;

CONST
{$IfDef V1024}
  ScrX          = 1024;
  ScrY          = 768;
{$Else}
  ScrX          = 800;
  ScrY          = 600;
{$EndIf}
TYPE
  PPalSwitch = ^TPalSwitch;
  TPalSwitch = Array[1..4] of Word;

CONST
  MaxDict   = 7;
  PalSwitch : Array[0..MaxDict] of TPalSwitch =
              {((40960,44032,48128,53248),
               (32777,32845,32914,33016),
               (32929,33093,35339,38610),
               (37925,43081,47312,52534),
               (46209,52450,57698,64002),
               (33826,34884,35941,38055),
               (37033,43344,52854,62364),
               (44224,46336,48448,50561));{}
             ((16416,22560,30720,40960),
              //(00041,00173,00306,00504),
              (00041,00174,00340,02649),
              (00321,00677,05163,11698),
              (10309,20617,29072,39510),
              (26881,39362,49858,62498),
              (02146,04260,06373,10567),
              (08521,21168,40150,59164),
              (22912,27136,31360,35617));{}
TYPE
  TRLESprite = Record
    DataSize : Integer;
    Data     : Pointer;
  End;
  TData = Word;

VAR
  Screen : TAvenus3D;
  Font   : TAvenusNewFont;
  Input  : TAvenusInput;
  Img    : TAvenusTextureImages;
  Spr    : TRLESprite;
  BufferSize : Integer;
  R,G,B : Byte;
  Num,Z,K,Color     : LongWord;
  Start,Frame,Time : LongWord;

PROCEDURE MakeRLE(Var Sprite : TRLESprite;Buffer : Pointer;BufferSize : Integer;MC : LongWord);
  Type ArrayofSmallInt = Array[0..0] of TData;
  Var I,Z,Run,Size,TmpSize : Integer;
      Tmp                  : ^ArrayofSmallInt;
      Color,Index          : LongWord;
  Begin
    With Sprite do
      Begin
        //MaskColor:=MC;
        Size:=0;
        TmpSize:=BufferSize;
        GetMem(Tmp,TmpSize*SizeOf(TData));
        Run:=-1;
        For I:=0 to BufferSize-1 do
          Begin
            Color:=ArrayofSmallInt(Buffer^)[I];
            Index:=MC;
            For Z:=1 to 4 do
              If Color=PalSwitch[1,Z] then Index:=Z;
            If Index=MC then
              Begin
                If Run>0 then Inc(Tmp^[Run])
                Else
                  Begin
                    Tmp^[Size]:=Index;
                    Tmp^[Size+1]:=1;
                    Run:=Size+1;
                    Inc(Size,2);
                  End
              End
            Else
              Begin
                Run:=-1;
                Tmp^[Size]:=Index;
                Inc(Size);
              End;
          End;
        DataSize:=SizeOf(TData)*Size;
        GetMem(Data,DataSize);
        Move(Tmp^,Data^,DataSize);
        FreeMem(Tmp);
      End;
  End;
  
PROCEDURE PasterFastOld2(Src,Dst : Pointer;Size : Integer;Mask : Word;Pal : PPalSwitch);
  Asm
    Push         EDI
    Push         ESI
    Push         EBX
    Mov          ESI,Src
    Mov          EDI,Dst
    Mov          EBX,Pal
    Sub          EBX,2
    Xor          EAX,EAX
    Xor          EDX,EDX
    @Loop:
    Mov          AX,[ESI]
    Cmp          AX,Mask
    JZ           @NoPoint
    @Loop2:
    Mov          AX,[EBX+EAX*2]
    Mov          [EDI],AX
    Add          ESI,2
    Add          EDI,2
    Dec          ECX
    JnZ          @Loop
    @NoPoint:
    Mov          DX,[ESI+2]
    Add          EDI,EDX
    Add          EDI,EDX
    Add          ESI,4
    Add          ECX,-2
    JnZ          @Loop
    Pop          EBX
    Pop          ESI
    Pop          EDI
  End;

BEGIN
  InitializePDrawEx;
  {$IfNDef Full}
  Screen:=TSelfAvenus3D.Create(ScrX,ScrY,'<Crazy Babe>');
  {$Else}
  Screen:=TSelfFullAvenus3D.Create(ScrX,ScrY,BitDepthLow,'<Crazy Babe>');
  {$EndIf}
  Font:=TAvenusNewFont.Create(Screen);
  Font.LoadFromFile('Font.Png',0);
  Img:=TAvenusTextureImages.Create;
  //Img.LoadFromFile(Screen.D3DDevice8,'Ogre.Png',72,72,D3DFMT_A1R5G5B5);
  Img.LoadFromFile(Screen.D3DDevice8,'Ogre.Png',72,72,D3DFMT_R5G6B5);
  //Img.LoadFromFileAlpha1Bit(Screen.D3DDevice8,'ogre.Png',72,72,$FFFFFF);
  //Img.LoadFromFileAlpha1Bit(Screen.D3DDevice8,'orcbarrack.Png',0,0,$FFFFFF);
  //Img.LoadFromFile(Screen.D3DDevice8,'Ogre.Png',72,72,D3DFMT_R5G6B5);
  Input:=TAvenusInput.Create(Screen.Handle);
  BufferSize:=Img.TextureWidth[0]*Img.TextureHeight[0];
  Color:=RGBToWord(255,255,255) or $8000;
  Num:=0;
  MakeRLE(Spr,Img.Ptr[Num].PBits,BufferSize,Color);
  //ScreenBPP:=16;
  //LongWord2RGB(40960,R,G,B);
  //ScreenBPP:=15;
  //Color:=RGB2LongWord(R,G,B);
  //8192,11264,15360,20480
  //16416,22560,30720,40960
  (*For Z:=0 to MaxDict do
    For K:=1 to 4 do
      Begin
        ScreenBPP:=16;
        LongWord2RGB(PalSwitch[Z,K],R,G,B);
        ScreenBPP:=15;
        Color:=RGB2LongWord(R,G,B);
        PalSwitch[Z,K]:=Color or $8000;
        {PalSwitch[Z,1]:=PalSwitch[Z,1] or $8000;
        PalSwitch[Z,2]:=PalSwitch[Z,2] or $8000;
        PalSwitch[Z,3]:=PalSwitch[Z,3] or $8000;
        PalSwitch[Z,4]:=PalSwitch[Z,4] or $8000;}
      End;*)
  Start:=TimeGetTime;
  Frame:=0;
  Repeat
    Screen.BeginScene;
    Screen.Clear(0);
    For Z:=1 to 300 do
      Begin
        PasterFastOld2(Spr.Data,Img.Ptr[Num].PBits,Spr.DataSize div SizeOf(TData),$FFFF,@PalSwitch[2]);
        Screen.RenderEffect(Img,100+10*(Z mod 2),100,Num,EffectSrcAlpha);
        Screen.RenderBuffer;
      End;
    Inc(Frame);
    Time:=TimeGetTime-Start;
    If Time>0 then
      Font.TextOut(10,10,Format('FPS : %0.2f',[Frame/Time*1000]),$FFFFFF);
    Screen.EndScene;
    If Not Screen.Present then Exit;
  Until Input.KeyDown(K_Escape) or (Screen.DoEvents=False);
END.
