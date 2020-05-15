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

SECTION "Game code", ROM0

Start:
    di	; disable interrupts
	ld	a, IEF_VBLANK	; --
	ld	[rIE], a	; Set only Vblank interrupt flag
	ei			; enable interrupts. Only vblank will trigger
    
    ; Turn off the LCD
    xor a
    ld a, [rLY]

vblank:
    nop
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

.print
    ld hl, $9800 ; set tile indexes
    ld bc, $400 
    call memzero

    ld hl, $9800
    ld a, $01 ; clear all indexes
    ld [hl], a


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
INCBIN "out.2bpp"
TilesEnd: