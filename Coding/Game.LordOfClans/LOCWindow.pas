UNIT LOCWindow;

INTERFACE

USES Windows,
     AvenusBase,
     Avenus3D,
     LOCBased,
     LOCScreen;

TYPE
  PBoolean = ^Boolean;
  PWindow = ^TWindow;
  PAppWindow = ^TAppWindow;
  TAppWindow = Record
    SizeX,SizeY,CaptionBarHeight : Integer;
  End;
  //Structure for the mouse
  PMouse = ^TMouse;
  TMouse = Record
    PosX,PosY : Integer;
    Button    : Integer;// 1=left, 2=right, 3=middle
  End;
  TMouseDrag = Record
    Drag      : Boolean;// window draggin enabled
    PosX,PosY : Integer;// PosX and PosY coords when drag started
  End;
  PButton = ^TButton;
  TButton = Object
    PosX,PosY   : Integer;
    SizeX,SizeY : Integer;
    Caption     : String;
    Pressed     : Boolean;
    Index       : Integer;
    OnClick     : Procedure;
    Return      : TMenuSelectResult;
    HotKey      : Byte;
  End;
  TText = Object
    PosX,PosY : Integer;
    Visible   : Boolean;
    Caption   : String;
  End;
  TPanel = Object
    PosX,PosY   : Integer;
    SizeX,SizeY : Integer;
    Visible     : Boolean;
  End;
  TCheckbox = Object
    PosX,PosY : Integer;
    Visible   : Boolean;
    Checked   : Boolean;
    OnClick   : Procedure;
  End;
  TRadioButton = Object
    PosX,PosY : Integer;
    Visible   : Boolean;
    Checked   : Boolean;
    Group     : Integer;
    OnClick   : Procedure;
  End;
  TWindow = Class
    PosX,PosY     : Integer;
    SizeX,SizeY   : Integer;
    Visible       : Boolean;
    Alpha         : Byte;
    BackGround    : TAvenusImage;
    Button        : Array of TButton;
    Text          : Array of TText;
    Panel         : Array of TPanel;
    Checkbox      : Array of TCheckBox;
    RadioButton   : Array of TRadioButton;
    ChildWindow   : Array of PWindow;
    Mouse         : TMouse;
    ButtonPressed : PButton;
    MouseDrag     : TMouseDrag;
    ButtonReturn  : TMenuSelectResult;
    MyScreen      : TLOCScreen;
    Caption       : String;
    Change        : Boolean;
    Constructor Create(Screen : TLOCScreen;WX,WY,WWidth,WHeight : Integer;CCaption : String);
    Procedure InitButton(Var Button : TButton;BX,BY,BWidth,BHeight : Integer;BCaption : String;BReturn : TMenuSelectResult);
    Procedure InitText(Var Text : TText;TX,TY : Integer;Caption : String);
    Procedure InitPanel(Var Panel : TPanel;PX,PY,PWidth,PHeight: Integer);
    Procedure InitCheckbox(Var CheckBox : TCheckBox;CBX,CBY : Integer;CBChecked : Boolean);
    Procedure InitRadioButton(Var RadioButton : TRadioButton;RBX,RBY,RBGroup : Integer;RBChecked : Boolean);
    Procedure AddButton(BTNX,BTNY,BTNWidth,BTNHeight : Integer;BTNCaption : String;BReturn : TMenuSelectResult);
    Procedure AddText(TX,TY : Integer;TCaption : String);
    Procedure AddPanel(PX,PY,PWidth,PHeight : Integer);
    Procedure AddCheckbox(CBX,CBY : Integer;Checked : Boolean);
    Procedure AddRadioButton(RBX,RBY,RBGroup : Integer;Checked : Boolean);
    Procedure AddWindow(Child : PWindow);
    Procedure Render;
    Procedure RenderButton(Button : TButton);
    Procedure RenderPanel(Panel : TPanel);
    Procedure RenderCheckBox(CheckBox : TCheckBox);
    Procedure RenderRadioButton(RadioButton : TRadioButton);
    Procedure RenderText(Text : TText);
    Function  OnLeftMouseUp : Boolean;
    Function  OnLeftMouseDown : Boolean;
    Function  OnLeftMouseDrag : Boolean;
  End;

IMPLEMENTATION

CONSTRUCTOR TWindow.Create(Screen : TLOCScreen;WX,WY,WWidth,WHeight : Integer;CCaption : String);
  Begin
    MyScreen:=Screen;
    PosX:=WX;PosY:=WY;
    SizeX:=WWidth;
    SizeY:=WHeight;
    Visible:=True;
    Caption:=CCaption;
    Change:=True;
    Alpha:=128;
  End;

PROCEDURE TWindow.AddButton(BTNX,BTNY,BTNWidth,BTNHeight : Integer;BTNCaption : String;BReturn : TMenuSelectResult);
  Begin
    SetLength(Button,High(Button)+2);
    InitButton(Button[High(Button)],BTNX,BTNY,BTNWidth,BTNHeight,BTNCaption,BReturn);
    Button[High(Button)].Index:=High(Button);
  End;

PROCEDURE TWindow.AddText(TX,TY : Integer;TCaption : String);
  Begin
    SetLength(Text,High(Text)+2);
    InitText(Text[High(Text)],TX,TY,TCaption);
  End;

PROCEDURE TWindow.AddPanel(PX,PY,PWidth,PHeight : Integer);
  Begin
    SetLength(Panel,High(Panel)+2);
    InitPanel(Panel[High(Panel)],PX,PY,PWidth,PHeight);
  End;

PROCEDURE TWindow.AddCheckbox(CBX,CBY : Integer;Checked : Boolean);
  Begin
    SetLength(Checkbox,High(Checkbox)+2);
    InitCheckBox(Checkbox[High(Checkbox)],CBX,CBY,Checked);
  End;

PROCEDURE TWindow.AddRadioButton(RBX,RBY,RBGroup : Integer;Checked : Boolean);
  Begin
    SetLength(RadioButton,High(RadioButton)+2);
    InitRadioButton(RadioButton[High(RadioButton)],RBX,RBY,RBGroup,Checked);
  End;

PROCEDURE TWindow.AddWindow(Child : PWindow);
  Begin
    SetLength(ChildWindow,High(ChildWindow)+2);
    ChildWindow[High(ChildWindow)]:=Child;
  End;

PROCEDURE TWindow.Render;
  Var I : Integer;
  Begin
    With MyScreen do
      If Visible then
        Begin
          {$IfDef FullClip}
          Screen.SetClipRect(PosX,PosY,PosX+SizeX,PosY+SizeY);
          {$EndIf}
          Screen.FillRect(PosX,PosY,SizeX,SizeY,$808080,EffectInvSrcColor);
          Screen.FrameRect(PosX,PosY,SizeX,SizeY,White,EffectNone);
          Screen.FrameRect(PosX,PosY,SizeX,CaptionSize,White,EffectNone);
          StrDraw(PosX+(SizeX-Length(Caption)*Font.Width) div 2,
                  PosY+(CaptionSize-Font.Height) div 2,White,Caption);
          For I:=0 to High(Panel)       do RenderPanel(Panel[I]);
          For I:=0 to High(Button)      do RenderButton(Button[I]);
          For I:=0 to High(Checkbox)    do RenderCheckBox(Checkbox[I]);
          For I:=0 to High(RadioButton) do RenderRadioButton(RadioButton[I]);
          For I:=0 to High(Text)        do RenderText(Text[I]);
          For I:=0 to High(ChildWindow) do ChildWindow[I].Render;
        End;
  End;

PROCEDURE TWindow.InitButton(Var Button : TButton;BX,BY,BWidth,BHeight : Integer;
                             BCaption : String;BReturn : TMenuSelectResult);
  Begin
    With Button do
      Begin
        PosX:=BX;PosY:=BY;
        SizeX:=BWidth;
        SizeY:=BHeight;
        Caption:=BCaption;
        Return:=BReturn;
      End;
  End;

PROCEDURE TWindow.RenderButton(Button : TButton);
  Var DX,DY : Integer;
  Begin
    With MyScreen,Button do
      Begin
        DX:=Self.PosX+PosX;
        DY:=Self.PosY+PosY;
        If Pressed then
          Begin
            Screen.FillRect(DX,DY,SizeX,SizeY,SeaBlue,EffectNone);
            Screen.FrameRect(DX,DY,SizeX,SizeY,White,EffectNone);
            StrDraw(DX+(SizeX-Length(Caption)*Font.Width) div 2,
                    DY+(SizeY-Font.Height) div 2,White,Caption);
          End
        Else
          Begin
            Screen.FrameRect(DX,DY,SizeX,SizeY,White,EffectNone);
            StrDraw(DX+(SizeX-Length(Caption)*Font.Width) div 2,
                    DY+(SizeY-Font.Height) div 2,White,Caption);
          End;
      End;
  End;

PROCEDURE TWindow.InitPanel(Var Panel : TPanel;PX,PY,PWidth,PHeight: Integer);
  Begin
    With Panel do
      Begin
        PosX:=PX;PosY:=PY;
        SizeX:=PWidth;
        SizeY:=PHeight;
        Visible:=True;
      End;
  End;

PROCEDURE TWindow.RenderPanel(Panel : TPanel);
  Begin
    With MyScreen,Panel do
      If Visible then
        Begin
          Screen.FillRect(PosX,PosY,SizeX,SizeY,Green,EffectNone);
        End;
  End;

PROCEDURE TWindow.InitCheckbox(Var CheckBox : TCheckBox;CBX,CBY : Integer;CBChecked : Boolean);
  Begin
    With CheckBox do
      Begin
        PosX:=CBX;PosY:=CBY;
        Visible:=True;
        Checked:=CBChecked;
      End;
  End;


PROCEDURE TWindow.RenderCheckBox(CheckBox : TCheckBox);
  Begin
    With MyScreen,CheckBox do
      If Visible then
        Begin
          If Checked then
            Begin
              //Screen.FillCircle(PosX,PosY,16,White);
            End
          Else
            Begin
              //Screen.Circle(PosX,PosY,16,White);
            End;
        End;
  End;

PROCEDURE TWindow.InitRadioButton(Var RadioButton : TRadioButton;RBX,RBY,RBGroup : Integer;RBChecked : Boolean);
  Begin
    With RadioButton do
      Begin
        PosX:=RBX;PosY:=RBY;
        Visible:=True;
        Checked:=RBChecked;
        Group:=RBGroup;
      End;
  End;

PROCEDURE TWindow.RenderRadioButton(RadioButton : TRadioButton);
  Begin
    With MyScreen,RadioButton do
      If Visible then
        Begin
          If Checked then
            Begin
              //Screen.FillCircle(PosX,PosY,16,Green);
            End
          Else
            Begin
              //Screen.Circle(PosX,PosY,16,Green);
            End;
        End;
  End;

PROCEDURE TWindow.InitText(Var Text : TText;TX,TY : Integer;Caption : String);
  Begin
    Text.PosX:=TX;
    Text.PosY:=TY;
    Text.Caption:=Caption;
  End;

PROCEDURE TWindow.RenderText(Text : TText);
  Begin
    With MyScreen do
      StrDraw(Self.PosX+Text.PosX,
              Self.PosY+Text.PosY,White,
              Text.Caption,
              StyleCenterText,
              StyleLeftText);
  End;

FUNCTION  TWindow.OnLeftMouseDown : boolean;
  Var WndClick      : Boolean;
      I,J           : Integer;
      MouseX,MouseY : Integer;
  Begin
    Result:=False;
    If Visible=False then Exit;
    WndClick:=False;
    //First check child windows since they can be on top.
    For I:=0 to High(ChildWindow) do
      If (ChildWindow[I].Visible) and (WndClick=False) then
        WndClick:=ChildWindow[I].OnLeftMouseDown;
    If WndClick then
      Begin
        Result:=True;
        Exit;
      End;
    //Test to see If user clicked in a window
    MouseX:=Mouse.PosX;MouseY:=Mouse.PosY;
    If (MouseX>PosX) and (MouseX<PosX+SizeX) then
      If (MouseY>PosY) and (MouseY<PosY+SizeY) then WndClick:=True;
    // If something inside the window was clicked,then find the object
    If WndClick then
      Begin
        Result:=True;
        //Test to see if user clicked on window close icon
        {If (MouseX>PosX+SizeX-22) and (MouseX<PosX+SizeX-6) then
          If (MouseY>PosY+8) and (MouseY<PosY+24) then
            Begin
              Visible:=False;
              Exit;
            End;{}
        //Test to see if user clicked in caption bar
        If (MouseX>PosX) and (MouseX<PosX+SizeX) then
          If (MouseY>PosY+1) and (MouseY<PosY+CaptionSize) then
            Begin
              MouseDrag.Drag:=True;
              MouseDrag.PosX:=PosX-Mouse.PosX;
              MouseDrag.PosY:=PosY-Mouse.PosY;
              Exit;
            End;
        //Recalculate coordinates relative to window
        MouseX:=MouseX-PosX;
        MouseY:=MouseY-PosY;
        //Test and execute button click
        For I:=0 to High(Button) do
          Begin
            If (MouseX>Button[I].PosX) and (MouseX<Button[I].PosX+Button[I].SizeX) then
              If (MouseY>Button[I].PosY) and (MouseY<Button[I].PosY+Button[I].SizeY) then
                Begin
                  Button[I].Pressed:=True;
                  ButtonPressed:=@Button[I];
                  Change:=True;
                  Exit;
                End;
          End;
        //Test and execute checkbox click
        For I:=0 to High(CheckBox) do
          Begin
            If (MouseX>CheckBox[I].PosX) and (MouseX<CheckBox[I].PosX+16) then
              If (MouseY>CheckBox[I].PosY) and (MouseY<CheckBox[I].PosY+16) then
                Begin
                  CheckBox[I].Checked:=Not (CheckBox[I].Checked);
                  If Assigned(CheckBox[I].OnClick) then CheckBox[I].OnClick;
                  Change:=True;
                  Exit;
                End;
          End;
        //Test and execute RadioButton click
        For I:=0 to High(RadioButton) do
          Begin
            If (MouseX>RadioButton[I].PosX) and (MouseX<RadioButton[I].PosX+16) then
              If (MouseY>RadioButton[I].PosY) and (MouseY<RadioButton[I].PosY+16) then
                Begin
                  //Uncheck all the other radio buttons in this group
                  For J:=0 to High(RadioButton) do
                    If RadioButton[J].Group=RadioButton[I].Group then RadioButton[J].Checked:=False;
                  RadioButton[I].Checked:=True;
                  If Assigned(RadioButton[I].OnClick) then RadioButton[I].OnClick;
                  Change:=True;
                  Exit;
                End;
          End;
      End;
    Result:=WndClick;
  End;

FUNCTION  TWindow.OnLeftMouseUp : Boolean;
  Var MouseX,MouseY : Integer;
  Begin
    Result:=False;
    MouseDrag.Drag:=False;
    Mouse.Button:=0;
    MouseX:=Mouse.PosX;
    MouseY:=Mouse.PosY;
    If ButtonPressed<>Nil then
      Begin
        MouseX:=MouseX-PosX;
        MouseY:=MouseY-PosY;
        If (MouseX>ButtonPressed^.PosX) and (MouseX<ButtonPressed^.PosX+ButtonPressed^.SizeX) then
          If (MouseY>ButtonPressed^.PosY) and (MouseY<ButtonPressed^.PosY+ButtonPressed^.SizeY) then
             Begin
               If Assigned(ButtonPressed^.OnClick) then ButtonPressed^.OnClick;
               ButtonReturn:=ButtonPressed^.Return;
               Result:=True;
             End;
        ButtonPressed.Pressed:=False;
        Change:=True;
      End
  End;

FUNCTION  TWindow.OnLeftMouseDrag : Boolean;
  Var NewPosX,NewPosY : Integer;
  Begin
    Result:=False;
    If Visible=False then Exit;
    If MouseDrag.Drag then
      Begin
        NewPosX:=MouseDrag.PosX+Mouse.PosX;
        NewPosY:=MouseDrag.PosY+Mouse.PosY;
        If (PosX<>NewPosX) or (PosY<>NewPosY) then
          Begin
            PosX:=NewPosX;
            PosY:=NewPosY;
            Change:=True;
          End;
        Result:=True;
        Exit;
      End;
  End;
END.
