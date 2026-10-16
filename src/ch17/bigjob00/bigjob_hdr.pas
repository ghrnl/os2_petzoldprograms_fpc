{/*----------------------
   BIGJOB.H header file
  ----------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

const ID_RESOURCE = 1;

const IDM_REPS   = 1;
const IDM_ACTION = 2;
const IDM_10     = 10;
const IDM_100    = 11;
const IDM_1000   = 12;
const IDM_10000  = 13;
const IDM_100000 = 14;
const IDM_START  = 20;
const IDM_ABORT  = 21;

const STATUS_READY    = 0;
const STATUS_WORKING  = 1;
const STATUS_DONE     = 2;

const WM_CALC_DONE    = (WM_USER + 0);  // Used in BIGJOB4 and BIGJOB5
const WM_CALC_ABORTED = (WM_USER + 1);  // Used in BIGJOB4 and BIGJOB5

const STACKSIZE  = 4096;                // Used in BIGJOB4 and BIGJOB5

{typedef struct}                        // Used in BIGJOB4 and BIGJOB5

type
  CALCPARAM = record   
     h_wnd : HWND;
     lCalcRep : LONGint;
     fContinueCalc : boolean;
     hevTrigger: longint; {HEV ;}                 // Used in BIGJOB5 as longint
  end;
  PCALCPARAM = ^CALCPARAM;

