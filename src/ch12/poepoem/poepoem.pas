program poepoem;

{ --------------------------------------------------------
   POEPOEM.C -- Demonstrates Programmer-Defined Resources
                (c) Charles Petzold, 1993
  -------------------------------------------------------- }
{ port to fpc 2.6.4 GH Renkema 2021 }

{ resource compiler after fpc: wrc poepoem.rc poepoem.exe }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, doscalls;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\maxmin.pas}

const
  ID_RESOURCE =    1;

  IDT_TEXT    = 1024;
  IDT_POEM    =    1;

  IDS_CLASS   =    0;
  IDS_TITLE   =    1;

var
  hps : cardinal;

var
  pResource: PChar;
  hwndScroll: cardinal;
  cyClient, cxChar, cyChar, cyDesc,
                 iScrollPos, iNumLines : integer;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  fm: FONTMETRICS;
  iLineLength, iLine: integer;
  ptext: PChar;
  ulMemSize, ulMemFlags: longword;
  ptl:  POINTL;

var
  ipi: integer;

begin
  ClientWindowProc := nil;

  case msg of
           WM_CREATE: begin
             
                    { -----------------------------------------
                       Load the resource, get size and address
                      ----------------------------------------- }

               DosGetResource (0, IDT_TEXT, IDT_POEM, pResource) ;
               DosQueryMem (pResource, ulMemSize, ulMemFlags) ;

                    { -----------------------------------------------
                       Determine how many text lines are in resource
                      ----------------------------------------------- }

               pText := pResource ;
               iNumLines:=0;

               ipi:=0;
               while not ((pText[ipi]=chr(0)) or (pText[ipi]=chr($1A))) do
                  begin
                    if  (pText[ipi] = chr(13) ) then
                         inc(iNumLines);                
                    inc(ipi) ;
                    end; {while}

                    { ------------------------------------------
                       Initialize scroll bar range and position
                      ------------------------------------------ }

               hwndScroll := WinWindowFromID (
                                   WinQueryWindow (window, QW_PARENT),
                                   FID_VERTSCROLL) ;

               WinSendMsg (hwndScroll, SBM_SETSCROLLBAR,

                                       MPFROM2SHORT (iScrollPos, 0),
                                       MPFROM2SHORT (0, iNumLines - 1)) ;

                    { ----------------------
                       Query character size
                      ---------------------- }

               hps := WinGetPS (window) ;

               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               cxChar := fm.lAveCharWidth ;
               cyChar := fm.lMaxBaselineExt ;
               cyDesc := fm.lMaxDescender ;

             
               WinReleasePS (hps) ;

             end;

            WM_SIZE: begin
               cyClient := SHORT2FROMMP (mp2) ;
              end;

          WM_CHAR: begin
               WinSendMsg (hwndScroll, msg, mp1, mp2) ;
              end;

          WM_VSCROLL: begin
               case SHORT2FROMMP (mp2) of
                    
                     SB_LINEUP:
                         iScrollPos := iScrollPos - 1 ;

                     SB_LINEDOWN:
                         iScrollPos := iScrollPos + 1 ;

                     SB_PAGEUP:
                         iScrollPos := iScrollPos-  cyClient div cyChar ;

                     SB_PAGEDOWN:
                         iScrollPos := iScrollPos + cyClient div cyChar ;

                     SB_SLIDERPOSITION:
                         iScrollPos := SHORT1FROMMP (mp2) ;

                    otherwise;
                    
                  end; {case}
                    
               iScrollPos := max (0, min (iScrollPos, iNumLines - 1)) ;

               WinSendMsg (hwndScroll, SBM_SETPOS,
                           MPFROM2SHORT (iScrollPos, 0), NIL) ;

               WinInvalidateRect (window, NIL, FALSE) ;
               end;

           WM_PAINT:  begin
               hps := WinBeginPaint (window, 0, nil) ;
               GpiErase (hps) ;

               pText := pResource ;

               for iLine := 0 to iNumLines-1 do 
                    begin
                    iLineLength := 0 ;

                    while (pText [iLineLength] <> chr(13) ) do
                         inc(iLineLength) ;

                    ptl.x := cxChar ;
                    ptl.y :=  cyClient - cyChar * (iLine + 1 - iScrollPos)
                                     + cyDesc ;
                    
                    GpiCharStringAt (hps, ptl, iLineLength, pText) ;

                    pText := pText+ iLineLength + 2 ;
                    end;
               WinEndPaint (hps) ;
               end;

          WM_DESTROY: begin

               DosFreeResource (pResource) ;
            end;
          
          else ;
 
      end; {case}

      ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2)

end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: array[0..10-1] of char;
  szTitleBar   : array[0..64-1] of char;
  {declaring the next two as Pchar doesnt give the .RC defined titlebar }
  {szClientClass : Pchar = 'PoePoem_init_class';
  szTitleBar    : Pchar = 'PoePoem_init_title';}

begin
  
  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST
                 or FCF_VERTSCROLL    or FCF_ICON;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinLoadString (hab, 0, IDS_CLASS, sizeof(szClientClass), szClientClass) ;
  WinLoadString (hab, 0, IDS_TITLE, sizeof(szTitleBar),    szTitleBar) ;

  WinRegisterClass (hab, szClientClass, @ClientWindowProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, szTitleBar,
                                     0, 0, ID_RESOURCE, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

