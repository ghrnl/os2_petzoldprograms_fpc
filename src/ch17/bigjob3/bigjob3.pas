program bigjob3;

{/*--------------------------------------------------------------
   BIGJOB3.C -- Peek Message approach to lengthy processing job
                (c) Charles Petzold, 1993
 ---------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\commandmsg.pas}
{$i ..\..\ch00\winmenuitems.pas}

{$i ..\bigjob00\bigjob_hdr.pas}
{$i ..\bigjob00\bigjob.pas}

var
     fContinueCalc : boolean = FALSE ;
     hab: cardinal ;
     hwndMenu: cardinal ;
     iStatus : integer = STATUS_READY ;
     iCurrentRep : integer = IDM_10 ;
     lCalcRep: longint;
     lRepAmts : array [0..5-1] of longint = (10, 100, 1000, 10000, 100000);
     ulElapsedTime : longint;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     A : real ;
     lRep : longint;
     qmsg : TQmsg;

begin

     case (msg) of
          
          WM_CREATE: begin
               hab := WinQueryAnchorBlock (Window) ;

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

                         lCalcRep := lRepAmts [iCurrentRep - IDM_10] ;
                         fContinueCalc := TRUE ;
                         ulElapsedTime := WinGetCurrentTime (hab) ;

                         qmsg.msg := WM_NULL ;

                         
                         A := 1.0;
                         for lRep := 0 to lCalcRep-1 do
                              begin
                              A := Savage (A) ;

                              while (WinPeekMsg (hab, qmsg, 0,
                                                 0, 0, PM_NOREMOVE)) do
                                   begin
                                   if (qmsg.msg = WM_QUIT) then
                                        break ;

                                   WinGetMsg (hab, qmsg, 0, 0, 0) ;
                                   WinDispatchMsg (hab, qmsg) ;

                                   if (not fContinueCalc) then
                                        break ;
                                   end;
                              if (not fContinueCalc) or (qmsg.msg = WM_QUIT) then
                                   break ;
                              end;
                         ulElapsedTime := WinGetCurrentTime (hab) - 
                                                  ulElapsedTime ;

                         if (not fContinueCalc ) or ( qmsg.msg = WM_QUIT) then
                              iStatus := STATUS_READY
                         else
                              iStatus := STATUS_DONE ;

                         WinInvalidateRect (Window, nil, FALSE) ;

                         WinEnableMenuItem (hwndMenu, IDM_START, TRUE) ;
                         WinEnableMenuItem (hwndMenu, IDM_ABORT, FALSE) ;
                         end;

                    IDM_ABORT: begin
                         fContinueCalc := FALSE ;
                         end;
                    end;
               
               end;

          WM_PAINT: begin
               PaintWindow (Window, iStatus, lCalcRep, ulElapsedTime) ;
               end;
          otherwise;
     end; {case}

     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

begin
  MainCode ('BigJob3', ' BigJob3 - Message Peeking') ;
end.

