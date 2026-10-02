readme blokout2:

conditions:

not
               if (fCapture and {CHARMSG(&msg)^.} (fs>0)   and  (KC_VIRTUALKEY>0) and
                             not({CHARMSG(&msg)^.} (fs>0)   and  (KC_KEYUP>0))     and 

but
               if (fCapture and ({CHARMSG(&msg)^.} (fs>0   and  KC_VIRTUALKEY)) and
                             (not({CHARMSG(&msg)^.} (fs>0   and  KC_KEYUP))  )   and

and "mind the flow" 

FIX (or not)

                    {ptlEnd.x := SHORT1FROMMP (mp1) ;
                    ptlEnd.y := SHORT2FROMMP (mp1) ;}
                    { FIX needed here }
                    WinQueryPointerPos (HWND_DESKTOP, ptlEnd) ;
                    WinMapWindowPoints (HWND_DESKTOP, Window, ptlEnd,1) ;
