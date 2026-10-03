{/*------------------------------------------
   OLFSHEAR.C -- Sheared OS/2 Outline Fonts
                 (c) Charles Petzold, 1993
  ------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_FONT  =  1;
const TWO_PI     =  (2 * 3.14159);

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

var
     szBuffer : array [0..32-1] of char ;
     dAngle : real ;
     fm : FONTMETRICS ;
     ptl, ptlShear : POINTL;

begin

          // Set POINTL structure to near-left top of client

     ptl.x := cxClient div 8 ;
     ptl.y := cyClient ;

          // Create the logical font, select it, and scale it

     CreateOutlineFont (hps, LCID_FONT, 'Helvetica', 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;
     ScaleOutlineFont (hps, 160, 160) ;

     GpiQueryFontMetrics (hps, sizeof (FONTMETRICS), fm) ;

          // Loop through the shear angles

     dAngle:=0;
     while (dAngle<360) do
          begin
               // Set the shear angle

          ptlShear.x := round( (100 * cos (TWO_PI * dAngle / 360)) );
          ptlShear.y := round( (100 * sin (TWO_PI * dAngle / 360)) );

          GpiSetCharShear (hps, ptlShear) ;

               // Display the character string

          ptl.y := ptl.y - fm.lMaxAscender ;

          szBuffer := format('Character Shear (%.1f) degrees', [dAngle]);

          GpiCharStringAt (hps, ptl,
                  strlen(szBuffer),
                    szBuffer) ;

          ptl.y := ptl.y - fm.lMaxDescender ;
          dAngle := dAngle + 22.5;
     end; {while}

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;
end;

