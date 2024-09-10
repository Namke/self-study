USES PNGZLib;

VAR
  Pt,PtOut     : Pointer;
  OutSize,Size : LongInt;
  F            : File;
  FN           : String;

BEGIN
  If ParamCount<1 then Exit;
  FN:=ParamStr(1);
  Assign(F,FN);
  Reset(F,1);
  Size:=FileSize(F);
  GetMem(Pt,Size);
  BlockRead(F,Pt^,Size);
  Close(F);
  ZCompress(Pt,Size,PtOut,OutSize);
  Assign(F,'Tmp.ZLib');
  Rewrite(F,1);
  BlockWrite(F,PtOut^,OutSize);
  Close(F);
END.
