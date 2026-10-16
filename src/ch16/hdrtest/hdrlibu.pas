unit hdrlibu;

{/*-----------------------------------------------------------
   HDRLIB.C -- "Handy Drawing Routines" Dynamic Link Library
               (c) Charles Petzold, 1993
  -----------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

interface

{fpc  uses os2def, pmwin, pmgpi, sysutils;}
{VP21 uses os2def, os2pmapi, sysutils;    }

uses os2def, pmwin, pmgpi, sysutils;

function HdrPuts    (hps: cardinal; pptl: PPOINTL; szText: Pchar): integer;
     cdecl;

function HdrPrintf  (hps: cardinal; pptl: PPOINTL; szFormat: Pchar; sz1: Pchar): integer;
     cdecl;

function HdrEllipse (hps: cardinal; lOption: longint; pptl: PPOINTL): longint;
     cdecl;

implementation

function HdrPuts    (hps: cardinal; pptl: PPOINTL; szText: Pchar): integer;
     cdecl;
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

function HdrPrintf  (hps: cardinal; pptl: PPOINTL; szFormat: Pchar; sz1: Pchar): integer;
     cdecl;
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

function HdrEllipse (hps: cardinal; lOption: longint; pptl: PPOINTL): longint;
     cdecl;
var
     ptlCurrent : POINTL;

begin

     GpiQueryCurrentPosition (hps, ptlCurrent) ;

     HdrEllipse := GpiBox (hps, lOption, pptl^, {l} abs (pptl^.x - ptlCurrent.x),
                                        {l} abs (pptl^.y - ptlCurrent.y)) ;
end; {HdrEllipse}


end.

