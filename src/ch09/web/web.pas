program web;

{/*--------------------------------------
   WEB.C -- Mouse Movement Demo Program
            (c) Charles Petzold, 1993
  --------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

var
  ptl: POINTL;

procedure DrawWeb (hps: cardinal;  pptlPointerPos: PPOINTL; pptlClient: PPOINTL);
begin
                                   // Lower Left -^. Pointer -^. Upper Right
     ptl.x := 0 ;
     ptl.y := 0 ;
     GpiMove (hps, ptl) ;
     GpiLine (hps, pptlPointerPos^) ;
     GpiLine (hps, pptlClient^) ;
                                   // Upper Left -^. Pointer -^. Lower Right

     ptl.x := 0 ;

     ptl.y := pptlClient^.y ;

     GpiMove (hps, ptl) ;
     GpiLine (hps, pptlPointerPos^) ;

     ptl.x := pptlClient^.x ;
     ptl.y := 0 ;
     GpiLine (hps, ptl) ;
                                   // Lower Center -^. Pointer -^. Upper Center
     ptl.x := pptlClient^.x div 2 ;
     ptl.y := 0 ;
     GpiMove (hps, ptl) ;
     GpiLine (hps, pptlPointerPos^) ;

     ptl.y := pptlClient^.y ;
     GpiLine (hps, ptl) ;
                                   // Left Center -^. Pointer -^. Right Center
     ptl.x := 0 ;
     ptl.y := pptlClient^.y div 2 ;
     GpiMove (hps, ptl) ;
     GpiLine (hps, pptlPointerPos^) ;

     ptl.x := pptlClient^.x ;
     GpiLine (hps, ptl) ;
end; {DrawWeb}

var
  ptlClient, ptlPointerPos : POINTL;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;

var
   hps: cardinal;

begin
  ClientWindowProc := nil;
   case Msg of
         WM_SIZE: begin
               ptlClient.x := SHORT1FROMMP (mp2) ;
               ptlClient.y := SHORT2FROMMP (mp2) ;
             end;

         WM_MOUSEMOVE: begin
               hps := WinGetPS (Window) ;
               GpiSetMix (hps, FM_INVERT) ;

               DrawWeb (hps, @ptlPointerPos, @ptlClient) ;

               ptlPointerPos.x := MOUSEMSG(@msg).x ;
               ptlPointerPos.y := MOUSEMSG(@msg).y ;

               DrawWeb (hps, @ptlPointerPos, @ptlClient) ;

               WinReleasePS (hps) ;
           end;                      // do default processing

        WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil ) ;
               
               GpiErase (hps) ;
               GpiSetMix (hps, FM_INVERT) ;

               DrawWeb (hps, @ptlPointerPos, @ptlClient) ;

               WinEndPaint (hps) ;
            end;
        else ;
    end; {case}
    
    ClientWindowProc := WinDefWindowProc (Window, Msg, MP1, MP2);
    
end;

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Web' ;

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

