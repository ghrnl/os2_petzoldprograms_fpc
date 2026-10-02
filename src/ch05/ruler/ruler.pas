program ruler;

{/*--------------------------------------
   RULER.C -- Draw a Ruler
              (c) Charles Petzold, 1993
  --------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }


{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,sysutils;

{$i ..\..\ch00\mousutil.pas}

const
  NUMPOINTS = 1000;
  NUMREV    = 20;
  PI        = 3.14159;

var
  cxClient, cxChar, cyDesc: integer;
  sizl: SIZEL;
  szBuffer: Pchar; 

  iTick: array[0..15] of integer;

procedure init_ticks;
begin
  iTick[ 0]:= 100 ;
  iTick[ 1]:= 25;
  iTick[ 2]:= 35; 
  iTick[ 3]:= 25;
  iTick[ 4]:= 50;
  iTick[ 5]:= 25; 
  iTick[ 6]:= 35;
  iTick[ 7]:= 25;
  iTick[ 8]:= 70; 
  iTick[ 9]:= 25;
  iTick[10]:= 35;
  iTick[11]:= 25;
  iTick[12]:= 50;
  iTick[13]:= 25;
  iTick[14]:= 35;
  iTick[15]:= 25;
end; {init_ticks}


function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  i: integer;
  hps : cardinal;
  fm: FONTMETRICS;
  ptl: POINTL;

begin
  ClientWindowProc := nil;

  case msg of
          WM_CREATE: begin
               hps := WinGetPS (window) ;
               GpiSetPS (hps, sizl, PU_LOENGLISH) ;

               GpiQueryFontMetrics (hps, sizeof(fm), fm) ;
               cxChar := fm.lAveCharWidth ;
               cyDesc := fm.lMaxDescender ;

               WinReleasePS (hps) ;
             end;

          WM_SIZE: begin

               ptl.x := SHORT1FROMMP (mp2) ;
               ptl.y := SHORT2FROMMP (mp2) ;

               hps := WinGetPS (window) ;
               GpiSetPS (hps, sizl, PU_LOENGLISH) ;
               GpiConvert (hps, CVTC_DEVICE, CVTC_PAGE, 1, ptl) ;
               WinReleasePS (hps) ;

               cxClient := ptl.x ;
            end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
         
               GpiSetPS (hps, sizl, PU_LOENGLISH) ;
               GpiErase (hps) ;

               for i := 0  to  16* cxClient div 100 do 
                    begin
                    ptl.x := 100 * i div 16 ;
                    ptl.y := 0 ;
                    GpiMove (hps, ptl) ;

                    ptl.y := iTick [i mod 16] ;
                    GpiLine (hps, ptl) ;

                    if (i mod 16 = 0) then
                         begin
                         if (i>=160) then ptl.x := ptl.x - cxChar 
                            else ptl.x := ptl.x - cxChar div 2;
                         ptl.y := ptl.y + cyDesc ;
                         szBuffer:=pchar(format('%d', [i div 16] ));
                         GpiCharStringAt (hps, ptl, strlen(szBuffer),
                                          szBuffer) ;
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
  szClientClass: PChar = 'Ruler' ;

begin

  init_ticks;

  flFrameFlags :=  FCF_TITLEBAR      or FCF_SYSMENU
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

