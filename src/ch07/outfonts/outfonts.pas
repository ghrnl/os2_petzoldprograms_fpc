program outfonts;

{ works but should have a scroll bar and actions with it }

{/*-------------------------------------------
   OUTFONTS.C -- Displays OS/2 Outline Fonts
                 (c) Charles Petzold, 1993
  -------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi,pmdev,sysutils;

{$i ..\..\ch00\mousutil.pas}

const
  LCID_FONT  =  1;
  PTSIZE     = 12;

type
  fontArray = array of FONTMETRICS;

function GetAllOutlineFonts (hps: cardinal; var pfmOut: fontArray): longint;

var
  szDbgMessage: array[0..63] of char;

var
  l, lAllFnt, lOutFnt : longint;
  pfmAll: fontArray;

begin {GetAllOutlineFonts}
  
               { Find number of fonts }

     lAllFnt := 0 ;
     setlength(pfmAll,1);
     lAllFnt := GpiQueryFonts (hps, QF_PUBLIC, nil, lAllFnt, 0, pfmAll[0]) ;

     if (lAllFnt >  0) then begin
        
               { Get all fonts }

     setlength(pfmAll,lAllFnt);
     GpiQueryFonts (hps, QF_PUBLIC, nil, lAllFnt,
                         sizeof (FONTMETRICS), pfmAll[0]) ;

               { Get all the outline fonts }

     lOutFnt := 0 ;
     setlength(pfmOut,lAllFnt);
     for l := 0  to lAllFnt-1 do
          if (pfmAll[l].fsDefn and FM_DEFN_OUTLINE)>0 then begin
               pfmOut [lOutFnt] := pfmAll [l] ;
               inc(lOutFnt);
          end; {for}

               { Clean up }


    end; {if (lAllFnt >  0)}

    { extra }
    szDbgMessage:=format('Number of fonts found: %d', [lOutFnt]);
    WinMessageBox (HWND_DESKTOP, HWND_DESKTOP, szDbgMessage, 'Outfonts', 0,
                                                      MB_OK or MB_INFORMATION);

     GetAllOutlineFonts := lOutFnt;
     
end; {GetAllOutlineFonts}

{ static}
var
     fat : FATTRS;
     xRes, yRes, lFonts : longint;
     pfm : fontArray;
     cyClient : integer ;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
     szBuffer : array[0..FACESIZE + 32-1] of char;
     fm : FONTMETRICS;
     hdc : cardinal ;
     hps : cardinal ;
     l : longint;
     ptl : POINTL;
     _sizef : SIZEF;
     {extra}
     xxx: str8;
 
begin
  ClientWindowProc := nil;

  case msg of
          WM_CREATE: begin
               { Get the array of FONTMETRICS structures }

               hps := WinGetPS (window) ;
               GpiQueryFontAction (hps, QFA_PUBLIC) ;
               lFonts := GetAllOutlineFonts (hps,  pfm) ;

               { Get the font resolution of the device }

               hdc := GpiQueryDevice (hps) ;
               DevQueryCaps (hdc, CAPS_HORIZONTAL_FONT_RES, 1, xRes) ;
               DevQueryCaps (hdc, CAPS_VERTICAL_FONT_RES,   1, yRes) ;
               WinReleasePS (hps) ;

             end;

          WM_SIZE: begin
               cyClient := SHORT2FROMMP (mp2);
            end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;

               { Get new fonts if they've changed }

               if ((QFA_PUBLIC>0) and (GpiQueryFontAction (hps, QFA_PUBLIC)>0)) then
                    begin
                    lFonts := GetAllOutlineFonts (hps, pfm) ;
                    end;

               { Set POINTL structure to upper left corner of client }

               ptl.x := 0 ;
               ptl.y := cyClient ;

               { Set the character box for the point size }

               _sizef.cx := 65536 * xRes * PTSIZE div 72 ;
               _sizef.cy := 65536 * yRes * PTSIZE div 72 ;

               GpiSetCharBox (hps, _sizef) ;

               { Loop through all the bitmap fonts }

               for l := 0  to lFonts-1 do 
                 begin
                    { Define the FATTRS structure }

                    fat.usRecordLength  := sizeof (FATTRS) ;
                    fat.fsSelection     := 0 ;
                    fat.lMatch          := 0 ;

                    strcopy (fat.szFacename, pfm[l].szFacename) ;

                    fat.idRegistry      := pfm[l].idRegistry ;
                    fat.usCodePage      := pfm[l].usCodePage ;
                    fat.lMaxBaselineExt := 0 ;
                    fat.lAveCharWidth   := 0 ;
                    fat.fsType          := FATTR_FONTUSE_OUTLINE or
                                           FATTR_FONTUSE_TRANSFORMABLE ;
                    fat.fsFontUse       := 0 ;

                    { Create the logical font and select it }

                    GpiCreateLogFont (hps, xxx {NULL}, LCID_FONT, fat) ;
                    GpiSetCharSet (hps, LCID_FONT) ;

                    { Query the font metrics of the current font }

                    GpiQueryFontMetrics (hps, sizeof (FONTMETRICS), fm) ;

                    { Set up a text string to display }

                    szBuffer:=format(' %s - %d points',[fm.szFacename,PTSIZE]);

                    { Drop POINTL structure to baseline of font }

                    ptl.y := ptl.y  - fm.lMaxAscender ;

                    { Display the character string }

                    GpiCharStringAt (hps, ptl, strlen (szBuffer), szBuffer) ;

                    { Drop POINTL structure down to bottom of text }

                    ptl.y := ptl.y  - fm.lMaxDescender ;

                    { Select the default font; delete the logical font }

                    GpiSetCharSet (hps, LCID_DEFAULT) ;
                    GpiDeleteSetId (hps, LCID_FONT) ;
                  end;

               WinEndPaint (hps) ;

             end;

          WM_DESTROY: begin
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
  szClientClass: PChar = 'Outfonts';

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

