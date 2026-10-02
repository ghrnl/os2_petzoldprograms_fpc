not >0


                 { if (!WinStartTimer (hab, hwnd, ID_TIMER, 0)) }
                         if (not WinStartTimer (_hab, Window, ID_TIMER, 0))>0 then

but =0

                 { if (!WinStartTimer (hab, hwnd, ID_TIMER, 0)) }
                         if (not WinStartTimer (_hab, Window, ID_TIMER, 0))=0 then

and finally:

                 { if (!WinStartTimer (hab, hwnd, ID_TIMER, 0)) }
                         if (WinStartTimer (_hab, Window, ID_TIMER, 0)=0) then

