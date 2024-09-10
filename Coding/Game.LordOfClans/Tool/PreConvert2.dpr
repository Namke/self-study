USES Graphics,PNGImage;

VAR
  Image     : TPNGImage;
  I,J,Color : Integer;
  A         : Array[0..10000] of Byte;
  S         : String;

BEGIN
  S:=ParamStr(1);
  Image:=TPNGImage.Create;
  Image.LoadFromFile(S);
  Image.SaveToFile('_'+S+'_');
  For J:=0 to Image.Height-1 do
    Begin
      Move(Image.ScanLine[J]^,A,Image.Width);
      For I:=0 to Image.Width-1 do
        Begin
          Color:=A[I];
          If (Color>=208) and (Color<=211) then A[I]:=A[I]+4;
        End;
      Move(A,Image.ScanLine[J]^,Image.Width);
    End;
  Image.SaveToFile(S);
END.
