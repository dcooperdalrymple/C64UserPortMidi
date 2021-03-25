; C64.H
; Version 0.1
; D Cooper Dalrymple - 2021.03.25
; Based on http://unusedino.de/ec64/technical/project64/memory_maps.html

VERSION_C64         = 001

; Changelog
; 0.1   2021.03.25  Initial development

;===============
; C64 Constants
;===============

LOROM   = $8000
HIROM   = $A000
NMIVEC  = $0318 ; $0318-$0319 Interrupt Vector (2 bytes)

; CIA #1
CIA1A       = $DC00 ; User Port data port A (keyboard matrix columns & joystick/paddle #2)
CIA1B       = $DC01 ; User Port data port B (keyboard matrix rows & joystick/paddle #1)
CIA1DDRA    = $DC02 ; Data direction port A
CIA1DDRB    = $DC03 ; Data direction port B
CIA1ICR     = $DC0D ; Interrupt Control Register

; CIA #2
CIA2A       = $DD00 ; User Port data port A (serial bus access)
CIA2B       = $DD01 ; User Port data port B
CIA2DDRA    = $DD02 ; Data direction port A
CIA2DDRB    = $DD03 ; Data direction port B
CIA2ICR     = $DD0D ; Interrupt Control Register

; Kernal Screen Functions
CHROUT      = $FFD2 ; Print character from accumulator to screen
BDCOL       = $D020 ; Border Color
BKCOL       = $D021 ; Background Color (0?)
CHCOL       = $0286 ; Current character Color
SCINIT      = $FF81 ; Init VIC & clear screen
CURCOL      = $00D3 ; Cursor column
CURROW      = $00D6 ; Cursor row
DECOUT      = $BDCD ; Print accumulator as decimal number

; Kernal Keyboard Functions
SCNKEY      = $FF9F ; Scan keyboard
GETIN       = $FFE4 ; Read keyboard buffer
KEYLEN      = $0289 ; Maximum length of buffer, max 15
KEYREP      = $028A ; Keyboard repeat switch

; Screen Codes
EOL         = $0D
EOF         = $03
CLS         = $93
SPACE       = $20

; Keyboard Codes
KEY_F1      = $85
KEY_F3      = $86
KEY_F5      = $87
KEY_F7      = $88
KEY_NA      = $00 ; No key was pressed

; Color Codes
COL_BLACK       = $00
COL_WHITE       = $01
COL_RED         = $02
COL_CYAN        = $03
COL_PURPLE      = $04
COL_GREEN       = $05
COL_BLUE        = $06
COL_YELLOW      = $07
COL_ORANGE      = $08
COL_BROWN       = $09
COL_PINK        = $0A
COL_DARK_GREY   = $0B
COL_GREY        = $0C
COL_LIGHT_GREEN = $0D
COL_LIGHT_BLUE  = $0E
COL_LIGHT_GREY  = $0F
