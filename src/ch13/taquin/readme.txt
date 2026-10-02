inverted reset reverses the sequence of the bottom row only

my version has a double movement when I use the keyboard
so wrong program flow?
note all the return and break statements...


ISSUE FIXED with modified bool expr

old: wrong:
               {if ( not(CHARMSG(msg,mp1,mp2).fs and KC_VIRTUALKEY) or 
                     (CHARMSG(msg,mp1,mp2).fs and KC_KEYUP) ) >0 then}

new: ok:
               if (( not(CHARMSG(msg,mp1,mp2).fs and KC_VIRTUALKEY)>0) or 
                     ( (CHARMSG(msg,mp1,mp2).fs and KC_KEYUP) >0)) then



-rw-rw-r-- 1 gert gert 11995 dec 10 16:20 taquin_0.pas
-rw-rw-r-- 1 gert gert 12006 dec 17 12:14 taquin_1.pas
-rw-rw-r-- 1 gert gert 12028 dec 17 22:34 taquin_2.pas
-rw-rw-r-- 1 gert gert 13097 dec 17 21:50 taquin_end.pas
-rw-rw-r-- 1 gert gert   185 jan 25  2022 taquin_hdr.pas
-rw-rw-r-- 1 gert gert 12028 dec 25 14:36 taquin.pas

meld taquin_0.pas taquin_1.pas &
meld taquin_1.pas taquin_2.pas &
meld taquin_2.pas taquin.pas &
meld taquin_2.pas taquin_end.pas &


0 & 1 equiv
2 and F identical

0 and 2 junked


meld taquin_1.pas taquin.pas &
meld taquin.pas taquin_end.pas &

1>F: corrected counts for downto loops (!)
add one done:=false stmt......

taquin_end.pas was/is a debug version
can be junked

replace on array of char by pchar
tests ok
done

meld taquin_1.pas taquin_2.pas &
meld taquin_2.pas taquin.pas &



