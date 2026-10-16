program digclock;

{ status: functional but shows blank iso leading zero }

{ special: fpc format frm sysutils to replace c sprintf     }
{ special: fpc DosQueryCtryInfo to replace c DosGetCtryInfo }

{/*-----------------------------------------
   DIGCLOCK.C -- Digital Clock
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmdev, doscalls, sysutils; {sysutils for format}

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

const ID_TIMER  = 1;

procedure SizeTheWindow (hwndFrame: cardinal);
var
     fm : FONTMETRICS;
     hps : cardinal;
     rcl: RECTL ;

begin

     hps := WinGetPS (hwndFrame) ;
     GpiQueryFontMetrics (hps, {(LONG)} sizeof(fm), fm) ;
     WinReleasePS (hps) ;

     rcl.yBottom := 0 ;
     rcl.yTop    := 11 * fm.lMaxBaselineExt div 4 ;
     rcl.xRight  := WinQuerySysValue (HWND_DESKTOP, SV_CXSCREEN) ;
     rcl.xLeft   := rcl.xRight - 24 * fm.lAveCharWidth ;

     WinCalcFrameRect (hwndFrame, rcl, FALSE) ;

     WinSetWindowPos (hwndFrame, 0, rcl.xLeft, rcl.yBottom,
                      rcl.xRight - rcl.xLeft, rcl.yTop - rcl.yBottom,
                      SWP_SIZE or SWP_MOVE) ;
end; {SizeTheWindow}

var
     fHaveCtryInfo : boolean = FALSE ;
     szDayName: array [0..7-1] of Pchar = ( 'Sun', 'Mon', 'Tue', 'Wed',
                                          'Thu', 'Fri', 'Sat' );
     szDateFormat: Pchar = ' %s  %d%s%02d%s%02d ' ;
     ctryc : COUNTRYCODE { = (0, 0 )};
     ctryi : COUNTRYINFO;
     
procedure UpdateTime (hwnd: cardinal; hps: cardinal);

var
     szBuffer: array [0..20-1]  of CHAR ;
     dt : TDATETIME;
     rcl : RECTL;
     ulDataLength : ULONG;
     
     pmamchar: char;

begin

               // Get Country Information, Date and Time

     if (not fHaveCtryInfo) then
          begin
          DosQueryCtryInfo (sizeof(ctryi), ctryc, ctryi, ulDataLength) ;
          fHaveCtryInfo := TRUE ;
          end;
     DosGetDateTime (dt) ;
     dt.year := dt.year mod 100 ;

               // Format Date
                                        // mm/dd/yy format
     if (ctryi.fsDateFmt = 0) then

          szBuffer := format (szDateFormat, [szDayName [dt.weekday],
                             dt.month, ctryi.szDateSeparator,
                             dt.day,   ctryi.szDateSeparator, dt.year])

                                        // dd/mm/yy format
     else if (ctryi.fsDateFmt = 1) then

          szBuffer := format (szDateFormat, [szDayName [dt.weekday],
                             dt.day,   ctryi.szDateSeparator,
                             dt.month, ctryi.szDateSeparator, dt.year])

                                        // yy/mm/dd format
     else

          szBuffer := format (szDateFormat, [szDayName [dt.weekday],
                             dt.year,  ctryi.szDateSeparator,
                             dt.month, ctryi.szDateSeparator, dt.day]) ;

               // Display Date

     WinQueryWindowRect (hwnd, rcl) ;
     rcl.yBottom := rcl.yBottom + 5 * rcl.yTop div 11 ;
     WinDrawText (hps, -1, szBuffer, rcl, CLR_NEUTRAL, CLR_BACKGROUND,
                  DT_CENTER or DT_VCENTER) ;

               // Format Time
                                        // 12-hour format
     if ((ctryi.fsTimeFmt and 1) = 0) then begin

          pmamchar := 'p';
          if (dt.hours div 12 = 0) then
            pmamchar := 'a';
          szBuffer := format (' %d%s%02d%s%02d %sm ',
                             [(dt.hours + 11) mod 12 + 1, ctryi.szTimeSeparator,
                             dt.minutes, ctryi.szTimeSeparator,
                             dt.seconds, pmamchar])
     end

                                        // 24-hour format
     else
         
          szBuffer := format (' %02d%s%02d%s%02d ',
                             [dt.hours,   ctryi.szTimeSeparator,
                             dt.minutes, ctryi.szTimeSeparator, dt.seconds]) ;

               // Display Time

     WinQueryWindowRect (hwnd, rcl) ;
     rcl.yTop := rcl.yTop - 5 * rcl.yTop div 11 ;
     WinDrawText (hps, -1, szBuffer, rcl, CLR_NEUTRAL, CLR_BACKGROUND,
                  DT_CENTER or DT_VCENTER) ;
end; {UpdateTime}

function  ClientWndProc (Window, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;

var
     hps: cardinal;

begin

     case (msg) of
          
          WM_TIMER: begin
               hps := WinGetPS (Window) ;
               GpiSetBackMix (hps, BM_OVERPAINT) ;

               UpdateTime (Window, hps) ;

               WinReleasePS (hps) ;
               {return 0 ;}
               end;
               

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               UpdateTime (Window, hps) ;

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
  szClientClass: Pchar = 'DigClock';

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                     or FCF_BORDER    or FCF_TASKLIST ;
   
  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, 0, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
				     0, 0, 0, hwndClient) ;
  SizeTheWindow (hwndFrame) ;

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
     WinTerminate (hab) ;
end.

