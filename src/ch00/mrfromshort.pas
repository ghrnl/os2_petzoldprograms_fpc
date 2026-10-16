function mrfromshort(n: word): pointer;

{ 20221211 several type integers > word }

{ $pragma aux MPFROMSHORT = "and eax,0000ff }
{ $pragma aux MRFROMSHORT = "and eax,0000ffffh" }

{ called in colorscr with args 1 1 .. }
{ 20221203 change MPARAM(WORD(n)) into cardinal(n) }

begin
  {mrfromshort:=pointer(n)}
  {mrfromshort:=pointer(MPARAM(WORD(n)))}
  mrfromshort:=pointer(cardinal(n))
end;

