library hdrlib;

{/*-----------------------------------------------------------
   HDRLIB.C -- "Handy Drawing Routines" Dynamic Link Library
               (c) Charles Petzold, 1993
  -----------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{
#define INCL_GPI
#include <os2.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include "hdrlib.h"
}



{uses os2def, pmwin, pmgpi, sysutils;}

uses os2def, os2pmapi, sysutils;

{INT APIENTRY HdrPuts (HPS hps, PPOINTL pptl, PCHAR szText)}
function HdrPuts    (hps: cardinal; pptl: PPOINTL; szText: Pchar): integer;

var
     iLength: integer;
begin
     iLength := strlen (szText) ;

     if (pptl = nil) then
          GpiCharString (hps, iLength, szText)
     else
          GpiCharStringAt (hps, pptl^, iLength, szText) ;

     HdrPuts := iLength ;
end; {HdrPuts}

{INT APIENTRY HdrPrintf (HPS hps, PPOINTL pptl, PCHAR szFormat, ...)}
function HdrPrintf  (hps: cardinal; pptl: PPOINTL; szFormat: Pchar; sz1: Pchar): integer;


{
     static CHAR chBuffer [1024] ;
     INT         iLength ;
     va_list     pArguments ;
}

var
     {static} chBuffer: Pchar; {array [0..1024-1] of char ;}
     iLength: integer;
     {va_list     pArguments ;}

begin
     {va_start (pArguments, szFormat) ;}
     {iLength = vsprintf (chBuffer, szFormat, pArguments) ;}
     chBuffer := Pchar(format(szFormat,[sz1]));
     iLength := strlen(chBuffer);

     if (pptl = nil) then
          GpiCharString (hps, iLength, chBuffer)
     else
          GpiCharStringAt (hps, pptl^, iLength, chBuffer) ;

     {va_end (pArguments) ;}
     HdrPrintf := iLength ;
end; {HdrPrintf}

{LONG APIENTRY HdrEllipse (HPS hps, LONG lOption, PPOINTL pptl)}
function HdrEllipse (hps: cardinal; lOption: longint; pptl: PPOINTL): longint;

var
     ptlCurrent : POINTL;

begin

     GpiQueryCurrentPosition (hps, ptlCurrent) ;

     HdrEllipse := GpiBox (hps, lOption, pptl^, {l} abs (pptl^.x - ptlCurrent.x),
                                        {l} abs (pptl^.y - ptlCurrent.y)) ;
end; {HdrEllipse}


exports
  HdrPuts name 'HdrPuts',
  HdrPrintf name 'HdrPrintf',
  HdrEllipse name 'HdrEllipse';

begin
end.

