{/*--------------------------------------------------------------
   NEWBTN.C -- Contains window procedure for new 3D push button
               (c) Charles Petzold, 1993
  --------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const LCID_ITALIC = 1;

               {/*--------------------------------------------------
                  Structure for storing data unique to each window
                 --------------------------------------------------*/}

type NEWBTN = record
    pszText : Pchar; {PSZ;}
    fHaveCapture : boolean;
    fHaveFocus : boolean;
    fInsideRect : boolean;
    fSpaceDown : boolean;
  end;
  PNEWBTN = ^NEWBTN ;


{$i polygon.pas}
{$i DrawButton.pas}

          {/*--------------------------------
             NewBtnWndProc window procedure
            --------------------------------*/}

function NewBtnWndProc (h_wnd: HWND; msg: ULONG; mp1, mp2: MPARAM): MRESULT;
      cdecl; export;

var
     fTestInsideRect : boolean;
     hps : cardinal;
     pcrst : PCREATESTRUCT;
     ptl : POINTL;
     _pNewBtn : PNEWBTN;
     pwprm : PWNDPARAMS;
     rcl: RECTL ;
     { extra }
     xb1,xb2,xb3: boolean;

begin

     NewBtnWndProc := 0;

     _pNewBtn := WinQueryWindowPtr (h_wnd, 0) ;

     case (msg) of

          WM_CREATE: begin
               getmem (_pNewBtn,sizeof (NEWBTN)) ;

                         // Initialize structure

               _pNewBtn^.fHaveCapture := FALSE ;
               _pNewBtn^.fHaveFocus   := FALSE ;
               _pNewBtn^.fInsideRect  := FALSE ;
               _pNewBtn^.fSpaceDown   := FALSE ;

                         // Get window text from creation structure

               pcrst := PCREATESTRUCT(mp2) ;

               getmem (_pNewBtn^.pszText,1 + strlen (pcrst^.pszText)) ;
               strcopy (_pNewBtn^.pszText, pcrst^.pszText) ;

               WinSetWindowPtr (h_wnd, 0, _pNewBtn) ;
               end;

          WM_SETWINDOWPARAMS: begin
               pwprm := PWNDPARAMS(mp1) ;

                         // Get window text from window parameter structure

               if (pwprm^.fsStatus and WPM_TEXT)>0 then
                    begin
                    freemem (_pNewBtn^.pszText) ;
                    getmem (_pNewBtn^.pszText,1 + pwprm^.cchText) ;
                    strcopy (_pNewBtn^.pszText, pwprm^.pszText) ;
                    end;
               NewBtnWndProc := MRFROMSHORT (1) ;
               end;

          WM_QUERYWINDOWPARAMS: begin
               pwprm := PWNDPARAMS (mp1) ;

                         // Set window parameter structure fields

               if (pwprm^.fsStatus and WPM_CCHTEXT)>0 then
                    pwprm^.cchText := strlen (_pNewBtn^.pszText) ;

               if (pwprm^.fsStatus and WPM_TEXT)>0 then
                    strcopy (pwprm^.pszText, _pNewBtn^.pszText) ;

               if (pwprm^.fsStatus and WPM_CBPRESPARAMS)>0 then
                    pwprm^.cbPresParams := 0 ;

               if (pwprm^.fsStatus and WPM_PRESPARAMS)>0 then
                    pwprm^.pPresParams := nil ;

               if (pwprm^.fsStatus and WPM_CBCTLDATA)>0 then
                    pwprm^.cbCtlData := 0 ;

               if (pwprm^.fsStatus and WPM_CTLDATA)>0 then
                    pwprm^.pCtlData := nil ;

               NewBtnWndProc := MRFROMSHORT (1) ;
               end;

          WM_BUTTON1DOWN: begin
               WinSetFocus (HWND_DESKTOP, h_wnd) ;
               WinSetCapture (HWND_DESKTOP, h_wnd) ;
               _pNewBtn^.fHaveCapture := TRUE ;
               _pNewBtn^.fInsideRect  := TRUE ;
               WinInvalidateRect (h_wnd, nil, FALSE) ;
               end;

          WM_MOUSEMOVE: begin
               if (not _pNewBtn^.fHaveCapture) then
                   {break}
ELSE BEGIN
               WinQueryWindowRect (h_wnd, rcl) ;
               ptl.x := pMOUSEMSG(@msg).x ;
               ptl.y := pMOUSEMSG(@msg).y ;

                         // Test if mouse pointer is still in window

               fTestInsideRect := WinPtInRect (WinQueryAnchorBlock (h_wnd),
                                              rcl, ptl) ;

               if (_pNewBtn^.fInsideRect <> fTestInsideRect) then
                    begin
                    _pNewBtn^.fInsideRect := fTestInsideRect ;
                    WinInvalidateRect (h_wnd, nil, FALSE) ;
                    end;
END;
               end;

          WM_BUTTON1UP: begin
               if (not _pNewBtn^.fHaveCapture) then
                    {break}
ELSE BEGIN
               WinSetCapture (HWND_DESKTOP, 0) ;
               _pNewBtn^.fHaveCapture := FALSE ;
               _pNewBtn^.fInsideRect  := FALSE ;

               WinQueryWindowRect (h_wnd, rcl) ;
               ptl.x := pMOUSEMSG(@msg).x ;
               ptl.y := pMOUSEMSG(@msg).y ;

                         // Post WM_COMMAND if mouse pointer is in window

               if (WinPtInRect (WinQueryAnchorBlock (h_wnd), rcl, ptl)) then
                    WinPostMsg (WinQueryWindow (h_wnd, QW_OWNER),
                         WM_COMMAND,
                         MPFROMSHORT (WinQueryWindowUShort (h_wnd, QWS_ID)),
                         MPFROM2SHORT (CMDSRC_OTHER, ord(TRUE))) ;

               WinInvalidateRect (h_wnd, nil, FALSE) ;
 END;
               end;

          WM_ENABLE: begin
               WinInvalidateRect (h_wnd, nil, FALSE) ;
               end;

          WM_SETFOCUS: begin
               _pNewBtn^.fHaveFocus := (SHORT1FROMMP (mp2)>0) ;
               WinInvalidateRect (h_wnd, nil, FALSE) ;
               end;

          WM_CHAR: begin
               xb1:=(not(pCHARMSG(@msg).fs)   and  KC_VIRTUALKEY )>0   ;
               xb2:=(pCHARMSG(@msg).vkey <> VK_SPACE);
               xb3:=(pCHARMSG(@msg).fs and KC_PREVDOWN)>0;
               if
               (xb1) or
               (xb2) or
               (xb3)
                  then
                    {break}
ELSE BEGIN
                         // Post WM_COMMAND when space bar is released

               if (not(CHARMSGmp1(mp1).fs and KC_KEYUP))>0 then
                    _pNewBtn^.fSpaceDown := TRUE
               else
                    begin
                    _pNewBtn^.fSpaceDown := FALSE ;
                    WinPostMsg (WinQueryWindow (h_wnd, QW_OWNER),
                         WM_COMMAND,
                         MPFROMSHORT (WinQueryWindowUShort (h_wnd, QWS_ID)),
                         MPFROM2SHORT (CMDSRC_OTHER, ord(FALSE))) ;
                    end;
               WinInvalidateRect (h_wnd, nil, FALSE) ;
END;
               end;

          WM_PAINT: begin
               hps := WinBeginPaint (h_wnd, 0, nil) ;
               DrawButton (h_wnd, hps, _pNewBtn) ;
               WinEndPaint (hps) ;
               end;

          WM_DESTROY: begin
               freemem (_pNewBtn^.pszText) ;
               freemem (_pNewBtn) ;
               end;
     end; {case}

     NewBtnWndProc := WinDefWindowProc (h_wnd, msg, mp1, mp2) ;

end; {NewBtnWndProc}

          {/*---------------------------------------------------------
             RegisterNewBtnClass function available to other modules
            ---------------------------------------------------------*/}

function  RegisterNewBtnClass (_hab: HAB): longbool; cdecl; export;
begin
     RegisterNewBtnClass := WinRegisterClass (_hab, 'NewBtn', NewBtnWndProc,
                              CS_SIZEREDRAW, sizeof (PNEWBTN)) ;
end;

