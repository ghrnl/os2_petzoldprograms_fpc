program showbit;

{/*--------------------------------------------------------------------
   SHOWBIT.C -- Loads Bitmap Resources from BITLIB.DLL and Draws Them
                (c) Charles Petzold, 1993
  --------------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, doscalls;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}

var
    hmodBitLib : longint;
    idBitmap : integer = 1 ;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     hbm : HBITMAP;
     h_ps : HPS;
     rcl : RECTL;
     
     xb1,xb2,xb3: boolean;
     done: boolean;
     dummystr: shortstring;

begin
     
     ClientWndProc:=nil;
     done:=true;
     dummystr:='';
     
     case (msg) of
          
          WM_CREATE: begin
               if (DosLoadModule (dummystr, 0, 'BITLIB', hmodBitLib))>0 then
                    begin
                    WinMessageBox (HWND_DESKTOP, HWND_DESKTOP,
                                   'Cannot load BITLIB.DLL library',
                                   'ShowBit', 0, MB_OK or MB_WARNING) ;

                    ClientWndProc := MRFROMSHORT (1) ;
                    end;
               end;

          WM_CHAR: begin
               xb1:= (CHARMSG(@msg).fs and KC_KEYUP)>0;
               xb2:= (not(CHARMSG(@msg).fs and KC_VIRTUALKEY))>0;
               xb3:= not(CHARMSG(@msg).vkey = VK_SPACE);
               if ( xb1 ) or (
                    xb2 ) or (
                    xb3 ) then
                         {break} 
               ELSE BEGIN
               idBitmap := idBitmap + 1;
               if (idBitmap = 10) then
                    idBitmap := 1 ;

               WinInvalidateRect (Window, nil, FALSE) ;
               END;
             end;

          WM_BUTTON1DOWN: begin
               idBitmap := idBitmap + 1;
               if (idBitmap = 10) then
                    idBitmap := 1 ;

               WinInvalidateRect (Window, nil, FALSE) ;
               end;

          WM_PAINT: begin
               h_ps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (h_ps) ;

               hbm := GpiLoadBitmap (h_ps, hmodBitLib, idBitmap, 0, 0) ;

               if (hbm <> 0) then
                    begin
                    WinQueryWindowRect (Window, rcl) ;

                    WinDrawBitmap (h_ps, hbm, nil, PPOINTL(@rcl),
                                   CLR_NEUTRAL, CLR_BACKGROUND, DBM_STRETCH) ;

                    GpiDeleteBitmap (hbm) ;               
                    end;
               WinEndPaint (h_ps) ;
               end;

          WM_DESTROY: begin
               DosFreeModule (hmodBitLib) ;
               end;
               
          otherwise done:=false;
          
          end; {case}
          
     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}
 
{ MAIN PROGRAM }

var
   szClientClass : Pchar = 'ShowBit';

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame, hwndClient : cardinal;
  flFrameFlags: cardinal;

begin

  flFrameFlags :=    FCF_TITLEBAR      or FCF_SYSMENU
                  or FCF_SIZEBORDER    or FCF_MINMAX
                  or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass,
                                     'ShowBit' +
                                     ' (Space bar or mouse click for next)',
                                     0, 0, 0, hwndClient) ;
                    
  if (hwndFrame <> 0) then
    begin
          while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
               WinDispatchMsg (hab, qmsg) ;
          WinDestroyWindow (hwndFrame) ;
    end;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

