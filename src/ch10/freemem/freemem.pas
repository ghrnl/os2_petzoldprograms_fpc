program freemem;

{ deviating Main ! }

{/*----------------------------------------
   FREEMEM.C -- Free Memory Display
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

{ strings for strcat }

uses os2def, pmwin, pmgpi, strings, doscalls; 

{$i ..\..\ch00\mousutil.pas}

const ID_TIMER = 1;

var
    szText : Pchar = '1,234,567,890 bytes' ; { a value just for size }

procedure SizeTheWindow (hwndFrame: cardinal);

{ !!! use strlen iso sizeof }

var
     h_ps : HPS ;
     aptl: array [0..TXTBOX_COUNT-1] of POINTL;
     rcl : RECTL;

begin

     h_ps := WinGetPS (hwndFrame) ;
     GpiQueryTextBox (h_ps, strlen (szText) - 1, szText, TXTBOX_COUNT, aptl[0]) ;
     WinReleasePS (h_ps) ;

     rcl.yBottom := 0 ;
     rcl.yTop    := 3 * (aptl[TXTBOX_TOPLEFT].y -
                        aptl[TXTBOX_BOTTOMLEFT].y) div 2 ;
     rcl.xLeft   := 0 ;
     rcl.xRight  := ({sizeof} strlen(szText) + 1) * (aptl[TXTBOX_BOTTOMRIGHT].x -
                   aptl[TXTBOX_BOTTOMLEFT].x) div ({sizeof}  strlen(szText) - 1) ;

     WinCalcFrameRect (hwndFrame, rcl, FALSE) ;

     WinSetWindowPos (hwndFrame, 0, rcl.xLeft, rcl.yBottom,
                      rcl.xRight - rcl.xLeft, rcl.yTop - rcl.yBottom,
                      SWP_SIZE or SWP_MOVE) ;
end; {SizeTheWindow}

procedure FormatNumber (pchResult: Pchar; ulValue: ULONG);

var
     fDisplay : boolean = FALSE ;
     iDigit : integer;
     ulQuotient: ULONG;
     ulDivisor : ULONG = 1000000000 ;

begin
 
     for iDigit := 0 to 10-1 do
          begin
          ulQuotient := ulValue div ulDivisor ;

          if (fDisplay ) or (ulQuotient > 0 ) or (iDigit = 9) then
               begin
               fDisplay := TRUE ;

               { *pchResult++ = (CHAR) ('0' + ulQuotient) ; }
               pchResult^ := char (ord('0') + ulQuotient) ;
               pchResult := pchResult+1;

               if (iDigit mod 3 = 0) and (iDigit <> 9) then begin
                   { *pchResult++ := ',' ;}
                   pchResult^ := ',' ;
                   pchResult := pchResult+1;
               end;
               end;
          ulValue := ulValue - ulQuotient * ulDivisor ;
          ulDivisor := ulDivisor div 10 ;
          end;
     pchResult^ := char(0) ;
end; {FormatNumber}

var
     rcl: RECTL ;
     ulFreeMem, ulPrevMem : ULONG;

function  ClientWndProc (_hwnd, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;

var

     szBuffer : array [0..24-1] of CHAR ;
     h_ps: HPS;

begin
 
     case (msg) of
          
          WM_SIZE: begin
               WinQueryWindowRect (_hwnd, rcl) ;
               {return 0 ;} end;               

          WM_TIMER: begin
               DosQuerySysInfo (QSV_TOTAVAILMEM, QSV_TOTAVAILMEM,
                                PBYTE(ulFreeMem), sizeof (ULONG)) ;

               if (ulFreeMem <> ulPrevMem) then
                    begin
                    WinInvalidateRect (_hwnd, nil, FALSE) ;
                    ulPrevMem := ulFreeMem ;
                    end;
               {return 0 ;} end;

          WM_PAINT: begin
               h_ps := WinBeginPaint (_hwnd, 0, nil) ;

               FormatNumber (szBuffer, ulFreeMem) ;
               strcat (szBuffer, ' bytes') ;

               WinDrawText (h_ps, -1, szBuffer, rcl, 
                            CLR_NEUTRAL, CLR_BACKGROUND,
                            DT_CENTER or DT_VCENTER or DT_ERASERECT) ;

               WinEndPaint (h_ps) ;
               {return 0 ;} end;
          end;
     ClientWndProc := WinDefWindowProc (_hwnd, msg, mp1, mp2) ;
end; {ClientWndProc}
     
{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'FreeMem';

begin

  flFrameFlags :=  FCF_TITLEBAR or FCF_SYSMENU
                or FCF_BORDER   or FCF_TASKLIST ;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

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
  WinTerminate (hab);

end.

