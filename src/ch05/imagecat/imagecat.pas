program imagecat;

{/*-----------------------------------------
   IMAGECAT.C -- Cat drawn using GpiImage
                 (c) Charles Petzold, 1993
  -----------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{$APPTYPE GUI}

uses os2def,pmwin,pmgpi;

{$i ..\..\ch00\mousutil.pas}

var
  cxClient, cyClient: integer ;

function ClientWindowProc (Window, Msg: cardinal; MP1, MP2: pointer): pointer;
                                                                 cdecl; export;

var
  hps : cardinal;
  ptl: POINTL;
  sizl: SIZEL;

var
  abCat: array[0..127] of byte;

procedure init_abCat;
begin
  abCat[ 0]:=$01;
  abCat[ 1]:=$F8;
  abCat[ 2]:=$1F;
  abCat[ 3]:=$80;
  abCat[ 4]:=$01;
  abCat[ 5]:=$04;
  abCat[ 6]:=$20;
  abCat[ 7]:=$80;
  abCat[ 8]:=$00;
  abCat[ 9]:=$8F;
  abCat[10]:=$F1;
  abCat[11]:=$00;
  abCat[12]:=$00;
  abCat[13]:=$48;
  abCat[14]:=$12;
  abCat[15]:=$00;
  abCat[16]:=$00;
  abCat[17]:=$28;
  abCat[18]:=$14;
  abCat[19]:=$00;
  abCat[20]:=$00;
  abCat[21]:=$1A;
  abCat[22]:=$58;
  abCat[23]:=$00;
  abCat[24]:=$00;
  abCat[25]:=$08;
  abCat[26]:=$10;
  abCat[27]:=$00;
  abCat[28]:=$00;
  abCat[29]:=$FC;
  abCat[30]:=$3F;
  abCat[31]:=$00;
  abCat[32]:=$00;
  abCat[33]:=$09;
  abCat[34]:=$90;
  abCat[35]:=$00;
  abCat[36]:=$00;
  abCat[37]:=$FC;
  abCat[38]:=$3F;
  abCat[39]:=$00;
  abCat[40]:=$00;
  abCat[41]:=$08;
  abCat[42]:=$10;
  abCat[43]:=$00;
  abCat[44]:=$00;
  abCat[45]:=$07;
  abCat[46]:=$E0;
  abCat[47]:=$00;
  abCat[48]:=$00;
  abCat[49]:=$08;
  abCat[50]:=$10;
  abCat[51]:=$00;
  abCat[52]:=$00;
  abCat[53]:=$08;
  abCat[54]:=$10;
  abCat[55]:=$C0;
  abCat[56]:=$00;
  abCat[57]:=$08;
  abCat[58]:=$10;
  abCat[59]:=$20;
  abCat[60]:=$00;
  abCat[61]:=$10;
  abCat[62]:=$08;
  abCat[63]:=$10;
  abCat[64]:=$00;
  abCat[65]:=$10;
  abCat[66]:=$08;
  abCat[67]:=$08;
  abCat[68]:=$00;
  abCat[69]:=$10;
  abCat[70]:=$08;
  abCat[71]:=$04;
  abCat[72]:=$00;
  abCat[73]:=$20;
  abCat[74]:=$04;
  abCat[75]:=$04;
  abCat[76]:=$00;
  abCat[77]:=$20;
  abCat[78]:=$04;
  abCat[79]:=$04;
  abCat[80]:=$00;
  abCat[81]:=$20;
  abCat[82]:=$04;
  abCat[83]:=$04;
  abCat[84]:=$00;
  abCat[85]:=$40;
  abCat[86]:=$02;
  abCat[87]:=$04;
  abCat[88]:=$00;
  abCat[89]:=$40;
  abCat[90]:=$02;
  abCat[91]:=$04;
  abCat[92]:=$00;
  abCat[93]:=$40;
  abCat[94]:=$02;
  abCat[95]:=$04;
  abCat[96]:=$00;
  abCat[97]:=$C0;
  abCat[98]:=$03;
  abCat[99]:=$04;
  abCat[100]:=$00;
  abCat[101]:=$9C;
  abCat[102]:=$39;
  abCat[103]:=$08;
  abCat[104]:=$00;
  abCat[105]:=$A2;
  abCat[106]:=$45;
  abCat[107]:=$08;
  abCat[108]:=$00;
  abCat[109]:=$A2;
  abCat[110]:=$45;
  abCat[111]:=$10;
  abCat[112]:=$00;
  abCat[113]:=$A2;
  abCat[114]:=$45;
  abCat[115]:=$E0;
  abCat[116]:=$00;
  abCat[117]:=$A2;
  abCat[118]:=$45;
  abCat[119]:=$00;
  abCat[120]:=$00;
  abCat[121]:=$A2;
  abCat[122]:=$45;
  abCat[123]:=$00;
  abCat[124]:=$00;
  abCat[125]:=$FF;
  abCat[126]:=$FF;
  abCat[127]:=$00;
end; {init_abCat}

begin

  init_abCat;

  case msg of

          WM_SIZE: begin
               cxClient := SHORT1FROMMP (mp2) ;
               cyClient := SHORT2FROMMP (mp2) ;
            end;

          WM_PAINT: begin
               hps := WinBeginPaint (Window, 0, nil) ;
               GpiErase (hps) ;
            

               ptl.x := cxClient div 2 - 16 ;
               ptl.y := cyClient div 2 + 16 ;
               ptl.x := cxClient div 2 - 16 ;
               ptl.y := cyClient div 2 + 16 ;
               GpiMove (hps, ptl) ;

               sizl.cx := 32 ;
               sizl.cy := 32 ;
               GpiImage (hps, 0, sizl, sizeof(abCat), abCat[0]) ;

               WinEndPaint (hps) ;

              end;
 
         else ;
 
    end; {case}
    
    ClientWindowProc :=WinDefWindowProc (window, msg, mp1, mp2) ;
    
end; {WinDefWindowProc}

{ MAIN PROGRAM }

var
  hab,hmq: cardinal;
  qmsg: TQMsg;
  hwndFrame,hwndClient: cardinal;
  flFrameFlags: cardinal;
  szClientClass: PChar = 'Imagecat' ;

begin

  flFrameFlags :=   FCF_TITLEBAR      or FCF_SYSMENU
                 or FCF_SIZEBORDER    or FCF_MINMAX
                 or FCF_SHELLPOSITION or FCF_TASKLIST;

  hab := WinInitialize (0) ;
  hmq := WinCreateMsgQueue (hab, 0) ;

  WinRegisterClass (hab, szClientClass, @ClientWindowProc, CS_SIZEREDRAW, 0) ;

  hwndFrame := WinCreateStdWindow (HWND_DESKTOP, WS_VISIBLE,
                                     flFrameFlags, szClientClass, nil,
                                     0, 0, 0, hwndClient) ;

  while WinGetMsg (hab, qmsg, 0, 0, 0) do
    WinDispatchMsg (hab, qmsg) ;

  WinDestroyWindow (hwndFrame) ;
  WinDestroyMsgQueue (hmq) ;
  WinTerminate (hab);

end.

