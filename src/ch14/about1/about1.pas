program about1;

{/*---------------------------------------------------------
   ABOUT1.C -- Demonstration of About Box Dialog Procedure
               (c) Charles Petzold, 1993
  ---------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i about_hdr.pas}

function AboutDlgProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

begin

  case (msg) of
    WM_COMMAND: begin
         case COMMANDMSG(@msg).cmd of
           DID_OK,
           DID_CANCEL: WinDismissDlg (Window, ord(TRUE)) ;
           {break ;}
           otherwise ;
         end; {inner case}
         end; {WM_COMMAND}
    otherwise ;
  end; {case}
  AboutDlgProc := WinDefDlgProc (Window, msg, mp1, mp2) ;
end; {AboutDlgProc}

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     done: boolean;
     
begin {ClientWndProc}
    
     ClientWndProc := nil;
     done:=true;
     
     case (msg) of
          
          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_NEW,
                    IDM_OPEN,
                    IDM_SAVE,
                    IDM_SAVEAS: begin
                         WinAlarm (HWND_DESKTOP, WA_NOTE) ;
                         end;

                    IDM_ABOUT: begin
                         WinDlgBox (HWND_DESKTOP, Window, @AboutDlgProc,
                                    0, IDD_ABOUT, nil) ;
                         end;
                    end; {inner case}
               {break ;}
               done:=false;
               end; {WM_COMMAND}

          WM_ERASEBACKGROUND: begin
               ClientWndProc := MRFROMSHORT (1) ;
               end; {WM_ERASEBACKGROUND}
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
  szClientClass: Pchar = 'About1' ;

begin

     flFrameFlags :=      FCF_TITLEBAR      or FCF_SYSMENU or
                          FCF_SIZEBORDER    or FCF_MINMAX  or
                          FCF_SHELLPOSITION or FCF_TASKLIST or
                          FCF_MENU          or FCF_ICON ;

     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, 0, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
				     0, 0, ID_RESOURCE, hwndClient) ;

     while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
          WinDispatchMsg (hab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;

end.

