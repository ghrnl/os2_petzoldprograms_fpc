program checker2;

{/*------------------------------------------------------------------
   CHECKER2.C -- Mouse Hit-Test Demo Program with Keyboard Interface
                 (c) Charles Petzold, 1993
  -------------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

const DIVISIONS = 5;

procedure  DrawLine (hps: cardinal; x1,y1, x2, y2: integer);
var
   ptl: POINTL ;
begin
     ptl.x := x1 ;  ptl.y := y1 ;  GpiMove (hps, ptl) ;
     ptl.x := x2 ;  ptl.y := y2 ;  GpiLine (hps, ptl) ;
end; {DrawLine}

var
  fBlockState : array [0..DIVISIONS-1] of array[0..DIVISIONS-1] of boolean;
  xBlock, yBlock: integer;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;
var
   hps: cardinal;
   x,y: integer;
   ptl: POINTL ;
   rcl: RECTL;

begin
  ClientWindowProc := nil;
   case Msg of
         WM_SIZE: begin
               xBlock := SHORT1FROMMP (mp2) div DIVISIONS ;
               yBlock := SHORT2FROMMP (mp2) div DIVISIONS ;
             end;

         WM_BUTTON1DOWN,
         WM_BUTTON1DBLCLK: begin
               if (xBlock > 0 ) and ( yBlock > 0) then
                    begin
                    x := MOUSEMSG(@msg).x div xBlock ;
                    y := MOUSEMSG(@msg).y div yBlock ;

                    if (x < DIVISIONS ) and ( y < DIVISIONS) then
                         begin
                         fBlockState [x][y] := not fBlockState [x][y] ;

                         rcl.xLeft  := x * xBlock;
                         rcl.xRight := xBlock + rcl.xLeft ;
                         rcl.yBottom := y * yBlock;
                         rcl.yTop   := yBlock + rcl.yBottom ;

                         WinInvalidateRect (Window, rcl, FALSE) ;
                         end
                    else
                         WinAlarm (HWND_DESKTOP, WA_WARNING) ;
                    end
               else
                    WinAlarm (HWND_DESKTOP, WA_WARNING) ;

                               // do default processing
             end;

          WM_SETFOCUS: begin
               if (WinQuerySysValue (HWND_DESKTOP, SV_MOUSEPRESENT) = 0) then
                     WinShowPointer (HWND_DESKTOP,SHORT1FROMMP (mp2)>0);
             end;

          WM_CHAR:begin

               if (xBlock = 0) or (yBlock = 0) then
                    
               else begin
               
               if (CHARMSG(@msg).fs and KC_KEYUP)>0 then

               else begin
               
               if not(CHARMSG(@msg).fs and KC_VIRTUALKEY)>0 then
               
               else begin

               WinQueryPointerPos (HWND_DESKTOP, ptl) ;
               WinMapWindowPoints (HWND_DESKTOP, window, ptl,1) ;

               x := max (0, min (DIVISIONS - 1, ptl.x div xBlock)) ;
               y := max (0, min (DIVISIONS - 1, ptl.y div yBlock)) ;

               case CHARMSG(@msg).vkey of
                    
                    VK_LEFT: begin
                         x:=x-1 ;
                         end;

                    VK_RIGHT: begin
                         x:=x+1 ;
                         end;

                    VK_DOWN: begin
                         y:=y-1 ;
                         end;

                    VK_UP: begin
                         y:=y+1 ;
                         end;

                    VK_HOME: begin
                         x := 0 ;
                         y := DIVISIONS - 1 ;
                         end;

                    VK_END: begin
                         x := DIVISIONS - 1 ;
                         y := 0 ;
                         end;

                    VK_NEWLINE,
		    VK_ENTER,
                    VK_SPACE: begin
                         WinSendMsg (Window, WM_BUTTON1DOWN, 
                              MPFROM2SHORT (x * xBlock, y * yBlock), nil) ;
                    end;

                    otherwise
  WinMessageBox (HWND_DESKTOP, HWND_DESKTOP,
                         'Warning: Cannot find any valid char key.',
                         'Checker2' , 0, MB_OK or MB_WARNING) ;

                    end; {case}
               x := (x + DIVISIONS) mod DIVISIONS ;
               y := (y + DIVISIONS) mod DIVISIONS ;

               ptl.x := x * xBlock + xBlock div 2 ;
               ptl.y := y * yBlock + yBlock div 2 ;

               WinMapWindowPoints (Window, HWND_DESKTOP, ptl, 1) ;
               WinSetPointerPos (HWND_DESKTOP, ptl.x, ptl.y) ;
               end;
               end;
               end;
            end; {WM_CHAR}

  WM_PAINT: begin
               
               hps := WinBeginPaint (Window, 0, nil ) ;

               GpiErase (hps) ;

               if (xBlock > 0 ) and ( yBlock > 0) then
                    for x := 0  to DIVISIONS-1 do
                         for y := 0  to DIVISIONS-1 do
                              begin
                              rcl.xLeft   := x * xBlock;
                              rcl.xRight := xBlock + rcl.xLeft;
                              rcl.yBottom := y * yBlock;
                              rcl.yTop   := yBlock + rcl.yBottom;

                              WinDrawBorder (hps, rcl, 1, 1,
                                             CLR_NEUTRAL, CLR_BACKGROUND,
                                             DB_STANDARD or DB_INTERIOR) ;

                              if (fBlockState [x][y]) then
                                   begin
                                   DrawLine (hps, rcl.xLeft,  rcl.yBottom,
                                                  rcl.xRight, rcl.yTop) ;

                                   DrawLine (hps, rcl.xLeft,  rcl.yTop,
                                                  rcl.xRight, rcl.yBottom) ;
                                   end;
                              end;
               WinEndPaint (hps) ;
         
            end; 
          else ;
     end; {case}
     
     ClientWindowProc := WinDefWindowProc (Window, Msg, MP1, MP2);
     
end;

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Checker2' ;

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

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

