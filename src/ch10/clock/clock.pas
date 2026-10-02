program clock;

{ status: ok but repaint at resize fails     }
{ fix   : add WinInvalidateRect to WM_SIZE   }
{ the REF exe doesn't have this issue so ??? }

{/*--------------------------------------
   CLOCK.C -- Analog Clock
              (c) Charles Petzold, 1993
  --------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmdev, doscalls;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

const ID_TIMER = 1;

type WINDOWINFO = record
     cxClient : integer ;
     cyClient : integer ;
     cxPixelDiam : integer ;
     cyPixelDiam : integer ;
   end;
   
   PWINDOWINFO = ^WINDOWINFO;

var
     iSin : array [0..60-1] of integer =
                    (
                       0,  105,  208,  309,  407,  500,  588,  669,  743,  809,
                     866,  914,  951,  978,  995, 1000,  995,  978,  951,  914,
                     866,  809,  743,  669,  588,  500,  407,  309,  208,  105,
                       0, -104, -207, -308, -406, -499, -587, -668, -742, -808,
                    -865, -913, -950, -977, -994, -999, -994, -977, -950, -913,
                    -865, -808, -742, -668, -587, -499, -406, -308, -207, -104
                    );

procedure RotatePoint (var aptl: array of POINTL; iNum, iAngle: integer);
var
     iIndex : integer;
     ptlTemp: POINTL ;

begin
     for iIndex := 0  to iNum - 1 do
          begin
          ptlTemp.x := (aptl[iIndex].x * iSin [(iAngle + 15) mod 60] +
                       aptl[iIndex].y * iSin [iAngle]) div 1000 ;

          ptlTemp.y := (aptl[iIndex].y * iSin [(iAngle + 15) mod 60] -
                       aptl[iIndex].x * iSin [iAngle]) div 1000 ;

          aptl[iIndex] := ptlTemp ;
          end;
end; {RotatePoint}

procedure ScalePoint (var aptl: array of POINTL; iNum: integer; pwi: PWINDOWINFO);

var
     iIndex : integer;
     
begin
     for iIndex := 0  to iNum - 1 do
          begin
          aptl[iIndex].x := aptl[iIndex].x * pwi^.cxPixelDiam div 200 ;
          aptl[iIndex].y := aptl[iIndex].y * pwi^.cyPixelDiam div 200 ;
          end;
end; {ScalePoint}

procedure TranslatePoint (var aptl: array of POINTL; iNum: integer; pwi: PWINDOWINFO);

var
     iIndex : integer;

begin
     for iIndex := 0  to iNum - 1 do
          begin
          aptl[iIndex].x := aptl[iIndex].x + pwi^.cxClient div 2 ;
          aptl[iIndex].y := aptl[iIndex].y + pwi^.cyClient div 2 ;
          end;
end; {TranslatePoint}

procedure DrawHand (hps: cardinal; var aptlIn: array of POINTL; iNum, iAngle: integer;
               pwi: PWINDOWINFO);

var
     iIndex : integer;
     aptl: array [0..5-1] of POINTL ;
     
begin

     for iIndex := 0  to iNum - 1 do
          aptl [iIndex] := aptlIn [iIndex] ;

     RotatePoint    (aptl, iNum, iAngle) ;
     ScalePoint     (aptl, iNum, pwi) ;
     TranslatePoint (aptl, iNum, pwi) ;

     GpiMove (hps, aptl[0]) ;
     GpiPolyLine (hps, iNum - 1, aptl [1] ) ;
end; {DrawHand}

var
     dtPrevious : TDATETIME;
     hdc : cardinal;
     xPixelsPerMeter, yPixelsPerMeter : longint;
     aptlHour: array [0..5-1] of POINTL =
                 ( (x: 0;y:-15), (x:10;y:0), (x:0;y:60), (x:-10;y:0), (x:0;y:-15) );
     aptlMinute: array [0..5-1] of POINTL =
                 ( (x:0;y:-20),  (x:5;y:0), (x:0;y:80), (x:-5;y:0),(x: 0;y:-20) );
     aptlSecond: array [0..2-1] of POINTL =
                 ( (x:0;y:0),  (x:0;y:80) );
     wi : WINDOWINFO;

function  ClientWndProc (Window, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;

var
     dt : TDATETIME;
     hps : cardinal;
     iDiamMM, iAngle : integer;
     aptl: array [0..3-1] of POINTL;
     
     {extra}
     done: boolean;

begin
     
     ClientWndProc:=nil;
     done:=true;
     
     case (msg) of
          
          WM_CREATE: begin
               hdc := WinOpenWindowDC (Window) ;

               DevQueryCaps (hdc, CAPS_VERTICAL_RESOLUTION,
                                  1, yPixelsPerMeter) ;
               DevQueryCaps (hdc, CAPS_HORIZONTAL_RESOLUTION,
                                  1, xPixelsPerMeter) ;

               DosGetDateTime (dtPrevious) ;
               dtPrevious.hours := (dtPrevious.hours * 5) mod 60 +
                                   dtPrevious.minutes div 12 ;
               {return 0 ;}
               end;

          WM_SIZE: begin
               wi.cxClient := SHORT1FROMMP (mp2) ;
               wi.cyClient := SHORT2FROMMP (mp2) ;

               iDiamMM := min (wi.cxClient * 1000 div xPixelsPerMeter,
                              wi.cyClient * 1000 div yPixelsPerMeter) ;

               wi.cxPixelDiam := xPixelsPerMeter * iDiamMM div 1000 ;
               wi.cyPixelDiam := yPixelsPerMeter * iDiamMM div 1000 ;
                              
               WinInvalidateRect (Window, nil, FALSE) ; {!!! extra }
               
               {return 0 ;}
               end;

          WM_TIMER: begin
               DosGetDateTime (dt) ;
               dt.hours := (dt.hours * 5) mod 60 + dt.minutes div 12 ;

               hps := WinGetPS (Window) ;
               GpiSetColor (hps, CLR_BACKGROUND) ;

               DrawHand (hps, aptlSecond, 2, dtPrevious.seconds, @wi) ;

               if (dt.hours   <> dtPrevious.hours) or (
                   dt.minutes <> dtPrevious.minutes) then
                    begin
                    DrawHand (hps, aptlHour,   5, dtPrevious.hours,   @wi) ;
                    DrawHand (hps, aptlMinute, 5, dtPrevious.minutes, @wi) ;
                    end;

               GpiSetColor (hps, CLR_NEUTRAL) ;

               DrawHand (hps, aptlHour,   5, dt.hours,   @wi) ;
               DrawHand (hps, aptlMinute, 5, dt.minutes, @wi) ;
               DrawHand (hps, aptlSecond, 2, dt.seconds, @wi) ;

               WinReleasePS (hps) ;
               dtPrevious := dt ;
               {return 0 ;}
               end;
               
          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               for iAngle := 0 to 60-1 do
                    begin
                    aptl[0].x := 0 ;
                    aptl[0].y := 90 ;

                    RotatePoint    (aptl, 1, iAngle) ;
                    ScalePoint     (aptl, 1, @wi) ;
                    TranslatePoint (aptl, 1, @wi) ;

                    {aptl[2].x := aptl[2].y := iAngle % 5 ? 2 : 10 ;}
                    if (iAngle mod 5)>0 then
                      aptl[2].x := 2
                    else
                      aptl[2].x := 10;
                    aptl[2].y := aptl[2].x ;

                    ScalePoint (aptl [2], 1, @wi) ;

                    aptl[0].x := aptl[0].x - aptl[2].x div 2 ;
                    aptl[0].y := aptl[0].y - aptl[2].y div 2 ;

                    aptl[1].x := aptl[0].x + aptl[2].x ;
                    aptl[1].y := aptl[0].y + aptl[2].y ;

                    GpiMove (hps, aptl[0]) ;
                    GpiBox (hps, DRO_OUTLINEFILL, aptl [1],
                                 aptl[2].x, aptl[2].y) ;
                    end;
               DrawHand (hps, aptlHour,   5, dtPrevious.hours,   @wi) ;
               DrawHand (hps, aptlMinute, 5, dtPrevious.minutes, @wi) ;
               DrawHand (hps, aptlSecond, 2, dtPrevious.seconds, @wi) ;

               WinEndPaint (hps) ;
               {return 0 ;}
               end;
               
     otherwise done:=false;
     
     end; {case}

     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'Clock';

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST ;
   
  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, 0, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  if (WinStartTimer (hab, hwndClient, ID_TIMER, 1000))>0 then
          begin
          while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
               WinDispatchMsg (hab, qmsg) ;

          WinStopTimer (hab, hwndClient, ID_TIMER) ;
          end
     else
          WinMessageBox (HWND_DESKTOP, hwndClient,
                         'Too many clocks or timers',
                         szClientClass, 0, MB_OK or MB_WARNING) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

