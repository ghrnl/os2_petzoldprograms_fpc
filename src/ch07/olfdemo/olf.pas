{/*--------------------------------------------
   OLF.C -- Easy access to OS/2 outline fonts
            (c) Charles Petzold, 1993
  --------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

type FACELIST = record
    iNumFaces: integer ;
    szFacename: array of array[0..FACESIZE-1] of char;
  end;
  PFACELIST = ^FACELIST;

{ moved up from below because static}
var
  pfl: PFACELIST ;

function GetAllOutlineFonts (hps: cardinal; window: cardinal) : PFACELIST;

var
  l, lFonts: longint ;

begin {GetAllOutlineFonts}
 
  GetAllOutlineFonts:=nil;

  { Check for changed fonts }

  if ( not( (QFA_PUBLIC>0) 
       and (GpiQueryFontAction (hps, QFA_PUBLIC)>0))
       and (pfl <> nil )
     )
  then
    GetAllOutlineFonts:=pfl
  else begin

    { Delete old structure if necessary }

     if (pfl <> nil) then
        dispose(pfl);

     { Determine the number of fonts }

     lFonts := 0 ;
     setlength(pfmAll,1000);
     lFonts := GpiQueryFonts (hps, QF_PUBLIC, nil, lFonts, 0, pfmAll[0]) ;

     if not (lFonts = 0) then begin
          ;

     { Allocate memory for FONTMETRICS structures }

               // Get all fonts

     GpiQueryFonts (hps, QF_PUBLIC, nil, lFonts,
                         sizeof(FONTMETRICS), pfmAll[0]) ;

     { Allocate memory for FACELIST structure }

     new(pfl);
     pfl^.iNumFaces := 0 ;
     setlength(pfl^.szFacename,lFonts+1);
     setlength(pfmAll,lFonts+1);

     { Loop through all fonts }
     for l := 0  to lFonts-1 do
          begin
                    // Check if outline font

          if (pfmAll[l].fsDefn>0 and FM_DEFN_OUTLINE) then
               begin
               { Reallocate FACELIST structure and store face name }
               {just made a large array here }
               strcopy (pfl^.szFacename[pfl^.iNumFaces], pfmAll[l].szFacename) ;

               inc(pfl^.iNumFaces) ;
               end; {if}
          end; {for}
     end; {if not (lFonts = 0) }
     end; { "top"  if / 1st return }

     GetAllOutlineFonts := pfl;

end; {GetAllOutlineFonts}

function CreateOutlineFont (hps: cardinal; lcid: longint; szFacename: Pchar;
                        fsAttributes: integer; usCodePage: integer): longint;

var
     fat: FATTRS ;
     lReturn : longint;

{ extra }
var
     xxx: str8;

begin {CreateOutlineFont}
 
     CreateOutlineFont:=0;

     { Set up FATTRS structure }

     fat.usRecordLength  := sizeof (FATTRS) ;
     fat.fsSelection     := fsAttributes ;
     fat.lMatch          := 0 ;
     fat.idRegistry      := 0 ;
     fat.usCodePage      := usCodePage ;
     fat.lMaxBaselineExt := 0 ;
     fat.lAveCharWidth   := 0 ;
     fat.fsType          := FATTR_FONTUSE_OUTLINE or
                           FATTR_FONTUSE_TRANSFORMABLE ;
     fat.fsFontUse       := 0 ;

     strcopy (fat.szFacename, szFacename) ;

     { Create the font }

     lReturn := GpiCreateLogFont (hps, xxx {NULL}, lcid, fat) ;

     { If no match, try a symbol code page }

     if (lReturn = FONT_DEFAULT) and (usCodePage = 0) then
          begin
          fat.usCodePage := 65400 ;
          lReturn := GpiCreateLogFont (hps, xxx {NULL}, lcid, fat) ;
          end;

     CreateOutlineFont := lReturn ;

end; {CreateOutlineFont}

function ScaleOutlineFont (hps: cardinal; iPointSize: integer; iPointWidth: integer): boolean ;

var
     hdc : cardinal;
     xRes, yRes : longint ;
     aptl: array [0..2-1] of POINTL ;
     _sizef : SIZEF ;

begin {ScaleOutlineFont}

    ScaleOutlineFont:=false;
               // Get font resolution in pixels per inch

     hdc := GpiQueryDevice (hps) ;

     DevQueryCaps (hdc, CAPS_HORIZONTAL_FONT_RES, 1, xRes) ;
     DevQueryCaps (hdc, CAPS_VERTICAL_FONT_RES,   1, yRes) ;

               // Find desired font size in pixels

     if (iPointWidth = 0) then
          iPointWidth := iPointSize ;

     aptl[0].x := 0 ;
     aptl[0].y := 0 ;
     aptl[1].x :=  (16 * xRes * iPointWidth + 360) div 720 ;
     aptl[1].y :=  (16 * yRes * iPointSize  + 360) div 720 ;

               // Convert to page coordinates

     GpiConvert (hps, CVTC_DEVICE, CVTC_PAGE, 2, aptl[0]) ;

               // Set the character box

     _sizef.cx := (aptl[1].x - aptl[0].x) shl 12 ;
     _sizef.cy := (aptl[1].y - aptl[0].y) shl 12 ;

     ScaleOutlineFont := GpiSetCharBox (hps, _sizef) ;
   
end; {ScaleOutlineFont}

