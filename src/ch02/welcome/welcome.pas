program welcome;

{/*---------------------------------------------------------
   WELCOME.C -- A Program that Writes to its Client Window
                (c) Charles Petzold, 1993
  ---------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, doscalls;

{ pmgpi    for predefined colors }
{ doscalls for dosbeep           }

var
    szText : Pchar  = 'Welcome to the OS/2 2.0 Presentation Manager!' ;

function ClientWndProc (_hwnd, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  h_ps: HPS;
  rcl : RECTL;
   
  done : boolean;

begin
     
     ClientWndProc:=nil;
     done:=true;
 
     case (msg) of
	  
          WM_CREATE: begin
               DosBeep (261, 100) ;
               DosBeep (330, 100) ;
               DosBeep (392, 100) ;
               DosBeep (523, 500) ;
             end;

          WM_PAINT: begin
               h_ps := WinBeginPaint (_hwnd, 0, nil) ;

               WinQueryWindowRect (_hwnd, rcl) ;

               WinDrawText (h_ps, -1, szText, rcl, CLR_NEUTRAL, CLR_BACKGROUND,
                            DT_CENTER or DT_VCENTER or DT_ERASERECT) ;

               WinEndPaint (h_ps) ;
             end;

          WM_DESTROY: begin
               DosBeep (523, 100) ;
               DosBeep (392, 100) ;
               DosBeep (330, 100) ;
               DosBeep (261, 500) ;
             end;
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
  szClientClass: PChar = 'Welcome1' ; {! this is what .C has }

begin

  flFrameFlags :=  FCF_TITLEBAR      or FCF_SYSMENU
                or FCF_SIZEBORDER    or FCF_MINMAX
                or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (
                    hab,                // Anchor block handle
                    szClientClass,      // Name of class being registered
                    @ClientWndProc,     // Window procedure for class
                    CS_SIZEREDRAW,      // Class style
                    0) ;                // Extra bytes to reserve

  hwndFrame := WinCreateStdWindow (
                    HWND_DESKTOP,       // Parent window handle
                    WS_VISIBLE,         // Style of frame window
                    flFrameFlags,       // Pointer to control data
                    szClientClass,      // Client window class name
                    nil,                // Title bar text
                    0,                  // Style of client window
                    0,                  // Module handle for resources
                    0,                  // ID of resources
                    hwndClient) ;        // Pointer to client window handle

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

