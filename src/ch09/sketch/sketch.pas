program sketch;

{/*---------------------------------------
   SKETCH.C -- Mouse Sketching Program
               (c) Charles Petzold, 1993
  ---------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi, pmbitmap, pmdev;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}
{$i ..\..\ch00\mrfromshort.pas}

var
  hab : cardinal;

var {static}
     bmp : BITMAPINFOHEADER2;
     fButton1Down, fButton2Down : boolean;
     hbm : HBITMAP ;
     hdcMemory : cardinal;
     hpsMemory : cardinal;
     ptlPointerPos: POINTL;
     aptl: array [0..3-1] of POINTL ;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;
var
     hpsWindow : HPS;
     cxFullScrn, cyFullScrn : integer;
     sizl : SIZEL ;

     xxunk1: DevOpenStruc;
     xxunk2: TBitmapInfo2;
     xxunk3: byte;
     
     done: boolean;

begin
     
     ClientWndProc:=nil;
     done:=true;
     
     case  (msg) of
          
          WM_CREATE: begin
               cxFullScrn := WinQuerySysValue (HWND_DESKTOP, SV_CXFULLSCREEN) ;
               cyFullScrn := WinQuerySysValue (HWND_DESKTOP, SV_CYFULLSCREEN) ;

                         // Create Memory DC and PS

               hdcMemory := DevOpenDC (hab, OD_MEMORY, '*', 0, xxunk1, 0) ;

               sizl.cx := 0 ;
               sizl.cy := 0 ;
               hpsMemory := GpiCreatePS (hab, hdcMemory, sizl,
					PU_PELS    or GPIF_DEFAULT or
                                        GPIT_MICRO or GPIA_ASSOC) ;

                         // Create monochrome bitmap, return 1 if cannot

               bmp.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               bmp.cx        := cxFullScrn ;
               bmp.cy        := cyFullScrn ;
               bmp.cPlanes   := 1 ;
               bmp.cBitCount := 1 ;

               hbm := GpiCreateBitmap (hpsMemory, bmp, 0, xxunk3, xxunk2) ;

               if (hbm = 0) then
                    begin
                    GpiDestroyPS (hpsMemory) ;
                    DevCloseDC (hdcMemory) ;
                    {return} MRFROMSHORT (1) ;
                    end;

                         // Set bitmap in memory PS and clear it

               GpiSetBitmap (hpsMemory, hbm) ;

               aptl[1].x := cxFullScrn ;
               aptl[1].y := cyFullScrn ;
               GpiBitBlt (hpsMemory, 0, 2, aptl[0], ROP_ZERO, BBO_OR) ;
             end;
               
          WM_BUTTON1DOWN: begin
               if (not fButton2Down) then
                    WinSetCapture (HWND_DESKTOP, Window) ;

               ptlPointerPos.x := MOUSEMSG(@msg).x ;
               ptlPointerPos.y := MOUSEMSG(@msg).y ;

               fButton1Down := TRUE ;
               {break} ;                    // do default processing
               done:=false;
             end;

          WM_BUTTON1UP: begin
               if (not fButton2Down) then
                    WinSetCapture (HWND_DESKTOP, 0) ;

               fButton1Down := FALSE ;
               
             end;
               
          WM_BUTTON2DOWN: begin
               if (not fButton1Down) then
                    WinSetCapture (HWND_DESKTOP, Window) ;

               ptlPointerPos.x := MOUSEMSG(@msg).x ;
               ptlPointerPos.y := MOUSEMSG(@msg).y ;

               fButton2Down := TRUE ;
               {break} ;                     // do default processing
               done:=false;
             end;

          WM_BUTTON2UP: begin
               if (not fButton1Down) then
                    WinSetCapture (HWND_DESKTOP, 0) ;

               fButton2Down := FALSE ;
             end;
               
          WM_MOUSEMOVE: begin
               if (fButton1Down or fButton2Down) then begin
               hpsWindow := WinGetPS (Window) ;

                if fButton1Down then
                 GpiSetColor (hpsMemory, CLR_TRUE ) 
               else
                 GpiSetColor (hpsMemory, CLR_FALSE) ;
                 
               if fButton1Down then
                 GpiSetColor (hpsWindow, CLR_NEUTRAL)
               else
                 GpiSetColor (hpsWindow, CLR_BACKGROUND);

               GpiMove (hpsMemory, ptlPointerPos) ;
               GpiMove (hpsWindow, ptlPointerPos) ;

               ptlPointerPos.x := MOUSEMSG(@msg).x ;
               ptlPointerPos.y := MOUSEMSG(@msg).y ;
               { FIX }
               WinQueryPointerPos (HWND_DESKTOP, ptlPointerPos) ;
               WinMapWindowPoints (HWND_DESKTOP, Window, ptlPointerPos,1) ;

               GpiLine (hpsMemory, ptlPointerPos) ;
               GpiLine (hpsWindow, ptlPointerPos) ;

               WinReleasePS (hpsWindow) ;
               {break} ;                      // do default processing
               done:=false;
               end; {if}
             end;

          WM_PAINT: begin
               hpsWindow := WinBeginPaint (Window, 0, @aptl[0]) ;

               aptl[2] := aptl[0] ;

               GpiBitBlt (hpsWindow, hpsMemory, 3, aptl[0], ROP_SRCCOPY,
                          BBO_OR) ;

               WinEndPaint (hpsWindow) ;
             end;
               
          WM_DESTROY: begin
               GpiDestroyPS (hpsMemory) ;
               DevCloseDC (hdcMemory) ;
               GpiDeleteBitmap (hbm) ;
             end;
              
          otherwise done:=false;
               
     end; {case}
          
     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Sketch' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

    if (hwndFrame = 0) then
          WinMessageBox (HWND_DESKTOP, HWND_DESKTOP,
                         'Not enough memory to create the '
                        + 'bitmap used for storing images.',
                         szClientClass, 0, MB_OK or MB_WARNING) 
     else
          begin
          while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
               WinDispatchMsg (hab, qmsg) ;

          WinDestroyWindow (hwndFrame) ;
          end;

  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

