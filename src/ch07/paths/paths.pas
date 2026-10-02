program paths;

{/*--------------------------------------
   PATHS.C -- Path Functions
              (c) Charles Petzold, 1993
  --------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
   cxClient, cyClient: integer ;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;

var
   hps: cardinal;
   x,y: integer;
   ptl: POINTL;

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
         
               for x := 0  to 3-1 do
               for y := 0 to 2-1 do
                    begin
                         {  Create an open sub-path }

                    GpiBeginPath (hps, 1) ;

                    ptl.x :=  (1 + 10 * x) * cxClient div 30;
                    ptl.y :=  (4 +  5 * y) * cyClient div 10;
                    GpiMove (hps, ptl) ;

                    ptl.x :=  (5 + 10 * x) * cxClient div 30;
                    ptl.y :=  (2 +  5 * y) * cyClient div 10;
                    GpiLine (hps, ptl) ;

                    ptl.x :=  (9 + 10 * x) * cxClient div 30;
                    ptl.y :=  (4 +  5 * y) * cyClient div 10;
                    GpiLine (hps, ptl) ;

                         { Create a closed sub-path }

                    ptl.x :=  (1 + 10 * x) * cxClient div 30;
                    ptl.y :=  (3 +  5 * y) * cyClient div 10;
                    GpiMove (hps, ptl) ;

                    ptl.x :=  (5 + 10 * x) * cxClient div 30;
                    ptl.y :=  (1 +  5 * y) * cyClient div 10;
                    GpiLine (hps, ptl) ;

                    ptl.x :=  (9 + 10 * x) * cxClient div 30;
                    ptl.y :=  (3 +  5 * y) * cyClient div 10;
                    GpiLine (hps, ptl) ;

                    GpiCloseFigure (hps) ;
                    GpiEndPath (hps) ;

                         { Possibly modify the path }

                    if (y = 0) then
                         begin
                         GpiSetLineWidthGeom (hps, cxClient div 30) ;
                         GpiModifyPath (hps, 1, MPATH_STROKE) ;
                         end;

                         { Perform the operation }

                    GpiSetLineWidth (hps, LINEWIDTH_THICK) ;
                    GpiSetLineWidthGeom (hps, cxClient div 50) ;
                    GpiSetPattern (hps, PATSYM_HALFTONE) ;


                    case x of
                          0:  GpiOutlinePath (hps, 1, 0) ;

                          1:  GpiStrokePath (hps, 1, 0) ;

                          2:  GpiFillPath (hps, 1, FPATH_ALTERNATE) ;

                         end; {case x}
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
  szClientClass: PChar = 'Paths' ;

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

