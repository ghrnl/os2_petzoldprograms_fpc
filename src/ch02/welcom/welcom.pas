program welcom;

{/*----------------------------------------------------
   WELCOM.C -- A Program that Creates a Client Window
               (c) Charles Petzold, 1993
  ----------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses pmwin;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
begin
  ClientWindowProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
end;

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Welcome' ; {! this is what .C has }

{ MAIN PROGRAM }

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWindowProc, 0, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;


  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

