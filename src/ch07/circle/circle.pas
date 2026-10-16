program circle;

{---------------------------------------
   CIRCLE.C -- Transform Demonstration
               (c) Charles Petzold, 1993
  ---------------------------------------}
{ port to fpc 2.6.4   Gert Renkema, 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

procedure DrawFigure (hps: cardinal);

var
  ptl : POINTL;

begin
     ptl.x := -1000 ;
     ptl.y := -1000 ;
     GpiMove (hps, ptl) ;

     ptl.x := 1000 ;
     ptl.y := 1000 ;
     GpiBox (hps, DRO_OUTLINE, ptl, 2000, 2000) ;
end; {DrawFigure}


var {static}
   cxClient, cyClient: integer ;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;

var
   hps: cardinal;
   ptl: POINTL;
   rcl: RECTL;
   _sizel: SIZEL ;

begin {ClientWindowProc}
  ClientWindowProc := nil;
   case Msg of
         WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
             end;

         WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil ) ;
               
               GpiErase (hps) ;

                   { Draw ellipse }

               _sizel.cx := 1000 ;
               _sizel.cy := 1000 ;
               GpiSetPS (hps, _sizel, PU_PELS) ;

               rcl.xLeft   := cxClient div 2 ;
               rcl.xRight  := cxClient ;
               rcl.yBottom := cyClient div 2 ;
               rcl.yTop    := cyClient ;

               GpiSetPageViewport (hps, rcl) ;

               DrawFigure (hps) ;

                    { Draw circle }

               _sizel.cx := 1000 ;
               _sizel.cy := 1000 ;
               GpiSetPS (hps, _sizel, PU_ARBITRARY) ;

               ptl.x := cxClient ;
               ptl.y := cyClient ;

               GpiConvert (hps, CVTC_DEVICE, CVTC_PAGE, 1, ptl) ;

               ptl.x := min (ptl.x, ptl.y) ;
               ptl.y := ptl.x;

               GpiConvert (hps, CVTC_PAGE, CVTC_DEVICE, 1, ptl) ;

               rcl.xLeft   := cxClient div 2 ;
               rcl.xRight  := (ptl.x + cxClient) div 2 ;
               rcl.yBottom := cyClient div 2 ;
               rcl.yTop    := (ptl.y + cyClient) div 2 ;

               GpiSetPageViewport (hps, rcl) ;

               DrawFigure (hps) ;

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
  szClientClass: PChar = 'Circle';

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

