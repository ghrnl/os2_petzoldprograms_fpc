can roll back "all" (ca 9) integer > word changes
ok here?


function GRID (x,y: integer): PBYTE; inline;
{ both are equivalent for fpc }
begin
  {GRID :=  @pbGrid [y * xNumCells + x]}
  GRID :=  pbGrid + y * xNumCells + x
end; {GRID}


