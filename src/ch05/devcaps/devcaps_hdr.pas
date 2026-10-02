{/*-----------------------
   DEVCAPS.H header file
  -----------------------*/}
{ port to fpc 2.6.4 GH Renkema 2021 }

{
#define NUMLINES (sizeof devcaps / sizeof devcaps [0])
struct
     /
     LONG lIndex ;
     CHAR *szIdentifier ;
     }

const
     NUMLINES = 42;

type devcapsrec = record

     lIndex : longint;
     szIdentifier : Pchar;
  end;

var
   devcaps: array[0..NUMLINES-1] of devcapsrec = (

   (lIndex: CAPS_FAMILY                 ; szIdentifier: 'CAPS_FAMILY'                 ),
   (lIndex: CAPS_IO_CAPS                ; szIdentifier: 'CAPS_IO_CAPS'                ),
   (lIndex: CAPS_TECHNOLOGY             ; szIdentifier: 'CAPS_TECHNOLOGY'             ),
   (lIndex: CAPS_DRIVER_VERSION         ; szIdentifier: 'CAPS_DRIVER_VERSION'         ),
   (lIndex: CAPS_HEIGHT                 ; szIdentifier: 'CAPS_HEIGHT'                 ),
   (lIndex: CAPS_WIDTH                  ; szIdentifier: 'CAPS_WIDTH'                  ),
   (lIndex: CAPS_HEIGHT_IN_CHARS        ; szIdentifier: 'CAPS_HEIGHT_IN_CHARS'        ),
   (lIndex: CAPS_WIDTH_IN_CHARS         ; szIdentifier: 'CAPS_WIDTH_IN_CHARS'         ),
   (lIndex: CAPS_VERTICAL_RESOLUTION    ; szIdentifier: 'CAPS_VERTICAL_RESOLUTION'    ),
   (lIndex: CAPS_HORIZONTAL_RESOLUTION  ; szIdentifier: 'CAPS_HORIZONTAL_RESOLUTION'  ),
   (lIndex: CAPS_CHAR_HEIGHT            ; szIdentifier: 'CAPS_CHAR_HEIGHT'            ),
   (lIndex: CAPS_CHAR_WIDTH             ; szIdentifier: 'CAPS_CHAR_WIDTH'             ),
   (lIndex: CAPS_SMALL_CHAR_HEIGHT      ; szIdentifier: 'CAPS_SMALL_CHAR_HEIGHT'      ),
   (lIndex: CAPS_SMALL_CHAR_WIDTH       ; szIdentifier: 'CAPS_SMALL_CHAR_WIDTH'       ),
   (lIndex: CAPS_COLORS                 ; szIdentifier: 'CAPS_COLORS'                 ),
   (lIndex: CAPS_COLOR_PLANES           ; szIdentifier: 'CAPS_COLOR_PLANES'           ),
   (lIndex: CAPS_COLOR_BITCOUNT         ; szIdentifier: 'CAPS_COLOR_BITCOUNT'         ),
   (lIndex: CAPS_COLOR_TABLE_SUPPORT    ; szIdentifier: 'CAPS_COLOR_TABLE_SUPPORT'    ),
   (lIndex: CAPS_MOUSE_BUTTONS          ; szIdentifier: 'CAPS_MOUSE_BUTTONS'          ),
   (lIndex: CAPS_FOREGROUND_MIX_SUPPORT ; szIdentifier: 'CAPS_FOREGROUND_MIX_SUPPORT' ),
   (lIndex: CAPS_BACKGROUND_MIX_SUPPORT ; szIdentifier: 'CAPS_BACKGROUND_MIX_SUPPORT' ),
   (lIndex: CAPS_VIO_LOADABLE_FONTS     ; szIdentifier: 'CAPS_VIO_LOADABLE_FONTS'     ),
   (lIndex: CAPS_WINDOW_BYTE_ALIGNMENT  ; szIdentifier: 'CAPS_WINDOW_BYTE_ALIGNMENT'  ),
   (lIndex: CAPS_BITMAP_FORMATS         ; szIdentifier: 'CAPS_BITMAP_FORMATS'         ),
   (lIndex: CAPS_RASTER_CAPS            ; szIdentifier: 'CAPS_RASTER_CAPS'            ),
   (lIndex: CAPS_MARKER_HEIGHT          ; szIdentifier: 'CAPS_MARKER_HEIGHT'          ),
   (lIndex: CAPS_MARKER_WIDTH           ; szIdentifier: 'CAPS_MARKER_WIDTH'           ),
   (lIndex: CAPS_DEVICE_FONTS           ; szIdentifier: 'CAPS_DEVICE_FONTS'           ),
   (lIndex: CAPS_GRAPHICS_SUBSET        ; szIdentifier: 'CAPS_GRAPHICS_SUBSET'        ),
   (lIndex: CAPS_GRAPHICS_VERSION       ; szIdentifier: 'CAPS_GRAPHICS_VERSION'       ),
   (lIndex: CAPS_GRAPHICS_VECTOR_SUBSET ; szIdentifier: 'CAPS_GRAPHICS_VECTOR_SUBSET' ),
   (lIndex: CAPS_DEVICE_WINDOWING       ; szIdentifier: 'CAPS_DEVICE_WINDOWING'       ),
   (lIndex: CAPS_ADDITIONAL_GRAPHICS    ; szIdentifier: 'CAPS_ADDITIONAL_GRAPHICS'    ),
   (lIndex: CAPS_PHYS_COLORS            ; szIdentifier: 'CAPS_PHYS_COLORS'            ),
   (lIndex: CAPS_COLOR_INDEX            ; szIdentifier: 'CAPS_COLOR_INDEX'            ),
   (lIndex: CAPS_GRAPHICS_CHAR_WIDTH    ; szIdentifier: 'CAPS_GRAPHICS_CHAR_WIDTH'    ),
   (lIndex: CAPS_GRAPHICS_CHAR_HEIGHT   ; szIdentifier: 'CAPS_GRAPHICS_CHAR_HEIGHT'   ),
   (lIndex: CAPS_HORIZONTAL_FONT_RES    ; szIdentifier: 'CAPS_HORIZONTAL_FONT_RES'    ),
   (lIndex: CAPS_VERTICAL_FONT_RES      ; szIdentifier: 'CAPS_VERTICAL_FONT_RES'      ),
   (lIndex: CAPS_DEVICE_FONT_SIM        ; szIdentifier: 'CAPS_DEVICE_FONT_SIM'        ),
   (lIndex: CAPS_LINEWIDTH_THICK        ; szIdentifier: 'CAPS_LINEWIDTH_THICK'        ),
   (lIndex: CAPS_DEVICE_POLYSET_POINTS  ; szIdentifier: 'CAPS_DEVICE_POLYSET_POINTS'  )
);

