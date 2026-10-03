{/*------------------------------------------
   OLFJUST.C -- Justified OS/2 Outline Font
                (c) Charles Petzold, 1993
  ------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }


const  LCID_FONT      =  1;
const  FACENAME       =  'Times New Roman';
const  PTWIDTH        =  200;
const  PTHEIGHT       =  200;

const  ALIGN_LEFT     =  1;
const  ALIGN_RIGHT    =  2;
const  ALIGN_CENTER   =  3;
const  ALIGN_JUST     =  4;

const  SPACE_SINGLE   =  1;
const  SPACE_HALF     =  2;
const  SPACE_DOUBLE   =  3;


var
       iBreakCount, iSurplus : integer;
       ptlStart: POINTL;
       aptlTextBox: array [0..TXTBOX_COUNT-1] of POINTL ;

{ extra }
   iText: integer;
   iStart, iEnd: integer;
   pTextlen: integer;

procedure Justify
     (hps: cardinal; pText: Pchar;  prcl: PRECTL;  nAlign, nSpace: integer);

begin

     iText:=0;
     pTextlen := strlen(pText);

     ptlStart.y := prcl^.yTop ;

     repeat {do 1}                             // until end of text
          begin
          iBreakCount := 0 ;

          while ( pText[iText] = ' ')  do       // Skip over leading blanks
               inc(iText) ;

          {pStart := pText ;}
          iStart := iText;

          repeat {do 2}                            // until line is known
               begin
               while ( pText[iText] = ' ') and  ( iText<pTextlen ) do   // Skip over leading blanks
                    inc(iText) ;

                                        // Find next break point

               while ( iText<pTextlen ) and ( pText[iText] <> ' ') do
                    inc(iText) ;

                                        // Determine text width

               GpiQueryTextBox (hps, iText-iStart, @pText[iStart],
                                TXTBOX_COUNT, aptlTextBox[0]) ;

                         // Normal case: text less wide than column

               if (aptlTextBox[TXTBOX_CONCAT].x < (prcl^.xRight - prcl^.xLeft)) then
                    begin
                    inc(iBreakCount) ;
                    {pEnd := pText ;}
                    iEnd := iText;
                    end

                         // Text wider than window with only one word

               else if (iBreakCount = 0) then
                    begin
                    {pEnd := pText ;}
                    iEnd := iText;
                    break ;
                    end

                         // Text wider than window, so fix up and get out
               else
                    begin
                    dec(iBreakCount) ;
                    {pText := pEnd ;}
                    iText := iEnd;
                    break ;
                    end;
               end;
{do 2}
         until not (( iText< pTextlen )) ;

                         // Get the final text box

               GpiQueryTextBox (hps, iText-iStart, @pText[iStart],
                                TXTBOX_COUNT, aptlTextBox[0]) ;

                         // Drop down by maximum ascender

          ptlStart.y := ptlStart.y - aptlTextBox[TXTBOX_TOPLEFT].y ;

                         // Find surplus space in text line

          iSurplus := prcl^.xRight - prcl^.xLeft -
                     aptlTextBox[TXTBOX_CONCAT].x ;

                        // Adjust starting position and
                        // space and character spacing

          case nAlign of
               
               ALIGN_LEFT: begin
                    ptlStart.x := prcl^.xLeft ;
                    {break ;} end;

               ALIGN_RIGHT: begin
                    ptlStart.x := prcl^.xLeft + iSurplus ;
                    {break ;} end;

               ALIGN_CENTER: begin
                    ptlStart.x := prcl^.xLeft + iSurplus div 2 ;
                    {break ;} end;

               ALIGN_JUST: begin
                    ptlStart.x := prcl^.xLeft ;

                    if ( iText = pTextlen ) then
                         {break ;}
                         
                    ELSE BEGIN

                    if (iBreakCount > 0) then
                         GpiSetCharBreakExtra (hps,
                              65536 * iSurplus div  iBreakCount)

                    else if (iEnd - iStart - 1 > 0) then
                         GpiSetCharExtra (hps,
                              65536 * iSurplus div (iEnd - iStart - 1)) ;
                    
                    END
                    {break ;} end;
               end; {case nAlign}

                         // Display the string & return to normal
         
          GpiCharStringAt (hps, ptlStart, iEnd-iStart,  @pText[iStart]) ;

          GpiSetCharExtra (hps, 0) ;
          GpiSetCharBreakExtra (hps, 0) ;

                         // Drop down by maximum descender

          ptlStart.y := ptlStart.y + aptlTextBox[TXTBOX_BOTTOMLEFT].y ;

                         // Do additional line-spacing

          case nSpace of
               
               SPACE_HALF: begin
                    ptlStart.y := ptlStart.y - (aptlTextBox[TXTBOX_TOPLEFT].y -
                                   aptlTextBox[TXTBOX_BOTTOMLEFT].y) div 2 ;
                    end;

               SPACE_DOUBLE: begin
                    ptlStart.y := ptlStart.y - aptlTextBox[TXTBOX_TOPLEFT].y -
                                  aptlTextBox[TXTBOX_BOTTOMLEFT].y ;
                    end;
               end; {case}
          end;

{do 1}
     until not (( iText<pTextlen) and (ptlStart.y > prcl^.yBottom)) ;

end; {Justify}

var
  rcl: RECTL;

procedure PaintClient (hps: cardinal; cxClient, cyClient: integer);

var
  szText: Pchar = 'You don''t know about me, without you have read a book by '
                + 'the name of "The Adventures of Tom Sawyer," but that '
                + 'ain''t no matter. That book was made by Mr. Mark Twain, '
                + 'and he told the truth, mainly. There was things which he '
                + 'stretched, but mainly he told the truth. That is nothing. '
                + 'I never seen anybody but lied, one time or another, '
                + 'without it was Aunt Polly, or the widow, or maybe Mary. '
                + 'Aunt Polly - Tom''s Aunt Polly, she is - and Mary, and the '
                + 'Widow Douglas, is all told about in that book - which is '
                + 'mostly a true book; with some stretchers, as I said before.' ;

begin {PaintClient}

          // Create and size the logical font

     CreateOutlineFont (hps, LCID_FONT, FACENAME, 0, 0) ;
     GpiSetCharSet (hps, LCID_FONT) ;
     ScaleOutlineFont (hps, PTWIDTH, PTHEIGHT) ;

          // Display the text

     rcl.xLeft   := 0 ;
     rcl.yBottom := 0 ;
     rcl.xRight  := cxClient ;
     rcl.yTop    := cyClient ;

     Justify (hps, szText, @rcl, ALIGN_JUST, SPACE_SINGLE) ;

          // Select the default font; delete the logical font

     GpiSetCharSet (hps, LCID_DEFAULT) ;
     GpiDeleteSetId (hps, LCID_FONT) ;
end; {PaintClient}

