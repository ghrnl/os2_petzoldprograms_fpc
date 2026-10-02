          {/*---------------------
             Draws Square Button
            ---------------------*/}

procedure DrawButton (hwnd: cardinal; hps: cardinal; _pNewBtn: PNEWBTN);

var
     fat : FATTRS;
     fm : FONTMETRICS;
     hdc : cardinal;
     lColor, lHorzRes, lVertRes, cxEdge, cyEdge : longint;
     aptl: array [0..10-1] of POINTL;
     aptlTextBox: array [0..TXTBOX_COUNT-1] of POINTL;
     ptlShadow, ptlText : POINTL;
     rcl : RECTL ;
     
     { extra }
     xxxstr8: str8;

begin {DrawButton}

               // Find 2 millimeter edge width in pixels

     hdc := GpiQueryDevice (hps) ;
     DevQueryCaps (hdc, CAPS_HORIZONTAL_RESOLUTION, 1, lHorzRes) ;
     DevQueryCaps (hdc, CAPS_VERTICAL_RESOLUTION,   1, lVertRes) ;

     cxEdge := lHorzRes div 500 ;
     cyEdge := lVertRes div 500 ;

               // Set up coordinates for drawing the button

     WinQueryWindowRect (hwnd, rcl) ;

     aptl[0].x := 0 ;                    aptl[0].y := 0 ;
     aptl[1].x := cxEdge ;               aptl[1].y := cyEdge ;
     aptl[2].x := rcl.xRight - cxEdge ;  aptl[2].y := cyEdge ;
     aptl[3].x := rcl.xRight - 1 ;       aptl[3].y := 0 ;
     aptl[4].x := rcl.xRight - 1 ;       aptl[4].y := rcl.yTop - 1 ;
     aptl[5].x := rcl.xRight - cxEdge ;  aptl[5].y := rcl.yTop - cyEdge ;
     aptl[6].x := cxEdge ;               aptl[6].y := rcl.yTop - cyEdge ;
     aptl[7].x := 0 ;                    aptl[7].y := rcl.yTop - 1 ;
     aptl[8].x := 0 ;                    aptl[8].y := 0 ;
     aptl[9].x := cxEdge ;               aptl[9].y := cyEdge ;

               // Paint edges at bottom and right side

     GpiSetColor (hps, CLR_BLACK) ;
     if (_pNewBtn^.fInsideRect or _pNewBtn^.fSpaceDown) then
       lColor :=  CLR_PALEGRAY 
     else
       lColor :=  CLR_DARKGRAY ;
     
     Polygon (hps, 4, @aptl [0], lColor) ;
     Polygon (hps, 4, @aptl [2], lColor) ;

               // Paint edges at top and left side

     if (_pNewBtn^.fInsideRect or _pNewBtn^.fSpaceDown) then
       lColor :=  CLR_DARKGRAY 
     else
       lColor :=  CLR_WHITE ;

     Polygon (hps, 4, @aptl [4], lColor) ;
     Polygon (hps, 4, @aptl [6], lColor) ;

               // Paint interior area

     GpiSavePS (hps) ;
     if  (_pNewBtn^.fInsideRect or _pNewBtn^.fSpaceDown) then
       GpiSetColor (hps, CLR_DARKGRAY )
     else
       GpiSetColor (hps, CLR_PALEGRAY) ;
     
     GpiMove (hps, aptl [1]) ;
     GpiBox (hps, DRO_FILL, aptl [5], 0, 0) ;
     GpiRestorePS (hps, -1) ;
     GpiBox (hps, DRO_OUTLINE, aptl [5], 0, 0) ;

               // If button has focus, use italic font

     GpiQueryFontMetrics (hps, {(LONG)} sizeof(fm), fm) ;

     if (_pNewBtn^.fHaveFocus) then
          begin
          fat.usRecordLength  := sizeof(fat) ;
          fat.fsSelection     := FATTR_SEL_ITALIC ;
          fat.lMatch          := 0 ;
          fat.idRegistry      := fm.idRegistry ;
          fat.usCodePage      := fm.usCodePage ;
          fat.lMaxBaselineExt := fm.lMaxBaselineExt ;
          fat.lAveCharWidth   := fm.lAveCharWidth ;
          fat.fsType          := 0 ;
          fat.fsFontUse       := 0 ;
          strcopy (fat.szFacename, fm.szFacename) ;

          GpiCreateLogFont (hps, xxxstr8, LCID_ITALIC, fat) ;
          GpiSetCharSet (hps, LCID_ITALIC) ;
          end;
               // Calculate text position

     GpiQueryTextBox (hps, strlen (_pNewBtn^.pszText), _pNewBtn^.pszText,
                           TXTBOX_COUNT, aptlTextBox[0]) ;

     ptlText.x := (rcl.xRight - aptlTextBox[TXTBOX_CONCAT].x) div 2 ;
     ptlText.y := (rcl.yTop   - aptlTextBox[TXTBOX_TOPLEFT].y -
                               aptlTextBox[TXTBOX_BOTTOMLEFT].y) div 2 ;

     ptlShadow.x := ptlText.x + fm.lAveCharWidth   div 3 ;
     ptlShadow.y := ptlText.y - fm.lMaxBaselineExt div 8 ;

               // Display text shadow in black, and text in white

     GpiSetColor (hps, CLR_BLACK) ;
     GpiCharStringAt (hps, ptlShadow, strlen (_pNewBtn^.pszText),
                                       _pNewBtn^.pszText) ;
     GpiSetColor (hps, CLR_WHITE) ;
     GpiCharStringAt (hps, ptlText, strlen (_pNewBtn^.pszText),
                                     _pNewBtn^.pszText) ;

               // X out button if the window is not enabled

     if (not WinIsWindowEnabled (hwnd)) then
          begin
          GpiMove (hps, aptl [1]) ;
          GpiLine (hps, aptl [5]) ;
          GpiMove (hps, aptl [2]) ;
          GpiLine (hps, aptl [6]) ;
          end;
               // Clean up

     if (_pNewBtn^.fHaveFocus) then
          begin
          GpiSetCharSet (hps, LCID_DEFAULT) ;
          GpiDeleteSetId (hps, LCID_ITALIC) ;
          end;
end; {DrawButton}

