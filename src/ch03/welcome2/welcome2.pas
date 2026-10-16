program welcome2;

{/*------------------------------------------------------------
   WELCOME2.C -- A Program that Creates Two Top-Level Windows
                 (c) Charles Petzold, 1993
  ------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

function Client1WndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     szText1 : Pchar = 'Welcome to Window No. 1' ;
     h_ps : HPS;
     rcl : RECTL;
     
     done: boolean;

begin
     
     Client1WndProc:=nil;
     done:=true;

     case (msg) of
          
          WM_PAINT: begin
               h_ps := WinBeginPaint (Window, 0, nil) ;

               WinQueryWindowRect (Window, rcl) ;

               WinDrawText (h_ps, -1, szText1, rcl, CLR_NEUTRAL, CLR_BACKGROUND,
                            DT_CENTER or DT_VCENTER or DT_ERASERECT) ;

               WinEndPaint (h_ps) ;
               end;
               otherwise done:=false;
          end;
          
     if not done then Client1WndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {Client1WndProc}
     
function Client2WndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     szText2 : Pchar = 'Welcome to Window No. 2' ;
     h_ps : HPS;
     rcl : RECTL;
     
     done: boolean;

begin

     Client2WndProc:=nil;
     done:=true;

     case (msg) of
          
          WM_PAINT: begin
               h_ps := WinBeginPaint (Window, 0, nil) ;

               WinQueryWindowRect (Window, rcl) ;

               WinDrawText (h_ps, -1, szText2, rcl, CLR_NEUTRAL, CLR_BACKGROUND,
                            DT_CENTER or DT_VCENTER or DT_ERASERECT) ;

               WinEndPaint (h_ps) ;
             end;

          WM_CLOSE: begin
             end;
          otherwise done:=false;
          end;
          
     if not done then Client2WndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {Client2WndProc}

{ MAIN PROGRAM }

var
   szClientClass1 : Pchar = 'Welcome2.1';
   szClientClass2 : Pchar = 'Welcome2.2';

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame1, hwndFrame2, hwndClient1, hwndClient2 : cardinal;
  flFrameFlags: cardinal;

begin

  flFrameFlags :=    FCF_TITLEBAR      or FCF_SYSMENU
                  or FCF_SIZEBORDER    or FCF_MINMAX
                  or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (
                    hab,                // Anchor block handle
                    szClientClass1,     // Name of class being registered
                    @Client1WndProc,    // Window procedure for class
                    CS_SIZEREDRAW,      // Class style
                    0) ;                // Extra bytes to reserve

     WinRegisterClass (
                    hab,                // Anchor block handle
                    szClientClass2,     // Name of class being registered
                    @Client2WndProc,    // Window procedure for class
                    CS_SIZEREDRAW,      // Class style
                    0) ;                // Extra bytes to reserve

     hwndFrame1 := WinCreateStdWindow (
                    HWND_DESKTOP,       // Parent window handle
                    WS_VISIBLE,         // Style of frame window
                    flFrameFlags,       // Pointer to control data
                    szClientClass1,     // Client window class name
                    nil,                // Title bar text
                    0,                  // Style of client window
                    0,                  // Module handle for resources
                    0,                  // ID of resources
                    hwndClient1) ;      // Pointer to client window handle


     hwndFrame2 := WinCreateStdWindow (
                    HWND_DESKTOP,       // Parent window handle
                    WS_VISIBLE,         // Style of frame window
                    flFrameFlags,       // Pointer to control data
                    szClientClass2,     // Client window class name
                    'Window No. 2',     // Title bar text
                    0,                  // Style of client window
                    0,                  // Module handle for resources
                    0,                  // ID of resources
                    hwndClient2) ;      // Pointer to client window handle
                    
  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame1) ;
  WinDestroyWindow (hwndFrame2) ;

  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

