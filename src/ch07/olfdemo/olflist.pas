{/*----------------------------------------
   OLFLIST.C -- Lists OS/2 Outline Fonts
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
  LCID_FONT  =   1;
  PTSIZE     = 120;
  PTWIDTH    = 120;

var
  szBuffer: array[0 .. FACESIZE + 32-1] of char;
  fm: FONTMETRICS;
  i: integer;
  pfl: PFACELIST;
  ptl: POINTL;

begin {PaintClient}

     { Get pointer to FACELIST structure }

     pfl := GetAllOutlineFonts (hps,HWND_DESKTOP) ;

     { Set POINTL structure to upper left corner of client }

     ptl.x := 0 ;
     ptl.y := cyClient ;

     { Loop through all the outline fonts }

     for i := 0  to pfl^.iNumFaces-1  do
          begin

          { Create the logical font and select it }

          CreateOutlineFont (hps, LCID_FONT, pfl^.szFacename[i], 0, 0) ; 
          GpiSetCharSet (hps, LCID_FONT) ;

          { Scale the selected font }

          ScaleOutlineFont (hps, PTSIZE, PTWIDTH) ;

          { Query the font metrics of the current font }

          fm:=pfmAll[i];

          { Set up a text string to display }

          szBuffer:=format('%s - %d decipoints, width %d',[fm.szFacename, PTSIZE, PTWIDTH]);

          { Drop POINTL structure to baseline of font }

          ptl.y := ptl.y - fm.lMaxAscender ;

          { Display the character string }

          GpiCharStringAt (hps, ptl, strlen (szBuffer), szBuffer) ;

          { Drop POINTL structure down to bottom of text }

          ptl.y := ptl.y - fm.lMaxDescender ;

          { Select the default font; delete the logical font }

          GpiSetCharSet (hps, LCID_DEFAULT) ;
          GpiDeleteSetId (hps, LCID_FONT) ;

          if (ptl.y < 0) then
               break ;
      end; {for}

end;

