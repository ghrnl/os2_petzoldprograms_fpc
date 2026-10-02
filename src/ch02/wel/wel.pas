program wel;

{/*-------------------------------------------------
   WEL.C -- A Program that Creates a Message Queue
            (c) Charles Petzold, 1993
  -------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses pmwin;

var
  hab: cardinal;
  hmq: cardinal;

begin
     hab := WinInitialize (0) ;
     hmq := WinCreateMsgQueue (hab, 0) ;
     WinDestroyMsgQueue (hmq) ;
     WinTerminate (hab) ;
end.

