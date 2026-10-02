program bigjob1;

{/*-------------------------------------------------------
   BIGJOB1.C -- Naive approach to lengthy processing job
                (c) Charles Petzold, 1993
 --------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\commandmsg.pas}
{$i ..\..\ch00\winmenuitems.pas}

{$i ..\bigjob00\bigjob_hdr.pas}
{$i ..\bigjob00\bigjob.pas}


{ r bigjob.res}

var
     h_ab : HAB;
     hwndMenu: HWND;
     iCurrentRep : integer = IDM_10 ;
     iStatus : integer = STATUS_READY ;
     lCalcRep: LONGint;
     lRepAmts : array  [0..5-1] of LONGint = (10, 100, 1000, 10000, 100000) ;
     ulElapsedTime : ULONG;
     A : real;
     lRep : LONGint;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
begin

     case (msg) of
          
          WM_CREATE: begin
               h_ab := WinQueryAnchorBlock (Window) ;

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
                         WinEnableMenuItem (hwndMenu, IDM_START, FALSE) ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, TRUE) ;

                         iStatus := STATUS_WORKING ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                         WinUpdateWindow (Window) ;

                         WinSetPointer (HWND_DESKTOP,
                                   WinQuerySysPointer (HWND_DESKTOP,
                                                       SPTR_WAIT, FALSE)) ;

                         if (WinQuerySysValue (HWND_DESKTOP, SV_MOUSEPRESENT)
                                   = 0) then
                              WinShowPointer (HWND_DESKTOP, TRUE) ;

                         lCalcRep := lRepAmts [iCurrentRep - IDM_10] ;
                         ulElapsedTime := WinGetCurrentTime (h_ab) ;

                         A:=1.0;
                         for lRep :=0 to lCalcRep-1 do
                           A := Savage (A) ;

                         ulElapsedTime := WinGetCurrentTime (h_ab) -
                                        ulElapsedTime ;

                         if (WinQuerySysValue (HWND_DESKTOP, SV_MOUSEPRESENT)
                                  = 0) then
                              WinShowPointer (HWND_DESKTOP, FALSE) ;

                         WinSetPointer (HWND_DESKTOP,
                                   WinQuerySysPointer (HWND_DESKTOP,
                                                       SPTR_ARROW, FALSE)) ;
                         iStatus := STATUS_DONE ;
                         WinInvalidateRect (Window, nil, FALSE) ;
                         WinUpdateWindow (Window) ;

                         WinEnableMenuItem (hwndMenu, IDM_START, TRUE) ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, FALSE) ;
                         end;

                    IDM_ABORT: begin   // Not much we can do here
                         end;
                    otherwise;
                    end; {inner case}
               
               end;

          WM_PAINT: begin
               PaintWindow (Window, iStatus, lCalcRep, ulElapsedTime) ;
               end;
          otherwise ;
          end;
          
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}
 
begin
  MainCode ('BigJob1', 'BigJob1 - The Bad Program') ;
end.

