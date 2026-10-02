program drawline;

{/*--------------------------------------------
   DRAWLINE.C -- Draw line from radio buttons
                 (c) Charles Petzold, 1993
  --------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def, pmwin, pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
     szGroupText: array[0..2-1] of Pchar = ('Color', 'Type');
     szColorText: array[0..16-1] of Pchar = (
                                      'Background', 'Blue',      'Red',
                                      'Pink',       'Green',     'Cyan',
                                      'Yellow',     'Neutral',   'Dark Gray',
                                      'Dark Blue',  'Dark Red',  'Dark Pink',
                                      'Dark Green', 'Dark Cyan', 'Brown',
                                      'Pale Gray' );
     szTypeText : array[0..8-1] of Pchar = (
                                      'Dot',        'Short Dash',
                                      'Dash Dot',   'Double Dot',
                                      'Long Dash',  'Dash Double Dot',
                                      'Solid',      'Invisible') ;
     hwndGroup : array[0..2-1] of cardinal;
     hwndRadioColor : array[0..16-1] of cardinal;
     hwndRadioType : array[0..8-1] of cardinal;
     iCurrentColor : integer = 7;   // Neutral
     iCurrentType  : integer = 6 ;  // Solid
     aptl: array [0..5-1] of  POINTL ;

function  ClientWndProc (_hwnd, msg: cardinal; mp1, mp2: pointer) : pointer;
                                                                 cdecl; export;

var
     fm : FONTMETRICS;
     h_ps : HPS ;
     i, id, cxChar, cyChar : integer;

begin
 
     case (msg) of
          
          WM_CREATE : begin
               h_ps := WinGetPS (_hwnd) ;
               GpiQueryFontMetrics (h_ps, sizeof(fm), fm) ;
               cxChar := fm.lAveCharWidth ;
               cyChar := fm.lMaxBaselineExt ;
               WinReleasePS (h_ps) ;

               for i := 0 to 2-1 do

                    hwndGroup[i] := WinCreateWindow (
                                        _hwnd,              // Parent
                                        WC_STATIC,          // Class
                                        szGroupText[i],     // Text
                                        WS_VISIBLE or       // Style
                                             SS_GROUPBOX,
                                        (8 + 42 * i) * cxChar,
                                        4 * cyChar,         // Position
                                        (26 + 12 * (1 - i)) *
                                             cxChar,        // Width
                                        14 * cyChar,        // Height
                                        _hwnd,              // Owner
                                        HWND_TOP,           // Placement
                                        i + 24,             // ID
                                        nil,                // Ctrl Data
                                        nil) ;              // Pres Params

               for i := 0 to 8-1 do

                    hwndRadioColor[i] := WinCreateWindow (
                                        _hwnd,              // Parent
                                        WC_BUTTON,          // Class
                                        szColorText[i],     // Text
                                        WS_VISIBLE or       // Style
                                             BS_RADIOBUTTON,
                                        (10 + 0)
                                             * cxChar,      // X Position
                                        (31 - 3 * (i mod 8))
                                             * cyChar div 2, // Y Position
                                        16 * cxChar,         // Width
                                        3 * cyChar div 2,    // Height
                                        _hwnd,               // Owner
                                        HWND_BOTTOM,         // Placement
                                        i,                   // ID
                                        nil,                 // Ctrl Data
                                        nil) ;               // Pres Params

               for i := 8 to 16-1 do

                    hwndRadioColor[i] := WinCreateWindow (
                                        _hwnd,              // Parent
                                        WC_BUTTON,          // Class
                                        szColorText[i],     // Text
                                        WS_VISIBLE or       // Style
                                             BS_RADIOBUTTON,
                                        (10 + (18 ))
                                             * cxChar,      // X Position
                                        (31 - 3 * (i mod 8))
                                             * cyChar div 2, // Y Position
                                        16 * cxChar,         // Width
                                        3 * cyChar div 2,    // Height
                                        _hwnd,               // Owner
                                        HWND_BOTTOM,         // Placement
                                        i,                   // ID
                                        nil,                 // Ctrl Data
                                        nil) ;               // Pres Params


               for i := 0 to 8-1 do

                    hwndRadioType[i]  := WinCreateWindow (
                                        _hwnd,              // Parent
                                        WC_BUTTON,          // Class
                                        szTypeText[i],      // Text
                                        WS_VISIBLE or       // Style
                                             BS_RADIOBUTTON,
                                        52 * cxChar,        // Position
                                        (31 - 3 * i) * cyChar div 2,
                                        22 * cxChar,        // Width
                                        3 * cyChar div 2,   // Height
                                        _hwnd,              // Owner
                                        HWND_BOTTOM,        // Placement
                                        i + 16,             // ID
                                        nil,                // Ctrl Data
                                        nil) ;              // Pres Params
                    
               WinSendMsg (hwndRadioColor[iCurrentColor],
                           BM_SETCHECK, MPFROMSHORT (1), nil) ;

               WinSendMsg (hwndRadioType[iCurrentType],
                           BM_SETCHECK, MPFROMSHORT (1), nil) ;

               aptl[0].x := 4 * cxChar ;
               aptl[3].x := 4 * cxChar ;
               aptl[4].x := 4 * cxChar ;
               aptl[1].x := 80 * cxChar ;
               aptl[2].x := 80 * cxChar ;

               aptl[0].y :=  2 * cyChar ;
               aptl[1].y :=  2 * cyChar ;
               aptl[4].y :=  2 * cyChar ;
               aptl[2].y := 20 * cyChar ;
               aptl[3].y := 20 * cyChar ;

             end;

          WM_CONTROL: begin
               id := SHORT1FROMMP (mp1) ;

               if (id < 16) then            // Color IDs
                    begin
                    WinSendMsg (hwndRadioColor[iCurrentColor],
                                BM_SETCHECK, MPFROMSHORT (0), nil) ;

                    iCurrentColor := id ;

                    WinSendMsg (hwndRadioColor[iCurrentColor],
                                BM_SETCHECK, MPFROMSHORT (1), nil) ;
                    end

               else if (id < 24) then       // Line Type IDs
                    begin
                    WinSendMsg (hwndRadioType[iCurrentType],
                                BM_SETCHECK, MPFROMSHORT (0), nil) ;

                    iCurrentType := id - 16 ;

                    WinSendMsg (hwndRadioType[iCurrentType],
                                BM_SETCHECK, MPFROMSHORT (1), nil) ;
                    end;
               WinInvalidateRect (_hwnd, nil, TRUE) ;
             end;

          WM_PAINT: begin
               h_ps := WinBeginPaint (_hwnd, 0, nil) ;
               GpiErase (h_ps) ;

               GpiSetColor (h_ps, iCurrentColor) ;
               GpiSetLineType (h_ps, iCurrentType + LINETYPE_DOT) ;
               GpiMove (h_ps, aptl[0]) ;
               GpiPolyLine (h_ps, 4, aptl [ + 1]) ;

               WinEndPaint (h_ps) ;
             end;
          
          otherwise;
          
          end; {case}
          
          ClientWndProc := WinDefWindowProc (_hwnd, msg, mp1, mp2) ;

end; {ClientWndProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: Pchar = 'DrawLine';

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWndProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

