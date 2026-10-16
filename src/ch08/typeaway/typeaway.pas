program typeaway;

{/*-----------------------------------------
   TYPEAWAY.C -- Typing Program
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi, pmdev,strings;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch05\easyfont\easyfont.pas}

{ from easyfont.h }

const
  FONTFACE_SYSTEM = 0;
  FONTFACE_MONO   = 1;
  FONTFACE_COUR   = 2;
  FONTFACE_HELV   = 3;
  FONTFACE_TIMES  = 4;

  FONTSIZE_8     =  0;
  FONTSIZE_10    =  1;
  FONTSIZE_12    =  2;
  FONTSIZE_14    =  3;
  FONTSIZE_18    =  4;
  FONTSIZE_24    =  5;


const
   LCID_FIXEDFONT = 1;

const
   szClientClass = 'TypeAway' ;

var
  HAB: cardinal;

procedure GetCharXY (hps: cardinal; var pcxChar, pcyChar, pcyDesc: integer);
{ note the var }
var
   fm: FONTMETRICS;

begin
     GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
     {*} pcxChar := fm.lAveCharWidth ;
     {*} pcyChar := fm.lMaxBaselineExt ;
     {*} pcyDesc := fm.lMaxDescender ;
end; {GetCharXY}


var
     fInsertMode: boolean = FALSE ;
     pBuffer : Pchar;
     cxClient, cyClient, cxChar, cyChar, cyDesc,
                  xCursor, yCursor, xMax,  yMax : integer;
                  
var
     fProcessed : boolean;
     szBuffer: Pchar;
     hps : cardinal;
     iRep, i : integer;
     ptl : POINTL ;
     rcl : RECTL ;
     
function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

function BUFFER(x,y: integer): Pchar;
begin
  BUFFER := pBuffer + y * xMax + x
end;

var     
     {extra}
     done: boolean;
     
begin

     ClientWindowProc:=nil;
     done:=true;
     
     case (msg) of
          
          WM_CREATE: begin
               hps := WinGetPS (Window) ;
               EzfQueryFonts (hps) ;

               if (not EzfCreateLogFont (hps, LCID_FIXEDFONT, FONTFACE_MONO,
                                                           FONTSIZE_10, 0))>0 then
                    begin
                    WinReleasePS (hps) ;

                    WinMessageBox (HWND_DESKTOP, HWND_DESKTOP,
                         'Cannot find the System Monospaced font.',
                         szClientClass, 0, MB_OK or MB_WARNING) ;

                    ClientWindowProc := MRFROMSHORT (1) ;
               end
               
               else begin

               GpiSetCharSet (hps, LCID_FIXEDFONT) ;

               GetCharXY (hps, cxChar, cyChar, cyDesc) ;

               GpiSetCharSet (hps, LCID_DEFAULT) ;
               GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
               WinReleasePS (hps) ;
               
               end;
               end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;

               xMax := cxClient div cxChar ;
               yMax := cyClient div cyChar - 2 ;

               if (pBuffer <> nil) then
                    freemem (pBuffer) ;

               pBuffer := getmem (xMax * yMax + 1);
               if (nil = pBuffer) then
                    begin
                    WinMessageBox (HWND_DESKTOP, Window,
                         'Cannot allocate memory for text buffer.\n'
                       + 'Try a smaller window.', szClientClass, 0,
                         MB_OK or MB_WARNING) ;

                    xMax := 0 ;
                    yMax := 0 ;
               end
               else
                    begin                    
                    for i := 0 to xMax * yMax-0*1 do
                         BUFFER (i, 0)^ := ' ' ;

                    xCursor := 0 ;
                    yCursor := 0 ;
               end;

               if (Window = WinQueryFocus (HWND_DESKTOP)) then
                    begin
                    WinDestroyCursor (Window) ;

                    WinCreateCursor (Window, 0, cyClient - cyChar,
                                     cxChar, cyChar,
                                     CURSOR_SOLID or CURSOR_FLASH, nil) ;

                    WinShowCursor (Window, (xMax > 0) and (yMax > 0)) ;
               end;
               end;

          WM_SETFOCUS: begin
               if (SHORT1FROMMP (mp2))>0 then
                    begin
                    WinCreateCursor (Window, cxChar * xCursor,
                                     cyClient - cyChar * (1 + yCursor),
                                     cxChar, cyChar,
                                     CURSOR_SOLID or CURSOR_FLASH, nil) ;

                    WinShowCursor (Window, (xMax > 0) and (yMax > 0)) ;
               end
               else
                    WinDestroyCursor (Window) ;
               end;

          WM_CHAR: begin
               if (xMax = 0 ) or ( yMax = 0) then
                    {return 0 ;} 
               else begin

               if ((CHARMSG(@msg).fs) and (KC_KEYUP))>0 then
                    {return 0 ;}
               else begin

               if ((CHARMSG(@msg).fs) and (KC_INVALIDCHAR))>0 then
                    {return 0 ;} 
               else begin

               if ((CHARMSG(@msg).fs) and (KC_INVALIDCOMP))>0 then
                    begin
                    xCursor := (xCursor + 1) mod xMax ;        // Advance cursor
                    if (xCursor = 0) then
                         yCursor := (yCursor + 1) mod yMax ;

                    WinAlarm (HWND_DESKTOP, WA_ERROR) ;     // And beep
               end;

               for iRep := 0  to (CHARMSG(@msg).cRepeat-1) do
                    begin
                    fProcessed := FALSE ;

                    ptl.x := xCursor * cxChar ;
                    ptl.y := cyClient - cyChar * (yCursor + 1) + cyDesc ;

                              {/*---------------------------
                                 Process some virtual keys
                                ---------------------------*/}

                    if (CHARMSG(@msg).fs and  KC_VIRTUALKEY)>0 then
                         begin
                         fProcessed := TRUE ;

                         case (CHARMSG(@msg).vkey) of
                              
                                       { /*---------------
                                           Backspace key
                                          ---------------*/}

                              VK_BACKSPACE: begin
                                   if (xCursor > 0) then begin
                                        WinSendMsg (Window, WM_CHAR,
                                             MPFROM2SHORT (KC_VIRTUALKEY, 1),
                                             MPFROM2SHORT (0, VK_LEFT)) ;

                                        WinSendMsg (Window, WM_CHAR,
                                             MPFROM2SHORT (KC_VIRTUALKEY, 1),
                                             MPFROM2SHORT (0, VK_DELETE)) ;
                                   end;
                                   
                                   end;

                                        {/*---------
                                           Tab key
                                          ---------*/}

                              VK_TAB: begin
                                   i := min (8 - xCursor mod 8, xMax - xCursor) ;

                                   WinSendMsg (Window, WM_CHAR, 
                                        MPFROM2SHORT (KC_CHAR, i),
                                        MPFROM2SHORT ( {(USHORT)} ord(' '), 0)) ;
                                   
                                   end;

                                        {/*-------------------------
                                           Backtab (Shift-Tab) key
                                          -------------------------*/}

                              VK_BACKTAB: begin
                                   if (xCursor > 0) then begin
                                        i := (xCursor - 1) mod 8 + 1 ;

                                        WinSendMsg (Window, WM_CHAR,
                                             MPFROM2SHORT (KC_VIRTUALKEY, i),
                                             MPFROM2SHORT (0, VK_LEFT)) ;
                                   end;
                                   
                                   end;

                                        {/*------------------------
                                           Newline and Enter keys
                                          ------------------------*/}

                              VK_NEWLINE,
                              VK_ENTER: begin
                                   xCursor := 0 ;
                                   yCursor := (yCursor + 1) mod yMax ;
                                   
                                   end;

                              otherwise begin
                                   fProcessed := FALSE ;
                                   
                                   end;
                         end; {inner case}
                    end; {for}

                              {/*------------------------
                                 Process character keys
                                ------------------------*/}

                    if (not fProcessed) and 
                         ( (CHARMSG(@msg).fs and KC_CHAR)
                        or (CHARMSG(@msg).fs and KC_DEADKEY)>0) then
                         begin
                                                  // Shift line if fInsertMode
                         if (fInsertMode) then
                              {for i := xMax - 1 ; i > xCursor ; i--)}
                              for i := xMax - 1 downto xCursor+1 do
                                   BUFFER (i, yCursor)^ :=
                                        BUFFER (i - 1, yCursor)^ ;

                                                  // Store character in buffer

                         BUFFER (xCursor, yCursor)^ :=
                                  char(CHARMSG(@msg).chr mod 256) ;

                                                  // Display char or new line

                         WinShowCursor (Window, FALSE) ;
                         hps := WinGetPS (Window) ;

                         EzfCreateLogFont (hps, LCID_FIXEDFONT,
                                           FONTFACE_MONO, FONTSIZE_10, 0) ;
                         GpiSetCharSet (hps, LCID_FIXEDFONT) ;
                         GpiSetBackMix (hps, BM_OVERPAINT) ;

                         if (fInsertMode) then
                              GpiCharStringAt (hps, ptl,
                                               {(LONG)} (xMax - xCursor),
                                               BUFFER (xCursor, yCursor))
                         else begin
                              GpiCharStringAt (hps, ptl, 1,
                                               Pchar(@BUFFER (xCursor, yCursor)^) ) ;
                         end;

                         GpiSetCharSet (hps, LCID_DEFAULT) ;
                         GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
                         WinReleasePS (hps) ;
                         WinShowCursor (Window, TRUE) ;

                                                  // Increment cursor

                         if (not (CHARMSG(@msg).fs) and (KC_DEADKEY))>0 then
                         begin
                              xCursor := (xCursor + 1) mod xMax;
                              if (0 = xCursor) then
                                   yCursor := (yCursor + 1) mod yMax ;
                         end;

                         fProcessed := TRUE ;
                    end;

                              {/*--------------------------------
                                 Process remaining virtual keys
                                --------------------------------*/}
                    
                    if ((not fProcessed) and
                       ((CHARMSG(@msg).fs and KC_VIRTUALKEY)>0)) then
                         begin
                         fProcessed := TRUE ;

                         case (CHARMSG(@msg).vkey) of
                              
                                        {/*----------------------
                                           Cursor movement keys
                                          ----------------------*/}

                              VK_LEFT: begin
                                   xCursor := (xCursor - 1 + xMax) mod xMax ;

                                   if (xCursor = xMax - 1) then
                                        yCursor := (yCursor - 1 + yMax) mod yMax ;
                                   end;

                              VK_RIGHT: begin
                                   xCursor := (xCursor + 1) mod xMax ;

                                   if (xCursor = 0) then
                                        yCursor := (yCursor + 1) mod yMax ;
                                   end;

                              VK_UP: begin
                                   yCursor := max (yCursor - 1, 0) ;
                                   end;

                              VK_DOWN: begin
                                   yCursor := min (yCursor + 1, yMax - 1) ;
                                   end;

			      VK_PAGEUP: begin
                                   yCursor := 0 ;
                                   end;

			      VK_PAGEDOWN: begin
                                   yCursor := yMax - 1 ;
                                   end;

                              VK_HOME: begin
                                   xCursor := 0 ;
                                   end;

                              VK_END: begin
                                   xCursor := xMax - 1 ;
                                   end;

                                        {/*------------
                                           Insert key
                                          ------------*/}

                              VK_INSERT: begin {GRE: assume toggle, what else }
                                   fInsertMode:=not(fInsertMode);
                                   WinSetRect (hab, rcl, 0, 0,
                                               cxClient, cyChar) ;
                                   WinInvalidateRect (Window, @rcl, FALSE) ;
                                   end;

                                        {/*------------
                                           Delete key
                                          ------------*/}

			      VK_DELETE: begin
                                   for i := xCursor to xMax - 2 do
                                        BUFFER (i, yCursor)^ :=
                                             BUFFER (i + 1, yCursor)^ ;

                                   BUFFER (xMax, yCursor)^ := ' ' ;

                                   WinShowCursor (Window, FALSE) ;
                                   hps := WinGetPS (Window) ;
                                   EzfCreateLogFont (hps, LCID_FIXEDFONT,
                                             FONTFACE_MONO, FONTSIZE_10, 0) ;
                                   GpiSetCharSet (hps, LCID_FIXEDFONT) ;
                                   GpiSetBackMix (hps, BM_OVERPAINT) ;

                                   GpiCharStringAt (hps, ptl,
                                             {(LONG)} (xMax - xCursor), 
                                             BUFFER (xCursor, yCursor)) ;

                                   GpiSetCharSet (hps, LCID_DEFAULT) ;
                                   GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
                                   WinReleasePS (hps) ;
                                   WinShowCursor (Window, TRUE) ;
                                   end;

                              otherwise begin
                                   fProcessed := FALSE ;
                                   end;
                         end; {inner case CHARMSG}
                    end;
               end;
               WinCreateCursor (Window, cxChar * xCursor,
                                      cyClient - cyChar * (1 + yCursor),
                                      0, 0, CURSOR_SETPOS, nil) ;
               end;
               end;
               end;
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;
               EzfCreateLogFont (hps, LCID_FIXEDFONT, FONTFACE_MONO,
                                                      FONTSIZE_10, 0) ;
               GpiSetCharSet (hps, LCID_FIXEDFONT) ;

               ptl.x := cxChar ;
               ptl.y := cyDesc ;
               if fInsertMode then
                 szBuffer := 'Insert Mode: ON'
               else
                 szBuffer := 'Insert Mode: OFF';
               GpiCharStringAt (hps, ptl,
                                {(LONG)} strlen(szBuffer),
                                szBuffer) ;

               ptl.x := 0 ;
               ptl.y := 3 * cyChar div 2 ;
               GpiMove (hps, ptl) ;

               ptl.x := cxClient ;
               GpiLine (hps, ptl) ;

               if (xMax > 0 ) and ( yMax > 0) then
                    begin
                    for i := 0  to yMax-1 do
                         begin
                         ptl.x := 0 ;
                         ptl.y := cyClient - cyChar * (i + 1) + cyDesc ;

                         GpiCharStringAt (hps, ptl, {(LONG)} xMax,
                                                     BUFFER (0, i)) ;
                    end;
               end;
               GpiSetCharSet (hps, LCID_DEFAULT) ;
               GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
               WinEndPaint (hps) ;
               end;

          WM_DESTROY: begin
               if (pBuffer <> nil) then
                    freemem (pBuffer) ;
               
               end;
          otherwise done :=false;
     end; {case}
     
     if not done then ClientWindowProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;

begin

  flFrameFlags :=    FCF_TITLEBAR or FCF_SYSMENU
                  or FCF_SIZEBORDER or FCF_MINMAX
                  or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWindowProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  if (hwndFrame <> 0) then begin {!!! deviating}
    while WinGetMsg (hab, qmsg, 0, 0, 0) do
      WinDispatchMsg (hab, qmsg) ;

    WinDestroyWindow (hwndFrame) ;
  end;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

