program minmax2;

{/*-----------------------------------------------
   MINMAX2.C -- Bitblt of Minimize-Maximize Menu
                (c) Charles Petzold, 1993
  -----------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
     cxClient, cyClient: integer ;
     cxMinMax, cyMinMax: longint ;
     hps : cardinal;
     aptl: array [0..3] of POINTL ;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  R: TRectL;

begin
  ClientWindowProc := nil;

  case msg of
         WM_CREATE: begin
               cxMinMax := WinQuerySysValue (HWND_DESKTOP, SV_CXMINMAXBUTTON) ;
               cyMinMax := WinQuerySysValue (HWND_DESKTOP, SV_CYMINMAXBUTTON) ;
            end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
            end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, R) ;
               GpiErase (hps) ;

               aptl[0].x := 0 ;                    // target lower left
               aptl[0].y := 0 ;

               aptl[1].x := cxClient ;             // target upper right
               aptl[1].y := cyClient ;

               aptl[2].x := cxClient - cxMinMax ;  // source lower left
               aptl[2].y := cyClient ;

               aptl[3].x := cxClient ;             // source upper right
               aptl[3].y := cyClient + cyMinMax ;

               GpiBitBlt (hps, hps, 4, aptl[0], ROP_SRCCOPY, BBO_AND) ;
            
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
  szClientClass: PChar = 'Minmax2' ;

begin

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

