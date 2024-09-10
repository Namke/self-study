{$AppType Console}
USES Classes,SysUtils,KPF;

VAR
  DataFile : TKPF;
  FileName : String;
  Key      : TRecordKey;
  Stream   : TStream;
  Z,K      : Integer;
  F,G      : Text;

BEGIN
  Assign(G,'DataBase.Result');
  Rewrite(G);
  //Extract
  If ParamStr(1)='E' then
    Begin
      DataFile:=TKPF.Create;
      DataFile.OpenMode:=OpenReadOnly;
      DataFile.FileName:='DataBase.$$$';
      If DataFile.Initialize<>0 then
        Begin
          DataFile.Free;
          Exit;
        End;
      For Z:=0 to DataFile.RecordCount-1 do
        Begin
          Key:=DataFile.RecordKey[Z];
          FileName:=Key;
          For K:=1 to Length(FileName) do
            If FileName[K]='\' then FileName[K]:='.';
          Stream:=TFileStream.Create(FileName,FMCreate);
          DataFile.ReadRecord(Key,Stream);
          Stream.Free;
        End;
      DataFile.Free;
    End
  Else
    Begin
      DataFile:=TKPF.Create;
      DataFile.OpenMode:=OpenOverwrite;
      DataFile.FileName:='DataBase.$$$';
      If DataFile.Initialize<>0 then
        Begin
          DataFile.Free;
          Exit;
        End;
      Assign(F,'DataBase.Txt');
      Reset(F);
      While Not EoF(F) do
        Begin
          ReadLn(F,FileName);
          If (FileName='') or
             (FileName[1]='#') then Continue;
          Stream:=TFileStream.Create(FileName,FMOpenRead);
          If Stream<>Nil then
            Begin
              Key:=FileName;
              DataFile.WriteRecord(Key,Stream);
              Stream.Free;
              WriteLn(G,'Added file ',FileName);
              Flush(G);
            End
          Else
            Begin
              WriteLn(G,'Error on add file ',FileName);
              Flush(G);
            End;
        End;
      Close(F);
      DataFile.Free;
    End;
  Close(G);
END.
