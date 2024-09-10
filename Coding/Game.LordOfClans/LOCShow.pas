UNIT LOCShow;

INTERFACE

USES LOCBased,
     LOCScreen,
     AvenusCommon,
     AvenusMedia;

TYPE
  TLOCShow = Class
    MyScreen : TLOCScreen;
    Constructor Create(Screen : TLOCScreen);
    Destructor Destroy;OverRide;
    Procedure ShowCredits;
  End;
VAR
  GameShow : TLOCShow;
  
IMPLEMENTATION

CONSTRUCTOR TLOCShow.Create(Screen : TLOCScreen);
  Begin
    MyScreen:=Screen;
  End;

DESTRUCTOR TLOCShow.Destroy;
  Begin
  End;

PROCEDURE TLOCShow.ShowCredits;
  Var Sound : TAvenusSound;
  Begin
    With MyScreen do
      Begin
        Sound:=TAvenusSound.Create(Screen.Handle,GameDataDir+'Sound\CreditVocal.mp3',True);
        Sound.SetVolume(100);
        Sound.Test;
        Sound.Play;
        Repeat
          Input.GetState;
          If Input.KeyPress(Key_0) then Sound.EnvironmentChanged(sePaddedCell);
          If Input.KeyPress(Key_1) then Sound.EnvironmentChanged(seRoom);
          If Input.KeyPress(Key_2) then Sound.EnvironmentChanged(seBathroom);
          If Input.KeyPress(Key_3) then Sound.EnvironmentChanged(seLivingRoom);
          If Input.KeyPress(Key_4) then Sound.EnvironmentChanged(seStoneroom);
          If Input.KeyPress(Key_5) then Sound.EnvironmentChanged(seAuditorium);
          If Input.KeyPress(Key_6) then Sound.EnvironmentChanged(seConcertHall);
          If Input.KeyPress(Key_7) then Sound.EnvironmentChanged(seCave);
          If Input.KeyPress(Key_8) then Sound.EnvironmentChanged(seArena);
          If Input.KeyPress(Key_9) then Sound.EnvironmentChanged(seHangar);
        Until Input.KeyPress(Key_Escape);
        Sound.Stop;
        Sound.Free;
      End;
  End;
END.