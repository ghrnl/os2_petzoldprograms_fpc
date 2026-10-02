program welcome3;

{/*-----------------------------------------------------------
   WELCOME3.C -- Creates a Top-Level Window and Two Children
                 (c) Charles Petzold, 1993
  -----------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

const
     szText = 'I''m the parent of two children' ;
 var
     hps : cardinal;
     rcl : RECTL;

begin
     case (msg) of
          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;

               WinQueryWindowRect (Window, rcl) ;

               WinDrawText (hps, -1, szText, rcl, CLR_NEUTRAL, CLR_BACKGROUND,
                            DT_CENTER or DT_VCENTER or DT_ERASERECT) ;

               WinEndPaint (hps) ;
          end
     otherwise;
     end; {case}
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
end; {ClientWndProc}

function ChildWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     hps : cardinal;
     rcl : RECTL;

begin
     case (msg) of
          
          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;

               WinQueryWindowRect (Window, rcl) ;

               WinDrawText (hps, -1, WinQueryWindowPtr (Window, QWL_USER), rcl,
                            CLR_NEUTRAL, CLR_BACKGROUND,
                            DT_CENTER or DT_VCENTER or DT_ERASERECT) ;

               WinEndPaint (hps) ;
             end;

          WM_CLOSE: begin
               WinDestroyWindow (WinQueryWindow (Window, QW_PARENT)) ;
             end;
          
          otherwise;
          
      end; {case}
      
      ChildWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
end; {ChildWndProc}

{ MAIN PROGRAM }

const
   szClientClass = 'Welcome3' ;
   szChildClass  = 'Welcome3.Child' ;

var
  flFrameFlags: cardinal;
  hab: cardinal;
  hmq: cardinal;
  hwndFrame,  hwndClient, hwndChildClient1, hwndChildClient2 : cardinal;
  _qmsg: QMSG;
  
  child1str: Pchar =  'I''m a child ...' ;
  child2str: Pchar = '... Me too!' ;

begin
     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;
     
     flFrameFlags :=    FCF_TITLEBAR      or FCF_SYSMENU  or
                        FCF_SIZEBORDER    or FCF_MINMAX   or
                        FCF_SHELLPOSITION or FCF_TASKLIST ;

     WinRegisterClass (
                    hab,                // Anchor block handle
                    szClientClass,      // Name of class being registered
                    @ClientWndProc,     // Window procedure for class
                    CS_SIZEREDRAW,      // Class style
                    0) ;                // Extra bytes to reserve

     WinRegisterClass (
                    hab,                // Anchor block handle
                    szChildClass,       // Name of class being registered
                    @ChildWndProc,      // Window procedure for class
                    CS_SIZEREDRAW,      // Class style
                    sizeof (pointer)) ; // Extra bytes to reserve

         {/*-------------------------
             Create top-level window
            -------------------------*/}

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

         {/*--------------------------
             Create two child windows
            --------------------------*/}

     flFrameFlags := flFrameFlags and not(FCF_TASKLIST) ;

     WinCreateStdWindow (
                    hwndClient,         // Parent window handle
                    WS_VISIBLE,         // Style of frame window
                    flFrameFlags,      // Pointer to control data
                    szChildClass,       // Client window class name
                    'Child No. 1',      // Title bar text
                    0,                  // Style of client window
                    0,                  // Module handle for resources
                    0,                  // ID of resources
                    hwndChildClient1) ; // Pointer to client window handle

     WinCreateStdWindow (
                    hwndClient,         // Parent window handle
                    WS_VISIBLE,         // Style of frame window
                    flFrameFlags,      // Pointer to control data
                    szChildClass,       // Client window class name
                    'Child No. 2',      // Title bar text
                    0,                  // Style of client window
                    0,                  // Module handle for resources
                    0,                  // ID of resources
                    hwndChildClient2) ; // Pointer to client window handle

         {/*-----------------------------------------------------
             Set reserved area of window to text string pointers
            -----------------------------------------------------*/}

     WinSetWindowPtr (hwndChildClient1, QWL_USER, child1str) ;
     WinSetWindowPtr (hwndChildClient2, QWL_USER, child2str) ;      

     while (WinGetMsg (hab, _qmsg, 0, 0, 0)) do
          WinDispatchMsg (hab, _qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
end.

