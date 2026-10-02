program buttons2;

{/*-----------------------------------------
   BUTTONS2.C -- New Button Demonstration
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmdev, sysutils;

{ sysutils or strings}

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i newbtn.pas}

var
     szButtonLabel: array [0..2-1] of Pchar = ('Smaller', 'Larger');
     _hwndFrame: cardinal;
     hwndButton: array [0..2-1] of cardinal ;
     cxClient, cyClient, cxChar, cyChar : integer ;

function  ClientWndProc (_hwnd, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;

var
     fm : FONTMETRICS;
     h_ab : cardinal ;
     h_ps: cardinal ;
     id : integer;
     rcl : RECTL;
     {extra}
     done: boolean;

begin
     
     ClientWndProc:=nil;
     done:=true;

     case (msg) of
          
          WM_CREATE: begin
               h_ab := WinQueryAnchorBlock (_hwnd) ;
               _hwndFrame := WinQueryWindow (_hwnd, QW_PARENT) ;

               h_ps := WinGetPS (_hwnd) ;
               GpiQueryFontMetrics (h_ps, sizeof(fm), fm) ;
               cxChar := fm.lAveCharWidth ;
               cyChar := fm.lMaxBaselineExt ;
               WinReleasePS (h_ps) ;

               RegisterNewBtnClass (h_ab) ;

               for id := 0 to 2-1 do
                    hwndButton[id] := WinCreateWindow (
                                        _hwnd,              // Parent
                                        'NewBtn',           // Class
                                        szButtonLabel[id],  // Text
                                        WS_VISIBLE,         // Style
                                        0, 0,               // Position
                                        12 * cxChar,        // Width
                                        2 * cyChar,         // Height
                                        _hwnd,              // Owner
                                        HWND_BOTTOM,        // Placement
                                        id,                 // ID
                                        nil,                // Ctrl Data
                                        nil) ;              // Pres Params
             end;

          WM_SIZE : begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;

               for id := 0 to 2-1 do
                    WinSetWindowPos (hwndButton[id], 0,
                              cxClient div 2 + (14 * id - 13) * cxChar,
                              (cyClient - 2 * cyChar) div 2,
                              0, 0, SWP_MOVE) ;
             end;

          WM_COMMAND: begin
               WinQueryWindowRect (_hwnd, rcl) ;
               WinMapWindowPoints (_hwnd, HWND_DESKTOP, @rcl, 2) ;
               
               case COMMANDMSG(@msg).cmd of             // Child ID
                    
                    0:   begin                              // "Smaller"
                         rcl.xLeft   := rcl.xLeft   + cxClient div 20 ;
                         rcl.xRight  := rcl.xRight  - cxClient div 20 ;
                         rcl.yBottom := rcl.yBottom + cyClient div 20 ;
                         rcl.yTop    := rcl.yTop    - cyClient div 20 ;
                         end;

                    1: begin                                // "Larger"
                         rcl.xLeft   := rcl.xLeft   - cxClient div 20 ;
                         rcl.xRight  := rcl.xRight  + cxClient div 20 ;
                         rcl.yBottom := rcl.yBottom - cyClient div 20 ;
                         rcl.yTop    := rcl.yTop    + cyClient div 20 ;
                         end;
                    otherwise;
                    end; {inner case}
               
               WinCalcFrameRect (_hwndFrame, rcl, FALSE) ;

               WinSetWindowPos (_hwndFrame, 0,
                                rcl.xLeft, rcl.yBottom,
                                rcl.xRight - rcl.xLeft,
                                rcl.yTop   - rcl.yBottom,
				SWP_MOVE or SWP_SIZE) ;
             end;

          WM_ERASEBACKGROUND: 
               ClientWndProc := MRFROMSHORT (1) ;
               
          otherwise done:=false;
          
          end; {case}
          
     if not done then ClientWndProc := WinDefWindowProc (_hwnd, msg, mp1, mp2) ;
     
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'Buttons2';

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

