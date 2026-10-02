program bigjob2;

{/*-------------------------------------------------------
   BIGJOB2.C -- Timer approach to lengthy processing job
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


const ID_TIMER = 1;

var
      A : real;
     lRep : LONGint;
     h_ab : HAB;
     hwndMenu: HWND;
     iCurrentRep : integer = IDM_10 ;
     iStatus : integer = STATUS_READY ;
     lCalcRep: LONGint;
     lRepAmts : array  [0..5-1] of LONGint = (10, 100, 1000, 10000, 100000) ;
     ulElapsedTime : ULONG;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
begin
 
     case  (msg) of
          
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

                    IDM_START:  begin
                         if (WinStartTimer (h_ab, Window, ID_TIMER, 0)=0) then
                              begin
                              WinAlarm (HWND_DESKTOP, WA_ERROR) ;
                              
                              end
                         else begin
                         WinEnableMenuItem (hwndMenu, IDM_START, FALSE) ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, TRUE) ;

                         iStatus := STATUS_WORKING ;
                         WinInvalidateRect (Window, nil, FALSE) ;

                         lCalcRep := lRepAmts [iCurrentRep - IDM_10] ;
                         ulElapsedTime := WinGetCurrentTime (h_ab) ;
                         A := 1.0 ;
                         lRep := 0 ;

                         
                         end;
                         end;

                    IDM_ABORT: begin
                         WinStopTimer (h_ab, Window, ID_TIMER) ;

                         iStatus := STATUS_READY ;
                         WinInvalidateRect (Window, nil, FALSE) ;

                         WinEnableMenuItem (hwndMenu, IDM_START, TRUE) ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, FALSE) ;
                         
                         end;
                      otherwise;
                    end; {inner case}
               
               end;

          WM_TIMER: begin
               A := Savage (A) ;

               lRep:=lRep+1;
               if (lRep = lCalcRep) then
                    begin
                    ulElapsedTime := WinGetCurrentTime (h_ab) -
                                        ulElapsedTime ;

                    WinStopTimer (h_ab, Window, ID_TIMER) ;

                    iStatus := STATUS_DONE ;
                    WinInvalidateRect (Window, nil, FALSE) ;

                    WinEnableMenuItem (hwndMenu, IDM_START, TRUE) ;
                    WinEnableMenuItem (hwndMenu, IDM_ABORT, FALSE) ;
                    end;
                    
               end;

          WM_PAINT: begin
               PaintWindow (Window, iStatus, lCalcRep, ulElapsedTime) ;
               
               end;

          WM_DESTROY: begin
               if (iStatus = STATUS_WORKING) then
                    WinStopTimer (h_ab, Window, ID_TIMER) ;
               
               end;
          otherwise;
          end; {case}

     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

begin
  MainCode ('BigJob2', 'BigJob2 - The Timer') ;
end.

