{/*--------------------------------------------------------
   OLFREFL2.C -- Reflected and Rotated OS/2 Outline Fonts
                 (c) Charles Petzold, 1993
  --------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_FONT   = 1;

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

const
   szText = 'Reflect' ;

var
     gradl  : GRADIENTL    ;
     i  : integer ;
     ptl : POINTL ;

    is1,is2: integer;

begin
          // Set POINTL structure to center of client

     ptl.x := cxClient div 2 ;
     ptl.y := cyClient div 2 ;

          // Create the logical font and select it

     CreateOutlineFont (hps, LCID_FONT, 'Times New Roman', 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;

          // Set character angle

     gradl.x := 1 ;
     gradl.y := 1 ;

     GpiSetCharAngle (hps, gradl) ;

     for i := 0  to 4-1 do 
          begin
          if (i>1) then is1:= -720 else is1:=720;
          if (i mod 2 = 1) then is2:= -720 else is2:=720;
          ScaleOutlineFont (hps, is1, is2) ;

               // Display the character string

          GpiCharStringAt (hps, ptl, strlen (szText), szText) ;
     end; {for}

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;

end;

