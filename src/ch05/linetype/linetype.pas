program linetype;

{/*-----------------------------------------
   LINETYPE.C -- GPI Line Types
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

{$i ..\..\ch00\mousutil.pas}

type
  linrec = record
    lLineType: longint;
    szLineType: Pchar;
end;

const
  {iNumTypes = sizeof show / sizeof show[0] ;}
  iNumTypes = 10;
var
  show : array[0..iNumTypes-1] of linrec;

procedure init_show1(ind: integer; lLineT: longint; szLineT: Pchar);
begin
  with show[ind] do begin
    lLineType:=lLineT;
    szLineType:=szLineT;
  end;
end;

procedure init_shows;
begin
   init_show1(0,             LINETYPE_DEFAULT       , 'LINETYPE_DEFAULT'     ); 
   init_show1(1,             LINETYPE_DOT           , 'LINETYPE_DOT'         );  
   init_show1(2,             LINETYPE_SHORTDASH     , 'LINETYPE_SHORTDASH'   );  
   init_show1(3,             LINETYPE_DASHDOT       , 'LINETYPE_DASHDOT'     );  
   init_show1(4,             LINETYPE_DOUBLEDOT     , 'LINETYPE_DOUBLEDOT'   ); 
   init_show1(5,             LINETYPE_LONGDASH      , 'LINETYPE_LONGDASH'    );  
   init_show1(6,             LINETYPE_DASHDOUBLEDOT , 'LINETYPE_DASHDOUBLEDOT'); 
   init_show1(7,             LINETYPE_SOLID         , 'LINETYPE_SOLID'       ); 
   init_show1(8,             LINETYPE_INVISIBLE     , 'LINETYPE_INVISIBLE'   ); 
   init_show1(9,             LINETYPE_ALTERNATE     , 'LINETYPE_ALTERNATE'   ); 
end;

var
    cxClient, cyClient, cxCaps, cyChar, cyDesc: integer;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  hps : cardinal;
  {colors}
  {                   iNumColors = sizeof show / sizeof show[0] ;}
  fm:FONTMETRICS ;
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
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
            end;

          WM_PAINT:
               begin
                 hps := WinBeginPaint (Window, 0, nil) ;
                  GpiErase (hps) ;

               for i := 0  to iNumTypes-1 do 
                    begin
                    GpiSetLineType (hps, show [i].lLineType) ;

                    ptl.x := cxCaps ;
                    ptl.y := cyClient - 2 * (i + 1) * cyChar + cyDesc ;

                    GpiCharStringAt (hps, ptl,
                                     strlen (show [i].szLineType),
                                     show [i].szLineType) ;

                    if (cxClient > 25 * cxCaps) then
                         begin
                         ptl.x := 24 * cxCaps ;
                         ptl.y := ptl.y + cyChar div 2 - cyDesc ;
                         GpiMove (hps, ptl) ;

                         ptl.x := cxClient - cxCaps ;
                         GpiLine (hps, ptl) ;
                         end;
                    end;

               WinEndPaint (hps) ;
            end;
     
        else ;
 
     end; {case}
     
     ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;
     
end;

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'LineType' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;
                 
  init_shows;

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

