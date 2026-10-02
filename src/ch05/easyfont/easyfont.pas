{easyfont.pas}

{/*----------------------------------------------
   EASYFONT.C -- Routines for Using Image Fonts
                 (c) Charles Petzold, 1993
  ----------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

var
  alMatch: array [0..5-1,0..6-1] of longint;
  szFacename: array [0..5-1] of Pchar = ( 'System Proportional',
                               'System Monospaced',
                               'Courier', 'Helv', 'Tms Rmn') ;
  iFontSize: array [0..6-1] of integer = (80, 100, 120, 140, 180, 240);

var
     hdc: cardinal ;
     lHorzRes, lVertRes, lRequestFonts, lNumberFonts : longint;

function EzfQueryFonts (hps:cardinal ): boolean;

type
  fontArray = array of FONTMETRICS;
var
  pfm: fontArray;

var
  hlpres: boolean;
  iIndex, iFace, iSize: integer; { LOCAL FOR LOOP COUNTERS }

begin {EzfQueryFonts}
    
     hdc := GpiQueryDevice (hps) ;
     DevQueryCaps (hdc, CAPS_HORIZONTAL_FONT_RES, 1, lHorzRes) ;
     DevQueryCaps (hdc, CAPS_VERTICAL_FONT_RES,   1, lVertRes) ;

     setlength(pfm,5);

     for iFace := 0  to 5-1 do 
          begin
          lRequestFonts := 0 ;
          lNumberFonts := GpiQueryFonts (hps, QF_PUBLIC, szFacename[iFace],
                                        lRequestFonts, 0, pfm[0]) ;

       if (lNumberFonts <> 0) then begin
           setlength(pfm,lNumberFonts);

          GpiQueryFonts (hps, QF_PUBLIC, szFacename[iFace],
                         lNumberFonts, sizeof (FONTMETRICS), pfm[0]) ;

          for iIndex := 0 to lNumberFonts-1 do begin
               if ((pfm[iIndex].sXDeviceRes = {(SHORT)} lHorzRes ) and
                   (pfm[iIndex].sYDeviceRes = {(SHORT)} lVertRes ) and
                  ((pfm[iIndex].fsDefn mod 2) = 0)) then
                    begin 
                    for iSize := 0  to 6-1 do 
                         if (pfm[iIndex].sNominalPointSize = iFontSize[iSize]) then
                              break ;

                    if (iSize <> 6-1) then
                         alMatch[iFace][iSize] := pfm[iIndex].lMatch ;
                    end;
         end; {for iIndex}
         
       end; {if (lNumberFonts <> 0)}
       hlpres:=true;
     end; {for iFace}
     
     EzfQueryFonts:=hlpres;
     
end; {EzfQueryFonts}

var
  fat: FATTRS ;

function EzfCreateLogFont (hps: cardinal; lcid: longint; idFace: integer;
                           idSize: integer; fsSelection: byte ): longint;

var
   xxx: str8;    {???} { array[0..7]of char}
begin
     if (idFace > 4 ) or (idSize > 5) or (alMatch[idFace][idSize]= 0)  then
          EzfCreateLogFont:=0
     else begin
       fat.usRecordLength := sizeof(fat) ;
       fat.fsSelection    := fsSelection ;
       fat.lMatch         := alMatch[idFace,idSize] ;

       strcopy (fat.szFacename, szFacename[idFace]) ;

       EzfCreateLogFont := GpiCreateLogFont (hps, xxx, lcid, fat) ;
   end;
end; {EzfCreateLogFont}

