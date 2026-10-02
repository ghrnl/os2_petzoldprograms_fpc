program popmenu;

{/*----------------------------------------
   POPMENU.C -- Popup Menu Demonstration
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i popmenu_hdr.pas}

var
     hwndMenuPopup : cardinal;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     hps : cardinal;
     ptlMouse : POINTL;
     { extra }
     done: boolean;

begin

     ClientWndProc:=nil;
     done:=true;
     
     case (msg) of
          
          WM_CREATE: begin
               hwndMenuPopup := WinLoadMenu (Window, 0, ID_RESOURCE) ;
               end;

          WM_BUTTON2DOWN: begin
               ptlMouse.x := SHORT1FROMMP (mp1) ;
               ptlMouse.y := SHORT2FROMMP (mp1) ;

               WinMapWindowPoints (Window, HWND_DESKTOP, ptlMouse, 1) ;

               WinPopupMenu (HWND_DESKTOP, Window, hwndMenuPopup,
                             ptlMouse.x, ptlMouse.y, 0,
                             PU_HCONSTRAIN   or PU_VCONSTRAIN   or
                             PU_MOUSEBUTTON1 or PU_MOUSEBUTTON2 or
                             PU_KEYBOARD) ;
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_ABOUT: begin
                         WinMessageBox (HWND_DESKTOP, Window,
                                        '(C) Charles Petzold (C version), 1993'#10#13
                                      + '(C) Gert Renkema (fpc), 2023',
                                        'PopMenu', 0, MB_OK) ;
                         end;
                    end;
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;
               WinEndPaint (hps) ;
               end;
          else done:=false;
          end; {case}

     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'PopMenu' ;

begin

  flFrameFlags :=     FCF_TITLEBAR      or FCF_SYSMENU
                   or FCF_SIZEBORDER    or FCF_MINMAX
                   or FCF_SHELLPOSITION or FCF_TASKLIST
                   or FCF_MENU;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, ID_RESOURCE, hwndClient) ;

  while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

