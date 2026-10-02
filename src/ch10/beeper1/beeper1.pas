program beeper1;

{/*----------------------------------------
   BEEPER1.C -- Timer Demo Program No. 1
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

const ID_TIMER =  1;

var
     fFlipFlop : boolean;

function  ClientWndProc (Window, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;

var
     hps : cardinal;
     rcl : RECTL;

begin

     case (msg) of
          
          WM_TIMER: begin
               WinAlarm (HWND_DESKTOP, WA_NOTE) ;
               fFlipFlop := not fFlipFlop ;
               WinInvalidateRect (Window, nil, FALSE) ;
               {return 0 ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;

               WinQueryWindowRect (Window, rcl) ;
               if fFlipFlop then
                 WinFillRect (hps, rcl, CLR_BLUE) 
               else
                 WinFillRect (hps, rcl, CLR_RED) ;

               WinEndPaint (hps) ;
               {return 0 ;}
               end;
     end; {case}
     
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'Beeper1';

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST ;
   
  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, 0, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  WinStartTimer (hab, hwndClient, ID_TIMER, 1000) ;
  
  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinStopTimer (hab, hwndClient, ID_TIMER) ;
  
  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

