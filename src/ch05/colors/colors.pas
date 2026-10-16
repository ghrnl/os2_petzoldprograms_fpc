program colors;

{/*---------------------------------------
   COLORS.C -- GPI Foreground Colors
               (c) Charles Petzold, 1993
  ---------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
  cyClient, cxCaps, cyChar, cyDesc: integer;

type
  colorrec = record
    lColorIndex: longint;
    szColorIndex: PCHAR ;
  end;

const
  iNumColors=21;
var
  mycolors: array[0..iNumColors-1] of colorrec;

procedure init_mycolor1(i: integer; coli: integer;colnam: PChar);
begin
   mycolors[i].lColorIndex:= coli;
   mycolors[i].szColorIndex:= colnam;
end;

procedure init_mycolors;
begin
   init_mycolor1(0,             CLR_FALSE      , 'CLR_FALSE');
   init_mycolor1(1,             CLR_TRUE       , 'CLR_TRUE' );
   init_mycolor1(2,             CLR_DEFAULT    , 'CLR_DEFAULT');
   init_mycolor1(3,             CLR_WHITE      , 'CLR_WHITE');
   init_mycolor1(4,             CLR_BLACK      , 'CLR_BLACK' );
   init_mycolor1(5,             CLR_BACKGROUND , 'CLR_BACKGROUND');
   init_mycolor1(6,             CLR_BLUE       , 'CLR_BLUE'  );
   init_mycolor1(7,             CLR_RED        , 'CLR_RED' );
   init_mycolor1(8,             CLR_PINK       , 'CLR_PINK'  );
   init_mycolor1(9,             CLR_GREEN      , 'CLR_GREEN' );
   init_mycolor1(10,            CLR_CYAN       , 'CLR_CYAN' );
   init_mycolor1(11,            CLR_YELLOW     , 'CLR_YELLOW');
   init_mycolor1(12,            CLR_NEUTRAL    , 'CLR_NEUTRAL');
   init_mycolor1(13,            CLR_DARKGRAY   , 'CLR_DARKGRAY');
   init_mycolor1(14,            CLR_DARKBLUE   , 'CLR_DARKBLUE');
   init_mycolor1(15,            CLR_DARKRED    , 'CLR_DARKRED' );
   init_mycolor1(16,            CLR_DARKPINK   , 'CLR_DARKPINK');
   init_mycolor1(17,            CLR_DARKGREEN  , 'CLR_DARKGREEN');
   init_mycolor1(18,            CLR_DARKCYAN   , 'CLR_DARKCYAN');
   init_mycolor1(19,            CLR_BROWN      , 'CLR_BROWN'   );
   init_mycolor1(20,            CLR_PALEGRAY   , 'CLR_PALEGRAY');
end; {init_mycolors}

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  {colors}
  {                   iNumColors = sizeof show / sizeof show[0] ;}
  fm:FONTMETRICS ;
  hps : cardinal;
  i: integer;
  ptl : POINTL;

begin
  ClientWindowProc := nil;

  case msg of
          WM_CREATE: begin
               hps := WinGetPS (Window) ;
               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               if (fm.fsType mod 2=1) then
                  cxCaps := (2 * fm.lAveCharWidth) div 2 
               else
                  cxCaps := (3 * fm.lAveCharWidth) div 2;
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

               for i := 0 to iNumColors-1 do 
                    begin
                    if (i<11) then ptl.x := 1*cxCaps else ptl.x := 33*cxCaps;
                    ptl.y := cyClient - (i mod 11 * 5 + 4) * cyChar div 2 + cyDesc ;

                    GpiCharStringAt (hps, ptl,
                                     strlen (mycolors [i].szColorIndex),
                                     mycolors [i].szColorIndex) ;

                    if (i<11) then ptl.x:=20*cxCaps else ptl.x:=52*cxCaps;
                    ptl.y := ptl.y - (cyDesc + cyChar div 2) ;
                    GpiMove (hps, ptl) ;

                    GpiSavePS (hps) ;
                    GpiSetColor (hps, mycolors[i].lColorIndex) ;

                    ptl.x :=ptl.x + 10 * cxCaps ;
                    ptl.y :=ptl.y +  2 * cyChar ;
                    GpiBox (hps, DRO_FILL, ptl, 0, 0) ;

                    GpiRestorePS (hps, -1) ;
                   end;
               WinEndPaint (hps) ;
            end;
 
        else ;
 
    end; {case}
    
    ClientWindowProc:=WinDefWindowProc (window, msg, mp1, mp2) ;
    
end;

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Colors' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  init_mycolors;

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

