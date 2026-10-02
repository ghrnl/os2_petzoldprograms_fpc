program we;

{/*-------------------------------------------------------
   WE.C -- A Program that Obtains an Anchor Block Handle
           (c) Charles Petzold, 1993
  -------------------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses  pmwin;

var
  hab: cardinal;

begin
  hab := WinInitialize (0) ;
  WinTerminate (hab) ;
end.

