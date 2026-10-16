program spiral;

{/*---------------------------------------
   SPIRAL.C -- GPI Spiral Drawing
               (c) Charles Petzold, 1993
 ----------------------------------------*/}
 { port to fpc 2.6.4 GH Renkema 2021 }
 



{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

const
  NUMPOINTS = 1000;
  NUMREV    = 20;
  PI        = 3.14159;

var
   cxClient, cyClient: integer;
   dAngle, dScale : double;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
 i: integer;
 pptl: array[0..NUMPOINTS-1] of POINTL;
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

                  for i := 0 to NUMPOINTS-1 do 
                      begin
                      dAngle := i * 2 * PI / (NUMPOINTS / NUMREV) ;
                      dScale := 1 -  i / NUMPOINTS ;

                      pptl[i].x := round((cxClient / 2 *
                                               (1 + dScale * cos (dAngle))) );

                      pptl[i].y := round((cyClient / 2 *
                                               (1 + dScale * sin (dAngle))) );
                        end;
                  GpiMove (hps, pptl[0]) ;
                  GpiPolyLine (hps, NUMPOINTS - 1, pptl[1]) ;

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
  szClientClass: PChar = 'Spiral' ;

begin

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

