;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	HC2 Keyboard Test Program                                               **
;**	Author: Dan Werner -- 3/24/2021	                                        **
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
; Hardware port addresses. SBC65816 uses the $FExx block for ECB hardware.
;
via2regb	.equ	$FE20		; Register 
via2rega	.equ	$FE21		; Register 
via2ddrb	.equ	$FE22		; Register 
via2ddra	.equ	$FE23		; Register 
via2t1cl	.equ	$FE24		; Register 
via2t1ch	.equ	$FE25		; Register 
via2t1ll	.equ	$FE26		; Register 
via2t1lh	.equ	$FE27		; Register 
via2t2cl	.equ	$FE28		; Register 
via2t2ch	.equ	$FE29		; Register 
via2sr  	.equ	$FE2A		; Register 
via2acr 	.equ	$FE2B		; Register 
via2pcr 	.equ	$FE2C		; Register 
via2ifr 	.equ	$FE2D		; Register 
via2ier 	.equ	$FE2E		; Register 
via2ora 	.equ	$FE2F		; Register 
DATAP:			.EQU 	$FE0A 		; 	VDP Data port 
CMDP:			.EQU 	$FE0B 		; 	VDP Command port 
    ; VIDEO/KEYBOARD PARAMETER AREA
CSRX           	.EQU $0330 			; CURRENT X POSITION
CSRY           	.EQU $0331 			; CURRENT Y POSITION
LEDS        	.EQU $0332
KeyLock     	.EQU $0333
ScannedKey  	.EQU $0334
ScrollCount 	.EQU $0335			; 
TEMP           	.EQU $0336 			; TEMP AREA
   
ConsoleDevice	.EQU $0341			; Current Console Device 
   

CSRCHAR			.EQU $0342			; Character under the Cursor
ScrollBuffer 	.equ $0350			; at least 80 bytes?

LINEFLGS        .EQU $03D0          ; 24 BYTES OF LINE POINTERS (3D0 - 3E9 , one extra for scrolling)

                 
Ibuffs		.EQU  $2000
Ibuffe		.EQU Ibuffs+80; end of input buffer

;
; BIOS JUMP TABLE
;
PRINTVEC    .EQU    $FF71
;INPVEC      .EQU    $FF74
;INPWVEC     .EQU    $FF77
;INITDISK    .EQU    $FF7A
;READDISK    .EQU    $FF7D 
;WRITEDISK   .EQU    $FF80
;RTC_WRITE   .EQU    $FF83
;RTC_READ    .EQU    $FF86
;
; Zero Page Work Vars
;
;
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
	PHA		    ; Set Direct Register to 0
	PHA
	PLD 
	PHA		; set DBR to 0        
	PLB 

    JSR INITMESSAGE	; let's say hello
    JSR INITKEYBOARD
    jsr Setup9918
         JSR LoadFont
      JSR ClearScreen
     	lda #$F0
      JSR SetColor

; allow prepopulate of screen
ploop:
    jsr CURSOR
    jsr GetKey 
    cmp #$FF
    beq ploop
    jsr UNCURSOR
    cmp #01
    beq crsrup
    cmp #02
    beq crsrdn
    cmp #$1f
    beq crsrlt
    cmp #$04
    beq crsrrt    
    PHA
    jsr Outch9918
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
		jsr ScrollUp
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

exit:
	CLC			; SET THE CPU TO NATIVE MODE
	XCE
	JMP	$8000
	BRK


LdKbBuffer:
    lda CSRX
    pha
    lda CSRY
    pha
; clear input buffer
    ldx #80
clloop:
    lda #00
    sta Ibuffs-1,X 
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
		jsr SetXY
        tay
        nop
        nop
        nop
        nop
LdKbBuffer_2:
		LDA DATAP
        sta Ibuffs-1,X
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
        jsr ScrollUp
LdKbBuffer_3:        
        rts

;
;__INITMESSAGE______________________________________________________________________________________
;
;   PRINT INIT MESSAGE
;___________________________________________________________________________________________________
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


    INCLUDE '../firmware/fonttms-2.ASM'	
    INCLUDE "../firmware/conlocal.asm"

;_Text Strings and Data____________________________________________________________________________________________________
; 
HELLO:
	.DB $0A, $0D     ; line feed and carriage return
	.DB $0A, $0D     ; line feed and carriage return
	.DB "Begin Keyboard Test Program"
	.DB $0A, $0D, 00     ; line feed and carriage return

;_________________________________________________________________________________________________________________________

        .Include "..\firmware\macros.asm"
;================================================================================
;
;binhex: CONVERT BINARY BYTE TO HEX ASCII CHARS
;
;   ————————————————————————————————————
;   Preparatory Ops: .A: byte to convert
;
;   Returned Values: .A: MSN ASCII char
;                    .X: LSN ASCII char
;                    .Y: entry value
;   ————————————————————————————————————
;
binhex 
         StoreContext
         pha                   ;save byte
         and #%00001111        ;extract LSN
         tax                   ;save it
         pla                   ;recover byte
         lsr                   ;extract...
         lsr                   ;MSN
         lsr
         lsr
         pha                   ;save MSN
         txa                   ;LSN
         jsr _0000010          ;generate ASCII 
         tax                   ;save
         pla                   ;get MSN & fall thru
         jsr _0000010          ;generate ASCII 
         StoreContext
         jsr PRINTVEC
         RestoreContext
         txa
         jsr PRINTVEC
         RestoreContext
         rts
;
;
;   convert nybble to hex ASCII equivalent...
;
_0000010 cmp #$0a
         bcc _0000020          ;in decimal range
;
         adc #$66              ;hex compensate
;         
_0000020 eor #%00110000        ;finalize nybble

         
         rts                   ;done
;

	.end


