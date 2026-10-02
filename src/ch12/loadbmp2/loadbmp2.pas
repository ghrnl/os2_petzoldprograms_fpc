program loadbmp2;

{/*----------------------------------------------------
   LOADBMP2.C -- Loads a Bitmap Resource and Draws it
                 (c) Charles Petzold, 1993
  ----------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{ resource compiler after fpc: wrc loadbmp.rc loadbmp2.exe }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

const
  IDB_HELLO = 55;

var
  hps : cardinal;
  hbm:  HBITMAP;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  Rcl: TRectL;
begin
  ClientWindowProc := nil;
  
  case msg of
  
          WM_CREATE: begin
               hps := WinGetPS (window) ;
               hbm := GpiLoadBitmap (hps, 0, IDB_HELLO, 0, 0) ;
               WinReleasePS (hps) ;
             end;

          WM_PAINT: begin
               hps := WinBeginPaint (window, 0, nil) ;
               GpiErase (hps) ;

               WinQueryWindowRect (window, rcl) ;

               if (hbm>0) then begin
                    WinDrawBitmap (hps, hbm, nil, @rcl,
                                   CLR_BACKGROUND, CLR_NEUTRAL, DBM_STRETCH) ;

               end;

               WinEndPaint (hps) ;
             end;

          WM_DESTROY: begin
               if (hbm>0) then
                    GpiDeleteBitmap (hbm) ;               
             end;
          
          else ;
          
       end; {case}
       
       ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;
       
end; {WinDefWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'LoadBmp2' ;

begin
  
  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWindowProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

