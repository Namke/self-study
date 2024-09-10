USES Windows,Classes,VFW,MMSystem,SysUtils,DirectShow,DirectDraw,AvenusBase,AvenusMedia,PNGZLib;
{$AppType GUI}
CONST
  ScrW = 640;
  ScrH = 480;

TYPE
  Array10 = Array[0..0] of Word;
  TVideoAvi = Class
    //frame holds the latest frame
    Frame : TAvenusBuffer;
    //This func will update frame as
    //needed,the frames will be always
    //syncronized with the FPS in the File.
    Procedure UpdateFrame;
    //controls
    Procedure Play;
    Procedure Pause;
    Procedure Stop;
    //setup
    Constructor Create(Hyper : TAvenus;FileName : String;Loop : Boolean);
    Destructor Destroy;OverRide;
    Public
    Handle   : HWnd;
    pAviFile : PAVIFILE;
    fInfo    : TAVIFILEINFO;
    pVInfo   : TAVISTREAMINFO;
    pAInfo   : TAVISTREAMINFO;
    pVideo   : PAVISTREAM;
    pAudio   : PAVISTREAM;
    pChunk   : pbyte;
    lSize    : Integer;
    pBInfo   : PBITMAPINFO;
    pgf      : PGETFRAME;
    //Time Related vars
    lEndTime,
    lOldTime,
    lNewTime,
    lElapsedTime,
    lFrameTime,
    lFrame  : Integer;
    //MISC
    Running : Boolean;
    Paused  : Boolean;
    Audio   : Boolean;
    DoLoop  : Boolean;
    Procedure Err_Msg(Source,ErrMsg : String);
    Procedure GetFrame(pBMPInfo : PBITMAPINFO);
  End;

PROCEDURE TVideoAvi.Err_Msg(Source,ErrMsg : String);
  Begin 
    If Assigned(Self) then Destroy;
    //If VideosOpen=0 then AVIFileExit();
    MessageBox(Handle,PChar('[TVideoAvi]'+ Source+ ' ->'+ ErrMsg),'Runtime Error',MB_OK);
    Halt;
  End;

PROCEDURE TVideoAvi.Play;
  Begin
    lOldTime:=TimeGetTime();
    lFrameTime:=0;
    Running:=True;
    Paused:=False;
  End;

PROCEDURE TVideoAvi.Pause;
  Begin
    If Not Running then Exit;
    Paused:=Not Paused;
  End;

PROCEDURE TVideoAvi.Stop;
  Begin
    Paused:=True;
    Running:=False;
  End;

PROCEDURE TVideoAvi.GetFrame(pBMPInfo : PBitmapInfo);
  Var DC,hBMPDC : HDC;    
      PBmpBits  : Pointer;
      PGDIBits  : Pointer;
      HBmp      : HBitmap;
      POldObj   : HGDIOBJ;
      HRet      : HResult;
  Begin
    HRet:=Frame.DDSurface.GetDC(DC);
    If (HRet<>DD_OK) then Err_Msg('GetDC',DDErrorString(HRet));
    PBmpBits:=Pointer(Integer(pBMPInfo)+Integer(pBMPInfo.bmiHeader.biSize));
    HBmp:=CreateDIBSection(DC,TBITMAPINFO(pBMPInfo^),DIB_RGB_COLORS,PGDIBits,0,0);
    If (HBmp=0) then Err_Msg('CreateDIBSection','Error creating bitmap...');
    Move(PBmpBits^,PGDIBits^,pBMPInfo^.bmiHeader.biSizeImage);
    hBMPDC:=CreateCompatibleDC(DC);
    If (HBmp=0) then Err_Msg('CreateCompatibleDC','Error creating A compatible device context...');
    POldObj:=SelectObject(hBMPDC,HBmp);
    BitBlt(DC,0,0,pBMPInfo.bmiHeader.biWidth,pBMPInfo.bmiHeader.biHeight,hBMPDC,0,0,SRCCOPY);
    If (POldObj>0) then SelectObject(hBMPDC,POldObj);
    DeleteObject(HBmp);
    DeleteDC(hBMPDC);
    Frame.DDSurface.ReleaseDC(DC);
  End;
//Updates the current Frame
PROCEDURE TVideoAvi.UpdateFrame;
  Var LpBi : PBitmapInfoHeader;
  Begin
    If Not Running then Exit;
    If Paused then Begin lOldTime:=TimeGetTime();Exit;End;
    lNewTime:=TimeGetTime();
    lElapsedTime:=lNewTime-lOldTime;
    Inc(lFrameTime,lElapsedTime);
    {If (lFrameTime<=lEndTime) then
      Begin
        lFrame:=AVIStreamTimeToSample(pVideo,lFrameTime)
      End
    Else
      Begin
        If DoLoop then Begin lFrameTime:=0;Exit;End
        Else Begin Running:=False;Exit;End;
      End;}
    Inc(LFrame);
    If LFrame>=FInfo.DWLength then Begin Running:=False;LFrame:=1;End;
    LpBi:=PBitmapInfoHeader(AVIStreamGetFrame(pgf,lFrame));
    If (LpBi=Nil) then Exit;
    GetFrame(PBitmapInfo(LpBi));
    lOldTime:=lNewTime;
  End;

CONSTRUCTOR TVideoAvi.Create(Hyper : TAvenus;FileName : String;Loop : Boolean);
  Begin
    Inherited Create;
    If Not FileExists(FileName) then Err_Msg('Create','File not found...');
    Handle:=Hyper.Handle;
    If VideosOpen=0 then AVIFileInit;
    If Failed(AVIFileOpen(PAviFile,PChar(FileName),OF_READ,Nil)) then
      Err_Msg('AVIFileOpen','Error loading '+FileName+'...');
    If Failed(AVIFileInfo(PAviFile,@fInfo,SizeOf(fInfo))) then
      Err_Msg('AVIFileInfo','Error extracting info...');
    If Failed(AVIFileGetStream(PAviFile,pVideo,STREAMTYPEVIDEO,0)) then
      Err_Msg('AVIFileGetStream','Error extracting stream...');
    If Failed(AVIFileGetStream(PAviFile,pAudio,STREAMTYPEAUDIO,0)) then Audio:=False
    Else Audio:=True;
    If Failed(AVIStreamInfo(pVideo,@pVInfo,SizeOf(pVInfo))) then
      Err_Msg('AVIStreamInfo','Error extracting video stream info...');
    If Audio then
      Begin
        If Failed(AVIStreamInfo(pAudio,@pAInfo,SizeOf(pAInfo))) then
          Err_Msg('AVIStreamInfo','Error extracting audio stream info...');
      End;
    If Failed(AVIStreamReadFormat(pVideo,AVIStreamStart(pVideo),Nil,@lSize)) then
      Err_Msg('AVIStreamReadFormat','Error reading video stream format...');
    GetMem(pChunk,lSize);
    If (pChunk=Nil) then
      Err_Msg('AVIStreamReadFormat','Error setting up chunk...');
    If Failed(AVIStreamReadFormat(pVideo,AVIStreamStart(pVideo),pChunk,@lSize)) then
      Err_Msg('AVIStreamReadFormat','Error reading video stream format...');
    pBInfo:=PBitmapInfo(pChunk);
    If (pBInfo=Nil) then
      Err_Msg('pBInfo','Error extracting bitmap format...');
    Frame:=TAvenusBuffer.Create(Hyper,pBInfo.bmiHeader.biWidth,pBInfo.bmiHeader.biHeight,True);
    PGF:=AVIStreamGetFrameOpen(pVideo,Nil);
    If (PGF=Nil) then
      Err_Msg('AVIStreamGetFrameOpen','Error preparing decompression...');
    lEndTime:=AVIStreamEndTime(pVideo);
    lNewTime:=0;
    lOldTime:=TimeGetTime();
    Running:=False;
    Paused:=False;
    DoLoop:=loop;
    lFrameTime:=0;
    lFrame:=0;
    Inc(VideosOpen);
  End;

DESTRUCTOR TVideoAvi.Destroy;
  Begin
    FreeMem(pChunk,lSize);
    If Failed(AVIStreamGetFrameClose(PGF)) then
      Err_Msg('AVIStreamGetFrameClose','Error releasing decompression Handle...');
    If Audio then AVIStreamRelease(pAudio);
    AVIStreamRelease(pVideo);
    AVIFileRelease(PAviFile);
    Frame.Free;
    //Dec(VideosOpen);
    //If (VideosOpen=0) then AVIFileExit();
    Inherited Destroy;
  End;

VAR
  Screen                      : TAvenus;
  Input                       : TAvenusInput;
  Buffer                      : TAvenusBuffer;
  Img                         : TAvenusImage;
  Video                       : TVideoAvi;
  FinishGame                  : Boolean;
  Name                        : String;
  F                           : TStream;
  BlockIn,BackUp              : ^Array10;
  BlockOut                    : Pointer;
  SizeIn,SizeOut,Size,OutTime : Integer;

PROCEDURE Saved;
  Var Z : Integer;
  Begin
    F:=TFileStream.Create('Test.Save',FMCreate);
    GetMem(BlockIn,1024*1024);
    Repeat
      Video.UpdateFrame;
      SizeIn:=Video.Frame.XSize*Video.Frame.YSize*2;
      Move(Video.Frame.Ptr^,BlockIn^,SizeIn);
      For Z:=0 to (SizeIn div 2)-1 do
        If BackUp^[Z]=BlockIn^[Z] then BlockIn^[Z]:=0;
      Move(Video.Frame.Ptr^,BackUp^,SizeIn);
      Move(BlockIn^,Video.Frame.Ptr^,SizeIn);
      ZCompress(BlockIn,SizeIn,BlockOut,SizeOut,ZCMax);
      F.Write(Video.Frame.XSize,SizeOf(Video.Frame.XSize));
      F.Write(Video.Frame.YSize,SizeOf(Video.Frame.YSize));
      F.Write(SizeOut,SizeOf(SizeOut));
      F.Write(BlockOut^,SizeOut);
      FreeMem(BlockOut);
      Video.Frame.DrawSprite(0,0,0);
      If Video.Running=False then Begin Video.Play;FinishGame:=True;End;
      If Screen.DoEvents=False then FinishGame:=True;
      If Input.KeyDown(K_Escape) then FinishGame:=True;
    Until FinishGame;
    FreeMem(BlockIn);
    F.Free;
  End;

PROCEDURE Played;
  Var Image       : TAvenusImage;
      XSize,YSize : Integer;
  Begin
    F:=TFileStream.Create('Test.Save',FMOpenRead);
    GetMem(BlockIn,1024*1024);
    F.Read(XSize,SizeOf(XSize));
    F.Read(YSize,SizeOf(YSize));
    Image:=TAvenusImage.Create(Screen,XSize,YSize,False);
    F.Position:=0;
    Repeat
      F.Read(XSize,SizeOf(XSize));
      F.Read(YSize,SizeOf(YSize));
      F.Read(SizeIn,SizeOf(SizeIn));
      F.Read(BlockIn^,SizeIn);
      If F.Position=F.Size then F.Position:=0;
      ZDecompress(BlockIn,SizeIn,BlockOut,SizeOut,OutTime);
      Move(BlockOut^,Image.Ptr^,SizeOut);
      Image.CopySprite(Buffer,0,0,0);
      FreeMem(BlockOut);
      Buffer.Flip(False);
      If Screen.DoEvents=False then FinishGame:=True;
      If Input.KeyDown(K_Escape) then FinishGame:=True;
    Until FinishGame;
    FreeMem(BlockIn);
    Image.Free;
    F.Free
  End;

PROCEDURE Save3;
  Var Count : Integer;
      Name  : String;
  Begin
    Count:=0;
    Repeat
      Video.UpdateFrame;
      //Video.Frame.Negative;
      //Video.Frame.Grayscale;
      Inc(Count);Str(Count,Name);
      While Length(Name)<10 do Name:='0'+Name;
      Name:='Frame\'+Name+'.png';
      //Video.Frame.SaveQuality(70);
      Video.Frame.SaveImage(Name);
      //Img.CopyAlpha(Video.Frame,10,10,128);
      //Img.ClipCopyAlpha50(Video.Frame,10,10);
      Video.Frame.Draw(0,0);
      If Video.Running=False then
        Begin
          Video.Play;
          FinishGame:=True;
        End;
      If Screen.DoEvents=False then FinishGame:=True;
      If Input.KeyDown(K_Escape) then FinishGame:=True;
    Until FinishGame;
  End;

PROCEDURE Save2;
  Var Count,I,J : Integer;
      Name      : String;
      Image,Img : TAvenusImage;
  Begin
    Count:=0;
    Img:=TAvenusImage.Create(Screen,ScrW,ScrH,False);
    Image:=TAvenusImage.Create(Screen,ScrW,ScrH,False);
    Img.Fill(0);
    Repeat
      Video.UpdateFrame;
      {Video.Frame.Copy(Image,0,0);
      For I:=0 to Video.Frame.XSize do
        For J:=0 to Video.Frame.YSize do
          If Video.Frame.GetPixel(I,J)=Img.GetPixel(I,J) then Video.Frame.PutPixel(I,J,0);
      Image.Copy(Img,0,0);}
      //Video.Frame.Negative;
      //Video.Frame.Grayscale;
      Inc(Count);Str(Count,Name);Name:='Frame\'+Name+'.jpg';
      Video.Frame.SaveQuality(50);
      Video.Frame.SaveImage(Name);
      //Img.CopyAlpha(Video.Frame,10,10,128);
      //Img.ClipCopyLens(Video.Frame,10,10);
      Video.Frame.Draw(0,0);
      If Video.Running=False then
        Begin
          Video.Play;
          FinishGame:=True;
        End;
      If Screen.DoEvents=False then FinishGame:=True;
      If Input.KeyDown(K_Escape) then FinishGame:=True;
    Until FinishGame;
  End;

PROCEDURE Play2;
  Var Count : Integer;
      Name  : String;
      Image : TAvenusImage;
  Begin
    Count:=0;
    Image:=TAvenusImage.Create(Screen,1,1,False);
    Repeat
      //If Count<701 then Inc(Count) Else Count:=1;
      //Str(Count,Name);Name:='Frame\'+Name+'.jpg';
      If Count<300 then Inc(Count) Else Count:=1;
      Str(Count,Name);Name:='Frame\'+Name+'.jpg';
      Image:=TAvenusImage.Create(Screen,Name,False);
      //Image.LoadImage(Name,False);
      Image.DrawSprite(0,0,0);
      Image.Free;
      If Screen.DoEvents=False then FinishGame:=True;
      If Input.KeyDown(K_Escape) then FinishGame:=True;
    Until FinishGame;
  End;

BEGIN
  //Screen:=TSelfFullAvenus.Create(ScrW,ScrH,16,'Crazy babe');
  Screen:=TSelfAvenus.Create(ScrW,ScrH,'Crazy babe');
  Buffer:=TAvenusBuffer.Create(Screen,ScrW,ScrH,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  Video:=TVideoAvi.Create(Screen,'D:\TEMP\SNAG-0001.avi',False);
  //Video:=TVideoAvi.Create(Screen,'1.avi',False);
  //Video:=TVideoAvi.Create(Screen,'G:\2\Yeu bang ca trai tim.1.avi',False);
  //Img:=TImage64.Create(Screen,'1.bmp',False);
  Img:=TAvenusImage.Create(Screen,100,280,False);
  Img.Fill(0);
  Video.Play;
  FinishGame:=False;
  GetMem(BackUp,1024*1024*2);
  FillChar(BackUp^,1024*1024*2,0);
  //Saved;
  //Played;
  Save3;
  //Play2;
  Input.Free;
  Buffer.Free;
  Screen.Free;
END.

