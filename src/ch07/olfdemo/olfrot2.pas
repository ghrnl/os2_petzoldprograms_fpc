{/*-----------------------------------------------------
   OLFROT2.C -- Rotated and Sheared OS/2 Outline Fonts
                (c) Charles Petzold, 1993
  -----------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_FONT  =  1;
const TWO_PI     =  (2 * 3.14159);

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
    szText = '  Rotated Font' ;

var
     dAngle: real ;
     gradl : GRADIENTL ;
     ptl, ptlShear : POINTL;

begin
          // Set POINTL structure to center of client

     ptl.x := cxClient div 2 ;
     ptl.y := cyClient div 2 ;

          // Create the logical font, select it, and scale it

     CreateOutlineFont (hps, LCID_FONT, 'Helvetica', 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;
     ScaleOutlineFont (hps, 240, 240) ;

          // Loop through the character angles

     
     {for (dAngle = 11.25 ; dAngle < 360 ; dAngle += 22.5)}
     dAngle := 11.25 ;
    while  dAngle < 360 do

          begin
               // Set the character angle

          gradl.x := round( (100 * cos (TWO_PI * dAngle / 360)) );
          gradl.y := round( (100 * sin (TWO_PI * dAngle / 360)) );

          GpiSetCharAngle (hps, gradl) ;

               // Set the character shear

          ptlShear.x := round( (100 * cos (TWO_PI * (90 - dAngle) / 360)));
          ptlShear.y := round( (100 * sin (TWO_PI * (90 - dAngle) / 360))) ;

          GpiSetCharShear (hps, ptlShear) ;

               // Display the character string

          GpiCharStringAt (hps, ptl, strlen (szText), szText) ;

          dAngle := dAngle + 22.5;

          end;

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;
end;

