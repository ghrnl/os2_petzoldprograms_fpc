{/*-----------------------------------------
   OLFSHAD.C -- Shadowed OS/2 Outline Font
                (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_FONT   = 1;

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
  szText  = 'Shadow' ;

var
    ptl, ptlShear : POINTL;

begin
          // Color the client window

     GpiSetColor (hps, CLR_BLUE) ;

     ptl.x := 0 ;
     ptl.y := 0 ;
     GpiMove (hps, ptl) ;

     ptl.x := cxClient ;
     ptl.y := cyClient ;
     GpiBox (hps, DRO_FILL, ptl, 0, 0) ;

          // Create the logical font

     CreateOutlineFont (hps, LCID_FONT, 'Times New Roman', 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;

          // Display the shadow

     GpiSetColor (hps, CLR_DARKBLUE) ;

     ScaleOutlineFont (hps, 2160, 720) ;

     ptlShear.x := 2 ;
     ptlShear.y := 1 ;
     GpiSetCharShear (hps, ptlShear) ;

     ptl.x := cxClient div 8 ;
     ptl.y := cyClient div 4 ;
     GpiCharStringAt (hps, ptl, strlen (szText), szText) ;

          // Display the text

     GpiSetColor (hps, CLR_RED) ;

     ScaleOutlineFont (hps, 720, 720) ;

     ptlShear.x := 0 ;
     ptlShear.y := 1 ;
     GpiSetCharShear (hps, ptlShear) ;

     GpiCharStringAt (hps, ptl, strlen (szText), szText) ;

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;
end;

