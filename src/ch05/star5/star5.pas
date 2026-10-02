program star5;

{/*--------------------------------------
   STAR5.C -- Draws 5-Pointed Star
              (c) Charles Petzold, 1993
  --------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

{$i ..\..\ch00\mousutil.pas}

const
  NSPTS=5;
var
   aptl: array [0..NSPTS-1] of POINTL  ;
   aptlStar: array [0..NSPTS-1] of POINTL  ;
   cxClient, cyClient: integer;


function ClientWndProc (hwnd, msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
     hps : cardinal;
     i:  integer;

begin

    ClientWndProc:=nil;

    aptlStar[0].x:=-59;
    aptlStar[0].y:=-81;
    aptlStar[1].x:=0;
    aptlStar[1].y:=100;
    aptlStar[2].x:=59;
    aptlStar[2].y:=-81;
    aptlStar[3].x:=-95;
    aptlStar[3].y:=31;
    aptlStar[4].x:=95;
    aptlStar[4].y:=31;
   

     case msg oF
           WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
              end;
           WM_PAINT: begin
               hps := WinBeginPaint (hwnd, 0, nil) ;
               GpiErase (hps) ;

               for i := 0 to NSPTS-1 do begin
                    
                    aptl[i].x := cxClient div 2 + cxClient * aptlStar[i].x div 200 ;
                    aptl[i].y := cyClient div 2 + cyClient * aptlStar[i].y div 200 ;
                    end; {for}
               GpiMove (hps, aptl[NSPTS-1]) ;
               GpiSetLineType (hps, LINETYPE_SOLID) ;

               for i:=0 to NSPTS-1 do 
                   GpiLine (hps, aptl[i]) ;

               WinEndPaint (hps) ;

             end;
         else ;
         
     end; {case}
     
    ClientWndProc:=WinDefWindowProc (hwnd, msg, mp1, mp2)
    
end;

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Star5' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
       WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab) ;

end.

