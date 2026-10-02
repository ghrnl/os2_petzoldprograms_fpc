program blokout2;

{/*-----------------------------------------
   BLOKOUT2.C -- Mouse Button Demo Program
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

procedure DrawBoxOutline (hwnd: cardinal; pptlStart: POINTL; pptlEnd: POINTL);
var
   hps: cardinal;
begin
     hps := WinGetPS (hwnd) ;
     GpiSetMix (hps, FM_INVERT) ;

     GpiMove (hps, pptlStart) ;
     GpiBox (hps, DRO_OUTLINE, pptlEnd, 0, 0) ;

     WinReleasePS (hps) ;
end; {DrawBoxOutline}

var
  fCapture, fValidBox: boolean;
  ptlStart, ptlEnd, ptlBoxStart, ptlBoxEnd : POINTL;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;

var
   hps: cardinal;

{ extra }
var
  fs: integer;
  vkey: integer;

begin
  ClientWindowProc := nil;
   case Msg of

          WM_BUTTON1DOWN: begin
               ptlEnd.x := MOUSEMSG(@msg).x ;
               ptlStart.x := ptlEnd.x;
               ptlEnd.y := MOUSEMSG(@msg).y ;
               ptlStart.y := ptlEnd.y;
               { FIX not needed here }

               DrawBoxOutline (Window, ptlStart, ptlEnd) ;

               WinSetCapture (HWND_DESKTOP, Window) ;
               fCapture := TRUE ;
             end;                       // do default processing

          WM_MOUSEMOVE: begin
               if (fCapture) then
                    begin
                    DrawBoxOutline (Window, ptlStart, ptlEnd) ;
                    {ptlEnd.x := MOUSEMSG(@msg).x ;
                    ptlEnd.y := MOUSEMSG(@msg).y ;}
                    { FIX needed here }
                    WinQueryPointerPos (HWND_DESKTOP, ptlEnd) ;
                    WinMapWindowPoints (HWND_DESKTOP, Window, ptlEnd,1) ;

                    DrawBoxOutline (Window, ptlStart, ptlEnd) ;
                    end;
                end;                        // do default processing

          WM_BUTTON1UP: begin
               if (fCapture) then
                    begin
                    DrawBoxOutline (Window, ptlStart, ptlEnd) ;

                    ptlBoxStart := ptlStart ;
                    ptlBoxEnd.x := MOUSEMSG(@msg).x ;
                    ptlBoxEnd.y := MOUSEMSG(@msg).y ;
                    { FIX not needed here}

                    WinSetCapture (HWND_DESKTOP, 0) ;
                    fCapture := FALSE ;
                    fValidBox := TRUE ;
                    WinInvalidateRect (Window, nil, FALSE) ;
                    end;
                 end;

           WM_CHAR: begin
               fs:=short1frommp(mp2);
               vkey:=short2frommp(mp2);

               if (fCapture and ((fs>0   and  KC_VIRTUALKEY)) and
                             (not((fs>0   and  KC_KEYUP))  )   and 
                               (vkey = VK_ESC)) then
                    begin
                    DrawBoxOutline (Window, ptlStart, ptlEnd) ;

                    WinSetCapture (HWND_DESKTOP, 0) ;
                    fCapture := FALSE ;
                    end;
                end;

           WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil ) ;

               GpiErase (hps) ;

               if (fValidBox) then
                    begin
                    GpiMove (hps, ptlBoxStart) ;
                    GpiBox (hps, DRO_OUTLINEFILL, ptlBoxEnd, 0, 0) ;
                    end;
               if (fCapture) then
                    begin
                    GpiSetMix (hps, FM_INVERT) ;

                    GpiMove (hps, ptlStart) ;
                    GpiBox (hps, DRO_OUTLINE, ptlEnd, 0, 0) ;
                    end;
               WinEndPaint (hps) ;
         
            end;
        else ;
    end; {case}
    
    ClientWindowProc := WinDefWindowProc (Window, Msg, MP1, MP2);
    
end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Blokout2' ;

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

