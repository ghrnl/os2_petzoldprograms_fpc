program convmenu;

{/*-----------------------------------------
   CONVMENU.C -- Conventional Menu Use
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\commandmsg.pas}

const
  ID_TIMER =  1;

{ header }
const
   ID_RESOURCE     = 1;

   IDM_FILE        =  1;    // Top-level items
   IDM_TIMER       =  2;
   IDM_BACKGROUND  =  3;
   IDM_TOPHELP     =  4;

   IDM_NEW         =  10;   // "File" submenu
   IDM_OPEN        =  11;
   IDM_SAVE        =  12;
   IDM_SAVEAS      =  13;
   IDM_EXIT        =  14;

   IDM_START       =  20;   // "Timer" submenu
   IDM_STOP        =  21;

   IDM_WHITE       =  30;   // "Background" submenu
   IDM_LTGRAY      =  31;
   IDM_GRAY        =  32;        // Program logic assumes these
   IDM_DKGRAY      =  33;        // five numbers are consecutive
   IDM_BLACK       =  34;

   IDM_HELP        =  40;   // "Help" submenu
   IDM_ABOUT       =  41;

var
  szClientClass: PChar = 'Convmenu' ;
  hab: cardinal;

{ moved up }
var
  iCurrentBackground: integer = IDM_WHITE ;
  fTimerGoing: boolean;
  hwndMenu: cardinal;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     colBackground: array [0..5-1] of longint;
     hps : cardinal ;
     rcl: RECTL;

{ extra }
     tmp1: integer;
     tmp1B: boolean;
     tmp2: integer;

     xalTable: longint;

begin

  colBackground[0]:= $FFFFFF;
  colBackground[1]:= $C0C0C0;
  colBackground[2]:= $808080;
  colBackground[3]:= $404040;
  colBackground[4]:= $000000;

  ClientWindowProc := nil;

  case msg of
          WM_CREATE: begin
             hwndMenu := WinWindowFromID (
                              WinQueryWindow (window, QW_PARENT),
                              FID_MENU) ;
              end;

          WM_INITMENU: begin
               case SHORT1FROMMP (mp1) of
                   IDM_TIMER: begin
                   if WinQuerySysValue (HWND_DESKTOP, SV_CTIMERS)>0 then
                     tmp1:=0 else tmp1:=MIA_DISABLED;
                     tmp1B:=not(fTimerGoing) and (tmp1>0);
                     if tmp1B then tmp1:=1 else tmp1:=0;
                         WinSendMsg (hwndMenu, MM_SETITEMATTR,
                                   MPFROM2SHORT (IDM_START,ord(TRUE)),
                                   MPFROM2SHORT (MIA_DISABLED, 
                                           tmp1)) ;

                   if fTimerGoing then tmp2:=0 else tmp2:= MIA_DISABLED;
                   WinSendMsg (hwndMenu, MM_SETITEMATTR,
                                  MPFROM2SHORT (IDM_STOP, ord(TRUE)),
                                  MPFROM2SHORT (MIA_DISABLED,
                                  tmp2) ) ;
                    end; {IDM_TIMER}
                end; {case}
           end; {WM_INITMENU}
              
          WM_COMMAND: begin
               
               case COMMANDMSG(@msg).cmd of
                    
                     IDM_NEW: begin
                         WinMessageBox (HWND_DESKTOP, window,
                                   'Bogus "New" Dialog',
                                   szClientClass, 0, MB_OK or MB_INFORMATION) ;
                         end;

                     IDM_OPEN: begin
                         WinMessageBox (HWND_DESKTOP, window,
                                   'Bogus "Open" Dialog',
                                   szClientClass, 0, MB_OK or MB_INFORMATION) ;
                         end;

                     IDM_SAVE: begin
                         WinMessageBox (HWND_DESKTOP, window,
                                   'Bogus "Save" Dialog',
                                   szClientClass, 0, MB_OK or MB_INFORMATION) ;
                         end;

                     IDM_SAVEAS: begin
                         WinMessageBox (HWND_DESKTOP, window,
                                   'Bogus "Save As" Dialog',
                                   szClientClass, 0, MB_OK or MB_INFORMATION) ;
                         end;

                     IDM_EXIT: begin
                         WinSendMsg (window, WM_CLOSE, NIL, NIL) ;
                         end;

                     IDM_START: begin
                         if (WinStartTimer ( hab, window, ID_TIMER, 1000)>0) then
                              fTimerGoing := TRUE 
                         else
                              WinMessageBox (HWND_DESKTOP, window,
                                   'Too many clocks or timers',
                                   szClientClass, 0,
                                   MB_OK or MB_WARNING) ;
                         end;

                     IDM_STOP: begin
                         WinStopTimer (hab, window, ID_TIMER) ;
                         fTimerGoing := FALSE ;
                         end;

                     IDM_WHITE,
                     IDM_LTGRAY,
                     IDM_GRAY,
                     IDM_DKGRAY,
                     IDM_BLACK:  begin
                         WinSendMsg (hwndMenu, MM_SETITEMATTR,
                                     MPFROM2SHORT (iCurrentBackground, ord(TRUE)),
                                     MPFROM2SHORT (MIA_CHECKED, 0)) ;

                         iCurrentBackground := COMMANDMSG(@msg).cmd;

                         WinSendMsg (hwndMenu, MM_SETITEMATTR,
                                     MPFROM2SHORT (iCurrentBackground, ord(TRUE)),
                                     MPFROM2SHORT (MIA_CHECKED, MIA_CHECKED)) ;

                         WinInvalidateRect (window, nil, FALSE) ;
                       end;

                    IDM_HELP: begin
                         WinMessageBox (HWND_DESKTOP, window,
                                   'Bogus "Help" Dialog',
                                   szClientClass, 0, MB_OK or MB_INFORMATION) ;
                         end;

                    IDM_ABOUT: begin
                         WinMessageBox (HWND_DESKTOP, window,
                                   'Bogus "About" Dialog',
                                   szClientClass, 0, MB_OK or MB_INFORMATION) ;
                         end;
                    end; { inner case }

        end; {WM_COMMAND}

         WM_HELP: begin
               WinMessageBox (HWND_DESKTOP, window,
                              'Help not yet implemented',
                              szClientClass, 0, MB_OK or MB_WARNING) ;
               end;

          WM_TIMER: begin
               WinAlarm (HWND_DESKTOP, WA_NOTE) ;
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiSavePS (hps) ;

               GpiCreateLogColorTable (hps, 0, LCOLF_RGB, 0, 0, xalTable) ;

               WinQueryWindowRect (window, rcl) ;

               WinFillRect (hps, rcl,
                            colBackground [iCurrentBackground - IDM_WHITE]) ;

               GpiRestorePS (hps, -1) ;
               WinEndPaint (hps) ;

             end;

          WM_DESTROY: begin
               if (fTimerGoing) then
                    begin
                    WinStopTimer (hps, window, ID_TIMER) ;
                    fTimerGoing := FALSE ;
                    end;
             end;
          
          else  ;
          
      end; {case}
      
      ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;
      
end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;

begin

  iCurrentBackground := IDM_WHITE;
  fTimerGoing := FALSE;
  
  flFrameFlags :=    FCF_TITLEBAR      or FCF_SYSMENU
                  or FCF_SIZEBORDER    or FCF_MINMAX
                  or FCF_SHELLPOSITION or FCF_TASKLIST
                  or FCF_MENU          or FCF_ACCELTABLE;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWindowProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, ID_RESOURCE, hwndClient) ;

     while (TRUE) do
          begin
          while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
               WinDispatchMsg (hab, qmsg) ;

          if (MBID_OK = WinMessageBox (HWND_DESKTOP, hwndClient,
                                        'Really want to end program?',
                                        szClientClass, 0,
                                        MB_OKCANCEL or MB_QUERY)) then
               break ;

          WinCancelShutdown (hmq, FALSE) ;
          end;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

