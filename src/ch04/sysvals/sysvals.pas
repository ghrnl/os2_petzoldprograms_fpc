program sysvalsf;

{/*--------------------------------------------
   SYSVALS.C -- System Values Display Program
                (c) Charles Petzold, 1993
  --------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\sysvalshdr.pas}
{$i ..\..\ch00\maxmin.pas}

var
  cxChar, cxCaps, cyChar, cyDesc, cyClient : integer;
  fm:FONTMETRICS ;
  hwndVscroll: cardinal;
  iVscrollPos: integer;

function RtJustCharStringAt (hps: cardinal; pptl: PPOINTL; lLength: longint; pchText: pchar): longint;
var
  aptlTextBox: array[0..TXTBOX_COUNT-1] of POINTL;
begin
      GpiQueryTextBox (hps, lLength, pchText, TXTBOX_COUNT, aptlTextBox[0]) ;
      pptl^.x := pptl^.x - aptlTextBox[TXTBOX_CONCAT].x ;
      RtJustCharStringAt :=  GpiCharStringAt (hps, pptl^, lLength, pchText) ;
end;  {RtJustCharStringAt}

var
  hwndHscroll: cardinal;
  iHscrollMax, iVscrollMax, iHscrollPos, cxClient, cxTextTotal : integer;
  fUpdate : boolean ;
  szBuffer : Pchar;
  hps : cardinal;
  iLine, iPaintBeg, iPaintEnd, iHscrollInc, iVscrollInc : integer ;
  ptl : POINTL;
  rclInvalid: RECTL;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

begin
  ClientWindowProc := nil;

  case msg of
         WM_CREATE: begin
               hps := WinGetPS (Window) ;
               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;

               cxChar := fm.lAveCharWidth ;
               if (fm.fsType mod 2 = 1) then
                  cxCaps := (2 * cxChar) div 2
               else
                  cxCaps := (3 * cxChar) div 2 ;
               cyChar := fm.lMaxBaselineExt;
               cyDesc := fm.lMaxDescender ;

               WinReleasePS (hps) ;

               cxTextTotal := 32 * cxCaps + 38 * cxChar ;

               hwndHscroll := WinWindowFromID (
                                   WinQueryWindow (window, QW_PARENT),
                                   FID_HORZSCROLL) ;

               hwndVscroll := WinWindowFromID (
                                   WinQueryWindow (Window, QW_PARENT),
                                   FID_VERTSCROLL) ;
             end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;

               iHscrollMax := max (0, cxTextTotal - cxClient) ;
               iHscrollPos := min (iHscrollPos, iHscrollMax) ;

               WinSendMsg (hwndHscroll, SBM_SETSCROLLBAR,
                                        MPFROM2SHORT (iHscrollPos, 0),
                                        MPFROM2SHORT (0, iHscrollMax)) ;

               WinSendMsg (hwndHscroll, SBM_SETTHUMBSIZE,
                                        MPFROM2SHORT (cxClient, cxTextTotal),
                                        nil) ;

               WinEnableWindow (hwndHscroll,iHscrollMax>0) ;

               iVscrollMax := max (0, NUMLINES - cyClient div cyChar) ;
               iVscrollPos := min (iVscrollPos, iVscrollMax) ;

               WinSendMsg (hwndVscroll, SBM_SETSCROLLBAR,
                                        MPFROM2SHORT (iVscrollPos, 0),
                                        MPFROM2SHORT (0, iVscrollMax)) ;

               WinSendMsg (hwndVscroll, SBM_SETTHUMBSIZE,
                                        MPFROM2SHORT (cyClient div cyChar,
                                                      NUMLINES),
                                        nil) ;

               WinEnableWindow (hwndVscroll,iVscrollMax>0) ;

            end;

          WM_HSCROLL: begin
               case SHORT2FROMMP (mp2) of
                    
                    SB_LINELEFT: begin
                         iHscrollInc := iHscrollInc - cxCaps ;
                         end;

                    SB_LINERIGHT: begin
                         iHscrollInc := cxCaps ;
                         end;

                    SB_PAGELEFT: begin
                         iHscrollInc := -8 * cxCaps ;
                         end;

                    SB_PAGERIGHT: begin
                         iHscrollInc := 8 * cxCaps ;
                         end;

                    SB_SLIDERPOSITION: begin
                         iHscrollInc := SHORT1FROMMP (mp2) - iHscrollPos;
                         end;

                    else begin {default:}
                         iHscrollInc := 0 ;
                         end;
                    end; {case}
               iHscrollInc := max (-iHscrollPos,
                             min (iHscrollInc, iHscrollMax - iHscrollPos)) ;

               if (iHscrollInc <> 0) then
                    begin
                    iHscrollPos := iHscrollPos + iHscrollInc ;
                    WinScrollWindow (window, -iHscrollInc, 0,
                                      nil, nil, 0, nil,
                                     SW_INVALIDATERGN) ;

                    WinSendMsg (hwndHscroll, SBM_SETPOS,
                                MPFROMSHORT (iHscrollPos), nil) ;
                    end;
                 end;

         WM_VSCROLL: begin
               fUpdate:=true;
               case SHORT2FROMMP (mp2) of
                    
                     SB_LINEUP: begin
                         iVscrollInc := -1 ;
                       end;

                     SB_LINEDOWN: begin
                         iVscrollInc := 1 ;
                       end;

                     SB_PAGEUP: begin
                         iVscrollInc := min (-1, -cyClient div cyChar) ;
                       end;

                     SB_PAGEDOWN: begin
                         iVscrollInc := max (1, cyClient div cyChar) ;
                       end;

                     SB_SLIDERTRACK: begin
                         fUpdate := FALSE ;
                         iVscrollInc := SHORT1FROMMP (mp2) - iVscrollPos;
                       end;

                    SB_SLIDERPOSITION: begin
                         iVscrollInc := SHORT1FROMMP (mp2) - iVscrollPos;
                       end;

                    else begin
                         fUpdate := FALSE ;
                         iVscrollInc := 0 ;
                         end;
                    end;

               iVscrollInc := max (-iVscrollPos,
                             min (iVscrollInc, iVscrollMax - iVscrollPos)) ;

               if (iVscrollInc <> 0) then
                    begin
                    iVscrollPos := iVscrollPos  + iVscrollInc ;
                    WinScrollWindow (window, 0, cyChar * iVscrollInc,
                                     nil, nil, 0, nil,
                                     SW_INVALIDATERGN) ;

                    WinUpdateWindow (window) ;
                    end;

               if fUpdate then WinSendMsg (hwndVscroll, SBM_SETPOS,
                           MPFROMSHORT (iVscrollPos), nil) ;
             end;


       WM_CHAR: begin
               case (CHARMSG(@msg).vkey) of
                    
                    VK_LEFT,
                    VK_RIGHT:
                         WinSendMsg (hwndHscroll, msg, mp1, mp2) ;
                    VK_UP,
                    VK_DOWN,
                    VK_PAGEUP,
                    VK_PAGEDOWN:
                         WinSendMsg (hwndVscroll, msg, mp1, mp2) ;
                    end; {case}
            end;

         WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, rclInvalid) ;
               GpiErase (hps) ;

               iPaintBeg := max (0, iVscrollPos +
                              (cyClient - rclInvalid.yTop) div cyChar) ;
               iPaintEnd := min (NUMLINES, iVscrollPos +
                              (cyClient - rclInvalid.yBottom)
                                   div cyChar + 1) ;

               for iLine := iPaintBeg to iPaintEnd-1 do 
                    begin
                    ptl.x := cxCaps - iHscrollPos ;
                    ptl.y := cyClient - cyChar * (iLine + 1 - iVscrollPos)
                                     + cyDesc ;

                    GpiCharStringAt (hps, ptl,
                                     strlen (sysvals[iLine].szIdentifier),
                                     sysvals[iLine].szIdentifier) ;

                    ptl.x := ptl.x  + 24 * cxCaps ;
                    GpiCharStringAt (hps, ptl,
                                     strlen (sysvals[iLine].szDescription),
                                     sysvals[iLine].szDescription) ;

                    szBuffer:=Pchar(format('%d',
                             [WinQuerySysValue (HWND_DESKTOP,
                                               sysvals[iLine].sIndex)]));
                    ptl.x := ptl.x  + 38 * cxChar + 6 * cxCaps ;
                    RtJustCharStringAt (hps, @ptl, strlen (szBuffer),
                                        szBuffer) ;
                    end; {for}
               WinEndPaint (hps) ;
            end;

  end; {case}

  ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;

end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'SysValsF' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST
                 or FCF_VERTSCROLL    or FCF_HORZSCROLL;

  init_sysvals;

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

