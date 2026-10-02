program hexcalc2;

{/*-------------------------------------------------------------------
   HEXCALC2.C -- Hexadecimal Calculator with Clipboard Cut and Paste
                 (c) Charles Petzold, 1993
  -------------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, sysutils, doscalls;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i hexcalc_hdr.pas}

{$i isdigit.pas}
{$i isxdigit.pas}
{$i toupper.pas}

const IDM_COPY   = 256;
const IDM_PASTE  = 257;

const
  ULONG_MAX = MAXLONGINT ; {!!!}
  BACKSPACE = 8;
  {ESCAPE = 27;}
  
type MENUITEM = record
        iPosition : integer;
        afStyle : word;
        afAttribute : word;
        id : word;
        hwndSubMenu : cardinal;
        hItem : cardinal;
end;

procedure EnableSysMenuItem (hwnd: cardinal; idItem: integer; fEnable: boolean);

var
     hwndSysMenu : cardinal;

begin

     hwndSysMenu := WinWindowFromID (WinQueryWindow (hwnd, QW_PARENT),
                                    FID_SYSMENU) ;

     WinSendMsg (hwndSysMenu, MM_SETITEMATTR,
                 MPFROM2SHORT (idItem, ord(TRUE)),
                 MPFROM2SHORT (MIA_DISABLED, ord(not fEnable)* MIA_DISABLED)) ;
end; {EnableSysMenuItem}


var
     szMenuText : array [0..3-1] of Pchar = (nil, '~Copy'#09'Ctrl+Ins',
                                               '~Paste'#09'Shift+Ins' );
     mi: array [0..3-1] of MENUITEM =

        ((iPosition: MIT_END; afStyle: MIS_SEPARATOR; afAttribute:0; id:        0;
              HWndSubMenu: 0; hItem: 0 ),
        (iPosition: MIT_END; afStyle: MIS_TEXT;      afAttribute:0; id:IDM_COPY;
              HWndSubMenu: 0; hItem: 0 ),
        (iPosition: MIT_END; afStyle: MIS_TEXT;      afAttribute:0; id: IDM_PASTE;
              HWndSubMenu: 0; hItem: 0 )
        ) ;

type HACCEL = cardinal;

function AddItemsToSysMenu (hab: cardinal; hwndFrame: cardinal): HACCEL;

var
     pacct : ^ACCELTABLE;
     h_accel : HACCEL;
     hwndSysMenu, hwndSysSubMenu : cardinal;
     idSysMenu, iItem : word; {!}
     miSysMenu : MENUITEM;

begin

                              // Add items to system menu

     hwndSysMenu := WinWindowFromID (hwndFrame, FID_SYSMENU) ;
     idSysMenu := SHORT1FROMMR (WinSendMsg (hwndSysMenu,
                                           MM_ITEMIDFROMPOSITION,
                                           nil, nil)) ;

     WinSendMsg (hwndSysMenu, MM_QUERYITEM,
                 MPFROM2SHORT (idSysMenu, ord(FALSE)),
                 @miSysMenu) ;

     hwndSysSubMenu := miSysMenu.hwndSubMenu ;

     for iItem := 0 to 3-1 do
          WinSendMsg (hwndSysSubMenu, MM_INSERTITEM,
                      @mi [iItem],
                      szMenuText [iItem]) ;

                              // Create and set accelerator table

     pacct := {malloc} getmem (sizeof (ACCELTABLE) + sizeof (ACCEL)) ;

     pacct^.cAccel        := 1 ;    // Number of accelerators
     pacct^.codepage      := 0 ;    // Not used

     pacct^.aaccel[0].fs  := AF_VIRTUALKEY or AF_CONTROL ;
     pacct^.aaccel[0].key := VK_INSERT ;
     pacct^.aaccel[0].cmd := IDM_COPY ;
{
     pacct^.cAccel        := 2 ;    // Number of accelerators
     pacct^.aaccel[1].fs  := AF_VIRTUALKEY or AF_SHIFT ;
     pacct^.aaccel[1].key := VK_INSERT ;
     pacct^.aaccel[1].cmd := IDM_PASTE ;
}
     h_accel := WinCreateAccelTable (hab, pacct) ;
     WinSetAccelTable (hab, h_accel, hwndFrame) ;

     freemem (pacct) ;

     AddItemsToSysMenu := h_accel ;
end; {AddItemsToSysMenu}

procedure ShowNumber (hwnd: cardinal; ulNumber: ULONG);

var
   szBuffer: Pchar;

begin
     szBuffer:=Pchar(format('%X', [ulNumber]));
     WinSetWindowText (WinWindowFromID (hwnd, ESCAPE), szBuffer) ;
end; {ShowNumber}

function CalcIt (ulFirstNum: ULONG; iOperation: char; ulNum: ULONG): ULONG;
begin
     case (iOperation) of
          '=' : CalcIt :=  ulNum ;
          '+' : CalcIt :=  ulFirstNum +  ulNum ;
          '-' : CalcIt :=  ulFirstNum -  ulNum ;
          '*' : CalcIt :=  ulFirstNum *  ulNum ;
          '&' : CalcIt :=  ulFirstNum and  ulNum ;
          '|' : CalcIt :=  ulFirstNum or   ulNum ;
          '^' : CalcIt :=  ulFirstNum XOR  ulNum ;
          '<' : CalcIt :=  ulFirstNum shl ulNum ;
          '>' : CalcIt :=  ulFirstNum shr ulNum ;
          '/' : if (ulNum>0) then
                   CalcIt := ulFirstNum div ulNum
                else
                   CalcIt :=  ULONG_MAX ;
          '%' :  if (ulNum>0) then
                   CalcIt := ulFirstNum mod ulNum
                else
                   CalcIt :=  ULONG_MAX ;
          else CalcIt := 0 ;
     end; {case}
          
end; {CalcIt}

var
     fNewNumber: boolean = TRUE ;
     iOperation : char = '=' ;
     ulNumber, ulFirstNum : ULONG;

     habWP : cardinal ;
     h_accel : HACCEL;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     hwndButton : cardinal;
     i, iLen, idButton : integer ;
     pchClipText : Pchar;
     qmsg : TQMSG;
     {extra}
     done: boolean;
     itemp : integer;
     cmsg_chr: integer;
     cmsg_fs: integer;

begin {}
     
     ClientWndProc:=nil;
     done:=true;
     
     case  (msg) of

         WM_CREATE: begin
               habWP := WinQueryAnchorBlock (Window) ;
               h_accel := AddItemsToSysMenu (habWP,
                              WinQueryWindow (Window, QW_PARENT)) ;
               end;

          
          WM_CHAR: begin
               if (CHARMSG(@msg).fs and KC_KEYUP)>0 then

               ELSE BEGIN
               
               if (CHARMSG(@msg).fs and KC_VIRTUALKEY)>0 then
                    case (CHARMSG(@msg).vkey) of
                         
                         VK_LEFT: begin
                              if (not(CHARMSG(@msg).fs and KC_CHAR))>0 then
                                   begin {backspace}
                                   cmsg_chr:=BACKSPACE; {ord('\b')}
                                   cmsg_fs:=CHARMSG(@msg).fs or KC_CHAR ;
                                   end;
                              end;

                         VK_ESC: begin
                              cmsg_chr:=ESCAPE;
                              cmsg_fs:=CHARMSG(@msg).fs or KC_CHAR ;
                              end;

                         VK_NEWLINE,
                         VK_ENTER: begin
                              cmsg_chr:=ord('=');
                              cmsg_fs:=CHARMSG(@msg).fs or KC_CHAR ;
                              end;
                         end {inner case}
               else begin
                 cmsg_fs:=CHARMSG(@msg).fs;
               end;

               if (cmsg_fs and KC_CHAR)>0 then
                    begin
                    cmsg_chr:= toupper (CHARMSG(@msg).chr) ;

                    hwndButton := WinWindowFromID (Window, cmsg_chr) ;

                    if (hwndButton <> 0) then
                         WinSendMsg (hwndButton, BM_CLICK, nil, nil) 
                    else
                         WinAlarm (HWND_DESKTOP, WA_ERROR) ;
                    end
               END
               end;

          WM_COMMAND: begin
               idButton := COMMANDMSG(@msg).cmd;

               if (idButton = IDM_COPY) then                // "Copy"
                    begin
                    hwndButton := WinWindowFromID (Window, ESCAPE) ;
                    iLen := WinQueryWindowTextLength (hwndButton) + 1 ;
                    
                    DosAllocSharedMem (pchClipText, nil, iLen,
                                       PAG_COMMIT or PAG_READ or PAG_WRITE or
                                       OBJ_TILE or OBJ_GIVEABLE) ;
                                     
                    WinQueryWindowText (hwndButton, iLen, pchClipText) ;

                    WinOpenClipbrd (habWP) ;
                    WinEmptyClipbrd (habWP) ;
                    WinSetClipbrdData (habWP, ULONG(pchClipText), CF_TEXT,
                                       CFI_POINTER) ;
                    WinCloseClipbrd (habWP) ;
                    end

               else if (idButton = IDM_PASTE) then          // "Paste"
                    begin
                    EnableSysMenuItem (Window, IDM_COPY,  FALSE) ;
                    EnableSysMenuItem (Window, IDM_PASTE, FALSE) ;

                    WinOpenClipbrd (habWP) ;

                    pchClipText := {(PVOID)}
                         Pchar (WinQueryClipbrdData (habWP, CF_TEXT)) ;

                    if (pchClipText <> nil ) then
                         begin
                         for i := 0 to {ord(pchClipText[i])-1} strlen(pchClipText)-1 do
                              begin
                              if (pchClipText[i] = char(13) {'\r'}) then
                                   WinSendMsg (Window, WM_CHAR,
                                               MPFROM2SHORT (KC_CHAR, 1),
                                               MPFROM2SHORT (ord('='), 0)) 

                              else if (pchClipText[i] <> char(10) {'\n'} ) and (
                                       pchClipText[i] <> ' ') then
                                   WinSendMsg (Window, WM_CHAR,
                                               MPFROM2SHORT (KC_CHAR, 1),
                                               MPFROM2SHORT (ord(pchClipText[i]),
                                                             0)) ;

                              while (WinPeekMsg (habWP, qmsg, 0,
                                                 0, 0, PM_NOREMOVE)) do
                                   begin
                                   if (qmsg.msg = WM_QUIT) then
                                        begin
                                        WinCloseClipbrd (habWP) ;
                                        {return 0 ;}
                                        end
                                   else
                                        begin
                                        WinGetMsg (habWP, qmsg, 0,
                                                               0, 0) ;
                                        WinDispatchMsg (habWP, qmsg) ;
                                        end;
                                   end;
                              end;
                         end;
                    WinCloseClipbrd (habWP) ;

                    EnableSysMenuItem (Window, IDM_COPY,  TRUE) ;
                    EnableSysMenuItem (Window, IDM_PASTE, TRUE) ;
                    end

               else if (idButton = BACKSPACE) then begin            // backspace
                    ulNumber := ulNumber div 16;
                    ShowNumber (Window, ulNumber)
               end

               else if (idButton = ESCAPE) then begin          // escape
                    ulNumber := 0;
                    ShowNumber (Window, ulNumber)
               end

               else if (isxdigit (idButton)) then              // hex digit
                    begin
                    if (fNewNumber) then
                         begin
                         ulFirstNum := ulNumber ;
                         ulNumber := 0 ;
                         end;
                    fNewNumber := FALSE ;

                    if isdigit (idButton) then
                       itemp := ord('0')
                    else
                       itemp := ord('A') - 10;
                    
                    if (ulNumber <= ULONG_MAX shr 4) then begin
                         ulNumber := 16 * ulNumber + idButton -
                                   itemp;
                         ShowNumber (Window, ulNumber) ;
                         end
                    else
                         WinAlarm (HWND_DESKTOP, WA_ERROR) ;
                    end
               else                                         // operation
                    begin
                    if (not fNewNumber) then begin
                         ulNumber :=
                              CalcIt (ulFirstNum, iOperation, ulNumber);
                         ShowNumber (Window, ulNumber) ;
                    end;
                    fNewNumber := TRUE ;
                    iOperation := char(idButton) ;
                    end;
               end;

          WM_BUTTON1DOWN: begin
               WinAlarm (HWND_DESKTOP, WA_ERROR) ;
               end;

          WM_ERASEBACKGROUND: begin
               ClientWndProc := MRFROMSHORT (1) ;
          end;
          
          WM_DESTROY: begin
               WinDestroyAccelTable (h_accel) ;
               end;
          else done:=false;
          end; {case}

     if not done then  ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame: cardinal;

begin

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, CLIENTCLASS, @ClientWndProc, 0, 0) ;

  hwndFrame := WinLoadDlg (HWND_DESKTOP, HWND_DESKTOP,
                                 nil, 0, ID_HEXCALC, nil) ;
  
  WinSendMsg (hwndFrame, WM_SETICON,
                 pointer(WinLoadPointer (HWND_DESKTOP, 0, ID_ICON)), nil) ;

  WinSetFocus (HWND_DESKTOP, WinWindowFromID (hwndFrame, FID_CLIENT)) ;

  while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

