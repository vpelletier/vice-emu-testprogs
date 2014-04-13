        !to "via3.prg", cbm

TESTID =          3

tmp=$fc
addr=$fd
add2=$f9

ERRBUF=$5f00
TMP=$8000          ; measured data on C64 side
DATA=$9000

TESTLEN =         $20

NUMTESTS =        16 - 4

DTMP   = $0700          ; measured data on drive side
TESTSLOC = $1000


        !src "common.asm"


        * = TESTSLOC

;------------------------------------------
; before:
;       [Timer A lo | Timer A hi] = 1
;       Timer A CTRL = [Timed Interrupt when Timer 1 is loaded, no PB7 |
;                       Continuous Interrupts, no PB7 |
;                       Timed Interrupt when Timer 1 is loaded, one-shot on PB7 |
;                       Continuous Interrupts, square-wave on PB7]
; in the loop:
;       read IRQ Flags

	!zone {         ; 
.test 	lda #1
	sta $1804       ; Timer A lo
	;lda #$1
	;sta $dc0e       ; start timer A continuous
        lda #%00000000
        sta $180b       ; Timed Interrupt when Timer 1 is loaded, no PB7

	ldx #0
.t1b	lda $180d       ; IRQ Flags / ACK
	sta DTMP,x
	inx
	bne .t1b
	rts
        * = .test+TESTLEN
        }

	!zone {         ; 
.test 	lda #1
	sta $1804       ; Timer A lo
	;lda #$1
	;sta $dc0e       ; start timer A continuous
        lda #%01000000
        sta $180b       ; Continuous Interrupts, no PB7

	ldx #0
.t1b	lda $180d       ; IRQ Flags / ACK
	sta DTMP,x
	inx
	bne .t1b
	rts
        * = .test+TESTLEN
        }

        !zone {         ; 
.test   lda #1
        sta $1804       ; Timer A lo
        ;lda #$11
        ;sta $dc0e       ; start timer A continuous, force reload
        lda #%10000000
        sta $180b       ; Timed Interrupt when Timer 1 is loaded, one-shot on PB7

        ldx #0
.t1b    lda $180d       ; IRQ Flags / ACK
        sta DTMP,x
        inx
        bne .t1b
        rts
        * = .test+TESTLEN
        }

        !zone {         ; 
.test   lda #1
        sta $1804       ; Timer A lo
        ;lda #$11
        ;sta $dc0e       ; start timer A continuous, force reload
        lda #%11000000
        sta $180b       ; Continuous Interrupts, square-wave on PB7

        ldx #0
.t1b    lda $180d       ; IRQ Flags / ACK
        sta DTMP,x
        inx
        bne .t1b
        rts
        * = .test+TESTLEN
        }

        !zone {         ; 
.test   lda #1
        sta $1805       ; Timer A hi
        ;lda #$1
        ;sta $dc0e       ; start timer A continuous
        lda #%00000000
        sta $180b       ; Timed Interrupt when Timer 1 is loaded, no PB7

        ldx #0
.t1b    lda $180d       ; IRQ Flags / ACK
        sta DTMP,x
        inx
        bne .t1b
        rts
        * = .test+TESTLEN
        }

        !zone {         ; 
.test   lda #1
        sta $1805       ; Timer A hi
        ;lda #$1
        ;sta $dc0e       ; start timer A continuous
        lda #%01000000
        sta $180b       ; Continuous Interrupts, no PB7

        ldx #0
.t1b    lda $180d       ; IRQ Flags / ACK
        sta DTMP,x
        inx
        bne .t1b
        rts
        * = .test+TESTLEN
        }

        !zone {         ; 
.test   lda #1
        sta $1805       ; Timer A hi
        ;lda #$11
        ;sta $dc0e       ; start timer A continuous, force reload
        lda #%10000000
        sta $180b       ; Timed Interrupt when Timer 1 is loaded, one-shot on PB7

        ldx #0
.t1b    lda $180d       ; IRQ Flags / ACK
        sta DTMP,x
        inx
        bne .t1b
        rts
        * = .test+TESTLEN
        }

        !zone {         ; 
.test   lda #1
        sta $1805       ; Timer A hi
        ;lda #$11
        ;sta $dc0e       ; start timer A continuous, force reload
        lda #%11000000
        sta $180b       ; Continuous Interrupts, square-wave on PB7

        ldx #0
.t1b    lda $180d       ; IRQ Flags / ACK
        sta DTMP,x
        inx
        bne .t1b
        rts
        * = .test+TESTLEN
        }

;------------------------------------------
; before:
;       [Timer B lo | Timer B hi] = 1
;       Timer B CTRL = [Continuous | Count Pulses on PB6]
; in the loop:
;       read IRQ Flags

	!zone {         ; 
.test 	lda #1
	sta $1808       ; Timer B lo
	;lda #$1
	;sta $dc0f       ; start timer B continuous
        lda #%00000000
        sta $180b       ; Continuous

	ldx #0
.t1b	lda $180d       ; IRQ Flags / ACK
	sta DTMP,x
	inx
	bne .t1b
	rts
        * = .test+TESTLEN
        }

	!zone {         ; 
.test	lda #1
	sta $1808       ; Timer B lo
	;lda #$1
	;sta $dc0f       ; start timer B continuous
        lda #%00100000
        sta $180b       ; Count Pulses on PB6

	ldx #0
.t1b	lda $180d       ; IRQ Flags / ACK
	sta DTMP,x
	inx
	bne .t1b
	rts
        * = .test+TESTLEN
        }

	!zone {         ; 
.test 	lda #1
	sta $1809       ; Timer B hi
	;lda #$1
	;sta $dc0f       ; start timer B continuous
        lda #%00000000
        sta $180b       ; Continuous

	ldx #0
.t1b	lda $180d       ; IRQ Flags / ACK
	sta DTMP,x
	inx
	bne .t1b
	rts
        * = .test+TESTLEN
        }

	!zone {         ; 
.test	lda #1
	sta $1809       ; Timer B hi
	;lda #$1
	;sta $dc0f       ; start timer B continuous
        lda #%00100000
        sta $180b       ; Count Pulses on PB6

	ldx #0
.t1b	lda $180d       ; IRQ Flags / ACK
	sta DTMP,x
	inx
	bne .t1b
	rts
        * = .test+TESTLEN
        }

        * = DATA
        !bin "via3ref.bin", NUMTESTS * $0100, 2
        