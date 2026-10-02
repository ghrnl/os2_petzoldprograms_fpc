function toupper(c: byte): byte;
begin
  if (c in [ord('a') .. ord('z')]) then
    toupper := c + ord('A')-ord('a')
  else
    toupper := c
end;

