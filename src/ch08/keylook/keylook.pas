program keylook;

{/*----------------------------------------
   KEYLOOK.C -- Displays WM_CHAR Messages
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,pmdev,sysutils;

{$i ..\..\ch00\maxmin.pas}
{$i ..\..\ch00\mousutil.pas}

{ from easyfont.h}
const
  FONTFACE_SYSTEM = 0;
  FONTFACE_MONO   = 1;
  FONTFACE_COUR   = 2;
  FONTFACE_HELV   = 3;
  FONTFACE_TIMES  = 4;

  FONTSIZE_8     =  0;
  FONTSIZE_10    =  1;
  FONTSIZE_12    =  2;
  FONTSIZE_14    =  3;
  FONTSIZE_18    =  4;
  FONTSIZE_24    =  5;

{$i ..\..\ch05\easyfont\easyfont.pas}

const
  LCID_FIXEDFONT =   1;
  MAX_KEYS       = 100;

type
  keyrecord = record
    mp1: pointer;
    mp2: pointer;
    fValid: boolean;
  end;

var
  cxChar, cyChar, cyDesc, cxClient, cyClient, iNextKey: integer;
  key: array [0.. MAX_KEYS-1] of keyrecord;
  szHeader : Pchar = 'Scan  Rept  IN TG IC CM DK LK PD KU AL CT SH SC VK CH  Virt  Char' ;
  szUndrLn : Pchar = '----  ----  -- -- -- -- -- -- -- -- -- -- -- -- -- --  ----  ----' ;
  szFormat : Pchar =
  '%4X %4dx  %2d %2d %2d %2d %2d %2d %2d %2d'
                                 +   ' %2d %2d %2d %2d %2d %2d  %4X  %4X  %1s' ;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
        szBuffer: array[0..80-1] of char ;
        fm : FONTMETRICS;
        hps : cardinal ;
        iKey, iIndex, iFlag : integer;
        ptl : POINTL;
        rcl, rclInvalid : RECTL;
        {extra}
        nkey19: integer;

begin {ClientWindowProc}

     case msg of
         
          WM_CREATE: begin
               hps := WinGetPS (Window) ;
               EzfQueryFonts (hps) ;

               if not(EzfCreateLogFont (hps, LCID_FIXEDFONT, FONTFACE_MONO,
                                                           FONTSIZE_10, 0)>0) then
                    begin
                    WinReleasePS (hps) ;

                    WinMessageBox (HWND_DESKTOP, HWND_DESKTOP,
                         'Cannot find the System Monospaced font.',
                         'KeyLook' {szClientClass}, 0, MB_OK or MB_WARNING) ;
                      {return} MPFROMSHORT (1) ;
                    end

               else begin
               GpiSetCharSet (hps, LCID_FIXEDFONT) ;

               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               cxChar := fm.lAveCharWidth ;
               cyChar := fm.lMaxBaselineExt ;
               cyDesc := fm.lMaxDescender ;

               GpiSetCharSet (hps, LCID_DEFAULT) ;
               GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
               WinReleasePS (hps) ;
end;
             end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
             end;

          WM_CHAR: begin
               key [iNextKey].mp1 := mp1 ;
               key [iNextKey].mp2 := mp2 ;

               key [iNextKey].fValid := TRUE ;

               iNextKey := (iNextKey + 1) mod MAX_KEYS ;

               WinSetRect (Window, rcl,
                           0, 2 * cyChar, cxClient, cyClient - 2 * cyChar) ;

               WinScrollWindow (Window, 0, cyChar, @rcl, @rcl, 0, nil,
                                                 SW_INVALIDATERGN) ;
               WinUpdateWindow (Window) ;
             end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, rclInvalid) ;
               GpiErase (hps) ;
               EzfCreateLogFont (hps, LCID_FIXEDFONT, FONTFACE_MONO,
                                                      FONTSIZE_10, 0) ;
               GpiSetCharSet (hps, LCID_FIXEDFONT) ;

               ptl.x := cxChar ;
               ptl.y := cyDesc ;

               GpiCharStringAt (hps, ptl, strlen(szHeader), szHeader) ;

               ptl.y := ptl.y + cyChar ;
               GpiCharStringAt (hps, ptl, strlen(szUndrLn), szUndrLn) ;

               for iKey := 0  to MAX_KEYS-1 do
                    begin
                    ptl.y := ptl.y + cyChar ;

                    iIndex := (iNextKey - iKey - 1 + MAX_KEYS) mod MAX_KEYS ;

                    if ((ptl.y > rclInvalid.yTop) or
                              (ptl.y > cyClient - 2 * cyChar) or
                                   not(key [iIndex].fValid)) then
                         break ;
                         
                    mp1 := key [iIndex].mp1 ;

                    mp2 := key [iIndex].mp2 ;

                    iFlag := SHORT1FROMMP (mp1) ;

                    nkey19 := iFlag and KC_CHAR ;
                    if  nkey19>0 then
                      nkey19 := ord(CHARMSG(@msg).chr)
                    else
                      nkey19 := ord(' ') ;

                    szBuffer := format(szFormat, [
                    
                                   ord(CHARMSG(@msg).scancode),  // scan code
                                   ord(CHARMSG(@msg).cRepeat),  // repeat count
                                   ord(iFlag and KC_INVALIDCHAR>0),
                                   ord(iFlag and KC_TOGGLE     >0),
                                   ord(iFlag and KC_INVALIDCOMP>0),
                                   ord(iFlag and KC_COMPOSITE  >0),
                                   ord(iFlag and KC_DEADKEY    >0),
                                   ord(iFlag and KC_LONEKEY    >0),
                                   ord(iFlag and KC_PREVDOWN   >0),
                                   ord(iFlag and KC_KEYUP      >0),
                                   ord(iFlag and KC_ALT        >0),
                                   ord(iFlag and KC_CTRL       >0),
                                   ord(iFlag and KC_SHIFT      >0),
                                   ord(iFlag and KC_SCANCODE   >0),
                                   ord(iFlag and KC_VIRTUALKEY >0),
                                   ord(iFlag and KC_CHAR       >0),
                                   ord(CHARMSG(@msg).vkey),  // virtual key
                                   ord(CHARMSG(@msg).chr),  // character
                                   chr(nkey19)] );

                    GpiCharStringAt (hps, ptl, 
                        strlen(szBuffer), szBuffer);

               end; {for}
               ptl.y := cyClient - cyChar + cyDesc ;
               GpiCharStringAt (hps, ptl, strlen(szHeader), szHeader) ;

               ptl.y := ptl.y - cyChar ;

               GpiCharStringAt (hps, ptl, strlen(szUndrLn), szUndrLn) ;

               GpiSetCharSet (hps, LCID_DEFAULT) ;
               GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
               WinEndPaint (hps) ;

             end;
             else;
          end; {case}
       
     ClientWindowProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'KeyLook' ;

begin

  flFrameFlags :=      FCF_TITLEBAR or FCF_SYSMENU
                  or FCF_SIZEBORDER or FCF_MINMAX
               or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWindowProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);
  
end.

