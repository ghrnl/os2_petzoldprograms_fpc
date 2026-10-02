program blowup;

{/*---------------------------------------
   BLOWUP.C -- Screen Capture Program
               (c) Charles Petzold, 1993
  ---------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmbitmap, pmdev, doscalls;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}
{$i ..\..\ch00\winmenuitems.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i blowup_hdr.pas}

var
  szClientClass : Pchar = 'BlowUp' ;
var
  hab : cardinal;

procedure BitmapCreationError (hwnd: cardinal);
begin
     WinMessageBox (HWND_DESKTOP, hwnd, 'Cannot create bitmap.',
                    szClientClass, 0, MB_OK or MB_WARNING) ;
end; {BitmapCreationError}

function CopyBitmap (hbmSrc: HBITMAP): HBITMAP;
var
     bmp : BITMAPINFOHEADER2;
     hbmDst :HBITMAP ;
     hdcSrc, hdcDst : cardinal ;
     hpsSrc, hpsDst : cardinal ;
     aptl: array [0..3-1] of POINTL;
     sizl : SIZEL ;
     
     { extra }
     xxx1: DevOpenStruc;
     xxx3: Byte;
     xxx2: TBitmapInfo2;

begin
                                   // Create memory DC's and PS's

     hdcSrc := DevOpenDC (hab, OD_MEMORY, '*', 0, xxx1 {nil}, 0) ;
     hdcDst := DevOpenDC (hab, OD_MEMORY, '*', 0, xxx1 {nil}, 0) ;

     sizl.cx := 0 ;
     sizl.cy := 0 ;
     hpsSrc := GpiCreatePS (hab, hdcSrc, sizl, PU_PELS    or GPIF_DEFAULT or
                                               GPIT_MICRO or GPIA_ASSOC) ;

     hpsDst := GpiCreatePS (hab, hdcDst, sizl, PU_PELS   or GPIF_DEFAULT or
                                               GPIT_MICRO or GPIA_ASSOC) ;

                                   // Create bitmap

     bmp.cbFix := sizeof (BITMAPINFOHEADER2) ;
     GpiQueryBitmapInfoHeader (hbmSrc, bmp) ;
     hbmDst := GpiCreateBitmap (hpsDst, bmp, 0, xxx3 {nil}, xxx2 {nil}) ;

                                   // Copy from source to destination

     if (hbmDst <> 0) then
          begin
          GpiSetBitmap (hpsSrc, hbmSrc) ;
          GpiSetBitmap (hpsDst, hbmDst) ;

          aptl[0].x := 0 ;
          aptl[0].y := 0 ;
          aptl[1].x := bmp.cx ;
          aptl[1].y := bmp.cy ;
          aptl[2]   := aptl[0] ;

          GpiBitBlt (hpsDst, hpsSrc, 3, aptl[0], ROP_SRCCOPY, BBO_IGNORE) ;
          end;
                                   // Clean up
     GpiDestroyPS (hpsSrc) ;
     GpiDestroyPS (hpsDst) ;
     DevCloseDC (hdcSrc) ;
     DevCloseDC (hdcDst) ;

     CopyBitmap := hbmDst ;
     
end; {CopyBitmap}

function CopyScreenToBitmap (prclTrack: PRECTL): HBITMAP;

var
     bmp : BITMAPINFOHEADER2;
     hbm : HBITMAP;
     hdcMemory : cardinal ;
     hps, hpsMemory : cardinal ;
     alBmpFormats: array [0..2-1] of longint;
     aptl: array [0..3-1] of POINTL;
     sizl : SIZEL ;

     { extra }
     xxx1: DevOpenStruc;
     xxx3: Byte;
     xxx2: TBitmapInfo2;

begin

                                   // Create memory DC and PS

     hdcMemory := DevOpenDC (hab, OD_MEMORY, '*', 0, xxx1 {nil}, 0) ;

     sizl.cx := 0 ;
     sizl.cy := 0 ;
     hpsMemory := GpiCreatePS (hab, hdcMemory, sizl,
                              PU_PELS    or GPIF_DEFAULT or
                              GPIT_MICRO or GPIA_ASSOC) ;

                                   // Create bitmap for destination

     GpiQueryDeviceBitmapFormats (hpsMemory, 2, alBmpFormats[0]) ;

     {memset} fillbyte (bmp, sizeof (BITMAPINFOHEADER2), 0) ;

     bmp.cbFix     := sizeof (BITMAPINFOHEADER2) ;
     bmp.cx        := prclTrack^.xRight - prclTrack^.xLeft ;
     bmp.cy        := prclTrack^.yTop   - prclTrack^.yBottom ;
     bmp.cPlanes   := {(USHORT)} alBmpFormats[0] ;
     bmp.cBitCount := {(USHORT)} alBmpFormats[1] ;

     hbm := GpiCreateBitmap (hpsMemory, bmp, 0, xxx3 {nil}, xxx2 {nil}) ;

                                   // Copy from screen to bitmap
     if (hbm <> 0) then
          begin
          GpiSetBitmap (hpsMemory, hbm) ;
          hps := WinGetScreenPS (HWND_DESKTOP) ;

          aptl[0].x := 0 ;
          aptl[0].y := 0 ;
          aptl[1].x := bmp.cx ;
          aptl[1].y := bmp.cy ;
          aptl[2].x := prclTrack^.xLeft ;
          aptl[2].y := prclTrack^.yBottom ;

          WinLockVisRegions (HWND_DESKTOP, TRUE) ;

          GpiBitBlt (hpsMemory, hps, 3, aptl[0], ROP_SRCCOPY, BBO_IGNORE);

          WinLockVisRegions (HWND_DESKTOP, FALSE) ;

          WinReleasePS (hps) ;
          end;
                                   // Clean up
     GpiDestroyPS (hpsMemory) ;
     DevCloseDC (hdcMemory) ;

     CopyScreenToBitmap := hbm ;
end; {CopyScreenToBitmap}

function BeginTracking (prclTrack: PRECTL): boolean;

var
     cxScreen, cyScreen, cxPointer, cyPointer : integer;
     ti : TRACKINFO;


begin

     cxScreen  := WinQuerySysValue (HWND_DESKTOP, SV_CXSCREEN) ;
     cyScreen  := WinQuerySysValue (HWND_DESKTOP, SV_CYSCREEN) ;
     cxPointer := WinQuerySysValue (HWND_DESKTOP, SV_CXPOINTER) ;
     cyPointer := WinQuerySysValue (HWND_DESKTOP, SV_CYPOINTER) ;

                                   // Set up track rectangle for moving

     ti.cxBorder := 1 ;                       // Border width
     ti.cyBorder := 1 ;
     ti.cxGrid := 0 ;                         // Not used
     ti.cyGrid := 0 ;
     ti.cxKeyboard := 4 ;                     // Pixel increment for keyboard
     ti.cyKeyboard := 4 ;

     ti.rclBoundary.xLeft   := 0 ;            // Area for tracking rectangle
     ti.rclBoundary.yBottom := 0 ;
     ti.rclBoundary.xRight  := cxScreen ;
     ti.rclBoundary.yTop    := cyScreen ;

     ti.ptlMinTrackSize.x := 1 ;              // Minimum rectangle size
     ti.ptlMinTrackSize.y := 1 ;

     ti.ptlMaxTrackSize.x := cxScreen ;       // Maximum rectangle size
     ti.ptlMaxTrackSize.y := cyScreen ;
                                             // Initial position

     ti.rclTrack.xLeft   := (cxScreen - cxPointer) div 2 ;
     ti.rclTrack.yBottom := (cyScreen - cyPointer) div 2 ;
     ti.rclTrack.xRight  := (cxScreen + cxPointer) div 2 ;
     ti.rclTrack.yTop    := (cyScreen + cyPointer) div 2 ;

     ti.fs := TF_MOVE or TF_STANDARD or TF_SETPOINTERPOS ;     // Flags

     if (not WinTrackRect (HWND_DESKTOP, 0, ti)) then
          exit(FALSE) ;
                                   // Switch to "sizing" pointer
     WinSetPointer (HWND_DESKTOP,
               WinQuerySysPointer (HWND_DESKTOP, SPTR_SIZENESW, FALSE)) ;

                                   // Track rectangle for sizing

     ti.fs := TF_RIGHT or TF_TOP or TF_STANDARD or TF_SETPOINTERPOS ;

     if (not WinTrackRect (HWND_DESKTOP, 0, ti)) then
          exit(FALSE) ;

     prclTrack^ := ti.rclTrack ;    // Final rectangle

     BeginTracking := TRUE ;
end; {BeginTracking}


var
     hbm : HBITMAP;
     hwndMenu : cardinal ;
     iDisplay : integer = IDM_ACTUAL ;

function  ClientWndProc (Window, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;
var
     bEnable : boolean ;
     hbmClip : HBITMAP;
     hps : cardinal ;
     rclTrack, rclClient : RECTL;
     ulfInfo : ULONG;

begin

     case (msg) of
          
          WM_CREATE: begin
               hwndMenu := WinWindowFromID (
                               WinQueryWindow (Window, QW_PARENT),
                               FID_MENU) ;
               {return 0 ;}
               end;

          WM_INITMENU: begin
               case (SHORT1FROMMP (mp1)) of
                    
                    IDM_EDIT: begin
                         bEnable := (hbm <> 0); { ? TRUE : FALSE) ;}

                         WinEnableMenuItem (hwndMenu, IDM_CUT,   bEnable) ;
                         WinEnableMenuItem (hwndMenu, IDM_COPY,  bEnable) ;
                         WinEnableMenuItem (hwndMenu, IDM_CLEAR, bEnable) ;
                         WinEnableMenuItem (hwndMenu, IDM_PASTE,
                              WinQueryClipbrdFmtInfo (hab, CF_BITMAP,
                                                      ulfInfo)) ;
                         {return 0 ;}
                         end;
                    end;
               {break ;}
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_CUT: begin
                         if (hbm <> 0) then
                              begin
                              WinOpenClipbrd (hab) ;
                              WinEmptyClipbrd (hab) ;
                              WinSetClipbrdData (hab, {(ULONG)} hbm,
                                                 CF_BITMAP, CFI_HANDLE) ;
                              WinCloseClipbrd (hab) ;
                              hbm := 0 ;
                              WinInvalidateRect (Window, nil, FALSE) ;
                              end;
                         {return 0 ;}
                         end;

                    IDM_COPY: begin
                                        // Make copy of stored bitmap

                         hbmClip := CopyBitmap (hbm) ;

                                        // Set clipboard data to copy of bitmap

                         if (hbmClip <> 0) then
                              begin
                              WinOpenClipbrd (hab) ;
                              WinEmptyClipbrd (hab) ;
                              WinSetClipbrdData (hab, {(ULONG)} hbmClip,
                                                 CF_BITMAP, CFI_HANDLE) ;
                              WinCloseClipbrd (hab) ;
                              end
                         else
                              BitmapCreationError (Window) ;
                         {return 0 ;}
                         end;

                    IDM_PASTE: begin
                                         // Get bitmap from clipboard

                         WinOpenClipbrd (hab) ;
                         hbmClip := {(HBITMAP)} WinQueryClipbrdData (hab,
                                                                  CF_BITMAP) ;
                         if (hbmClip <> 0) then
                              begin
                              if (hbm <> 0) then
                                   GpiDeleteBitmap (hbm) ;

                                        // Make copy of clipboard bitmap

                              hbm := CopyBitmap (hbmClip) ;

                              if (hbm = 0) then
                                   BitmapCreationError (Window) ;
                              end;
                         WinCloseClipbrd (hab) ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                         {return 0 ;}
                         end;

                    IDM_CLEAR: begin
                         if (hbm <> 0) then
                              begin
                              GpiDeleteBitmap (hbm) ;
                              hbm := 0 ;
                              WinInvalidateRect (Window, nil, FALSE) ;
                              end;
                         {return 0 ;}
                         end;

                    IDM_CAPTURE: begin
                         if (BeginTracking (@rclTrack)) then
                              begin
                              if (hbm <> 0) then
                                   GpiDeleteBitmap (hbm) ;

                              hbm := CopyScreenToBitmap (@rclTrack) ;

                              if (hbm = 0) then
                                   BitmapCreationError (Window) ;

                              WinInvalidateRect (Window, nil, FALSE) ;
                              end;
                         {return 0 ;}
                         end;

                    IDM_ACTUAL,
                    IDM_STRETCH: begin
                         WinCheckMenuItem (hwndMenu, iDisplay, FALSE) ;

                         iDisplay := SHORT1FROMMP(mp1) ;

                         WinCheckMenuItem (hwndMenu, iDisplay, TRUE) ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                         {return 0 ;}
                         end;
                    end;
               {break ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               if (hbm <> 0) then
                    begin
                    WinQueryWindowRect (Window, rclClient) ;

                    if iDisplay = IDM_STRETCH then
                      WinDrawBitmap (hps, hbm, nil, PPOINTL(@rclClient),
                                   CLR_NEUTRAL, CLR_BACKGROUND,
                                   DBM_STRETCH)
                                        else
                       WinDrawBitmap (hps, hbm, nil, PPOINTL(@rclClient),
                                   CLR_NEUTRAL, CLR_BACKGROUND,
                                   DBM_NORMAL)


                    end;
               WinEndPaint (hps) ;
               {return 0 ;} end;

          WM_DESTROY: begin
               if (hbm <> 0)  then
                    GpiDeleteBitmap (hbm) ;
               {return 0 ;} end;
     
     end; {case}
     
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

var
  hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;

begin

    flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                   or FCF_SIZEBORDER    or FCF_MINMAX
                   or FCF_SHELLPOSITION or FCF_TASKLIST
                   or FCF_MENU          or FCF_ACCELTABLE ;
                 
     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, ID_RESOURCE, hwndClient) ;

     while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
          WinDispatchMsg (hab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
     
end.

