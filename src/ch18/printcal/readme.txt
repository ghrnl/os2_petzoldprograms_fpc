{ stat: improve flow (and makefix added }

{ needs wrc !!! for .RC file ! }
{ issue round szBuffer }

{ scaling for first text Month + Year is off (xfac) }
{ use strlen iso length and I get something completely different }
{ text a lot larger and rotated 180 deg? upside down }
{ fix in using longint for min, max }
{ cleanup done }

{ status 20220118: printing works but issues:
 [1] font for year/month too small (eCS only, not under Warp, strange)
 [2] rubbish page at end (one page too much ) (in both cases)
     but after ps2pdf this is gone....
     what would that do with a "real" printer???
}

{ redundant/unwanted page in ps:
%%Page: 3 3
[1 0 0 1 0 0] setmx
wc
/SavedState0 save def
w2d
0 0 m
2394 0 l
2394 3145 l
0 3145 l cp
clip n d2w
}

{ 20220118 fixes: mainly 2 items:
  [1] fix in the str*.pas file (exit + value) (!)
  [2] assignment pcpCurrent/cpLocal (!)
}

{ 20221204 some bugs }
{ September heading with strange char at end (A4 as well as Letter) }
{ page size A4 just not handled right, Letter works out better }

{ the alt version seems to fix the September 2022 bug (!!!) }


note this: 
C: lLength = sprintf (szBuffer, " %s %d ", apszMonths[iMonth], iYear) ;
P: szBuffer := format(' %s %d ', [apszMonths[iMonth], iYear]);
P: szBuffer := Pchar(format(' %s %d ', [apszMonths[iMonth], iYear]));

a space preceding and following the format specifiers.
why?

I removed all those so just kept  '%s %d'
