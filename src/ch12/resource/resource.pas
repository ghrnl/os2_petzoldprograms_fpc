program resource;

{/*-------------------------------------------------
   RESOURCE.C -- Uses an Icon and Pointer Resource
                 (c) Charles Petzold, 1993
  -------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{ status: runs including deviating mouse pointer :) }
{ resource compiler after fpc: wrc resource.rc resource.exe }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

{$i ..\..\ch00\mousutil.pas}
{$i ..\..\ch00\mrfromshort.pas}

{ from res.h }
const ID_RESOURCE = 1;
const IDP_CIRCLE  = 2;

var
     hIcon, hptr : cardinal;
     cxClient, cyClient, cxIcon, cyIcon : integer;

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     h_ps: HPS;
     rcl : RECTL;
     
     done: boolean;

begin

     ClientWndProc:=nil;
     done:=true;

     case (msg) of
          
          WM_CREATE: begin
               hIcon := WinLoadPointer (HWND_DESKTOP, 0, ID_RESOURCE) ;
               hptr  := WinLoadPointer (HWND_DESKTOP, 0, IDP_CIRCLE) ;

               cxIcon := WinQuerySysValue (HWND_DESKTOP, SV_CXICON) ;
               cyIcon := WinQuerySysValue (HWND_DESKTOP, SV_CYICON) ;
             end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
             end;

          WM_MOUSEMOVE: begin
               WinSetPointer (HWND_DESKTOP, hptr) ;
               ClientWndProc := MRFROMSHORT (1) ;
             end;

          WM_PAINT: begin
               h_ps := WinBeginPaint (Window, 0, nil) ;

               WinQueryWindowRect (Window, rcl) ;
               WinFillRect (h_ps, rcl, CLR_CYAN) ;

               WinDrawPointer (h_ps, 0, 0, hIcon, DP_NORMAL) ;
               WinDrawPointer (h_ps, 0, cyClient - cyIcon, hIcon, DP_NORMAL) ;
               WinDrawPointer (h_ps, cxClient - cyIcon, 0, hIcon, DP_NORMAL) ;
               WinDrawPointer (h_ps, cxClient - cxIcon, cyClient - cyIcon,
                                    hIcon, DP_NORMAL) ;

               WinDrawPointer (h_ps, cxClient div 3, cyClient div 2, hIcon,
                                                       DP_HALFTONED) ;
               WinDrawPointer (h_ps, 2 * cxClient div 3, cyClient div 2, hIcon,
                                                       DP_INVERTED) ;
               WinEndPaint (h_ps) ;
             end;

          WM_DESTROY: begin
               WinDestroyPointer (hIcon) ;
               WinDestroyPointer (hptr) ;
             end;
             
          otherwise done:=false;
          
          end; {case}

     if not done then ClientWndProc := WinDefWindowProc (Window, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

var
   szClientClass : Pchar = 'Resource';

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame, hwndClient : cardinal;
  flFrameFlags: cardinal;

begin

  flFrameFlags :=    FCF_TITLEBAR      or FCF_SYSMENU
                  or FCF_SIZEBORDER    or FCF_MINMAX
                  or FCF_SHELLPOSITION or FCF_TASKLIST
                  or FCF_ICON;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

     WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

     hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, ID_RESOURCE, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

