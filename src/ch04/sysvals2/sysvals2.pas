program sysvals2;

{/*---------------------------------------------------
   SYSVALS2.C -- System Values Display Program No. 2
                 (c) Charles Petzold, 1993
  ---------------------------------------------------*/}
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

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  hps : cardinal;
  ptl : POINTL;
  iLine: integer;
  szBuffer: Pchar;

begin
  ClientWindowProc := nil;

  case msg of

          WM_CREATE: begin
               hps := WinGetPS (Window) ;
               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;

               cxChar := fm.lAveCharWidth ;
               if (fm.fsType mod 2=1) then
                  cxCaps := (2 * cxChar) div 2 
               else
                  cxCaps := (3 * cxChar) div 2;
               cyChar := fm.lMaxBaselineExt ;
               cyDesc := fm.lMaxDescender ;

               WinReleasePS (hps) ;

               hwndVscroll := WinWindowFromID (
                                   WinQueryWindow (Window, QW_PARENT),
                                   FID_VERTSCROLL) ;

               WinSendMsg (hwndVscroll, SBM_SETSCROLLBAR,
                                   MPFROM2SHORT (iVscrollPos, 0),
                                   MPFROM2SHORT (0, NUMLINES - 1)) ;
            end;

          WM_SIZE: begin
               cyClient := SHORT2FROMMP (mp2) ;
            end;


          WM_VSCROLL: begin
               case SHORT2FROMMP (mp2) of
                    
                     SB_LINEUP: begin
                         iVscrollPos := iVscrollPos - 1 ;
                       end;

                     SB_LINEDOWN:begin
                         iVscrollPos := iVscrollPos + 1 ;
                       end;

                     SB_PAGEUP:begin
                         iVscrollPos := iVscrollPos - cyClient div cyChar ;
                       end;

                     SB_PAGEDOWN:begin
                         iVscrollPos := iVscrollPos + cyClient div cyChar ;
                       end;

                     SB_SLIDERPOSITION:begin
                         iVscrollPos := SHORT1FROMMP (mp2) ;
                       end;

                    else
                       ;
                    end;{case}
               iVscrollPos := max (0, min (iVscrollPos, NUMLINES - 1)) ;

               WinSendMsg (hwndVscroll, SBM_SETPOS,
                           MPFROMSHORT (iVscrollPos), nil) ;

               WinInvalidateRect (window, nil, FALSE) ;
             end;

          WM_PAINT:
               begin
                 hps := WinBeginPaint (Window, 0, nil) ;
                 GpiErase (hps) ;


               for iLine := 0 to NUMLINES-1 do begin
                    
                    ptl.x := cxCaps ;
                    ptl.y := cyClient - cyChar * (iLine + 1 - iVscrollPos) + cyDesc ;

                    GpiCharStringAt (hps, ptl,
                              strlen (sysvals[iLine].szIdentifier),
                              sysvals[iLine].szIdentifier) ;

                    ptl.x := ptl.x + 24 * cxCaps ;
                    GpiCharStringAt (hps, ptl,
                                     strlen (sysvals[iLine].szDescription),
                                     sysvals[iLine].szDescription) ;

                    szBuffer:=Pchar(format('%d',
                             [WinQuerySysValue (HWND_DESKTOP,
                                               sysvals[iLine].sIndex)]));
                    ptl.x := ptl.x + 38 * cxChar;
                    GpiCharStringAt (hps, ptl, strlen (szBuffer),
                                     szBuffer) ;
                    end; {for}
               WinEndPaint (hps) ;
            end;

     else ;

  end; {case}

  ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;

end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'SysVals2' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST
                 or FCF_VERTSCROLL;

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

