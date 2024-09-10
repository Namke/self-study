UNIT Play2;

INTERFACE
{ $Define Old}
USES Windows,Messages,SysUtils,Classes,Graphics,Controls,Forms,Dialogs,StdCtrls,ExtCtrls,
     DirectDraw,DirectShow,VFW,MMSystem,
     {$IfDef Old}Avenus;{$Else}AvenusBase,AvenusMedia;{$EndIf}

TYPE
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
  TForm1 = Class(TForm)
    Procedure FormClose(Sender : TObject;Var Action : TCloseAction);
    Procedure FormCreate(Sender : TObject);
    Private
    Public
    Count : LongInt;
    Name : String;
    Screen : TAvenus;
    {$IfDef Old}
    Video  : TVideo64;
    {$Else}
    //Video  : TAvenusVideoExpansion;
    Video  : TVideoAvi;
    {$EndIf}
    Procedure FormIdle(Sender : TObject;Var Done : Boolean);
  End;

VAR
  Form1 : TForm1;

IMPLEMENTATION

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
    //If VideosOpen=0 then AVIFileInit;
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
    //Inc(VideosOpen);
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
{$R *.DFM}
PROCEDURE TForm1.FormCreate(Sender : TObject);
  Begin
    //Screen:=TFullAvenus.Create(Handle,800,600,16);
    Screen:=TAvenus.Create(Handle,400,300);
    //Video:=TAvenusVideoExpansion.Create(Screen,'PTT2012.Avi',False,False);
    //Video:=TAvenusVideo.Create(Screen,'PTT2012.Avi',False);
    //Video:=TVideo64.Create(Screen,'PTT2012.Avi',False);
    {$IfDef Old}
    //Video:=TVideoEx64.Create(Screen,'D:\Video\Video.VietNam\Chia xa - Lam Chi Khanh.dat',True,True);
    Video:=TVideo64.Create(Screen,'globe.avi',True);
    {$Else}
    //Video:=AvenusMedia.TAvenusVideoExpansion.Create(Screen,'D:\Video\Video.VietNam\Chia xa - Lam Chi Khanh.dat',True,True);
    //Video:=AvenusMedia.TAvenusVideoExpansion.Create(Screen,'D:\TEMP\SNAG-0001.avi',True,True);
    Video:=TVideoAvi.Create(Screen,'D:\TEMP\SNAG-0001.avi',True);
    //Video:=TAvenusVideo.Create(Screen,'globe.avi',True);
    //Video:=TAvenusVideoExpansion.Create(Screen,'PTT2012.avi',True,True);
    {$EndIf}
    Video.Play;
    Count:=0;
    Application.OnIdle:=FormIdle;
  End;

PROCEDURE TForm1.FormClose(Sender : TObject;Var Action : TCloseAction);
  Begin
    Application.OnIdle:=Nil;
    Video.Free;
    Screen.Free;
  End;

PROCEDURE TForm1.FormIdle(Sender : TObject;Var Done : Boolean);
  Begin
    Video.UpDateFrame;
    //Video.Frame.Negative;
    //Video.Frame.Grayscale;
    //Video.Frame.Blur2x_Speed;
    Inc(Count);
    Str(Count,Name);
    While Length(Name)<5 do Name:='0'+Name;
    Video.Frame.SaveImage('Frame\'+Name+'.png');
    Video.Frame.Draw(0,0);
    //Video.Frame.Flip(False);
    Done:=False;
  End;
END.


