{ olfstr2 }

{/*-------------------------------------------
   OLFSTR2.C -- Stretched OS/2 Outline Fonts
               (c) Charles Petzold, 1993
  -------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_FONT   = 1;

{$i ..\..\ch00\maxmin.pas}

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
   szText = 'Hello!' ;

var
     iPtHt, iPtWd, iPtSize : integer;
     ptl: POINTL;
     aptl: array [0..TXTBOX_COUNT-1]  of POINTL ;

begin
          // Create the logical font, select it, and scale it

     CreateOutlineFont (hps, LCID_FONT, 'Helvetica', 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;
     ScaleOutlineFont (hps, 120, 120) ;

          // Scale font to client window size

     GpiQueryTextBox (hps, strlen (szText), szText, TXTBOX_COUNT, aptl[0]) ;

     iPtHt :=  (120 * cyClient div (aptl[TXTBOX_TOPLEFT].y -
                                      aptl[TXTBOX_BOTTOMLEFT].y)) ;
     iPtWd :=  (120 * cxClient div  aptl[TXTBOX_CONCAT].x) ;

     iPtSize := min (iPtHt, iPtWd) ;

     ScaleOutlineFont (hps, iPtSize, iPtSize) ;

          // Display the text string

     GpiQueryTextBox (hps, strlen (szText), szText, TXTBOX_COUNT, aptl[0]) ;

     ptl.x :=  (cxClient - aptl[TXTBOX_CONCAT].x) div 2 ;
     ptl.y :=  (cyClient - aptl[TXTBOX_TOPLEFT].y
                       - aptl[TXTBOX_BOTTOMLEFT].y) div 2 ;

     GpiCharStringAt (hps, ptl, strlen (szText), szText) ;

          // Select the default font; delete the logical font


     GpiSetCharSet (hps, LCID_DEFAULT) ;

     GpiDeleteSetId (hps, LCID_FONT) ;
end;

