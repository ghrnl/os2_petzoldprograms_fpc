program minmax3;

{/*----------------------------------------
   MINMAX3.C -- Minimize-Maximize Bitmap
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
     cxClient, cyClient: integer ;
     hps : cardinal;
     aptl: array [0..1] of POINTL ;
     hbmMin, hbmMax :  HBITMAP;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  R: TRectL;

begin
  ClientWindowProc := nil;

  case msg of
  
          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
            end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, R) ;
             
               hbmMin := WinGetSysBitmap (HWND_DESKTOP, SBMP_MINBUTTON) ;
               hbmMax := WinGetSysBitmap (HWND_DESKTOP, SBMP_MAXBUTTON) ;

               aptl[0].x := 0 ;               // Target lower left
               aptl[0].y := 0 ;
               aptl[1].x := cxClient div 2 ;  // Target upper right
               aptl[1].y := cyClient ;

               WinDrawBitmap (hps, hbmMin, NIL, aptl,
                              CLR_NEUTRAL, CLR_BACKGROUND, DBM_STRETCH) ;

               aptl[0].x := cxClient div 2 ;  // Target left
               aptl[1].x := cxClient ;        // Target right

               WinDrawBitmap (hps, hbmMax, NIL, aptl,
                              CLR_NEUTRAL, CLR_BACKGROUND, DBM_STRETCH) ;

               GpiDeleteBitmap (hbmMin) ;
               GpiDeleteBitmap (hbmMax) ;
          
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
  szClientClass: PChar = 'Minmax3' ;

begin

  flFrameFlags :=   FCF_TITLEBAR     or FCF_SYSMENU
                 or FCF_SIZEBORDER   or FCF_MINMAX
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

