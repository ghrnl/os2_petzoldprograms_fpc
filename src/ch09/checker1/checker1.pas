program checker1;

{/*-------------------------------------------
   CHECKER1.C -- Mouse Hit-Test Demo Program
                 (c) Charles Petzold, 1993
  -------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

const DIVISIONS = 5;

procedure  DrawLine (hps: cardinal; x1,y1, x2, y2: longint);
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
  szClientClass: PChar = 'Checker1' ;

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

