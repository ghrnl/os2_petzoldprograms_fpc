{/*-------------------------------------------
   OLFWIDE.C -- Wide-Lined OS/2 Outline Font
                (c) Charles Petzold, 1993
  -------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const  LCID_FONT  = 1;

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
     szText = 'Hello!' ;

var
     ptl: POINTL;
     aptlTextBox : array [0..TXTBOX_COUNT-1] of POINTL;

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

          // Stroke the path

     GpiSetLineWidthGeom (hps, 10) ;
     GpiSetPattern (hps, PATSYM_HATCH) ;
     GpiStrokePath (hps, 1, 0) ;

          // Create the path again

     GpiBeginPath (hps, 1) ;
     GpiCharStringAt (hps, ptl, strlen (szText), szText) ;
     GpiEndPath (hps) ;

          // Modify and outline the path

     GpiModifyPath (hps, 1, MPATH_STROKE) ;
     GpiOutlinePath (hps, 1, 0) ;

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;
end;

