program devcapsp;

{/*--------------------------------------------------
   DEVCAPS.C -- Device Capabilities Display Program
                (c) Charles Petzold, 1993
  --------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,pmdev, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i devcaps_hdr.pas}

function RtJustCharStringAt (hps: cardinal; pptl: PPOINTL; lLength: longint; pchText: Pchar): longint;

var
     aptlTextBox: array [0..TXTBOX_COUNT-1] of POINTL;

begin

     GpiQueryTextBox (hps, lLength, pchText, TXTBOX_COUNT, aptlTextBox[0]) ;

     pptl^.x := pptl^.x - aptlTextBox[TXTBOX_CONCAT].x ;

     RtJustCharStringAt := GpiCharStringAt (hps, pptl^, lLength, pchText) ;
end;

var
     hdc : cardinal;
     cyClient, cxCaps, cyChar, cyDesc : integer ;
     
function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     szBuffer: array [0..12-1] of char ;
     fm : FONTMETRICS;
     hps : cardinal ;
     i : integer;
     lValue : longint;
     ptl : POINTL;

begin

     case (msg) of
          
          WM_CREATE: begin
               hps := WinGetPS (Window) ;
               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               cxCaps := fm.lEmInc ;
               {cxCaps := (fm.fsType & 1 ? 2 : 3) * fm.lAveCharWidth / 2 ;}
               if (fm.fsType and 1)>0 then
                 cxCaps := (2) * fm.lAveCharWidth div 2
               else
                 cxCaps := (3) * fm.lAveCharWidth div 2 ;
               
               cyChar := fm.lMaxBaselineExt ;
               cyDesc := fm.lMaxDescender ;
               WinReleasePS (hps) ;

               hdc := WinOpenWindowDC (Window) ;
               {return 0 ;}
               end;

          WM_SIZE: begin
               cyClient := SHORT2FROMMP (mp2) ;
               {return 0 ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               for i := 0 to NUMLINES-1 do
                    begin
                    ptl.x := cxCaps ;
                    ptl.y := cyClient - cyChar * (i + 2) + cyDesc ;

                    if (i >= (NUMLINES + 1) div 2) then
                         begin
                         ptl.x := ptl.x + cxCaps * 35 ;
                         ptl.y := ptl.y + cyChar * ((NUMLINES + 1) div 2) ;
                         end;

                    DevQueryCaps (hdc, devcaps[i].lIndex, 1, lValue) ;

                    GpiCharStringAt (hps, ptl,
                                     strlen (devcaps[i].szIdentifier),
                                     devcaps[i].szIdentifier) ;

                    ptl.x := ptl.x + 33 * cxCaps ;
                    {RtJustCharStringAt (hps, &ptl,
                              sprintf (szBuffer, "%d", lValue),
                              szBuffer) ;}
                    szBuffer := format ('%d', [lValue]);
                    RtJustCharStringAt (hps, @ptl,
                              strlen (szBuffer),
                              szBuffer) ;
                    end;
               WinEndPaint (hps) ;
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
  szClientClass: PChar = 'DevCaps' ;
  
begin

     flFrameFlags :=    FCF_TITLEBAR      or FCF_SYSMENU
                     or FCF_SIZEBORDER    or FCF_MINMAX
                     or FCF_SHELLPOSITION or FCF_TASKLIST ;

     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, 0, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

     while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
          WinDispatchMsg (hab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
     
end.

