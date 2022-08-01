;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	CON9918 TMS9918 Console Outputam                                        **
;**	Author: D. Werner 3/28/2021     	                                    **
;**                                                                         **
;**                                                                         **
;*****************************************************************************
;*****************************************************************************
; 
;=============================================================================
; Constants Section
;=============================================================================
		CHIP	65816		; SET CHIP
		LONGA	OFF		; long accumulator off		
		LONGI	OFF		; long index registers off
		PW	128		; page width
		PL 	60		; page length
		INCLIST ON		; allow listing of includes

;
; BIOS JUMP TABLE
;
PRINTVEC    .EQU    $FF71
INPVEC      .EQU    $FF74
INPWVEC     .EQU    $FF77
INITDISK    .EQU    $FF7A
READDISK    .EQU    $FF7D 
WRITEDISK   .EQU    $FF80
RTC_WRITE   .EQU    $FF83
RTC_READ    .EQU    $FF86

; Configure this part: 
;
; Hardware port addresses. SBC65816 uses the $FExx block for ECB hardware.
;
DATAP:	.EQU $FE0A 	; VDP Data port 
CMDP:	.EQU $FE0B 	; VDP Command port 


TEMP        .EQU    $0005
TEMP1       .EQU    $0006
ScrollCount .EQU    $000A
CSRX		.EQU    $000B
CSRY		.EQU    $000C
CSRCHAR		.EQU    $000D

ScrollBuffer .equ 	$0400	; at least 80 bytes?


;=============================================================================
; Code Section
;=============================================================================
;
	.ORG	$4000

	.DB	"816"
;load address
;	.DB     $0B,$40,0,0
	.db	#<Start,#>Start,0,0

;execute address
;	.DB     $0B,$40,0,0
	.db	#<Start,#>Start,0,0

Start:
;   ensure CPU Context is in a known state
; LONG* are for the assembler context; the REP/SEP is for the code
;	$20=A  $10=I  $30=both
;	REP is ON; SEP is OFF
;
    CLD		; VERIFY DECIMAL MODE IS OFF
    CLC
	XCE 		; SET NATIVE MODE
	SEP #$30 	; 8 bit REGISTERS
	PHA		; Set Direct Register to 0
	PHA
	PLD 
	PHA		; set DBR to 0        
	PLB 

    JSR 	INITMESSAGE	; let's say hello

    JSR     Setup9918
    JSR     LoadFont

	
	JSR ClearScreen
	LDA #$f0
	JSR SetColor

	LDX #0
	LDY #0
	JSR SetXY
	ldy #$00

lp1:
	tya
	jsr Outch9918
	iny
	bne lp1

	jsr $FF77

	JSR ClearScreen
	LDA #$f0
	JSR SetColor

	LDX #0
	LDY #0
	JSR SetXY



	lda #'*'
	sta DATAP

	LDX #0
	LDY #2
	JSR SetXY
	JSR	OutMessage9918
	jsr $FF77

	LDX #0
	LDY #23
	JSR SetXY
	JSR	OutMessage9918
	jsr $FF77


	LDX #0
	LDY #22
	JSR SetXY
	JSR	OutMessage9918
	jsr $FF77
	

	LDX #10
	LDY #15
	JSR SetXY
	lda #'A'
	sta DATAP
	NOP
	NOP
	NOP
	lda #'B'
	NOP
	NOP
	NOP
	sta DATAP
	NOP
	NOP
	NOP
	lda #'C'
	sta DATAP


	jsr $FF77
	LDX #10
	LDY #15
	LDA #80	
	JSR CopyVideoMem

	jsr $FF77
	LDX #10
	LDY #15
	LDA #80	
	ora #$80
	JSR CopyVideoMem

	jsr $FF77
	LDA #40	
	JSR ScrollUp 
	jsr $FF77
	LDA #40	
	JSR ScrollUp 
	jsr $FF77
	LDA #40	
	JSR ScrollUp 


	LDX #10
	LDY #8
	JSR SetXY

Tloop:
	jsr Cursor
	jsr $FF77
	jsr UnCursor
	cmp #27
	beq Exit
	JSR Outch9918
	jmp Tloop
	
Exit:
	CLC			; SET THE CPU TO NATIVE MODE
	XCE
	JMP $8000
	BRK


;__INITMESSAGE___________________________________________________________________________
;   PRINT INIT MESSAGE
;________________________________________________________________________________________
INITMESSAGE:
        LDY	#$00 		; LOAD $00 INTO Y
OUTSTRLP:
        LDA	HELLO,Y         ; LOAD NEXT CHAR FROM STRING INTO ACC
        CMP 	#$00            ; IS NULL?
        BEQ 	ENDOUTSTR       ; YES, END PRINT OUT
        JSR 	PRINTVEC        ; PRINT CHAR IN ACC

        INY			; Y=Y+1 (BUMP INDEX)
        JMP 	OUTSTRLP        ; DO NEXT CHAR
ENDOUTSTR:
        RTS



;__Setup9918______________________________________________________________________________
;   Setup 9918 registers and clear VRAM
;________________________________________________________________________________________
Setup9918:
        phy
        pha
        php
		REP #$10 		; 16 bit Index registers 
		LONGI ON
        SEP #$20 		; 8 bit accum 
		LONGA OFF 


; Let's set VDP write address to $0000 
	LDA	#$00
	sta	CMDP
	lda	#$40
	sta	CMDP
	
; Now let's clear first 16Kb of VDP memory 
	LDA	#$00
	LDY	#$3FFF
CLEAR: 
	STA	DATAP
	DEY
	BEQ	ENDCLR
	NOP 	; Let's wait 8 clock cycles just in case VDP is not quick enough. 
	NOP 
	JMP	CLEAR

ENDCLR:
	LONGI	OFF
	SEP	#$10

; Now it is time to set up VDP registers: 
;---------------------------------------- 
; Register 0 to $0 
; 
; Set mode selection bit M3 (maybe also M4 & M5) to zero and 
; disable external video & horizontal interrupt 
	LDA	#$00
	STA	CMDP
	LDA	#$80
	STA	CMDP
	
;---------------------------------------- 
; Register 1 to $50 
; 
; Select 40 column mode, enable screen and disable vertical interrupt 
	LDA	#$50
	STA	CMDP
    LDA #$81
	STA	CMDP
;---------------------------------------- 
; Register 2 to $0 
; 
; Set pattern name table to $0000 
	LDA	#$00
	STA	CMDP
    LDA #$82
	STA	CMDP
	
;---------------------------------------- 
; Register 3 is ignored as 40 column mode does not need color table 
; 

;---------------------------------------- 
; Register 4 to $1 
; Set pattern generator table to $8
	LDA #$01
	STA	CMDP
    LDA #$84
	STA	CMDP

;---------------------------------------- 
; Registers 5 (Sprite attribute) & 6 (Sprite pattern) are ignored 
; as 40 column mode does not have sprites 


;---------------------------------------- 
; Register 7 to $F0 
; Set colors to white on black 
	LDA	#$F1
	STA	CMDP
    LDA #$87
	STA	CMDP

    plp
    pla
    ply
    rts

;__Outch9918______________________________________________________________________________
;   Output char to screen
;   
; Char in A 
;________________________________________________________________________________________
Outch9918:
		phx
		phy
        php
        SEP #$30 		; 8 bit accum 
		LONGA OFF 
		LONGI OFF 

		ldx CSRX
		ldy CSRY

		cmp #13
		beq Outch9918_CR
		cmp #8
		beq Outch9918_BS

		sta DATAP

		INX
		cpx #40
		bne Outch9918_Exit
		iny
		ldx #0
		cpy #24
		bne Outch9918_Exit
Outch9918_CR1:
		LDA #40	
		ldx #0
		ldy #23	
		stx CSRX
		sty CSRY
		jsr ScrollUp
Outch9918_Exit:
		stx CSRX
		sty CSRY
		plp
		ply
		plx
		rts
Outch9918_CR:
		iny
		cpy #24
		beq Outch9918_CR1
		ldx #0		
		jsr SetXY
		plp
		ply
		plx
		rts
Outch9918_BS:
		cpx #0
		beq Outch9918_BS1
		dex		
		jsr SetXY
		bra Outch9918_Exit
Outch9918_BS1:
		cpy #0
		beq Outch9918_Exit
		DEY
		ldx #39
		jsr SetXY
		bra Outch9918_Exit

;__SetColor______________________________________________________________________________
;   Setup 9918 Color
;   
; Color in A - High 4 bits background, Low 4 bits Foreground
;________________________________________________________________________________________
SetColor:
        php
        SEP #$30 		; 8 bit accum 
		LONGA OFF 
		LONGI OFF 

;---------------------------------------- 
; Register 7 to A
	STA	CMDP
    LDA #$87
	STA	CMDP
    plp
    rts


;__Cursor________________________________________________________________________________
;   Draw A cursor 
;   
;________________________________________________________________________________________
Cursor:
		phx
		phy
		pha
        php
		SEP #$30
		LONGA OFF
		LONGI OFF
		ldy CSRY
		ldx CSRX
		jsr SetXY
		LDA DATAP
		nop
		nop
		LDA DATAP
		STA CSRCHAR
		ldy CSRY
		ldx CSRX
		jsr SetXY	
		LDA #$FE
		STA DATAP
		ldy CSRY
		ldx CSRX
		jsr SetXY
	    plp
		pla
		ply
		plx
	    rts

;__Cursor________________________________________________________________________________
;   Remove the cursor 
;   
;________________________________________________________________________________________
UnCursor:
		phx
		phy
		pha
        php
		SEP #$30
		LONGA OFF
		LONGI OFF
		LDA CSRCHAR
		STA DATAP
		ldy CSRY
		ldx CSRX
		jsr SetXY
	    plp
		pla
		ply
		plx
	    rts



;__SetXY_________________________________________________________________________________
;   Setup 9918 Cursor Position
;   
; Screen Coords in X,Y
;________________________________________________________________________________________
SetXY:
		phx
		phy
		pha
        php
		SEP #$30
		LONGA OFF
		LONGI OFF
		sty CSRY
		stx CSRX
        REP #$30 		; 16 bit accum, 16 bit X&Y 
		LONGA ON
		LONGI ON 

		tya
		and #$00ff			; Lower Byte of Y only
		clc
		ASL 
		ASL 
		ASL 
		ASL 
		ASL 				; A=A*32
		sta TEMP			;TEMP=A
		tya				
		and #$00ff			; Lower Byte of Y only
		ASL 
		ASL 
		ASL					; A=A*8
		clc 
		adc TEMP			; add a to temp
		sta TEMP			; store in temp (TEMP now = Y*40)
		TXA 				; move X to A
		clc
		adc TEMP			; Add A to Temp
		sta TEMP			; Store A to TEMP (TEMP now = Screen Address)
        SEP #$30 		; 8 bit accum, 8 bit X&Y 
		LONGA OFF
		LONGI OFF
; Let's set VDP write address 
		LDA	TEMP
		sta	CMDP
		LDA TEMP+1
		ORA #$40
		AND #$4F
		sta	CMDP
	    plp
		pla
		ply
		plx
	    rts

;__ScrollUp______________________________________________________________________________
;   Scroll the screen up one line 
;   
; number of positions in line in A
 
;________________________________________________________________________________________
ScrollUp:
		phx
		phy
        php
	    SEP #$30 		; 8 bit accum, 8 bit X&Y 
		LONGA OFF
		LONGI OFF

		ldy #00
ScrollUpLoop:
		ldx #00
		phy
		iny
		pha
		jsr SetXY
		pla
		ply
		phy
		iny
		ldx #00
		pha
		ora #$80
		jsr CopyVideoMem
		pla
		ply
		iny
		cpy #23
		bne ScrollUpLoop
		tay
		iny
		phy
		LDX #0
		LDY #23
		JSR SetXY
		ply
		lda #' '
ScrollUpLoop1:
		sta DATAP
		NOP
		NOP
		NOP
		DEY
		bne ScrollUpLoop1

		SEP #$10 		; 8 bit Index registers 
		LONGI OFF
		ldx CSRX
		ldy CSRY
		jsr SetXY

		plp
		ply
		plx
		rts		





;__CopyVideoMem__________________________________________________________________________
;   Copy Screen Mem Bytes 
;   
; Screen Coords in X,Y, number of positions to copy in A
; High bit in A indicates direction 1=backward, 0=forward
;________________________________________________________________________________________
CopyVideoMem:
        php
	    SEP #$30 		; 8 bit accum, 8 bit X&Y 
		LONGA OFF
		LONGI OFF
		sta ScrollCount
		jsr SetXY
		lda DATAP
        REP #$30 		; 16 bit accum, 16 bit X&Y 
		LONGA ON
		LONGI ON 
		lda ScrollCount
		AND #$007f
		tay
		ldx #$0000
	    SEP #$20 		; 8 bit accum
		LONGA OFF		
CopyVideoMemLoop:		
		lda DATAP
		sta ScrollBuffer,x
		INX
		DEY				; potential delay needed here?
		bne CopyVideoMemLoop

	    REP #$20 		; 16 bit accum
		LONGA ON
		lda ScrollCount
		AND #$0080
		cmp #$00
		beq CopyVideoMemForward
		lda TEMP
		pha
		txa
		tay
		sta TEMP
		pla
		sec
		sbc TEMP
		sta TEMP
		bra CopyVideoMemCont
CopyVideoMemForward:				
		txa
		tay
		clc
		adc TEMP
		sta TEMP
CopyVideoMemCont:				
	    SEP #$20 		; 8 bit accum
		LONGA OFF
		LDA	TEMP
		sta	CMDP
		LDA TEMP+1
		ORA #$40
		AND #$4F
		sta	CMDP
		ldx #$0000
CopyVideoMemLoop1:			
		lda ScrollBuffer,x
		sta DATAP
		INX
		DEY
		bne CopyVideoMemLoop1
		plp
	    rts


;__ClearScreen___________________________________________________________________________
;  clear 9918 Screen
;________________________________________________________________________________________
ClearScreen:
        phy
        pha
        php
		REP #$10 		; 16 bit Index registers 
		LONGI ON
        SEP #$20 		; 8 bit accum 
		LONGA OFF 

; Let's set VDP write address to $0000 
	LDA	#$00
	sta	CMDP
	lda	#$40
	sta	CMDP
	
; Now let's clear 
	LDA	#32
	LDY	#$0400
ClearScreen1: 
	STA	DATAP
	DEY
	BEQ	ENDCLRScreen
	NOP 	; Let's wait 8 clock cycles just in case VDP is not quick enough. 
	NOP 
	JMP	ClearScreen1

ENDCLRScreen:
		SEP #$10 		; 8 bit Index registers 
		LONGI OFF
		ldx #0
		txy
		jsr SetXY

    plp
    pla
    ply
    rts


;__LoadFont______________________________________________________________________________
;   Load 9918 Font
;________________________________________________________________________________________
LoadFont:
        phy
        phx
        pha
        php
		REP #$10 		; 16 bit Index registers 
		LONGI ON
        SEP #$20 		; 8 bit accum 
		LONGA OFF 


;---------------------------------------- 
; Let's set VDP write address to $800 so, that we can write 
; character set to memory 
	LDA	#$00
	STA	CMDP
	LDA	#$48
	STA	CMDP


; Let's copy character set 
	LDY	#(FONT_TMS_END-FONT_TMS)-1	; count of chars to send

COPYCHARS: 
	LDA	FONT_TMS,Y
	STA	DATAP
	NOP
	NOP
	DEY
	BNE	COPYCHARS

    plp
    pla
    plx
    ply
    rts



;__OutMessage9918______________________________________________________________________________
;   Video chip test routines
;________________________________________________________________________________________
OutMessage9918:
        phy
        phx
        pha
        php
		REP #$10 		; 16 bit Index registers 
		LONGI ON
        SEP #$20 		; 8 bit accum 
		LONGA OFF 
	
; Let's put some characters to screen 
	LDX	#$00		        ; table offset
	LDY	#40	; count of chars to send

    
COPYORDER: 
	LDA	HELLO1,X   
	STA	DATAP
	NOP
	NOP
	INX
	DEY
	BNE	COPYORDER

    plp
    pla
    plx
    ply
    rts
	

;_Text Strings and Data__________________________________________________________________
; 
HELLO:
	.DB $0A, $0D 
	.DB $0A, $0D 
	.DB "Begin SCG Video Test Program"
	.DB $0A, $0D, 00 

HELLO1:
	.DB "Begin SCG Video Test Program 1234567890-=+"

		INCLUDE 'fonttms.ASM'	

;________________________________________________________________________________________

	.END
	
