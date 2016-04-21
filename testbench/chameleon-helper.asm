
        *=$0801

        !word link
        !word 42        ; 42
        !byte $9e       ; SYS
        !text "2061"    ; 2061
        !byte 0
link:   !word 0

        sei
        inc $d020
        lda #42
        sta $d0fe       ; enable config mode
        lda #$22        ; MMU and I/O RAM
        sta $d0fa       ; enable config registers

        lda #$00
        sta $d0f7       ; select 1 disk per drive, select image slot 1
        lda #$40
        sta $d0f8       ; enable disk drive 1 at id 8

        lda #0
        ldx $0400
        cpx #$20
        beq nocart
        lda $0401
nocart:
        sta $d0f0       ; dis/enable cartridge

        cmp #$20        ; easyflash
        bne noef
        ldx #0
        stx $de00       ; ef bank 0
        ldx #$04
        stx $de02       ; ef off
;        ldx #$1f
;        stx $dc0d
;        stx $dd0d
;        inc $0428
;        dec $d020
;        jmp *-3
noef:

        lda #$13        ; MMU Slot for Cartridge ROM
        sta $d0af
        lda #0
        ldx #$b0
        ; there is free memory at 0x00b00000
        sta $d0a0
        sta $d0a1
        stx $d0a2
        sta $d0a3

        lda #$12        ; MMU Slot for Cartridge RAM
        sta $d0af
        lda #0
        ldx #$27
        ; there is free memory at 0x00270000
        sta $d0a0
        sta $d0a1
        stx $d0a2
        sta $d0a3

        ldx #0
        lda $0402
        beq noreu
        ldx #$82        ; reu on, 512k
noreu:
        stx $d0f5       ; dis/enable REU

        lda #$27        ; MMU Slot for I/O RAM
        sta $d0af
        lda #0
        ldx #1
        ; there is free memory at 0x00010000
        sta $d0a0
        sta $d0a1
        stx $d0a2
        sta $d0a3

        lda #0
        sta $d7ff
        ; try to somewhat reset the TOD
        ldx #0
        ; cia 1 tod
        stx $dc08 ; 0 starts TOD clock
        stx $dc09 ; 0
        stx $dc0a ; 0

        ; cia 2 tod
        stx $dd08 ; 0 starts TOD clock
        stx $dd09 ; 0
        stx $dd0a ; 0
        inx
        stx $dc0b ; 1 (hour) stops TOD clock
        stx $dd0b ; 1 (hour) stops TOD clock

        lda $dc08 ; un-latch
        lda $dd08 ; un-latch

        ; clear pending flags
        lda $d01e ; Sprite to Sprite Collision Detect
        lda $d01f ; Sprite to Background Collision Detect

        ; clear pending irqs
        lda $d019
        sta $d019
        lda $dc0d
        lda $dd0d
        lda $df00 ; REU

        dec $d020
        cli
        rts