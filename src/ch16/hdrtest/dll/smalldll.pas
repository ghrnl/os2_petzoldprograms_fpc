library SmallDLL;

{ source;  vp21lang.pdf, page 128 ff }
{ 20181223 my changes: quotes around MinL, insert a begin before end. }

function MaxL(A, B: Longint): Longint;
begin
  if A > B then Result := A else Result := B;
end;

function MinL(A, B: Longint): Longint;
begin
  if A < B then Result := A else Result := B;
end;

function SumL(A, B: Longint): Longint; export;
begin
  if A < B then Result := A else Result := B;
end;

exports
  MaxL index 1, {// Export by ordinal}
  MinL name 'MinL', {// Export by name}
  SumL; {// Export by name}

begin
end.
