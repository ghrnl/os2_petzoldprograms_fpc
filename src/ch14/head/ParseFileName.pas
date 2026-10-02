function ParseFileName (pcOut: Pchar; pcIn: Pchar): integer;
{
          /*----------------------------------------------------------------
             Input:    pcOut -- Pointer to parsed file specification.
                       pcIn  -- Pointer to raw file specification.
                       
             Returns:  0 -- pcIn had invalid drive or directory.
                       1 -- pcIn was empty or had no filename.
                       2 -- pcOut points to drive, full dir, and file name.

             Changes current drive and directory per pcIn string.
            ----------------------------------------------------------------*/
}

var
     pcLastSlash, pcFileOnly : Pchar;
     ulDriveNum, ulDriveMap: ULONG;
     ulDirLen: ULONG = CCHMAXPATH ;
     
     { extra }

     tmpstring: string; {needed to force a selection of DosSetCurrentDir }
     
begin

     {!!! need an in-place upper case, avoid changing the ptr }
     strcopy(pcIn,Pchar(UpperCase(pcIn)));

               // If input string is empty, return 1

     if (pcIn [0] = char(0) {'\0'}) then
          exit(1) ;

               // Get drive from input string or current drive

     if (pcIn [1] = ':') then
          begin
          if (DosSetDefaultDisk ( ord(pcIn [0]) - ord('@')))>0 then
               exit(0) ;

          pcIn := pcIn + 2 ;
          end;
     DosQueryCurrentDisk (ulDriveNum, ulDriveMap) ;

     pcOut^ := char(ulDriveNum + ord('@')) ;
     inc(pcOut);
     pcOut^ := ':' ;
     inc(pcOut);
     pcOut^ := '\' ;
     inc(pcOut);
     pcOut^ := char(0); {20221216 NEW}

               // If rest of string is empty, return 1

     if (pcIn^ = char(0) {'\0'} ) then
          exit(1) ;

               // Search for last backslash.  If none, could be directory.

     pcLastSlash := StrRScan (pcIn, '\');
     if (nil = pcLastSlash) then
          begin
          if (DosSetCurrentDir (pcIn)=0) then {!!!!}
               exit(1) ;
               
                    // Otherwise, get current dir & attach input filename

          DosQueryCurrentDir (0, pcOut[0], ulDirLen) ;  {!!!!}

          if (strlen (pcIn) > CCHMAXPATH div 2) then { 12 restricts to 8.3 filenames }
               exit(0) ;

          if ((pcOut + strlen (pcOut) - 1)^ <> '\') then begin
               strcat (pcOut, '\') ;
               pcOut := pcOut + 1 ;
          end;

          strcat (pcOut, pcIn) ;
          exit(2) ;
          end;
               // If the only backslash is at beginning, change to root

     if (pcIn = pcLastSlash) then
          begin
          {DosSetCurrentDir ('\') ;}
          tmpstring := '\';
          DosSetCurrentDir (tmpstring) ;

          if (pcIn [1] = char(0) {'\0'}) then
               exit(1) ;

          strcopy (pcOut, pcIn + 1) ;
          exit(2) ;
          end;
               // Attempt to change directory -- Get current dir if OK

     pcLastSlash := char(0) {'\0'} ;

     if (DosSetCurrentDir (pcIn))>0 then
          exit(0) ;

     DosQueryCurrentDir (0, pcOut, ulDirLen) ;

               // Append input filename, if any

     pcFileOnly := pcLastSlash + 1 ;

     if (pcFileOnly^ = char(0) {'\0'} )  then
          exit(1) ;

     if ((pcOut + strlen (pcOut) - 1)^ <> '\') then begin
          strcat (pcOut, '\') ;
     end;

     strcat (pcOut, pcFileOnly) ;
     ParseFileName := 2 ;

end; {ParseFileName}

