program life;

{/*--------------------------------------
   LIFE.C -- John Conway's Game of Life
             (c) Charles Petzold, 1993
  --------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i ..\..\ch00\winmenuitems.pas}

{$i life_hdr.pas}

const ID_TIMER  =  1;

var
  szClientClass: Pchar = 'Life' ;

procedure ErrorMsg (hwnd: cardinal; szMessage: Pchar);
begin
     WinMessageBox (HWND_DESKTOP, hwnd, szMessage, szClientClass, 0,
                    MB_OK or MB_WARNING) ;
end; {ErrorMsg}

procedure DrawCell (hps: cardinal; x, y, cxCell, cyCell: integer; bCell: BYTE);
var
     rcl : RECTL;
begin
     rcl.xLeft   := x * cxCell ;
     rcl.yBottom := y * cyCell ;
     rcl.xRight  := rcl.xLeft   + cxCell - 1 ;
     rcl.yTop    := rcl.yBottom + cyCell - 1 ;

     if (bCell and 1)>0 then
       WinFillRect (hps, rcl, CLR_NEUTRAL) 
     else
       WinFillRect (hps, rcl, CLR_BACKGROUND) ;
end; {DrawCell}

var
     pbGrid : PBYTE = nil;
     xNumCells: integer;

function GRID (x,y: integer): PBYTE; inline;
begin
  GRID :=  pbGrid + y * xNumCells + x
end; {GRID}

procedure DoGeneration (hps: cardinal; pbGrid: PBYTE; xNumCells, yNumCells,
                   cxCell, cyCell: integer);
var
     x, y, sSum: integer;

begin

     for y := 0 to yNumCells - 2 do
          for x := 0  to xNumCells - 1 do
               begin
               if (x = 0 ) or ( x = xNumCells - 1 ) or (y = 0) then
                    GRID (x,y)^ := GRID (x,y)^  or (GRID (x,y)^ shl 4 )
               else
                    begin
                    sSum := (GRID (x - 1, y    )^ +           // Left
                             GRID (x - 1, y - 1)^ +           // Lower Left
                             GRID (x    , y - 1)^ +           // Lower
                             GRID (x + 1, y - 1)^) shr 4 ;    // Lower Right

                    sSum := sSum +
                             GRID (x + 1, y    )^ +           // Right
                             GRID (x + 1, y + 1)^ +           // Upper Right
                             GRID (x    , y + 1)^ +           // Upper
                             GRID (x - 1, y + 1)^ ;           // Upper Left

                    sSum := (sSum or GRID (x, y)^) and $0F ;

                    GRID (x, y)^ := GRID (x, y)^ and $0F; { to avoid byte overflow }
                    GRID (x, y)^ := GRID (x, y)^ shl 4 ;

                    if (sSum = 3) then
                         GRID (x, y)^ := GRID (x, y)^ or 1 ;

                    if (GRID (x, y)^ <> (GRID (x, y)^ shr 4)) then
                         DrawCell (hps, x, y, cxCell, cyCell, GRID (x, y)^) ;
                    end;
               end;
end; {DoGeneration}

procedure DisplayGenerationNum (hps: cardinal; xGen, yGen, iGeneration: integer);

var
     ptl : POINTL;
     szBuffer : array [0..24-1] of char ;

begin
     ptl.x := xGen ;
     ptl.y := yGen ;

     szBuffer := format('Generation %d', [iGeneration]);

     GpiSavePS (hps) ;

     GpiSetBackMix (hps, BM_OVERPAINT) ;
     GpiCharStringAt (hps, ptl, strlen (szBuffer), szBuffer) ;

     GpiRestorePS (hps, -1) ;
end; {DisplayGenerationNum}

var
     fTimerGoing : boolean;
     habWP : cardinal;
     hwndMenu : cardinal ;
     iGeneration, cxChar, cyChar, cyDesc, cxClient, cyClient,
                  xGenNum, yGenNum, cxCell, cyCell, {xNumCells,} yNumCells: integer;
                  
     iScaleCell : integer = 2 ;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     fm : FONTMETRICS;
     hps : cardinal;
     x, y : integer;
     ptl : POINTL ;
     {extra}
     done: boolean;

begin

     ClientWndProc:=nil;
     done:=true;
     
     case (msg) of
          
          WM_CREATE: begin
               habWP := WinQueryAnchorBlock (Window) ;

               hps := WinGetPS (Window) ;
               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               cxChar := fm.lAveCharWidth ;
               cyChar := fm.lMaxBaselineExt ;
               cyDesc := fm.lMaxDescender ;
               WinReleasePS (hps) ;

               hwndMenu := WinWindowFromID (
                               WinQueryWindow (Window, QW_PARENT),
                               FID_MENU) ;
               end;

          WM_SIZE: begin
               if (pbGrid <> nil) then
                    begin
                    freemem (pbGrid) ;
                    pbGrid := nil ;
                    end;

               if (fTimerGoing) then
                    begin
                    WinStopTimer (habWP, Window, ID_TIMER) ;
                    fTimerGoing := FALSE ;
                    end;

               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;

               xGenNum := cxChar ;
               yGenNum := cyClient - cyChar + cyDesc ;

               cxCell := cxChar * 2 div iScaleCell ;
               cyCell := cyChar div iScaleCell ;

               xNumCells := cxClient div cxCell ;
               yNumCells := (cyClient - cyChar) div cyCell ;

               {extra} if (xNumCells*xNumCells>MAXINT) then
                    ErrorMsg (Window, 'Number of cells > MAXINT.') ;

               if (xNumCells <= 0 ) or ( yNumCells <= 0) then
                    ErrorMsg (Window, 'Not enough room for even one cell.') 
               else begin
                    pbGrid := getmem (xNumCells * yNumCells);
                    if (nil = pbGrid) then
                      ErrorMsg (Window, 'Not enough memory for this many cells.') ;
                    fillbyte (pbGrid^, xNumCells * yNumCells,0) ;
               end;

               WinEnableMenuItem (hwndMenu, IDM_SIZE,  TRUE) ;
               WinEnableMenuItem (hwndMenu, IDM_START, pbGrid <> nil) ;
               WinEnableMenuItem (hwndMenu, IDM_STOP,  FALSE) ;
               WinEnableMenuItem (hwndMenu, IDM_STEP,  pbGrid <> nil) ;
               WinEnableMenuItem (hwndMenu, IDM_CLEAR, pbGrid <> nil) ;

               iGeneration := 0 ;
             end;

          WM_BUTTON1DOWN: begin
               x := MOUSEMSG(@msg).x div cxCell ;
               y := MOUSEMSG(@msg).y div cyCell ;

               if (pbGrid <> nil) and (not fTimerGoing) and (x < xNumCells) and (
                                                     y < yNumCells) then
                  begin
                    hps := WinGetPS (Window) ;
                    GRID (x, y)^ := GRID (x, y)^ XOR 1 ;
                    DrawCell (hps, x, y, cxCell, cyCell, GRID (x, y)^) ;
                    WinReleasePS (hps) ;
                  end
                  else
                    WinAlarm (HWND_DESKTOP, WA_WARNING) ;
             end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_LARGE,
                    IDM_SMALL,
                    IDM_TINY: begin
                         WinCheckMenuItem (hwndMenu, iScaleCell, FALSE) ;
                         iScaleCell := COMMANDMSG(@msg).cmd;
                         WinCheckMenuItem (hwndMenu, iScaleCell, TRUE) ;

                         WinSendMsg (Window, WM_SIZE, nil,
                                     MPFROM2SHORT (cxClient, cyClient)) ;

                         WinInvalidateRect (Window, nil, FALSE) ;
                       end;

                    IDM_START: begin
                         if (not WinStartTimer (habWP, Window, ID_TIMER, 1))=0 then
                              ErrorMsg (Window, 'Too many clocks or timers.') 
                         else
                              begin
                              fTimerGoing := TRUE ;

                              WinEnableMenuItem (hwndMenu, IDM_SIZE,  FALSE) ;
                              WinEnableMenuItem (hwndMenu, IDM_START, FALSE) ;
                              WinEnableMenuItem (hwndMenu, IDM_STOP,  TRUE) ;
                              WinEnableMenuItem (hwndMenu, IDM_STEP,  FALSE) ;
                              WinEnableMenuItem (hwndMenu, IDM_CLEAR, FALSE) ;
                              end
                       end;

                    IDM_STOP: begin
                         WinStopTimer (habWP, Window, ID_TIMER) ;
                         fTimerGoing := FALSE ;

                         WinEnableMenuItem (hwndMenu, IDM_SIZE,  TRUE) ;
                         WinEnableMenuItem (hwndMenu, IDM_START, TRUE) ;
                         WinEnableMenuItem (hwndMenu, IDM_STOP,  FALSE) ;
                         WinEnableMenuItem (hwndMenu, IDM_STEP,  TRUE) ;
                         WinEnableMenuItem (hwndMenu, IDM_CLEAR, TRUE) ;
                       end;

                    IDM_STEP: begin
                         WinSendMsg (Window, WM_TIMER, nil, nil) ;
                       end;

                    IDM_CLEAR: begin
                         iGeneration := 0 ;
                         fillbyte (pbGrid^, xNumCells * yNumCells, 0) ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                       end;
                    end; {inner case}
               end;

          WM_TIMER: begin
               hps := WinGetPS (Window) ;

               inc(iGeneration);
               DisplayGenerationNum (hps, xGenNum, yGenNum, iGeneration) ;
               DoGeneration (hps, pbGrid, xNumCells, yNumCells, cxCell, cyCell);

               WinReleasePS (hps) ;
             end;
               
          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               if (pbGrid <> nil) then
                    begin
                    for x := 1 to xNumCells do
                         begin
                         ptl.x := cxCell * x - 1 ;
                         ptl.y := 0 ;
                         GpiMove (hps, ptl) ;

                         ptl.y := cyCell * yNumCells - 1 ;
                         GpiLine (hps, ptl) ;
                         end;

                    for y := 1 to yNumCells do
                         begin
                         ptl.x := 0 ;
                         ptl.y := cyCell * y - 1 ;
                         GpiMove (hps, ptl) ;

                         ptl.x := cxCell * xNumCells - 1 ;
                         GpiLine (hps, ptl) ;
                         end;

                    for y := 0 to yNumCells-1 do
                         for x := 0 to xNumCells-1 do
                              if (GRID(x, y)^ and 1) >0 then
                                   DrawCell (hps, x, y, cxCell, cyCell,
                                             GRID (x, y)^) ;

                    DisplayGenerationNum (hps, xGenNum, yGenNum, iGeneration) ;
                    end;
               WinEndPaint (hps) ;
             end;
               
          WM_DESTROY: begin
               if (fTimerGoing) then
                    WinStopTimer (habWP, Window, ID_TIMER) ;

               if (pbGrid <> nil) then
                    freemem (pbGrid) ;

               end;
               
          else done:=false;
          
     end; {case}
     
     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;

begin

  flFrameFlags :=     FCF_TITLEBAR      or FCF_SYSMENU
                   or FCF_SIZEBORDER    or FCF_MINMAX
                   or FCF_SHELLPOSITION or FCF_TASKLIST
                   or FCF_MENU          or FCF_ICON ;

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
  WinTerminate (hab);

end.

