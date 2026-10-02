program pattdlg;

{/*--------------------------------------------------
   PATTDLG.C -- Select GPI Patterns from Dialog Box
                (c) Charles Petzold, 1993
  --------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, pmshl;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}
{$i ..\..\ch00\commandmsg.pas}

{$i ..\..\ch00\winbuttons.pas}

{$i pattdlg_hdr.pas}

type
  PATTERNSDATA = record
  iPattern: integer ;
  iColor  : integer ;
  fBorder : boolean ;
end;

PPATTERNSDATA = ^PATTERNSDATA;

var
     pdLocal : PATTERNSDATA;
     ppdCurrent : PPATTERNSDATA;
     
function PatternDlgProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

begin

     case (msg) of
          
          WM_INITDLG: begin
               ppdCurrent := PPATTERNSDATA(mp2) ;
               pdLocal := ppdCurrent^ ;

               WinCheckButton (Window, pdLocal.iPattern, ord(TRUE)) ;
               WinCheckButton (Window, pdLocal.iColor,   ord(TRUE)) ;
               WinCheckButton (Window, IDD_BORDER,       ord(pdLocal.fBorder)) ;

               WinSetFocus (HWND_DESKTOP,
                            WinWindowFromID (Window, pdLocal.iPattern)) ;

               PatternDlgProc := MRFROMSHORT (1) ;
               end;

          WM_CONTROL: begin
               if (SHORT1FROMMP (mp1) >= IDD_DENSE1 ) and (
                   SHORT1FROMMP (mp1) <= IDD_DIAGHATCH) then
                    begin
                    WinCheckButton (Window, pdLocal.iPattern, ord(FALSE)) ;
                    pdLocal.iPattern := SHORT1FROMMP (mp1) ;
                    WinCheckButton (Window, pdLocal.iPattern, ord(TRUE)) ;
                    end

               else if (SHORT1FROMMP (mp1) >= IDD_BKGRND ) and (
                        SHORT1FROMMP (mp1) <= IDD_PALEGRAY) then
                    begin
                    WinCheckButton (Window, pdLocal.iColor, ord(FALSE)) ;
                    pdLocal.iColor := SHORT1FROMMP (mp1) ;
                    WinCheckButton (Window, pdLocal.iColor, ord(TRUE)) ;
                    end;
               {return 0 ;}
               end;
               

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    DID_OK: begin
                         pdLocal.fBorder := (WinQueryButtonCheckstate
                                                     (Window, IDD_BORDER)>0) ;
                         ppdCurrent^ := pdLocal ;

                         WinDismissDlg (Window, ord(TRUE)) ;
                         {return 0 ;}
                         end;

                    DID_CANCEL: begin
                         WinDismissDlg (Window, ord(FALSE)) ;
                         {return 0 ;}
                         end;
                    end; {inner case}
               {break ;}
               end;
          end; {case}
          
     PatternDlgProc := WinDefDlgProc (Window, msg, mp1, mp2) ;
     
end; {PatternDlgProc}

const WM_USER_QUERYSAVE = (WM_USER + 1);

function AboutDlgProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

begin
     case (msg) of
          
           WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    DID_OK,
                    DID_CANCEL: begin
                         WinDismissDlg (Window, ord(TRUE)) ;
                         {return 0 ;}
                         end;
                    otherwise;
                    end; {inner case}
               {break ;}
               end;
          end; {case}
     AboutDlgProc := WinDefDlgProc (Window, msg, mp1, mp2) ;
end; {AboutDlgProc}

var
     szAppName : Pchar = 'PATTDLG' ;
     szKeyName : Pchar = 'SETTINGS' ;
     cxClient, cyClient : integer;
     pdCurrent : PATTERNSDATA = (iPattern: IDD_DENSE1; iColor:IDD_BKGRND; fBorder:TRUE);

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     hps : cardinal;
     ptl : POINTL ;
     ulDataLength: ULONG ;

begin

     case (msg) of
          
          WM_CREATE: begin
               ulDataLength := sizeof(pdCurrent) ;

               PrfQueryProfileData (cardinal(HINI_USERPROFILE), szAppName, szKeyName,
                                    pdCurrent, ulDataLength) ;
               {return 0 ;}
               end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
               {return 0 ;}
               end;

          WM_COMMAND: begin
               case COMMANDMSG(@msg).cmd of
                    
                    IDM_PATTERNS: begin
                         if (WinDlgBox (HWND_DESKTOP, Window, @PatternDlgProc,
                                        0, IDD_PATTERNS, @pdCurrent))>0 then

                              WinInvalidateRect (Window, nil, FALSE) ;
                         {return 0 ;}
                         end;

                    IDM_ABOUT: begin
                         WinDlgBox (HWND_DESKTOP, Window, @AboutDlgProc,
                                    0, IDD_ABOUT, nil) ;
                         {return 0 ;}
                         end;
                    end;
               {break ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               GpiSetColor (hps, pdCurrent.iColor -
                                 IDD_BKGRND + CLR_BACKGROUND) ;

               GpiSetPattern (hps, pdCurrent.iPattern -
                                   IDD_DENSE1 + PATSYM_DENSE1) ;

               ptl.x := cxClient div 4 ;
               ptl.y := cyClient div 4 ;
               GpiMove (hps, ptl) ;

               ptl.x := ptl.x * 3 ;
               ptl.y := ptl.y * 3 ;
               if pdCurrent.fBorder then
                 GpiBox (hps, DRO_OUTLINEFILL,
                            ptl, 0, 0) 
               else
                 GpiBox (hps, DRO_FILL,
                            ptl, 0, 0) ;

               WinEndPaint (hps) ;
               {return 0 ;}
               end;

          WM_USER_QUERYSAVE: begin
               if (MBID_YES = WinMessageBox (HWND_DESKTOP, Window,
                                    'Save current settings?', szAppName, 0,
                                    MB_YESNO or MB_QUERY)) then

                    PrfWriteProfileData (cardinal(HINI_USERPROFILE), szAppName, szKeyName,
                                         pdCurrent, sizeof(pdCurrent)) ;
               {return 0 ;}
               end;
     end; {case}
     
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
     
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab, hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'PattDlg' ;
  
begin

   flFrameFlags :=              FCF_TITLEBAR      or FCF_SYSMENU 
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

     WinSendMsg (hwndClient, WM_USER_QUERYSAVE, nil, nil) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
     
end.

