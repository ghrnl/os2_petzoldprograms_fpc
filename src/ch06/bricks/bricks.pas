program bricks;

{ status: paints, but only with fpc bricks, not with -gh }

{/*--------------------------------------------
   BRICKS.C -- Customized Pattern from Bitmap
               (c) Charles Petzold, 1993
  --------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmbitmap, pmdev;

{$i ..\..\ch00\mousutil.pas}

const LCID_BRICKS_BITMAP  =  1;

var
     abBrick : array  [0..32-1] of BYTE = (
                                      $00, $00, $00, $00,
                                      $F3, $00, $00, $00,
                                      $F3, $00, $00, $00,
                                      $F3, $00, $00, $00,
                                      $00, $00, $00, $00,
                                      $3F, $00, $00, $00,
                                      $3F, $00, $00, $00,
                                      $3F, $00, $00, $00
                                      ) ;
     hbm : HBITMAP;
     aptl: array [0..2-1] of POINTL ;
     
function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     pbmi : ^BITMAPINFO2; { use PBITMAPINFO2 or ^TBITMAPINFO2 or ^BITMAPINFO2}
     bmp : BITMAPINFOHEADER2;
     hps : cardinal;

begin

     case (msg) of
          
          WM_CREATE: begin
                              // Create 8 by 8 bitmap

               {memset} fillbyte (bmp, sizeof (BITMAPINFOHEADER2), 0) ;

               bmp.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               bmp.cx        := 8 ;
               bmp.cy        := 8 ;
               bmp.cPlanes   := 1 ;
               bmp.cBitCount := 1 ;

               pbmi := getmem (sizeof (BITMAPINFO2) + sizeof (RGB)) ;

               {memset} fillbyte (pbmi^, sizeof (pbmi^), 0) ;

               pbmi^.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               pbmi^.cx        := 8 ;
               pbmi^.cy        := 8 ;
               pbmi^.cPlanes   := 1 ;
               pbmi^.cBitCount := 1 ;

               pbmi^.argbColor[0].bBlue  := $00 ;
               pbmi^.argbColor[0].bGreen := $00 ;
               pbmi^.argbColor[0].bRed   := $00 ;
               pbmi^.argbColor[0].fcOptions := 0 ;

               {pbmi^.argbColor[1].bBlue  := $FF ;
               pbmi^.argbColor[1].bGreen := $FF ;
               pbmi^.argbColor[1].bRed   := $FF ;
               pbmi^.argbColor[1].fcOptions := 0 ;}

               hps := WinGetPS (Window) ;
               hbm := GpiCreateBitmap (hps, bmp, CBM_INIT, abBrick[0], pbmi^) ;

               WinReleasePS (hps) ;
               freemem (pbmi) ;
               {return 0 ;}
               end;

          WM_SIZE: begin
               aptl[1].x := SHORT1FROMMP (mp2) ;
               aptl[1].y := SHORT2FROMMP (mp2) ;
               {return 0 ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;

               GpiSetBitmapId (hps, hbm, LCID_BRICKS_BITMAP) ;
               GpiSetPatternSet (hps, LCID_BRICKS_BITMAP) ;

               GpiBitBlt (hps, 0, 2, aptl[0], ROP_PATCOPY, BBO_AND) ;

               GpiSetPatternSet (hps, LCID_DEFAULT) ;
               GpiDeleteSetId (hps, LCID_BRICKS_BITMAP) ;

               WinEndPaint (hps) ;
               {return 0 ;}
               end;

          WM_DESTROY: begin
               GpiDeleteBitmap (hbm) ;
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
  szClientClass: PChar = 'Bricks';

begin

     flFrameFlags :=  FCF_TITLEBAR      or FCF_SYSMENU  or
                      FCF_SIZEBORDER    or FCF_MINMAX   or
                      FCF_SHELLPOSITION or FCF_TASKLIST ;

     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

     while WinGetMsg (hab, qmsg, 0, 0, 0) do
          WinDispatchMsg (hab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
     
end.

