program checker3;

{/*--------------------------------------------------------------
   CHECKER3.C -- Mouse Hit-Test Demo Program with Child Windows
                 (c) Charles Petzold, 1993
  --------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}
{$i ..\..\ch00\mrfromshort.pas}

const DIVISIONS = 5;

var
  hab: cardinal;
  
procedure  DrawLine (hps: cardinal; x1,y1, x2, y2: longint);
var
   ptl: POINTL ;
begin
     ptl.x := x1 ;  ptl.y := y1 ;  GpiMove (hps, ptl) ;
     ptl.x := x2 ;  ptl.y := y2 ;  GpiLine (hps, ptl) ;
end; {DrawLine}

function ChildWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export; forward;
                                                         
var
     hwndChild: array [0..DIVISIONS-1,0..DIVISIONS-1] of cardinal ;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;
const
     szChildClass = 'Checker3.Child' ;

var
     xBlock, yBlock, x, y : integer;
     done: boolean;

begin

     ClientWndProc:=nil;
     done:= true;     

     case (msg) of
          
          WM_CREATE: begin
               WinRegisterClass (hab, szChildClass, @ChildWndProc,
                                 CS_SIZEREDRAW, sizeof (WORD) {USHORT}) ;

               for x := 0 to DIVISIONS-1 do
                    for y := 0 to DIVISIONS-1 do

                         hwndChild [x][y] :=
                              WinCreateWindow (
                                        Window,        // Parent window
                                        szChildClass,  // Window class
                                        nil,           // Window text
                                        WS_VISIBLE,    // Window style
                                        0, 0, 0, 0,    // Position & size
                                        Window,        // Owner window
                                        HWND_BOTTOM,   // Placement
                                        y shl 8 or x,  // Child window ID
                                        nil,           // Control data
                                        nil) ;         // Pres. Params
               
               end;

          WM_SIZE: begin
               xBlock := SHORT1FROMMP (mp2) div DIVISIONS ;
               yBlock := SHORT2FROMMP (mp2) div DIVISIONS ;

               for x := 0 to DIVISIONS-1 do
                    for y := 0 to DIVISIONS-1 do

                         WinSetWindowPos (hwndChild [x][y], 0,
                              x * xBlock, y * yBlock, xBlock, yBlock,
                              SWP_MOVE or SWP_SIZE) ;      
               end;

          WM_BUTTON1DOWN,
          WM_BUTTON1DBLCLK: begin
               WinAlarm (HWND_DESKTOP, WA_WARNING) ;
               {break ;}                       // do default processing
               done:=false;
               end;

          WM_ERASEBACKGROUND: 
               ClientWndProc := MRFROMSHORT (1) ;
          
          otherwise done:=false;
          
     end; {case}
          
     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

function ChildWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                         cdecl; export;

var
     h_ps : HPS;
     rcl : RECTL ;

begin

     ChildWndProc:=nil;
     
     case (msg) of
          
          WM_CREATE: begin
               WinSetWindowUShort (Window, 0, 0) ;
               end;

          WM_BUTTON1DOWN,
          WM_BUTTON1DBLCLK: begin
               WinSetActiveWindow (HWND_DESKTOP, Window) ;
               WinSetWindowUShort (Window, 0, not(WinQueryWindowUShort (Window, 0))) ;
               WinInvalidateRect (Window, nil, FALSE) ;
               end;

          WM_PAINT: begin
               h_ps := WinBeginPaint (Window, 0, nil) ;

               WinQueryWindowRect (Window, rcl) ;

               WinDrawBorder (h_ps, rcl, 1, 1, CLR_NEUTRAL, CLR_BACKGROUND,
                                   DB_STANDARD or DB_INTERIOR) ;

               if (WinQueryWindowUShort (Window, 0))>0 then
                    begin
                    DrawLine (h_ps, rcl.xLeft,  rcl.yBottom,
                                   rcl.xRight, rcl.yTop) ;
                    DrawLine (h_ps, rcl.xLeft,  rcl.yTop,
                                   rcl.xRight, rcl.yBottom) ;
                    end;
               WinEndPaint (h_ps) ;
               end;
               
          otherwise ChildWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
          
     end; {case}

end; {ChildWndProc}

{ MAIN PROGRAM }

var
  hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Checker3' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

