USES Windows,SysUtils,Types;

CONST
  Size = 20;

VAR
  X,Y,Z   : Integer;
  F : Text;

PROCEDURE Line(X1,Y1,X2,Y2 : Integer;Color : Cardinal;Effect : Integer);
  Var I,DeltaX,DeltaY,NumPixels,D,DInc1,DInc2,Z,//Count,
      X,XInc1,XInc2,Y,YInc1,YInc2,MaxPix : Integer;
      Pix                                : Array of TPoint;
  Begin
    Write(F,'(');
    SetLength(Pix,256);
    //Count:=0;
    MaxPix:=0;
    DeltaX:=Abs(X2-X1);
    DeltaY:=Abs(Y2-Y1);
    If DeltaX>=DeltaY then
      Begin
        NumPixels:=DeltaX+1;
        D:=(DeltaY ShL 1)-DeltaX;
        DInc1:=DeltaY ShL 1;
        DInc2:=(DeltaY-DeltaX) ShL 1;
        XInc1:=1;XInc2:=1;
        YInc1:=0;YInc2:=1;
      End
    Else
      Begin
        NumPixels:=DeltaY+1;
        D:=(DeltaX ShL 1)-DeltaY;
        DInc1:=DeltaX ShL 1;
        DInc2:=(DeltaX-DeltaY) ShL 1;
        XInc1:=0;XInc2:=1;
        YInc1:=1;YInc2:=1;
      End;
    If X1>X2 then
      Begin
        XInc1:=-XInc1;
        XInc2:=-XInc2;
      End;
    If Y1>Y2 then
      Begin
        YInc1:=-YInc1;
        YInc2:=-YInc2;
      End;
    X:=X1;Y:=Y1;
    For I:=1 to NumPixels do
      Begin
        Pix[MaxPix]:=Point(X,Y);
        Inc(MaxPix);
        If MaxPix>255 then
          Begin
            MaxPix:=0;
            For Z:=0 to MaxPix-1 do
              Begin
                //Inc(Count);
                Write(F,Format('(%3d,%3d),',[Pix[Z].X,Pix[Z].Y]));
                //If Count mod 10=0 then WriteLn(F);
              End;
          End;
        If D<0 then
          Begin
            D:=D+DInc1;
            X:=X+XInc1;
            Y:=Y+YInc1;
          End
        Else
          Begin
            D:=D+DInc2;
            X:=X+XInc2;
            Y:=Y+YInc2;
          End;
      End;
    If MaxPix>0 then
      Begin
        SetLength(Pix,MaxPix);
        For Z:=0 to MaxPix-1 do
          Begin
            //Inc(Count);
            Write(F,Format('(%3d,%3d),',[Pix[Z].X,Pix[Z].Y]));
            //If Count mod 10=0 then WriteLn(F);
          End;
      End;
    WriteLn(F,'),');
  End;

BEGIN
  Assign(F,'Point.Txt');
  Rewrite(F);
  X:=0;
  Y:=0;
  WriteLn(F,'//89');
  For Z:=0 to Size do
    Line(X,Y,X+Z,Y-Size,$FFFFFF,0);
  WriteLn(F,'//96');
  For Z:=0 to Size do
    Line(X,Y,X+Size,Y-Z,$FFFFFF,0);
  WriteLn(F,'//63');
  For Z:=0 to Size do
    Line(X,Y,X+Size,Y+Z,$FFFFFF,0);
  WriteLn(F,'//32');
  For Z:=0 to Size do
    Line(X,Y,X+Z,Y+Size,$FFFFFF,0);
  WriteLn(F,'//21');
  For Z:=0 to Size do
    Line(X,Y,X-Z,Y+Size,$FFFFFF,0);
  WriteLn(F,'//14');
  For Z:=0 to Size do
    Line(X,Y,X-Size,Y+Z,$FFFFFF,0);
  WriteLn(F,'//47');
  For Z:=0 to Size do
    Line(X,Y,X-Size,Y-Z,$FFFFFF,0);
  WriteLn(F,'//78');
  For Z:=0 to Size do
    Line(X,Y,X-Z,Y-Size,$FFFFFF,0);
  Close(F);
END.
