{/*---------------------------------------
   EASYFONT.H header file for EASYFONT.C
  ---------------------------------------*/}

{BOOL EzfQueryFonts    (HPS hps) ;
LONG EzfCreateLogFont (HPS hps, LONG lcid, INT idFace, INT idSize,
                                           USHORT fsSelection) ;
}


const FONTFACE_SYSTEM = 0;
const FONTFACE_MONO   = 1;
const FONTFACE_COUR   = 2;
const FONTFACE_HELV   = 3;
const FONTFACE_TIMES  = 4;

const FONTSIZE_8      = 0;
const FONTSIZE_10     = 1;
const FONTSIZE_12     = 2;
const FONTSIZE_14     = 3;
const FONTSIZE_18     = 4;
const FONTSIZE_24     = 5;

