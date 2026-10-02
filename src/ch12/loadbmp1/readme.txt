
NEW:  uses resources so...
rc -r loadbmp.rc

fpc loadbmp1
rc loadbmp.rc loadbmp1.exe

mwah

note that there is also a unit (RTL) pmbitmap ...
use wrc (Watcom) and it works
this is in the pp install tree !!!!!!!!!!!!!!!

summarizing:

fpc loadbmp1
wrc loadbmp.res loadbmp1.exe


