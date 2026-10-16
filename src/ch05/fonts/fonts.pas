program fonts;

{/*--------------------------------------
   FONTS.C -- GPI Image Fonts
              (c) Charles Petzold, 1993
  --------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,pmdev,sysutils;

{$i ..\..\ch00\maxmin.pas}
{$i ..\..\ch00\mousutil.pas}

const
   LCID_MYFONT = 1;

{ from easyfont.h}

 FONTFACE_SYSTEM = 0;
 FONTFACE_MONO   = 1;
 FONTFACE_COUR   = 2;
 FONTFACE_HELV   = 3;
 FONTFACE_TIMES  = 4;

 FONTSIZE_8     =  0;
 FONTSIZE_10    =  1;
 FONTSIZE_12    =  2;
 FONTSIZE_14    =  3;
 FONTSIZE_18    =  4;
 FONTSIZE_24    =  5;

{$i ..\easyfont\easyfont.pas}

const
  iVscrollMax=5-1;
  iHscrollMax=5-1;

var
  cyClient, iHscrollPos, iVscrollPos : integer;

var
  szFace: array[0..4] of Pchar;
  szSize: array[0..5] of Pchar;
  szSel : array[0..4] of Pchar;

  hwndVscroll, hwndHscroll: cardinal;

  idFace:  array[0..5-1] of integer;
  idSize:  array[0..6-1] of integer;
  afiSel:  array[0..5-1] of integer;


procedure init_fonts;
begin
  szFace[0] := 'System';
  szFace[1] := 'Monospaced';
  szFace[2] := 'Courier';
  szFace[3] := 'Helv';
  szFace[4] := 'Tms Rmn' ;

  szSize[0] := '8';
  szSize[1] := '10';
  szSize[2] := '12';
  szSize[3] := '14';
  szSize[4] := '18' ;
  szSize[5] := '24' ;

  szSel[0] := 'Normal';
  szSel[1] := 'Italic';
  szSel[2] := 'Underscore';
  szSel[3] := 'Strike-out';
  szSel[4] := 'Bold' ;

  idFace[0] := FONTFACE_SYSTEM;
  idFace[1] := FONTFACE_MONO;
  idFace[2] := FONTFACE_COUR;
  idFace[3] := FONTFACE_HELV;
  idFace[4] := FONTFACE_TIMES;

  idSize[0] := FONTSIZE_8;
  idSize[1] := FONTSIZE_10;
  idSize[2] := FONTSIZE_12;
  idSize[3] := FONTSIZE_14;
  idSize[4] := FONTSIZE_18;
  idSize[5] := FONTSIZE_24;

  afiSel[0] := 0;
  afiSel[1] := FATTR_SEL_ITALIC;
  afiSel[2] := FATTR_SEL_UNDERSCORE;
  afiSel[3] := FATTR_SEL_STRIKEOUT;
  afiSel[4] := FATTR_SEL_BOLD ;

end; {init_fonts}

var
   hps : cardinal;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
 isize: integer;
 ptl: POINTL;

var
  hwndFrame: cardinal;
  szBuffer: array[0..80-1] of char;
  fm: FONTMETRICS;
 
begin

  ClientWindowProc := nil;

  case msg of
          WM_CREATE: begin
               hps := WinGetPS (window) ;
               if EzfQueryFonts (hps) then ;
               WinReleasePS (hps) ;

               hwndFrame   := WinQueryWindow (window, QW_PARENT) ;
               hwndVscroll := WinWindowFromID (hwndFrame, FID_VERTSCROLL) ;
               hwndHscroll := WinWindowFromID (hwndFrame, FID_HORZSCROLL) ;

               WinSendMsg (hwndVscroll, SBM_SETSCROLLBAR,
                           MPFROM2SHORT (iVscrollPos, 0),
                           MPFROM2SHORT (0, iVscrollMax)) ;

               WinSendMsg (hwndHscroll, SBM_SETSCROLLBAR,
                           MPFROM2SHORT (iHscrollPos, 0),
                           MPFROM2SHORT (0, iHscrollMax)) ;
             end;

          WM_SIZE: begin
               cyClient := SHORT2FROMMP (mp2) ;
            end;

        WM_VSCROLL: begin
               case (SHORT2FROMMP (mp2)) of
                    
                     SB_LINEUP,
                     SB_PAGEUP:
                         iVscrollPos := max (0, iVscrollPos - 1) ;

                     SB_LINEDOWN,
                     SB_PAGEDOWN:
                         iVscrollPos := min (iVscrollMax, iVscrollPos + 1) ;

                     SB_SLIDERPOSITION:
                         iVscrollPos := SHORT1FROMMP (mp2) ;

                    else ;
                end; {case}
                WinSendMsg (hwndVscroll, SBM_SETPOS,
                           MPFROM2SHORT (iVscrollPos, 0), nil) ;

               WinInvalidateRect (window, NIL, FALSE) ;
            end; {WM_VSCROLL}

      WM_HSCROLL: begin
      
               case SHORT2FROMMP (mp2) of
                    
                     SB_LINELEFT,
                     SB_PAGELEFT: begin
                         iHscrollPos := max (0, iHscrollPos - 1) ;
                       end;

                    SB_LINERIGHT,
                    SB_PAGERIGHT: begin
                         iHscrollPos := min (iHscrollMax, iHscrollPos + 1) ;
                      end;

                    SB_SLIDERPOSITION: begin
                         iHscrollPos := SHORT1FROMMP (mp2) ;
                       end;

                    else ;
                end; {case}
                WinSendMsg (hwndHscroll, SBM_SETPOS,
                           MPFROM2SHORT (iHscrollPos, 0), nil) ;

               WinInvalidateRect (window, NIL, FALSE) ;
             end;

      WM_CHAR: begin
               
               case  CHARMSG(@msg).vkey of
                    
                     VK_LEFT,
                     VK_RIGHT:
                         WinSendMsg (hwndHscroll, msg, mp1, mp2) ;
                     VK_UP,
                     VK_DOWN,
                     VK_PAGEUP,
                     VK_PAGEDOWN:
                         WinSendMsg (hwndVscroll, msg, mp1, mp2) ;
                    end; {case}
                end;


          WM_PAINT:
               begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;
    
               ptl.x := 0 ;
               ptl.y := cyClient ;

               for iSize := 0  to 1*(6-1) do begin
                    if (EzfCreateLogFont (hps, LCID_MYFONT,
                                          idFace [iVscrollPos],
                                          idSize [iSize],
                                          afiSel [iHscrollPos]) >0)  then
                         begin
                         GpiSetCharSet (hps, LCID_MYFONT) ;
                         GpiQueryFontMetrics (hps, sizeof(fm), fm) ;

                         ptl.y :=  ptl.y - fm.lMaxBaselineExt ;

                        szBuffer:=Pchar(format('%s, %s point, %s',
                                       [szFace [iVscrollPos],
                                       szSize [iSize],
                                       szSel  [iHscrollPos]]
                                  ));

                     GpiCharStringAt (hps, ptl,strlen(szBuffer),
                              szBuffer) ;

                         GpiSetCharSet (hps, LCID_DEFAULT) ;
                         GpiDeleteSetId (hps, LCID_MYFONT) ;
                         end;

               end; {for}
          
               WinEndPaint (hps) ;

              end;

        else  ;
 
    end; {case}
     
    ClientWindowProc := WinDefWindowProc (window, msg, mp1, mp2) ;
    
end; {ClientWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Fonts' ;

begin

  init_fonts;

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

