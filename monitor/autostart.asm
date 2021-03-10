; 8/16k cartridge autostart header by World of Jani
; http://blog.worldofjani.com/?p=879
; Include just before program start code

    .word coldstart            ; coldstart vector
    .word warmstart            ; warmstart vector
    .byte $C3,$C2,$CD,$38,$30  ; "CBM8O". Autostart string

coldstart:
    sei
    stx $d016
    jsr $fda3 ;Prepare IRQ
    jsr $fd50 ;Init memory. Rewrite this routine to speed up boot process.
    jsr $fd15 ;Init I/O
    jsr $ff5b ;Init video
    cli

warmstart:
