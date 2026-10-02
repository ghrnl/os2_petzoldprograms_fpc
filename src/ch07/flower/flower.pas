program flower;

{/*---------------------------------------
   FLOWER.C -- Transform Demonstration
               (c) Charles Petzold, 1993
  ---------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

const TWOPI = (2 * pi); {3.14159}

procedure DrawPetal (hps: cardinal);

var
  ab: AREABUNDLE;
  lb: LINEBUNDLE;
  aptl: array[0..7-1] of POINTL = (
     (x:   0; y:   0),
     (x: 125; y: 125),
     (x: 475; y: 125),
     (x: 600; y:   0),
     (x: 475; y:-125),
     (x: 125; y:-125),
     (x:   0; y:   0)
  );

begin {DrawPetal}

    { static vars }
    ab.lColor:=CLR_RED;
    lb.lColor:=CLR_BLACK;

     GpiSavePS (hps) ;
     GpiSetAttrs (hps, PRIM_AREA, ABB_COLOR, 0,  @ab) ;
     GpiSetAttrs (hps, PRIM_LINE, LBB_COLOR, 0,  @lb) ;

     GpiBeginArea (hps, BA_BOUNDARY or BA_ALTERNATE) ;

     GpiMove (hps, aptl[0]) ;
     GpiPolySpline (hps, 6, aptl[1]) ;

     GpiEndArea (hps) ;
     GpiRestorePS (hps, -1) ;
end; {DrawPetal}

procedure  DrawPetals (hps: cardinal);

var
  ab: AREABUNDLE;
  lb: LINEBUNDLE;
  i: integer;
  matlf: MATRIXLF;
  aptl: array[0..2-1] of POINTL = ((x:-150; y: -150),(x: 150; y:150));

begin {DrawPetals}

    { static vars }
    ab.lColor:=CLR_YELLOW;
    lb.lColor:=CLR_BLACK;

     GpiSavePS (hps) ;

     GpiQueryModelTransformMatrix (hps, 9, matlf);
     for i := 0  to 8-1 do
          begin
          matlf.fxM11 := round( (65536 *  cos (TWOPI * i / 8)) );
          matlf.fxM12 := round( (65536 *  sin (TWOPI * i / 8)) );
          matlf.fxM21 := round( (65536 * -sin (TWOPI * i / 8)) );
          matlf.fxM22 := round( (65536 *  cos (TWOPI * i / 8)) );

          GpiSetModelTransformMatrix (hps, 9, matlf, TRANSFORM_REPLACE);
 
          DrawPetal (hps) ;
          end; {for i}

     GpiSetAttrs (hps, PRIM_AREA, ABB_COLOR, 0, @ab) ;
     GpiSetAttrs (hps, PRIM_LINE, LBB_COLOR, 0, @lb) ;

     GpiMove (hps, aptl[0]) ;
     GpiBox (hps, DRO_OUTLINEFILL, aptl[1], 300, 300) ;

     GpiRestorePS (hps, -1) ;
end; {DrawPetals}

procedure DrawFlower (hps: cardinal; cxClient, cyClient: integer);

var
   matlf: MATRIXLF;
   ptl: POINTL;
   aptl: array [0..4-1] of POINTL;

begin {DrawFlower}

     GpiSavePS (hps) ;

     ptl.x := cxClient ;
     ptl.y := cyClient ;

     GpiConvert (hps, CVTC_DEVICE, CVTC_PAGE, 1, ptl) ;

     aptl[0].x := 0 ;
     aptl[0].y := 0 ;

     aptl[1].x := 0 ;
     aptl[1].y := ptl.y div 4 ;

     aptl[2].x := 0 ;
     aptl[2].y := ptl.y ;

     aptl[3].x := ptl.x div 2 ;
     aptl[3].y := ptl.y div 2 ;

     GpiSavePS (hps) ;

     GpiSetLineWidthGeom (hps, 50) ;

     GpiBeginPath (hps, 1) ;
     GpiMove (hps, aptl[0]) ;
     GpiPolySpline (hps, 3, aptl[1]) ;
     GpiEndPath (hps) ;

     GpiStrokePath (hps, 1, 0) ;

     GpiRestorePS (hps, -1) ;

     GpiQueryDefaultViewMatrix (hps, 9, matlf) ;

     matlf.lM31 := ptl.x div 2 ;
     matlf.lM32 := ptl.y div 2 ;

     GpiSetDefaultViewMatrix (hps, 9, matlf, TRANSFORM_REPLACE) ;

     DrawPetals (hps) ;

     GpiRestorePS (hps, -1) ;
end; {DrawFlower}

var
   cxClient, cyClient: integer ;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;

var
   hps: cardinal;
    _sizel: SIZEL;

begin
  ClientWindowProc := nil;
   case Msg of
         WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
             end;

  wm_Paint: begin
               hps := WinBeginPaint (Window, 0, nil ) ;
               
               GpiErase (hps) ;

               _sizel.cx := 0 ;
               _sizel.cy := 0 ;
               GpiSetPS (hps, _sizel, PU_LOMETRIC) ;

               DrawFlower (hps, cxClient, cyClient) ;

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
  szClientClass: PChar = 'Flower';

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

