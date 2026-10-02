{/*------------------------------------------------------------------
   PRINTDC.C -- Function to open device context for default printer
                (c) Charles Petzold, 1993
  ------------------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

var
     achPrnData: array [0..256-1] of char ;
     driv : DRIVDATA;


function OpenDefaultPrinterDC (hab: cardinal): cardinal;

var
     achDefPrnName: array [0..43-1] of CHAR;
     pchDelimiter : PCHAR;
     dop: DEVOPENSTRUC ;


begin

               // Obtain default printer name and remove semicolon

     PrfQueryProfileString (HINI_PROFILE, 'PM_SPOOLER',
                            'PRINTER', ';',
                            achDefPrnName, sizeof(achDefPrnName)) ;

     pchDelimiter := strscan (achDefPrnName, ';');
     if (pchDelimiter <> nil) then
          pchDelimiter^ := chr(0); {'\0'}

     if (achDefPrnName[0] = chr(0) {'\0'} ) then
          {return} OpenDefaultPrinterDC := DEV_ERROR
          
     else begin {1}

               // Obtain information on default printer

     PrfQueryProfileString (HINI_PROFILE, 'PM_SPOOLER_PRINTER',
                            achDefPrnName, ';;;;',
                            achPrnData, sizeof(achPrnData)) ;

               // Parse printer information string

     pchDelimiter := strscan (achPrnData, ';');
     if (pchDelimiter = nil) then
          {return} OpenDefaultPrinterDC := DEV_ERROR
          
     else begin {2}

     dop.pszDriverName := pchDelimiter + 1 ;

     pchDelimiter := strscan (dop.pszDriverName, ';');
     if (pchDelimiter = nil) then
          {return} OpenDefaultPrinterDC := DEV_ERROR
          
     else begin {3}

     dop.pszLogAddress := pchDelimiter + 1 ;
     (dop.pszLogAddress + strcspn (dop.pszLogAddress, ',;'))^ := chr(0) {'\0'} ;
     (dop.pszDriverName + strcspn (dop.pszDriverName, ',;'))^ := chr(0) {'\0'} ;

               // Fill DRIVDATA structure if necessary

     pchDelimiter := strscan (dop.pszDriverName, '.');
     if (pchDelimiter <> nil) then
          begin
          pchDelimiter^ := chr(0) {'\0'} ;
          {strncpy} {strcopy(driv.szDeviceName, pchDelimiter + 1,
                                      sizeof (driv.szDeviceName)) ;}
          { replace by copy + length adjustment }
          strcopy(driv.szDeviceName, pchDelimiter + 1) ;
          
          driv.szDeviceName[sizeof (driv.szDeviceName)-1]:=chr(0);
          dop.pdriv := @driv ;
          end
     else
          dop.pdriv := nil ;

               // Set data type to 'std'

     dop.pszDataType := 'PM_Q_STD' ;

               // Open printer device context

     OpenDefaultPrinterDC := 
           DevOpenDC (hab, OD_QUEUED, '*', 4, PDEVOPENDATA(@dop)^, 0) ;
           
     end; {3}
     end; {2}
     end; {1}

end; {OpenDefaultPrinterDC}

