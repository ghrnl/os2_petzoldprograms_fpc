{ 20221225 inspired by VirtPas os2pmapi }
{ 20221226 status: functional incl -Cr  }

{ test with e.g. blokout1, blokout2, sketch }

{ FPC: MSEMSG = record
         x : integer;
         y : integer;
         codeHitTest : word;
         fsInp : word;
       end; }
{ alt: type
       MSEMSG = record
         x : word;
         y : word;
         codeHitTest : word;
         fsInp : word;
       end;
}

function MouseMsg(pmsg : pointer) : MseMsg;
{ MouseMsg requires the procedure or function  }
{ passing mp1 and mp2 to be declared as cdecl  }
{ input : pmsg: adress of msg                  }
var pWord: ^word;
begin
  with MouseMsg do begin
    pWord       := pmsg + Sizeof(cardinal);
    x           := (pWord+0)^;
    if (x>32767) then x:=0; { handle neg value: clamp to left hand side of window }
    y           := (pWord+1)^;
    if (y>32767) then y:=0; { handle neg value: clamp to bottom side of window }
    codeHitTest := (pWord+2)^;
    fsInp       := (pWord+3)^;
  end;
end;

