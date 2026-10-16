program bitcat2;

{/*------------------------------------------
   BITCAT2.C -- Bitmap Creation and Display
                (c) Charles Petzold, 1993
  ------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,pmbitmap,pmdev;

{$i ..\..\ch00\mousutil.pas}

var
     hbm : HBITMAP;
     hdcMemory : cardinal; {HDC}
     hpsMemory : cardinal; {HPS}
     cxClient, cyClient : integer;

{$i ..\bitcat1\bitcat_hdr.pas}

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     pbmi: PBITMAPINFO2; { * pbmi }
     bmp : BITMAPINFOHEADER2 ; { ??? or prefixed with T }
     hab : cardinal;
     hps : cardinal;
     aptl : array [0..4-1] of POINTL;
     sizl : SIZEL;

{ extra }
    xxx1: DevOpenStruc;
    xxx2: TBitmapInfo2;
    xxx3: byte=0;

begin

     case msg of
          
          WM_CREATE: begin
               hab := WinQueryAnchorBlock (Window) ;

                         // Open memory DC and create PS associated with it

               {hdcMemory = DevOpenDC (hab, OD_MEMORY, "*", 0L, NULL, 0) ;}
               fillbyte (xxx1, sizeof (xxx1), 0);
               hdcMemory := DevOpenDC (hab, OD_MEMORY, '*', 0, xxx1, 0) ;

               sizl.cx := 0 ;
               sizl.cy := 0 ;

               hpsMemory := GpiCreatePS (hab, hdcMemory, sizl,
					PU_PELS    or GPIF_DEFAULT or
                                        GPIT_MICRO or GPIA_ASSOC) ;

                         // Create 32 by 32 bitmap

               {memset} fillbyte (bmp, sizeof (bmp), 0);

               bmp.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               bmp.cx        := 32 ;
               bmp.cy        := 32 ;
               bmp.cPlanes   := 1 ;
               bmp.cBitCount := 1 ;

               fillbyte (xxx2, 0, sizeof (xxx2)) ;
               fillbyte (xxx3, 0, sizeof (xxx3)) ;
               {hbm = GpiCreateBitmap (hpsMemory, &bmp, 0L, NULL, NULL) ;}
               hbm := GpiCreateBitmap (hpsMemory, bmp, 0, xxx3, xxx2) ;

                         // Select bitmap into memory PS

               GpiSetBitmap (hpsMemory, hbm) ;

                         // Set bitmap bits from abBitCat array

               pbmi := getmem (sizeof (BITMAPINFO2) + sizeof (RGB)) ;
               {memset} fillbyte (pbmi^, sizeof (pbmi^), 0);

               pbmi^.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               pbmi^.cx        := 32 ;
               pbmi^.cy        := 32 ;
               pbmi^.cPlanes   := 1 ;
               pbmi^.cBitCount := 1 ;

               pbmi^.argbColor[0].bBlue  := $00 ;      // 0 bits (background)
               pbmi^.argbColor[0].bGreen := $00 ;
               pbmi^.argbColor[0].bRed   := $00 ;
               pbmi^.argbColor[0].fcOptions := 0 ;
{
               pbmi^.argbColor[1].bBlue  := $FF ;      // 1 bits (foreground)
               pbmi^.argbColor[1].bGreen := $FF ;
               pbmi^.argbColor[1].bRed   := $FF ;
}
               pbmi^.argbColor[0].fcOptions := 0 ;

               GpiSetBitmapBits (hpsMemory, 0, 32, abBitCat[0], pbmi^) ;

               freemem (pbmi) ;
               {return 0 ;}
               end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
               {return 0 ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;

               aptl[0].x := 0 ;                    // target lower left
               aptl[0].y := 0 ;

               aptl[1].x := cxClient ;             // target upper right
               aptl[1].y := cyClient ;

               aptl[2].x := 0 ;                    // source lower left
               aptl[2].y := 0 ;

               aptl[3].x := 32 ;                   // source upper right
               aptl[3].y := 32 ;

               GpiBitBlt (hps, hpsMemory, 4, aptl[0], ROP_SRCCOPY, BBO_AND) ;

               aptl[1] := aptl[3] ;                // target upper right

               GpiBitBlt (hps, hpsMemory, 3, aptl[0], ROP_SRCCOPY, BBO_AND) ;

               WinEndPaint (hps) ;
               {return 0 ;}
               end;

          WM_DESTROY: begin
               GpiDestroyPS (hpsMemory) ;
               DevCloseDC (hdcMemory) ;
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
  szClientClass: PChar = 'BitCat2';

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

