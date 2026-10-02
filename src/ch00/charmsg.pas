{ 20221225 inspired by VirtPas os2pmapi }
{ 20221226 status: functional incl -Cr  }

{ test with e.g. typeaway }

{ FPC: CHRMSG = record
         fs : word;
         cRepeat : byte;
         scancode : byte;
         chr : word;
         vkey : word;
       end;
       PCHRMSG = ^CHRMSG;
}

function CharMsg( pmsg : Pointer ) : ChrMsg;
{ CharMsg requires the procedure or function  }
{ passing mp1 and mp2 to be declared as cdecl }
{ input : pmsg: adress of msg                 }
var
  pWord: ^word;
  wx: word;
begin
  with CharMsg do begin
    pWord       := pmsg + Sizeof(cardinal);
    fs          := (pWord+0)^;
    wx          := (pWord+1)^;
    scancode    := wx div 256;
    cRepeat     := wx mod 256;
    chr         := (pWord+2)^; {type word is risky here; could force to safe with mod 256}
    vkey        := (pWord+3)^;
  end;
end;

