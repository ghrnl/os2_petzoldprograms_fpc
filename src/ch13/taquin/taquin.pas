program taquin;

{/*---------------------------------------
   TAQUIN.C -- Jeu de Taquin
               (c) Charles Petzold, 1993
  ---------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i taquin_hdr.pas}

function rand: integer;
begin
  rand := random(1024)
end;

const
  NUMROWS     =   4;      // greater than or equal to 2
  NUMCOLS     =   4;      // greater than or equal to 3
  SCRAMBLEREP = 100;      // make larger if using more than 16 squares
  SQUARESIZE  =  67;      // in 1/100th inch

var
     aiPuzzle: array [0..NUMROWS-1,0..NUMCOLS-1] of integer;
     iBlankRow, iBlankCol, cxSquare, cySquare : integer;
                
function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     szNum: Pchar;
     hps : cardinal;
     hwndFrame : cardinal;
     iRow, iCol, i: integer;
     iMouseRow, iMouseCol: integer;
     ptl : POINTL;
     rcl, rclInvalid, rclIntersect : RECTL;
     sizl : SIZEL;
     
     { extra }
     done: boolean;

begin

     ClientWndProc:=nil;
     done:=not true;
     
     case (msg) of
          
          WM_CREATE: begin
                              // Calculate square size in pixels

               hps := WinGetPS (Window) ;
               sizl.cx := 0 ;
               sizl.cy := 0 ;
               GpiSetPS (hps, sizl, PU_LOENGLISH) ;
               ptl.x := SQUARESIZE ;
               ptl.y := SQUARESIZE ;
               GpiConvert (hps, CVTC_PAGE, CVTC_DEVICE, 1, ptl) ;
               WinReleasePS (hps) ;

               cxSquare := ptl.x ;
               cySquare := ptl.y ;

                              // Calculate client window size and position

               rcl.xLeft   := (WinQuerySysValue (HWND_DESKTOP, SV_CXSCREEN) -
                                           NUMCOLS * cxSquare) div 2 ;
               rcl.yBottom := (WinQuerySysValue (HWND_DESKTOP, SV_CYSCREEN) -
                                           NUMROWS * cySquare) div 2 ;
               rcl.xRight  := rcl.xLeft   + NUMCOLS * cxSquare ;
               rcl.yTop    := rcl.yBottom + NUMROWS * cySquare ;

                              // Set frame window position and size

               hwndFrame := WinQueryWindow (Window, QW_PARENT) ;
               WinCalcFrameRect (hwndFrame, rcl, FALSE) ;
               WinSetWindowPos  (hwndFrame, 0,
                                 rcl.xLeft, rcl.yBottom,
                                 rcl.xRight - rcl.xLeft,
                                 rcl.yTop - rcl.yBottom,
                                 SWP_MOVE or SWP_SIZE or SWP_ACTIVATE) ;

                              // Initialize the aiPuzzle array

               WinSendMsg (Window, WM_COMMAND, MPFROMSHORT (IDM_NORMAL), nil) ;
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, rclInvalid) ;

                              // Draw the squares

               for iRow := NUMROWS - 1 downto 0 do
                    for iCol := 0 to NUMCOLS-1 do
                         begin
                         rcl.xLeft   := cxSquare * iCol ;
                         rcl.yBottom := cySquare * iRow ;
                         rcl.xRight  := rcl.xLeft   + cxSquare ;
                         rcl.yTop    := rcl.yBottom + cySquare ;

                         if (not WinIntersectRect (0, rclIntersect,
                                                rcl, rclInvalid)) then
                              continue ;

                         if (iRow = iBlankRow ) and ( iCol = iBlankCol) then
                              WinFillRect (hps, rcl, CLR_BLACK) 
                         else
                              begin
                              WinDrawBorder (hps, rcl, 5, 5,
                                             CLR_PALEGRAY, CLR_DARKGRAY,
                                             DB_STANDARD or DB_INTERIOR) ;

                              WinDrawBorder (hps, rcl, 2, 2,
                                             CLR_BLACK, 0, DB_STANDARD) ;

                              szNum := Pchar(format('%d', [aiPuzzle[iRow][iCol]]));

                              WinDrawText (hps, -1, szNum,
                                           rcl, CLR_WHITE, CLR_DARKGRAY,
                                           DT_CENTER or DT_VCENTER) ;
                              end;
                         end;
               WinEndPaint (hps) ;
               end;

          WM_BUTTON1DOWN: begin
               iMouseCol := MOUSEMSG(@msg).x div cxSquare ;
               iMouseRow := MOUSEMSG(@msg).y div cySquare ;

                              // Check if mouse was in valid area

               if ( iMouseRow < 0          ) or ( iMouseCol < 0          ) or (
                    iMouseRow >= NUMROWS   ) or ( iMouseCol >= NUMCOLS   ) or (
                   (iMouseRow <> iBlankRow ) and (iMouseCol <> iBlankCol) ) or (
                   (iMouseRow =  iBlankRow ) and ( iMouseCol = iBlankCol)) then
                         {break ; }
                         done:=false
                         
               ELSE BEGIN

                              // Move a row right or left

               if (iMouseRow = iBlankRow) then
                    begin
                    if (iMouseCol < iBlankCol) then
                         for iCol := iBlankCol downto iMouseCol+1 do
                              aiPuzzle[iBlankRow][iCol] :=
                                   aiPuzzle[iBlankRow][iCol - 1] 
                    else
                         for iCol := iBlankCol to iMouseCol-1 do
                              aiPuzzle[iBlankRow][iCol] :=
                                   aiPuzzle[iBlankRow][iCol + 1] ;
                    end
                              // Move a column up or down
               else
                    begin
                    if (iMouseRow < iBlankRow) then
                         for iRow := iBlankRow downto iMouseRow+1 do
                              aiPuzzle[iRow][iBlankCol] :=
                                   aiPuzzle[iRow - 1][iBlankCol] 
                    else
                         for iRow := iBlankRow to iMouseRow-1 do
                              aiPuzzle[iRow][iBlankCol] :=
                                   aiPuzzle[iRow + 1][iBlankCol] ;
                    end;
                              // Calculate invalid rectangle

               rcl.xLeft   := cxSquare *  min (iMouseCol, iBlankCol) ;
               rcl.yBottom := cySquare *  min (iMouseRow, iBlankRow) ;
               rcl.xRight  := cxSquare * (max (iMouseCol, iBlankCol) + 1) ;
               rcl.yTop    := cySquare * (max (iMouseRow, iBlankRow) + 1) ;

                              // Set new array and blank values

               iBlankRow := iMouseRow ;
               iBlankCol := iMouseCol ;
               aiPuzzle[iBlankRow][iBlankCol] := 0 ;

                              // Invalidate rectangle

               WinInvalidateRect (Window, rcl, FALSE) ;
               {break ;}
               END;
               end;

          WM_CHAR: begin
               if (( not(CHARMSG(@msg).fs and KC_VIRTUALKEY)>0) or 
                     ( (CHARMSG(@msg).fs and KC_KEYUP) >0)) then

               ELSE BEGIN

                              // Mimic a WM_BUTTON1DOWN message

               iMouseCol := iBlankCol ;
               iMouseRow := iBlankRow ;

               case (CHARMSG(@msg).vkey) of
                    
                    VK_LEFT:   inc(iMouseCol) ;
                    VK_RIGHT:  dec(iMouseCol) ;
                    VK_UP:     dec(iMouseRow) ;
                    VK_DOWN:   inc(iMouseRow) ;
                    otherwise;
                    end;
               WinSendMsg (Window, WM_BUTTON1DOWN,
                           MPFROM2SHORT (iMouseCol * cxSquare,
                                         iMouseRow * cySquare), nil) ;
               END;
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                              // Initialize aiPuzzle array

                    IDM_NORMAL,
                    IDM_INVERT: begin
                         for iRow := 0 to NUMROWS-1 do
                              for iCol := 0 to NUMCOLS-1 do
                                   aiPuzzle[iRow][iCol] := iCol + 1 +
                                        NUMCOLS * (NUMROWS - iRow - 1) ;

                         if ( COMMANDMSG(@msg).cmd = IDM_INVERT) then
                              begin
                              aiPuzzle[0][NUMCOLS-2] := NUMCOLS * NUMROWS - 2 ;
                              aiPuzzle[0][NUMCOLS-3] := NUMCOLS * NUMROWS - 1 ;
                              end;
                         iBlankRow := 0;
                         iBlankCol := NUMCOLS - 1;
                         aiPuzzle[iBlankRow][iBlankCol] := 0 ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                         {return 0 ;}
                         end; {IDM_INVERT}

                              // Randomly scramble the squares

                    IDM_SCRAMBLE: begin
                         WinSetPointer (HWND_DESKTOP, WinQuerySysPointer (
                                        HWND_DESKTOP, SPTR_WAIT, FALSE)) ;

                         randomize;

                         for i := 0  to SCRAMBLEREP-1 do
                              begin
                              WinSendMsg (Window, WM_BUTTON1DOWN,
                                   MPFROM2SHORT ((rand mod NUMCOLS) * cxSquare,
                                        iBlankRow * cySquare), nil) ;
                              WinUpdateWindow (Window) ;

                              WinSendMsg (Window, WM_BUTTON1DOWN,
                                   MPFROM2SHORT (iBlankCol * cxSquare,
                                        (rand mod NUMROWS) * cySquare), nil) ;
                              WinUpdateWindow (Window) ;
                              end; {for}
 
                        WinSetPointer (HWND_DESKTOP, WinQuerySysPointer (
                                        HWND_DESKTOP, SPTR_ARROW, FALSE));
                         end;
                    end; {inner case}
               {break ;}
               end;
               otherwise done := false;
     end; {case}

     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'Taquin' ;
  
begin

     flFrameFlags :=    FCF_SYSMENU  or FCF_TITLEBAR
                     or FCF_BORDER   or FCF_MINBUTTON
                     or FCF_MENU     or FCF_ICON
                     or FCF_TASKLIST ;

     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, 0, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, ID_RESOURCE, hwndClient) ;

     while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
          WinDispatchMsg (hab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
     
end.

