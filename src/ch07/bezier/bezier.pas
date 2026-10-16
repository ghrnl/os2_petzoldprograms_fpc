program bezier;

{---------------------------------------
   BEZIER.C -- Bezier Splines
               (c) Charles Petzold, 1993
  ---------------------------------------}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
  cxClient, cyClient: longint; {integer;}
  aptl: array [0..3] of POINTL;
 
function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
 hps : cardinal;


begin
  ClientWindowProc := nil;
   case Msg of
         WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;

               aptl[0].x := cxClient div 3 ;
               aptl[0].y := cyClient div 2 ;

               aptl[1].x := cxClient div 2 ;
               aptl[1].y := 3 * cyClient div 4 ;

               aptl[2].x := cxClient div 2 ;
               aptl[2].y := cyClient div 4 ;


               aptl[3].x := 2 * cxClient div 3 ;
               aptl[3].y := cyClient div 2 ;

             end;

           WM_BUTTON1DOWN: begin
               aptl[1].x := MOUSEMSG(@msg).x ;
               aptl[1].y := MOUSEMSG(@msg).y ;

               WinInvalidateRect (window, nil, TRUE) ;
             end;

           WM_BUTTON2DOWN: begin
               aptl[2].x := MOUSEMSG(@msg).x ;
               aptl[2].y := MOUSEMSG(@msg).y ;
               WinInvalidateRect (window, nil, TRUE) ;
            end;

           WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

                    // Draw dotted straight lines

               GpiSetLineType (hps, LINETYPE_DOT) ;

               GpiMove (hps, aptl[0]) ;
               GpiLine (hps, aptl[1]) ;
               GpiMove (hps, aptl[2]) ;
               GpiLine (hps, aptl[3]) ;

                    // Draw spline

               GpiSetLineType (hps, LINETYPE_SOLID) ;
               GpiMove (hps, aptl[0]) ;
               GpiPolySpline (hps, 3, aptl[1]) ;

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
  szClientClass: PChar = 'Bezier' ;

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

