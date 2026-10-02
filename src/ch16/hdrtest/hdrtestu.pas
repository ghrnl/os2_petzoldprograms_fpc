program hdrtest;

{/*--------------------------------------------------------------
   HDRTEST.C -- Program to Test HDRLIB.DLL Dynamic Link Library
                (c) Charles Petzold, 1993
  --------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi, hdrlibu;

{$i ..\..\ch00\mousutil.pas}

var
     cxClient, cyClient : integer;

{MRESULT EXPENTRY ClientWndProc (HWND hwnd, ULONG msg, MPARAM mp1, MPARAM mp2)}
function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
{
     static INT cxClient, cyClient ;
     HPS        hps;
     POINTL     ptl ;
}

var
     hps : cardinal;
     ptl : POINTL;


begin

     case (msg) of
	  
          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
               {return 0 ;}
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               ptl.x := cxClient div 8 ;
               ptl.y := 3 * cyClient div 4 ;
               HdrPrintf (hps, @ptl, 'Welcome to the %s',
                          'OS/2 2.0 Presentation Manager!') ;

               ptl.x := cxClient div 8 ;
               ptl.y := cyClient div 4 ;
               HdrPuts (hps, @ptl, 'This line was displayed by a ') ;
               HdrPuts (hps, nil, 'routine in a dynamic link library.') ;

               ptl.x := 0 ;
               ptl.y := 0 ;
               GpiMove (hps, ptl) ;

               ptl.x := cxClient - 1 ;
               ptl.y := cyClient - 1 ;
               HdrEllipse (hps, DRO_OUTLINE, @ptl) ;

               WinEndPaint (hps) ;
               {return 0 ;}
               end;
     end; {case}
     ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame, hwndClient : cardinal;
  flFrameFlags: cardinal;
  szClientClass : Pchar = 'HdrTest' ;

begin
{
     static ULONG flFrameFlags := FCF_TITLEBAR      | FCF_SYSMENU |
                                 FCF_SIZEBORDER    | FCF_MINMAX  |
                                 FCF_SHELLPOSITION | FCF_TASKLIST ;
                                 }

     flFrameFlags :=     FCF_TITLEBAR      or FCF_SYSMENU
                      or FCF_SIZEBORDER    or FCF_MINMAX
                      or FCF_SHELLPOSITION or FCF_TASKLIST ;

     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

     while (WinGetMsg (hab, qmsg, 0, 0, 0)) do
          WinDispatchMsg (hab, qmsg) ;

     WinDestroyWindow (hwndFrame) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
     
end.

