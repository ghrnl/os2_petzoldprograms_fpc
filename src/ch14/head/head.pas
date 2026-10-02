program head;

{/*-------------------------------------
   HEAD.C -- Displays File Head
             (c) Charles Petzold, 1993
  -------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmdev, doscalls, sysutils;
  
{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

const LIT_SORTASCENDING = 65534;
const LIT_END           = 65535;

{$i easyfont_hdr.pas} 
{$i ..\..\ch05\easyfont\easyfont.pas}
{$i head_hdr.pas}

const LCID_FIXEDFONT  = 1;
const LCID_BOLDFONT   = 2;

const
    CCHMAXPATH = 260; {VP has 260 }
    file_Directory = $0010;

var
    szClientClass: Pchar = 'Head' ;

function AboutDlgProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
   done: boolean;

begin

     AboutDlgProc := nil;
     done:=true;
     
     case (msg) of
          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    DID_OK,
                    DID_CANCEL: begin
                         WinDismissDlg (Window, ord(TRUE)) ;
                    end;
               else done:=false;
               end; {inner case}
          end;
          else done:=false;
     end; {case}
     if not done then AboutDlgProc := WinDefDlgProc (Window, msg, mp1, mp2) ;
end; {AboutDlgProc}

const {from VP os2base }
  hdir_Create                  = -1;
  file_Normal                   = $0000;

procedure FillFileListBox (hwnd: cardinal);
var
     findbuf : TFileFindBuf3;
     h_Dir : THandle = HDIR_CREATE ;
     ulReturn: ULONG;
     ulSearchCount : ULONG = 1;

begin
     WinSendDlgItemMsg (hwnd, IDD_FILELIST, LM_DELETEALL, nil, nil) ;

{ DOSCALLS.PP}
{Find first file matching a filemask. In contradiction to DOS, a search
 handle is returned which should be closed with FindClose when done.
 FileMask       = Filemask to search.
 Handle         = Search handle will be returned here, fill with -1 before
                  call.
 Attrib         = File attributes to search for.
 AFileStatus    = Return buffer.
 FileStatusLen  = Size of return buffer.
 Count          = Fill with maximum number of files to search for, the
                  actual number of matching files found is returned here.
 InfoLevel      = One of the ilXXXX constants. Consult IBM documentation
                  for exact meaning. For normal use: Use ilStandard and
                  use PFileFindBuf3 for AFileStatus.}
{function DosFindFirst (FileMask: PChar; var Handle: THandle; Attrib: cardinal;
                      AFileStatus: PFileStatus; FileStatusLen: cardinal;
                      var Count: cardinal; InfoLevel: cardinal): cardinal;
                                                                         cdecl;
function DosFindFirst (const FileMask: string; var Handle: THandle;
                      Attrib: cardinal; AFileStatus: PFileStatus;
                      FileStatusLen: cardinal; var Count: cardinal;
                      InfoLevel: cardinal): cardinal;
}

{Find next matching file.}

     ulReturn := DosFindFirst ('*.*', h_Dir, FILE_NORMAL, @findbuf,
                              sizeof(findbuf), ulSearchCount, FIL_STANDARD) ;

     while (ulReturn=0) do { use =, not <> !!! }
          begin
          WinSendDlgItemMsg (hwnd, IDD_FILELIST, LM_INSERTITEM,
                             MPFROM2SHORT (LIT_SORTASCENDING, 0),
                             (@findbuf.Name[1])) ;

          ulReturn := DosFindNext (h_Dir, @findbuf, sizeof(findbuf),
                                  ulSearchCount) ;
          end;
     DosFindClose (h_Dir) ;
end; {FillFileListBox}

var
   szDrive : Pchar = '  :';

procedure FillDirListBox (hwnd: cardinal; pcCurrentPath: Pchar);

var
     findbuf : TFileFindBuf3;
     h_Dir : longint = HDIR_CREATE ;
     sDrive : integer;
     ulDriveNum, ulDriveMap, ulCurPathLen, ulReturn: ULONG;
     ulSearchCount: ULONG = 1 ;
     
begin

     DosQueryCurrentDisk (ulDriveNum, ulDriveMap) ;
     { note that ASCII seq is ... @ A B C ... etc. }
     pcCurrentPath [0] := char(ulDriveNum + ord('@')) ;
     pcCurrentPath [1] := ':' ;
     pcCurrentPath [2] := '\' ;

     ulCurPathLen := CCHMAXPATH ;
     DosQueryCurrentDir (0, pcCurrentPath[3], ulCurPathLen) ;

     WinSetDlgItemText (hwnd, IDD_PATH, pcCurrentPath) ;
     WinSendDlgItemMsg (hwnd, IDD_DIRLIST, LM_DELETEALL, nil, nil) ;

     for sDrive := 0 to 26-1 do
          if (ulDriveMap and (1 shl sDrive)) >0 then
               begin
               szDrive [1] := char(sDrive + ord('A')) ;

               WinSendDlgItemMsg (hwnd, IDD_DIRLIST, LM_INSERTITEM,
                                  MPFROM2SHORT (LIT_END, 0),
                                  szDrive) ;
               end;

     ulReturn := DosFindFirst ('*.*', h_Dir, FILE_DIRECTORY, @findbuf,
                              sizeof(findbuf), ulSearchCount, FIL_STANDARD) ;

     while (ulReturn=0) do
          begin
          if ((findbuf.attrFile and $0010)>0) and (
                    (findbuf.Name [0] <> '.' ) or (findbuf.Name [1] <> chr(0))) then
               
               WinSendDlgItemMsg (hwnd, IDD_DIRLIST, LM_INSERTITEM,
                                  MPFROM2SHORT (LIT_SORTASCENDING, 0),
                                  @findbuf.Name[1]) ;

          ulReturn := DosFindNext (h_Dir, @findbuf, sizeof(findbuf),
                                  ulSearchCount) ;
          end;

     DosFindClose (h_Dir) ;
end; {FillDirListBox}

{$i ParseFileName.pas}

var
     szFileName:    array [0..CCHMAXPATH-1] of char ;
     szCurrentPath: array [0..CCHMAXPATH-1] of char ;
     szBuffer:      array [0..CCHMAXPATH-1] of char ;

function OpenDlgProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     iSelect : word; {!}
     
     done: boolean;

begin

     OpenDlgProc:=nil;
     done:=not true;
     
     case (msg) of
          
          WM_INITDLG: begin
               FillDirListBox (Window, szCurrentPath) ;
               FillFileListBox (Window) ;

               WinSendDlgItemMsg (Window, IDD_FILEEDIT, EM_SETTEXTLIMIT,
                                        MPFROM2SHORT (CCHMAXPATH, 0), nil) ;
               {return 0 ;} end;

          WM_CONTROL: begin
               if (SHORT1FROMMP (mp1) = IDD_DIRLIST ) or (
                   SHORT1FROMMP (mp1) = IDD_FILELIST) then
                    begin
                    iSelect := SHORT1FROMMP( WinSendDlgItemMsg (Window,
                                                  SHORT1FROMMP (mp1),
                                                  LM_QUERYSELECTION, nil, nil) );

                    WinSendDlgItemMsg (Window, SHORT1FROMMP (mp1),
                                       LM_QUERYITEMTEXT,
                                       MPFROM2SHORT (iSelect, sizeof(szBuffer)),
                                       @szBuffer) ;
                    end;

               case (SHORT1FROMMP (mp1)) of            // Control ID
                    
                    IDD_DIRLIST: begin
                         case (SHORT2FROMMP (mp1)) of  // notification code
                              
                              LN_ENTER: begin
                                   if (szBuffer [0] = ' ') then
                                        DosSetDefaultDisk (
                                             ord(szBuffer [1]) - ord('@'))
                                   else
                                        DosSetCurrentDir (szBuffer) ;

                                   FillDirListBox (Window, szCurrentPath) ;
                                   FillFileListBox (Window) ;

                                   WinSetDlgItemText (Window, IDD_FILEEDIT, '') ;
                                   end;
                              otherwise;
                              end; {ii case}
                         end;

                    IDD_FILELIST: begin
                         case (SHORT2FROMMP (mp1)) of  // notification code
                              
                              LN_SELECT: begin
                                   WinSetDlgItemText (Window, IDD_FILEEDIT,
                                                      szBuffer) ;
                                   end;

                              LN_ENTER: begin
                                   ParseFileName (szFileName, szBuffer) ;
                                   WinDismissDlg (Window, ord(TRUE)) ;
                                   end;
                              otherwise;
                              end; {inner inner case}
                         end; { inner case}
                    otherwise;
                    end; { inner case}
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    DID_OK: begin
                         WinQueryDlgItemText (Window, IDD_FILEEDIT,
                                              sizeof(szBuffer), szBuffer) ;

                         case (ParseFileName (szCurrentPath, szBuffer)) of
                              
                              0: begin
                                   WinAlarm (HWND_DESKTOP, WA_ERROR) ;
                                   FillDirListBox (Window, szCurrentPath) ;
                                   FillFileListBox (Window) ;
                                 end;

                              1: begin
                                   FillDirListBox (Window, szCurrentPath) ;
                                   FillFileListBox (Window) ;
                                   WinSetDlgItemText (Window, IDD_FILEEDIT, '') ;
                                 end;

                              2: begin
                                   strcopy (szFileName, szCurrentPath) ;
                                   WinDismissDlg (Window, ord(TRUE)) ;
                                 end;
                              otherwise;
                              end;
                         end;

                    DID_CANCEL: begin
                         WinDismissDlg (Window, ord(FALSE)) ;
                       end;
                    otherwise;
                    end; {inner case}
               end;
               otherwise done:=false;
     end; {case}

     if not done then OpenDlgProc := WinDefDlgProc (Window, msg, mp1, mp2) ;

end; {OpenDlgProc}

var
     szErrorMsg : Pchar = 'File not found or could not be opened' ;
     cxClient, cyClient, cxChar, cyChar, cyDesc : integer;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

const
  ofRead        = $0000;     {Open for reading}
  ofWrite       = $0001;     {Open for writing}

  {iBufSize = 100 div 2; } {and use it }
  
var
     pcReadBuffer : Pchar; { array [0..iBufSize] of char;}
     fileInput: THandle;
     fm : FONTMETRICS;
     hps : cardinal;
     iLength : integer;
     ptl : POINTL;
     iBufSize: integer;
     { extra}
     done: boolean;
     ipi,linestart: Pchar;

begin

     ClientWndProc := nil;
     done:=true;
     
     case (msg) of
          
          WM_CREATE: begin
               hps := WinGetPS (Window) ;
               EzfQueryFonts (hps) ;

               if (not EzfCreateLogFont (hps, LCID_FIXEDFONT, FONTFACE_MONO,
                                                           FONTSIZE_10, 0))>0 then
                    begin
                    WinReleasePS (hps) ;

                    WinMessageBox (HWND_DESKTOP, HWND_DESKTOP,
                         'Cannot find a fixed-pitch font.  Load the Courier '
                         + 'fonts from the Control Panel and try again.',
                         szClientClass, 0, MB_OK or MB_WARNING) ;

                    ClientWndProc := MRFROMSHORT (1) ;
                    end;

               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               cxChar := fm.lAveCharWidth ;
               cyChar := fm.lMaxBaselineExt ;
               cyDesc := fm.lMaxDescender ;

               GpiSetCharSet (hps, LCID_DEFAULT) ;
               GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
               WinReleasePS (hps) ;
             end;
          
          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
             end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_OPEN: begin
                         if (WinDlgBox (HWND_DESKTOP, Window, @OpenDlgProc,
                                        0, IDD_OPEN, nil))>0 then
                              WinInvalidateRect (Window, nil, FALSE) ;
                         end;

                    IDM_ABOUT: begin
                         WinDlgBox (HWND_DESKTOP, Window, @AboutDlgProc,
                                    0, IDD_ABOUT, nil) ;
                         end;
                    otherwise;
                    end; {inner case}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               if (szFileName [0] <> char(0) {'\0'} ) then
                    begin
                    EzfCreateLogFont (hps, LCID_FIXEDFONT, FONTFACE_MONO,
                                           FONTSIZE_10,    0) ;
                    EzfCreateLogFont (hps, LCID_BOLDFONT,  FONTFACE_MONO,
                                           FONTSIZE_10,    FATTR_SEL_BOLD) ;

                    GpiSetCharSet (hps, LCID_BOLDFONT) ;
                    ptl.x := cxChar ;
                    ptl.y := cyClient - cyChar + cyDesc ;
                    GpiCharStringAt (hps, ptl, strlen (szFileName),
                                     szFileName) ;
                    ptl.y := ptl.y - cyChar ;
                                
                    fileInput := FileOpen (szFileName, ofRead);
                    if ((fileInput) <> feInvalidHandle) then
                         begin
                         GpiSetCharSet (hps, LCID_FIXEDFONT) ;
                         
                         iBufSize := (cxClient div cxChar) * (cyClient div cyChar);
                         pcReadBuffer :=  getmem(iBufSize) ;

                         ptl.y := ptl.y - cyChar;
                         iLength :=  FileRead (fileInput, pcReadBuffer^,
                                 iBufSize );
                         linestart:=pcReadBuffer;
                         while (ptl.y > 0 ) and (iLength <> -1) and (linestart<>nil) do
                              begin
                              ptl.y := ptl.y - cyChar;
                              {iLength := strlen (pcReadBuffer) ;}
                              { 10 or 13 ??? Windows & OS/2 have CRLF = #13 #10 }
                              { test for 10 at end or 13 at (end-1) }
                              ipi:=strscan(linestart,char(10));
                              if (ipi<>nil) then begin
                                   GpiCharStringAt (hps, ptl, (ipi-1)-linestart,
                                                    linestart) ;
                                   linestart:=ipi+1;
                              end
                              else begin {just show the rest}
                                   GpiCharStringAt (hps, ptl, strlen(linestart),
                                                    linestart) ;
                                   linestart:=nil;
                              end;
                              end; {while}
                         freemem (pcReadBuffer) ;
                         FileClose (fileInput) ;
                         end
                    else           // file cannot be opened
                         begin
                         ptl.y := ptl.y - cyChar;
                         GpiCharStringAt (hps, ptl, strlen (szErrorMsg),
                                          szErrorMsg) ;
                         end;
                    GpiSetCharSet (hps, LCID_DEFAULT) ;
                    GpiDeleteSetId (hps, LCID_FIXEDFONT) ;
                    GpiDeleteSetId (hps, LCID_BOLDFONT) ;
                    end;
               WinEndPaint (hps) ;
             end;
          otherwise done := false;
          end; {case}
          
     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab, hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  
begin

   flFrameFlags :=              FCF_TITLEBAR      or FCF_SYSMENU 
                             or FCF_SIZEBORDER    or FCF_MINMAX
                             or FCF_SHELLPOSITION or FCF_TASKLIST
                             or FCF_MENU ;


               // Check for filename parameter and copy to szFileName

     if (argc > 1) then
          ParseFileName (szFileName, argv [1]) ;

               // Continue normally
     
     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, ID_RESOURCE, hwndClient) ;

     if (hwndFrame <> 0) then
          begin
          while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
               WinDispatchMsg (hab, qmsg) ;

          WinDestroyWindow (hwndFrame) ;
          end;

     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
     
end.

