function LastCharPos(const S: string; const Chr: char): integer;
var
  i: Integer;
begin
  for i := length(S) downto 1 do
    if S[i] = Chr then
      Exit(i);
  { 20221216 return 0 when we get here }
  Exit(0);
end;

