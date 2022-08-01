;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	AY-3-8910 Sound Test Program                                        **
;**	Author: Rich Cini -- 11/26/2020	                                    **
;**                                                                         **
;**	Translation of similar test program by Wayne Warthen for the Z80    **
;**                                                                         **
;*****************************************************************************
;*****************************************************************************
; This is a "Hello World" program for Z80 and TMS9918 / TMS9928 / TMS9929 / 
; V9938 or V9958 VDP. 
; That means that this should work on SVI, MSX, Colecovision, Memotech, 
; and many other Z80 based home computers or game consoles. 
; 
; Because we don't know what system is used, we don't know where RAM 
; is, so we can't use stack in this program. 
; 
; This version of Hello World was written by Timo "NYYRIKKI" Soilamaa 
; 17.10.2001 
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
CMDP:	.EQU $FE0B 	; VDP Command port $99 works on all MSX models 
ACRP:	.EQU $FE9C


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

	JSR	TEST9918	; go to the test routines
	
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


;__TEST9918______________________________________________________________________________
;   Actual video chip test routines
;________________________________________________________________________________________
TEST9918:
	lda	#$ff		; send wake-up to the SCG
	sta	ACRP		; write value to ACR	
	
; Let's set VDP write address to $0000 
;	XOR A 
;	OUT (CMDP),A 
;	LD A,040H 
;	OUT (CMDP),A
	LONGI	ON
	REP	#$10
	LDA	#$00
	sta	CMDP
	lda	#$40
	sta	CMDP
	
; Now let's clear first 16Kb of VDP memory 
;	LD B,0 
;	LD HL,03FFFH 
;	LD C,DATAP
	LDA	#$00
	LDY	#$3FFF
CLEAR: 
;	OUT (C),B 
;	DEC HL 
;	LD A,H 
;	OR L
;	JR NZ,CLEAR
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
;	LD A,00
;	LD C,CMDP 
;	LD E,080H 
;	OUT (C),A 
;	OUT (C),E 
	LDA	#$00
	STA	CMDP
	LDX	#$80
	STX	CMDP
	
;---------------------------------------- 
; Register 1 to $50 
; 
; Select 40 column mode, enable screen and disable vertical interrupt 
;	LD A,050H 
;	INC E 
;	OUT (C),A 
;	OUT (C),E
	LDA	#$50
	INX
	STA	CMDP
	STX	CMDP
	
;---------------------------------------- 
; Register 2 to $0 
; 
; Set pattern name table to $0000 
;	XOR A
;	INC E 
;	OUT (C),A 
;	OUT (C),E 
	LDA	#$00
	INX
	STA	CMDP
	STX	CMDP
	
;---------------------------------------- 
; Register 3 is ignored as 40 column mode does not need color table 
; 
;	INC E
	INX
		 
;---------------------------------------- 
; Register 4 to $1 
; Set pattern generator table to $8
;	INC A 
;	INC E 
;	OUT (C),A 
;	OUT (C),E 
	INC
	INX
	STA	CMDP
	STX	CMDP

;---------------------------------------- 
; Registers 5 (Sprite attribute) & 6 (Sprite pattern) are ignored 
; as 40 column mode does not have sprites 
;	INC E 
;	INC E 
	INX
	INX
	
;---------------------------------------- 
; Register 7 to $F0 
; Set colors to white on black 
;	LD A,0F1H 
;	INC E 
;	OUT (C),A 
;	OUT (C),E 
	LDA	#$F1
	INX
	STA	CMDP
	STX	CMDP
	
;---------------------------------------- 
; Let's set VDP write address to $808 so, that we can write 
; character set to memory 
; (No need to write SPACE it is clear char already) 
;	LD A,8 
;	OUT (C),A 
;	LD A,048H 
;	OUT (C),A 
	LDA	#$08
	STA	CMDP
	LDA	#$48
	STA	CMDP
	
; Let's copy character set 
;	LD HL,CHARS		;HL=address of chars
;	LD B, CHARS_END-CHARS 	;B=length of table
	LONGI	ON
	REP	#$10
	LDX	#$00		; table offset
	LDY	#CHARS_END-CHARS	; count of chars to send

COPYCHARS: 
;	LD A,(HL) 
;	OUT (DATAP),A 
;	INC HL 
;	NOP ; Let's wait 8 clock cycles just in case VDP is not quick enough. 
;	NOP 
;	DJNZ COPYCHARS 
	LDA	CHARS,X
	STA	DATAP
	NOP
	NOP
	INX
	DEY
	BNE	COPYCHARS
	
; Let's set write address to start of name table 
;	XOR A 
;	OUT (C),A 
;	LD A,040H 
;	OUT (C),A 
	LDA	#$00
	STA	CMDP
	LDA	#$40
	STA	CMDP
	
; Let's put characters to screen 
;	LD HL,ORDER 
;	LD B,ORDER_END-ORDER 
	LDX	#$00		; table offset
	LDY	#ORDER_END-ORDER	; count of chars to send
COPYORDER: 
;	LD A,(HL) 
;	OUT (DATAP),A 
;	INC HL 
;	NOP 
;	NOP 
;	DJNZ COPYORDER 
	LDA	ORDER,X
	STA	DATAP
	NOP
	NOP
	INX
	DEY
	BNE	COPYORDER
	LONGI	OFF
	SEP	#$10
; The end 
;	HALT
	RTS
	

;_Text Strings and Data__________________________________________________________________
; 
; Character set: 
; -------------- 
ORDER: 
	.DB 1,2,3,3,4,0,5,4,6,3,7 
ORDER_END: 

CHARS: 
; H 
	.DB %10001000 
	.DB %10001000 
	.DB %10001000 
	.DB %11111000 
	.DB %10001000 
	.DB %10001000 
	.DB %10001000 
	.DB %00000000 
; e 
	.DB %00000000 
	.DB %00000000 
	.DB %01110000 
	.DB %10001000 
	.DB %11111000 
	.DB %10000000 
	.DB %01110000 
	.DB %00000000 
; l 
	.DB %01100000 
	.DB %00100000 
	.DB %00100000 
	.DB %00100000 
	.DB %00100000 
	.DB %00100000 
	.DB %01110000 
	.DB %00000000 
; o 
	.DB %00000000 
	.DB %00000000 
	.DB %01110000 
	.DB %10001000 
	.DB %10001000 
	.DB %10001000 
	.DB %01110000 
	.DB %00000000 
; W 
	.DB %10001000 
	.DB %10001000 
	.DB %10001000 
	.DB %10101000 
	.DB %10101000 
	.DB %11011000 
	.DB %10001000 
	.DB %00000000 

; r 
	.DB %00000000 
	.DB %00000000 
	.DB %10110000 
	.DB %11001000 
	.DB %10000000 
	.DB %10000000 
	.DB %10000000 
	.DB %00000000 
; d 
	.DB %00001000 
	.DB %00001000 
	.DB %01101000 
	.DB %10011000 
	.DB %10001000 
	.DB %10011000 
	.DB %01101000 
	.DB %00000000 
CHARS_END: 
HELLO:
	.DB $0A, $0D 
	.DB $0A, $0D 
	.DB "Begin SCG Video Test Program"
	.DB $0A, $0D, 00 
;________________________________________________________________________________________

	.END
	
