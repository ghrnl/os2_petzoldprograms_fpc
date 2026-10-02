program beeper2;

{/*----------------------------------------
   BEEPER2.C -- Timer Demo Program No. 2
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
    fFlipFlop : boolean = false;
    
function  ClientWndProc (Window, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;

var
     hps : cardinal;
     rcl : RECTL;

begin

     case (msg) of
          
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
  szClientClass: Pchar = 'Beeper2';
  idTimer : ULONG;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST ;
   
  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  idTimer := WinStartTimer (hab, 0, 0, 1000) ;
  
  while WinGetMsg (hab, qmsg, 0, 0, 0) do
          begin
          if (qmsg.msg = WM_TIMER) and (SHORT1FROMMP (qmsg.mp1) = idTimer) then
               begin
               WinAlarm (HWND_DESKTOP, WA_NOTE) ;
               fFlipFlop := not fFlipFlop ;
               WinInvalidateRect (hwndClient, nil, FALSE) ;
               end
          else
               WinDispatchMsg (hab, qmsg) ;
  end;

  WinStopTimer (hab, 0, idTimer) ;
  
  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

