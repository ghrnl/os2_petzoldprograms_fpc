function pMouseMsg(pmsg : pointer) : pMseMsg;
{ input : pmsg: adress of msg  }
{ output: pointer to MSEMSG    }
{         at offset sizeof(pmsg) }
begin
  {pMouseMsg := @pmsg + Sizeof(pmsg)}
  {pMouseMsg := pMseMsg(@pmsg + Sizeof(pmsg))}
  {pMouseMsg := pMseMsg (@pmsg) + 1} {Sizeof(pmsg)}
  pMouseMsg := pMseMsg (PBYTE(pmsg) + Sizeof(pmsg))
end;

function pCommandMsg(pmsg : pointer) : pCmdMsg;
{ input : pmsg: adress of msg  }
{ output: pointer to CMDMSG    }
{         at offset sizeof(pmsg) }
begin
  pCommandMsg := pCmdMsg (PBYTE(pmsg) + Sizeof(pmsg))
end;

function pCharMsg(pmsg : pointer) : pChrMsg;
{ input : pmsg: adress of msg  }
{ output: pointer to CHRMSG    }
{         at offset sizeof(pmsg) }
begin
  pCharMsg := pChrMsg (PBYTE(pmsg) + Sizeof(pmsg))
end;

