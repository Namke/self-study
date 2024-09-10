UNIT WaveLetCompress;

INTERFACE

TYPE
  TBArray = Array[0..100000000] of Byte;
  TFArray = Array[0..100000000] of Double;
  TCArray = Array[0..100000000] of Cardinal;
  TIArray = Array[0..100000000] of LongInt;
  TWArray = Array[0..100000000] of Word;
  PBArray = ^TBArray;
  PFArray = ^TFArray;
  PCArray = ^TCArray;
  PIArray = ^TIArray;
  PWArray = ^TWArray;
  HWL_Header = Packed Record
    ID                                  : Array[0..2] of Char;//'HWL'
    Width,Height                        : Word;//X,Y
    BPP                                 : Byte;//BitsPerPixel (HWL_GS,HWL_RGB)
    Depth                               : Byte;//TransformationDepth
    BitSR,BitSG,BitSB,DataR,DataG,DataB : Cardinal; //Bits/Data in Buffers
    QuantBitSY,QuantBitSU,QuantBitSV    : Byte;//Quantizer Bits Used (1..8)
  End;
//Following the Header:
//1.   ((Depth+2)*sizeof(Double)) Bytes of Data for QuantizerFactors (One for HWL_GS, Three (R,G,B) for HWL_RGB)
//2.a. (bits*2/8) Bytes of Data for BitTable (HWL_ISO_ZERO,HWL_RLE_ZERO,etc)
//  b. (data*quantbits/8) Bytes of Data for DataTable
//  (One (R) for HWL_GS, Three (R,G,B) for HWL_RGB)
CONST
  HWL_GS       = 8;//Valid BPP
  HWL_RGB      = 24;
  HWL_ISO_ZERO = 0;//Valid En/Decoder-Values
  HWL_RLE_ZERO = 1;
  HWL_POS      = 2;
  HWL_NEG      = 3;

PROCEDURE HWL2Mem(Var Pic : Pointer;Var Head : HWL_Header;Name : String;AllocMem : Boolean);
//For all who just want to get a HWL-File loaded into memory =)
//Everything else in this Unit is then TOTALLY unnecessary to work with / know about.
//Depending on the BPP the resulting "Pic"-Pointer will be filled with
//Bytes (HWL_GS) or Cardinals (HWL_RGB), the necessary infos are delivered inside "Head".
//"AllocMem" lets the procedure get memory for "Pic" (TRUE) or awaits a already allocated "Pic" (FALSE)
PROCEDURE WaveletGS(Pic : PFArray;WL : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);//BMP to HWL
PROCEDURE WaveletRGB(RF,GF,BF : PFArray;WLR,WLG,WLB : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);
PROCEDURE DeWaveletGS(WL : PFArray;Pic : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);//Inverse
PROCEDURE DeWaveletRGB(WLR,WLG,WLB : PFArray;RF,GF,BF : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);
PROCEDURE WaveletQuantGS(WL : PFArray;WLI : PIArray;XRes,YRes,Depth,Bits : Cardinal;QuantFactor : PFArray);//Quantizer
PROCEDURE WaveletQuantRGB(RF,GF,BF : PFArray;YI,UI,VI : PIArray;XRes,YRes,Depth,BitSY,BitSU,BitSV : Cardinal;
                          QuantFactorY,QuantFactorU,QuantFactorV : PFArray);
PROCEDURE DeWaveletQuantGS(WLI : PIArray;WL : PFArray;XRes,YRes,Depth : Cardinal;QuantFactor : PFArray);//Inverse
PROCEDURE DeWaveletQuantRGB(YI,UI,VI : PIArray;RF,GF,BF : PFArray;XRes,YRes,Depth : Cardinal;QuantFactorY,QuantFactorU,QuantFactorV : PFArray);
FUNCTION  WaveletZeroOutGS(WL : PFArray;EPS : Double;Bits : Byte;XRes,YRes,Depth : Cardinal) : Cardinal;//Kick Coefficients smaller "EPS"
FUNCTION  WaveletCountZerosGS(WLI : PIArray;XRes,YRes,Depth : Cardinal) : Cardinal;//Count overall Zeros in HWL
PROCEDURE ReadHWL(Name : String;WLR,WLG,WLB : PIArray;QuantFactorR,QuantFactorG,QuantFactorB : PFArray);//Read HWL-File
PROCEDURE WriteHWL(Name : String;WLR,WLG,WLB : PIArray;XRes,YRes,BPP,Depth : Cardinal;
                   QuantFactorR,QuantFactorG,QuantFactorB : PFArray;QuantBitSY,QuantBitSU,QuantBitSV : Byte);//Write HWL-File
PROCEDURE ReadHeaderHWL(Name : String;Var Head : HWL_Header);//Get HWL-File-Information

IMPLEMENTATION

PROCEDURE HWL2Mem(Var Pic : Pointer;Var Head : HWL_Header;Name : String;AllocMem : Boolean);
  Var pic_qHWL,pic_qHWLr,pic_qHWLg,pic_qHWLb : PIArray;
      pic_oHWL,pic_oHWLr,pic_oHWLg,pic_oHWLb : PFArray;
      pic_oBMP,pic_oBMPr,pic_oBMPg,pic_oBMPb : PFArray;
      pic_quantfactor,pic_quantfactorr,pic_quantfactorg,pic_quantfactorb : PFArray;
  Procedure CopyDouble2ByteGS(src : PFArray;dest : PBArray);//GreyScale-FloatingPoint-BMP to Byte-BMP
    Var v : LongInt;
    Begin
      for v:=0 to Head.Height*Head.Width-1 do Begin
       if (src^[v]>0.0) then Begin
        if (src^[v]<255.0) then dest^[v]:=round(src^[v])
         else dest^[v]:=255;
       End else dest^[v]:=0;
      End;
    End;
  Procedure CopyDouble2CardinalRGB(r,g,b : PFArray;dest : PCArray);//RGB-FloatingPoint-BMP to 32Bit-BMP
    Var v   : LongInt;
        col : Cardinal;
    Begin
      for v:=0 to Head.Height*Head.Width-1 do Begin
     if b^[v]>0.0 then Begin
      if b^[v]<255.0 then col:=round(b^[v])
       else col:=255;
     End else col:=0;

     if g^[v]>0.0 then Begin
      if g^[v]<255.0 then col:=col or (round(g^[v])shl 8)
       else col:=col or $FF00;
     End;

     if r^[v]>0.0 then Begin
      if r^[v]<255.0 then col:=col or (round(r^[v])shl 16)
       else col:=col or $FF0000;
     End;
     dest^[v]:=col;
    End;
 End;


Begin

  ReadHeaderHWL(Name,Head);

  if AllocMem then Begin
   if Head.BPP=HWL_GS then reallocmem(Pic,Head.Width*Head.Height)
    else if Head.BPP=HWL_RGB then reallocmem(Pic,Head.Width*Head.Height*4);
  End;

  if Head.BPP=HWL_GS then Begin
   getmem(pic_qHWL,Head.Width*Head.Height*sizeof(LongInt));
   getmem(pic_oHWL,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_oBMP,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_quantfactor,18*sizeof(Double));

   ReadHWL(Name,pic_qHWL,nil,nil,pic_quantfactor,nil,nil);//Load HWL

   DeWaveletQuantGS(pic_qHWL,pic_oHWL,Head.Width,Head.Height,Head.Depth,pic_quantfactor);//DeQuant

   DeWaveletGS(pic_oHWL,pic_oBMP,Head.Width,Head.Height,Head.Width,Head.Height,Head.Depth);//Restore BMP from HWL

   CopyDouble2ByteGS(pic_oBMP,Pic);

   freemem(pic_quantfactor);
   freemem(pic_oBMP);
   freemem(pic_oHWL);
   freemem(pic_qHWL);
  End else if Head.BPP=HWL_RGB then Begin
   getmem(pic_qHWLr,Head.Width*Head.Height*sizeof(LongInt));
   getmem(pic_oHWLr,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_oBMPr,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_qHWLg,Head.Width*Head.Height*sizeof(LongInt));
   getmem(pic_oHWLg,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_oBMPg,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_qHWLb,Head.Width*Head.Height*sizeof(LongInt));
   getmem(pic_oHWLb,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_oBMPb,Head.Width*Head.Height*sizeof(Double));
   getmem(pic_quantfactorr,18*sizeof(Double));
   getmem(pic_quantfactorg,18*sizeof(Double));
   getmem(pic_quantfactorb,18*sizeof(Double));

   ReadHWL(Name,pic_qHWLr,pic_qHWLg,pic_qHWLb,pic_quantfactorr,pic_quantfactorg,pic_quantfactorb);//Load HWL

   DeWaveletQuantRGB(pic_qHWLr,pic_qHWLg,pic_qHWLb,pic_oHWLr,pic_oHWLg,pic_oHWLb,Head.Width,Head.Height,Head.Depth,pic_quantfactorr,pic_quantfactorg,pic_quantfactorb);//DeQuant

   DeWaveletRGB(pic_oHWLr,pic_oHWLg,pic_oHWLb,pic_oBMPr,pic_oBMPg,pic_oBMPb,Head.Width,Head.Height,Head.Width,Head.Height,Head.Depth);//Restore BMP from HWL

   CopyDouble2CardinalRGB(pic_oBMPr,pic_oBMPg,pic_oBMPb,Pic);

   freemem(pic_quantfactorb);
   freemem(pic_quantfactorg);
   freemem(pic_quantfactorr);
   freemem(pic_oBMPb);
   freemem(pic_oHWLb);
   freemem(pic_qHWLb);
   freemem(pic_oBMPg);
   freemem(pic_oHWLg);
   freemem(pic_qHWLg);
   freemem(pic_oBMPr);
   freemem(pic_oHWLr);
   freemem(pic_qHWLr);
  End;

End;

//

PROCEDURE WaveletGS(Pic : PFArray;WL : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);
 Var x,y : LongInt;
     tempx,tempy : PFArray;
     factor : Double;
     offset : Cardinal;
Begin
  factor:=(1.0/sqrt(2.0));//Normalized Haar

  getmem(tempx,XRes*YRes*sizeof(Double));//Temporary Transformation-Storage
  getmem(tempy,XRes*YRes*sizeof(Double));

  for y:=0 to DY-1 do Begin               //Transform Rows
   offset:=y*XRes;
   for x:=0 to (DX div 2)-1 do Begin
    tempx^[x +offset]            := (Pic^[x*2 +offset] + Pic^[(x*2+1) +offset]) *factor;//LOW-PASS
    tempx^[(x+DX div 2) +offset] := (Pic^[x*2 +offset] - Pic^[(x*2+1) +offset]) *factor;//HIGH-PASS
   End;
  End;

  for x:=0 to DX-1 do                     //Transform Columns
   for y:=0 to (DY div 2)-1 do Begin
    tempy^[x +y*XRes]            := (tempx^[x +y*2*XRes] + tempx^[x +(y*2+1)*XRes]) *factor;//LOW-PASS
    tempy^[x +(y+DY div 2)*XRes] := (tempx^[x +y*2*XRes] - tempx^[x +(y*2+1)*XRes]) *factor;//HIGH-PASS
   End;

  for y:=0 to DY-1 do
   move(tempy^[y*XRes],WL^[y*XRes],DX*sizeof(Double));//Copy to Wavelet

  freemem(tempx);//Free Temp-Storage
  freemem(tempy);

  if Depth>0 then waveletgs(WL,WL,DX div 2,DY div 2,XRes,YRes,Depth-1);//Repeat for SubDivisionDepth
End;

PROCEDURE WaveletRGB(RF,GF,BF : PFArray;WLR,WLG,WLB : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);
 Var yf,uf,vf : PFArray;
     offset : LongInt;
Begin
  getmem(yf,XRes*YRes*sizeof(Double));
  getmem(uf,XRes*YRes*sizeof(Double));
  getmem(vf,XRes*YRes*sizeof(Double));

  for offset:=0 to XRes*YRes-1 do Begin //Convert the RGB-Coefficients to YUV
   yf^[offset]:=0.3*RF^[offset]+0.59*GF^[offset]+0.11*BF^[offset];
   uf^[offset]:=(BF^[offset]-yf^[offset])*0.493;
   vf^[offset]:=(RF^[offset]-yf^[offset])*0.877;
  End;

  WaveletGS(yf,WLR,DX,DY,XRes,YRes,Depth);
  WaveletGS(uf,WLG,DX,DY,XRes,YRes,Depth);
  WaveletGS(vf,WLB,DX,DY,XRes,YRes,Depth);

  freemem(vf);
  freemem(uf);
  freemem(yf);
End;

PROCEDURE DeWaveletGS(WL : PFArray;Pic : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);
 Var x,y : LongInt;
     tempx,tempy : PFArray;
     offset : Cardinal;
     factor : Double;
Begin
  if Depth>0 then dewaveletgs(WL,WL,DX div 2,DY div 2,XRes,YRes,Depth-1);//Repeat for SubDivisionDepth

  factor:=(1.0/sqrt(2.0));//Normalized Haar

  getmem(tempx,XRes*YRes*sizeof(Double));//Temporary Transformation-Storage
  getmem(tempy,XRes*YRes*sizeof(Double));

  ////

  for x:=0 to DX-1 do Begin //The first and last pixel has to be done "normal"
   y:=0;
   tempy^[x +y*2*XRes]     :=(WL^[x +y*XRes] + WL^[x +(y+(DY div 2))*XRes])*factor;//LOW-PASS
   tempy^[x +(y*2+1)*XRes] :=(WL^[x +y*XRes] - WL^[x +(y+(DY div 2))*XRes])*factor;//HIGH-PASS
   y:=(DY div 2)-1;
   if (y>0) then Begin
    tempy^[x +y*2*XRes]     :=(WL^[x +y*XRes] + WL^[x +(y+(DY div 2))*XRes])*factor;//LOW-PASS
    tempy^[x +(y*2+1)*XRes] :=(WL^[x +y*XRes] - WL^[x +(y+(DY div 2))*XRes])*factor;//HIGH-PASS
   End;
  End;

  //

  if ((DY div 2)-2>=1) then Begin           //More then 2 pixels in the row?
   if (DY>=4) then Begin                    //DY must be greater then 4 to make the faked algo look good.. else it must be done "normal"
    for x:=0 to DX-1 do                     //Inverse Transform Colums (fake: if (high-pass coefficient=0.0) and (surrounding high-pass coefficients=0.0) then interpolate between surrounding low-pass coefficients)
     for y:=1 to (DY div 2)-2 do
      if (WL^[x +(y+(DY div 2))*XRes]<>0.0) then Begin //!UPDATED
       tempy^[x +y*2*XRes]     :=(WL^[x +y*XRes] + WL^[x +(y+(DY div 2))*XRes])*factor;//LOW-PASS
       tempy^[x +(y*2+1)*XRes] :=(WL^[x +y*XRes] - WL^[x +(y+(DY div 2))*XRes])*factor;//HIGH-PASS
      End else Begin //!UPDATED
       if (WL^[x +(y-1+(DY div 2))*XRes]=0.0) and (WL^[x +(y+1)*XRes]<>WL^[x +y*XRes]) and ((y=(DY div 2)-2) or (WL^[x +(y+1)*XRes]<>WL^[x +(y+2)*XRes])) then tempy^[x +y*2*XRes]:=(WL^[x +y*XRes]*0.8 + WL^[x +(y-1)*XRes]*0.2)*factor //LOW-PASS
        else tempy^[x +y*2*XRes]:=WL^[x +y*XRes]*factor;
       if (WL^[x +(y+1+(DY div 2))*XRes]=0.0) and (WL^[x +(y-1)*XRes]<>WL^[x +y*XRes]) and ((y=1) or (WL^[x +(y-1)*XRes]<>WL^[x +(y-2)*XRes])) then tempy^[x +(y*2+1)*XRes]:=(WL^[x +y*XRes]*0.8 + WL^[x +(y+1)*XRes]*0.2)*factor //HIGH-PASS
        else tempy^[x +(y*2+1)*XRes]:=WL^[x +y*XRes]*factor;
      End;
   End else //DY<4
    for x:=0 to DX-1 do
     for y:=1 to (DY div 2)-2 do Begin
      tempy^[x +y*2*XRes]     :=(WL^[x +y*XRes] + WL^[x +(y+(DY div 2))*XRes])*factor;//LOW-PASS
      tempy^[x +(y*2+1)*XRes] :=(WL^[x +y*XRes] - WL^[x +(y+(DY div 2))*XRes])*factor;//HIGH-PASS
     End;
  End;

  ////

  for y:=0 to DY-1 do Begin //The first and last pixel has to be done "normal"
   offset:=y*XRes;
   x:=0;
   tempx^[x*2 +offset]     :=(tempy^[x +offset] + tempy^[(x+DX div 2) +offset])*factor;//LOW-PASS
   tempx^[(x*2+1) +offset] :=(tempy^[x +offset] - tempy^[(x+DX div 2) +offset])*factor;//HIGH-PASS
   x:=(DX div 2)-1;
   if (x>0) then Begin
    tempx^[x*2 +offset]     :=(tempy^[x +offset] + tempy^[(x+DX div 2) +offset])*factor;//LOW-PASS
    tempx^[(x*2+1) +offset] :=(tempy^[x +offset] - tempy^[(x+DX div 2) +offset])*factor;//HIGH-PASS
   End;
  End;

  //

  if ((DX div 2)-2>=1) then Begin
   if (DX>=4) then Begin
    for y:=0 to DY-1 do Begin               //Inverse Transform Rows (fake: if (high-pass coefficient=0.0) and (surrounding high-pass coefficients=0.0) then interpolate between surrounding low-pass coefficients)
     offset:=y*XRes;
     for x:=1 to (DX div 2)-2 do
      if (tempy^[(x+DX div 2) +offset]<>0.0) then Begin //!UPDATED
       tempx^[x*2 +offset]     :=(tempy^[x +offset] + tempy^[(x+DX div 2) +offset])*factor;//LOW-PASS
       tempx^[(x*2+1) +offset] :=(tempy^[x +offset] - tempy^[(x+DX div 2) +offset])*factor;//HIGH-PASS
      End else Begin //!UPDATED
       if (tempy^[(x-1+DX div 2) +offset]=0.0) and (tempy^[(x+1) +offset]<>tempy^[x +offset]) and ((x=(DX div 2)-2) or (tempy^[(x+1) +offset]<>tempy^[(x+2) +offset])) then tempx^[x*2 +offset]:=(tempy^[x +offset]*0.8 + tempy^[(x-1) +offset]*0.2)*factor //LOW-PASS
        else tempx^[x*2 +offset]:=tempy^[x +offset]*factor;
       if (tempy^[(x+1+DX div 2) +offset]=0.0) and (tempy^[(x-1) +offset]<>tempy^[x +offset]) and ((x=1) or (tempy^[(x-1) +offset]<>tempy^[(x-2) +offset])) then tempx^[(x*2+1) +offset]:=(tempy^[x +offset]*0.8 + tempy^[(x+1) +offset]*0.2)*factor //HIGH-PASS
        else tempx^[(x*2+1) +offset]:=tempy^[x +offset]*factor;
      End;
    End;
   End else //DX<4
    for y:=0 to DY-1 do Begin               //Inverse Transform Rows (fake: if (high-pass coefficient=0.0) and (surrounding high-pass coefficients=0.0) then interpolate between surrounding low-pass coefficients)
     offset:=y*XRes;
     for x:=1 to (DX div 2)-2 do Begin
      tempx^[x*2 +offset]     :=(tempy^[x +offset] + tempy^[(x+DX div 2) +offset])*factor;//LOW-PASS
      tempx^[(x*2+1) +offset] :=(tempy^[x +offset] - tempy^[(x+DX div 2) +offset])*factor;//HIGH-PASS
     End;
    End;
  End;

  ////

  for y:=0 to DY-1 do
   move(tempx^[y*XRes],Pic^[y*XRes],DX*sizeof(Double));//Copy to Pic

  freemem(tempx);//Free Temp-Storage
  freemem(tempy);
End;

PROCEDURE DeWaveletRGB(WLR,WLG,WLB : PFArray;RF,GF,BF : PFArray;DX,DY,XRes,YRes,Depth : Cardinal);
 Var yf,uf,vf : PFArray;
     offset : LongInt;
Begin
  getmem(yf,XRes*YRes*sizeof(Double));
  getmem(uf,XRes*YRes*sizeof(Double));
  getmem(vf,XRes*YRes*sizeof(Double));

  DeWaveletGS(WLR,yf,DX,DY,XRes,YRes,Depth);
  DeWaveletGS(WLG,uf,DX,DY,XRes,YRes,Depth);
  DeWaveletGS(WLB,vf,DX,DY,XRes,YRes,Depth);

  for offset:=0 to XRes*YRes-1 do Begin //Convert the RGB-Coefficients to YUV
   RF^[offset]:=yf^[offset]+vf^[offset]*1.140251;
   BF^[offset]:=yf^[offset]+uf^[offset]*2.028398;
   GF^[offset]:=(yf^[offset]-RF^[offset]*0.3-BF^[offset]*0.11)*1.694915;
  End;

  freemem(vf);
  freemem(uf);
  freemem(yf);
End;

PROCEDURE WaveletQuantGS(WL : PFArray;WLI : PIArray;XRes,YRes,Depth,Bits : Cardinal;QuantFactor : PFArray);
 Var startx,d,x,y,DX,DY,offset : LongInt;
     min,max,factor : Double;
Begin
 //HIGH-PASS
 for d:=0 to Depth do Begin //Repeat for all SubDivisions
  min:=100000000.0;
  max:=-100000000.0;

  if d>0 then DY:=(YRes shr d) -1 //Shifting Factors (to "navigate" within the Wavelet-HighPass)
   else DY:=YRes-1;
  if d>0 then DX:=(XRes shr d) -1
   else DX:=XRes-1;

  for y:=0 to DY do Begin //Get Minimum/Maximum Coefficient from current Subdivision-High-Pass
   offset:=y*XRes;
   if (y>=(YRes shr (d+1))) then startx:=0 //Only look inside the High-Pass
    else startx:=(XRes shr (d+1));
   for x:=startx to DX do Begin
    if WL^[x+offset]<min then min:=WL^[x+offset];//Smaller/Bigger ??!
    if WL^[x+offset]>max then max:=WL^[x+offset];
   End;
  End;

  if (min<>0.0) or (max<>0.0) then //Calc Quantizer Factor
   if abs(min)>abs(max) then factor:=(1 shl Bits -1)/abs(min)
   else factor:=(1 shl Bits -1)/abs(max)
  else factor:=0.0;

  for y:=0 to DY do Begin //Quantize (Linear Scale) the Coefficients
   offset:=y*XRes;
   if (y>=(YRes shr (d+1))) then startx:=0 //Only quantize inside the High-Pass
    else startx:=(XRes shr (d+1));
   for x:=startx to DX do
    WLI^[x+offset]:=round(WL^[x+offset]*factor);
  End;

  QuantFactor^[d]:=factor;//Save current Quantize-Factor
 End;

  //LOW-PASS
  min:=100000000.0;
  max:=-100000000.0;

  for y:=0 to (YRes shr (Depth+1))-1 do Begin //Get Minimum/Maximum Value from remaining Subdivision-Low-Pass
   offset:=y*XRes;
   for x:=0 to (XRes shr (Depth+1))-1 do Begin
    if WL^[x+offset]<min then min:=WL^[x+offset];
    if WL^[x+offset]>max then max:=WL^[x+offset];
   End;
  End;

  if (min<>0.0) or (max<>0.0) then Begin //Calc Quantizer-factor
   if abs(min)>abs(max) then factor:=(1 shl Bits -1)/abs(min)
    else factor:=(1 shl Bits -1)/abs(max);
  End else factor:=0.0;

//  application.messagebox(@(floattostr(min)+'/'+floattostr(max)+'/'+floattostr(factor)+#0)[1],'min/max/factor',0);//TESTING PURPOSE

  for y:=0 to (YRes shr (Depth+1))-1 do Begin //Quantize (Scale) Values
   offset:=y*XRes;
   for x:=0 to (XRes shr (Depth+1))-1 do
    WLI^[x+offset]:=round(WL^[x+offset]*factor);
  End;

  QuantFactor^[Depth+1]:=factor;//Save Factor

End;

PROCEDURE WaveletQuantRGB(RF,GF,BF : PFArray;YI,UI,VI : PIArray;XRes,YRes,Depth,BitSY,BitSU,BitSV : Cardinal;QuantFactorY,QuantFactorU,QuantFactorV : PFArray);
Begin
  WaveletQuantGS(RF,YI,XRes,YRes,Depth,BitSY,QuantFactorY);
  WaveletQuantGS(GF,UI,XRes,YRes,Depth,BitSU,QuantFactorU);
  WaveletQuantGS(BF,VI,XRes,YRes,Depth,BitSV,QuantFactorV);
End;

PROCEDURE DeWaveletQuantGS(WLI : PIArray;WL : PFArray;XRes,YRes,Depth : Cardinal;QuantFactor : PFArray);
 Var DX,DY,x,y,offset,d,startx : LongInt;
     factor : Double;
Begin
 //HIGH-PASS
 for d:=0 to Depth do Begin        //Repeat for all SubDivisions
  if d>0 then DY:=(YRes shr d) -1  //Shifting Factors (to "navigate" within the Wavelet-HighPass)
   else DY:=YRes-1;
  if d>0 then DX:=(XRes shr d) -1
   else DX:=XRes-1;

  if QuantFactor^[d]<>0.0 then factor:=1.0/QuantFactor^[d] //Invert QuantFactor
   else factor:=0.0;

  for y:=0 to DY do Begin
   offset:=y*XRes;
   if (y>=(YRes shr (d+1))) then startx:=0 //Only dequantize inside the High-Pass
    else startx:=(XRes shr (d+1));
   for x:=startx to DX do
    WL^[x+offset]:=WLI^[x+offset]*factor; //dequant
  End;
 End;

  //LOW-PASS
  if QuantFactor^[Depth+1]<>0.0 then factor:=1.0/QuantFactor^[Depth+1] //Invert QuantFactor
   else factor:=0.0;

  for y:=0 to (YRes shr (Depth+1))-1 do Begin
   offset:=y*XRes;
   for x:=0 to (XRes shr (Depth+1))-1 do
    WL^[x+offset]:=WLI^[x+offset]*factor;//Dequant LowPass
  End;
End;

PROCEDURE DeWaveletQuantRGB(YI,UI,VI : PIArray;RF,GF,BF : PFArray;XRes,YRes,Depth : Cardinal;QuantFactorY,QuantFactorU,QuantFactorV : PFArray);
Begin
  DeWaveletQuantGS(YI,RF,XRes,YRes,Depth,QuantFactorY);
  DeWaveletQuantGS(UI,GF,XRes,YRes,Depth,QuantFactorU);
  DeWaveletQuantGS(VI,BF,XRes,YRes,Depth,QuantFactorV);
End;

FUNCTION  WaveletZeroOutGS(WL : PFArray;EPS : Double;Bits : Byte;XRes,YRes,Depth : Cardinal) : Cardinal;
 Var x,y : LongInt;
     c,offset,startx : Cardinal;
Begin
  c:=0;//Numbers of Coefficients kicked

  for y:=0 to YRes-1 do Begin
   offset:=y*XRes;
   if (y>=(YRes shr (Depth+1))) then startx:=0  //Only High-Pass
    else startx:=(XRes shr (Depth+1));
   for x:=startx to XRes-1 do                   //Search for all Coefficients<>0.0 and <=EPS
    if (abs(WL^[x+offset])<=EPS) and (WL^[x+offset]<>0.0) then Begin WL^[x+offset]:=0.0;inc(c);End;
  End;

  WaveletZeroOutGS:=c;
End;

FUNCTION  WaveletCountZerosGS(WLI : PIArray;XRes,YRes,Depth : Cardinal) : Cardinal;
 Var v : LongInt;
     c : Cardinal;
Begin
  c:=0;//Count all Zeros in Wavelet

  for v:=0 to XRes*YRes-1 do
   if (WLI^[v]=0) then inc(c);

  WaveletCountZerosGS:=c;
End;

PROCEDURE DeWaveletPackGS(WLI : PIArray;bitbuffer : PBArray;bitindex : Cardinal;databuffer : PBArray;dataindex : Cardinal;XRes,YRes,Depth,Bits : Cardinal);
 Var v : Cardinal;
     bitcounter,datacounter : Cardinal;
Begin
  v:=0;          //Index for the Wavelet
  bitcounter:=0; //Index for the 2Bit-Table (HWL_ISO_ZERO,HWL_RLE_ZERO,HWL_POS,HWL_NEG)
  datacounter:=0;//Index for the 8Bit-DataTable

  while (bitcounter<=bitindex) and (datacounter<=dataindex) and (v<XRes*YRes) do Begin
   if (bitbuffer^[bitcounter]=HWL_ISO_ZERO) then WLI^[v]:=0            //Single Zero found
   else if bitbuffer^[bitcounter]=HWL_RLE_ZERO then Begin              //(databuffer^[datacounter]+1) Zeros found
     inc(bitcounter);                                                 //move on to read upper 2Bits of amount
     fillchar(WLI^[v],(databuffer^[datacounter]+(bitbuffer^[bitcounter] shl Bits)+1)*sizeof(LongInt),0);
     inc(v,databuffer^[datacounter]+(bitbuffer^[bitcounter] shl Bits));
     inc(datacounter);
    End else if bitbuffer^[bitcounter]=HWL_POS then Begin              //Positive Significant Coefficient found
     WLI^[v]:=databuffer^[datacounter];
     inc(datacounter);
    End else Begin                                                     //Negative Significant Coefficient found
     WLI^[v]:=-databuffer^[datacounter];
     inc(datacounter);
    End;
   inc(bitcounter);//move on =)
   inc(v);
  End;
End;

PROCEDURE ReadHeaderHWL(Name : String;Var Head : HWL_Header);
 Var f : file;
Begin
  Assignfile(f,Name);
  filemode:=0;
  Reset(f,1);
  blockread(f,Head,sizeof(Head));
  Close(f);
End;

PROCEDURE ReadHWL(Name : String;WLR,WLG,WLB : PIArray;QuantFactorR,QuantFactorG,QuantFactorB : PFArray);
 Var f : file;
     Head : HWL_Header;
     bitbuffer,pbitbuffer : PBArray;
     databuffer,pdatabuffer : PBArray;
     bitindex,dataindex,pbits,pdata,data,data2 : Cardinal;
     v : LongInt;
Begin
  Assignfile(f,Name);
  filemode:=0;
  Reset(f,1);

  blockread(f,Head,sizeof(Head));

  //if Head.ID<>'HWL' then ..

  if Head.BPP=HWL_GS then Begin //GREYSCALE
   blockread(f,QuantFactorR^,(Head.Depth+2)*sizeof(Double));//Read Quantizer-Factors

   bitindex:=Head.BitSR; //2Bit-Packets in BitTable
   dataindex:=Head.DataR;//QuantBit-Packets in DataTable

   getmem(bitbuffer,bitindex);  //Alloc Mem for Byte-Storage of the Tables
   getmem(databuffer,dataindex);

   //UnPack the BitBuffer
   pbits:=bitindex div 4;

   if (bitindex mod 4=0) then Begin
    getmem(pbitbuffer,pbits);   //Temp-Storage for Packed BitTable
    blockread(f,pbitbuffer^,pbits);
   End else Begin
    getmem(pbitbuffer,pbits+1);
    blockread(f,pbitbuffer^,pbits+1);
   End;

   for v:=0 to pbits-1 do Begin //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v*4]:=pbitbuffer^[v] and 3;
    bitbuffer^[v*4+1]:=(pbitbuffer^[v] and (3 shl 2)) shr 2;
    bitbuffer^[v*4+2]:=(pbitbuffer^[v] and (3 shl 4)) shr 4;
    bitbuffer^[v*4+3]:=pbitbuffer^[v] shr 6;
   End;

   if (bitindex mod 4>0) then Begin
    bitbuffer^[pbits*4]:=pbitbuffer^[pbits] and 3;
    if (bitindex mod 4>1) then bitbuffer^[pbits*4+1]:=(pbitbuffer^[pbits] and (3 shl 2)) shr 2;
    if (bitindex mod 4>2) then bitbuffer^[pbits*4+2]:=(pbitbuffer^[pbits] and (3 shl 4)) shr 4;
   End;

   freemem(pbitbuffer);
   //End UnPack

   //Unpack the DataBuffer
   if (Head.QuantBitSY<>8) then Begin //Can we copy directly into databuffer?
    if ((dataindex*Head.QuantBitSY) mod 8=0) then pdata:=(dataindex*Head.QuantBitSY) div 8
     else pdata:=(dataindex*Head.QuantBitSY) div 8 +1;

    getmem(pdatabuffer,pdata);      //Temp-Storage for Packed DataTable
    blockread(f,pdatabuffer^,pdata);

    pbits:=0;
    for v:=0 to dataindex-1 do Begin //ReStore Bytes out of the "Packed" BitStream
     if (pbits mod 8=0) then Begin
      data:=pdatabuffer^[pbits div 8] and ((1 shl Head.QuantBitSY)-1);
     End else Begin
      data:=(Cardinal(pdatabuffer^[pbits div 8]) shr (pbits mod 8)) and ((1 shl Head.QuantBitSY)-1);
      if ((pbits+Head.QuantBitSY) div 8>pbits div 8) then Begin
       data2:=Cardinal(pdatabuffer^[(pbits div 8)+1]) and ((1 shl ((pbits+Head.QuantBitSY) mod 8))-1);
       data:=data or (data2 shl (8-(pbits mod 8)));
      End;
     End;
     databuffer^[v]:=data;
     inc(pbits,Head.QuantBitSY);
    End;

    freemem(pdatabuffer);
   End else blockread(f,databuffer^,dataindex);
   //End Unpack

   DeWaveletPackGS(WLR,bitbuffer,bitindex,databuffer,dataindex,Head.Width,Head.Height,Head.Depth,Head.QuantBitSY);//Restore Wavelet from the Byte-Tables

   freemem(bitbuffer);
   freemem(databuffer);
  End else if Head.BPP=HWL_RGB then Begin //RGB
   blockread(f,QuantFactorR^,(Head.Depth+2)*sizeof(Double));//Read Quantizer-Factors
   blockread(f,QuantFactorG^,(Head.Depth+2)*sizeof(Double));
   blockread(f,QuantFactorB^,(Head.Depth+2)*sizeof(Double));

   //RED

   bitindex:=Head.BitSR; //2Bit-Packets in BitTable (Red)
   dataindex:=Head.DataR;//QuantBit-Packets in DataTable

   getmem(bitbuffer,bitindex); //Alloc Mem for Byte-Storage of the Tables
   getmem(databuffer,dataindex);

   //UnPack the BitBuffer
   pbits:=bitindex div 4;

   if (bitindex mod 4=0) then Begin
    getmem(pbitbuffer,pbits);   //Temp-Storage for Packed BitTable
    blockread(f,pbitbuffer^,pbits);
   End else Begin
    getmem(pbitbuffer,pbits+1);
    blockread(f,pbitbuffer^,pbits+1);
   End;

   for v:=0 to pbits-1 do Begin //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v*4]:=pbitbuffer^[v] and 3;
    bitbuffer^[v*4+1]:=(pbitbuffer^[v] and (3 shl 2)) shr 2;
    bitbuffer^[v*4+2]:=(pbitbuffer^[v] and (3 shl 4)) shr 4;
    bitbuffer^[v*4+3]:=pbitbuffer^[v] shr 6;
   End;

   if (bitindex mod 4>0) then Begin
    bitbuffer^[pbits*4]:=pbitbuffer^[pbits] and 3;
    if (bitindex mod 4>1) then bitbuffer^[pbits*4+1]:=(pbitbuffer^[pbits] and (3 shl 2)) shr 2;
    if (bitindex mod 4>2) then bitbuffer^[pbits*4+2]:=(pbitbuffer^[pbits] and (3 shl 4)) shr 4;
   End;

   freemem(pbitbuffer);
   //End UnPack

   //Unpack the DataBuffer
   if (Head.QuantBitSY<>8) then Begin //Can we copy directly into databuffer?
    if ((dataindex*Head.QuantBitSY) mod 8=0) then pdata:=(dataindex*Head.QuantBitSY) div 8
     else pdata:=(dataindex*Head.QuantBitSY) div 8 +1;

    getmem(pdatabuffer,pdata);//Temp-Storage for Packed DataTable
    blockread(f,pdatabuffer^,pdata);

    pbits:=0;
    for v:=0 to dataindex-1 do Begin //ReStore Bytes out of the "Packed" BitStream
     if (pbits mod 8=0) then Begin
      data:=pdatabuffer^[pbits div 8] and ((1 shl Head.QuantBitSY)-1);
     End else Begin
      data:=(Cardinal(pdatabuffer^[pbits div 8]) shr (pbits mod 8)) and ((1 shl Head.QuantBitSY)-1);
      if ((pbits+Head.QuantBitSY) div 8>pbits div 8) then Begin
       data2:=Cardinal(pdatabuffer^[(pbits div 8)+1]) and ((1 shl ((pbits+Head.QuantBitSY) mod 8))-1);
       data:=data or (data2 shl (8-(pbits mod 8)));
      End;
     End;
     databuffer^[v]:=data;
     inc(pbits,Head.QuantBitSY);
    End;

    freemem(pdatabuffer);
   End else blockread(f,databuffer^,dataindex);
   //End Unpack

   DeWaveletPackGS(WLR,bitbuffer,bitindex,databuffer,dataindex,Head.Width,Head.Height,Head.Depth,Head.QuantBitSY);

   freemem(bitbuffer);
   freemem(databuffer);

   //GREEN

   bitindex:=Head.BitSG; //2Bit-Packets in BitTable (Green)
   dataindex:=Head.DataG;//QuantBit-Packets in DataTable

   getmem(bitbuffer,bitindex); //Alloc Mem for Byte-Storage of the Tables
   getmem(databuffer,dataindex);

   //UnPack the BitBuffer
   pbits:=bitindex div 4;

   if (bitindex mod 4=0) then Begin
    getmem(pbitbuffer,pbits);   //Temp-Storage for Packed BitTable
    blockread(f,pbitbuffer^,pbits);
   End else Begin
    getmem(pbitbuffer,pbits+1);
    blockread(f,pbitbuffer^,pbits+1);
   End;

   for v:=0 to pbits-1 do Begin //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v*4]:=pbitbuffer^[v] and 3;
    bitbuffer^[v*4+1]:=(pbitbuffer^[v] and (3 shl 2)) shr 2;
    bitbuffer^[v*4+2]:=(pbitbuffer^[v] and (3 shl 4)) shr 4;
    bitbuffer^[v*4+3]:=pbitbuffer^[v] shr 6;
   End;

   if (bitindex mod 4>0) then Begin
    bitbuffer^[pbits*4]:=pbitbuffer^[pbits] and 3;
    if (bitindex mod 4>1) then bitbuffer^[pbits*4+1]:=(pbitbuffer^[pbits] and (3 shl 2)) shr 2;
    if (bitindex mod 4>2) then bitbuffer^[pbits*4+2]:=(pbitbuffer^[pbits] and (3 shl 4)) shr 4;
   End;

   freemem(pbitbuffer);
   //End UnPack

   //Unpack the DataBuffer
   if (Head.QuantBitSU<>8) then Begin //Can we copy directly into databuffer?
    if ((dataindex*Head.QuantBitSU) mod 8=0) then pdata:=(dataindex*Head.QuantBitSU) div 8
     else pdata:=(dataindex*Head.QuantBitSU) div 8 +1;

    getmem(pdatabuffer,pdata);//Temp-Storage for Packed DataTable
    blockread(f,pdatabuffer^,pdata);

    pbits:=0;
    for v:=0 to dataindex-1 do Begin //ReStore Bytes out of the "Packed" BitStream
     if (pbits mod 8=0) then Begin
      data:=pdatabuffer^[pbits div 8] and ((1 shl Head.QuantBitSU)-1);
     End else Begin
      data:=(Cardinal(pdatabuffer^[pbits div 8]) shr (pbits mod 8)) and ((1 shl Head.QuantBitSU)-1);
      if ((pbits+Head.QuantBitSU) div 8>pbits div 8) then Begin
       data2:=Cardinal(pdatabuffer^[(pbits div 8)+1]) and ((1 shl ((pbits+Head.QuantBitSU) mod 8))-1);
       data:=data or (data2 shl (8-(pbits mod 8)));
      End;
     End;
     databuffer^[v]:=data;
     inc(pbits,Head.QuantBitSU);
    End;

    freemem(pdatabuffer);
   End else blockread(f,databuffer^,dataindex);
   //End Unpack

   DeWaveletPackGS(WLG,bitbuffer,bitindex,databuffer,dataindex,Head.Width,Head.Height,Head.Depth,Head.QuantBitSU);

   freemem(bitbuffer);
   freemem(databuffer);

   //BLUE

   bitindex:=Head.BitSB; //2Bit-Packets in BitTable (Blue)
   dataindex:=Head.DataB;//QuantBit-Packets in DataTable

   getmem(bitbuffer,bitindex);  //Alloc Mem for Byte-Storage of the Tables
   getmem(databuffer,dataindex);

   //UnPack the BitBuffer
   pbits:=bitindex div 4;

   if (bitindex mod 4=0) then Begin
    getmem(pbitbuffer,pbits);   //Temp-Storage for Packed BitTable
    blockread(f,pbitbuffer^,pbits);
   End else Begin
    getmem(pbitbuffer,pbits+1);
    blockread(f,pbitbuffer^,pbits+1);
   End;

   for v:=0 to pbits-1 do Begin //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v*4]:=pbitbuffer^[v] and 3;
    bitbuffer^[v*4+1]:=(pbitbuffer^[v] and (3 shl 2)) shr 2;
    bitbuffer^[v*4+2]:=(pbitbuffer^[v] and (3 shl 4)) shr 4;
    bitbuffer^[v*4+3]:=pbitbuffer^[v] shr 6;
   End;

   if (bitindex mod 4>0) then Begin
    bitbuffer^[pbits*4]:=pbitbuffer^[pbits] and 3;
    if (bitindex mod 4>1) then bitbuffer^[pbits*4+1]:=(pbitbuffer^[pbits] and (3 shl 2)) shr 2;
    if (bitindex mod 4>2) then bitbuffer^[pbits*4+2]:=(pbitbuffer^[pbits] and (3 shl 4)) shr 4;
   End;

   freemem(pbitbuffer);
   //End UnPack

   //Unpack the DataBuffer
   if (Head.QuantBitSV<>8) then Begin //Can we copy directly into databuffer?
    if ((dataindex*Head.QuantBitSV) mod 8=0) then pdata:=(dataindex*Head.QuantBitSV) div 8
     else pdata:=(dataindex*Head.QuantBitSV) div 8 +1;

    getmem(pdatabuffer,pdata);//Temp-Storage for Packed DataTable
    blockread(f,pdatabuffer^,pdata);

    pbits:=0;
    for v:=0 to dataindex-1 do Begin //ReStore Bytes out of the "Packed" BitStream
     if (pbits mod 8=0) then Begin
      data:=pdatabuffer^[pbits div 8] and ((1 shl Head.QuantBitSV)-1);
     End else Begin
      data:=(Cardinal(pdatabuffer^[pbits div 8]) shr (pbits mod 8)) and ((1 shl Head.QuantBitSV)-1);
      if ((pbits+Head.QuantBitSV) div 8>pbits div 8) then Begin
       data2:=Cardinal(pdatabuffer^[(pbits div 8)+1]) and ((1 shl ((pbits+Head.QuantBitSV) mod 8))-1);
       data:=data or (data2 shl (8-(pbits mod 8)));
      End;
     End;
     databuffer^[v]:=data;
     inc(pbits,Head.QuantBitSV);
    End;

    freemem(pdatabuffer);
   End else blockread(f,databuffer^,dataindex);
   //End Unpack

   DeWaveletPackGS(WLB,bitbuffer,bitindex,databuffer,dataindex,Head.Width,Head.Height,Head.Depth,Head.QuantBitSV);

   freemem(bitbuffer);
   freemem(databuffer);
  End;

  Closefile(f);
End;

PROCEDURE WaveletPackGS(WL : PIArray;bitbuffer : PBArray;Var bitindex : Cardinal;databuffer : PBArray;Var dataindex : Cardinal;XRes,YRes,Depth,Bits : Cardinal);
Var v,c,maxlength,minlength : Cardinal;

 FUNCTION Zeros2Come : Cardinal;//Count overall Zeros AFTER the current position in the Wavelet
  Var t : Cardinal;
 Begin
   t:=1;
   while (v+t<XRes*YRes-1) and (WL^[v+t]=0) and (t<maxlength) do inc(t);
   zeros2come:=t-1;
 End;

Begin
   maxlength:=1 shl (Bits+2);//Maximum RLE-length (depends on the QuantizerBits!)
   minlength:=(Bits+4) div 2;//Minimum RLE-length (otherwise the File gets bigger then possible!)

   v:=0;
   while (v<XRes*YRes) do Begin //Go through Wavelet
     if WL^[v]=0 then Begin     //Found a Zero
      c:=zeros2come;           //Count Zeros afterwards
      if c<=minlength then bitbuffer^[bitindex]:=HWL_ISO_ZERO //One (or only a few) Zeros found -> Encode Single Zero
       else Begin
        bitbuffer^[bitindex]:=HWL_RLE_ZERO;//Found a lotta Zeros =)
        inc(bitindex);                     //continue in bitTable (+2Bits for the amount!)
        databuffer^[dataindex]:=c and ((1 shl Bits)-1);//Store the first Bits of the amount in the DataBuffer
        bitbuffer^[bitindex]:=c shr Bits;  //Store the last 2 Bits in the next entry of the BitBuffer
        inc(dataindex);                    //inc databuffer-index
        inc(v,c);                          //inc position in wavelet
       End;
     End else if WL^[v]>0 then Begin   //Significant Positive
      bitbuffer^[bitindex]:=HWL_POS;
      databuffer^[dataindex]:=WL^[v]; //store in databuffer
      inc(dataindex);
     End else Begin                    //Significant Negative
      bitbuffer^[bitindex]:=HWL_NEG;
      databuffer^[dataindex]:=-WL^[v];//store in databuffer
      inc(dataindex);
     End;
    inc(bitindex);                    //continue in wavelet/bitTable
    inc(v);
   End;
End;

PROCEDURE WriteHWL(Name : String;WLR,WLG,WLB : PIArray;XRes,YRes,BPP,Depth : Cardinal;QuantFactorR,QuantFactorG,QuantFactorB : PFArray;QuantBitSY,QuantBitSU,QuantBitSV : Byte);
 Var f : file;
     Head : HWL_Header;
     bitbuffer : PBArray;
     databuffer : PBArray;
     bitindex,dataindex,pbits,pbits2,data,data2 : Cardinal;
     v : LongInt;
Begin
  Head.ID:='HWL';   //Prepare HWL-Header
  Head.Width:=XRes;
  Head.Height:=YRes;
  Head.BPP:=BPP;
  Head.Depth:=Depth;
  Head.QuantBitSY:=QuantBitSY;
  Head.QuantBitSU:=QuantBitSU;
  Head.QuantBitSV:=QuantBitSV;

  getmem(bitbuffer,XRes*YRes); //Alloc Mem for the Bit/Data-Table
  getmem(databuffer,XRes*YRes);

  Assignfile(f,Name);
  filemode:=2;
  Rewrite(f,1);

  if BPP=HWL_GS then Begin //Greyscale
   bitindex:=0;
   dataindex:=0;

   WaveletPackGS(WLR,bitbuffer,bitindex,databuffer,dataindex,XRes,YRes,Depth,QuantBitSY);//Pack the Wavelet into Byte-Tables

   //Pack the BitBuffer
   pbits:=bitindex div 4;

   for v:=0 to pbits-1 do //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v]:=bitbuffer^[v*4] or (bitbuffer^[v*4+1] shl 2) or (bitbuffer^[v*4+2] shl 4) or (bitbuffer^[v*4+3] shl 6);

   case (bitindex mod 4) of
    1: bitbuffer^[pbits]:=bitbuffer^[pbits*4];
    2: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2);
    3: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2) or (bitbuffer^[pbits*4+2] shl 4);
   End;
   //End Pack

   Head.BitSR:=bitindex;//Output Head,QuantizerFactors and BitTable
   Head.DataR:=dataindex;
   blockwrite(f,Head,sizeof(Head));
   blockwrite(f,QuantFactorR^,(Depth+2)*sizeof(Double));
   if (bitindex mod 4=0) then blockwrite(f,bitbuffer^,pbits)
    else blockwrite(f,bitbuffer^,pbits+1);

   //Pack the DataBuffer
   pbits:=0;
   for v:=0 to dataindex-1 do Begin //Pack single Bytes into a BitStream (depending on QuantizerBits)
    if (pbits mod 8=0) then Begin
     data:=databuffer^[v];
    End else Begin
     data:=Cardinal(databuffer^[v]) shl (pbits mod 8);
     if ((pbits+QuantBitSY) div 8>pbits div 8) then Begin
      data2:=data shr 8;
      data:=data and $FF;
      databuffer^[(pbits div 8)+1]:=data2;
     End;
     data:=data or (Cardinal(databuffer^[pbits div 8]) and ((1 shl (pbits mod 8))-1));
    End;
    databuffer^[pbits div 8]:=data;
    inc(pbits,QuantBitSY);
   End;
   //End Pack

   if (pbits mod 8=0) then blockwrite(f,databuffer^,pbits div 8) //Output Data-Bit-Table
    else blockwrite(f,databuffer^,(pbits div 8)+1);
  End else if BPP=HWL_RGB then Begin //RGB
   //RED
   bitindex:=0;
   dataindex:=0;

   WaveletPackGS(WLR,bitbuffer,bitindex,databuffer,dataindex,XRes,YRes,Depth,QuantBitSY);//Pack the Wavelet into Byte-Tables

   //Pack the BitBuffer
   pbits:=bitindex div 4;

   for v:=0 to pbits-1 do //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v]:=bitbuffer^[v*4] or (bitbuffer^[v*4+1] shl 2) or (bitbuffer^[v*4+2] shl 4) or (bitbuffer^[v*4+3] shl 6);

   case (bitindex mod 4) of
    1: bitbuffer^[pbits]:=bitbuffer^[pbits*4];
    2: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2);
    3: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2) or (bitbuffer^[pbits*4+2] shl 4);
   End;
   //End Pack

   if (bitindex mod 4=0) then pbits2:=pbits
    else pbits2:=pbits+1;

   //Pack the DataBuffer
   pbits:=0;
   for v:=0 to dataindex-1 do Begin //Pack single Bytes into a BitStream (depending on QuantizerBits)
    if (pbits mod 8=0) then Begin
     data:=databuffer^[v];
    End else Begin
     data:=Cardinal(databuffer^[v]) shl (pbits mod 8);
     if ((pbits+QuantBitSY) div 8>pbits div 8) then Begin
      data2:=data shr 8;
      data:=data and $FF;
      databuffer^[(pbits div 8)+1]:=data2;
     End;
     data:=data or (Cardinal(databuffer^[pbits div 8]) and ((1 shl (pbits mod 8))-1));
    End;
    databuffer^[pbits div 8]:=data;
    inc(pbits,QuantBitSY);
   End;
   //End Pack

   Head.BitSR:=bitindex; //Output Head,QuantizerFactors (Red,Green,Blue), BitTable (Red) and DataTable (Red)
   Head.DataR:=dataindex;
   blockwrite(f,Head,sizeof(Head));
   blockwrite(f,QuantFactorR^,(Depth+2)*sizeof(Double));
   blockwrite(f,QuantFactorG^,(Depth+2)*sizeof(Double));
   blockwrite(f,QuantFactorB^,(Depth+2)*sizeof(Double));
   blockwrite(f,bitbuffer^,pbits2);
   if (pbits mod 8=0) then blockwrite(f,databuffer^,pbits div 8)
    else blockwrite(f,databuffer^,(pbits div 8)+1);

   //GREEN

   bitindex:=0;
   dataindex:=0;

   WaveletPackGS(WLG,bitbuffer,bitindex,databuffer,dataindex,XRes,YRes,Depth,QuantBitSU);//Pack the Wavelet into Byte-Tables

   //Pack the BitBuffer
   pbits:=bitindex div 4;

   for v:=0 to pbits-1 do //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v]:=bitbuffer^[v*4] or (bitbuffer^[v*4+1] shl 2) or (bitbuffer^[v*4+2] shl 4) or (bitbuffer^[v*4+3] shl 6);

   case (bitindex mod 4) of
    1: bitbuffer^[pbits]:=bitbuffer^[pbits*4];
    2: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2);
    3: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2) or (bitbuffer^[pbits*4+2] shl 4);
   End;
   //End Pack

   if (bitindex mod 4=0) then pbits2:=pbits
    else pbits2:=pbits+1;

   //Pack the DataBuffer
   pbits:=0;
   for v:=0 to dataindex-1 do Begin //Pack single Bytes into a BitStream (depending on QuantizerBits)
    if (pbits mod 8=0) then Begin
     data:=databuffer^[v];
    End else Begin
     data:=Cardinal(databuffer^[v]) shl (pbits mod 8);
     if ((pbits+QuantBitSU) div 8>pbits div 8) then Begin
      data2:=data shr 8;
      data:=data and $FF;
      databuffer^[(pbits div 8)+1]:=data2;
     End;
     data:=data or (Cardinal(databuffer^[pbits div 8]) and ((1 shl (pbits mod 8))-1));
    End;
    databuffer^[pbits div 8]:=data;
    inc(pbits,QuantBitSU);
   End;
   //End Pack

   Head.BitSG:=bitindex;//Output BitTable (Green) and DataTable (Green)
   Head.DataG:=dataindex;
   blockwrite(f,bitbuffer^,pbits2);
   if (pbits mod 8=0) then blockwrite(f,databuffer^,pbits div 8)
    else blockwrite(f,databuffer^,(pbits div 8)+1);

   //BLUE

   bitindex:=0;
   dataindex:=0;

   WaveletPackGS(WLB,bitbuffer,bitindex,databuffer,dataindex,XRes,YRes,Depth,QuantBitSV);//Pack the Wavelet into Byte-Tables

   //Pack the BitBuffer
   pbits:=bitindex div 4;

   for v:=0 to pbits-1 do //4 2Bit-Pakets match one Byte =)
    bitbuffer^[v]:=bitbuffer^[v*4] or (bitbuffer^[v*4+1] shl 2) or (bitbuffer^[v*4+2] shl 4) or (bitbuffer^[v*4+3] shl 6);

   case (bitindex mod 4) of
    1: bitbuffer^[pbits]:=bitbuffer^[pbits*4];
    2: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2);
    3: bitbuffer^[pbits]:=bitbuffer^[pbits*4] or (bitbuffer^[pbits*4+1] shl 2) or (bitbuffer^[pbits*4+2] shl 4);
   End;
   //End Pack

   if (bitindex mod 4=0) then pbits2:=pbits
    else pbits2:=pbits+1;

   //Pack the DataBuffer
   pbits:=0;
   for v:=0 to dataindex-1 do Begin //Pack single Bytes into a BitStream (depending on QuantizerBits)
    if (pbits mod 8=0) then Begin
     data:=databuffer^[v];
    End else Begin
     data:=Cardinal(databuffer^[v]) shl (pbits mod 8);
     if ((pbits+QuantBitSV) div 8>pbits div 8) then Begin
      data2:=data shr 8;
      data:=data and $FF;
      databuffer^[(pbits div 8)+1]:=data2;
     End;
     data:=data or (Cardinal(databuffer^[pbits div 8]) and ((1 shl (pbits mod 8))-1));
    End;
    databuffer^[pbits div 8]:=data;
    inc(pbits,QuantBitSV);
   End;
   //End Pack

   Head.BitSB:=bitindex;//Output BitTable (Blue) and DataTable (Blue)
   Head.DataB:=dataindex;
   blockwrite(f,bitbuffer^,pbits2);
   if (pbits mod 8=0) then blockwrite(f,databuffer^,pbits div 8)
    else blockwrite(f,databuffer^,(pbits div 8)+1);

   seek(f,0);
   blockwrite(f,Head,sizeof(Head));//Output Head (again =)
  End;

  freemem(bitbuffer,XRes*YRes);
  freemem(databuffer,XRes*YRes);

  Closefile(f);

  {application.messagebox(@(inttostr(pbits)+#0)[1],'Bits',0);
  application.messagebox(@(inttostr(dataindex)+#0)[1],'data',0);//TEST PURPOSE}
End;
END.

{HISTORY: 02.02.2001: -added a little 'trick' to the DeWaveletGS-Routine..
                       it's based upon the idea of more complex wavelets, which
                       try to filter more "information" (-> pixeldata) into
                       single low/high-pass coefficients..
                       the 'trick' in my routine uses an idea i adopted from
                       alan watt's article about wavelets in his "3d games vol.1"-book..
                       he uses linear interpolation of the transformed coefficients
                       (-> results in an effect like gouraud shading =)
                       together with a (progressive) quadtree representation of the coefficient data..
                       DeWaveletGS simulates (read: "fakes" ;) this effect by interpolating
                       between the low-pass coefficients (if the related high-pass coefficient=0.0 (-> kicked data))..

                       Result: Amazing Quality Improvement! (-> CHECK IT OUT! 8-)
                       Best Thing: All previously stored .hwl-files remain valid.. 

                       (Search for //!UPDATED in the source)

          04.02.2001: -little bugfix for high contrasts (-> resulted in 'false' interpolation producing ugly artefacts!)

          05.05.2001: -added YUV-color-model..
                       the picture is converted into YUV before the wavelet transformation..
                       YUV allows to store more Bits for the luminancy
                       of the picture (Y) and needs less Bits for the color
                       information (U/V).. "without" quality loss.. (the human
                       eye can't recognize the pixel artefacts as easy as before ;)

                       it's converted back into RGB during loading..
                       so the header has been changed (two more bytes added!)
                       and the old (<v.0.6) .hwl-files can't be used anymore.. :(

                       Result: More Quality at Higher Compression Rates!
                       Bad Thing: due to "lame coding" =) the source-code
                                  isn't as readable as before.. :(

          06.05.2001: -improved RLE compression by using two additional Bits for Zero-Packing..
}