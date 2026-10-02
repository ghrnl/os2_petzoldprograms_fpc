{ make FIXED number from SHORT integer part and USHORT fractional part }
function MakeFixed(intpart,fractpart : SmallInt) : Fixed; inline;
begin
  MakeFixed := fractpart OR intpart shl 16;
end;

