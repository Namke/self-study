USES Windows,Classes,VFW,MMSystem,SysUtils,DirectShow,DirectDraw,
     AvenusBase,AvenusMedia,PNGZLib,WaveLetCompress;
{$AppType GUI}
CONST
  ScrW = 740;
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
    Frame:=TAvenusBuffer.Create(Hyper,pBInfo.bmiHeader.biWidth,pBInfo.bmiHeader.biHeight,False);
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
  Screen                : TAvenus;
  Input                 : TAvenusInput;
  Buffer                : TAvenusBuffer;
  Img                   : TAvenusImage;
  Video                 : TVideoAvi;
  FinishGame            : Boolean;
  F                     : TStream;
  BlockIn,BlockOut,Back : Pointer;
  SizeIn,SizeOut        : Integer;

PROCEDURE SavedRaw(SF,DF : String);
  Var SizeX,SizeY,Z : Integer;
  Begin
    Video:=TVideoAvi.Create(Screen,SF,False);
    Video.Play;
    F:=TFileStream.Create(DF,FMCreate);
    GetMem(BlockIn,10241024);
    GetMem(Back,10241024);
    FillChar(Back^,10241024,0);
    Repeat
      Video.UpdateFrame;
      SizeX:=Video.Frame.XSize;
      SizeY:=Video.Frame.YSize;
      SizeIn:=SizeX*SizeY*Video.Frame.BytePerPixel;
      Move(Video.Frame.Ptr^,BlockIn^,SizeIn);
      For Z:=0 to SizeIn-1 do
        If Array10(BlockIn^)[Z]=Array10(Back^)[Z] then Array10(BlockIn^)[Z]:=0;
      Move(Video.Frame.Ptr^,Back^,SizeIn);
      ZCompress(BlockIn,SizeIn,BlockOut,SizeOut,ZCMax);
      F.Write(SizeX,SizeOf(SizeX));
      F.Write(SizeY,SizeOf(SizeY));
      F.Write(SizeOut,SizeOf(SizeOut));
      F.Write(BlockOut^,SizeOut);
      FreeMem(BlockOut);
      Video.Frame.DrawSprite(0,0,0);
      If Video.Running=False then Begin Video.Play;FinishGame:=True;End;
      Video.UpdateFrame;
      If Screen.DoEvents=False then FinishGame:=True;
      If Input.KeyDown(K_Escape) then FinishGame:=True;
    Until FinishGame;
    FreeMem(BlockIn);
    FreeMem(Back);
    F.Free;
    Video.Free;
  End;

PROCEDURE PlayedRaw(FN : String);
  Var SizeX,SizeY : Integer;
  Begin
    F:=TFileStream.Create(FN,FMOpenRead);
    Img:=TAvenusImage.Create(Screen,100,100,False);
    GetMem(BlockIn,10241024);
    Repeat
      F.Read(SizeX,SizeOf(SizeX));
      F.Read(SizeY,SizeOf(SizeY));
      F.Read(SizeIn,SizeOf(SizeIn));
      F.Read(BlockIn^,SizeIn);
      If F.Position=F.Size then F.Position:=0;
      Img.Resize(SizeX,SizeY);
      ZDeCompress(BlockIn,SizeIn,BlockOut,SizeOut);
      Move(BlockOut^,Img.Ptr^,SizeOut);
      FreeMem(BlockOut);
      Img.DrawSprite(0,0,0);
      If Screen.DoEvents=False then FinishGame:=True;
      If Input.KeyDown(K_Escape) then FinishGame:=True;
    Until FinishGame;
    FreeMem(BlockIn);
    Img.Free;
    F.Free;
  End;

BEGIN
  //Screen:=TSelfFullAvenus.Create(ScrW,ScrH,16,'Crazy babe');
  Screen:=TSelfAvenus.Create(ScrW,ScrH,'Crazy babe');
  Buffer:=TAvenusBuffer.Create(Screen,ScrW,ScrH,False);
  Input:=TAvenusInput.Create(Screen.Handle);
  FinishGame:=False;
  //SavedRaw('D:\VIDEO\A\INTRO.Avi','Test.Raw');
  //SavedRaw('D:\TEMP\SNAG-0001.Avi','Test.Raw');
  PlayedRaw('Test.Raw');
  Input.Free;
  Buffer.Free;
  Screen.Free;
END.

