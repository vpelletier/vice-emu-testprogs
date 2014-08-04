;----------------------------------------------------------------------------
; SHS "unstable" behaviour check
; inspired by emulamers "bad copy"
;----------------------------------------------------------------------------

basicstart = $0801

;testpatternlen = 21 + 2
testpatternlen = $18

                * = basicstart
                !word basicstart + $0c
                !byte $0a, $00
                !byte $9e

                !byte $32, $30, $36, $32

                !byte 0,0,0

                * = basicstart + $0d

;----------------------------------------------------------------------------

zp_testbase = $f0
patternbase = $f3

start:
                ldx #0
-
                lda #$20
                sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $0700,x
                lda #$01
                sta $d800,x
                sta $d900,x
                sta $da00,x
                sta $db00,x
                lda #$ff
                sta $0c00,x
                dex
                bne -

                SEI
; timer NMI and IRQ off
                LDA     #$7F
                STA     $DC0D
                STA     $DD0D
; set NMI
                LDA     #<nmi0
                LDX     #>nmi0
                STA     $FFFA
                STX     $FFFB
; set IRQ0
                LDA     #<irq0
                LDX     #>irq0
                STA     $FFFE
                STX     $FFFF
; all RAM
                LDA     #$35
                STA     $01
; raster IRQ on
                LDA     #1
                STA     $D01A
                LDA     #$1C
                STA     $D012
                LDA     #$1B
                STA     $D011
; timer NMI on
; it triggers on next cycle to disable RESTORE
                LDX     #$81
                STX     $DD0D
                LDX     #0
                STX     $DD05
                INX
                STX     $DD04
                LDX     #$DD
                STX     $DD0E
; setup sprite
                LDA     #$A0 ;
                STA     $D006
                LDA     #$1E
                STA     $D007

                LDA     #$33 ;sprite pointer
                STA     $7FB

                LDA     #$D
                STA     $D02A
                LDA     #$16
                STA     $D018
                LDA     #$1B
                STA     $D011

                lda     #<testpattern
                STA     patternbase
                lda     #>testpattern
                STA     patternbase+1

                lda     #<testbase
                sta     zp_testbase
                lda     #>testbase
                sta     zp_testbase+1

                LDA     #0
                STA     $D010
                STA     $D017
                STA     $D01B
                STA     $D01C
                STA     $D01D
                STA     $D020
                STA     $D021

                sta     $3fff

                LDA     #$7F
                STA     $DC0D
                STA     $DD0D

                lda     $dc0d
                inc     $d019

                cli
                jmp *

;----------------------------------------------------------------------------

nmi0:
                rti

waitvbl:
                LDA     $D011
                BMI     waitvbl

loc_E35:
                LDA     $D011
                BPL     loc_E35
                RTS

;----------------------------------------------------------------------------

                * = $0900
irq0:
; stabilize (double irq)
                LDA     #<irq1
                LDX     #>irq1
                STA     $FFFE
                STX     $FFFF
                INC     $D012
                ASL     $D019
                TSX
                CLI
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP

irq1:
                TXS

                LDX     #8
-
                DEX
                BNE     -
                BIT     $ea

                LDA     $D012
                CMP     $D012
                BEQ     +
+
                ; irq is stable now

                LDX     #7
-
                DEX
                BNE     -

                LDA     #$01
                STA     $D020

                LDA     #8
                STA     $D015
                DEC     $D020
                INC     $D020

; second test
                tsx
                stx     spsave+1

                !if (opcode = $9b) {
                LDY     #0
testlp:
                ;BIT     $ea     ; 3 cycles
                nop

                LDX     #6
-
                DEX
                BPL     -

;                inc $d021

                ;LDA     (patternbase),Y    ; 5
                lda     testpattern,y   ;4
                tax                     ;2

                ; SP = A & X
                ; addr + Y = SP & H+1

                ; testbase + Y = (SP = A & X) & $11

                ; in cycles where sprite dma stops the opcode the & H+1 drops off

                ; SP = A & X
                ; addr + Y = SP

                ; testbase + Y = (SP = A & X)

                ; SHS     testbase,Y    ; 5 cycles
                !byte $9b, <testbase, >testbase

                NOP

                INY
                CPY     #testpatternlen
                BNE     testlp
                }

spsave:         ldx     #0
                txs

                inc $d020

                ldx #0
-
                lda testbase,x
                sta $0400+(40*10),x

                ldy #5
                cmp reference,x
                beq +
                ldy #10
                sty bordercolor+1
+
                tya
                sta $d800+(40*10),x

                inx
                cpx #testpatternlen
                bne -

bordercolor:
                lda #5
                sta $d020
                lda #0
                sta $d021

; open lower border
                LDA     #$F8

-
                CMP     $D012
                BNE     -

                LDA     #$13
                STA     $D011

                LDA     #$FC
-
                CMP     $D012
                BNE     -

                LDA     #$1B
                STA     $D011

; set IRQ back to IRQ0
                LDA     #$1C
                STA     $D012

                LDA     #<irq0
                LDX     #>irq0
                STA     $FFFE
                STX     $FFFF
                ASL     $D019
                RTI

reference:
                !byte $00, $01, $02, $03, $04, $05, $06, $07
                !byte $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
                !byte $10, $11, $12, $13, $10, $11, $10, $11

testpattern:
                !byte $00, $01, $02, $03, $04, $05, $06, $07
                !byte $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
                !byte $10, $11, $12, $13, $14, $15, $16, $17
                !byte $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
                !byte $20, $21, $22, $23, $24, $25, $26, $27
                !byte $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
                !byte $30, $31, $32, $33, $34, $35, $36, $37
                !byte $38, $39, $3a, $3b, $3c, $3d, $3e, $3f
                !byte $40, $41, $42, $43, $44, $45, $46, $47
                !byte $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
                !byte $50, $51, $52, $53, $54, $55, $56, $57
                !byte $58, $59, $5a, $5b, $5c, $5d, $5e, $5f
                !byte $60, $61, $62, $63, $64, $65, $66, $67
                !byte $68, $69, $6a, $6b, $6c, $6d, $6e, $6f
                !byte $70, $71, $72, $73, $74, $75, $76, $77
                !byte $78, $79, $7a, $7b, $7c, $7d, $7e, $7f

                * = $1080
testbase: