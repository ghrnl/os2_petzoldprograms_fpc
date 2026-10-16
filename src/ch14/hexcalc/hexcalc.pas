program hexcalc;

{/*----------------------------------------
   HEXCALC.C -- Hexadecimal Calculator
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4  GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, sysutils;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i hexcalc_hdr.pas}

{$i isdigit.pas}
{$i isxdigit.pas}
{$i toupper.pas}

const
  ULONG_MAX = MAXLONGINT ; {!!!}
  BACKSPACE = 8;
  {ESCAPE = 27;}
  
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

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     hwndButton : cardinal;
     idButton: integer ;
     {extra}
     done: boolean;
     itemp : integer;
     cmsg_chr: integer;
     cmsg_fs: integer;

begin
     
     ClientWndProc:=nil;
     done:=true;
     
     case  (msg) of
          
          WM_CHAR: begin
               if (CHARMSG(@msg).fs and KC_KEYUP)>0 then
                    {return 0 ;}
                    {end}

               ELSE BEGIN
               
               if (CHARMSG(@msg).fs and KC_VIRTUALKEY)>0 then
                    case (CHARMSG(@msg).vkey) of
                         
                         VK_LEFT: begin
                              if (not(CHARMSG(@msg).fs and KC_CHAR))>0 then
                                   begin {backspace}
                                   cmsg_chr:=BACKSPACE;
                                   cmsg_fs:=CHARMSG(@msg).fs or KC_CHAR ;
                                   end;
                              {break ;}
                              end;

                         VK_ESC: begin
                              cmsg_chr:=ESCAPE;
                              cmsg_fs:=CHARMSG(@msg).fs or KC_CHAR ;
                              {break ;}
                              end;

                         VK_NEWLINE,
                         VK_ENTER: begin
                              cmsg_chr:=ord('=');
                              cmsg_fs:=CHARMSG(@msg).fs or KC_CHAR ;
                              {break ;}
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
               {return 0 ;}
               END
               end;

          WM_COMMAND: begin
               idButton := COMMANDMSG(@msg).cmd ;

               if (idButton = BACKSPACE) then begin            // backspace
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
               {return 0 ;}
               end;

          WM_BUTTON1DOWN: begin
               WinAlarm (HWND_DESKTOP, WA_ERROR) ;
               {break ;}
               end;

          WM_ERASEBACKGROUND: begin
               ClientWndProc := MRFROMSHORT (1) ;
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

