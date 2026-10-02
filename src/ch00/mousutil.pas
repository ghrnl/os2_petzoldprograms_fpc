{ mousutil.pas}

{ 20221211 several type integers > word }
{ 20221230 add/move some comments plus some opt }

function SHORT1FROMMP(MP: pointer): word;
{ map C name SHORT1... on fpc name integer1... }
{ pmwin.pas:    function Integer1FromMP (MP: pointer): word; cdecl; }
begin
  SHORT1FROMMP:=integer1frommp(mp)
end;

function SHORT2FROMMP(MP: pointer): word;
{ map C name SHORT2... on fpc name integer2... }
{ pmwin.pas:    function Integer2FromMP (MP: pointer): word; cdecl; }
begin
  SHORT2FROMMP:=integer2frommp(mp)
end;

{ ========================== }
{ Next 3 SOMEWHAT validated  }
{ ========================== }

function makelong(low1,high2: word): cardinal;
{MAKELONG( low, high )   ((LONG)(((WORD)(low)) | (((DWORD)((WORD)(high))) << 16)))}
{ tentative }
begin
  makelong:=low1 + high2 shl 16
end;

function MPFROM2SHORT(n1,n2: word): pointer;
{ 20211020 works in sysval3 ? }
begin
  MPFROM2SHORT:=pointer(makelong(n1,n2))
end;

function MPFROMSHORT(n1: word): pointer;
{ 20211020 works in sysval2 }
{ 20211020
$ grep -r MPFROMSHORT *
fortran/os2/pmwin.for:     +     MPFROMSHORT( usCheckState ), 0 )
fortran/os2/pmwin.for:     +     LM_QUERYITEMTEXTLENGTH, MPFROMSHORT( index ), 0 )
fortran/os2/pmwin.fap:c$pragma aux MPFROMSHORT = "and eax,0000ffffh" \
fortran/os2/pmwin.fi:        integer*4 MPFROMSHORT
}
begin
  MPFROMSHORT:=pointer(makelong(n1,0))
end;

{ ==============================  }
{ all CHAR* below ok for KEYLOOK  }
{ ==============================  }
{ typ nicer: use CHARMSG.fieldid  }
{ 20211102 corr', all had 3 m iso 2 }
{ 20211103 swap mod and div/keylook }

function CHAR1FROMMP(P: pointer): char;
begin
  CHAR1FROMMP:=chr(integer1frommp(p) and $FF) {mod 256}
end;

function CHAR2FROMMP(P: pointer): char;
begin
  CHAR2FROMMP:=chr(integer1frommp(p) shr 8) {div 256}
end;

function CHAR3FROMMP(P: pointer): char;
begin
  CHAR3FROMMP:=chr(integer2frommp(p) and $FF) {mod 256}
end;

function CHAR4FROMMP(P: pointer): char;
begin
  CHAR4FROMMP:=chr(integer2frommp(p) shr 8) {div 256}
end;

{ =================== }
{ all below tentative }
{ =================== }

function SHORT1FROMMR(MR: pointer): word; {not integer...}
{ tentative }
{ 20211020
grep -r SHORT1FROMMR *
fortran/os2/pmwin.fap:c$pragma aux SHORT1FROMMR = "and eax,0000ffffh" \
fortran/os2/pmwin.fi:        integer*4 SHORT1FROMMR
}
begin
  SHORT1FROMMR := lo(cardinal(mr))
end;

function SHORT2FROMMR(MR: pointer): word; {not integer...}
{ tentative }
{ 20211020
$ grep -r SHORT2FROMMR *
fortran/os2/pmwin.fap:c$pragma aux SHORT2FROMMR = "shr eax,16" \
fortran/os2/pmwin.fi:        integer*4 SHORT2FROMMR
}
begin
  SHORT2FROMMR := hi(cardinal(mr))
end;

{ 20211022 added }
{ ~/Downloads/watcom_source/ow-snapshot/src$ grep -r HIUSHORT *
fortran/os2/os2def.fi:        integer*2 HIUSHORT
fortran/os2/os2def.fi:        external HIUSHORT
fortran/os2/os2def.fap:c$pragma aux HIUSHORT = "shr eax,16" \
fortran/os2/os2def.fap:c$pragma aux (HIUSHORT) ERRORIDSEV
}

{ 20211103 CHARMSG    }
{ all tentative       }
{ See Petzold figs:   }
{   fig 4.2 at p. 126 }
{   fig 8.1 at p. 466 }

{ mp1 HI short2 LO short1 }
{ mp2 HI short2 LO short1 }

{ 20220114 use TChrMsg from fpc pmwin.pas }
{ 20220114 and chrcode becomes chr        }

{$i mousemsg.pas}
{$i charmsg.pas}

