
CARTTYPE = 0

PAYLOADLOC = $0600

    * = $0000

    !fill $2000, $a5

    !pseudopc $e000 {

start:


    ldx #0
-
    txa
    and #$0f
    sta $0002,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    sta $0800,x
    sta $0900,x
    sta $0a00,x
    sta $0b00,x
    sta $0c00,x
    sta $0d00,x
    sta $0e00,x
    sta $0f00,x
    inx
    bne -

    ldx #0
-
    lda payload,x
    sta PAYLOADLOC,x
    lda payload+$100,x
    sta PAYLOADLOC+$100,x
    lda payload+$200,x
    sta PAYLOADLOC+$200,x
    lda payload+$300,x
    sta PAYLOADLOC+$300,x
    inx
    bne -

    jmp PAYLOADLOC

payload:
    }
    !src "vic.asm"

    * = $3ffa
    !word start
    !word start
    !word start
    
