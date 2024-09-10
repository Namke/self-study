UNIT FastBlend;

INTERFACE
{$R-}
USES Windows,FastDIB;

PROCEDURE AvgBlend(Dst,Src1,Src2 : TFastDIB);
PROCEDURE DifBlend(Dst,Src1,Src2 : TFastDIB);
PROCEDURE SubBlend(Dst,Src1,Src2 : TFastDIB);
PROCEDURE AddBlend(Dst,Src1,Src2 : TFastDIB);
PROCEDURE MulBlend(Dst,Src1,Src2 : TFastDIB);
PROCEDURE AlphaBlend(Dst,Src1,Src2 : TFastDIB;Alpha : Integer);

IMPLEMENTATION

PROCEDURE AvgMem(Dst,Src1,Src2 : Pointer;Size,Mask : Integer);
//Dst= EAX; Src1 = EDX; Src2 = ECX;
//Size = [EBP+12]; Mask = [EBP+8]; S = [EBP-4]; A = [EBP-8]; B = [EBP-12];
  Var S,A,B : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+12]
    Push ECX
    Mov  S,ESP
    Mov  ESP,EAX
    And  ECX,$FFFFFFFC
    JZ   @Skip
    Add  ECX,EAX
    Mov  [EBP+12],ECX
    Mov  EAX,[EBP+8]
    // (A+B)/2 = (A And  B)+((A xor B)/2)
    @DWords:
    Mov  EBX,[EDI]
    Mov  EDX,[ESI]
    Mov  ECX,EBX
    And  EBX,EDX
    Xor  EDX,ECX
    Shr  EDX,1
    And  EDX,EAX
    Add  EDX,EBX
    Mov  [ESP],EDX
    Add  EDI,4
    Add  ESI,4
    Add  ESP,4
    Cmp  ESP,[EBP+12]
    JnE  @DWords
    @Skip:
    Mov  EAX,ESP
    Mov  ESP,S
    Pop  ECX
    And  ECX,11b
    JZ   @Exit
    Mov  EDX,ECX
    Push EDI
    LEA  EDI,A
    Rep  MovSB
    Mov  ECX,EDX
    Pop  ESI
    LEA  EDI,B
    Rep  MovSB
    Mov  EBX,B
    Mov  ECX,A
    And  EBX,ECX
    Xor  ECX,B
    Shr  ECX,1
    And  ECX,[EBP+8]
    Add  ECX,EBX
    Mov  B,ECX
    Mov  ECX,EDX
    LEA  ESI,B
    Mov  EDI,EAX
    Rep  MovSB
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE AvgMemMMX(Dst,Src1,Src2 : Pointer;Size,Mask : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX;
//Size = [EBP+12]; Mask = [EBP+8]; A:B = [EBP-8]
  Var A,B : Integer;
  Asm
    Push  EDI
    Push  ESI
    Mov   A,0
    Mov   B,0
    Mov   EDI,EDX
    Mov   ESI,ECX
    Mov   ECX,[EBP+12]
    MovD  MM3,[EBP+8]
    MovQ  MM4,MM3
    PsllQ MM4,32
    POr   MM3,MM4
    //DB $0F,$6E,$5D,$08 /// MovD  MM3,[EBP+8]
    //DB $0F,$6F,$E3     /// MovQ  MM4,MM3
    //DB $0F,$73,$F4,$20 /// PsllQ MM4,32
    //DB $0F,$EB,$DC     /// POr   MM3,MM4
    Shr   ECX,3
    JZ    @Skip
    @Quads:
    MovQ  MM0,[EDI]
    MovQ  MM1,[ESI]
    MovQ  MM2,MM0
    PAnd  MM0,MM1
    PXor  MM1,MM2
    PSrlQ MM1,1
    PAnd  MM1,MM3
    PAddD MM1,MM0
    MovQ  [EAX],MM1
    //DB $0F,$6F,$07     /// MovQ  MM0,[EDI]
    //DB $0F,$6F,$0E     /// MovQ  MM1,[ESI]
    //DB $0F,$6F,$D0     /// MovQ  MM2,MM0
    //DB $0F,$DB,$C1     /// PAnd  MM0,MM1
    //DB $0F,$EF,$CA     /// PXor  MM1,MM2
    //DB $0F,$73,$D1,$01 /// PSrlQ MM1,1
    //DB $0F,$DB,$CB     /// PAnd  MM1,MM3
    //DB $0F,$FE,$C8     /// PAddD MM1,MM0
    //DB $0F,$7F,$08     /// MovQ  [EAX],MM1
    Add   EDI,8
    Add   ESI,8
    Add   EAX,8
    Dec   ECX
    JnZ   @Quads
    @Skip:
    Mov   ECX,[EBP+12]
    And   ECX,111b
    JZ    @Exit
    Mov   EDX,ECX
    Push  EDI
    LEA   EDI,[EBP-8]
    Rep   MovSB
    //DB $0F,$6F,$8D,$F8,$FF,$FF,$FF /// MovQ MM1,[EBP-8]
    MovQ  MM1,[EBP-8]
    Mov   ECX,EDX
    Pop   ESI
    LEA   EDI,[EBP-8]
    Rep   MovSB
    MovQ  MM0,[EBP-8]
    MovQ  MM2,MM0
    PAnd  MM0,MM1
    PXor  MM1,MM2
    PSrlQ MM1,1
    PAnd  MM1,MM3
    PAddD MM1,MM0
    MovQ  [EBP-8],MM1
    //DB $0F,$6F,$85,$F8,$FF,$FF,$FF /// MovQ MM0,[EBP-8]
    //DB $0F,$6F,$D0                 /// MovQ  MM2,MM0
    //DB $0F,$DB,$C1                 /// PAnd  MM0,MM1
    //DB $0F,$EF,$CA                 /// PXor  MM1,MM2
    //DB $0F,$73,$D1,$01             /// PSrlQ MM1,1
    //DB $0F,$DB,$CB                 /// PAnd  MM1,MM3
    //DB $0F,$FE,$C8                 /// PAddD MM1,MM0
    //DB $0F,$7F,$8D,$F8,$FF,$FF,$FF /// MovQ  [EBP-8],MM1
    Mov   ECX,EDX
    LEA   ESI,[EBP-8]
    Mov   EDI,EAX
    Rep   MovSB
    @Exit:
    EMMS
    //DB  $0F,$77 // EMMS
    Pop   ESI
    Pop   EDI
  End;

PROCEDURE AvgBlend(Dst,Src1,Src2 : TFastDIB);
  Type TAvgMemProc = Procedure(Dst,Src1,Src2 : Pointer;Size,Mask : Integer);
  Var I,Mask  : Integer;
      AvgProc : TAvgMemProc;
  Begin
    Case Dst.Bpp of
      8,24  : Mask:=$7F7F7F7F;
      16,32 :
        Begin
          Mask:=((Dst.RMask+(1 ShL Dst.RShl)) or
                 (Dst.GMask+(1 ShL Dst.GShl)) or
                 (Dst.BMask+1)) ShR 1;
          If Dst.Bpp=16 then Mask:=(Mask ShL 16 or Mask) xor -1
          Else Mask:=Mask xor -1;
        End;
      Else Mask:=0;
    End;
    If cfMMX in CPUInfo.Features then AvgProc:=AvgMemMMX Else AvgProc:=AvgMem;
    For I:=0 to Dst.AbsHeight-1 do
      AvgProc(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap,Mask);
  End;

PROCEDURE DifMem16(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX
//Size = [EBP+8]; A = [EBP-4]; B = [EBP-8];C = [EBP-12]
  Var A,B,C : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    And  ECX,$FFFFFFFC
    JZ   @Skip
    Add  ECX,EAX
    Mov  [EBP+8],ECX
    @DWords:
    Mov  ECX,[EDI]
    Mov  EBX,[ESI]
    And  ECX,$001F001F
    And  EBX,$001F001F
    Or   ECX,$00200020
    Sub  ECX,EBX
    Mov  EBX,ECX
    And  EBX,$00200020
    ShR  EBX,5
    IMul EBX,$1F
    Xor  ECX,EBX
    Mov  EDX,[EDI]
    Mov  EBX,[ESI]
    And  EDX,$07E007E0
    And  EBX,$07E007E0
    ShR  EDX,5
    ShR  EBX,5
    Or   EDX,$00400040
    Sub  EDX,EBX
    Mov  EBX,EDX
    And  EBX,$00400040
    ShR  EBX,6
    IMul EBX,$3F
    Xor  EDX,EBX
    ShL  EDX,5
    Or   ECX,EDX
    Mov  EDX,[EDI]
    Mov  EBX,[ESI]
    And  EDX,$F800F800
    And  EBX,$F800F800
    ShR  EDX,11
    ShR  EBX,11
    Or   EDX,$00200020
    Sub  EDX,EBX
    Mov  EBX,EDX
    And  EBX,$00200020
    ShR  EBX,5
    IMul EBX,$1F
    Xor  EDX,EBX
    ShL  EDX,11
    Or   ECX,EDX
    Xor  ECX,-1
    Mov  [EAX],ECX
    Add  EDI,4
    Add  ESI,4
    Add  EAX,4
    Cmp  EAX,[EBP+8]
    JnE  @DWords
    Cmp  EDI,EBP
    JE   @Last
    @Skip:
    Pop  ECX
    And  ECX,11b
    ShR  ECX,1
    JZ   @Exit
    Mov  CX,[EDI]
    Mov  BX,[ESI]
    Mov  A,ECX
    Mov  B,EBX
    LEA  EDI,A
    LEA  ESI,B
    Push EAX
    LEA  EAX,C
    LEA  EBX,[EAX+4]
    Mov  [EBP+8],EBX
    Jmp  @DWords
    @Last:
    Pop  EAX
    Mov  EBX,[EBP-12]
    Mov  [EAX],BX
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE DifMem16MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX
//Size = [EBP+8]; B1:B2 = [EBP-8]; G1:G2 =[EBP-16]; M1:M2 = [EBP-24]
  Var B1,B2,G1,G2,M1,M2 : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  B1,$001F001F
    Mov  B2,$001F001F
    Mov  G1,$07E007E0
    Mov  G2,$07E007E0
    Mov  M2,0
    Mov  M1,0
    PCmpEQD MM7,MM7
    PSrlW   MM7,11
    PSllQ   MM7,11
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,3
    JZ   @Skip
    @Quads:
    MovQ    MM0,[EDI]
    MovQ    MM1,[ESI]
    @cleanup:
    MovQ    MM2,MM0
    MovQ    MM3,MM1
    MovQ    MM4,MM0
    MovQ    MM5,MM1
    PAnd    MM0,[EBP-8]
    PAnd    MM1,[EBP-8]
    MovQ    MM6,MM0
    PSubUSW MM0,MM1
    PSubUSW MM1,MM6
    PAddUSW MM0,MM1
    PAnd    MM2,[EBP-16]
    PAnd    MM3,[EBP-16]
    PSrlW   MM2,5
    PSrlW   MM3,5
    MovQ    MM6,MM2
    PSubUSW MM2,MM3
    PSubUSW MM3,MM6
    PAddUSW MM2,MM3
    PSllQ   MM2,5
    POr     MM0,MM2
    PAnd    MM4,MM7
    PAnd    MM5,MM7
    PSrlW   MM4,11
    PSrlW   MM5,11
    MovQ    MM6,MM4
    PSubUSW MM4,MM5
    PSubUSW MM5,MM6
    PAddUSW MM4,MM5
    PSllQ   MM4,11
    POr     MM0,MM4
    MovQ   [EAX],MM0
    Add  EDI,8
    Add  ESI,8
    Add  EAX,8
    Dec  ECX
    JnZ  @Quads
    Cmp  EDI,0
    JE  @Last
    @Skip:
    Pop  ECX
    And  ECX,111b
    ShR  ECX,1
    JZ   @Exit
    Mov  EDX,ECX
    Push EDI
    LEA  EDI,M1
    Rep  MovSW
    MovQ MM1,[EBP-24]
    Pop  ESI
    Mov  ECX,EDX
    LEA  EDI,M1
    Rep  MovSW
    MovQ MM0,[EBP-24]
    Push EAX
    LEA  EAX,M1
    Mov  EDI,-8
    Mov  ECX,1
    Jmp  @cleanup
    @Last:
    Pop  EDI
    LEA  ESI,M1
    Mov  ECX,EDX
    Rep  MovSW
    @Exit:
    EMMS
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE DifBlend16(Dst,Src1,Src2 : TFastDIB);
  Type TDifMem16REG  =  Array[0..256]of Byte;
       PDifMem16REG  = ^TDifMem16REG;
       TDifMem16MMX  =  Array[0..299]of Byte;
       PDifMem16MMX  = ^TDifMem16MMX;
       TDifMem16Proc = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Const
    DifMem16REG : TDifMem16REG =
    ($55,$8B,$EC,$83,$C4,$F4,$53,$57,$56,$89,$D7,$89,$CE,$8B,$4D,$08,$51,$83,$E1,
     $FC,$0F,$84,$AE,$00,$00,$00,$01,$C1,$89,$4D,$08,$8B,$0F,$8B,$1E,$81,$E1,$1F,
     $00,$1F,$00,$81,$E3,$1F,$00,$1F,$00,$81,$C9,$20,$00,$20,$00,$29,$D9,$89,$CB,
     $81,$E3,$20,$00,$20,$00,$C1,$EB,$05,$6B,$DB,$1F,$31,$D9,$8B,$17,$8B,$1E,$81,
     $E2,$E0,$07,$E0,$07,$81,$E3,$E0,$07,$E0,$07,$C1,$EA,$05,$C1,$EB,$05,$81,$CA,
     $40,$00,$40,$00,$29,$DA,$89,$D3,$81,$E3,$40,$00,$40,$00,$C1,$EB,$06,$6B,$DB,
     $3F,$31,$DA,$C1,$E2,$05,$09,$D1,$8B,$17,$8B,$1E,$81,$E2,$00,$F8,$00,$F8,$81,
     $E3,$00,$F8,$00,$F8,$C1,$EA,$0B,$C1,$EB,$0B,$81,$CA,$20,$00,$20,$00,$29,$DA,
     $89,$D3,$81,$E3,$20,$00,$20,$00,$C1,$EB,$05,$6B,$DB,$1F,$31,$DA,$C1,$E2,$0B,
     $09,$D1,$83,$F1,$FF,$89,$08,$83,$C7,$04,$83,$C6,$04,$83,$C0,$04,$3B,$45,$08,
     $0F,$85,$5B,$FF,$FF,$FF,$39,$EF,$74,$29,$59,$83,$E1,$03,$D1,$E9,$74,$28,$66,
     $8B,$0F,$66,$8B,$1E,$89,$4D,$FC,$89,$5D,$F8,$8D,$7D,$FC,$8D,$75,$F8,$50,$8D,
     $45,$F4,$8D,$58,$04,$89,$5D,$08,$E9,$2E,$FF,$FF,$FF,$58,$8B,$5D,$F4,$66,$89,
     $18,$5E,$5F,$5B,$8B,$E5,$5D,$C2,$04,$00);
    DifMem16MMX : TDifMem16MMX =
    ($55,$8B,$EC,$83,$C4,$E8,$53,$57,$56,$C7,$45,$FC,$1F,$00,$1F,$00,$C7,$45,$F8,
     $1F,$00,$1F,$00,$C7,$45,$F4,$E0,$07,$E0,$07,$C7,$45,$F0,$E0,$07,$E0,$07,$C7,
     $45,$EC,$00,$00,$00,$00,$C7,$45,$E8,$00,$00,$00,$00,$0F,$76,$FF,$0F,$71,$D7,
     $0B,$0F,$71,$F7,$0B,$89,$D7,$89,$CE,$8B,$4D,$08,$51,$C1,$E9,$03,$0F,$84,$8E,
     $00,$00,$00,$0F,$6F,$07,$0F,$6F,$0E,$0F,$6F,$D0,$0F,$6F,$D9,$0F,$6F,$E0,$0F,
     $6F,$E9,$0F,$DB,$85,$F8,$FF,$FF,$FF,$0F,$DB,$8D,$F8,$FF,$FF,$FF,$0F,$6F,$F0,
     $0F,$D9,$C1,$0F,$D9,$CE,$0F,$DD,$C1,$0F,$DB,$95,$F0,$FF,$FF,$FF,$0F,$DB,$9D,
     $F0,$FF,$FF,$FF,$0F,$71,$D2,$05,$0F,$71,$D3,$05,$0F,$6F,$F2,$0F,$D9,$D3,$0F,
     $D9,$DE,$0F,$DD,$D3,$0F,$71,$F2,$05,$0F,$EB,$C2,$0F,$DB,$E7,$0F,$DB,$EF,$0F,
     $71,$D4,$0B,$0F,$71,$D5,$0B,$0F,$6F,$F4,$0F,$D9,$E5,$0F,$D9,$EE,$0F,$DD,$E5,
     $0F,$71,$F4,$0B,$0F,$EB,$C4,$0F,$7F,$00,$83,$C7,$08,$83,$C6,$08,$83,$C0,$08,
     $49,$0F,$85,$77,$FF,$FF,$FF,$83,$FF,$00,$74,$3B,$59,$83,$E1,$07,$D1,$E9,$74,
     $3C,$89,$CA,$57,$8D,$7D,$E8,$66,$F3,$A5,$0F,$6F,$8D,$E8,$FF,$FF,$FF,$5E,$89,
     $D1,$8D,$7D,$E8,$66,$F3,$A5,$0F,$6F,$85,$E8,$FF,$FF,$FF,$50,$8D,$45,$E8,$BF,
     $F8,$FF,$FF,$FF,$B9,$01,$00,$00,$00,$E9,$3D,$FF,$FF,$FF,$5F,$8D,$75,$E8,$89,
     $D1,$66,$F3,$A5,$0F,$77,$5E,$5F,$5B,$8B,$E5,$5D,$C2,$04,$00);
  Var I    : Integer;
      Code : PLine8;
  Begin
    If cfMMX in CPUInfo.Features then
      Begin
        GetMem(Code,SizeOf(TDifMem16MMX));
        PDifMem16MMX(Code)^:=DifMem16MMX;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[12])^:=I;
        PDWord(@Code[19])^:=I;
        I:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[26])^:=I;
        PDWord(@Code[33])^:=I;
        Code[57]:=16-Dst.Bpr;
        Code[61]:=Dst.RShl;
        Code[140]:=Dst.GShl;
        Code[144]:=Dst.GShl;
        Code[160]:=Dst.GShl;
        Code[173]:=Dst.RShl;
        Code[177]:=Dst.RShl;
        Code[193]:=Dst.RShl;
      End
    Else
      Begin
        GetMem(Code,SizeOf(TDifMem16REG));
        PDifMem16REG(Code)^:=DifMem16REG;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[37])^:=I;
        PDWord(@Code[43])^:=I;
        I:=(I+I) and (not I);
        PDWord(@Code[49])^:=I;
        PDWord(@Code[59])^:=I;
        I:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[77])^:=I;
        PDWord(@Code[83])^:=I;
        I:=I ShR Dst.GShl;
        I:=(I+I) and (not I);
        PDWord(@Code[95])^:=I;
        PDWord(@Code[105])^:=I;
        I:=Dst.RMask ShL 16 or Dst.RMask;
        PDWord(@Code[128])^:=I;
        PDWord(@Code[134])^:=I;
        I:=I ShR Dst.RShl;
        I:=(I+I)And (not I);
        PDWord(@Code[146])^:=I;
        PDWord(@Code[156])^:=I;
        Code[65]:=Dst.Bpb;
        Code[68]:=(1 ShL Dst.Bpb)-1;
        Code[89]:=Dst.GShl;
        Code[92]:=Dst.GShl;
        Code[111]:=Dst.Bpg;
        Code[114]:=(1 ShL Dst.Bpg)-1;
        Code[119]:=Dst.GShl;
        Code[140]:=Dst.RShl;
        Code[143]:=Dst.RShl;
        Code[162]:=Dst.Bpr;
        Code[165]:=(1 ShL Dst.Bpr)-1;
        Code[170]:=Dst.RShl;
      End;
    For I:=0 to Dst.AbsHeight-1 do
      TDifMem16Proc(Code)(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
    FreeMem(Code);
  End;

PROCEDURE DifMem8(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX;
//Size = [EBP+8]; S = [EBP-4]
  Var S : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    Mov  S,ESP
    Mov  ESP,EAX
    And  ECX,$FFFFFFFC
    JZ   @Skip
    Add  ECX,EAX
    Mov  [EBP+8],ECX
    @DWords:
    Mov  ECX,[EDI]
    Mov  EBX,[ESI]
    Mov  EAX,ECX
    Mov  EDX,EBX
    And  ECX,$00FF00FF
    And  EBX,$00FF00FF
    Or   ECX,$01000100
    Sub  ECX,EBX
    Mov  EBX,ECX
    And  EBX,$01000100
    IMul EBX,$FF
    ShR  EBX,8
    Xor  ECX,EBX
    And  EAX,$FF00FF00
    And  EDX,$FF00FF00
    ShR  EAX,8
    ShR  EDX,8
    Or   EAX,$01000100
    Sub  EAX,EDX
    Mov  EDX,EAX
    And  EDX,$01000100
    IMul EDX,$FF
    ShR  EDX,8
    Xor  EAX,EDX
    ShL  EAX,8
    Or   ECX,EAX
    Xor  ECX,-1
    Mov  [ESP],ECX
    Add  EDI,4
    Add  ESI,4
    Add  ESP,4
    Cmp  ESP,[EBP+8]
    JnE  @DWords
    @Skip:
    Mov  EAX,ESP
    Mov  ESP,S
    Pop  ECX
    And  ECX,11b
    JZ   @Exit
    @Bytes:
    MovZX EBX,Byte([EDI])
    MovZX EDX,Byte([ESI])
    Sub   EBX,EDX
    Mov   EDX,EBX
    ShR   EDX,8
    Xor   EBX,EDX
    Mov   [EAX],bl
    Inc   EDI
    Inc   ESI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE DifMem8MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8]
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,3
    JZ   @Skip
    @Quads:
    MovQ    MM0,[EDI]
    MovQ    MM1,[ESI]
    MovQ    MM2,MM0
    psubusb MM0,MM1
    psubusb MM1,MM2
    paddusb MM0,MM1
    MovQ    [EAX],MM0
    //DB $0F,$6F,$07  /// MovQ    MM0,[EDI]
    //DB $0F,$6F,$0E  /// MovQ    MM1,[ESI]
    //DB $0F,$6F,$D0  /// MovQ    MM2,MM0
    //DB $0F,$D8,$C1  /// psubusb MM0,MM1
    //DB $0F,$D8,$CA  /// psubusb MM1,MM2
    //DB $0F,$DC,$C1  /// paddusb MM0,MM1
    //DB $0F,$7F,$00  /// MovQ    [EAX],MM0
    Add  EDI,8
    Add  ESI,8
    Add  EAX,8
    Dec  ECX
    JnZ  @Quads
    EMMS
    //DB $0F,$77 // EMMS
    @Skip:
    Pop  ECX
    And  ECX,111b
    JZ   @Exit
    @Bytes:
    MovZX EBX,Byte([EDI])
    MovZX EDX,Byte([ESI])
    Sub   EBX,EDX
    Mov   EDX,EBX
    ShR   EDX,8
    Xor   EBX,EDX
    Mov   [EAX],bl
    Inc   EDI
    Inc   ESI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE DifBlend8(Dst,Src1,Src2 : TFastDIB);
  Type TDifMem8Proc = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Var I      : Integer;
      DifMem : TDifMem8Proc;
  Begin
    If cfMMX in CPUInfo.Features then DifMem:=DifMem8MMX Else DifMem:=DifMem8;
    For I:=0 to Dst.AbsHeight-1 do
      DifMem(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
  End;

PROCEDURE DifBlend(Dst,Src1,Src2 : TFastDIB);
  Begin
    Case Dst.Bpp of
      8,24,32 : DifBlend8(Dst,Src1,Src2);
      16      : DifBlend16(Dst,Src1,Src2);
    End;
  End;
  
PROCEDURE SubMem16(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX;
//Size = [EBP+8]; A = [EBP-4]; B = [EBP-8]; C = [EBP-12]
  Var A,B,C : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    And  ECX,$FFFFFFFC
    JZ   @Skip
    Add  ECX,EAX
    Mov  [EBP+8],ECX
    @DWords:
    Mov  ECX,[EDI]
    Mov  EBX,[ESI]
    And  ECX,$001F001F
    And  EBX,$001F001F
    Or   ECX,$00200020
    Sub  ECX,EBX
    Mov  EBX,ECX
    And  EBX,$00200020
    ShR  EBX,5
    IMul EBX,$1F
    And  ECX,EBX
    Mov  EDX,[EDI]
    Mov  EBX,[ESI]
    And  EDX,$07E007E0
    And  EBX,$07E007E0
    ShR  EDX,5
    ShR  EBX,5
    Or   EDX,$00400040
    Sub  EDX,EBX
    Mov  EBX,EDX
    And  EBX,$00400040
    ShR  EBX,6
    IMul EBX,$3F
    And  EDX,EBX
    ShL  EDX,5
    Or   ECX,EDX
    Mov  EDX,[EDI]
    Mov  EBX,[ESI]
    And  EDX,$F800F800
    And  EBX,$F800F800
    ShR  EDX,11
    ShR  EBX,11
    Or   EDX,$00200020
    Sub  EDX,EBX
    Mov  EBX,EDX
    And  EBX,$00200020
    ShR  EBX,5
    IMul EBX,$1F
    And  EDX,EBX
    ShL  EDX,11
    Or   ECX,EDX
    Mov  [EAX],ECX
    Add  EDI,4
    Add  ESI,4
    Add  EAX,4
    Cmp  EAX,[EBP+8]
    JnE  @DWords
    Cmp  EDI,EBP
    JE   @Last
    @Skip:
    Pop  ECX
    And  ECX,11b
    ShR  ECX,1
    JZ   @Exit
    Mov  CX,[EDI]
    Mov  BX,[ESI]
    Mov  A,ECX
    Mov  B,EBX
    LEA  EDI,A
    LEA  ESI,B
    Push EAX
    LEA  EAX,C
    LEA  EBX,[EAX+4]
    Mov  [EBP+8],EBX
    Jmp  @DWords
    @Last:
    Pop  EAX
    Mov  EBX,[EBP-12]
    Mov [EAX],BX
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE SubMem16MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX
//Size = [EBP+8]; B1:B2 = [EBP-8]; M1:M2 = [EBP-16]
  Var B1,B2,M1,M2 : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  B1,$001F001F
    Mov  B2,$001F001F
    Mov  M2,0
    Mov  M1,0
    PCmpEQD MM6,MM6
    PSrlW   MM6,10
    PSllQ   MM6,5
    PCmpEQD MM7,MM7
    PSrlW   MM7,11
    PSllQ   MM7,11
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,3
    JZ   @Skip
    @Quads:
    MovQ    MM0,[EDI]
    MovQ    MM1,[ESI]
    @cleanup:
    MovQ    MM2,MM0
    MovQ    MM3,MM1
    MovQ    MM4,MM0
    MovQ    MM5,MM1
    PAnd    MM0,[EBP-8]
    PAnd    MM1,[EBP-8]
    PSubUSW MM0,MM1
    PAnd    MM2,MM6
    PAnd    MM3,MM6
    PSrlW   MM2,5
    PSrlW   MM3,5
    PSubUSW MM2,MM3
    PSllQ   MM2,5
    POr     MM0,MM2
    PAnd    MM4,MM7
    PAnd    MM5,MM7
    PSrlW   MM4,11
    PSrlW   MM5,11
    PSubUSW MM4,MM5
    PSllQ   MM4,11
    POr     MM0,MM4
    MovQ [EAX],MM0
    Add  EDI,8
    Add  ESI,8
    Add  EAX,8
    Dec  ECX
    JnZ  @Quads
    Cmp  EDI,0
    JE  @Last
    @Skip:
    Pop  ECX
    And  ECX,111b
    ShR  ECX,1
    JZ   @Exit
    Mov  EDX,ECX
    Push EDI
    LEA  EDI,M1
    Rep  MovSW
    MovQ MM1,[EBP-16]
    Pop  ESI
    Mov  ECX,EDX
    LEA  EDI,M1
    Rep  MovSW
    MovQ MM0,[EBP-16]
    Push EAX
    LEA  EAX,M1
    Mov  EDI,-8
    Mov  ECX,1
    Jmp  @cleanup
    @Last:
    Pop  EDI
    LEA  ESI,M1
    Mov  ECX,EDX
    Rep  MovSW
    @Exit:
    EMMS
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE SubBlend16(Dst,Src1,Src2 : TFastDIB);
  Type TSubMem16REG  = Array[0..253]of Byte;
       PSubMem16REG  = ^TSubMem16REG;
       TSubMem16MMX  = Array[0..253]of Byte;
       PSubMem16MMX  = ^TSubMem16MMX;
       TSubMem16Proc = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Const
    SubMem16REG : TSubMem16REG =
    ($55,$8B,$EC,$83,$C4,$F4,$53,$57,$56,$89,$D7,$89,$CE,$8B,$4D,$08,$51,$83,$E1,
     $FC,$0F,$84,$AB,$00,$00,$00,$01,$C1,$89,$4D,$08,$8B,$0F,$8B,$1E,$81,$E1,$1F,
     $00,$1F,$00,$81,$E3,$1F,$00,$1F,$00,$81,$C9,$20,$00,$20,$00,$29,$D9,$89,$CB,
     $81,$E3,$20,$00,$20,$00,$C1,$EB,$05,$6B,$DB,$1F,$21,$D9,$8B,$17,$8B,$1E,$81,
     $E2,$E0,$07,$E0,$07,$81,$E3,$E0,$07,$E0,$07,$C1,$EA,$05,$C1,$EB,$05,$81,$CA,
     $40,$00,$40,$00,$29,$DA,$89,$D3,$81,$E3,$40,$00,$40,$00,$C1,$EB,$06,$6B,$DB,
     $3F,$21,$DA,$C1,$E2,$05,$09,$D1,$8B,$17,$8B,$1E,$81,$E2,$00,$F8,$00,$F8,$81,
     $E3,$00,$F8,$00,$F8,$C1,$EA,$0B,$C1,$EB,$0B,$81,$CA,$20,$00,$20,$00,$29,$DA,
     $89,$D3,$81,$E3,$20,$00,$20,$00,$C1,$EB,$05,$6B,$DB,$1F,$21,$DA,$C1,$E2,$0B,
     $09,$D1,$89,$08,$83,$C7,$04,$83,$C6,$04,$83,$C0,$04,$3B,$45,$08,$0F,$85,$5E,
     $FF,$FF,$FF,$39,$EF,$74,$29,$59,$83,$E1,$03,$D1,$E9,$74,$28,$66,$8B,$0F,$66,
     $8B,$1E,$89,$4D,$FC,$89,$5D,$F8,$8D,$7D,$FC,$8D,$75,$F8,$50,$8D,$45,$F4,$8D,
     $58,$04,$89,$5D,$08,$E9,$31,$FF,$FF,$FF,$58,$8B,$5D,$F4,$66,$89,$18,$5E,$5F,
     $5B,$8B,$E5,$5D,$C2,$04,$00);
    SubMem16MMX : TSubMem16MMX =
    ($55,$8B,$EC,$83,$C4,$F0,$53,$57,$56,$C7,$45,$FC,$1F,$00,$1F,$00,$C7,$45,$F8,
     $1F,$00,$1F,$00,$C7,$45,$F4,$00,$00,$00,$00,$C7,$45,$F0,$00,$00,$00,$00,$0F,
     $76,$F6,$0F,$71,$D6,$0A,$0F,$71,$F6,$05,$0F,$76,$FF,$0F,$71,$D7,$0B,$0F,$71,
     $F7,$0B,$89,$D7,$89,$CE,$8B,$4D,$08,$51,$C1,$E9,$03,$74,$67,$0F,$6F,$07,$0F,
     $6F,$0E,$0F,$6F,$D0,$0F,$6F,$D9,$0F,$6F,$E0,$0F,$6F,$E9,$0F,$DB,$85,$F8,$FF,
     $FF,$FF,$0F,$DB,$8D,$F8,$FF,$FF,$FF,$0F,$D9,$C1,$0F,$DB,$D6,$0F,$DB,$DE,$0F,
     $71,$D2,$05,$0F,$71,$D3,$05,$0F,$D9,$D3,$0F,$71,$F2,$05,$0F,$EB,$C2,$0F,$DB,
     $E7,$0F,$DB,$EF,$0F,$71,$D4,$0B,$0F,$71,$D5,$0B,$0F,$D9,$E5,$0F,$71,$F4,$0B,
     $0F,$EB,$C4,$0F,$7F,$00,$83,$C7,$08,$83,$C6,$08,$83,$C0,$08,$49,$75,$9E,$83,
     $FF,$00,$74,$3B,$59,$83,$E1,$07,$D1,$E9,$74,$3C,$89,$CA,$57,$8D,$7D,$F0,$66,
     $F3,$A5,$0F,$6F,$8D,$F0,$FF,$FF,$FF,$5E,$89,$D1,$8D,$7D,$F0,$66,$F3,$A5,$0F,
     $6F,$85,$F0,$FF,$FF,$FF,$50,$8D,$45,$F0,$BF,$F8,$FF,$FF,$FF,$B9,$01,$00,$00,
     $00,$E9,$64,$FF,$FF,$FF,$5F,$8D,$75,$F0,$89,$D1,$66,$F3,$A5,$0F,$77,$5E,$5F,
     $5B,$8B,$E5,$5D,$C2,$04,$00);
  Var I    : Integer;
      Code : PLine8;
  Begin
    If cfMMX in CPUInfo.Features then
      Begin
        GetMem(Code,SizeOf(TSubMem16MMX));
        PSubMem16MMX(Code)^:=SubMem16MMX;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[12])^:=I;
        PDWord(@Code[19])^:=I;
        Code[43]:=16-Dst.Bpg;
        Code[47]:=Dst.GShl;
        Code[54]:=16-Dst.Bpr;
        Code[58]:=Dst.RShl;
        Code[116]:=Dst.GShl;
        Code[120]:=Dst.GShl;
        Code[127]:=Dst.GShl;
        Code[140]:=Dst.RShl;
        Code[144]:=Dst.RShl;
        Code[151]:=Dst.RShl;
      End
    Else
      Begin
        GetMem(Code,SizeOf(TSubMem16REG));
        PSubMem16REG(Code)^:=SubMem16REG;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[37])^:=I;
        PDWord(@Code[43])^:=I;
        I:=(I+I) and (Not I);
        PDWord(@Code[49])^:=I;
        PDWord(@Code[59])^:=I;
        I:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[77])^:=I;
        PDWord(@Code[83])^:=I;
        I:=I ShR Dst.GShl;
        I:=(I+I) and (Not I);
        PDWord(@Code[95])^:=I;
        PDWord(@Code[105])^:=I;
        I:=Dst.RMask ShL 16 or Dst.RMask;
        PDWord(@Code[128])^:=I;
        PDWord(@Code[134])^:=I;
        I:=I ShR Dst.RShl;
        I:=(I+I) and (Not I);
        PDWord(@Code[146])^:=I;
        PDWord(@Code[156])^:=I;
        Code[65]:=Dst.Bpb;
        Code[68]:=(1 ShL Dst.Bpb)-1;
        Code[89]:=Dst.GShl;
        Code[92]:=Dst.GShl;
        Code[111]:=Dst.Bpg;
        Code[114]:=(1 ShL Dst.Bpg)-1;
        Code[119]:=Dst.GShl;
        Code[140]:=Dst.RShl;
        Code[143]:=Dst.RShl;
        Code[162]:=Dst.Bpr;
        Code[165]:=(1 ShL Dst.Bpr)-1;
        Code[170]:=Dst.RShl;
      End;
    For I:=0 to Dst.AbsHeight-1 do
      TSubMem16Proc(Code)(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
    FreeMem(Code);
  End;

PROCEDURE SubMem8(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX
//Size = [EBP+8]; S = [EBP-4]
  Var S : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    Mov  S,ESP
    Mov  ESP,EAX
    And  ECX,$FFFFFFFC
    JZ   @Skip
    Add  ECX,EAX
    Mov  [EBP+8],ECX
    @DWords:
    Mov  ECX,[EDI]
    Mov  EBX,[ESI]
    Mov  EAX,ECX
    Mov  EDX,EBX
    And  ECX,$00FF00FF
    And  EBX,$00FF00FF
    Or   ECX,$01000100
    Sub  ECX,EBX
    Mov  EBX,ECX
    And  EBX,$01000100
    IMul EBX,$FF
    ShR  EBX,8
    And  ECX,EBX
    And  EAX,$FF00FF00
    And  EDX,$FF00FF00
    ShR  EAX,8
    ShR  EDX,8
    Or   EAX,$01000100
    Sub  EAX,EDX
    Mov  EDX,EAX
    And  EDX,$01000100
    IMul EDX,$FF
    ShR  EDX,8
    And  EAX,EDX
    ShL  EAX,8
    Or   ECX,EAX
    Mov  [ESP],ECX
    Add  EDI,4
    Add  ESI,4
    Add  ESP,4
    Cmp  ESP,[EBP+8]
    JnE  @DWords
    @Skip:
    Mov  EAX,ESP
    Mov  ESP,S
    Pop  ECX
    And  ECX,11b
    JZ   @Exit
    @Bytes:
    MovZX EBX,Byte([EDI])
    MovZX EDX,Byte([ESI])
    Sub   EBX,EDX
    Mov   EDX,EBX
    ShR   EDX,8
    Xor   EDX,-1
    And   EBX,EDX
    Mov   [EAX],bl
    Inc   EDI
    Inc   ESI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE SubMem8MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8]
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,3
    JZ   @Skip
    @Quads:
    MovQ    MM0,[EDI]
    MovQ    MM1,[ESI]
    PSubUSB MM0,MM1
    MovQ    [EAX],MM0
    //DB $0F,$6F,$07 /// MovQ    MM0,[EDI]
    //DB $0F,$6F,$0E /// MovQ    MM1,[ESI]
    //DB $0F,$D8,$C1 /// PSubUSB MM0,MM1
    //DB $0F,$7F,$00 /// MovQ    [EAX],MM0
    Add  EDI,8
    Add  ESI,8
    Add  EAX,8
    Dec  ECX
    JnZ  @Quads
    EMMS
    //DB $0F,$77 // EMMS
    @Skip:
    Pop  ECX
    And  ECX,111b
    JZ   @Exit
    @Bytes:
    MovZX EBX,Byte([EDI])
    MovZX EDX,Byte([ESI])
    Sub   EBX,EDX
    Mov   EDX,EBX
    ShR   EDX,8
    Xor   EDX,-1
    And   EBX,EDX
    Mov   [EAX],bl
    Inc   EDI
    Inc   ESI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE SubBlend8(Dst,Src1,Src2 : TFastDIB);
  Type TSubMem8Proc = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Var I      : Integer;
      SubMem : TSubMem8Proc;
  Begin
    If cfMMX in CPUInfo.Features then SubMem:=SubMem8MMX Else SubMem:=SubMem8;
    For I:=0 to Dst.AbsHeight-1 do
      SubMem(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
  End;

PROCEDURE SubBlend(Dst,Src1,Src2 : TFastDIB);
  Begin
    Case Dst.Bpp of
      8,24,32 : SubBlend8(Dst,Src1,Src2);
      16      : SubBlend16(Dst,Src1,Src2);
    End;
  End;

PROCEDURE AddMem16(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX
//Size = [EBP+8]; A = [EBP-4]; B = [EBP-8]; C = [EBP-12]
  Var A,B,C : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push CX
    And  ECX,$FFFFFFFC
    JZ   @Skip
    Add  ECX,EAX
    Mov  [EBP+8],ECX
    @DWords:
    Mov  ECX,[EDI]
    Mov  EBX,[ESI]
    And  ECX,$001F001F
    And  EBX,$001F001F
    Add  ECX,EBX
    Mov  EBX,ECX
    And  EBX,$00200020
    ShR  EBX,5
    IMul EBX,$1F
    Or   ECX,EBX
    Mov  EDX,[EDI]
    Mov  EBX,[ESI]
    And  EDX,$07E007E0
    And  EBX,$07E007E0
    ShR  EDX,5
    ShR  EBX,5
    Add  EDX,EBX
    Mov  EBX,EDX
    And  EBX,$00400040
    ShR  EBX,6
    IMul EBX,$3F
    Or   EDX,EBX
    ShL  EDX,5
    Or   ECX,EDX
    Mov  EDX,[EDI]
    Mov  EBX,[ESI]
    And  EDX,$F800F800
    And  EBX,$F800F800
    ShR  EDX,11
    ShR  EBX,11
    Add  EDX,EBX
    Mov  EBX,EDX
    And  EBX,$00200020
    ShR  EBX,5
    IMul EBX,$1F
    Or   EDX,EBX
    ShL  EDX,11
    Or   ECX,EDX
    Mov  [EAX],ECX
    Add  EDI,4
    Add  ESI,4
    Add  EAX,4
    Cmp  EAX,[EBP+8]
    JnE  @DWords
    Cmp  EDI,EBP
    JE   @Last
    @Skip:
    Pop  ECX
    And  ECX,11b
    ShR  ECX,1
    JZ   @Exit
    Mov  CX,[EDI]
    Mov  BX,[ESI]
    Mov  A,ECX
    Mov  B,EBX
    LEA  EDI,A
    LEA  ESI,B
    Push EAX
    LEA  EAX,C
    LEA  EBX,[EAX+4]
    Mov  [EBP+8],EBX
    Jmp  @DWords
    @Last:
    Pop  EAX
    Mov  EBX,[EBP-12]
    Mov  [EAX],BX
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE AddMem16MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8];
//B1:B2 = [EBP-8]; G1:G2 = [EBP-16]; R1:R2 = [EBP-24]; M1:M2 = [EBP-32]
  Var B1,B2,G1,G2,R1,R2,M1,M2 : Integer;
  Asm
    Push EDI
    Push ESI
    Mov  B1,$001F001F
    Mov  B2,$001F001F
    Mov  G1,$07E007E0
    Mov  G2,$07E007E0
    Mov  R1,$F800F800
    Mov  R2,$F800F800
    Mov  M2,0
    Mov  M1,0
    MovQ  MM6,[EBP-16]
    PSrlW MM6,5
    MovQ  MM7,[EBP-24]
    PSrlW MM7,11
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,3
    JZ   @Skip
    @Quads:
    MovQ    MM0,[EDI]
    MovQ    MM1,[ESI]
    @cleanup:
    MovQ    MM2,MM0
    MovQ    MM3,MM1
    MovQ    MM4,MM0
    MovQ    MM5,MM1
    PAnd    MM0,[EBP-8]
    PAnd    MM1,[EBP-8]
    PAddUSW MM0,MM1
    MovQ    MM1,MM0
    PCmpGTW MM1,[EBP-8]
    PSrlW   MM1,11
    POr     MM0,MM1
    PAnd    MM2,[EBP-16]
    PAnd    MM3,[EBP-16]
    PSrlW   MM2,5
    PSrlW   MM3,5
    PAddUSW MM2,MM3
    MovQ    MM3,MM2
    PCmpGTW MM3,MM6
    PSrlW   MM3,10
    POr     MM2,MM3
    PSllQ   MM2,5
    POr     MM0,MM2
    PAnd    MM4,[EBP-24]
    PAnd    MM5,[EBP-24]
    PSrlW   MM4,11
    PSrlW   MM5,11
    PAddUSW MM4,MM5
    MovQ    MM5,MM4
    PCmpGTW MM5,MM7
    PSrlW   MM5,11
    POr     MM4,MM5
    PSllQ   MM4,11
    POr     MM0,MM4
    MovQ    [EAX],MM0
    Add     EDI,8
    Add     ESI,8
    Add     EAX,8
    Dec     ECX
    JnZ     @Quads
    Cmp     EDI,0
    JE      @Last
    @Skip:
    Pop  ECX
    And  ECX,111b
    ShR  ECX,1
    JZ   @Exit
    Mov  EDX,ECX
    Push EDI
    LEA  EDI,M1
    Rep  MovSW
    MovQ MM1,[EBP-32]
    Pop  ESI
    Mov  ECX,EDX
    LEA  EDI,M1
    Rep  MovSW
    MovQ MM0,[EBP-32]
    Push EAX
    LEA  EAX,M1
    Mov  EDI,-8
    Mov  ECX,1
    Jmp  @cleanup
    @Last:
    Pop  EDI
    LEA  ESI,M1
    Mov  ECX,EDX
    Rep  MovSW
    @Exit:
    EMMS
    Pop  ESI
    Pop  EDI
  End;

PROCEDURE AddBlend16(Dst,Src1,Src2 : TFastDIB);
  Type TAddMem16REG = Array[0..235]of Byte;
       PAddMem16REG = ^TAddMem16REG;
       TAddMem16MMX = Array[0..346]of Byte;
       PAddMem16MMX = ^TAddMem16MMX;
       TAddMemProc  = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Const
    AddMem16REG : TAddMem16REG =
    ($55,$8B,$EC,$83,$C4,$F4,$53,$57,$56,$89,$D7,$89,$CE,$8B,$4D,$08,$51,$83,$E1,
     $FC,$0F,$84,$99,$00,$00,$00,$01,$C1,$89,$4D,$08,$8B,$0F,$8B,$1E,$81,$E1,$1F,
     $00,$1F,$00,$81,$E3,$1F,$00,$1F,$00,$01,$D9,$89,$CB,$81,$E3,$20,$00,$20,$00,
     $C1,$EB,$05,$6B,$DB,$1F,$09,$D9,$8B,$17,$8B,$1E,$81,$E2,$E0,$07,$E0,$07,$81,
     $E3,$E0,$07,$E0,$07,$C1,$EA,$05,$C1,$EB,$05,$01,$DA,$89,$D3,$81,$E3,$40,$00,
     $40,$00,$C1,$EB,$06,$6B,$DB,$3F,$09,$DA,$C1,$E2,$05,$09,$D1,$8B,$17,$8B,$1E,
     $81,$E2,$00,$F8,$00,$F8,$81,$E3,$00,$F8,$00,$F8,$C1,$EA,$0B,$C1,$EB,$0B,$01,
     $DA,$89,$D3,$81,$E3,$20,$00,$20,$00,$C1,$EB,$05,$6B,$DB,$1F,$09,$DA,$C1,$E2,
     $0B,$09,$D1,$89,$08,$83,$C7,$04,$83,$C6,$04,$83,$C0,$04,$3B,$45,$08,$0F,$85,
     $70,$FF,$FF,$FF,$39,$EF,$74,$29,$59,$83,$E1,$03,$D1,$E9,$74,$28,$66,$8B,$0F,
     $66,$8B,$1E,$89,$4D,$FC,$89,$5D,$F8,$8D,$7D,$FC,$8D,$75,$F8,$50,$8D,$45,$F4,
     $8D,$58,$04,$89,$5D,$08,$E9,$43,$FF,$FF,$FF,$58,$8B,$5D,$F4,$66,$89,$18,$5E,
     $5F,$5B,$8B,$E5,$5D,$C2,$04,$00);
    AddMem16MMX : TAddMem16MMX =
    ($55,$8B,$EC,$83,$C4,$E0,$57,$56,$C7,$45,$FC,$1F,$00,$1F,$00,$C7,$45,$F8,$1F,
     $00,$1F,$00,$C7,$45,$F4,$E0,$07,$E0,$07,$C7,$45,$F0,$E0,$07,$E0,$07,$C7,$45,
     $EC,$00,$F8,$00,$F8,$C7,$45,$E8,$00,$F8,$00,$F8,$C7,$45,$E4,$00,$00,$00,$00,
     $C7,$45,$E0,$00,$00,$00,$00,$0F,$6F,$B5,$F0,$FF,$FF,$FF,$0F,$71,$D6,$05,$0F,
     $6F,$BD,$E8,$FF,$FF,$FF,$0F,$71,$D7,$0B,$89,$D7,$89,$CE,$8B,$4D,$08,$51,$C1,
     $E9,$03,$0F,$84,$A6,$00,$00,$00,$0F,$6F,$07,$0F,$6F,$0E,$0F,$6F,$D0,$0F,$6F,
     $D9,$0F,$6F,$E0,$0F,$6F,$E9,$0F,$DB,$85,$F8,$FF,$FF,$FF,$0F,$DB,$8D,$F8,$FF,
     $FF,$FF,$0F,$DD,$C1,$0F,$6F,$C8,$0F,$65,$8D,$F8,$FF,$FF,$FF,$0F,$71,$D1,$0B,
     $0F,$EB,$C1,$0F,$DB,$95,$F0,$FF,$FF,$FF,$0F,$DB,$9D,$F0,$FF,$FF,$FF,$0F,$71,
     $D2,$05,$0F,$71,$D3,$05,$0F,$DD,$D3,$0F,$6F,$DA,$0F,$65,$DE,$0F,$71,$D3,$0A,
     $0F,$EB,$D3,$0F,$71,$F2,$05,$0F,$EB,$C2,$0F,$DB,$A5,$E8,$FF,$FF,$FF,$0F,$DB,
     $AD,$E8,$FF,$FF,$FF,$0F,$71,$D4,$0B,$0F,$71,$D5,$0B,$0F,$DD,$E5,$0F,$6F,$EC,
     $0F,$65,$EF,$0F,$71,$D5,$0B,$0F,$EB,$E5,$0F,$71,$F4,$0B,$0F,$EB,$C4,$0F,$7F,
     $00,$83,$C7,$08,$83,$C6,$08,$83,$C0,$08,$49,$0F,$85,$5F,$FF,$FF,$FF,$83,$FF,
     $00,$74,$3B,$59,$83,$E1,$07,$D1,$E9,$74,$3C,$89,$CA,$57,$8D,$7D,$E0,$66,$F3,
     $A5,$0F,$6F,$8D,$E0,$FF,$FF,$FF,$5E,$89,$D1,$8D,$7D,$E0,$66,$F3,$A5,$0F,$6F,
     $85,$E0,$FF,$FF,$FF,$50,$8D,$45,$E0,$BF,$F8,$FF,$FF,$FF,$B9,$01,$00,$00,$00,
     $E9,$25,$FF,$FF,$FF,$5F,$8D,$75,$E0,$89,$D1,$66,$F3,$A5,$0F,$77,$5E,$5F,$8B,
     $E5,$5D,$C2,$04,$00);
  Var I    : Integer;
      Code : PLine8;
  Begin
    If cfMMX in CPUInfo.Features then
      Begin
        GetMem(Code,SizeOf(TAddMem16MMX));
        PAddMem16MMX(Code)^:=AddMem16MMX;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[11])^:=I;
        PDWord(@Code[18])^:=I;
        I:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[25])^:=I;
        PDWord(@Code[32])^:=I;
        I:=Dst.RMask ShL 16 or Dst.RMask;
        PDWord(@Code[39])^:=I;
        PDWord(@Code[46])^:=I;
        Code[74]:=Dst.GShl;
        Code[85]:=Dst.RShl;
        Code[151]:=16-Dst.Bpb;
        Code[172]:=Dst.GShl;
        Code[176]:=Dst.GShl;
        Code[189]:=16-Dst.Bpg;
        Code[196]:=Dst.GShl;
        Code[217]:=Dst.RShl;
        Code[221]:=Dst.RShl;
        Code[234]:=16-Dst.Bpr;
        Code[241]:=Dst.RShl;
      End
    Else
      Begin
        GetMem(Code,SizeOf(TAddMem16REG));
        PAddMem16REG(Code)^:=AddMem16REG;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[37])^:=I;
        PDWord(@Code[43])^:=I;
        PDWord(@Code[53])^:=(I+I) and (Not I);
        I:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[71])^:=I;
        PDWord(@Code[77])^:=I;
        I:=I ShR Dst.GShl;
        PDWord(@Code[93])^:=(I+I) and (Not I);
        I:=Dst.RMask ShL 16 or Dst.RMask;
        PDWord(@Code[116])^:=I;
        PDWord(@Code[122])^:=I;
        I:=I ShR Dst.RShl;
        PDWord(@Code[138])^:=(I+I) and (Not I);
        Code[59]:=Dst.Bpb;
        Code[62]:=(1 ShL Dst.Bpb)-1;
        Code[83]:=Dst.GShl;
        Code[86]:=Dst.GShl;
        Code[99]:=Dst.Bpg;
        Code[102]:=(1 ShL Dst.Bpg)-1;
        Code[107]:=Dst.GShl;
        Code[128]:=Dst.RShl;
        Code[131]:=Dst.RShl;
        Code[144]:=Dst.Bpr;
        Code[147]:=(1 ShL Dst.Bpr)-1;
        Code[152]:=Dst.RShl;
      End;
    For I:=0 to Dst.AbsHeight-1 do
      TAddMemProc(Code)(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
    FreeMem(Code);
  End;

PROCEDURE AddMem8(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8]
  Var S : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    Mov  S,ESP
    Mov  ESP,EAX
    And  ECX,$FFFFFFFC
    JZ   @Skip
    Add  ECX,EAX
    Mov  [EBP+8],ECX
    @DWords:
    Mov  EAX,[EDI]
    Mov  EBX,[ESI]
    Mov  ECX,EAX
    Mov  EDX,EBX
    And  EAX,$00FF00FF
    And  EBX,$00FF00FF
    Add  EAX,EBX
    Mov  EBX,EAX
    And  EBX,$01000100
    ShR  EBX,8
    IMul EBX,$FF
    Or   EAX,EBX
    And  ECX,$FF00FF00
    And  EDX,$FF00FF00
    ShR  ECX,8
    ShR  EDX,8
    Add  ECX,EDX
    Mov  EDX,ECX
    And  EDX,$01000100
    ShR  EDX,8
    IMul EDX,$FF
    Or   ECX,EDX
    ShL  ECX,8
    Or   EAX,ECX
    Mov  [ESP],EAX
    Add  EDI,4
    Add  ESI,4
    Add  ESP,4
    Cmp  ESP,[EBP+8]
    JnE  @DWords
    @Skip:
    Mov  EAX,ESP
    Mov  ESP,S
    Pop  ECX
    And  ECX,11b
    JZ   @Exit
    @Bytes:
    MovZX EBX,Byte([ESI])
    MovZX EDX,Byte([EDI])
    Add   EBX,EDX
    Mov   EDX,EBX
    And   EDX,$0100
    Sub   EDX,$0100
    Xor   EDX,-1
    ShR   EDX,8
    Or    EBX,EDX
    Mov   [EAX],bl
    Inc   ESI
    Inc   EDI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE AddMem8MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8]
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,3
    JZ   @Skip
    @Quads:
    MovQ    MM0,[EDI]
    MovQ    MM1,[ESI]
    PAddUSB MM0,MM1
    MovQ    [EAX],MM0
    //DB $0F,$6F,$07  /// MovQ    MM0,[EDI]
    //DB $0F,$6F,$0E  /// MovQ    MM1,[ESI]
    //DB $0F,$DC,$C1  /// PAddUSB MM0,MM1
    //DB $0F,$7F,$00  /// MovQ    [EAX],MM0
    Add  EDI,8
    Add  ESI,8
    Add  EAX,8
    Dec  ECX
    JnZ  @Quads
    //DB $0F,$77 // EMMS
    EMMS
    @Skip:
    Pop  ECX
    And  ECX,111b
    JZ   @Exit
    @Bytes:
    MovZX EBX,Byte([ESI])
    MovZX EDX,Byte([EDI])
    Add   EBX,EDX
    Mov   EDX,EBX
    And   EDX,$0100
    Sub   EDX,$0100
    Xor   EDX,-1
    ShR   EDX,8
    Or    EBX,EDX
    Mov   [EAX],bl
    Inc   EDI
    Inc   ESI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE AddBlend8(Dst,Src1,Src2 : TFastDIB);
  Type TAddMemProc = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Var I      : Integer;
      AddMem : TAddMemProc;
  Begin
    If cfMMX in CPUInfo.Features then AddMem:=AddMem8MMX Else AddMem:=AddMem8;
    For I:=0 to Dst.AbsHeight-1 do
      AddMem(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
  End;

PROCEDURE AddBlend(Dst,Src1,Src2 : TFastDIB);
  Begin
    Case Dst.Bpp of
      8,24,32 : AddBlend8(Dst,Src1,Src2);
      16      : AddBlend16(Dst,Src1,Src2);
    End;
  End;

PROCEDURE MulMem16(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX
//Size = [EBP+8]; A = [EBP-4]; B = [EBP-8]
  Var A,B,S : Integer;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  S,ESP
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ESP,EAX
    Mov  ECX,[EBP+8]
    ShR  ECX,1
    JZ   @Exit
    @Words:
    MovZX EBX,Word([EDI])
    MovZX EDX,Word([ESI])
    Mov   A,EBX
    Mov   B,EDX
    And   EBX,$0000001F
    And   EDX,$0000001F
    IMul  EBX,EDX
    ShR   EBX,5
    Mov   EAX,A
    Mov   EDX,B
    And   EAX,$000007E0
    And   EDX,$000007E0
    ShR   EAX,5
    ShR   EDX,5
    IMul  EAX,EDX
    ShR   EAX,6
    ShL   EAX,5
    Or    EBX,EAX
    Mov   EAX,A
    Mov   EDX,B
    And   EAX,$0000F800
    And   EDX,$0000F800
    ShR   EAX,11
    ShR   EDX,11
    IMul  EAX,EDX
    ShR   EAX,5
    ShL   EAX,11
    Or    EBX,EAX
    Mov   [ESP],BX
    Add   EDI,2
    Add   ESI,2
    Add   ESP,2
    Dec   ECX
    JnZ   @Words
    @Exit:
    Mov  ESP,S
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE MulMem16MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8]
//HB:LB = [EBP-8]; HG:LG = [EBP-16]; HR:LR= [EBP-24]; AA:BB = [EBP-32]
  Var HB,LB,HG,LG,HR,LR,AA,BB : Integer;
  Asm
    Push EDI
    Push ESI
    Mov  HR,$F800F800
    Mov  LR,$F800F800
    Mov  HG,$07E007E0
    Mov  LG,$07E007E0
    Mov  HB,$001F001F
    Mov  LB,$001F001F
    Mov  AA,0
    Mov  BB,0
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,3
    JZ   @Skip
    @Quads:
    MovQ MM0,[EDI]
    MovQ MM1,[ESI]
    @cleanup:
    MovQ   MM2,MM0
    MovQ   MM3,MM0
    MovQ   MM4,MM1
    MovQ   MM5,MM1
    PAnd   MM0,[EBP-24]
    PAnd   MM1,[EBP-24]
    PMullW MM0,MM1
    PSrlW  MM0,5
    PAnd   MM2,[EBP-16]
    PAnd   MM4,[EBP-16]
    PSrlW  MM2,5
    PSrlW  MM4,5
    PMullW MM2,MM4
    PSrlW  MM2,6
    PSllQ  MM2,5
    POr    MM0,MM2
    PAnd   MM3,[EBP-8]
    PAnd   MM5,[EBP-8]
    PSrlW  MM3,11
    PSrlW  MM5,11
    PMullW MM3,MM5
    PSrlW  MM3,5
    PSllQ  MM3,11
    POr    MM0,MM3
    MovQ   [EAX],MM0
    Add    EDI,8
    Add    ESI,8
    Add    EAX,8
    Dec    ECX
    JnZ    @Quads
    Cmp    EDI,0
    JE     @Last
    @Skip:
    Pop  ECX
    And  ECX,111b
    ShR  ECX,1
    JZ   @Exit
    Mov  EDX,ECX
    Push EDI
    Mov  EDI,EBP
    Sub  EDI,32 //EDI = EBP-32
    Rep  MovSW
    MovQ MM1,[EBP-32]
    Pop  ESI
    Sub  EDI,EDX //EDI = EBP-32
    Mov  ECX,EDX
    Rep  MovSW
    MovQ MM0,[EBP-32]
    Mov  ECX,1
    Mov  EDI,-8
    Push EAX
    Mov  EAX,EBP
    Sub  EAX,32
    Jmp  @cleanup
    @Last:
    Mov  ECX,EDX
    Pop  EDI
    Mov  ESI,EBP
    Sub  ESI,32
    Rep  MovSW
    @Exit:
    EMMS
    Pop  ESI
    Pop  EDI
  End;

PROCEDURE MulBlend16(Dst,Src1,Src2 : TFastDIB);
  Type TMulMem16REG = Array[0..150]of Byte;
       PMulMem16REG = ^TMulMem16REG;
       TMulMem16MMX = Array[0..294]of Byte;
       PMulMem16MMX = ^TMulMem16MMX;
       TMulMemProc  = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Const
    MulMem16REG : TMulMem16REG =
    ($55,$8B,$EC,$83,$C4,$F4,$53,$57,$56,$89,$65,$FC,$89,$D7,$89,$CE,$89,$C4,$8B,
     $4D,$08,$D1,$E9,$74,$72,$0F,$B7,$1F,$0F,$B7,$16,$89,$5D,$F8,$89,$55,$F4,$81,
     $E3,$1F,$00,$00,$00,$81,$E2,$1F,$00,$00,$00,$0F,$AF,$DA,$C1,$EB,$05,$8B,$45,
     $F8,$8B,$55,$F4,$25,$E0,$07,$00,$00,$81,$E2,$E0,$07,$00,$00,$C1,$E8,$05,$C1,
     $EA,$05,$0F,$AF,$C2,$C1,$E8,$06,$C1,$E0,$05,$09,$C3,$8B,$45,$F8,$8B,$55,$F4,
     $25,$00,$F8,$00,$00,$81,$E2,$00,$F8,$00,$00,$C1,$E8,$0B,$C1,$EA,$0B,$0F,$AF,
     $C2,$C1,$E8,$05,$C1,$E0,$0B,$09,$C3,$66,$89,$1C,$24,$83,$C7,$02,$83,$C6,$02,
     $83,$C4,$02,$49,$75,$8E,$8B,$65,$FC,$5E,$5F,$5B,$8B,$E5,$5D,$C2,$04,$00);
    MulMem16MMX : TMulMem16MMX =
    ($55,$8B,$EC,$83,$C4,$E0,$57,$56,$C7,$45,$FC,$00,$F8,$00,$F8,$C7,$45,$F8,$00,
     $F8,$00,$F8,$C7,$45,$F4,$E0,$07,$E0,$07,$C7,$45,$F0,$E0,$07,$E0,$07,$C7,$45,
     $EC,$1F,$00,$1F,$00,$C7,$45,$E8,$1F,$00,$1F,$00,$C7,$45,$E4,$00,$00,$00,$00,
     $C7,$45,$E0,$00,$00,$00,$00,$89,$D7,$89,$CE,$8B,$4D,$08,$51,$C1,$E9,$03,$0F,
     $84,$83,$00,$00,$00,$0F,$6F,$07,$0F,$6F,$0E,$0F,$6F,$D0,$0F,$6F,$D8,$0F,$6F,
     $E1,$0F,$6F,$E9,$0F,$DB,$85,$E8,$FF,$FF,$FF,$0F,$DB,$8D,$E8,$FF,$FF,$FF,$0F,
     $D5,$C1,$0F,$71,$D0,$05,$0F,$DB,$95,$F0,$FF,$FF,$FF,$0F,$DB,$A5,$F0,$FF,$FF,
     $FF,$0F,$71,$D2,$05,$0F,$71,$D4,$05,$0F,$D5,$D4,$0F,$71,$D2,$06,$0F,$71,$F2,
     $05,$0F,$EB,$C2,$0F,$DB,$9D,$F8,$FF,$FF,$FF,$0F,$DB,$AD,$F8,$FF,$FF,$FF,$0F,
     $71,$D3,$0B,$0F,$71,$D5,$0B,$0F,$D5,$DD,$0F,$71,$D3,$05,$0F,$71,$F3,$0B,$0F,
     $EB,$C3,$0F,$7F,$00,$83,$C7,$08,$83,$C6,$08,$83,$C0,$08,$49,$75,$82,$83,$FF,
     $00,$74,$3E,$59,$83,$E1,$07,$D1,$E9,$74,$41,$89,$CA,$57,$89,$EF,$83,$EF,$20,
     $66,$F3,$A5,$0F,$6F,$8D,$E0,$FF,$FF,$FF,$5E,$29,$D7,$89,$D1,$66,$F3,$A5,$0F,
     $6F,$85,$E0,$FF,$FF,$FF,$B9,$01,$00,$00,$00,$BF,$F8,$FF,$FF,$FF,$50,$89,$E8,
     $83,$E8,$20,$E9,$45,$FF,$FF,$FF,$89,$D1,$5F,$89,$EE,$83,$EE,$20,$66,$F3,$A5,
     $0F,$77,$5E,$5F,$8B,$E5,$5D,$C2,$04,$00);
  Var I    : Integer;
      Code : PLine8;
  Begin
    If cfMMX in CPUInfo.Features then
      Begin
        GetMem(Code,SizeOf(TMulMem16MMX));
        PMulMem16MMX(Code)^:=MulMem16MMX;
        I:=Dst.RMask ShL 16 or Dst.RMask;
        PDWord(@Code[11])^:=I;
        PDWord(@Code[18])^:=I;
        I:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[25])^:=I;
        PDWord(@Code[32])^:=I;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[39])^:=I;
        PDWord(@Code[46])^:=I;
        Code[119]:=Dst.Bpb;
        Code[137]:=Dst.GShl;
        Code[141]:=Dst.GShl;
        Code[148]:=Dst.Bpg;
        Code[152]:=Dst.GShl;
        Code[173]:=Dst.RShl;
        Code[177]:=Dst.RShl;
        Code[184]:=Dst.Bpr;
        Code[188]:=Dst.RShl;
      End
    Else
      Begin
        GetMem(Code,SizeOf(TMulMem16REG));
        PMulMem16REG(Code)^:=MulMem16REG;
        PDWord(@Code[39])^:=Dst.BMask;
        PDWord(@Code[45])^:=Dst.BMask;
        PDWord(@Code[62])^:=Dst.GMask;
        PDWord(@Code[68])^:=Dst.GMask;
        PDWord(@Code[96])^:=Dst.RMask;
        PDWord(@Code[102])^:=Dst.RMask;
        Code[54]:=Dst.Bpb;
        Code[74]:=Dst.GShl;
        Code[77]:=Dst.GShl;
        Code[83]:=Dst.Bpg;
        Code[86]:=Dst.GShl;
        Code[108]:=Dst.RShl;
        Code[111]:=Dst.RShl;
        Code[117]:=Dst.Bpr;
        Code[120]:=Dst.RShl;
      End;
    For I:=0 to Dst.AbsHeight-1 do
      TMulMemProc(Code)(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
    FreeMem(Code);
  End;

PROCEDURE MulMem8(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8]
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Cmp  ECX,0
    JE   @Exit
    @Bytes:
    MovZX EBX,Byte([EDI])
    MovZX EDX,Byte([ESI])
    IMul  EBX,EDX
    ShR   EBX,8
    Mov   [EAX],bl
    Inc   EDI
    Inc   ESI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE MulMem8MMX(Dst,Src1,Src2 : Pointer;Size : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+8]
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+8]
    Push ECX
    ShR  ECX,2
    JZ  @Skip
    PXor MM2,MM2
    //DB $0F,$EF,$D2       /// PXor MM2,MM2
    @DWords:
    MovD       MM0,[EDI]
    MovD       MM1,[ESI]
    PUnpckLBW  MM0,MM2
    PUnpckLBW  MM1,MM2
    PMullW     MM0,MM1
    PSrlW      MM0,8
    PackUSWB   MM0,MM0
    MovD       [EAX],MM0
    //DB $0F,$6E,$07       /// MovD       MM0,[EDI]
    //DB $0F,$6E,$0E       /// MovD       MM1,[ESI]
    //DB $0F,$60,$C2       /// PUnpckLBW  MM0,MM2
    //DB $0F,$60,$CA       /// PUnpckLBW  MM1,MM2
    //DB $0F,$D5,$C1       /// PMullW     MM0,MM1
    //DB $0F,$71,$D0,$08   /// PSrlW      MM0,8
    //DB $0F,$67,$C0       /// PackUSWB   MM0,MM0
    //DB $0F,$7E,$00       /// MovD       [EAX],MM0
    Add  EDI,4
    Add  ESI,4
    Add  EAX,4
    Dec  ECX
    JnZ  @DWords
    EMMS
    //DB $0F,$77 // EMMS
    @Skip:
    Pop  ECX
    And  ECX,11b
    JZ   @Exit
    @Bytes:
    MovZX EBX,Byte([EDI])
    MovZX EDX,Byte([ESI])
    IMul  EBX,EDX
    ShR   EBX,8
    Mov   [EAX],bl
    Inc   EDI
    Inc   ESI
    Inc   EAX
    Dec   ECX
    JnZ   @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE MulBlend8(Dst,Src1,Src2 : TFastDIB);
  Type TMulMemProc = Procedure(Dst,Src1,Src2 : Pointer;Size : Integer);
  Var I      : Integer;
      MulMem : TMulMemProc;
  Begin
    If cfMMX in CPUInfo.Features then MulMem:=MulMem8MMX Else MulMem:=MulMem8;
    For I:=0 to Dst.AbsHeight-1 do
      MulMem(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap);
  End;

PROCEDURE MulBlend(Dst,Src1,Src2 : TFastDIB);
  Begin
    Case Dst.Bpp of
      8,24,32 : MulBlend8(Dst,Src1,Src2);
      16      : MulBlend16(Dst,Src1,Src2);
    End;
  End;

PROCEDURE BlendMem16(Dst,Src1,Src2 : Pointer;Size,Alpha : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+12]
//Alpha = [EBP+8]; A = [EBP-4]; B = [EBP-8]; C = [EBP-12]
  Var A,B,C : Cardinal;
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  ECX,[EBP+12]
    And  ECX,3
    Push ECX
    Sub  [EBP+12],ECX
    JZ   @Skip
    Add  [EBP+12],EAX
    @DWords:
    Mov  EDX,[EDI]     // EDX = src1
    Mov  ECX,[ESI]     // ECX = src2
    @Words:           
    Mov  A,EDX         // A = copy of src1
    Mov  B,ECX         // B = copy of src2
    And  EDX,$001F001F // EDX = blue_src1
    And  ECX,$001F001F // ECX = blue_src2
    Sub  EDX,ECX       // (blue_src1-blue_src2)
    IMul EDX,[EBP+8]   // (blue_src1-blue_src2)*blue_alpha
    ShR  EDX,8         // (blue_src1-blue_src2)*blue_alpha / 256
    Add  EDX,ECX       // (blue_src1-blue_src2)*blue_alpha / 256+blue_src2
    And  EDX,$001F001F // EDX = [-----------bbbbb-----------bbbbb]
    Mov  EBX,A         // EBX = src1
    Mov  ECX,B         // ECX = src2
    And  EBX,$03E003E0 // EBX = green_src1
    And  ECX,$03E003E0 // ECX = green_src2
    ShR  EBX,5         // [------ggggg-----] >> [-----------ggggg]
    ShR  ECX,5         // [------ggggg-----] >> [-----------ggggg]
    Sub  EBX,ECX       // (green_src1-green_src2)
    IMul EBX,[EBP+8]   // (green_src1-green_src2)*green_alpha
    ShR  EBX,8         // (green_src1-green_src2)*green_alpha / 256
    Add  EBX,ECX       // (green_src1-green_src2)*green_alpha / 256+green_src2
    ShL  EBX,5         // [------ggggg-----] << [-----------ggggg]
    And  EBX,$03E003E0 // EBX = [------ggggg-----------ggggg-----]
    Or   EDX,EBX       // EDX = [------gggggbbbbb------gggggbbbbb]
    Mov  EBX,A         // EBX = src1
    Mov  ECX,B         // ECX = src2
    And  EBX,$7C007C00 // EBX = red_src1
    And  ECX,$7C007C00 // ECX = red_src2
    ShR  EBX,10        // [-rrrrr----------] >> [-----------rrrrr]
    ShR  ECX,10        // [-rrrrr----------] >> [-----------rrrrr]
    Sub  EBX,ECX       // (red_src1-red_src2)
    IMul EBX,[EBP+8]   // (red_src1-red_src2)*red_alpha
    ShR  EBX,8         // (red_src1-red_src2)*red_alpha / 256
    Add  EBX,ECX       // (red_src1-red_src2)*red_alpha / 256+red_src2
    ShL  EBX,10        // [-rrrrr----------] << [-----------rrrrr]
    And  EBX,$7C007C00 // EBX = [-rrrrr-----------rrrrr----------]
    Or   EDX,EBX       // EDX = [-rrrrrgggggbbbbb-rrrrrgggggbbbbb]
    Mov  [EAX],EDX
    Add  EAX,4
    Add  EDI,4
    Add  ESI,4
    Cmp  EAX,[EBP+12]
    JnE  @DWords
    Mov  EBX,EBP
    Sub  EBX,8
    Cmp  EAX,EBX
    JE   @Last //EAX = @C (EBP-12)
    @Skip:
    Pop  ECX
    And  ECX,2
    JZ   @Exit
    Push EAX
    Mov  EBX,EBP
    Sub  EBX,12
    Mov  EAX,EBX //EAX = @C (EBP-12)
    Add  EBX,4
    Mov  [EBP+12],EBX
    Mov  DX,[EDI]
    Mov  CX,[ESI]
    Jmp  @Words
    @Last:
    Mov   EBX,C
    Pop   EAX
    Mov   [EAX],BX
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE BlendMem16MMX(Dst,Src1,Src2 : Pointer;Size,Alpha : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+12]
//Alpha = [EBP+8]; HA:LA = [EBP-8]; HB:LB = [EBP-16]
  Var HA,LA,HB,LB : Integer;
  Asm
    Push  EBX
    Push  EDI
    Push  ESI
    Mov   EDI,EDX
    Mov   ESI,ECX
    Mov   ECX,[EBP+12]
    ShR   ECX,3
    JZ    @Skip
    Mov   EBX,[EBP+8]
    ShL   EBX,16
    Or    EBX,[EBP+8]
    Mov   HA,EBX
    Mov   LA,EBX// HA:LA = 00aa00aa00aa00aa
    Mov   HB,0
    Mov   LB,0
    Mov   EBX,$001F001F
    MovD  MM2,EBX
    MovD  MM3,EBX
    PSllQ MM2,32
    POr   MM2,MM3// MM2 = 001F001F001F001F
    Mov   EBX,$03E003E0
    MovD  MM3,EBX
    MovD  MM4,EBX
    PSllQ MM3,32
    POr   MM3,MM4// MM3 = 03E003E003E003E0
    Mov   EBX,$7C007C00
    MovD  MM4,EBX
    MovD  MM5,EBX
    PSllQ MM4,32
    POr   MM4,MM5// MM4 = 7C007C007C007C00
    @Quads:
    MovQ   MM7,[EDI]
    MovQ   MM1,[ESI]
    @Words:
    MovQ   MM0,MM7
    MovQ   MM5,MM1
    PAnd   MM7,MM2
    PAnd   MM1,MM2
    PSubW  MM7,MM1
    PMullW MM7,[EBP-8]
    PSrlW  MM7,8
    PAddB  MM7,MM1
    MovQ   MM1,MM0
    MovQ   MM6,MM5
    PAnd   MM0,MM3
    PAnd   MM5,MM3
    PSrlW  MM0,5
    PSrlW  MM5,5
    PSubW  MM0,MM5
    PMullW MM0,[EBP-8]
    PSrlW  MM0,8
    PAddB  MM0,MM5
    PSllQ  MM0,5
    POr    MM7,MM0
    PAnd   MM1,MM4
    PAnd   MM6,MM4
    PSrlW  MM1,10
    PSrlW  MM6,10
    PSubW  MM1,MM6
    PMullW MM1,[EBP-8]
    PSrlW  MM1,8
    PAddB  MM1,MM6
    PSllQ  MM1,10
    POr    MM7,MM1
    MovQ   [EAX],MM7
    Add  EAX,8
    Add  EDI,8
    Add  ESI,8
    Dec  ECX
    JnZ  @Quads
    Mov  EBX,EBP
    Sub  EBX,8
    Cmp  EAX,EBX
    JE   @Last
    @Skip:
    Mov  ECX,[EBP+12]
    And  ECX,7
    ShR  ECX,1
    JZ   @Exit
    Push ECX
    Push EDI
    Push ECX
    Mov   EDI,EBP
    Sub   EDI,16
    Rep   MovSW
    MovQ MM1,[EBP-16]
    Pop   ECX
    Pop   ESI
    Mov   EDI,EBP
    Sub   EDI,16
    Rep   MovSW
    MovQ MM7,[EBP-16]
    Push EAX
    Mov   EAX,EBP
    Sub   EAX,16
    Mov   ECX,1
    Jmp  @Words
    @Last:
    Pop  EDI
    Pop  ECX
    Mov  ESI,EBP
    Sub  ESI,16
    Rep  MovSW
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
    EMMS
  End;

PROCEDURE AlphaBlend16(Dst,Src1,Src2 : TFastDIB;Alpha : Integer);
  Type TBlendMem16REG = Array[0..238]of Byte;
       PBlendMem16REG = ^TBlendMem16REG;
       TBlendMem16MMX = Array[0..334]of Byte;
       PBlendMem16MMX = ^TBlendMem16MMX;
       TBlendMemProc  = Procedure(Dst,Src1,Src2 : Pointer;Size,Alpha : Integer);
  Const
    BlendMem16REG : TBlendMem16REG =
    ($55,$8B,$EC,$83,$C4,$F4,$53,$57,$56,$89,$D7,$89,$CE,$8B,$4D,$0C,$83,$E1,$03,$51,
     $29,$4D,$0C,$0F,$84,$A3,$00,$00,$00,$01,$45,$0C,$8B,$17,$8B,$0E,$89,$55,$FC,$89,
     $4D,$F8,$81,$E2,$1F,$00,$1F,$00,$81,$E1,$1F,$00,$1F,$00,$29,$CA,$0F,$AF,$55,$08,
     $C1,$EA,$08,$01,$CA,$81,$E2,$1F,$00,$1F,$00,$8B,$5D,$FC,$8B,$4D,$F8,$81,$E3,$E0,
     $03,$E0,$03,$81,$E1,$E0,$03,$E0,$03,$C1,$EB,$05,$C1,$E9,$05,$29,$CB,$0F,$AF,$5D,
     $08,$C1,$EB,$08,$01,$CB,$C1,$E3,$05,$81,$E3,$E0,$03,$E0,$03,$09,$DA,$8B,$5D,$FC,
     $8B,$4D,$F8,$81,$E3,$00,$7C,$00,$7C,$81,$E1,$00,$7C,$00,$7C,$C1,$EB,$0A,$C1,$E9,
     $0A,$29,$CB,$0F,$AF,$5D,$08,$C1,$EB,$08,$01,$CB,$C1,$E3,$0A,$81,$E3,$00,$7C,$00,
     $7C,$09,$DA,$89,$10,$83,$C0,$04,$83,$C7,$04,$83,$C6,$04,$3B,$45,$0C,$0F,$85,$69,
     $FF,$FF,$FF,$89,$EB,$83,$EB,$08,$39,$D8,$74,$1F,$59,$83,$E1,$02,$74,$20,$50,$89,
     $EB,$83,$EB,$0C,$89,$D8,$83,$C3,$04,$89,$5D,$0C,$66,$8B,$17,$66,$8B,$0E,$E9,$45,
     $FF,$FF,$FF,$8B,$5D,$F4,$58,$66,$89,$18,$5E,$5F,$5B,$8B,$E5,$5D,$C2,$08,$00);
    BlendMem16MMX : TBlendMem16MMX =
    ($55,$8B,$EC,$83,$C4,$F0,$53,$57,$56,$89,$D7,$89,$CE,$8B,$4D,$0C,$C1,$E9,$03,$0F,
     $84,$E4,$00,$00,$00,$8B,$5D,$08,$C1,$E3,$10,$0B,$5D,$08,$89,$5D,$FC,$89,$5D,$F8,
     $C7,$45,$F4,$00,$00,$00,$00,$C7,$45,$F0,$00,$00,$00,$00,$BB,$1F,$00,$1F,$00,$0F,
     $6E,$D3,$0F,$6E,$DB,$0F,$73,$F2,$20,$0F,$EB,$D3,$BB,$E0,$03,$E0,$03,$0F,$6E,$DB,
     $0F,$6E,$E3,$0F,$73,$F3,$20,$0F,$EB,$DC,$BB,$00,$7C,$00,$7C,$0F,$6E,$E3,$0F,$6E,
     $EB,$0F,$73,$F4,$20,$0F,$EB,$E5,$0F,$6F,$3F,$0F,$6F,$0E,$0F,$6F,$C7,$0F,$6F,$E9,
     $0F,$DB,$FA,$0F,$DB,$CA,$0F,$F9,$F9,$0F,$D5,$BD,$F8,$FF,$FF,$FF,$0F,$71,$D7,$08,
     $0F,$FC,$F9,$0F,$6F,$C8,$0F,$6F,$F5,$0F,$DB,$C3,$0F,$DB,$EB,$0F,$71,$D0,$05,$0F,
     $71,$D5,$05,$0F,$F9,$C5,$0F,$D5,$85,$F8,$FF,$FF,$FF,$0F,$71,$D0,$08,$0F,$FC,$C5,
     $0F,$71,$F0,$05,$0F,$EB,$F8,$0F,$DB,$CC,$0F,$DB,$F4,$0F,$71,$D1,$0A,$0F,$71,$D6,
     $0A,$0F,$F9,$CE,$0F,$D5,$8D,$F8,$FF,$FF,$FF,$0F,$71,$D1,$08,$0F,$FC,$CE,$0F,$71,
     $F1,$0A,$0F,$EB,$F9,$0F,$7F,$38,$83,$C0,$08,$83,$C7,$08,$83,$C6,$08,$49,$0F,$85,
     $78,$FF,$FF,$FF,$89,$EB,$83,$EB,$08,$39,$D8,$74,$3D,$8B,$4D,$0C,$83,$E1,$07,$D1,
     $E9,$74,$3D,$51,$57,$51,$89,$EF,$83,$EF,$10,$66,$F3,$A5,$0F,$6F,$8D,$F0,$FF,$FF,
     $FF,$59,$5E,$89,$EF,$83,$EF,$10,$66,$F3,$A5,$0F,$6F,$BD,$F0,$FF,$FF,$FF,$50,$89,
     $E8,$83,$E8,$10,$B9,$01,$00,$00,$00,$E9,$38,$FF,$FF,$FF,$5F,$59,$89,$EE,$83,$EE,
     $10,$66,$F3,$A5,$5E,$5F,$5B,$0F,$77,$8B,$E5,$5D,$C2,$08,$00);
  Var I    : Integer;
      Code : PLine8;
  Begin
    If cfMMX in CPUInfo.Features then
      Begin
        GetMem(Code,SizeOf(BlendMem16MMX));
        PBlendMem16MMX(Code)^:=BlendMem16MMX;
        PDWord(@Code[55])^:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[73])^:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[91])^:=Dst.RMask ShL 16 or Dst.RMask;
        Code[158]:=Dst.GShl;
        Code[162]:=Dst.GShl;
        Code[183]:=Dst.GShl;
        Code[196]:=Dst.RShl;
        Code[200]:=Dst.RShl;
        Code[221]:=Dst.RShl;
      End
    Else
      Begin
        GetMem(Code,SizeOf(BlendMem16REG));
        PBlendMem16REG(Code)^:=BlendMem16REG;
        I:=Dst.BMask ShL 16 or Dst.BMask;
        PDWord(@Code[44])^:=I;
        PDWord(@Code[50])^:=I;
        PDWord(@Code[67])^:=I;
        I:=Dst.GMask ShL 16 or Dst.GMask;
        PDWord(@Code[79])^:=I;
        PDWord(@Code[85])^:=I;
        PDWord(@Code[111])^:=I;
        I:=Dst.RMask ShL 16 or Dst.RMask;
        PDWord(@Code[125])^:=I;
        PDWord(@Code[131])^:=I;
        PDWord(@Code[157])^:=I;
        Code[91]:=Dst.GShl;
        Code[94]:=Dst.GShl;
        Code[108]:=Dst.GShl;
        Code[137]:=Dst.RShl;
        Code[140]:=Dst.RShl;
        Code[154]:=Dst.RShl;
      End;
    For I:=0 to Dst.AbsHeight-1 do
      TBlendMemProc(Code)(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap,Alpha);
    FreeMem(Code);
  End;

PROCEDURE BlendMem8(Dst,Src1,Src2 : Pointer;Size,Alpha : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+12]; Alpha = [EBP+ 8]
  Asm
    Push EBX
    Push EDI
    Push ESI
    Mov  EDI,EDX
    Mov  ESI,ECX
    Mov  EBX,[EBP+12]
    And  EBX,3
    Push EBX
    Sub  [EBP+12],EBX
    JZ   @Skip
    Add  [EBP+12],EAX
    @DWords:
    Mov  EBX,[EDI]
    Mov  EDX,[ESI]
    And  EBX,$00FF00FF
    And  EDX,$00FF00FF
    Sub  EBX,EDX
    IMul EBX,[EBP+8]
    ShR  EBX,8
    Add  EBX,EDX
    And  EBX,$00FF00FF
    Mov  ECX,[EDI]
    Mov  EDX,[ESI]
    And  ECX,$FF00FF00
    And  EDX,$FF00FF00
    ShR  ECX,8
    ShR  EDX,8
    Sub  ECX,EDX
    IMul ECX,[EBP+8]
    ShR  ECX,8
    Add  ECX,EDX
    ShL  ECX,8
    And  ECX,$FF00FF00
    Or   ECX,EBX
    Mov  [EAX],ECX
    Add  EAX,4
    Add  ESI,4
    Add  EDI,4
    Cmp  EAX,[EBP+12]
    JnE  @DWords
    @Skip:
    Pop  EBX
    Cmp  EBX,0
    JE   @Exit
    Add  EBX,EAX
    Mov  [EBP+12],EBX
    @Bytes:
    Mov  BL,[EDI]
    Mov  CL,[ESI]
    And  EBX,$FF
    And  ECX,$FF
    Sub  EBX,ECX
    IMul EBX,[EBP+8]
    ShR  EBX,8
    Add  EBX,ECX
    Mov  [EAX],BL
    Inc  EAX
    Inc  ESI
    Inc  EDI
    Cmp  EAX,[EBP+12]
    JnE  @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
  End;

PROCEDURE BlendMem8MMX(Dst,Src1,Src2 : Pointer;Size,Alpha : Integer);
//Dst = EAX; Src1 = EDX; Src2 = ECX; Size = [EBP+12]; Alpha = [EBP+8]
  Asm
    Push  EBX
    Push  EDI
    Push  ESI
    Mov   EDI,EDX
    Mov   ESI,ECX
    Mov   ECX,[EBP+12]
    ShR   ECX,3
    JZ    @Skip
    Mov   EBX,[EBP+8]
    ShL   EBX,16
    Or    EBX,[EBP+8]
    MovD  MM6,EBX
    MovD  MM5,EBX
    PSllQ MM5,32
    POr   MM6,MM5 // MM6 = 00aa00aa00aa00aa
    PXor  MM7,MM7
    //DB $0F,$6E,$F3     /// MovD   MM6,EBX
    //DB $0F,$6E,$EB     /// MovD   MM5,EBX
    //DB $0F,$73,$F5,$20 /// PSllQ  MM5,32
    //DB $0F,$EB,$F5     /// POr    MM6,MM5 // MM6 = 00aa00aa00aa00aa
    //DB $0F,$EF,$FF     /// PXor   MM7,MM7
    @Quads:
    MovQ       MM0,[EDI] // src2
    MovQ       MM1,[ESI] // src2
    MovQ       MM2,MM0   // second copy of src1
    MovQ       MM3,MM1   // second copy of src2
    MovQ       MM4,MM1   // third copy of src2
    PUnpckLBW  MM0,MM7   // MM0 = unpacked low half of src1
    PUnpckLBW  MM1,MM7   // MM1 = unpacked low half of src2
    PUnpckHBW  MM2,MM7   // MM2 = unpacked high half of src1
    PUnpckHBW  MM3,MM7   // MM3 = unpacked high half of src2
    PSubW      MM0,MM1   // MM0 = low half of (src1-src2)
    PSubW      MM2,MM3   // MM2 = high half of (src1-src2)
    PMullW     MM0,MM6   // low (src1-src2)*alpha
    PMullW     MM2,MM6   // high (src1-src2)*alpha
    PSrlW      MM0,8     // low (src1-src2)*alpha / 256
    PSrlW      MM2,8     // high (src1-src2)*alpha / 256
    PackUSWB   MM0,MM2   // combine with unsigned saturation
    PAddB      MM0,MM4   // (src1-src2)*alpha / 256+src2
    MovQ       [EAX],MM0 // store the result
    {DB $0F,$6F,$07     /// MovQ       MM0,[EDI] // src1
    DB $0F,$6F,$0E     /// MovQ       MM1,[ESI] // src2
    DB $0F,$6F,$D0     /// MovQ       MM2,MM0   // second copy of src1
    DB $0F,$6F,$D9     /// MovQ       MM3,MM1   // second copy of src2
    DB $0F,$6F,$E1     /// MovQ       MM4,MM1   // third copy of src2
    DB $0F,$60,$C7     /// PUnpckLBW  MM0,MM7   // MM0 = unpacked low half of src1
    DB $0F,$60,$CF     /// PUnpckLBW  MM1,MM7   // MM1 = unpacked low half of src2
    DB $0F,$68,$D7     /// PUnpckHBW  MM2,MM7   // MM2 = unpacked high half of src1
    DB $0F,$68,$DF     /// PUnpckHBW  MM3,MM7   // MM3 = unpacked high half of src2
    DB $0F,$F9,$C1     /// PSubW      MM0,MM1   // MM0 = low half of (src1-src2)
    DB $0F,$F9,$D3     /// PSubW      MM2,MM3   // MM2 = high half of (src1-src2)
    DB $0F,$D5,$C6     /// PMullW     MM0,MM6   // low (src1-src2)*alpha
    DB $0F,$D5,$D6     /// PMullW     MM2,MM6   // high (src1-src2)*alpha
    DB $0F,$71,$D0,$08 /// PSrlW      MM0,8     // low (src1-src2)*alpha / 256
    DB $0F,$71,$D2,$08 /// PSrlW      MM2,8     // high (src1-src2)*alpha / 256
    DB $0F,$67,$C2     /// PackUSWB   MM0,MM2   // combine with unsigned saturation
    DB $0F,$FC,$C4     /// PAddB      MM0,MM4   // (src1-src2)*alpha / 256+src2
    DB $0F,$7F,$00     /// MovQ       [EAX],MM0 // store the result}
    Add  EAX,8
    Add  EDI,8
    Add  ESI,8
    Dec  ECX
    JnZ  @Quads
    @Skip:
    Mov  ECX,[EBP+12]
    And  ECX,111b
    JZ   @Exit
    Add  ECX,EAX
    Mov  [EBP+12],ECX
    @Bytes:
    Mov  BL,[EDI]
    Mov  CL,[ESI]
    And  EBX,$FF
    And  ECX,$FF
    Sub  EBX,ECX
    IMul EBX,[EBP+8]
    ShR  EBX,8
    Add  EBX,ECX
    Mov  [EAX],BL
    Inc  EAX
    Inc  EDI
    Inc  ESI
    Cmp  EAX,[EBP+12]
    JnE  @Bytes
    @Exit:
    Pop  ESI
    Pop  EDI
    Pop  EBX
    EMMS
    //DB $0F,$77 // EMMS
  End;

PROCEDURE AlphaBlend8(Dst,Src1,Src2 : TFastDIB;Alpha : Integer);
  Type TBlendMem8Proc = Procedure(Dst,Src1,Src2 : Pointer;Size,Alpha : Integer);
  Var I        : Integer;
      BlendMem : TBlendMem8Proc;
  Begin
    If cfMMX in CPUInfo.Features then BlendMem:=BlendMem8MMX Else BlendMem:=BlendMem8;
    For I:=0 to Dst.AbsHeight-1 do
      BlendMem(Dst.ScanLines[I],Src1.ScanLines[I],Src2.ScanLines[I],Dst.BWidth-Dst.Gap,Alpha);
  End;

PROCEDURE AlphaBlend(Dst,Src1,Src2 : TFastDIB;Alpha : Integer);
  Begin
    Case Dst.Bpp of
      8,24,32 : AlphaBlend8(Dst,Src1,Src2,Alpha);
      16      : AlphaBlend16(Dst,Src1,Src2,Alpha);
    End;
  End;
END.
