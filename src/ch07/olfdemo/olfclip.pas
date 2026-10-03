{/*-----------------------------------------
   OLFCLIP.C -- OS/2 Outline Font Clipping
                (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const  LCID_FONT  = 1;

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
     szText = 'Hello!'  ;

var
     i : integer;
     ptl: POINTL;
     aptl: array [0..3-1] of POINTL;
     aptlTextBox: array [0..TXTBOX_COUNT-1] of POINTL;

begin

          // Create and size the logical font

     CreateOutlineFont (hps, LCID_FONT, 'Times New Roman Italic', 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;
     ScaleOutlineFont (hps, 1440, 1440) ;

          // Get the text box

     GpiQueryTextBox (hps, strlen (szText), szText,
                      TXTBOX_COUNT, aptlTextBox[0]) ;

          // Create the path

     GpiBeginPath (hps, 1) ;

     ptl.x := (cxClient - aptlTextBox [TXTBOX_CONCAT].x) div 2 ;
     ptl.y := (cyClient - aptlTextBox [TXTBOX_TOPLEFT].y
                       - aptlTextBox [TXTBOX_BOTTOMLEFT].y) div 2 ;

     GpiCharStringAt (hps, ptl, strlen (szText), szText) ;

     GpiEndPath (hps) ;

          // Set the clipping path

     GpiSetClipPath (hps, 1, SCP_AND or SCP_ALTERNATE) ;

          // Draw Bezier splines

     for i := 0  to cyClient-1 do
          begin
          GpiSetColor (hps, (i div 16) mod 6 + 1) ;

          ptl.x := 0 ;
          ptl.y := i ;
          GpiMove (hps, ptl) ;

          aptl[0].x := cxClient div 3 ;
          aptl[0].y := i + cyClient div 3 ;

          aptl[1].x := 2 * cxClient div 3 ;
          aptl[1].y := i - cyClient div 3 ;

          aptl[2].x := cxClient ;
          aptl[2].y := i ;

          GpiPolySpline (hps, 3, aptl[0]) ;
          end;

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;
end;

