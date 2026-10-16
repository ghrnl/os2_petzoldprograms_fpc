{ 20211208 }
{ COMMANDMSG : where used and solved }
{    =====>        cmd:=SHORT1FROMMP(mp1);  /OK/ }

{ 20221216 os2/pmapi inspired }
{
type
  PCmdMsgMp1 = ^CommandMsgMp1;  // Mp1
  CommandMsgMp1 = record
    Cmd:    SmallWord;
    Unused: SmallWord;
  end;

  PCmdMsgMp2 = ^CommandMsgMp2; // Mp2
  CommandMsgMp2 = record
    Source: SmallWord;
    fMouse: SmallWord;
  end;
}
{ FPC: CMDMSG = record
         cmd : word;
         unused : word;
         source : word;
         fMouse : word;
       end;
       PCMDMSG = ^CMDMSG;
}

function COMMANDMSG( pmsg : Pointer ) : CMDMSG;
{ COMMANDMSG requires the procedure or function }
{ passing mp1 and mp2 to be declared as cdecl   }
{ input : pmsg: adress of msg                   }
var
  pWord: ^word;
begin
  with COMMANDMSG do begin
    pWord  := pmsg + Sizeof(cardinal);
    cmd    := (pWord+0)^;
    unused := (pWord+1)^;
    source := (pWord+2)^;
    fMouse := (pWord+3)^;
  end;
end;

