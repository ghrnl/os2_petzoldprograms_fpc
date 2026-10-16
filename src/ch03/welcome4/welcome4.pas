program welcome4;

{/*-------------------------------------------------------------
   WELCOME4.C -- Creates a Top-Level Window and Three Children
                 (c) Charles Petzold, 1993
  -------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }


{$APPTYPE GUI}

uses os2def, pmwin;

const
  ID_BUTTON = 1;
  ID_SCROLL = 2;
  ID_ENTRY  = 3;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  done: boolean;

begin
  ClientWindowProc := nil;
  done:= true;

  case msg of
        
     WM_COMMAND: begin
                 case COMMANDMSG(@msg).cmd of
                     ID_BUTTON:
                         WinAlarm (HWND_DESKTOP, WA_NOTE) ;
                     otherwise done:=false
                  end;  {inner case}
              
            end;
      WM_ERASEBACKGROUND: begin
             ClientWindowProc := MRFROMSHORT (1);
            end;
      
      else done:=false ;
 
  end; {case msg}
   
  if not done then ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;
  
end; {WinDefWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Welcome4' ;
  rcl: TRectL;

begin

  flFrameFlags :=       FCF_TITLEBAR      or FCF_SYSMENU
                     or FCF_BORDER        or FCF_MINBUTTON
                     or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass  (hab,                // Anchor block handle
                     szClientClass,      // Name of class being registered
                     @ClientWindowProc,  // Window procedure for class
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
                    hwndClient) ;       // Pointer to client window handle

          {/*--------------------------------------------------------
             Find dimensions of client window for sizes of children
            --------------------------------------------------------*/}

     WinQueryWindowRect (hwndClient, rcl) ;
     rcl.xRight := rcl.xRight div 3 ;   // divide width in thirds

          {/*---------------------------
             Create push button window
            ---------------------------*/}

        WinCreateWindow (
                    hwndClient,                   // Parent window handle
                    WC_BUTTON,                    // Window class
                    'Big Button',                 // Window text
                    WS_VISIBLE                    // Window style
                         or BS_PUSHBUTTON,
                    10,                           // Window position
                    10,
                    rcl.xRight - 20,              // Window size
                    rcl.yTop - 20,
                    hwndClient,                   // Owner window handle
                    HWND_BOTTOM,                  // Placement window handle
                    ID_BUTTON,                    // Child window ID
                    NIL,                          // Control data
                    NIL);                         // Presentation parameters

          {/*--------------------------
             Create scroll bar window
            --------------------------*/}

     WinCreateWindow (
                    hwndClient,                   // Parent window handle
                    WC_SCROLLBAR,                 // Window class
                    NIL,                          // Window text
                    WS_VISIBLE                    // Window style
                        or SBS_VERT,
                    rcl.xRight + 10,              // Window position
                    10,
                    rcl.xRight - 20,              // Window size
                    rcl.yTop - 20,
                    hwndClient,                   // Owner window handle
                    HWND_BOTTOM,                  // Placement window handle
                    ID_SCROLL,                    // Child window ID
                    NIL,                          // Control data
                    NIL) ;                        // Presentation parameters
  
          {/*-------------------------------------
             Create multiline entry field window
            -------------------------------------*/}

     WinCreateWindow (
                    hwndClient,                   // Parent window handle
                    WC_MLE,                       // Window class
                    NIL,                          // Window text
                    WS_VISIBLE                    // Window style
                         or MLS_BORDER
                         or MLS_VSCROLL
                         or MLS_WORDWRAP,
                    2 * rcl.xRight + 10,          // Window position
                    10,
                    rcl.xRight - 20,              // Window size
                    rcl.yTop - 20,
                    hwndClient,                   // Owner window handle
                    HWND_BOTTOM,                  // Placement window handle
                    ID_ENTRY,                     // Child window ID
                    NIL,                          // Control data
                    NIL) ;                        // Presentation parameters

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

