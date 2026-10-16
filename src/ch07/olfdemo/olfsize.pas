{/*----------------------------------------
   OLFSIZE.C -- OS/2 Outline Fonts Sizes
                (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_FONT   = 1;
const FACENAME    = 'Times New Roman Italic';

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

var
   szBuffer : array[0..FACESIZE + 32-1] of char;
   fm: FONTMETRICS;
   i: integer;
   aptlTextBox: array [0..TXTBOX_COUNT-1] of POINTL;
   ptl: POINTL;

begin

          // Set POINTL structure to upper left corner of client

     ptl.x := 0 ;
     ptl.y := cyClient ;

          // Create the logical font and select it

     CreateOutlineFont (hps, LCID_FONT, FACENAME, 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;

          // Loop through the font sizes

     i := 100 ;

     while (ptl.y > 0) do
          begin
               // Scale the selected font

          ScaleOutlineFont (hps, i, i) ;

               // Query the font metrics of the current font

          GpiQueryFontMetrics (hps, sizeof (FONTMETRICS), fm) ;

               // Set up a text string to display

          szBuffer := format('%s - %d decipoints',[fm.szFacename,i]);
          GpiQueryTextBox (hps, strlen (szBuffer), szBuffer,
                           TXTBOX_COUNT, aptlTextBox[0]) ;

          szBuffer := format('%s - %d decipoints (%d x %d)',[fm.szFacename,i,
                  aptlTextBox[TXTBOX_CONCAT].x,
                  aptlTextBox[TXTBOX_TOPLEFT].y -
                  aptlTextBox[TXTBOX_BOTTOMLEFT].y]);

               // Drop POINTL structure to baseline of font

          ptl.y := ptl.y - fm.lMaxAscender ;

               // Display the character string

          GpiCharStringAt (hps, ptl, strlen (szBuffer), szBuffer) ;

               // Drop POINTL structure down to bottom of text

          ptl.y := ptl.y - fm.lMaxDescender ;

          inc(i) ;
          end;


          // Select the default font; delete the logical font


     GpiSetCharSet (hps, LCID_DEFAULT) ;

     GpiDeleteSetId (hps, LCID_FONT) ;
end;

