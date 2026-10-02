program printcal;

{/*-----------------------------------------
   PRINTCAL.C -- Print a calendar
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmshl, pmdev, sysutils, doscalls;
    
const LCID_CALFONT         = 1;
const STACKSIZE            = 8192;
const WM_USER_PRINT_OK     = (WM_USER + 0);
const WM_USER_PRINT_ERROR  = (WM_USER + 1);

type CALPARAMS = record
       iYear, iMonthBeg, iMonthEnd : integer ;
     end;
     PCALPARAMS = ^CALPARAMS;

type THREADPARAMS = record
       cp: CALPARAMS;
       hwndNotify : cardinal ;
     end;
     PTHREADPARAMS = ^THREADPARAMS ;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxminlong.pas}
{$i ..\..\ch00\commandmsg.pas}
{$i ..\..\ch00\makefixed.pas}
{$i  ..\..\ch00\strcspn.pas}

{$i printdc.pas}
{$i printcal_hdr.pas}


var
   uiActiveThreads : word = 0;

function AboutDlgProc (hwnd, msg: cardinal; mp1, mp2: pointer): pointer;
  cdecl; export;

begin
     case (msg) of
          WM_COMMAND:
               case COMMANDMSG(@msg).cmd of  
                    DID_OK,
                    DID_CANCEL: WinDismissDlg (hwnd, ord(TRUE)) ;
                    end; {inner case}
               {break ;}
          end; {case}
     AboutDlgProc := WinDefDlgProc (hwnd, msg, mp1, mp2) ;
end; {AboutDlgProc}

procedure Message (hwnd: cardinal; sIcon: integer; pszMessage: Pchar);
begin
     WinMessageBox (HWND_DESKTOP, hwnd, pszMessage, 'PrintCal',
                    0, sIcon or MB_OK or MB_MOVEABLE) ;
end; {Message}

var
     apszMonths: array [0..11] of Pchar = ( 'January', 'February', 'March',
                                     'April',   'May',      'June',
                                     'July',    'August',   'September',
                                     'October', 'November', 'December') ;
     aiMonthLen: array [0..11] of integer = ( 31, 28, 31, 30, 31, 30,
                                     31, 31, 30, 31, 30, 31 );
     aiMonthStart: array [0..11] of integer = (0,  3,  3,  6,  1,  4,
                                      6,  2,  5,  0,  3,  5 ) ;
  
procedure DisplayPage (hps: cardinal; psizlPage: PSIZEL; iYear, iMonth: integer);
cdecl; export;

var
     szBuffer: Pchar;
     fLeap : boolean;
     fat : FATTRS;
     iDayStart, iDay, iExtraDay : integer;
     lLength : longint;
     ptl : POINTL;
     aptlTextBox: array [0..TXTBOX_COUNT-1] of POINTL;
     sizfx : SIZEF;
     sizlCell : SIZEL;
     
     { extra }
     xxx: str8;

begin {DisplayPage}

     {xxx := '        ';}
     GpiSavePS (hps) ;

               // Determine size of day cell

     sizlCell.cx := (psizlPage^.cx - 1) div 7 ;
     sizlCell.cy := (psizlPage^.cy - 1) div 7 ;

               // Create the vector font and use it in the PS

     fat.usRecordLength  := sizeof (fat) ;
     fat.fsSelection     := 0 ;
     fat.lMatch          := 0 ;
     fat.idRegistry      := 0 ;
     fat.usCodePage      := GpiQueryCp (hps) ;
     fat.lMaxBaselineExt := 0 ;
     fat.lAveCharWidth   := 0 ;
     fat.fsType          := 0 ;
     fat.fsFontUse       := FATTR_FONTUSE_OUTLINE or
                           FATTR_FONTUSE_TRANSFORMABLE ;

     strcopy (fat.szFacename, 'Helvetica') ;

     GpiCreateLogFont (hps, xxx, LCID_CALFONT, fat) ;
     GpiSetCharSet (hps, LCID_CALFONT) ;

               // Scale the font for the month and year name

     szBuffer := Pchar(format('%s %d', [apszMonths[iMonth], iYear]));
     lLength := strlen(szBuffer);
     GpiQueryTextBox (hps, lLength, szBuffer, TXTBOX_COUNT, aptlTextBox[0]) ;
     GpiQueryCharBox (hps, sizfx) ;

     sizfx.cx := sizlCell.cx * sizfx.cx div aptlTextBox[TXTBOX_CONCAT].x * 7 ;
     sizfx.cy := sizlCell.cy * sizfx.cy div (aptlTextBox[TXTBOX_TOPLEFT].y -
                                          aptlTextBox[TXTBOX_BOTTOMLEFT].y) ;

     sizfx.cx := min (sizfx.cx, sizfx.cy);
     sizfx.cy := sizfx.cx;
     GpiSetCharBox (hps, sizfx) ;
     GpiQueryTextBox (hps, lLength, szBuffer, TXTBOX_COUNT, aptlTextBox[0]) ;

               // Display month and year at top of page

     ptl.x := (psizlPage^.cx - aptlTextBox[TXTBOX_CONCAT].x) div 2 ;
     ptl.y :=  6 * sizlCell.cy - aptlTextBox[TXTBOX_BOTTOMLEFT].y ;
     GpiCharStringAt (hps, ptl, lLength, szBuffer) ;

               // Set font size for day numbers

     sizfx.cx := MAKEFIXED(min (sizlCell.cx, sizlCell.cy) div 4, 0) ;
     sizfx.cy := sizfx.cx;
     GpiSetCharBox (hps, sizfx) ;

               // Calculate some variables for showing days in month

     fLeap := (iYear mod 4 = 0) and ((iYear mod 100 <> 0) or (iYear mod 400 <> 0)) ;
     if iMonth = 1 then
       iExtraDay := ord(fLeap) and 1
     else
       iExtraDay := ord(fLeap) and 0;

     iDayStart  := 1 + iYear - 1900 + (iYear - 1901) div 4 ;
     iDayStart := iDayStart + aiMonthStart[iMonth] + (ord(fLeap) and ord(iMonth > 1)) ;
     iDayStart := iDayStart mod 7 ;

               // Loop through days

     for iDay := 0 to aiMonthLen[iMonth] + iExtraDay - 1 do
          begin
          ptl.x :=      (iDayStart + iDay) mod 7  * sizlCell.cx ;
          ptl.y := (5 - (iDayStart + iDay) div 7) * sizlCell.cy ;
          GpiMove (hps, ptl) ;

          ptl.x := ptl.x + sizlCell.cx ;
          ptl.y := ptl.y + sizlCell.cy ;
          GpiBox (hps, DRO_OUTLINE, ptl, 0, 0) ;

          szBuffer := Pchar(format(' %d', [iDay+1]));
          lLength := strlen(szBuffer);
          GpiQueryTextBox (hps, lLength, szBuffer, TXTBOX_COUNT, aptlTextBox[0]) ;

          GpiQueryCurrentPosition (hps, ptl) ;
          ptl.y := ptl.y + sizlCell.cy - aptlTextBox[TXTBOX_TOPLEFT].y ;
          GpiCharStringAt (hps, ptl, lLength, szBuffer) ;
          end;
               // Clean up

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_CALFONT) ;
     GpiRestorePS (hps, -1) ;
end; {DisplayPage}

function PrintThread (pArg: pointer): longint; export;

var
     hab : cardinal ;
     hdcPrinter : cardinal ;
     hpsPrinter : cardinal ;
     msgReturn : integer;
     iMonth : integer;
     sizlPage : SIZEL;
     ptp : PTHREADPARAMS ;
     {extra}
     arg4: pointer = nil;
     PStitle: array [0..7] of char = 'Calendar';
     { PStitle not Pchar otherwise it doesn't show up in ps :: %%Title: Calendar }
     arg5: longint = 0;
     arg6: pointer = nil;

begin

     ptp := PTHREADPARAMS(pArg) ;
     hab := WinInitialize (0) ;

     hdcPrinter := OpenDefaultPrinterDC (hab);
     if (hdcPrinter <> DEV_ERROR) then
          begin
                    // Create the presentation space for the printer

          sizlPage.cx := 0 ;
          sizlPage.cy := 0 ;
          hpsPrinter := GpiCreatePS (hab, hdcPrinter, sizlPage,
                                    PU_ARBITRARY or GPIF_DEFAULT or
                                    GPIT_MICRO   or GPIA_ASSOC) ;

          GpiQueryPS (hpsPrinter, sizlPage) ;

                    // Start the document

          if (DevEscape (hdcPrinter, DEVESC_STARTDOC,
                         8, PStitle, arg5, arg6) <> DEVESC_ERROR) then
               begin
                        // Loop through months

               for iMonth  := ptp^.cp.iMonthBeg to
                     ptp^.cp.iMonthEnd do
                    begin
                    DisplayPage (hpsPrinter, @sizlPage, ptp^.cp.iYear, iMonth);

                    arg4:=nil; arg5:=0; arg6:=nil;
                    DevEscape (hdcPrinter, DEVESC_NEWFRAME,
                               0, arg4, arg5, arg6) ;
                    end; {for}

                         // End the document

               arg4:=nil; arg5:=0; arg6:=nil;
               DevEscape (hdcPrinter, DEVESC_ENDDOC, 0, arg4, arg5, arg6) ;
               msgReturn := WM_USER_PRINT_OK ;
               end
          else
               msgReturn := WM_USER_PRINT_ERROR ;

                    // Clean up

          GpiDestroyPS (hpsPrinter) ;
          DevCloseDC (hdcPrinter) ;
          end
     else
          msgReturn := WM_USER_PRINT_ERROR ;

               // Post message to client window and end thread

     DosEnterCritSec ;
     WinPostMsg (ptp^.hwndNotify, msgReturn, pointer(ptp), nil) ;
     WinTerminate (hab) ;
     endthread ;
     
     PrintThread:=0
     
end; {PrintThread}

var
    cpLocal: CALPARAMS;
    pcpCurrent : PCALPARAMS;

function PrintDlgProc (hwnd, msg: cardinal; mp1, mp2: pointer): pointer;
      cdecl ;export;

begin

     case (msg) of
          
          WM_INITDLG: begin
               pcpCurrent := PCALPARAMS (mp2) ;
               cpLocal := pcpCurrent^ ;

               WinSendDlgItemMsg (hwnd, IDD_MONTHBEG + cpLocal.iMonthBeg,
                                  BM_SETCHECK, MPFROM2SHORT (ord(TRUE), 0), nil) ;

               WinSendDlgItemMsg (hwnd, IDD_MONTHEND + cpLocal.iMonthEnd,
                                  BM_SETCHECK, MPFROM2SHORT (ord(TRUE), 0), nil) ;

               WinSendDlgItemMsg (hwnd, IDD_YEAR, EM_SETTEXTLIMIT,
                                  MPFROM2SHORT (4, 0), nil) ;


               WinSetDlgItemShort (hwnd, IDD_YEAR, cpLocal.iYear, FALSE) ;
               end;

          WM_CONTROL: begin
               if (SHORT1FROMMP (mp1) >= IDD_MONTHBEG ) and (
                   SHORT1FROMMP (mp1) <  IDD_MONTHBEG + 12) then

                    cpLocal.iMonthBeg := SHORT1FROMMP (mp1) - IDD_MONTHBEG

               else if (SHORT1FROMMP (mp1) >= IDD_MONTHEND ) and (
                        SHORT1FROMMP (mp1) <  IDD_MONTHEND + 12) then

                    cpLocal.iMonthEnd := SHORT1FROMMP (mp1) - IDD_MONTHEND ;
               end;

          WM_COMMAND: begin
               
               case COMMANDMSG(@msg).cmd of 
                    DID_OK,
                    IDD_PREVIEW: begin
                         WinQueryDlgItemShort (hwnd, IDD_YEAR,
                                               @cpLocal.iYear, FALSE) ;

                         if (cpLocal.iYear < 1900 ) or ( cpLocal.iYear > 2099) then
                              begin
                              Message (hwnd, MB_ICONEXCLAMATION,
                                       'Year must be between 1900 and 2099!') ;
                              WinSetFocus (HWND_DESKTOP,
                                           WinWindowFromID (hwnd, IDD_YEAR)) ;
                              end

                         else if (cpLocal.iMonthBeg > cpLocal.iMonthEnd) then
                              begin
                              Message (hwnd, MB_ICONEXCLAMATION,
                                       'Begin month cannot be later '
                                      + 'than end month!') ;
                              WinSetFocus (HWND_DESKTOP,
                                   WinWindowFromID (hwnd,
                                        IDD_MONTHBEG + cpLocal.iMonthBeg)) ;
                              end
                              
                         else begin
                         
                         { EITHER pcpCurrent := @cpLocal OR pcpCurrent^ := cpLocal }
                         { with  pcpCurrent^ := cpLocal I get strange effects }
                         { with  pcpCurrent := @cpLocal the preview doesnt change }
                         {*} {pcpCurrent := @cpLocal ;}
                         pcpCurrent^.iYear := cpLocal.iYear;
                         pcpCurrent^.iMonthBeg := cpLocal.iMonthBeg;
                         pcpCurrent^.iMonthEnd := cpLocal.iMonthEnd;
                         
                                                       // fall through
                         
                         { copy stmt from DID_CANCEL below }
                         WinDismissDlg (hwnd,SHORT1FROMMP(mp1) ) ;
                         end;
                         end;
                    DID_CANCEL: begin
                         WinDismissDlg (hwnd, COMMANDMSG(@msg).cmd ) ;
                    end;
                    otherwise;
                    end; {inner case}
               {break ;}
               end; {WM_COMMAND}
               otherwise ;
          end; {case}

     PrintDlgProc := WinDefDlgProc (hwnd, msg, mp1, mp2) ;

end; {PrintDlgProc}

var
     cp : CALPARAMS;
     habWP : cardinal;
     hps : cardinal;
     sizlClient : SIZEL;

function  ClientWndProc (hwnd, msg: cardinal; mp1, mp2: pointer): pointer;
         cdecl; export;

var
     dt : TDATETIME;
     hdc : cardinal;
     iResult : integer;
     sizlPage : SIZEL;
     ptp : PTHREADPARAMS;
     {extra}
     flags: cardinal;
     FThreadID: cardinal;

label IDM_PRINT_DONE;
  
begin

     flags:=0;

     case (msg) of
          
          WM_CREATE: begin
               habWP := WinQueryAnchorBlock (hwnd) ;
               hdc := WinOpenWindowDC (hwnd) ;
               sizlPage.cx := 0 ;
               sizlPage.cy := 0 ;
               hps := GpiCreatePS (habWP, hdc, sizlPage,
                                  PU_ARBITRARY or GPIF_DEFAULT or
                                  GPIT_MICRO   or GPIA_ASSOC) ;

               DosGetDateTime (dt) ;
               cp.iYear     := dt.year ;
               cp.iMonthBeg := dt.month - 1 ;
               cp.iMonthEnd := dt.month - 1 ;
               end;

          WM_SIZE: begin
               sizlClient.cx := SHORT1FROMMP (mp2) ;
               sizlClient.cy := SHORT2FROMMP (mp2) ;

               GpiConvert (hps, CVTC_DEVICE, CVTC_PAGE, 1,
                           POINTL(sizlClient) ) ;
               end;

          WM_PAINT: begin
               WinBeginPaint (hwnd, hps, nil) ;

               GpiErase (hps) ;
               DisplayPage (hps, @sizlClient, cp.iYear, cp.iMonthBeg) ;

               WinEndPaint (hps) ;
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_ABOUT: begin
                         WinDlgBox (HWND_DESKTOP, hwnd, @AboutDlgProc,
                                    0, IDD_ABOUT, nil) ;
                         end; {IDM_ABOUT}

                    IDM_PRINT: begin
                         iResult := WinDlgBox (HWND_DESKTOP, hwnd, @PrintDlgProc,
                                              0, IDD_PRINT, @cp) ;

                         if (iResult = DID_CANCEL) then
                              goto IDM_PRINT_DONE;
                              
                         WinInvalidateRect (hwnd, nil, FALSE) ;

                         if (iResult = IDD_PREVIEW) then
                              goto IDM_PRINT_DONE;
                              
                         getmem (ptp,sizeof (THREADPARAMS));
                         if (ptp = nil) then
                              begin
                              Message (hwnd, MB_ICONEXCLAMATION,
                                  'Cannot allocate memory for print thread!') ;
                              goto IDM_PRINT_DONE;
                              end;

                         ptp^.cp         := cp ;
                         ptp^.hwndNotify := hwnd ;

                         if (0 = beginthread(
                                              nil,
                                              STACKSIZE,
                                              @PrintThread,
                                              ptp,
                                              flags,
                                              FThreadID)) then
                              begin
                              freemem (ptp) ;
                              Message (hwnd, MB_ICONEXCLAMATION,
                                       'Cannot create print thread!') ;
                              end
                              else begin
                              inc(uiActiveThreads) ;
                              Message (hwnd, MB_ICONASTERISK,
                                       'Print job successfully started.') ;
                              end;
                    IDM_PRINT_DONE:
                         end; {IDM_PRINT}
                    otherwise;
                    end; {inner case}

               {break ;}
               end; {WM_COMMAND}

          WM_USER_PRINT_OK: begin
               ptp := PTHREADPARAMS(mp1) ;
               freemem (ptp) ;
               dec(uiActiveThreads) ;
               Message (hwnd, MB_ICONASTERISK,
                        'Print job sent to spooler.') ;
               end;

          WM_USER_PRINT_ERROR: begin
               ptp := PTHREADPARAMS(mp1) ;
               freemem (ptp) ;
               dec(uiActiveThreads) ;
               Message (hwnd, MB_ICONEXCLAMATION,
                        'Error encountered during printing.') ;
               end;

          WM_DESTROY: begin
               GpiDestroyPS (hps) ;
               end;
          otherwise;
      end; {case}

     ClientWndProc := WinDefWindowProc (hwnd, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }
   
var
     habmain : cardinal;
     hmq : cardinal ;
     hwndFrame, hwndClient : cardinal;
     qmsg: TQMsg ;
     szClientClass: Pchar  = 'PrintCal' ;
     flFrameFlags: cardinal;

begin
      
     habmain := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (habmain, 0) ;
     WinRegisterClass (habmain, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     flFrameFlags := FCF_TITLEBAR      or FCF_SYSMENU or
                     FCF_SIZEBORDER    or FCF_MINMAX  or
                     FCF_MENU          or
                     FCF_SHELLPOSITION or FCF_TASKLIST ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, ID_RESOURCE, hwndClient) ;
     while (TRUE) do
        begin

          while (WinGetMsg (habmain, qmsg, 0, 0, 0)) do
               WinDispatchMsg (habmain, qmsg) ;

          if (uiActiveThreads = 0) then
               break ;

          Message (hwndClient, MB_ICONEXCLAMATION,
                   'Printing thread still active.'#10#13
                 + 'Program cannot be closed now.') ;

          WinCancelShutdown (hmq, FALSE) ;
        end;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (habmain) ;
     
end.

