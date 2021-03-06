;ACME 0.95.7
; Name		mousetest
; Purpose	Use several input drivers to move sprites, so user can tell which type of mouse they are using.
; Author	(c) Marco Baye, 2016
; Licence	Free software
; Changes:
; 10 Jun 2016	First try, derived from aamouse and DuoDriver.
; 12 Jun 2016	Fixed comments (version 1b).
;		Flipped joystick and 1351 sprites.
; 14 Jun 2016	Added primm to make re-startable and allowed reposition-on-restore (version 1c)
; 16 Jun 2016	Fixed bug where each port change was reported twice (made amigatari use 2-pixel steps)
;		Made Amiga/ST drivers act upon _every_ port change instead of just clk bits.
;		Used raster irq to do sprite stuff in border, making version 2.

	!src "petscii.inc"
	!src "vic.inc"
	!src "sid.inc"
	!src "cia1.inc"
	!src "kernal.inc"

; driver enumeration
	ENUM_JOYSTICK	= 0
	ENUM_1351	= 1
	ENUM_AMIGA	= 2
	ENUM_ATARIST	= 3
	ENUM_CX22	= 4
	ENUM_TOTAL	= 5
; helper values
	BITMASK_ALL	= (1 << ENUM_TOTAL) - 1
	CR		= 13
	MODIFIED8	= $ff
!addr	MODIFIED16	= $ffff
	BUTTON_PRESS	= %#......#	; these are written to top
	BUTTON_NOPRESS	= %########	; row of sprite patterns
; In the sprite coordinate system, the graphics pixel (0,0) has the
; coordinates ($18, $32), so these are needed for converting. Blame the
; VIC.
	SPRITE_TO_WINDOW_X	= $18
	SPRITE_TO_WINDOW_Y	= $32
; maximum pointer coordinates (smaller than usual to force sprites to be visible)
	MAX_COORD_X	= 320 - 24
	MAX_COORD_Y	= 200 - 21

!addr	sys_iirq	= $0314	; interrupt vector
!addr	sys_inmi	= $0318	; nmi vector
!addr	screen		= $0400	; for displaying port bits
!addr	spr_ptr		= 2040	; sprite pointers

; zp variables
!addr	tmp		= $02
!addr	state_now	= $fb
!addr	state_change	= $fc
!addr	potx		= $fd	; potx and poty must be consecutive!
!addr	poty		= $fe


; basic header
	* = $0801
		!wo line2, 2016
		!by $9e, $20	; "sys "
		!by '0' + entry % 10000 / 1000
		!by '0' + entry %  1000 /  100
		!by '0' + entry %   100 /   10
		!by '0' + entry %    10
		!pet $3a, $8f, " saufbox!", $0	; ":rem "
line2		!wo 0


; PRIMM - this fits neatly before next sprite block
	primm_ptr	= tmp	; we need a zp pointer
my_primm	pla	; get low byte of return address - 1
		tay	; into Y
		pla	; get high byte of return address - 1
		sta primm_ptr + 1	; to ptr high
		lda #0	; and zero ptr low, so "(ptr), y" points before text
		sta primm_ptr
		beq +
		;--
---			; fix high byte
			inc primm_ptr + 1
			bne +++	; I trust this branch always gets taken
			;--
-			jsr k_chrout
+			iny
			beq ---
+++			lda (primm_ptr), y
			bne -
		; push updated address onto stack
		lda primm_ptr + 1
		pha
		tya
		pha
		rts	; return to caller (after zero-terminated text)


; NMI, called when user presses RESTORE
my_nmi		inc reset_pos	; set flag to let main loop know
		; now call original nmi handler
.ori_nmi = * + 1:jmp MODIFIED16


; reserve space for sprites
.hole	!align 63, 0
sprites	!warn "There are ", sprites - .hole, " unused bytes before the sprites."	; atm, 2 bytes
	!src "sprites.asm"
	* = sprites + 64 * ENUM_TOTAL - 1	; go on after sprites


; irq hook
my_irq		lda vic_irq
		bmi .raster_irq
		; now call original irq handler
.ori_irq = * + 1:jmp MODIFIED16


; raster interrupt
.raster_irq	sta vic_irq	; acknowledge interrupt
		inc vsync	; set flag to let main loop know
		jmp address($ea81)


; main program
entry ; entry point for SYS
		cld
		; output text
		jsr my_primm
		!pet petscii_LOWERCASE, petscii_CLEAR
		!pet "$dc01: %        ", CR	; (spaces are for v1/v2 kernal)
		!pet "$d419: %        ", CR
		!pet "$d41a: %        ", CR
	SCREENOFFSET_cia	= 8	; show cia bits in upper left corner
	SCREENOFFSET_potx	= 8 + 40	; and pot values
	SCREENOFFSET_poty	= 8 + 2 * 40	; below
!if SCREENOFFSET_poty > 256 - 8 { !error "X index would overrun in bit display" }
		!pet CR
		!pet "This is mousetest, version 2.", CR
		!pet "Plug mouse in joyport #1 and use it,", CR
		!pet "then check which sprite moves correctly."
		!pet CR
		!pet CR
		!pet CR
		!pet CR
		!pet CR
		!pet "Button presses are shown in top line of", CR
		!pet "sprite. Unfortunately there is no safe", CR
		!pet "way to determine the state of additional"
		!pet "buttons on Amiga and Atari mice.", CR
		!pet CR
		!pet "Press RESTORE to reset sprite positions."
		!pet CR
		!pet "If none of the icons move, the mouse may"
		!pet "be a 'NEOS mouse', which is not yet", CR
		!pet "supported by this program."
		!byte 0	; terminate
		; init sprite registers
		ldy #0
		sty vic_sdy	; no double height
		sty vic_smc	; no multicolor
		sty vic_sdx	; no double width
		ldy #BITMASK_ALL
		sty vic_sactive	; activate sprites
		sty vic_sback	; priority
		lda #int(sprites / 64) + ENUM_TOTAL - 1	; last sprite
		sta .ptr
		; set sprite block pointers
		ldx #ENUM_TOTAL - 1
--			lda #viccolor_GRAY3	; set sprite color
			sta vic_cs0, x
.ptr = * + 1:		lda #MODIFIED8	; set sprite pointer
			sta spr_ptr, x
			dec .ptr	; prepare for next iteration
			dex
			bpl --
		inc reset_pos	; make sure next interrupt re-positions the sprites
		; keep current nmi
		lda sys_inmi
		ldx sys_inmi + 1
		sta .ori_nmi
		stx .ori_nmi + 1
		; install own nmi
		lda #<my_nmi
		ldx #>my_nmi
		sta sys_inmi
		stx sys_inmi + 1
		; keep current irq
		lda sys_iirq
		ldx sys_iirq + 1
		sta .ori_irq
		stx .ori_irq + 1
		; install own irq
		lda #<my_irq
		ldx #>my_irq
		php
		sei
		sta sys_iirq
		stx sys_iirq + 1
		plp
		; raster irq
		lda #251	; first line of lower border
		sta vic_line
		lda #%...##.##
		sta vic_controlv
		lda #1	; enable raster irq
		sta vic_irqmask
; main loop ;)
; endless polling loop (amiga/atari mice must be polled as often as possible)
mainloop	; get state of joyport
		lda #0	; set port b to input
		sta cia1_ddrb
--			lda cia1_prb
			cmp cia1_prb
			bne --
		tax	; X = now
		eor state_now	; A = change
		sei
		stx state_now
		sta state_change
		cli
		; call drivers
		jsr amiga_st_idle
		jsr cx22_idle
		; check for irq stuff
vsync = * + 1:	lda #0	; MODIFIED!
		beq mainloop
; "interrupt" (ok, not really, only triggered by it)
		lsr vsync
; poll joystick and 1351 (and Amiga/Atari buttons), and update sprite positions
		lda sid_potx
		sta potx
		lda sid_poty
		sta poty
		jsr joystick_poll
		jsr cbm1351_poll
		jsr amiga_st_poll	; shared function for buttons
		jsr cx22_poll
		; check whether to reset positions
reset_pos = * + 1:lda #0	; MODIFIED!
		beq ++
			lsr reset_pos
			; set x/y values to defaults
			ldx #4 * ENUM_TOTAL - 1
--				lda initial_x_lo, x
				sta table_x_lo, x
				dex
				bpl --
++		; now update sprite positions and screen contents
		; show current port bits in upper right corner
		lda state_now
		ldx #SCREENOFFSET_cia
		jsr show_bits
		; show potx value below
		lda potx
		ldx #SCREENOFFSET_potx
		jsr show_bits
		; show poty value below
		lda poty
		ldx #SCREENOFFSET_poty
		jsr show_bits
		; move sprites
		ldx #ENUM_TOTAL - 1
--			; prepare Y to hold 2*X because sprite register layout is unfortunate
			txa
			asl
			tay
			; set x position
			lda table_x_lo, x
			clc
			adc #SPRITE_TO_WINDOW_X
			sta vic_xs0, y
			; collect x overflow bits
			lda table_x_hi, x
			adc #0
			lsr
			rol tmp
			; set y position
			lda table_y_lo, x
			clc
			adc #SPRITE_TO_WINDOW_Y
			sta vic_ys0, y
			; high byte of y is unused
			dex
			bpl --
		; fix x overflow
		lda tmp
		sta vic_msb_xs
		jmp mainloop


; helper function to display bits of port byte
; entry: A = value, X = offset
show_bits	sec	; make sure first ROL inserts a 1
		rol	; get msb
		sta tmp
--			lda #'.'
			bcc ++
				lda #'#'
				clc
++			sta screen, x
			inx
			;clc
			rol tmp	; insert 0
			bne --
		rts


; helper function for Amiga/Atari mice, increments/decrements value
; entry: X = target offset ([0..ENUM_TOTAL[ for x change, +ENUM_TOTAL for y change)
; KEEPS Y!
; Z set means decrement, Z clear means increment
changeZ		beq .decrement
		bne .increment
; helper function for Amiga/Atari mice, increments/decrements value
; entry: X = target offset ([0..ENUM_TOTAL[ for x change, +ENUM_TOTAL for y change)
; KEEPS Y!
; C set means decrement, C clear means increment
changeC		bcs .decrement
.increment	inc table_x_lo, x
		bne restrict
			inc table_x_hi, x
			jmp restrict
.decrement	lda table_x_lo, x
		bne +
			dec table_x_hi, x
+		dec table_x_lo, x
		;FALLTHROUGH
; restrict to valid range ([0..ENUM_TOTAL[ for x, +ENUM_TOTAL for y)
; KEEPS Y!
restrict	lda table_x_hi, x
		bmi .zero_it
		cmp max_x_hi, x
		bcc .rts
		bne +
			lda max_x_lo, x
			cmp table_x_lo, x
			bcs .rts
+		lda max_x_lo, x
		sta table_x_lo, x
		lda max_x_hi, x
		sta table_x_hi, x
.rts		rts

.zero_it	lda #0
		sta table_x_lo, x
		sta table_x_hi, x
		rts


	!src "joystick.asm"
	!src "1351.asm"
	!src "amiga_st.asm"
	!src "cx22.asm"


; tables
initial_x_lo	!for .i, 0, ENUM_TOTAL - 1 {
			!by 70 + .i * 32	; x lo
		}
		!fill ENUM_TOTAL, 64	; y lo
		!fill ENUM_TOTAL	; x hi
		!fill ENUM_TOTAL	; y hi

max_x_lo	!fill ENUM_TOTAL, <MAX_COORD_X
max_y_lo	!fill ENUM_TOTAL, <MAX_COORD_Y
max_x_hi	!fill ENUM_TOTAL, >MAX_COORD_X
max_y_hi	!fill ENUM_TOTAL, >MAX_COORD_Y

; external data:

	table_x_lo	= *
	table_y_lo	= * + ENUM_TOTAL
	table_x_hi	= * + ENUM_TOTAL * 2
	table_y_hi	= * + ENUM_TOTAL * 3
