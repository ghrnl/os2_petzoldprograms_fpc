program endjoin;

{/*----------------------------------------
   ENDJOIN.C -- Line Ends and Joins
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

procedure DrawFigure (hps: cardinal; i: integer; cxClient: integer; cyClient: integer);

var ptl : POINTL ;
     begin
     ptl.x :=  (1 + 10 * i) * cxClient div 30 ;
     ptl.y := 3 * cyClient div 4 ;
     GpiMove (hps, ptl) ;

     ptl.x := (5 + 10 * i) * cxClient div 30 ;
     ptl.y := cyClient div 4;
     GpiLine (hps, ptl) ;

     ptl.x := (9 + 10 * i) * cxClient div 30 ;
     ptl.y := 3 * cyClient div 4 ;
     GpiLine (hps, ptl) ;
end; {DrawFigure}

var
   cxClient, cyClient: integer;
   hps: cardinal;
   { initial values below require fpc >= 3.2 }
   alJoin: array[0..3-1] of longint = (LINEJOIN_BEVEL, LINEJOIN_ROUND, LINEJOIN_MITRE);
   alEnd : array[0..3-1] of longint = (LINEEND_FLAT, LINEEND_SQUARE, LINEEND_ROUND);

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;

var
    i: integer;
 
begin
  ClientWindowProc := nil;
   case Msg of
         WM_SIZE: begin
                cxClient := SHORT1FROMMP (mp2) ;
                cyClient := SHORT2FROMMP (mp2) ;
              end;

        WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil ) ;
               GpiErase (hps) ;

               for i := 0  to 3-1 do
                    begin
                           // Draw the geometric line

                    GpiSetLineJoin (hps, alJoin [i]) ;
                    GpiSetLineEnd  (hps, alEnd  [i]) ;
                    GpiSetLineWidthGeom (hps, cxClient div 20) ;
                    GpiSetColor (hps, CLR_DARKGRAY) ;

                    GpiBeginPath (hps, 1) ;
                    DrawFigure (hps, i, cxClient, cyClient) ;
                    GpiEndPath (hps) ;

                    GpiStrokePath (hps, 1, 0) ;

                             // Draw the cosmetic line

                    GpiSetLineWidth (hps, LINEWIDTH_THICK) ;
                    GpiSetColor (hps, CLR_BLACK) ;

                    DrawFigure (hps, i, cxClient, cyClient) ;
                    end;

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
  szClientClass: PChar = 'Endjoin';

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

