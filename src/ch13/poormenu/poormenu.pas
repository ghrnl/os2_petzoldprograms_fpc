program poormenu;

{/*-----------------------------------------
   POORMENU.C -- Poor Person's Menu
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

const IDM_ABOUT   = 10;
const IDM_HELP    = 11;

type MENUITEM = record
        iPosition : integer;
        afStyle : word;
        afAttribute : word;
        id : word;
        hwndSubMenu : cardinal;
        hItem : cardinal;
end;

var
    szCaption: Pchar = 'Poor Person''s Menu' ;
    szClientClass: PChar = 'PoorMenu' ;

var
     szMenuText: array [0..3-1] of Pchar = (
                                         '', { '' or nil, same effect }
                                         'A~bout PoorMenu...',
                                         '~Help...' ) ;
     mi: array [0..3-1] of MENUITEM = (
        (iPosition: MIT_END; afStyle: MIS_SEPARATOR; afAttribute:0; id:        0;
              HWndSubMenu: 0; hItem: 0 ),
        (iPosition: MIT_END; afStyle: MIS_TEXT;      afAttribute:0; id:IDM_ABOUT;
              HWndSubMenu: 0; hItem: 0 ),
        (iPosition: MIT_END; afStyle: MIS_TEXT;      afAttribute:0; id: IDM_HELP;
              HWndSubMenu: 0; hItem: 0 )
        ) ;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     hwndSysMenu, hwndSysSubMenu : cardinal;
     iItem, idSysMenu : word; {!}
     miSysMenu : MENUITEM;
     { extra }
     done: boolean;

begin

     ClientWndProc:=nil;
     done:= true;
     
     case (msg) of
          
          WM_CREATE: begin
               hwndSysMenu := WinWindowFromID (
                                  WinQueryWindow (Window, QW_PARENT),
                                  FID_SYSMENU) ;

               idSysMenu := SHORT1FROMMR (WinSendMsg (hwndSysMenu,
                                                     MM_ITEMIDFROMPOSITION,
                                                     nil, nil)) ;

               WinSendMsg (hwndSysMenu, MM_QUERYITEM,
                           MPFROM2SHORT (idSysMenu, ord(FALSE)),
                           @miSysMenu) ;
 
               hwndSysSubMenu := miSysMenu.hwndSubMenu ;

               for iItem := 0  to 3-1 do
                    WinSendMsg (hwndSysSubMenu, MM_INSERTITEM,
                                @mi[iItem],
                                szMenuText [iItem]) ;

               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_ABOUT: begin
                         WinMessageBox (HWND_DESKTOP, Window,
                                   '(C) Charles Petzold (C version), 1993'#10#13
                                   + '(C) Gert Renkema (fpc), 2023',
                                   szCaption, 0, MB_OK or MB_INFORMATION) ;
                         end;

                    IDM_HELP: begin
                         WinMessageBox (HWND_DESKTOP, Window,
                                   'Help not yet implemented',
                                   szCaption, 0, MB_OK or MB_WARNING) ;
                         end;
                    else done:=false;
                    end; {inner case}
               end;

          WM_ERASEBACKGROUND: begin
               ClientWndProc := MRFROMSHORT (1) ;
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

begin

  flFrameFlags :=     FCF_TITLEBAR      or FCF_SYSMENU
                   or FCF_SIZEBORDER    or FCF_MINMAX
                   or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

