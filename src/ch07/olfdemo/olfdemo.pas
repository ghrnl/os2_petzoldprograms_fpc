program olfdemo;

{/*-----------------------------------------------------
   OLFDEMO.C -- OS/2 Outline Fonts Demonstration Shell
                (c) Charles Petzold, 1993
  -----------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,pmdev,sysutils;

{$i ..\..\ch00\mousutil.pas}

type
  fontArray = array of FONTMETRICS;
var
  pfmAll: fontArray;

var
   hps : cardinal ;

{$i olf.pas}

{ the unique PaintClient }
{ i olflist.pas}  {01}
{$i olfsize.pas}  {02}
{ i olfstr1.pas}  {03}
{ i olfstr2.pas}  {04}
{ i olfrot.pas}   {05}
{ i olfrefl.pas}  {06}
{ i olfrefl2.pas} {07}
{ i olfshear.pas} {08}
{ i olfrot2.pas}  {09}
{ i olfshad.pas}  {10}
{ i olfline.pas}  {11}

{ i olfblok.pas}
{ i olfclip.pas}
{ i olffill.pas}
{ i olfdrop.pas}
{ i olfwide.pas}

{ i olfjust_idx.pas} { 20220108 index version }
{ i olfjust_ptr.pas} { 20220111 pointer version }

var
    cxClient, cyClient: integer;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

begin
  ClientWindowProc := nil;

  case msg of
          WM_SIZE: begin
               {cxClient = LOUSHORT (mp2) ;
               cyClient = HIUSHORT (mp2) ;}
               cxClient := SHORT1FROMMP (mp2);
               cyClient := SHORT2FROMMP (mp2);
            end;

          WM_PAINT:
               begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               PaintClient (hps, cxClient, cyClient) ;

               WinEndPaint (hps) ;
            end;
         
         else  ;

     end; {case}
     
     ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;
     
end; {WinDefWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'OlfDemo' ;

begin

  pfl:=nil;

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

