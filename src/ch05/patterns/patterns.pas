program patterns;

{/*-----------------------------------------
   PATTERNS.C -- GPI Area Patterns
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

type
  patrec = record
    lPatternSymbol: longint ;
    szPatternSymbol : Pchar;
  end;

const
  iNumTypes = 21;
var 
  show: array[0..iNumTypes-1] of patrec;

procedure init_patrec1(n: integer;lPatt: longint;  szPatt: Pchar) ;
begin
  with show[n] do begin 
    lPatternSymbol:=lPatt;
    szPatternSymbol:=szPatt;
  end;
end;
     
procedure init_patterns;
begin
  init_patrec1( 0,   PATSYM_DEFAULT   , 'PATSYM_DEFAULT'   );
  init_patrec1( 1,   PATSYM_DENSE1    , 'PATSYM_DENSE1'    );
  init_patrec1( 2,   PATSYM_DENSE2    , 'PATSYM_DENSE2'    );
  init_patrec1( 3,   PATSYM_DENSE3    , 'PATSYM_DENSE3'    );
  init_patrec1( 4,   PATSYM_DENSE4    , 'PATSYM_DENSE4'    );
  init_patrec1( 5,   PATSYM_DENSE5    , 'PATSYM_DENSE5'    );
  init_patrec1( 6,   PATSYM_DENSE6    , 'PATSYM_DENSE6'    );
  init_patrec1( 7,   PATSYM_DENSE7    , 'PATSYM_DENSE7'    );
  init_patrec1( 8,   PATSYM_DENSE8    , 'PATSYM_DENSE8'    );
  init_patrec1( 9,   PATSYM_VERT      , 'PATSYM_VERT'      );
  init_patrec1(10,   PATSYM_HORIZ     , 'PATSYM_HORIZ'     );
  init_patrec1(11,   PATSYM_DIAG1     , 'PATSYM_DIAG1'     );
  init_patrec1(12,   PATSYM_DIAG2     , 'PATSYM_DIAG2'     );
  init_patrec1(13,   PATSYM_DIAG3     , 'PATSYM_DIAG3'     );
  init_patrec1(14,   PATSYM_DIAG4     , 'PATSYM_DIAG4'     );
  init_patrec1(15,   PATSYM_NOSHADE   , 'PATSYM_NOSHADE'   );
  init_patrec1(16,   PATSYM_SOLID     , 'PATSYM_SOLID'     );
  init_patrec1(17,   PATSYM_HALFTONE  , 'PATSYM_HALFTONE'  );
  init_patrec1(18,   PATSYM_HATCH     , 'PATSYM_HATCH'     );
  init_patrec1(19,   PATSYM_DIAGHATCH , 'PATSYM_DIAGHATCH' );
  init_patrec1(20,   PATSYM_BLANK     , 'PATSYM_BLANK'     );
end; {init_patterns}

var
   cyClient, cxCaps, cyChar, cyDesc: integer;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  i: integer;
  hps : cardinal;
  fm: FONTMETRICS;
  ptl: POINTL;


begin

  case msg of
          WM_CREATE: begin
               hps := WinGetPS (Window) ;
               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               if (fm.fsType mod 2)=1 then
                 cxCaps := (2) * fm.lAveCharWidth div 2 
               else
                 cxCaps := (3) * fm.lAveCharWidth div 2 ;

               cyChar := fm.lMaxBaselineExt ;
               cyDesc := fm.lMaxDescender ;
               WinReleasePS (hps) ;
             end;

          WM_SIZE: begin
               cyClient := SHORT2FROMMP (mp2) ;
            end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               for i := 0 to iNumTypes-1 do
                    begin
                    GpiSetPattern (hps, show [i].lPatternSymbol) ;

                    if (i<11) then ptl.x := cxCaps else ptl.x := 33 * cxCaps ;
                    ptl.y := cyClient - (i mod 11 * 5 + 4) * cyChar div 2 + cyDesc ;

                    GpiCharStringAt (hps, ptl,
                                     strlen (show [i].szPatternSymbol),
                                     show [i].szPatternSymbol) ;

                    if (i<11) then ptl.x  := 20 * cxCaps else ptl.x  := 52 * cxCaps ;
       	            ptl.y := ptl.y - (cyDesc + cyChar div 2) ;
                    GpiMove (hps, ptl) ;

                    ptl.x := ptl.x + 10 * cxCaps ;
                    ptl.y := ptl.y +  2 * cyChar ;
                    GpiBox (hps, DRO_FILL, ptl, 0, 0) ;
                    end;
               WinEndPaint (hps) ;
           
            end;

       else ;
 
    end; {case}
    
    ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;
    
end; {WinDefWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Patterns' ;

begin

  init_patterns;

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
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

