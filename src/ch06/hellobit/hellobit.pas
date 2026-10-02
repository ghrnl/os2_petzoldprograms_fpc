program hellobit;

{/*-----------------------------------------
   HELLOBIT.C -- "Hello, world" Bitmap
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmbitmap, pmdev;

{$i ..\..\ch00\mousutil.pas}


const
     szHello = ' Hello, world! '; {this works }

var
     {szHello : Pchar = ' Hello, world! ' ;} { ??? does not work but why }
     {szHello : array [0..15-1] of char = ' Hello, world! ' ;} { ??? works but why }
     hbm : HBITMAP;
     hdcMemory : cardinal; {HDC}
     hpsMemory : cardinal; {HPS}
     cxClient, cyClient, cxString, cyString : integer;
     
function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     bmp : BITMAPINFOHEADER2;
     hab : cardinal;
     hps : cardinal;
     aptl : array [0..4-1] of POINTL;
     ptl : POINTL;
     x, y : integer;
     sizl : SIZEL;

{ extra }
    xxx1: DevOpenStruc;
    xxx2: TBitmapInfo2;
    xxx3: byte=0;

begin

     case (msg) of
          
          WM_CREATE: begin
               hab := WinQueryAnchorBlock (Window) ;

                         // Open memory DC and create PS associated with it

               {hdcMemory = DevOpenDC (hab, OD_MEMORY, "*", 0L, NULL, 0) ;}
               hdcMemory := DevOpenDC (hab, OD_MEMORY, '*', 0, xxx1 {nil}, 0) ;

               sizl.cx := 0 ;
               sizl.cy := 0 ;
               hpsMemory := GpiCreatePS (hab, hdcMemory, sizl,
					PU_PELS    or GPIF_DEFAULT or
                                        GPIT_MICRO or GPIA_ASSOC) ;

                         // Determine dimensions of text string

               GpiQueryTextBox (hpsMemory, sizeof(szHello) - 1,
                                szHello, 4, aptl[0]) ;

               cxString := {(SHORT)} (aptl [TXTBOX_TOPRIGHT].x -
                                   aptl [TXTBOX_TOPLEFT].x) ;

               cyString := {(SHORT)} (aptl [TXTBOX_TOPLEFT].y -
                                   aptl [TXTBOX_BOTTOMLEFT].y) ;

                         // Create bitmap and set it in the memory PS

               {memset} fillbyte (bmp, sizeof(bmp), 0);

               bmp.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               bmp.cx        := cxString ;
               bmp.cy        := cyString ;
               bmp.cPlanes   := 1 ;
               bmp.cBitCount := 1 ;

               {hbm = GpiCreateBitmap (hpsMemory, &bmp, 0L, 0L, NULL) ;}
               hbm := GpiCreateBitmap (hpsMemory, bmp, 0, xxx3, xxx2) ;

               GpiSetBitmap (hpsMemory, hbm) ;

                         // Write the text string to the memory PS

               ptl.x := 0 ;
               ptl.y := {ptl.y } - aptl [TXTBOX_BOTTOMLEFT].y ;

               GpiSetColor (hpsMemory, CLR_TRUE) ;
               GpiSetBackColor (hpsMemory, CLR_FALSE) ;
               GpiSetBackMix (hpsMemory, BM_OVERPAINT) ;
               GpiCharStringAt (hpsMemory, ptl, sizeof(szHello) - 1,
                                szHello) ;
               {return 0 ;}
               end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
               {return 0 ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;

               for y := 0 to cyClient div cyString do
                    for x := 0  to cxClient div cxString do
                         begin
                         aptl[0].x := x * cxString ;    // target lower left
                         aptl[0].y := y * cyString ;

                         aptl[1].x := aptl[0].x + cxString ; // upper right
                         aptl[1].y := aptl[0].y + cyString ;

                         aptl[2].x := 0 ;               // source lower left
                         aptl[2].y := 0 ;

                         GpiBitBlt (hps, hpsMemory, 3, aptl[0], ROP_SRCCOPY,
                                    BBO_AND) ;
                         end;
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
  szClientClass: PChar = 'HelloBit';


begin

     flFrameFlags :=   FCF_TITLEBAR   or FCF_SYSMENU
                    or FCF_SIZEBORDER or FCF_MINMAX
                    or FCF_SHELLPOSITION or FCF_TASKLIST ;

     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

     while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
          WinDispatchMsg (hab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;

end.

