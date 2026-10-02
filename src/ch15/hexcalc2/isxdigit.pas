function isxdigit(c: byte): boolean;
{ returns true for 0..9 a..f A..F }
begin
  isxdigit := c in [ord('A') .. ord('F'), ord('a')..ord('f'), ord('0')..ord('9')]
end;

