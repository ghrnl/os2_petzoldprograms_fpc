you can use this:


var asysvalue: integer;


                    asysvalue:=WinQuerySysValue (HWND_DESKTOP,
                                               sysvals[iLine].sIndex) ;
                    szBuffer:=pchar(Dec2Numb(asysvalue,1,10));


but this is more elegant:

                    szBuffer:=Pchar(format( '%d',[
                             WinQuerySysValue (HWND_DESKTOP,
                                      sysvals[iLine].sIndex)]));


