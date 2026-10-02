see the not-clean dir !!!

{ deviating Main ! }

var
    szText : Pchar = '1,234,567,890 bytes' ; { a value just for size }

This has an issue due to integer sizing?
E.g. for 512M memory it reports ca 816M free...

WIP:

{ STATUS: MAIN TBD, and 3 errors left }
{ 20220124: functional :) use doscalls and a few fixes mostly strlen iso sizeof  }
{ and MAIN updated }

{
freemem.pas(182,16) Error: Identifier not found "DosQuerySysInfo"
freemem.pas(182,33) Error: Identifier not found "QSV_TOTAVAILMEM"
freemem.pas(182,50) Error: Identifier not found "QSV_TOTAVAILMEM"
freemem.pas(245) Fatal: There were 3 errors compiling module, stopping
}


note: sizeof(ULONG) = sizeof(cardinal) = 4

program cs;

uses os2def;

begin
  writeln('cardinal   ', sizeof(cardinal));
  writeln('ULONG  ', sizeof(ULONG));
end.


