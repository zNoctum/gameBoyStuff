INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100] ; I'm repeating this line so you know where we are. Don't write it twice!

EntryPoint: ; This is where execution begins
    di ; Disable interrupts. That way we can avoid dealing with them, especially since we didn't talk about them yet :p
    jp Start ; Leave this tiny space

REPT $150 - $104
    db 0
ENDR

SECTION "Vblank", ROM0[$0040]
	jp vblank

SECTION "MEM", ROM0
; hl = destination address
; bc = count of bytes
memzero::
    xor a
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, memzero
    ret

SECTION "PRINT", rom0
; @param a - value
; @param hl - location
; @destroy b c
PrintHex::
    ld b, a
    ld a, "0"
    ld [hli], a
    ld a, "x"
    ld [hli], a
    ld a, b
    swap a
    call .printNibble
    ld a, b
    call .printNibble
    ret

.printNibble
    and $0F
    cp 10
    jr c, .digit
    add ("A" - 10) - "0" ; We want 10 to map to "A", but we also have to compensate for the add just below
.digit
    add a, "0" ; Turn digit into character code
    ld [hli], a
    ret


SECTION "Game code", ROM0

Start:
    di	; disable interrupts
	ld	a, IEF_VBLANK	; --
	ld	[rIE], a	; Set only Vblank interrupt flag
	ei			; enable interrupts. Only vblank will trigger
    
    ; Turn off the LCD
    xor a
    ld a, [rLY]
    ld sp, $ffff

vblank:
    xor a ; ld a, 0 ; We only need to reset a value with bit 7 reset, but 0 does the job
    ld [rLCDC], a ; We will have to write to LCDC again later, so it's not a bother, really.

    ld hl, $9000
    ld de, Tiles
    ld bc, TilesEnd - Tiles
.loadTiles
    ld a, [de] ; Grab 1 byte from the source
    ld [hli], a ; Place it at the destination, incrementing hl
    inc de ; Move to next byte
    dec bc ; Decrement count
    ld a, b ; Check if count is 0, since `dec bc` doesn't update flags
    or c
    jr nz, .loadTiles

    ld hl, $9800 ; clear background
    ld bc, $400 
    call memzero

    ld hl, $9800
    
    xor a
    ld a, $ff
    rla
    call printHex

    ; Init Color palette
    ld a, %11100100
    ld [rBGP], a

    xor a ; ld a, 0
    ld [rSCY], a
    ld [rSCX], a

    ; Shut sound down
    ld [rNR52], a

    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a
    ; Lock up
.lockup
    jr .lockup


SECTION "Tiles", ROM0

Tiles:
INCBIN "font.chr"
TilesEnd: