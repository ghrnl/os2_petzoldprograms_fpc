library hdrlib;

{/*-----------------------------------------------------------
   HDRLIB.C -- "Handy Drawing Routines" Dynamic Link Library
               (c) Charles Petzold, 1993
  -----------------------------------------------------------*/}
{ port to VP21 GH Renkema 2022 }

uses os2def, os2pmapi, sysutils;

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

{ single arg, not a vararg list }

var
     chBuffer: Pchar;
     iLength: integer;

begin
     chBuffer := Pchar(format(szFormat,[sz1]));
     iLength := strlen(chBuffer);

     if (pptl = nil) then
          GpiCharString (hps, iLength, chBuffer)
     else
          GpiCharStringAt (hps, pptl^, iLength, chBuffer) ;

     HdrPrintf := iLength ;
end; {HdrPrintf}

function HdrEllipse (hps: cardinal; lOption: longint; pptl: PPOINTL): longint;
     cdecl;
var
     ptlCurrent : POINTL;

begin

     GpiQueryCurrentPosition (hps, ptlCurrent) ;

     HdrEllipse := GpiBox (hps, lOption, pptl^, abs (pptl^.x - ptlCurrent.x),
                                        abs (pptl^.y - ptlCurrent.y)) ;
end; {HdrEllipse}


exports
  HdrPuts index 3 {name 'HdrPuts'},
  HdrPrintf index 2 {name 'HdrPrintf'},
  HdrEllipse index 1 {name 'HdrEllipse'};

begin
end.

