          {/*--------------------------------------------------------
             Draws filled and outlined polygon (used by DrawButton)
            --------------------------------------------------------*/}

procedure  Polygon
      (hps: cardinal; lPoints: LONGint;  var aptl: array of POINTL; istart: integer; lColor: LONGint);
begin
               // Draw interior in specified color

     GpiSavePS (hps) ;
     GpiSetColor (hps, lColor) ;

     GpiBeginArea (hps, BA_NOBOUNDARY or BA_ALTERNATE) ;
     GpiMove (hps, aptl[istart+0]) ;
     GpiPolyLine (hps, lPoints - 1, aptl[istart + 1]) ;
     GpiEndArea (hps) ;

     GpiRestorePS (hps, -1) ;

               // Draw boundary in default color

     GpiMove (hps, aptl[istart + lPoints - 1]) ;
     GpiPolyLine (hps, lPoints, aptl[istart+0]) ;
end; {Polygon}

