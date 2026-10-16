program colorscr;

{/*--------------------------------------------------------
   COLORSCR.C -- Color Scroll using child window controls
                 (c) Charles Petzold, 1993
  --------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\maxmin.pas}

var
  hwndScroll : array [0..3-1] of cardinal;
  hwndFocus : cardinal;
  pfnOldScroll: array [0..3-1] of proc;

function ScrollProc (h_wnd: cardinal; msg: cardinal; mp1: pointer; mp2: pointer):pointer;
              cdecl; export;
var
  id: integer;
{ extra }
  done: boolean;

begin
     ScrollProc:=nil;
     done:=not true;

     id := WinQueryWindowUShort (h_wnd, QWS_ID) ;   // ID of scroll bar

     case (msg) of
          
          WM_CHAR: begin
               if (not(CHARMSG(@msg).fs and KC_VIRTUALKEY))>0  then
                   ;

               case (CHARMSG(@msg).vkey) of
                    
                    VK_TAB: begin
                         if (not(CHARMSG(@msg).fs and KC_KEYUP))>0 then
                              begin
                              hwndFocus := hwndScroll[(id + 1) mod 3] ;
                              WinSetFocus (HWND_DESKTOP, hwndFocus) ;
                              end;
                         ScrollProc := MRFROMSHORT (1) ;
                       end;

                    VK_BACKTAB: begin
                         if (not(CHARMSG(@msg).fs and KC_KEYUP))>0 then
                              begin
                              hwndFocus := hwndScroll[(id + 2) mod 3] ;
                              WinSetFocus (HWND_DESKTOP, hwndFocus) ;
                              end;
                         ScrollProc := MRFROMSHORT (1) ;
                        end;

                    otherwise done:=false;
               end; {inner case}
             end;

          WM_BUTTON1DOWN: begin
               hwndFocus := h_wnd;
               WinSetFocus (HWND_DESKTOP, hwndFocus) ;
             end;
             
          otherwise done:=false;
          
     end; {case}
          
     if not done then ScrollProc := pfnOldScroll[id] (h_wnd, msg, mp1, mp2);
          
end; {ScrollProc}

var
     apchColorLable: array[0..3-1] of Pchar = ('Red', 'Green', 'Blue');
     hwndLabel, hwndValue : array [0..3-1] of HWND;
     cyChar: integer;
     iColor: array [0..3-1] of integer ;
     alColorIndex: array [0..3-1] of LONGint = (CLR_RED, CLR_GREEN, CLR_BLUE);
     rclRightHalf : RECTL;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     szBuffer: array[0..10-1] of char ;
     fm: FONTMETRICS ;
     h_ps : HPS ;
     i, id, cxClient, cyClient : integer;

{ extra }
     dummyNIL: longint;
     done: boolean;

begin

     dummyNIL:=0;
     ClientWindowProc:=nil;
     done:=true;

     case (msg) of
          
          WM_CREATE : begin
               h_ps := WinGetPS (Window) ;
               GpiQueryFontMetrics (h_ps, sizeof(fm), fm) ;
               cyChar := fm.lMaxBaselineExt ;
               WinReleasePS (h_ps) ;

               for  i := 0  to 3-1 do
                    begin
                    hwndScroll[i] := WinCreateWindow (
                                        Window,              // Parent
                                        WC_SCROLLBAR,        // Class
                                        nil,                 // Text
                                        WS_VISIBLE or        // Style
                                             SBS_VERT,
                                        0, 0,               // Position
                                        0, 0,               // Size
                                        Window,             // Owner
                                        HWND_BOTTOM,        // Placement
                                        i,                  // ID
                                        nil,                // Ctrl Data
                                        nil) ;              // Pres Params

                    hwndLabel[i]  := WinCreateWindow (
                                        Window,             // Parent
                                        WC_STATIC,          // Class
                                        apchColorLable[i],  // Text
                                        WS_VISIBLE or       // Style
                                          SS_TEXT or DT_CENTER,
                                        0, 0,               // Position
                                        0, 0,               // Size
                                        Window,             // Owner
                                        HWND_BOTTOM,        // Placement
                                        i + 3,              // ID
                                        nil,                // Ctrl Data
                                        nil) ;              // Pres Params

                    hwndValue[i]  := WinCreateWindow (
                                        Window,             // Parent
                                        WC_STATIC,          // Class
                                        '0',                // Text
                                        WS_VISIBLE or       // Style
                                          SS_TEXT or DT_CENTER,
                                        0, 0,               // Position
                                        0, 0,               // Size
                                        Window,             // Owner
                                        HWND_BOTTOM,        // Placement
                                        i + 6,              // ID
                                        nil,                // Ctrl Data
                                        nil) ;              // Pres Params

                    pfnOldScroll[i] :=
                              WinSubclassWindow (hwndScroll[i], @ScrollProc) ;

                    WinSetPresParam (hwndScroll [i], PP_FOREGROUNDCOLORINDEX,
                                     sizeof (LONGint), @alColorIndex[+ i]) ;

                    WinSendMsg (hwndScroll[i], SBM_SETSCROLLBAR,
				MPFROM2SHORT (0, 0), MPFROM2SHORT (0, 255)) ;
                    end;
              end;

          WM_SIZE : begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;

               for i := 0  to 3-1 do
                    begin
                    WinSetWindowPos (hwndScroll[i], 0,
                                     (2 * i + 1) * cxClient div 14, 2 * cyChar,
                                     cxClient div 14, cyClient - 4 * cyChar,
                                     SWP_SIZE or SWP_MOVE) ;

                    WinSetWindowPos (hwndLabel[i], 0,
                                     (4 * i + 1) * cxClient div 28,
                                     cyClient - 3 * cyChar div 2,
                                     cxClient div 7, cyChar,
                                     SWP_SIZE or SWP_MOVE) ;

                    WinSetWindowPos (hwndValue[i], 0,
                                     (4 * i + 1) * cxClient div 28, cyChar div 2,
                                     cxClient div 7, cyChar,
                                     SWP_SIZE or SWP_MOVE) ;
                    end;

               WinQueryWindowRect (Window, rclRightHalf) ;
               rclRightHalf.xLeft := rclRightHalf.xRight div 2 ;
             end;

          WM_VSCROLL : begin
               id := SHORT1FROMMP (mp1) ;          // ID of scroll bar

               case (SHORT2FROMMP (mp2)) of
                    
                    SB_LINEDOWN : begin
                         iColor[id] := min (255, iColor[id] + 1) ;
                         end;

                    SB_LINEUP : begin
                         iColor[id] := max (0, iColor[id] - 1) ;
                         end;

                    SB_PAGEDOWN : begin
                         iColor[id] := min (255, iColor[id] + 16) ;
                         end;

                    SB_PAGEUP : begin
                         iColor[id] := max (0, iColor[id] - 16) ;
                         end;

                    SB_SLIDERTRACK : begin
                         iColor[id] := SHORT1FROMMP (mp2) ;
                         end;

                    otherwise 
                        done:=false;
                    end; {inner case}
                    
               WinSendMsg (hwndScroll[id], SBM_SETPOS,
                           MPFROM2SHORT (iColor[id], 0), nil) ;

               szBuffer:= format('%d', [iColor[id]]);
               WinSetWindowText (hwndValue[id], szBuffer) ;
               WinInvalidateRect (Window, rclRightHalf, FALSE) ;
             end;

          WM_PAINT: begin
               h_ps := WinBeginPaint (Window, 0, nil) ;

               GpiCreateLogColorTable (h_ps, LCOL_RESET, LCOLF_RGB,
                                            0, 0,  dummyNIL) ;

               WinFillRect (h_ps, rclRightHalf, cardinal (iColor[0] shl 16) or
                                               cardinal (iColor[1] shl 8) or
                                               cardinal (iColor[2])) ;
               WinEndPaint (h_ps) ;
             end;

          WM_ERASEBACKGROUND: begin
               ClientWindowProc := MRFROMSHORT (1) ;
          end;
          
          otherwise done:=false;
          
          end; {case}
          
     if not done then ClientWindowProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'ColorScr';

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

  hwndFocus := hwndScroll[0];
  WinSetFocus (HWND_DESKTOP, hwndFocus) ;


  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

