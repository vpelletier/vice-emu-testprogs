; original file was: icr01.asm
;-------------------------------------------------------------------------------

;icr01.asm - this file is part
;of the C64 Emulator Test Suite
;public domain, no copyright

           *= $0801
           .byte $4c,$14,$08,$00,$97
turboass   = 780
           .text "780"
           .byte $2c,$30,$3a,$9e,$32,$30
           .byte $37,$33,$00,$00,$00
           .block
           lda #1
           sta turboass
           ldx #0
           stx $d3
           lda thisname
printthis
           jsr $ffd2
           inx
           lda thisname,x
           bne printthis
           sec
           jsr vector
           jsr main
           lda #$37
           sta 1
           lda #$2f
           sta 0
           clc
           jsr vector
           jsr $fda3
           jsr print
           .text " - ok"
           .byte 13,0
            lda #$00 ; success
            sta $d7ff
           .bend
loadnext
           .block
           ldx #$f8
           txs
           lda nextname
           cmp #"-"
           bne notempty
           jmp $a474
notempty
           ldx #0
printnext
           jsr $ffd2
           inx
           lda nextname,x
           bne printnext
           lda #0
           sta $0a
           sta $b9
           stx $b7
           lda #<nextname
           sta $bb
           lda #>nextname
           sta $bc
           jmp $e16f
           .bend

;---------------------------------------
;print text which immediately follows
;the JSR and return to address after 0

print
           .block
           pla
           sta next+1
           pla
           sta next+2
           ldx #1
next
           lda $1111,x
           beq end
           jsr $ffd2
           inx
           bne next
end
           sec
           txa
           adc next+1
           sta return+1
           lda #0
           adc next+2
           sta return+2
return
           jmp $1111
           .bend

;---------------------------------------
;print hex byte

printhb
           .block
           pha
           lsr a
           lsr a
           lsr a
           lsr a
           jsr printhn
           pla
           and #$0f
printhn
           ora #$30
           cmp #$3a
           bcc noletter
           adc #6
noletter
           jmp $ffd2
           .bend

;---------------------------------------
;wait until raster line is in border
;to prevent getting disturbed by DMAs

waitborder
           .block
;           lda $d011
;           bmi ok
;wait
;           lda $d012
;           cmp #30
;           bcs wait
;ok
wait
           lda $d011
           bpl wait
           rts
           .bend

;---------------------------------------
;wait for a key and check for STOP

waitkey
            lda #$ff ; failure
            sta $d7ff

           .block
           clc
           jsr vector
           jsr $fda3
           cli
wait
           jsr $ffe4
           beq wait
           cmp #3
           beq stop
           rts
stop
           lda turboass
           beq load
           jmp $8000
load
           jsr print
           .byte 13
           .text "break"
           .byte 13,0
           jmp loadnext
           .bend

;---------------------------------------
; vector save/restore

vector     ldx #<$334
           ldy #>$334
           jmp $ff8d

;---------------------------------------

thisname   .null "icr01"
nextname   .null "imr"

;---------------------------------------

nmiadr     .word 0

onnmi
           pha
           txa
           pha
           tsx
           lda $0104,x
           sta nmiadr+0
           lda $0105,x
           sta nmiadr+1
           pla
           tax
           pla
           rti

main

;---------------------------------------
;read icr when it is $01 and check if
;$81 follows

           .block
           sei
           lda #0
           sta $dc0e
           sta $dc0f
           lda #$7f
           sta $dc0d
           lda #$81
           sta $dc0d
           bit $dc0d
.ifeq NEWCIA - 1
           lda #2 + 1
.else
           lda #2
.endif
           sta $dc04
           lda #0
           sta $dc05
           jsr waitborder
           lda #%00001001
           sta $dc0e

           lda $dc0d
           ldx $dc0d
           ldy $dc0d
           sta got1+1
           stx got2+1
           sty got3+1

.ifeq NEWCIA - 1
           cmp #$00
           beq ok1
           jsr print
           .byte 13
           .text "cia1 icr is not $00, got $"
           .byte 0
got1       lda #0
           jsr printhb
           jsr waitkey
ok1
           ldx got2+1
           cpx #$81
           beq ok2
           jsr print
           .byte 13
           .text "cia1 icr is not $81, got $"
           .byte 0
got2       lda #0
           jsr printhb
ok2
           lda got3+1
           cmp #$00
           beq ok3
           jsr print
           .byte 13
           .text "cia1 reading icr=81 did "
           .text "not clear int, got $"
           .byte 0
got3       lda #0
           jsr printhb
ok3
.else
           cmp #$01
           beq ok1
           jsr print
           .byte 13
           .text "cia1 icr is not $01, got $"
           .byte 0
got1       lda #0
           jsr printhb
           jsr waitkey
ok1
           ldx got2+1
           cpx #$00
           beq ok2
           jsr print
           .byte 13
           .text "cia1 reading icr=01 did "
           .text "not clear int, got $"
           .byte 0
got2       lda #0
           jsr printhb
ok2
           lda got3+1
           cmp #$00
           beq ok3
           jsr print
           .byte 13
           .text "reading icr=00 had "
           .text "unexpected result, got $"
           .byte 0
got3       lda #0
           jsr printhb
ok3
.endif
           .bend

;---------------------------------------
;read icr when it is $01 and check if
;nmi follows

           .block
           sei
           lda #0
           sta nmiadr+0
           sta nmiadr+1
           sta $dd0e
           sta $dd0f
           lda #$7f
           sta $dd0d
           lda #$81
           sta $dd0d
           bit $dd0d
           lda #<onnmi
           sta $0318
           lda #>onnmi
           sta $0319
.ifeq NEWCIA - 1
           lda #2 + 1
.else
           lda #2
.endif
           sta $dd04
           lda #0
           sta $dd05
           jsr waitborder
           lda #%00001001
           sta $dd0e

           lda $dd0d
           ldx $dd0d
           ldy $dd0d
           sta got1+1
           stx got2+1

.ifeq NEWCIA - 1
           sty got3+1

           cmp #$00
           beq ok1
           jsr print
           .byte 13
           .text "cia2 icr is not $00, got $"
           .byte 0
got1       lda #0
           jsr printhb
           jsr waitkey
ok1
           ldx got2+1
           cpx #$81
           beq ok2
           jsr print
           .byte 13
           .text "cia2 icr is not $81, got $"
           .byte 0
got2       lda #0
           jsr printhb
ok2
           lda got3+1
           cmp #$00
           beq ok3
           jsr print
           .byte 13
           .text "cia2 reading icr=81 did "
           .text "not clear int, got $"
           .byte 0
got3       lda #0
           jsr printhb
ok3
           lda nmiadr+1
           bne ok4
           jsr print
           .byte 13
           .text "cia2 reading icr=81 did "
           .text "prevent nmi"
           .byte 0
           jsr waitkey
ok4
.else
           cmp #$01
           beq ok1
           jsr print
           .byte 13
           .text "cia2 icr is not $01, got $"
           .byte 0
got1       lda #0
           jsr printhb
           jsr waitkey
ok1
           ldx got2+1
           cpx #$00
           beq ok2
           jsr print
           .byte 13
           .text "cia2 reading icr=01 did "
           .text "not clear icr, got $"
           .byte 0
got2       lda #0
           jsr printhb
           jsr waitkey
ok2
           lda nmiadr+1
           beq ok3
           jsr print
           .byte 13
           .text "cia2 reading icr=01 did "
           .text "not prevent nmi"
           .byte 0
           jsr waitkey
ok3
.endif
           .bend

;---------------------------------------
;read icr when it is $81 and check if
;nmi follows

           .block
           sei
           lda #0
           sta nmiadr+0
           sta nmiadr+1
           sta $dd0e
           sta $dd0f
           lda #$7f
           sta $dd0d
           lda #$81
           sta $dd0d
           bit $dd0d
           lda #<onnmi
           sta $0318
           lda #>onnmi
           sta $0319
.ifeq NEWCIA - 1
           lda #1 + 1
.else
           lda #1
.endif
           sta $dd04
           lda #0
           sta $dd05
           jsr waitborder
           lda #%00001001
           sta $dd0e
           lda $dd0d
           ldx $dd0d
nmi
           cmp #$81
           beq ok1
           jsr print
           .byte 13
           .text "cia2 icr is not $81"
           .byte 0
           jsr waitkey
ok1
           cpx #$00
           beq ok2
           jsr print
           .byte 13
           .text "reading icr=81 did "
           .text "not clear icr"
           .byte 0
           jsr waitkey
ok2
           lda nmiadr+1
           bne ok3
           jsr print
           .byte 13
           .text "reading icr=81 must "
           .text "pass nmi"
           .byte 0
           jsr waitkey
ok3
           .bend

;---------------------------------------
;read icr when it is $00 and check if
;nmi follows

           .block
           sei
           lda #0
           sta nmiadr+0
           sta nmiadr+1
           sta $dd0e
           sta $dd0f
           lda #$7f
           sta $dd0d
           lda #$81
           sta $dd0d
           bit $dd0d
           lda #<onnmi
           sta $0318
           lda #>onnmi
           sta $0319
.ifeq NEWCIA - 1
           lda #3 + 1
.else
           lda #3
.endif
           sta $dd04
           lda #0
           sta $dd05
           jsr waitborder
           lda #%00001001
           sta $dd0e
           lda $dd0d
           ldx $dd0d
nmi
           cmp #$00
           beq ok1
           jsr print
           .byte 13
           .text "cia2 icr is not $00"
           .byte 0
           jsr waitkey
ok1
           cpx #$81
           beq ok2
           jsr print
           .byte 13
           .text "reading icr=00 may "
           .text "not clear icr"
           .byte 0
           jsr waitkey
ok2
           lda nmiadr+1
           bne ok3
           jsr print
           .byte 13
           .text "reading icr=00 may "
           .text "not prevent nmi"
           .byte 0
           jsr waitkey
ok3
           .bend

;---------------------------------------

           rts


