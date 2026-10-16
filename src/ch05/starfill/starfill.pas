program starfill;

{/*--------------------------------------------
   STARFILL.C -- Alternate and Winding Modes
                    (c) Charles Petzold, 1993
  --------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
  cxClient, cyClient : integer;
  aptl: array[0..9] of POINTL;
  aptlStar : array[0..4] of POINTL;

procedure init_point(n,xx,yy: integer);
begin
  aptlStar[n].x:=xx;
  aptlStar[n].y:=yy;
end;

procedure init_star;
begin
  init_point(0,-59,-81);
  init_point(1 , 0,100);
  init_point(2, 59,-81);
  init_point(3, -95,31);
  init_point(4,  95,31);
end; {init_star}

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

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;
               GpiSetPattern (hps, PATSYM_HALFTONE) ;

                         {/*---------------------
                            Alternate Fill Mode
                           ---------------------*/}

               for i := 0 to 4 do 
                    begin
                    aptl[i].x := cxClient div 4 + cxClient *
                                          aptlStar[i].x div 400 ;
                    aptl[i].y := cyClient div 2 + cyClient *
                                          aptlStar[i].y div 200 ;
                    end; {for}

               GpiBeginArea (hps, BA_NOBOUNDARY or {|} BA_ALTERNATE) ;
               GpiMove (hps, aptl[0]) ;
               GpiPolyLine (hps, 4, aptl[1]) ;
               GpiEndArea (hps) ;

                         {/*-------------------
                            Winding Fill Mode
                           -------------------*/}

               for i := 0 to 4 do 
                    aptl[i].x := aptl[i].x + cxClient div 2 ;

               GpiBeginArea (hps, BA_NOBOUNDARY or BA_WINDING) ;
               GpiMove (hps, aptl[0]) ;
               GpiPolyLine (hps, 4, aptl[1]) ;

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
  szClientClass: PChar = 'Starfill' ;

begin

  init_star;

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

