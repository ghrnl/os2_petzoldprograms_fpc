program welc;

{/*----------------------------------------------------------
   WELC.C -- A Program that Creates a Standard Frame Window
             (c) Charles Petzold, 1993
  ----------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses pmwin;

var
  hab: cardinal;
  hmq: cardinal;
  hwndFrame :  cardinal;
  flFrameFlags: cardinal;

begin

  flFrameFlags := FCF_TITLEBAR or FCF_SYSMENU
                  or FCF_SIZEBORDER or FCF_MINMAX
                  or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;


  hwndFrame := WinCreateStdWindow (
                    HWND_DESKTOP,
                    WS_VISIBLE,
                    @flFrameFlags,
                    nil,
                    nil,
                    0,
                    0,
                    0,
                    nil) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab) ;

end.

