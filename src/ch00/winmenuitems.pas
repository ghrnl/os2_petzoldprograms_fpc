{ modelled after watcom src os2 fortran }
{ 20211228 }

function WinEnableMenuItem(hwndMenu: hwnd; id: cardinal; fEnable: boolean): longbool;
  cdecl; export;
{var  hwndMenu, id, fEnable:  integer;}
var
  ifEnable:  integer;
begin
       if( fEnable )then
            ifEnable := 0
        else
            ifEnable := MIA_DISABLED
        ; { if}
        WinEnableMenuItem := WinSendMsg( hwndMenu, MM_SETITEMATTR,
          MPFROM2SHORT( id, ord(TRUE) ),
          MPFROM2SHORT( MIA_DISABLED, ifEnable ) ) <> nil
end;


function WinCheckMenuItem(hwndMenu: hwnd; id: cardinal; fcheck: boolean): longbool;
  cdecl; export;
{ var        integer hwndMenu, id, fcheck}
var
  ifcheck: integer;
begin
        if( fcheck )then
            ifcheck := MIA_CHECKED
        else
            ifcheck := 0
        ; { if}
        WinCheckMenuItem := WinSendMsg( hwndMenu, MM_SETITEMATTR,
          MPFROM2SHORT( id, ord(TRUE) ),
          MPFROM2SHORT( MIA_CHECKED, ifcheck ) ) <> nil
end;

