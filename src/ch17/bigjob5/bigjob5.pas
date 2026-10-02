program bigjob5;

{/*--------------------------------------------------
   BIGJOB5.C -- Second thread and semaphore trigger
                (c) Charles Petzold, 1993
 ---------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, doscalls, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\longfrommp.pas}
{$i ..\..\ch00\mpfromlong.pas}
{$i ..\..\ch00\commandmsg.pas}
{$i ..\..\ch00\winmenuitems.pas}

{$i ..\bigjob00\bigjob_hdr.pas}
{$i ..\bigjob00\bigjob.pas}

var
  FThreadID: cardinal;
  
function CalcThread (pArg: pointer): longint;

var
     A : real;
     hab : cardinal ;
     lRep, lTime : longint ;
     pcp : PCALCPARAM ;
     ulPostCount : ULONG;
     
begin

     hab := WinInitialize (0) ;
     pcp := PCALCPARAM(pArg) ;

     while (TRUE) do
          begin
          DosWaitEventSem (pcp^.hevTrigger, SEM_INDEFINITE_WAIT) ;

          lTime := WinGetCurrentTime (hab) ;
          
          A := 1.0;
          for lRep := 0  to (pcp^.lCalcRep-1) {&& pcp^.fContinueCalc} do {DISABLED}
               A := Savage (A) ;

          DosResetEventSem (pcp^.hevTrigger, ulPostCount) ;

          if (pcp^.fContinueCalc) then
               begin
               lTime := WinGetCurrentTime (hab) - lTime ;
               WinPostMsg (pcp^.h_wnd, WM_CALC_DONE, MPFROMLONG (lTime), nil) ;
               end
          else
               WinPostMsg (pcp^.h_wnd, WM_CALC_ABORTED, nil, nil) ;
          end;

     WinTerminate (hab) ;
     endthread (FThreadID);
     
     CalcThread := 0
     
end; {CalcThread}

var
     cp: CALCPARAM ;
     hwndMenu : cardinal;
     tidCalc : integer;
     iCurrentRep : integer = IDM_10 ;
     iStatus : integer = STATUS_READY ;
     lRepAmts: array[0..5-1] of longint = (10, 100, 1000, 10000, 100000);
     ulElapsedTime : ULONG;
     
function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
{ extra }
var
  flags: cardinal = 0;

begin

     case (msg) of
          
          WM_CREATE: begin
               hwndMenu := WinWindowFromID (
                               WinQueryWindow (Window, QW_PARENT),
                               FID_MENU) ;

               cp.h_wnd := Window ;

               DosCreateEventSem (nil, cp.hevTrigger, 0, FALSE) ;

                         tidCalc := beginthread (nil,
                                                 STACKSIZE,
                                                 @CalcThread,
                                                 @cp,
                                                 flags,
                                                 FThreadID);

                end;

          WM_INITMENU: begin
               if (tidCalc = 0 ) and (SHORT1FROMMP (mp1) = IDM_ACTION) then
                    WinEnableMenuItem (Window, IDM_START, FALSE) ;
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_10,
                    IDM_100,
                    IDM_1000,
                    IDM_10000,
                    IDM_100000: begin
                         WinCheckMenuItem (hwndMenu, iCurrentRep, FALSE) ;
                         iCurrentRep := COMMANDMSG(@msg).cmd ;
                         WinCheckMenuItem (hwndMenu, iCurrentRep, TRUE) ;
                         end;

                    IDM_START: begin
                         cp.lCalcRep := lRepAmts [iCurrentRep - IDM_10] ;
                         cp.fContinueCalc := TRUE ;
                         DosPostEventSem (cp.hevTrigger) ;

                         iStatus := STATUS_WORKING ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                         WinEnableMenuItem (hwndMenu, IDM_START, FALSE) ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, TRUE) ;
                         end;

                    IDM_ABORT: begin
                         cp.fContinueCalc := FALSE ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, FALSE) ;
                         end;
                    end; {inner case}
               
               end;

          WM_CALC_DONE: begin
               iStatus := STATUS_DONE ;
               ulElapsedTime := LONGFROMMP (mp1) ;
               WinInvalidateRect (Window, nil, FALSE) ;
               WinEnableMenuItem (hwndMenu, IDM_START, TRUE) ;
               WinEnableMenuItem (hwndMenu, IDM_ABORT, FALSE) ;
               end;

          WM_CALC_ABORTED: begin
               iStatus := STATUS_READY ;
               WinInvalidateRect (Window, nil, FALSE) ;
               WinEnableMenuItem (hwndMenu, IDM_START, TRUE) ;
               end;

          WM_PAINT: begin
               PaintWindow (Window, iStatus, cp.lCalcRep, ulElapsedTime) ;
               end;

          WM_DESTROY: begin
               if (iStatus = STATUS_WORKING) then
                    DosKillThread (tidCalc) ;
               end;
     end; {case}
     
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

begin
  MainCode ('BigJob5', 'BigJob5 - A Second Thread with Semaphore') ;
end.

