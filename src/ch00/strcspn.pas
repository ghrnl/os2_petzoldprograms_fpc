function strcspn(s1, s2: PChar): Cardinal;
var
  SrchS2: PChar;
  myResult: cardinal;
begin
  myResult := 0;
  while S1^ <> #0 do
  begin
    SrchS2 := S2;
    while SrchS2^ <> #0 do
    begin
      if S1^ = SrchS2^ then
        Exit(myResult);
      Inc(SrchS2);
    end;
    Inc(S1);
    Inc(myResult);
  end;
  strcspn := myResult
end; {strcspn}

