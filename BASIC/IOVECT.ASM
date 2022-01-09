;__________________________________________________________
;
; BIOS JUMP TABLE (NATIVE)
;__________________________________________________________
LPRINTVEC        .EQU    $00FD00
LINPVEC          .EQU    $00FD04
LINPWVEC         .EQU    $00FD08
LSetXYVEC        .EQU    $00FD0C
LCPYVVEC         .EQU    $00FD10
LSrlUpVEC        .EQU    $00FD14
LSetColorVEC     .EQU    $00FD18                        :
LCURSORVEC       .EQU    $00FD1C
LUNCURSORVEC     .EQU    $00FD20
LWRITERTC        .EQU    $00FD24
LREADRTC         .EQU    $00FD28
LIECIN           .EQU    $00FD2C
LIECOUT          .EQU    $00FD30
LUNTALK          .EQU    $00FD34
LUNLSTN          .EQU    $00FD38
LLISTEN          .EQU    $00FD3C
LTALK            .EQU    $00FD40
LSETLFS          .EQU    $00FD44
LSETNAM          .EQU    $00FD48
LLOAD            .EQU    $00FD4C
LSAVE            .EQU    $00FD50
LIECINIT         .EQU    $00FD54
LIECCLCH         .EQU    $00FD58                ; close input and output channels
LIECOUTC         .EQU    $00FD5C                ; open a channel for output
LIECINPC         .EQU    $00FD60                ; open a channel for input
LIECOPNLF        .EQU    $00FD64                ; open a logical file
LIECCLSLF        .EQU    $00FD68                ; close a specified logical file
LClearScrVec     .EQU    $00FD6C                ; clear the 9918 Screen
LLOADFONTVec     .EQU    $00FD70                ; load the 9918 font


CSRX           	.EQU $0330 			; CURRENT X POSITION
CSRY           	.EQU $0331 			; CURRENT Y POSITION
ConsoleDevice	.EQU    $0341		; Current Console Device
VIDEOWIDTH	    .EQU    $0343
SpriteAttrs	    .EQU    $0344
SpritePatterns  .EQU    $0345
IECSTW			.equ 	$000317
IECMSGM			.equ 	$00031F         ; message mode flag,
					        ; $C0 = both control and kernal messages,
					        ; $80 = control messages only,
					        ; $40 = kernal messages only,
					        ; $00 = neither control or kernal messages
LOADBUFL		.equ 	$000322		; IEC buffer Pointer
LOADBUFH		.equ 	LOADBUFL+1
LOADBANK		.equ 	LOADBUFL+2	; BANK buffer Pointer
IECSTRTL		.equ 	$00031D		; IEC Start Address Pointer
IECSTRTH		.equ 	IECSTRTL+1
LINEFLGS        .EQU $03D0          		; 24 BYTES OF LINE POINTERS (3D0 - 3E9 , one extra for scrolling)

CMDP:			.EQU 	$FE0B 		; 	VDP COMMAND port
DATAP:			.EQU 	$FE0A 		; 	VDP Data port

;__________________________________________________________




;___V_INPT_________________________________________________
;
; MAKE A BIOS CALL TO GET NON-BLOCKING CHARACTER INPUT
; THIS COULD BE SERIAL OR KEYBOARD DEPENDING ON BIOS SETTING
; RETURNS
;   A: CHARACTER
;      CARRY SET IF NO CHARACTER
;
;
;   NOTE THAT BIOS IS IN BANK 0, SO A LONG BRANCH IS REQUIRED
;__________________________________________________________
V_INPT:
    PHB
    PHD
    PHX
    LDX #$00
    PHX
    PLB
	JSL LINPVEC		; INCHAR
    PLX
    PLD
    PLB
    RTS

;___V_OUTP_________________________________________________
;
; MAKE A BIOS CALL TO SEND CHARACTER TO OUTPUT
; THIS COULD BE SERIAL OR TMS9918 CHARACTER DISPLAY
;
;   A: CHARACTER
;
;
;   NOTE THAT BIOS IS IN BANK 0, SO A LONG BRANCH IS REQUIRED
;__________________________________________________________

V_OUTP:				; send byte to output device
    PHB
    PHD
    PHX
    LDX <VIDEOMODE
    CPX #2
    BNE V_OUTP1
    LDX #$00
    PHX
    PLB
	JSL LPRINTVEC	; OUTCHAR
V_OUTP1:
    PLX
    PLD
    PLB
    RTS


        .include 'diskcmds.asm'
        .include 'screencmds.asm'
        .include 'ay38910.asm'



;___TitleScreen_____________________________________________
;
; Basic Title Screen
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
TitleScreen:
        JSR psginit
        LDA #40
        STA >VIDEOWIDTH
        LDA #2
        STA <VIDEOMODE
        lda >ConsoleDevice
        cmp #$00
        bne TitleScreen_1
       	LDA	#<LAB_SMSG1		; point to sign-on message (low addr)
	    LDY	#>LAB_SMSG1		; point to sign-on message (high addr)
	    JSR	LAB_18C3		; print null terminated string from memory
        rts
TitleScreen_1:
        LDX     #02
        JSR     V_SCREEN1
        PHB
        SETBANK 0
        lda     #$F4
        JSL LSetColorVEC
        LDX #$00
        TXY
        JSL LSetXYVEC
        plb
 	    LDA	#<LAB_CONMSG		; point to sign-on message (low addr)
	    LDY	#>LAB_CONMSG		; point to sign-on message (high addr)
	    JSR	LAB_18C3		; print null terminated string from memory
        RTS

;___ScreenEditor____________________________________________
;
; Basic Screen editor code
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
ScreenEditor:
        pha
        phx
        phy
        php
        AccumulatorIndex8
        PHB
        SETBANK 0
; allow prepopulate of screen
ploop:
    jsl LCURSORVEC
    jsl LINPWVEC
    cmp #$FF
    beq ploop
    jsl LUNCURSORVEC
    cmp #01
    beq crsrup
    cmp #02
    beq crsrdn
    cmp #$1f
    beq crsrlt
    cmp #$04
    beq crsrrt
    PHA
    jsl LPRINTVEC
    PLA
    cmp #13
    beq pexit
    jmp ploop

crsrup:
    lda CSRY
    cmp #00
    beq ploop
    dec CSRY
    bra ploop
crsrdn:
    lda CSRY
    cmp #23
    beq crsrdn_1
    inc CSRY
    bra ploop
crsrdn_1:
    lda CSRX
    pha
    LDA #40
    ldx #0
    ldy #23
    stx CSRX
    sty CSRY
    jsl LSrlUpVEC
    pla
    sta CSRX
    bra ploop
crsrlt:
    lda CSRX
    cmp #00
    beq crsrlt_1
    dec CSRX
    jmp ploop
crsrlt_1
    lda CSRY
    cmp #00
    beq ploop
    lda #39
    sta CSRX
    dec CSRY
    jmp ploop
crsrrt:
    lda CSRX
    cmp #39
    beq crsrrt_1
    inc CSRX
    jmp ploop
crsrrt_1
    lda #00
    sta CSRX
    bra crsrdn
pexit:
    jsr LdKbBuffer

    LDX #81
    LDA #$00
    STA >LIbuffs,X
TERMLOOP:
    DEX
    LDA >LIbuffs,X
    CMP #32
    BEQ TERMLOOP_B
    CMP #00
    BEQ TERMLOOP_C
    BRA TERMLOOP_A
TERMLOOP_B:
    LDA #00
    STA >LIbuffs,X
TERMLOOP_C:
    CPX #00
    BNE TERMLOOP
TERMLOOP_A:

    PLB
    plp
    PLY
    PLX
    PLA
    RTS


LdKbBuffer:
    lda CSRX
    pha
    lda CSRY
    pha
; clear input buffer
    ldx #81
clloop:
    lda #00
    sta >LIbuffs-1,X
    dex
    bne clloop

; are we on the first line?  If so, we know it is not a continue
    ldy CSRY
    dey
    cpy #$00
    beq LdKbBuffer_1
; if prior line linked  set y-1
    tyx
    LDA LINEFLGS,X
    CMP #$00
    beq LdKbBuffer_1
    dey
    lda #81         ; get 80 chars
    bra LdKbBuffer_1b
; get chars; 40 if last line char=32, 80 if not

LdKbBuffer_1:
; is this the last line on the screen?
    cpy #23
    beq LdKbBuffer_1a
; if current line linked carries to the next set size to 80
    tyx
    LDA LINEFLGS+1,X
    CMP #$00
    beq LdKbBuffer_1a
    PLA
    inc A
    pha
    lda #81         ; get 80 chars
    bra LdKbBuffer_1b
LdKbBuffer_1a:
    lda #41         ; get 40 chars
LdKbBuffer_1b:
    ldx #0
    jsl LSetXYVEC
    tay
LdKbBuffer_2:
    JSR DELAY9918
    LDA DATAP
    sta >LIbuffs-1,X
    inx
    dey
    cpy #00
    bne LdKbBuffer_2
    PLY
    stY CSRY
    PLA
    sta CSRX
    cpy #24
    bne LdKbBuffer_3
    dey
    stY CSRY
    lda #40
    jsl LSrlUpVEC
LdKbBuffer_3:
    rts

;___LAB_MONITOR_____________________________________________
;
; UTILIZE BIOS TO GO TO MONITOR
;
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_MONITOR:
	CLD				; VERIFY DECIMAL MODE IS OFF
	CLC 			;
	XCE 			; SET NATIVE MODE
    SETBANK 0
    AccumulatorIndex16
	LDA #STACK 		; get the stack address
	TCS 			; and set the stack to it
    JML $008000
