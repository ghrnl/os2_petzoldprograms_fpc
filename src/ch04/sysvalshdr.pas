{/*----------------------------------------------
   SYSVALS.H -- System values display structure 
  ----------------------------------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

type

  valsrecord = record
    sIndex: integer; {SHORT}
    szIdentifier: Pchar; {string; }{CHAR}
    szDescription: Pchar; {string ;} {CHAR}
  end;

const
  NUMLINES = 54;
var
  sysvals: array[0..NUMLINES-1] of valsrecord;


procedure init_valsrec1(n: integer; sI: integer; szID: Pchar; szDes: Pchar);
begin
  with sysvals[n] do begin
    sIndex:= sI;
    szIdentifier:= szID; 
    szDescription:= szDes ;
  end;
end; {init_valsrec1}

procedure init_sysvals;
begin
  init_valsrec1( 0 ,SV_SWAPBUTTON,      'SV_SWAPBUTTON',      'Mouse buttons swapped flag');
  init_valsrec1( 1, SV_DBLCLKTIME,      'SV_DBLCLKTIME',      'Mouse double click time');
  init_valsrec1( 2, SV_CXDBLCLK,        'SV_CXDBLCLK',        'Mouse double click area width');
  init_valsrec1( 3, SV_CYDBLCLK,        'SV_CYDBLCLK',        'Mouse double click area height');
  init_valsrec1( 4, SV_CXSIZEBORDER,    'SV_CXSIZEBORDER',    'Sizing border width');
  init_valsrec1( 5, SV_CYSIZEBORDER,    'SV_CYSIZEBORDER',    'Sizing border height');
  init_valsrec1( 6, SV_ALARM,           'SV_ALARM',           'Alarm enabled flag');
  init_valsrec1( 7, SV_CURSORRATE,      'SV_CURSORRATE',      'Cursor blink rate');
  init_valsrec1( 8, SV_FIRSTSCROLLRATE, 'SV_FIRSTSCROLLRATE', 'Scroll bar repeat delay');
  init_valsrec1( 9, SV_SCROLLRATE,      'SV_SCROLLRATE',      'Scroll bar scroll rate');
  init_valsrec1(10, SV_NUMBEREDLISTS,   'SV_NUMBEREDLISTS',   'Undefined');
  init_valsrec1(11, SV_WARNINGFREQ,     'SV_WARNINGFREQ',     'Alarm frequency for warning');
  init_valsrec1(12, SV_NOTEFREQ,        'SV_NOTEFREQ',        'Alarm frequency for note');
  init_valsrec1(13, SV_ERRORFREQ,       'SV_ERRORFREQ',       'Alarm frequency for error');
  init_valsrec1(14, SV_WARNINGDURATION, 'SV_WARNINGDURATION', 'Alarm duration for warning');
  init_valsrec1(15, SV_NOTEDURATION,    'SV_NOTEDURATION',    'Alarm duration for note');
  init_valsrec1(16, SV_ERRORDURATION,   'SV_ERRORDURATION',   'Alarm duration for error');
  init_valsrec1(17, SV_CXSCREEN,        'SV_CXSCREEN',        'Screen width in pixels');
  init_valsrec1(18, SV_CYSCREEN,        'SV_CYSCREEN',        'Screen height in pixels');
  init_valsrec1(19, SV_CXVSCROLL,       'SV_CXVSCROLL',       'Vertical scroll bar width');
  init_valsrec1(20, SV_CYHSCROLL,       'SV_CYHSCROLL',       'Horizontal scroll bar height');
  init_valsrec1(21, SV_CYVSCROLLARROW,  'SV_CYVSCROLLARROW',  'Vertical scroll bar arrow height');
  init_valsrec1(22, SV_CXHSCROLLARROW,  'SV_CXHSCROLLARROW',  'Horizontal scroll bar arrow width');
  init_valsrec1(23, SV_CXBORDER,        'SV_CXBORDER',        'Border width');
  init_valsrec1(24, SV_CYBORDER,        'SV_CYBORDER',        'Border height');
  init_valsrec1(25, SV_CXDLGFRAME,      'SV_CXDLGFRAME',      'Dialog window frame width');
  init_valsrec1(26, SV_CYDLGFRAME,      'SV_CYDLGFRAME',      'Dialog window frame height');
  init_valsrec1(27, SV_CYTITLEBAR,      'SV_CYTITLEBAR',      'Title bar height');
  init_valsrec1(28, SV_CYVSLIDER,       'SV_CYVSLIDER',       'Vertical scroll bar slider height');
  init_valsrec1(29, SV_CXHSLIDER,       'SV_CXHSLIDER',       'Horizontal scroll bar slider width');
  init_valsrec1(30, SV_CXMINMAXBUTTON,  'SV_CXMINMAXBUTTON',  'Minimize/maximize button width');
  init_valsrec1(31, SV_CYMINMAXBUTTON,  'SV_CYMINMAXBUTTON',  'Minimize/maximize button height');
  init_valsrec1(32, SV_CYMENU,          'SV_CYMENU',          'Menu bar height');
  init_valsrec1(33, SV_CXFULLSCREEN,    'SV_CXFULLSCREEN',    'Full screen client window width');
  init_valsrec1(34, SV_CYFULLSCREEN,    'SV_CYFULLSCREEN',    'Full screen client window height');
  init_valsrec1(35, SV_CXICON,          'SV_CXICON',          'Icon width');
  init_valsrec1(36, SV_CYICON,          'SV_CYICON',          'Icon height');
  init_valsrec1(37, SV_CXPOINTER,       'SV_CXPOINTER',       'Pointer width');
  init_valsrec1(38, SV_CYPOINTER,       'SV_CYPOINTER',       'Pointer height');
  init_valsrec1(39, SV_DEBUG,           'SV_DEBUG',           'Debug version flag');
  init_valsrec1(40, SV_CMOUSEBUTTONS,   'SV_CMOUSEBUTTONS',   'Number of mouse buttons');
  init_valsrec1(41, SV_CPOINTERBUTTONS, 'SV_CPOINTERBUTTONS', 'Ditto');
  init_valsrec1(42, SV_POINTERLEVEL,    'SV_POINTERLEVEL',    'Pointer hide level');
  init_valsrec1(43, SV_CURSORLEVEL,     'SV_CURSORLEVEL',     'Cursor hide level');
  init_valsrec1(44, SV_TRACKRECTLEVEL,  'SV_TRACKRECTLEVEL',  'Tracking rectangle hide level');
  init_valsrec1(45, SV_CTIMERS,         'SV_CTIMERS',         'Number of available timers');
  init_valsrec1(46, SV_MOUSEPRESENT,    'SV_MOUSEPRESENT',    'Mouse present flag');
  init_valsrec1(47, SV_CXBYTEALIGN,     'SV_CXBYTEALIGN',     'Horizontal pixel alignment value');
  init_valsrec1(48, SV_CXALIGN,         'SV_CXALIGN',         'Ditto');
  init_valsrec1(49, SV_CYBYTEALIGN,     'SV_CYBYTEALIGN',     'Vertical pixel alignment value');
  init_valsrec1(50, SV_CYALIGN,         'SV_CYALIGN',         'Ditto');
  init_valsrec1(51, SV_EXTRAKEYBEEP,    'SV_EXTRAKEYBEEP',    'Extended key beep');
  init_valsrec1(52, SV_SETLIGHTS,       'SV_SETLIGHTS',       'Lights set from keyboard state flag');
  init_valsrec1(53, SV_INSERTMODE,      'SV_INSERTMODE',      'Insert mode flag');

end; {init_sysvals}

