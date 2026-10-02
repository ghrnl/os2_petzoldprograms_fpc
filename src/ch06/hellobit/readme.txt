this has a few issues/choices...

const
     szHello = ' Hello, world! '; {this works }

var
     {szHello : Pchar = ' Hello, world! ' ;} { ??? does not work but why }
     {szHello : array [0..15-1] of char = ' Hello, world! ' ;} { ??? works but why }


and see the extra vars:

{ extra }
    xxx1: DevOpenStruc;
    xxx2: TBitmapInfo2;
    xxx3: byte=0;

