;ACME 0.95.7
; driver for Atari CX-22 trackball

; CIA #1, $dc01: %76543210
;	bit7	bit6	bit5	bit4	bit3	bit2	bi1	bit0
;	keyb,	keyb,	keyb,	BUTTON,	YClk,	YDir,	XClk,	XDir

; signal change sequences on pins 4321 (bits 3210):
; '_' means don't care, "->" shows flow of time, all sequences wrap around
; up	| 00__ -> 10__
; down	| 01__ -> 11__
; left	| __00 -> __10
; right	| __01 -> __11

	!zone cx22
	.BUTTON		= %00010000
	.CLKBIT_Y	= %00001000
	.DIRBIT_Y	= %00000100
	.CLKBIT_X	= %00000010
	.DIRBIT_X	= %00000001

cx22_poll ; called via interrupt
		; button(s)
		ldy #BUTTON_NOPRESS
		lda state_now
		and #.BUTTON
		bne +
			ldy #BUTTON_PRESS
+		sty sprite_cx22	; O##
		rts

cx22_idle ; called as often as possible
		; check for X change
		lda state_change
		and #.CLKBIT_X
		beq +
			; X coordinate has changed
			ldx #ENUM_CX22
			lda #.DIRBIT_X
			bit state_now
			jsr changeZ
+		; check for Y change
		lda state_change
		and #.CLKBIT_Y
		beq +
			; Y coordinate has changed
			ldx #ENUM_CX22 + ENUM_TOTAL	; means "y stuff"
			lda #.DIRBIT_Y
			bit state_now
			jsr changeZ
+		rts
