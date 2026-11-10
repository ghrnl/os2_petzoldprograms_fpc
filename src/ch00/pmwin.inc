{ deal with pmwin.pas limitations }
{ applies to fpc 3.2.2 and older  }

type MENUITEM = record
        iPosition : integer;
        afStyle : word;
        afAttribute : word;
        id : word;
        hwndSubMenu : cardinal;
        hItem : cardinal;
end;

