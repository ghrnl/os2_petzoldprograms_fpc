program bitcat1;

{/*------------------------------------------
   BITCAT1.C -- Bitmap Creation and Display
                (c) Charles Petzold, 1993
  ------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }
 
{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,pmbitmap;

{$i ..\..\ch00\mousutil.pas}

var
     cxClient, cyClient: integer ;
     hps : cardinal;
     aptl: array [0..3] of POINTL  ;
     bmp:  ^BITMAPINFOHEADER2;
     pbmi: ^Bitmapinfo2;
     hbm:  longword;

{$i bitcat_hdr.pas}

function ClientWndProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;
begin
  ClientWndProc := nil;

  case msg of
         WM_CREATE: begin

                // Create 32-by-32 monochrome bitmap

               bmp:=getmem( sizeof (BITMAPINFOHEADER2));
               fillbyte (bmp^, sizeof (bmp^), 0);

               bmp^.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               bmp^.cx        := 32 ;
               bmp^.cy        := 32 ;
               bmp^.cPlanes   := 1 ;
               bmp^.cBitCount := 1 ;

               pbmi:=getmem( sizeof (BITMAPINFO2) + sizeof (RGB2));
               fillbyte (pbmi^, sizeof (pbmi^), 0);

               pbmi^.cbFix     := sizeof (BITMAPINFOHEADER2) ;
               pbmi^.cx        := 32 ;
               pbmi^.cy        := 32 ;
               pbmi^.cPlanes   := 1 ;
               pbmi^.cBitCount := 1;

               pbmi^.argbColor[0].bBlue  := $00 ;      // 0 bits (background)
               pbmi^.argbColor[0].bGreen := $00 ;
               pbmi^.argbColor[0].bRed   := $00 ;
               pbmi^.argbColor[0].fcOptions := 0 ;
{
               pbmi^.argbColor[1].bBlue  := $FF ;      // 1 bits (foreground)
               pbmi^.argbColor[1].bGreen := $FF ;
               pbmi^.argbColor[1].bRed   := $FF ;
               pbmi^.argbColor[1].fcOptions := 0 ;
}
               hps := WinGetPS (window) ;
               hbm := GpiCreateBitmap (hps, bmp^, CBM_INIT, abBitCat[0], pbmi^) ;
               WinReleasePS (hps) ;

               freemem (pbmi) ;
               freemem (bmp) ;
            end;

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
            end;

          WM_PAINT: begin
              hps := WinBeginPaint (Window, 0, nil) ;
             
               aptl[0].x := 0 ;                    // target lower left
               aptl[0].y := 0 ;

               aptl[1].x := cxClient ;             // target upper right
               aptl[1].y := cyClient ;

               aptl[2].x := 0 ;                    // source lower left
               aptl[2].y := 0 ;

               aptl[3].x := 32 ;                   // source upper right
               aptl[3].y := 32 ;

               GpiWCBitBlt (hps, hbm, 4, aptl[0], ROP_SRCCOPY, BBO_AND) ;

               aptl[1] := aptl[3] ;                // target upper right

               GpiWCBitBlt (hps, hbm, 4, aptl[0], ROP_SRCCOPY, BBO_AND) ;
            
               WinEndPaint (hps) ;
            end;

        WM_DESTROY:
               GpiDeleteBitmap (hbm) ;          
 
       else ;
 
    end; {case}
    
    ClientWndProc:=WinDefWindowProc (Window, msg, mp1, mp2) ;
    
end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'BitCat1';

begin

  flFrameFlags :=  FCF_TITLEBAR      or FCF_SYSMENU or
                   FCF_SIZEBORDER    or FCF_MINMAX  or
                   FCF_SHELLPOSITION or FCF_TASKLIST;

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
  WinTerminate (hab);

end.

