;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	HC2 DSKY Test Program                                               **
;**	Author: Dan Werner -- 5/15/2021	                                        **
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

TMPADDR           	.EQU $0336 			; TEMP AREA
;
; Hardware port addresses. SBC65816 uses the $FExx block for ECB hardware.
;


via1regb		.equ	$FE10		; Register 
via1rega		.equ	$FE11		; Register 
via1ddrb		.equ	$FE12		; Register 
via1ddra		.equ	$FE13		; Register 
via1t1cl		.equ	$FE14		; Register 
via1t1ch		.equ	$FE15		; Register 
via1t1ll		.equ	$FE16		; Register 
via1t1lh		.equ	$FE17		; Register 
via1t2cl		.equ	$FE18		; Register 
via1t2ch		.equ	$FE19		; Register 
via1sr  		.equ	$FE1A		; Register 
via1acr 		.equ	$FE1B		; Register 
via1pcr 		.equ	$FE1C		; Register 
via1ifr 		.equ	$FE1D		; Register 
via1ier 		.equ	$FE1E		; Register 
via1ora 		.equ	$FE1F		; Register 

; BIOS JUMP TABLE
;
PRINTVEC    .EQU    $FF71
OUTCH       .EQU    $FF71
outch       .EQU    $FF71
INPVEC      .EQU    $FF74
INPWVEC     .EQU    $FF77
INITDISK    .EQU    $FF7A
READDISK    .EQU    $FF7D 
WRITEDISK   .EQU    $FF80
RTC_WRITE   .EQU    $FF83
RTC_READ    .EQU    $FF86
SETLFS      .EQU    $FFA4
SETNAM      .EQU    $FFA7
LOAD        .EQU    $FFAA
SAVE        .EQU    $FFAD
IECINIT     .EQU    $FFB0

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
        .Include "..\firmware\macros.asm"

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
        AccumulatorIndex8
; INITIALIZE 8279
        JSR RESET8279
        JSR DELAY
        LDA #%00001000      ; SET 16 8-BIT CHAR DISPLAY LEFT ENTRY AND ENCODED SCAN KEYBOARD 2 KEY LOCK OUT
        LDX #$01            ; A0=1
        JSR OUT8279         ; SEND TO 8279

        LDA #%10100000      ; disable blanking
        LDX #$01            ; A0=1
        JSR OUT8279         ; SEND TO 8279

        LDA #%00110100      ; SET FOR 2MHZ CLOCK
        LDA #%00111111      ; SET FOR 2MHZ CLOCK
        LDX #$01            ; A0=1
        JSR OUT8279         ; SEND TO 8279

        LDA #%10010000      ; WRITE TO DISPLAY RAM ADDRESS 1, AUTO INCRIMENT = ON
        LDX #$01            ; A0=1  ; 
        JSR OUT8279         ; SEND TO 8279

        LDA #$00          ; WRITE TO DISPLAY RAM DIGIT 1
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279


        LDA #$00      ; WRITE TO DISPLAY RAM  DIGIT 2
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  DIGIT 3
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  DIGIT 4
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  DIGIT 5
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  DIGIT 6
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  DIGIT 7
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  DIGIT 8
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM COL 1
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279


        LDA #$00      ; WRITE TO DISPLAY RAM  COL 2
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  COL 3
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  COL 4
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  COL 4
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  COL 4
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  COL 4
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  COL 4
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279

        LDA #$00      ; WRITE TO DISPLAY RAM  COL 4
        LDX #$00            ; A0=0
        JSR OUT8279         ; SEND TO 8279



     ;   LDA #$0c      ; WRITE TO DISPLAY RAM
     ;   LDX #$00            ; A0=0
     ;   JSR OUT8279         ; SEND TO 8279


     ;   LDA #$0d      ; WRITE TO DISPLAY RAM
     ;   LDX #$00            ; A0=0
     ;   JSR OUT8279         ; SEND TO 8279

     ;   LDA #$0e      ; WRITE TO DISPLAY RAM
      ;  LDX #$00            ; A0=0
      ;  JSR OUT8279         ; SEND TO 8279

    ;    LDA #$0f      ; WRITE TO DISPLAY RAM
     ;   LDX #$00            ; A0=0
     ;   JSR OUT8279         ; SEND TO 8279

        ldx #$01
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        LDA #%01110000      ; WRITE TO DISPLAY RAM ADDRESS 1, AUTO INCRIMENT = ON
        LDX #$01            ; A0=1  ; 
        JSR OUT8279         ; SEND TO 8279

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch

        ldx #$00
        jsr IN8279
        jsr binhex
        lda #' '
        jsr outch





Exit:
	    CLC			; SET THE CPU TO NATIVE MODE
	    XCE
	    JMP	$8000
	    BRK

; a=data, x=register (bit0)
OUT8279:
    php
    pha
    AccumulatorIndex8
    ldy #$FF
    STy via1ddrb            ; OUTPUT PROPER DATA
    jsr DELAY
    STA via1regb            ; OUTPUT PROPER DATA
    txa                     ; MOVE A0 TO CORRECT OUTPUT BIT
    and #$01
    CLC
    ASL 
    ASL   
    STA TMPADDR
    lda #%00110000
    ORA TMPADDR
    sta via1rega            ; BEGIN TO SETUP FOR OUTPUT 
    lda #%00101000         ; PREP TO TOGGLE WD AND CS
    ORA TMPADDR
    TAX
    lda #%00111000         ; TOGGLE CS
    ORA TMPADDR
    sta via1rega
    stX via1rega           ; TOGGLE WD AND CS
    ldA #%00110000
    ORA TMPADDR
    TAX
    lda #%00111000
    ORA TMPADDR
    sta via1rega            ; STOP WD   
    stX via1rega            ; STOP CS
    ldA #%00110000
    stX via1rega            ; RETURN CHIP TO RESTING
    PLA
    PLP
    RTS


; a=data, x=register (bit0)
IN8279:
    php
    AccumulatorIndex8
    lda #$00
    STA via1ddrb            ; OUTPUT PROPER DATA
    txa                     ; MOVE A0 TO CORRECT OUTPUT BIT
    and #$01
    CLC
    ASL 
    ASL   
    STA TMPADDR
    lda #%00110000
    ORA TMPADDR
    sta via1rega            ; BEGIN TO SETUP FOR OUTPUT 
    lda #%00011000         ; PREP TO TOGGLE WD AND CS
    ORA TMPADDR
    TAX
    lda #%00111000         ; TOGGLE CS
    ORA TMPADDR
    sta via1rega
    stX via1rega           ; TOGGLE RD AND CS
    ldA #%00110000
    ORA TMPADDR
    TAX
    lda #%00111000
    ORA TMPADDR
    LDY via1regb
    sta via1rega            ; STOP RD   
    stX via1rega            ; STOP CS
    ldA #%00110000
    stX via1rega            ; RETURN CHIP TO RESTING
    TYA
    PLP
    RTS





RESET8279:
    php
    pha
    AccumulatorIndex8
    LDA #%00001110
    STA via1pcr            ; SET USERCA_1 TO HIGH (1/2 OF CHIP SELECT  )
    LDA #$FF                ; SET DDR TO OUTPUT FOR PORT A & B
    STA via1ddrb
    STA via1ddra
    lda #$00
    sta via1regb
    lda #%01110000
    sta via1rega
    JSR DELAY
    JSR DELAY
    JSR DELAY
    JSR DELAY
    JSR DELAY
    lda #%00110000
    sta via1rega
    pla
    PLP
    RTS

DELAY:
    pha
    PLA
    phA
    PLA
    phA
    PLA
    pha
    PLA
    phA
    PLA
    phA
    PLA
    pha
    PLA
    phA
    PLA
    phA
    PLA
    pha
    PLA
    phA
    PLA
    phA
    PLA
    pha
    PLA
    phA
    PLA
    phA
    PLA
    pha
    PLA
    phA
    PLA
    phA
    PLA
    RTS



FNPOINTER
    .db     '$'
FNPOINTER1
    .db     'TEST'

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



;_Text Strings and Data____________________________________________________________________________________________________
; 
HELLO:
	.DB $0A, $0D     ; line feed and carriage return
	.DB $0A, $0D     ; line feed and carriage return
	.DB "Begin DSKY Test Program"
	.DB $0A, $0D, 00     ; line feed and carriage return

chan	.db	0		; active audio channel
pitch	.dw	0		; current pitch
regno	.DB	0		; register number
lasta	.equ	regno+1
;_________________________________________________________________________________________________________________________

;;;;;;        INCLUDE '..\firmware\IEC.ASM'



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
         jsr outch
         RestoreContext
         txa
         jsr outch
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


