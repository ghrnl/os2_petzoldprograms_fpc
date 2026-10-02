program grafmenu;

{/*-----------------------------------------
   GRAFMENU.C -- A Menu with Graphics
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i grafmenu_hdr.pas}

type MENUITEM = record
        iPosition : word; {word or integer; orig has integer}
        afStyle : word;
        afAttribute : word;
        id : word;
        hwndSubMenu : cardinal;
        hItem : cardinal;
end;

var
     szClientClass: PChar = 'GrafMenu' ;

var
     miBigHelp: MENUITEM = (iPosition: 0;          // iPosition
                            afStyle: MIS_BITMAP or MIS_HELP;   // afStyle
                            afAttribute: 0;        // afAttribute
                            id: IDM_HELP;          // id
                            HWndSubMenu: 0;        // hwndSubMenu
                            hItem: 0 ) ;           // hItem

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     fm  : FONTMETRICS;
     hbm : cardinal;
     hps : cardinal;
     hwndMenu: cardinal;
     {extra}
     done: boolean;

begin

     ClientWndProc:=nil;
     done:=true; {!!!}
     
     case (msg) of
          
          WM_CREATE: begin
                    {/*----------------------
                       Load bitmap resource
                      ----------------------*/}
               hps := WinGetPS (Window) ;
               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               hbm := GpiLoadBitmap (hps, 0, IDB_BIGHELP,
                                     64 * fm.lAveCharWidth div 3,
                                     64 * fm.lMaxBaselineExt div 8) ;

               WinReleasePS (hps) ;
               
                    {/*-----------------------
                       Attach bitmap to menu
                      -----------------------*/}
               miBigHelp.hItem := hbm ;
               hwndMenu := WinWindowFromID (
                               WinQueryWindow (Window, QW_PARENT),
                               FID_MENU) ;

               WinSendMsg (hwndMenu, MM_SETITEM,
                           MPFROM2SHORT (0, ord(TRUE)),
                           @miBigHelp) ;
               end; {WM_CREATE}

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    IDM_NEW,
                    IDM_OPEN,
                    IDM_SAVE,
                    IDM_SAVEAS,
                    IDM_ABOUT: WinAlarm (HWND_DESKTOP, WA_NOTE) ;
                    otherwise done:=false;
                    end; {inner case}
               end; {WM_COMMAND}

          WM_HELP: begin
               WinMessageBox (HWND_DESKTOP, Window,
                              'Help not yet implemented',
                              szClientClass, 0, MB_OK or MB_WARNING) ;
               end; {WM_HELP}

          WM_ERASEBACKGROUND: begin
                 ClientWndProc := MRFROMSHORT (1) ;
               end; {WM_ERASEBACKGROUND}

          otherwise done:=false;
     end; {case}
          
     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;

begin

  flFrameFlags :=     FCF_TITLEBAR      or FCF_SYSMENU
                   or FCF_SIZEBORDER    or FCF_MINMAX
                   or FCF_SHELLPOSITION or FCF_TASKLIST
                   or FCF_MENU ;

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

