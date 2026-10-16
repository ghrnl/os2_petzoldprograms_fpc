{/*----------------------------------------
   OLFROT.C -- Rotated OS/2 Outline Fonts
               (c) Charles Petzold, 1993
  ----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_FONT  =  1;
const TWO_PI     =  (2 * 3.14159);

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
  szText = '  Rotated Font' ;

var
    dAngle : real;
    gradl : GRADIENTL;
    ptl : POINTL ;

begin

          // Set POINTL structure to center of client

     ptl.x := cxClient div 2 ;
     ptl.y := cyClient div 2 ;

          // Create the logical font, select it, and scale it

     CreateOutlineFont (hps, LCID_FONT, 'Helvetica', 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;
     ScaleOutlineFont (hps, 240, 240) ;

          // Loop through the character angles

     dAngle:=0;
     while (dAngle < 360 ) do

          begin
               // Set the character angle

          gradl.x := {LONG} round( (100 * cos (TWO_PI * dAngle / 360)) ) ;
          gradl.y := {LONG} round( (100 * sin (TWO_PI * dAngle / 360)) ) ;

          GpiSetCharAngle (hps, gradl) ;

               // Display the character string

          GpiCharStringAt (hps, ptl, strlen (szText), szText) ;

          dAngle := dAngle + 22.5;

          end; {while}

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;

end;

