program altwind;

{/*------------------------------------------
   ALTWIND.C -- Alternate and Winding Modes
                (c) Charles Petzold, 1993
 -------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ../../ch00/mousutil.pas}

var
  cxClient, cyClient : integer;
  aptl: array[0..9] of POINTL;

var aptlFigure : array [0..9] of POINTL;

procedure init_point(n,xx,yy: integer);
begin
  aptlFigure[n].x:=xx;
  aptlFigure[n].y:=yy;
end;

procedure init_figure;
begin
  init_point(0,10,30);
  init_point(1,50,30);
  init_point(2,50,90);
  init_point(3,90,90);
  init_point(4,90,50);
  init_point(5,30,50);
  init_point(6,30,10);
  init_point(7,70,10);
  init_point(8,70,70);
  init_point(9,10,70);
end; {init_figure}

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
 i: integer;
 hps : cardinal;

begin
  ClientWindowProc := nil;

  case msg of

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
            end;


          WM_PAINT:
               begin

               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;
               GpiSetPattern (hps, PATSYM_HALFTONE) ;

                       {  /*---------------------
                            Alternate Fill Mode

                           ---------------------*/}

               for i := 0 to 10-1 do
                    begin
                    aptl[i].x := cxClient * aptlFigure[i].x div 200 ;
                    aptl[i].y := cyClient * aptlFigure[i].y div 100 ;
                    end; {for}

               GpiBeginArea (hps, BA_BOUNDARY or BA_ALTERNATE) ;
               GpiMove (hps, aptl[0]) ;

               GpiPolyLine (hps, 9, aptl[1]) ;
               GpiEndArea (hps) ;

                      {   /*-------------------
                            Winding Fill Mode
                           -------------------*/}


               for i := 0 to 10-1 do
                    aptl[i].x := aptl[i].x + cxClient div 2 ;

               GpiBeginArea (hps, BA_BOUNDARY or BA_WINDING) ;
               GpiMove (hps, aptl[0]) ;
               GpiPolyLine (hps, 9, aptl[1]) ;
               GpiEndArea (hps) ;

               WinEndPaint (hps) ;

              end; 
  else ;
 
 end; {case}
 
 ClientWindowProc:=WinDefWindowProc (window, msg, mp1, mp2) ;
 
end; {WinDefWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Altwind' ;

begin

  init_figure;

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

