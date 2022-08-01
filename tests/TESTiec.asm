;*****************************************************************************
;*****************************************************************************
;**                                                                         **
;**	HC2 IEC Test Program                                               **
;**	Author: Dan Werner -- 4/9/2021	                                        **
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



; BIOS JUMP TABLE
;
PRINTVEC    .EQU    $FF71
OUTCH       .EQU    $FF71
outch       .EQU    $FF71
INPVEC      .EQU    $FF74
INPWVEC     .EQU    $FF77
;INITDISK    .EQU    $FF7A
;READDISK    .EQU    $FF7D 
;WRITEDISK   .EQU    $FF80
;RTC_WRITE   .EQU    $FF83
;RTC_READ    .EQU    $FF86
SETLFS      .EQU    $FFA4
SETNAM      .EQU    $FFA7
LOAD        .EQU    $FFAA
SAVE        .EQU    $FFAD
IECINIT     .EQU    $FFB0

IECCLCH         .EQU            $FFB3        ; close input and output channels
IECOUTC         .EQU            $FFB6        ; open a channel for output
IECINPC         .EQU            $FFB9        ; open a channel for input
IECOPNLF        .EQU            $FFBC        ; open a logical file
IECCLSLF        .EQU            $FFBF        ; close a specified logical file
IECREAD         .EQU            $FF92        ; READ AN IEC BUS BYTE
IECWRITE        .EQU            $FF95        ; WRITE AN IEC BUS BYTE

IECSTW			.equ 	$0317		; Status word 
IECMSGM			.equ 	$031F			; message mode flag,
					; $C0 = both control and kernal messages,
					; $80 = control messages only,
					; $40 = kernal messages only,
					; $00 = neither control or kernal messages
IECFNPL			.equ 	$0320			; File Name Pointer Low,
IECFNPH			.equ 	$0321			; File Name Pointer High,
LOADBUFL		.equ 	$0322		; low byte IEC buffer Pointer
LOADBUFH		.equ 	$0323		; High byte IEC buffer Pointer
LOADBANK		.equ 	$0324		; BANK buffer Pointer
; ADDED
IECOPENF                .EQU    $0325           ; OPEN FILE COUNT
IECLFN                  .EQU    $0326           ; IEC LOGICAL FILE NUMBER
IECIDN	                .EQU    $0327		; input device number
IECODN	                .EQU    $0328		; output device number

PTRLFT                  .EQU    $03B0		; .. to LAB_0262 logical file table
PTRDNT                  .EQU    $03BA		; .. to LAB_026C device number table
PTRSAT                  .EQU    $03C4		; .. to LAB_0276 secondary address table
FREESPC                 .EQU    $03CE
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
        jsr IECINIT
        lda #$C0
        sta IECMSGM


;; this will generate an error
        ldx#8           ; Device Number
        ldy#1           ; secondary address
        jsr     SETLFS ;setlfs
        lda#1           ; fn length
        ldx#<FNPOINTER
        ldy#>FNPOINTER
        jsr     SETNAM ; setnam                
        lda#$50
        sta LOADBUFH
        lda#$00
        sta LOADBUFL
        lda#02
        sta LOADBANK
        jsr     LOAD

        LDA #8
        jsr     GETIECSTATUS 

        LDA #8
        jsr     GETIECDIRECTORY




   ;     ldx#8           ; Device Number
   ;     ldy#1           ; secondary address
   ;     jsr     LAB_FE50 ;setlfs
   ;     lda#4           ; fn length
   ;     ldx#<FNPOINTER1
   ;     ldy#>FNPOINTER1
   ;     jsr     LAB_FE49 ; setnam        
   ;     lda#$50
   ;     sta IECSTRTH		
   ;     lda#$0
   ;     sta IECSTRTL		
   ;     lda#$55
   ;     sta LOADBUFH
   ;     lda#$00
   ;     sta LOADBUFL
   ;     lda#02
   ;     sta LOADBANK
   ;     jsr     IECSAVERAM


    ;    ldx#8           ; Device Number
    ;    ldy#1           ; secondary address
    ;    jsr     LAB_FE50 ;setlfs
    ;    lda#1           ; fn length
    ;    ldx#<FNPOINTER
    ;    ldy#>FNPOINTER
    ;    jsr     LAB_FE49 ; setnam                
    ;    lda#$60
    ;    sta LOADBUFH
    ;    lda#$00
    ;    sta LOADBUFL
    ;    lda#02
    ;    sta LOADBANK
    ;    jsr     LOADTORAM


Exit:
	CLC			; SET THE CPU TO NATIVE MODE
	XCE
	JMP	$8000
	BRK


GETIECSTATUS:
        PHA
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH

        lda     #0      ; fn length
        ldx     #0
        ldy     #0
        jsr     SETNAM  ; setnam       
        PLA
        TAX             ; Device Number
        ldy     #15     ; secondary address
        LDA     #15     ; LFN NUMBER
        jsr     SETLFS  ;setlfs       
        JSR     IECOPNLF 
        LDX     #15
        JSR     IECINPC
GETIECSTATUS_1:
	JSR	IECREAD 		; input a byte from the serial bus
        JSR     OUTCH
	LDA	IECSTW		        ; get serial status byte
	LSR				; shift time out read ..
	LSR				; .. into carry bit
	BCC	GETIECSTATUS_1		; all ok, do another
        jsr     IECCLCH         ; close input and output channels
        lda     #15
        jsr     IECCLSLF        ; close a specified logical file
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH
	RTS

GETIECDIRECTORY:
        PHA
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH

        lda     #1      ; fn length
        ldx     #<FNPOINTER
        ldy     #>FNPOINTER
        jsr     SETNAM  ; setnam       
        PLA
        TAX             ; Device Number
        ldy     #0     ; secondary address
        LDA     #15     ; LFN NUMBER
        jsr     SETLFS  ;setlfs       
        JSR     IECOPNLF 
        LDX     #15
        JSR     IECINPC
;        Index16
;        LDY     #$6000
;        STY     $50F0
;        Index8
GETIECDIRECTORY_1:
	JSR	IECREAD 		; input a byte from the serial bus
        jsr     binhex
        jsr     space
        JSR	IECREAD 		; input a byte from the serial bus
        jsr     binhex
        jsr     space
        JSR	IECREAD 		; input a byte from the serial bus
        jsr     binhex
        jsr     space
        JSR	IECREAD 		; input a byte from the serial bus
        jsr     binhex
        jsr     space

        JSR	IECREAD 		; input SIZE LOW byte from the serial bus
        jsr     binhex
        jsr     space
        JSR	IECREAD 		; input SIZE HIGH byte from the serial bus
        jsr     binhex
        jsr     space

GETIECDIRECTORY_2:
        JSR	IECREAD 		; input ENTRY TEXT byte from the serial bus
        JSR     OUTCH
        CMP     #$00
        BEQ     GETIECDIRECTORY_3       ; END ENTRY       
 ;       Index16
 ;       LDY     $50F0
 ;       STA     0,Y 
 ;       INY 
 ;       STY     $50F0
 ;       Index8
	LDA	IECSTW		        ; get serial status byte
	LSR				; shift time out read ..
	LSR				; .. into carry bit
	BCC	GETIECDIRECTORY_2		; all ok, do another
        jsr     IECCLCH         ; close input and output channels
        lda     #15
        jsr     IECCLSLF        ; close a specified logical file
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH
	RTS
GETIECDIRECTORY_3:
        LDA     #13
        JSR     OUTCH
        LDA     #10
        JSR     OUTCH
        JMP     GETIECDIRECTORY_1


space:
        LDA     #' '
        JSR     OUTCH
        rts

FNPOINTER
    .db     '$'
FNPOINTER1
    .db     'notTEST'

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
	.DB "Begin IEC Test Program"
	.DB $0A, $0D, 00     ; line feed and carriage return

chan	.db	0		; active audio channel
pitch	.dw	0		; current pitch
regno	.DB	0		; register number
lasta	.equ	regno+1
;_________________________________________________________________________________________________________________________

;;;;       INCLUDE '..\firmware\IEC.ASM'



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

TMPPOINTER:
        .DB 0
	.end


