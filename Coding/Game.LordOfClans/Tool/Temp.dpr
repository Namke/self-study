USES SysUtils,MMSystem,AvenusBase,AvenusFX,Types,DirectDraw;

CONST
  SizeX = 800;
  SizeY = 600;
  WQ    = 1;

TYPE
  PPalSwitch = ^TPalSwitch;
  TPalSwitch = Array[1..4] of Word;

CONST
  MaxDict   = 7;
  PalSwitch : Array[0..MaxDict] of TPalSwitch =
             ((16416,22560,30720,40960),
              (00041,00173,00306,00504),
              (00321,00677,05163,11698),
              (10309,20617,29072,39510),
              (26881,39362,49858,62498),
              (02146,04260,06373,10567),
              (08521,21168,40150,59164),
              (22912,27136,31360,35617));

TYPE
  TRLESprite = Record
    SizeX,SizeY,MaskColor,DataSize : Integer;
    ColorDepth                     : Byte;
    Data                           : Pointer;
  End;

VAR
  Screen           : TAvenus;
  BG,Image,Buffer,Img     : TAvenusBuffer;
  Input            : TAvenusInput;
  Spr              : TRLESprite;
  X,Y,Z,Depth,DI,Time  : LongWord;
  ASin             : Array[0..1024] of SmallInt;

PROCEDURE SmoothLine(Buffer : TAvenusBuffer;X1,Y1,X2,Y2 : Integer;Color : LongWord);
  Var DX,DY,S,D,CI,EA,EC : Integer;
      CB,CG,CR,B,G,R     : Byte;
      P                  : LongWord;
  Begin
    LongWord2RGB(Color,CR,CG,CB);
    If (Y1=Y2) or (X1=X2) then
      Buffer.Line(X1,Y1,X2,Y2,Color)
    Else
      Begin
        If Buffer.YSize>0 then
          Begin
            Y1:=Buffer.YSize-Y1-1;
            Y2:=Buffer.YSize-Y2-1;
          End;
        If Y1>Y2 then
          Begin
            D:=Y1;Y1:=Y2;Y2:=D;
            D:=X1;X1:=X2;X2:=D;
          End;
        DX:=X2-X1;
        DY:=Y2-Y1;
        If DX>-1 then S:=1
        Else Begin S:=-1;DX:=-DX;End;
        EC:=0;
        //Buffer.Pixels16[Y1,X1]:=Color;
        If DY>DX then
          Begin
            EA:=(DX ShL 16) div DY;
            While DY>1 do
              Begin
                Dec(DY);D:=EC;
                Inc(EC,EA);
                EC:=EC and $FFFF;
                If EC<=D then Inc(X1,S);
                Inc(Y1);CI:=EC ShR 8;
                P:=Buffer.GetPixel(X1,Y1);
                LongWord2RGB(P,R,G,B);
                R:=(R-CR)*CI ShR 8+CR;
                G:=(G-CG)*CI ShR 8+CG;
                B:=(B-CB)*CI ShR 8+CB;
                P:=RGB2LongWord(R,G,B);
                Buffer.PutPixel(X1,Y1,P);
                P:=Buffer.GetPixel(X1+S,Y1);
                LongWord2RGB(P,R,G,B);
                R:=(CR-R)*CI ShR 8+R;
                G:=(CG-G)*CI ShR 8+G;
                B:=(CB-B)*CI ShR 8+B;
                P:=RGB2LongWord(R,G,B);
                Buffer.PutPixel(X1+S,Y1,P);
              End;
          End
        Else
          Begin
            EA:=(DY ShL 16) div DX;
            While DX>1 do
              Begin
                Dec(DX);D:=EC;
                Inc(EC,EA);
                EC:=EC and $FFFF;
                If EC<=D then Inc(Y1);
                Inc(X1,S);CI:=EC ShR 8;
                P:=Buffer.GetPixel(X1,Y1);
                LongWord2RGB(P,R,G,B);
                R:=(R-CR)*CI ShR 8+CR;
                G:=(G-CG)*CI ShR 8+CG;
                B:=(B-CB)*CI ShR 8+CB;
                P:=RGB2LongWord(R,G,B);
                Buffer.PutPixel(X1,Y1,P);
                P:=Buffer.GetPixel(X1,Y1+1);
                LongWord2RGB(P,R,G,B);
                R:=(CR-R)*CI ShR 8+R;
                G:=(CG-G)*CI ShR 8+G;
                B:=(CB-B)*CI ShR 8+B;
                P:=RGB2LongWord(R,G,B);
                Buffer.PutPixel(X1,Y1+1,P);
              End;
          End;
        //Buffer.Pixels16[Y2,X2]:=Color;
      End;
  End;

PROCEDURE WaterWave(Dest : TAvenusBuffer;RC : TRect;Count : Byte);
  Var Z,K     : Integer;
      SrcRect : TRect;
  Begin
    For Z:=0 to ((RC.Right-RC.Left) div WQ-1) do
      Begin
        K:=(Z*WQ+Count*4) and $3FF;
        SrcRect:=Rect(RC.Left+Z*WQ,RC.Top,RC.Left+Z*WQ+WQ,RC.Bottom);
        Dest.DDSurface.BltFast(RC.Left+Z*WQ,RC.Top+ASin[K] ShR 8,Dest.DDSurface,@SrcRect,DDBLTFAST_NOCOLORKEY);
      End;
    For Z:=0 to ((RC.Bottom-RC.Top) div WQ-1) do
      Begin
        K:=(Z*6*WQ+Count*4+360) and $3FF;
        SrcRect:=Rect(RC.Left,RC.Top+Z*WQ,RC.Right,RC.Top+Z*WQ+WQ);
        Dest.DDSurface.BltFast(RC.Left+ASin[K] ShR 8,RC.Top+Z*WQ,Dest.DDSurface,@SrcRect,DDBLTFAST_NOCOLORKEY);
      End;
  End;

TYPE
  TData = Word;

PROCEDURE MakeRLE(Var Sprite : TRLESprite;Buffer : TAvenusBuffer;X1,Y1,X2,Y2 : Integer;MC : LongWord);
  Type ArrayofSmallInt = Array[0..10000] of TData;
  Var I,J,Run,Size,TmpSize : Integer;
      Color                : LongWord;
      Tmp                  : ^ArrayofSmallInt;
  Begin
    With Sprite do
      Begin
        SizeX:=X2-X1+1;
        SizeY:=Y2-Y1+1;
        ColorDepth:=Buffer.BytePerPixel;
        MaskColor:=MC;
        Size:=0;
        TmpSize:=SizeX*SizeY;
        GetMem(Tmp,TmpSize*SizeOf(TData));
        Run:=-1;
        For J:=Y1 to Y2 do
          Begin
            //Run:=-1;
            For I:=X1 to X2 do
              Begin
                Color:=Buffer.GetPixel(I,J);
                If Color=16416 then Color:=1 Else
                If Color=22560 then Color:=2 Else
                If Color=30720 then Color:=3 Else
                If Color=40960 then Color:=4
                Else Color:=MaskColor;
                {If (Color<>16416) and
                   (Color<>22560) and
                   (Color<>30720) and
                   (Color<>40960) then Color:=MaskColor;}
                If Color=MC then
                  Begin
                    If (Run>0) then Inc(Tmp^[Run])
                    Else
                      Begin
                        Tmp^[Size]:=Color;
                        Tmp^[Size+1]:=1;
                        Run:=Size+1;
                        Inc(Size,2);
                      End
                  End
                Else
                  Begin
                    Run:=-1;
                    Tmp^[Size]:=Color;
                    Inc(Size);
                  End;
              End;
          End;
        DataSize:=SizeOf(TData)*Size;
        GetMem(Data,DataSize);
        Move(Tmp^,Data^,DataSize);
        FreeMem(Tmp);
      End;
  End;

PROCEDURE DrawRLE(Sprite : TRLESprite;Buffer : TAvenusBuffer;X,Y : Integer);
  Type ArrayofSmallInt = Array[0..0] of TData;
  Var Z,I,J : Integer;
      Color : TData;
  Begin
    With Sprite do
      Begin
        Z:=0;I:=0;J:=0;
        Repeat
          Color:=ArrayofSmallInt(Data^)[Z];
          If Color=MaskColor then
            Begin
              Inc(I,ArrayofSmallInt(Data^)[Z+1]);
              If I>=SizeX then
                Begin
                  Inc(J,I div SizeX);
                  I:=I mod SizeX;
                End;
              Inc(Z,2);
            End
          Else
            Begin
              Buffer.PutPixel(X+I,Y+J,Color);
              Inc(Z);
              If I<SizeX then Inc(I)
              Else
                Begin
                  Inc(J);
                  I:=0;
                End;
            End;
        Until (J>=SizeY) or (Y+J>Buffer.YSize);
      End;
  End;

PROCEDURE DrawRLETransfer(Sprite : TRLESprite;Buffer : TAvenusBuffer;X,Y,Tab : Integer);
  Type ArrayofSmallInt = Array[0..0] of TData;
  Var Z,I,J : Integer;
      Color : TData;
  Begin
    With Sprite do
      Begin
        Z:=0;I:=0;J:=0;
        Repeat
          Color:=ArrayofSmallInt(Data^)[Z];
          If Color=MaskColor then
            Begin
              Inc(I,ArrayofSmallInt(Data^)[Z+1]);
              If I>=SizeX then
                Begin
                  Inc(J,I div SizeX);
                  I:=I mod SizeX;
                End;
              Inc(Z,2);
            End
          Else
            Begin
              Buffer.PutPixel(X+I,Y+J,PalSwitch[Tab,Color]);
              Inc(Z);
              If I<SizeX then Inc(I)
              Else
                Begin
                  Inc(J);
                  I:=0;
                End;
            End;
        Until (J>=SizeY) or (Y+J>Buffer.YSize);
      End;
  End;

PROCEDURE PasterFastOld1(Src,Dst : Pointer;Size : Integer;Mask : Word);
  Asm
    Push         EDI
    Push         ESI
    Mov          EDI,Src
    Mov          ESI,Dst
    Mov          ECX,Size
    Xor          EDX,EDX
    @Loop:
    Mov          AX,[EDI]
    Cmp          AX,Mask
    JZ           @NoPoint
    @Loop2:
    LEA          EDX,[PalSwitch-2+8*2]
    MovZX        EAX,AX
    Mov          AX,[EDX+EAX*2]
    Mov          [ESI],AX
    Add          ESI,2
    Add          EDI,2
    Dec          ECX
    JnZ          @Loop
    @NoPoint:
    Xor EDX,EDX
    Mov        DX,Word Ptr [EDI+2]
    Add          ESI,EDX
    Add          ESI,EDX
    Add          EDI,4
    Sub          ECX,2
    JnZ          @Loop
    Pop          ESI
    Pop          EDI
  End;

PROCEDURE PasterFastOld(Src,Dst : Pointer;Size : Integer;Mask : Word;PalNum : Integer);
  Asm
    Push         EDI
    Push         ESI
    Push         EBX
    Mov          EDI,Src
    Mov          ESI,Dst
    //Mov          ECX,Size
    Mov          EAX,PalNum
    LEA          EBX,[PalSwitch+EAX*8-2]
    Xor          EAX,EAX
    Xor          EDX,EDX
    @Loop:
    Mov          AX,[EDI]
    Cmp          AX,Mask
    JZ           @NoPoint
    @Loop2:
    Mov          AX,[EBX+EAX*2]
    Mov          [ESI],AX
    Add          ESI,2
    Add          EDI,2
    Dec          ECX
    JnZ          @Loop
    @NoPoint:
    Mov          DX,[EDI+2]
    Add          ESI,EDX
    Add          ESI,EDX
    Add          EDI,4
    Sub          ECX,2
    JnZ          @Loop
    Pop          EBX
    Pop          ESI
    Pop          EDI
  End;

PROCEDURE PasterFast(Src,Dst : Pointer;Size : Integer;Mask : Word;Pal : TPalSwitch);
  //Var Z : Word;
  Begin
  //Z:=Pal[1];
  Asm
    Push         EDI
    Push         ESI
    Mov          EDI,Src
    Mov          ESI,Dst
    //Mov          ECX,Size
    Xor          EAX,EAX
    Xor          EDX,EDX
    @Loop:
    Mov          AX,[EDI]
    Cmp          AX,Mask
    JZ           @NoPoint
    @Loop2:
    Mov          AX,[EAX*2+EBP-$12]
    Mov          [ESI],AX
    Add          ESI,2
    Add          EDI,2
    Dec          ECX
    JnZ          @Loop
    @NoPoint:
    Mov          DX,[EDI+2]
    Add          ESI,EDX
    Add          ESI,EDX
    Add          EDI,4
    Sub          ECX,2
    JnZ          @Loop
    Pop          ESI
    Pop          EDI
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

PROCEDURE TestRLE;
  Var Img : TAvenusSprite;
  Begin
    //Image.CopySprite(Buffer,0,0,RGB2LongWord(255,255,255));
    Image.Copy(Buffer,0,0);
    MakeRLE(Spr,Image,0,0,72,72,RGB2LongWord(252,252,252));
    Img:=TAvenusSprite.Create(0);
    Img.CreateNewSprite(Spr.SizeX,Spr.SizeY);
    Img.Get(0,Buffer,0,0);
    Time:=TimeGetTime;
    //DrawRLETransfer(Spr,Buffer,100,100,4);
    //For Z:=1 to 300000 do
      Begin
        //PasterFast(Spr.Data,Img.Sprites[0].Ptr,Spr.DataSize div SizeOf(TData),Spr.MaskColor,PalSwitch[6]);
        //PasterFast1(Spr.Data,Img.Sprites[0].Ptr,Spr.DataSize div SizeOf(TData),Spr.MaskColor,PalSwitch[6]);
        //PasterFastOld(Spr.Data,Img.Sprites[0].Ptr,Spr.DataSize div SizeOf(TData),Spr.MaskColor,7);
        PasterFastOld2(Spr.Data,Img.Sprites[0].Ptr,Spr.DataSize div SizeOf(TData),Spr.MaskColor,@PalSwitch[6]);
        Img.CopySprite(0,Buffer,200,200,RGB2LongWord(252,252,252));
        //Img.Copy(0,Buffer,200,200);
        //Img.Copy(0,Buffer,100,100);
        //DrawRLETransfer(Spr,Buffer,100,100,4);
      End;
    Time:=TimeGetTime-Time;
    //Z:=Img.GetPixel(0,0,0);
    Buffer.FillRect(0,0,300,30,0);
    Buffer.WriteStr(10,10,Format('%d %d',[Time,Spr.DataSize]),65535);
    Buffer.Flip(True);
  End;

PROCEDURE GouraudSprite(Img,Buffer : TAvenusBuffer;X,Y : Integer;C1,C2,C3,C4,ColorMask : LongWord);
  Var MC1,MC2,MH,LC,RC,HC : Real;
      I,J                 : Integer;
      ColorSrc,ColorDest  : LongWord;
      RS,GS,BS,RD,GD,BD   : Byte;
  Begin
    With Img do
      Begin
        MC1:=(C4-C1)/YSize;
        MC2:=(C3-C2)/YSize;
        LC:=C1;RC:=C2;
        For J:=0 to XMax do
          Begin
            MH:=(RC-LC)/XSize;
            HC:=LC;
            For I:=0 to XMax do
              Begin
                ColorSrc:=GetPixel(I,J);
                If ColorSrc<>ColorMask then
                  Begin
                    LongWord2RGB(ColorSrc,RS,GS,BS);
                    LongWord2RGB(Round(HC),RD,GD,BD);
                    RD:=(RS+RD) ShR 1;
                    GD:=(GS+GD) ShR 1;
                    BD:=(BS+BD) ShR 1;
                    ColorDest:=RGB2LongWord(RD,GD,BD);
                    Buffer.PutPixel(X+I,Y+J,ColorDest);
                  End;
                HC:=HC+MH;
              End;
            LC:=LC+MC1;
            RC:=RC+MC2;
          End;
      End;
  End;

PROCEDURE EffectSprite(Img,Buffer : TAvenusBuffer;X,Y : Integer;C1,C2,C3,C4,ColorMask : LongWord);
  Var MC1,MC2,MH,LC,RC,HC : Real;
      I,J                 : Integer;
      ColorSrc,ColorDest  : LongWord;
      RS,GS,BS,RD,GD,BD   : Byte;
  Begin
    With Img do
      Begin
        MC1:=(C4-C1)/YSize;
        MC2:=(C3-C2)/YSize;
        LC:=C1;RC:=C2;
        For J:=0 to XMax do
          Begin
            MH:=(RC-LC)/XSize;
            HC:=LC;
            For I:=0 to XMax do
              Begin
                ColorSrc:=GetPixel(I,J);
                If ColorSrc<>ColorMask then
                  Begin
                    LongWord2RGB(ColorSrc,RS,GS,BS);
                    LongWord2RGB(Buffer.GetPixel(X+I,Y+J),RD,GD,BD);
                    RD:=(RS-RD)*Round(HC) ShR 8+RD;
                    GD:=(GS-GD)*Round(HC) ShR 8+GD;
                    BD:=(BS-BD)*Round(HC) ShR 8+BD;
                    ColorDest:=RGB2LongWord(RD,GD,BD);
                    Buffer.PutPixel(X+I,Y+J,ColorDest);
                  End;
                HC:=HC+MH;
              End;
            LC:=LC+MC1;
            RC:=RC+MC2;
          End;
      End;
  End;

PROCEDURE TestEffect;
  Var Z : Word;
  Begin
    EffectSprite(Image,Buffer,10,10,0,0,255,255,65535);
    Buffer.Flip(True);
    Depth:=128;DI:=1;
    Time:=TimeGetTime;
    For Z:=0 to 100 do
      EffectSprite(Image,Buffer,10,10,0,0,255,255,65535);
    Time:=TimeGetTime-Time;
    //Z:=Img.GetPixel(0,0,0);
    Buffer.FillRect(0,0,300,30,0);
    Buffer.WriteStr(10,10,Format('%d %d',[Time,Spr.DataSize]),65535);
    Buffer.Flip(True);
    Repeat
      {If (Depth<=1) or (Depth>=255) then DI:=-DI;
      Depth:=Depth+DI;
      BG.Copy(Buffer,0,0);
      EffectSprite(Image,Buffer,10,10,Depth,Depth,255,255,65535);
      Buffer.Flip(True);}
    Until Input.KeyDown(K_Escape) or (Screen.DoEvents=False);
  End;

PROCEDURE TestSpeed;
  Var Img    : TAvenusImage;
      Spr    : TAvenusSprite;
      Z,Time : LongWord;
  Begin
    Img:=TAvenusImage.Create(Screen,'blueenv.jpg',False);
    Spr:=TAvenusSprite.Create(1);
    Spr.LoadImage(0,'blueenv.jpg',False);
    Time:=TimeGetTime;
    For Z:=1 to 10000 do
      Img.Copy(Buffer,100,100);
    Time:=TimeGetTime-Time;
    Buffer.WriteStr(0,0,Format('%d',[Time]),RGB2LongWord(255,255,255));
    Buffer.Flip(False);
    Time:=TimeGetTime;
    For Z:=1 to 10000 do
      Img.CopySprite(Buffer,100,100,0);
    Time:=TimeGetTime-Time;
    Buffer.WriteStr(0,20,Format('%d',[Time]),RGB2LongWord(255,255,255));
    Buffer.Flip(False);
    Time:=TimeGetTime;
    For Z:=1 to 10000 do
      Spr.Copy(0,Buffer,100,100);
    Time:=TimeGetTime-Time;
    Buffer.WriteStr(0,40,Format('%d',[Time]),RGB2LongWord(255,255,255));
    Buffer.Flip(False);
    Time:=TimeGetTime;
    For Z:=1 to 10000 do
      Spr.CopySprite(0,Buffer,100,100,0);
    Time:=TimeGetTime-Time;
    Buffer.WriteStr(0,60,Format('%d',[Time]),RGB2LongWord(255,255,255));
    Buffer.Flip(False);
  End;

PROCEDURE TestSpeed1;
  Var Img    : TAvenusImage;
      Spr    : TAvenusSprite;
      Z,Time,Frame : LongWord;
  Begin
    Img:=TAvenusImage.Create(Screen,'blueenv.jpg',False);
    Spr:=TAvenusSprite.Create(1);
    Spr.LoadImage(0,'blueenv.jpg',False);
    Frame:=0;
    Time:=TimeGetTime;
    Repeat
      For Z:=1 to 20 do
        Begin
          Img.Copy(Buffer,0,0);
          Spr.Copy(0,Buffer,300,300);
        End;
      Inc(Frame);
      Buffer.WriteStr(0,0,Format('%3.2f',[Frame/(TimeGetTime-Time)*1000]),RGB2LongWord(255,255,255));
      //Buffer.Flip(False);
    Until Input.KeyDown(K_Escape);// or (Screen.DoEvents=False);
    Buffer.Flip(False);
    Repeat Until (Screen.DoEvents=False);
  End;

BEGIN
  For Z:=0 to 1024 do
    ASin[Z]:=Trunc(Sin(3.14159265*(Z/512))*1024);
  Screen:=TSelfAvenus.Create(SizeX,SizeY,'Crazy Babe');
  //Screen:=TSelfFullAvenus.Create(SizeX,SizeY,32,'Crazy Babe');
  Buffer:=TAvenusBuffer.Create(Screen,SizeX,SizeY,False);
  Image:=TAvenusImage.Create(Screen,'Ogre.png',False);
  BG:=TAvenusImage.Create(Screen,'war3water.jpg',False);
  BG.Copy(Buffer,0,0);
  Input:=TAvenusInput.Create(Screen.Handle);
  //GouraudSprite(Image,Buffer,10,10,0,0,65535,65535,65535);
  EffectSprite(Image,Buffer,10,10,0,0,255,255,65535);
  Buffer.Flip(True);
  Depth:=128;DI:=1;
  //TestRLE;
  //TestEffect;
  //TestSpeed1;
  Img:=TAvenusImage.Create(Screen,'F11.png',False);
  Repeat
    Img.Copy(Buffer,0,0);
    For Z:=0 to 20 do
      Begin
        Buffer.Line(0,Z*32,SizeX,Z*32,65535);
        Buffer.Line(Z*32,0,Z*32,SizeY,65535);
      End;
    X:=(Input.M_X div 32)*32;
    Y:=(Input.M_Y div 32)*32;
    Buffer.WriteStr(10,10,Format('%d %d',[X,Y]),65535);
    Buffer.Flip(True);
  Until Input.KeyDown(K_Escape) or (Screen.DoEvents=False);
  Input.Free;
  Image.Free;
  Buffer.Free;
  Screen.Free;
END.
