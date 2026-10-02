function isdigit(c: byte): boolean;
begin
  isdigit := c in [ord('0') .. ord('9')]
end;

