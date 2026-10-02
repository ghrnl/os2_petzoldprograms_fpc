program bigjob4;

{/*---------------------------------------------------------------
   BIGJOB4.C -- Second thread approach to lengthy processing job
                (c) Charles Petzold, 1993
 ----------------------------------------------------------------*/}
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
     hab : cardinal;
     lRep, lTime: longint ;
     pcp : PCALCPARAM;

begin

     hab := WinInitialize (0) ;
     pcp := PCALCPARAM(pArg) ;
     lTime := WinGetCurrentTime (hab) ;

     A := 1.0;
     for lRep := 0 to (pcp^.lCalcRep-1) {and pcp^.fContinueCalc} do

          A := Savage (A) ;

     DosEnterCritSec ;     // So thread is dead when message retrieved

     if (pcp^.fContinueCalc) then
          begin
          lTime := WinGetCurrentTime (hab) - lTime ;
          WinPostMsg (pcp^.h_wnd, WM_CALC_DONE, MPFROMLONG (lTime), nil) ;
          end
     else
          WinPostMsg (pcp^.h_wnd, WM_CALC_ABORTED, nil, nil) ;

     WinTerminate (hab) ;
     endthread (FThreadID) ;
     
     CalcThread := 0;
     
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
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_10,
                    IDM_100,
                    IDM_1000,
                    IDM_10000,
                    IDM_100000: begin
                         WinCheckMenuItem (hwndMenu, iCurrentRep, FALSE) ;
                         iCurrentRep := COMMANDMSG(@msg).cmd;
                         WinCheckMenuItem (hwndMenu, iCurrentRep, TRUE) ;
                         end;

                    IDM_START: begin
                         cp.h_wnd := Window ;
                         cp.lCalcRep := lRepAmts [iCurrentRep - IDM_10] ;
                         cp.fContinueCalc := TRUE ;

                         { FPC RTL: On error, the value "0" is returned } 
                         tidCalc := beginthread (nil,
                                                 STACKSIZE,
                                                 @CalcThread,
                                                 @cp,
                                                 flags,
                                                 FThreadID);

                         if (0 = tidCalc) then
                              begin
                              WinAlarm (HWND_DESKTOP, WA_ERROR) ;
                              
                              end
                              
                              
                         else begin

                         iStatus := STATUS_WORKING ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                         WinEnableMenuItem (hwndMenu, IDM_START, FALSE) ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, TRUE) ;
                         end;
                         end;

                    IDM_ABORT: begin
                         cp.fContinueCalc := FALSE ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, FALSE) ;
                         end;
                    end;
               
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
               otherwise;
     end; {case}
     
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

begin
  MainCode ('BigJob4', 'BigJob4 - A Second Thread') ;
end.

