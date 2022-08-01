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
via1regb	.equ	$FE10		; Register
via1rega	.equ	$FE11		; Register
via1ddrb	.equ	$FE12		; Register
via1ddra	.equ	$FE13		; Register
via1t1cl	.equ	$FE14		; Register
via1t1ch	.equ	$FE15		; Register
via1t1ll	.equ	$FE16		; Register
via1t1lh	.equ	$FE17		; Register
via1t2cl	.equ	$FE18		; Register
via1t2ch	.equ	$FE19		; Register
via1sr  	.equ	$FE1A		; Register
via1acr 	.equ	$FE1B		; Register
via1pcr 	.equ	$FE1C		; Register
via1ifr 	.equ	$FE1D		; Register
via1ier 	.equ	$FE1E		; Register
via1ora 	.equ	$FE1F		; Register

;
; CPU speed for delay scaling
;
cpuspd	.equ	4		; CPU speed in MHz
;
; BIOS JUMP TABLE
;
PRINTVEC    .EQU    $FF71
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
	PHA		; Set Direct Register to 0
	PHA
	PLD
	PHA		; set DBR to 0
	PLB

        JSR 	INITMESSAGE	; let's say hello
		jsr 	psginit
		jsr 	tttpsg
		jsr 	clrpsg
lp1:
	lda	#$00		; start with channel 0
	sta	chan		; init channel number

chloop:
; Test each channel
	jsr	tstchan		; test the current channel
	lda	chan		; get current channel
	INA			; bump to next
	sta	chan		; save it
	cmp	#$03		; end of channels?
	bmi	chloop		; loop if not done
Exit:
	CLC			; SET THE CPU TO NATIVE MODE
	XCE
	JMP	$8000
	BRK


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


tstchan:
	lda	#$00
	STA	pitch
	sta	pitch+1

	lda	#$07
	ldy	#$f8
	jsr 	psgwr

	lda	#$0D
	ldy	#$18
	jsr 	psgwr

; Setup mixer register

mixloop:
	lda	chan
	ldy 	pitch
	jsr 	psgwr
	lda	chan
	INA
	ldy 	pitch+1
	jsr 	psgwr

Accumulator16
	LDA 	pitch
	INA
	STA 	pitch
	CMP 	#$1000
	BEQ	MIXOUT
ACCUMULATOR8


	lda	chan
	clc
	adc	#$08
	ldy	#$0f
	jsr 	psgwr


; Delay
;	ld	b,cpuspd	; cpu speed scalar
	ldy	cpuspd
dlyloop:
;	call	dly64		; arbitrary delay
;	djnz	dlyloop		; loop based on cpu speed
	jsr	dly256
	dey
	bne	dlyloop

	bra	mixloop
MIXOUT:

	jsr	clrpsg
	rts


;
; Clear PSG registers to default
;
clrpsg:
	phx
	phy
	ldx	#00
	ldy	#00

clrpsg1:
	txa
	jsr 	psgwr	; set register X to 0
	inx
	cpx 	#17
	bne	clrpsg1
	ply
	plx
	rts

;
; Program PSG registers from list at HL
;
setpsg:
	phx
	phy
	jsr 	psginit
	ldx	#$0
setpsg_lp:
;	ld	a,(hl)		; get psg reg number
;	inc	hl		; bump index
;	cp	$FF		; check for end
;	ret	z		; return if end marker $FF
;	out	(rsel),a	; select psg register
;	ld	a,(hl)		; get register value
;	inc	hl		; bump index
;	out	(rdat),a	; set register value
;	jr	setpsg		; loop till done
	lda	regno,x
	cmp	#$FF
	beq	setpsg1
	pha	rsel
	inx
	lda	regno,x
	tay
	inx
	pla
	jsr 	psgwr
	jmp	setpsg_lp
setpsg1:
	ply
	plx
	rts



;
; test PSG registers to default
;
tttpsg:
	ldx	#00

tttpsg1:
	txa
	txy
	jsr 	psgwr	; set register X to 0
	inx
	cpx 	#17
	bne	tttpsg1

	ldx	#00
tttpsg2:
	txa
	jsr 	psgrd	; set register X to 0
	tya
	jsr binhex
	lda #' '
	jsr PRINTVEC
	inx
	cpx 	#17
	bne	tttpsg2
	rts



;
; Short delay functions.  No clock speed compensation, so they
; will run longer on slower systems.  The number indicates the
; number of call/ret invocations.  A single call/ret is
; 27 t-states on a z80, 25 t-states on a z180
;
dly256:	jsr	dly128
dly128:	jsr	dly64
dly64:	jsr	dly32
dly32:	jsr	dly16
dly16:	jsr	dly8
dly8:	jsr	dly4
dly4:	jsr	dly2
dly2:	jsr	dly1
dly1:	rts


psginit:
	PHA
	lda	#%00011100
	STA	via1ddra
	LDA 	#%00010000
	STA 	via1rega
	LDA 	#$FF
	STA	via1ddrb
	LDA 	#$00
	STA 	via1regb
	PLA
	RTS

psgrd:
	sta 	via1regb	; select register
	PHA
	LDA 	#%00011100	; latch address
	STA	via1rega

	STA	via1rega
	STA	via1rega
	STA	via1rega
	STA	via1rega

	LDA 	#%00010000	; inact
	STA	via1rega

	STA	via1rega
	STA	via1rega

	LDA 	#$00
	STA	via1ddrb
	LDA 	#%00011000	; latch data
	STA	via1rega

	STA	via1rega
	STA	via1rega
	STA	via1rega
	STA	via1rega

	ldy 	via1regb	; get data
	LDA 	#$FF
	STA	via1ddrb
	LDA 	#%00010000	; inact
	STA	via1rega
	pla
	rts


psgwr:
	sta 	via1regb	; select register
	PHA
	LDA 	#%00011100	; latch address
	STA	via1rega

	STA	via1rega
	STA	via1rega
	STA	via1rega
	STA	via1rega

	LDA 	#%00010000	; inact
	STA	via1rega

	STA	via1rega
	STA	via1rega
	STA	via1rega
	STA	via1rega

	sty 	via1regb	; store data

	sty 	via1regb	; store data
	sty 	via1regb	; store data
	sty 	via1regb	; store data
	sty 	via1regb	; store data

	LDA 	#%00010100	; latch data
	STA	via1rega

	STA	via1rega
	STA	via1rega
	STA	via1rega
	STA	via1rega

	LDA 	#%00010000	; inact
	STA	via1rega
	pla
	rts


;_Text Strings and Data____________________________________________________________________________________________________
;
HELLO:
	.DB $0A, $0D     ; line feed and carriage return
	.DB $0A, $0D     ; line feed and carriage return
	.DB "Begin SCG Test Program"
	.DB $0A, $0D, 00     ; line feed and carriage return

chan	.db	0		; active audio channel
pitch	.dw	0		; current pitch
regno	.DB	0		; register number
lasta	.equ	regno+1
;_________________________________________________________________________________________________________________________


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
	pha
	phx
	phy
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
         pha
	 phx
	 phy
         jsr PRINTVEC
         ply
	 plx
	 pla
         txa
         jsr PRINTVEC
         PLY
	 plx
	 pla
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
