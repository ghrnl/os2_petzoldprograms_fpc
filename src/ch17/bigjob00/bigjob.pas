{/*-------------------------------------------------------
   BIGJOB.C -- Common functions used in BIGJOBx Programs
               (c) Charles Petzold, 1993
  -------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
forward;

function MainCode (szClientClass: Pchar; szTitleBarText: Pchar): integer; {???} cdecl; export;
var
     flFrameFlags: cardinal;
     h_ab : HAB;
     h_mq : HMQ;
     hwndFrame, hwndClient : HWND;
     qmsg : TQMSG;


begin
     flFrameFlags :=     FCF_TITLEBAR       or FCF_SYSMENU
                      or FCF_SIZEBORDER     or FCF_MINMAX 
                      or FCF_SHELLPOSITION  or FCF_TASKLIST
                      or FCF_MENU ;

     h_ab := WinInitialize (0) ;
     h_mq := WinCreateMsgQueue (h_ab, 0) ;

     WinRegisterClass (h_ab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass,
                                     szTitleBarText,
                                     0, 0, ID_RESOURCE, hwndClient) ;

     while (WinGetMsg (h_ab, qmsg, 0, 0, 0)) do
          WinDispatchMsg (h_ab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (h_mq) ;
     WinTerminate (h_ab) ;
     MainCode := 0 ;
end; {MainCode}


function log(x: real): real;
begin
  log:=ln(x)/ln(10)
end;

function tan(x: real): real;
begin
  tan:=sin(x)/cos(x)
end;

function Savage(a: real): real;
     begin
     Savage := tan (arctan (exp (log (sqrt (A * A))))) + 1.0 ;
end; {savage}

procedure PaintWindow (_hwnd: HWND; sStatus: {SHORT}integer; lCalcRep: LONGint; ulTime: cardinal); {???} cdecl; export;
var
     szMessage: array [0..3-1] of Pchar = ('Ready', 'Working...',
                                    '%d repetitions in %u msec.' );
     szBuffer: array [0..60-1]  of char;
     h_ps: HPS ;
     rcl : RECTL;

begin
     h_ps := WinBeginPaint (_hwnd, 0, nil) ;
     WinQueryWindowRect (_hwnd, rcl) ;

     szBuffer:= format(szMessage [sStatus], [lCalcRep, ulTime]);
     WinDrawText (h_ps, -1, szBuffer, rcl, CLR_NEUTRAL, CLR_BACKGROUND,
                  DT_CENTER or DT_VCENTER or DT_ERASERECT) ;

     WinEndPaint (h_ps) ;
end; {PaintWindow}

