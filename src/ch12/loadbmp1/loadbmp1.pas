program loadbmp1;

{/*----------------------------------------------------
   LOADBMP1.C -- Loads a Bitmap Resource and Draws it
                 (c) Charles Petzold, 1993
  ----------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{ resource compiler after fpc: wrc loadbmp.rc loadbmp1.exe }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

const
  IDB_HELLO = 55;

{$i ..\..\ch00\mousutil.pas}

var
  cxClient, cyClient: integer ;
  hps : cardinal;
  hbm:  HBITMAP;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
var
  pptl:  PPOINTL;
begin
  ClientWindowProc := nil;

  new(pptl);
  case msg of
  
          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
            end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
             
               GpiErase (hps) ;

               hbm := GpiLoadBitmap (hps, 0, IDB_HELLO, cxClient, cyClient) ;

               if (hbm>0)  then
                    begin
                    pptl^.x := 0 ;
                    pptl^.y := 0 ;

                    WinDrawBitmap (hps, hbm, nil, pptl,
                                   CLR_BACKGROUND, CLR_NEUTRAL, DBM_NORMAL) ;

                    GpiDeleteBitmap (hbm) ;               
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
  szClientClass: PChar = 'LoadBmp1' ;

begin

  flFrameFlags := FCF_TITLEBAR      or FCF_SYSMENU
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

