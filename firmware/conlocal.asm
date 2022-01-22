;__CONLOCAL_______________________________________________________________________________________
;
;	LOCAL CONSOLE DRIVER FOR THE HOMECOMPUTER3
;
;	WRITTEN BY: DAN WERNER -- 4/4/2021
;
;_________________________________________________________________________________________________


;;;    JSR     Setup9918
;;;    JSR     LoadFont
;;;	    JSR     ClearScreen
;;;	    JSR SetColor
;;;  	JSR SetXY
;;;	    JSR CopyVideoMem
;;;	    JSR ScrollUp
;;;	    JSR Outch9918
;;;     JSR INITKEYBOARD
;;;     jsr GetKey
;;;     DecodeKeyboard
;;;     ModifierKeyCheck
;;;     ScanKeyboard
;;;     CURSOR
;;;     UNCURSOR
;;;
;;;
;;; 	VRAM Memory Map
;;;	$0000-$03FF	Sprite Patterns
;;;	$0400-$07BF	Screen Memory  ($06FF for Graphics Modes)
;;;	$0700-$07FF	Sprite Attributes
;;;	$0800-$1FFF	Patterns
;;;	$2000-$3FFF	Color Memory
;;;
;;;
;;;



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

;	Setup Width Parm
	lda 	#40
	sta 	VIDEOWIDTH

; Let's set VDP write address to $0000
	LDA	#$00
	sta	CMDP
	lda	#$40
	sta	CMDP

; Now let's clear VDP memory
	LDA	#$00
	LDY	#$3FFF
CLEAR:
	STA	DATAP
	DEY
	BEQ	ENDCLR
	JSR 	DELAY9918
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
	LDA	#$D0
	STA	CMDP
    	LDA 	#$81
	STA	CMDP
;----------------------------------------
; Register 2 to $0
;
; Set Screen RAM to $0400
	LDA	#$01
	STA	CMDP
    	LDA 	#$82
	STA	CMDP

;----------------------------------------
; Register 3 is COLOR TABLE
; Set COLOR table to $2000
	LDA	#$80
	STA	CMDP
    	LDA 	#$83
	STA	CMDP

;----------------------------------------
; Register 4 to $1
; Set pattern generator table to $0800
	LDA 	#$01
	STA	CMDP
    	LDA 	#$84
	STA	CMDP

;----------------------------------------
; Register 5 Sprite attribute
; Set ATTRIBUTE table to $0700
	LDA	#$0E
	STA	CMDP
    	LDA 	#$85
	STA	CMDP

;----------------------------------------
; Register 6 Sprite pattern
; Set ATTRIBUTE table to $0000
	LDA	#$00
	STA	CMDP
    	LDA 	#$86
	STA	CMDP



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


;__Cursor________________________________________________________________________________
;   Draw A cursor
;
;________________________________________________________________________________________
CURSOR:
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
	JSR DELAY9918
	LDA DATAP
	JSR DELAY9918
	LDA DATAP
	STA CSRCHAR
	ldy CSRY
	ldx CSRX
	jsr SetXY
	JSR DELAY9918
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

;__UnCursor______________________________________________________________________________
;   Remove the cursor
;
;________________________________________________________________________________________
UNCURSOR:
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

	cmp #10
	beq Outch9918_Exit
	cmp #13
	beq Outch9918_CR
	cmp #8
	beq Outch9918_BS

	sta DATAP

	INX
	cpx VIDEOWIDTH
	bne Outch9918_Exit
	iny
	tyx			; set next line as a continuation line
	LDA #$FF		;
	STA LINEFLGS,X		;
	ldx #0
	cpy #24
	bne Outch9918_Exit
Outch9918_CR1:
	LDA VIDEOWIDTH
	ldx #0
	ldy #23
	stx CSRX
	sty CSRY
	jsr ScrollUp
	LDA #00			;
	STA LINEFLGS+24		;

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
	ldx VIDEOWIDTH
	DEX
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
	STA CMDP
    	LDA #$87
	STA CMDP
    	plp
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
	LDA VIDEOWIDTH
	AND #$00FF
	CMP #32
	BEQ SetXY_32
	tya
	and #$00ff			; Lower Byte of Y only
	ASL
	ASL
	ASL					; A=A*8
	clc
	adc TEMP			; add a to temp
	sta TEMP			; store in temp (TEMP now = Y*40)
	LDA VIDEOWIDTH
	AND #$00FF
	CMP #40
	BEQ SetXY_32
	; double for 80 columns
	LDA TEMP			;
	CLC
	ASL
	sta TEMP			; store in temp (TEMP now = Y*80)
SetXY_32:
	TXA 				; move X to A
	clc
	adc TEMP			; Add A to Temp
	sta TEMP
	LDA #$0400			; add in base of screen memory
	CLC
	adc TEMP
	sta TEMP			; Store A to TEMP (TEMP now = Screen Address)
        SEP #$30 			; 8 bit accum, 8 bit X&Y
	LONGA OFF
	LONGI OFF
; Let's set VDP write address
	LDA TEMP
	sta CMDP
	LDA TEMP+1
	ORA #$40
	AND #$4F
	sta CMDP
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
	pha
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
	PHY
	LDX #0
	LDY #23
	JSR SetXY
	PLY
	lda #' '
ScrollUpLoop1:
	sta DATAP
	JSR DELAY9918
	DEY
	bne ScrollUpLoop1

; SCROLL UP THE LINE FLAGS
	LDX  	#0
	LDY 	#25
SCRLFLGS:
	LDA 	LINEFLGS+1,X
	STA	LINEFLGS,X
	DEY
	INX
	CPY 	#00
	BNE 	SCRLFLGS

	SEP #$10 		; 8 bit Index registers
	LONGI OFF
	ldx CSRX
	ldy CSRY
	jsr SetXY

	plp
	ply
	plx
	pla
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
	JSR DELAY9918
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
	JSR DELAY9918
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
	LDA TEMP
	sta CMDP
	LDA TEMP+1
	ORA #$40
	AND #$4F
	sta CMDP
	ldx #$0000
CopyVideoMemLoop1:
	JSR DELAY9918
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

; Let's set VDP write address to $0400
	LDA	#$00
	sta	CMDP
	lda	#$44
	sta	CMDP

; Now let's clear
	LDA	#32
	LDY	#$0400
ClearScreen1:
	JSR 	DELAY9918
	STA	DATAP
	DEY
	BEQ	ENDCLRScreen
	JMP	ClearScreen1

ENDCLRScreen:
	LDX  	#LINEFLGS
	LDY 	#25
	LDA 	#00
CLRFLGS:
	STA	0,X
	DEY
	INX
	CPY 	#00
	BNE 	CLRFLGS
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
	JSR 	DELAY9918
	DEY
	BNE	COPYCHARS

    	plp
    	pla
    	plx
    	ply
    	rts

DELAY9918:
        PHA
        PHA             ; MIGHT BE POSSIBLE TO REDUCE DELAY
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PLA
        RTS

	INCLUDE 'fonttms-3.ASM'


;___________________________________________________________________________________________________
; Initialize Keyboard
;___________________________________________________________________________________________________

INITKEYBOARD:
    PHP
    SEP #$30 				; NEED 8 bit ACCUMULATOR & INDEX
    LONGA Off              	;
    LONGI Off              	;
    pha
    LDA #$F0
    STA LEDS
    lda #00
    sta KeyLock
    pla
    plp
    RTS

;___________________________________________________________________________________________________
; Get a key from Keyboard
;
; Returns Key in A
;___________________________________________________________________________________________________

GetKey:
    PHP
    SEP #$30 				; NEED 8 bit ACCUMULATOR & INDEX
    LONGA Off              	;
    LONGI Off              	;
    phx
    phy

GetKey_Loop:
    jsr kbdDelay
    jsr ScanKeyboard
    cmp #$FF
    beq GetKey_Loop
    sta TEMP+1
    jsr ModifierKeyCheck
    sta ScannedKey
GetKey_loop1:
    jsr kbdDelay
    jsr ScanKeyboard
    cmp TEMP+1
    beq GetKey_loop1

    LDA ScannedKey
    jsr DecodeKeyboard

    cmp #$FF
    beq GetKey_Loop
    cmp #$00
    beq GetKey_Loop
    ply
    plx
    plp
    rts


;___________________________________________________________________________________________________
; Scan Keyboard
;
; Returns Scancode in A
;
;___________________________________________________________________________________________________
ScanKeyboard:
    PHP
    SEP #$30 				; NEED 8 bit ACCUMULATOR & INDEX
    LONGA Off              	;
    LONGI Off              	;
	phx
	phy
	lda	#$ff		; SET OUTPUT DIRECTION
	sta	via2ddrb	; write value
	lda	#$00		; SET INPUT DIRECTION
	sta	via2ddra	; write value

	ldy	#$00		; SET ROW AND LEDS
outerScanLoop:
    cpy #09
    beq KeyNotFound
    sty TEMP
    lda LEDS
    ora TEMP
    sta	via2regb	; write value
innerScanLoop:
    lda	via2rega	; read value
    ldx #$00
    cmp #$FF        ;NO KEY PRESSED
    BEQ exitInnerScanLoop
    cmp #$FE        ; COL 1 key Pressed
    beq keyFound
    inx
    cmp #$FD        ; COL 2 key Pressed
    beq keyFound
    inx
    cmp #$FB        ; COL 3 key Pressed
    beq keyFound
    inx
    cmp #$F7        ; COL 4 key Pressed
    beq keyFound
    inx
    cmp #$EF        ; COL 5 key Pressed
    beq keyFound
    inx
    cmp #$DF        ; COL 6 key Pressed
    beq keyFound
    inx
    cmp #$BF        ; COL 7 key Pressed
    beq keyFound
    inx
    cmp #$7F        ; COL 8 key Pressed
    beq keyFound
exitInnerScanLoop:
    iny
    jmp outerScanLoop
KeyNotFound:
    lda #$FF
    ply
    plx
    plp
    rts
keyFound:
    stx TEMP
    tya
    CLC
    ASL
    ASL
    ASL
    CLC
    ADC TEMP
    cmp #48
    beq KeyNotFound
    cmp #49
    beq KeyNotFound
    cmp #50
    beq KeyNotFound
    ply
    plx
    plp
    rts

;___________________________________________________________________________________________________
; Check for Modifier keys (Shift, Control, Graph/Alt)
; Requires Scancode in A
; Returns modified Scancode in A
;
;___________________________________________________________________________________________________
ModifierKeyCheck:
    PHP
    SEP #$30 				; NEED 8 bit ACCUMULATOR & INDEX
    LONGA Off              	;
    LONGI Off              	;
    pha
; Check for Modifiers
    lda LEDS
    ora #06
    sta	via2regb	; write value
    lda	via2rega	; read value
    cmp #$FF        	;NO KEY PRESSED
    BEQ exit_Scan
    cmp #$FE        	; COL 1 key Pressed
    bne check_Ctrl
    pla
    clc
    adc #72
    plp
    rts
check_Ctrl:
    cmp #$FD        ; COL 2 key Pressed
    bne check_Graph
    pla
    cmp #48
    bcs skip_Ctrl
    clc
    adc #144
skip_Ctrl:
    plp
    rts
check_Graph:
    cmp #$FB        ; COL 3 key Pressed
    bne exit_Scan
check_Graph1:
    pla
    cmp #48
    bcs skip_Ctrl
    clc
    adc #192
    plp
    rts
exit_Scan:
    pla
    plp
    rts


;___________________________________________________________________________________________________
; Decode Keyboard
;
; Scancode in A
; Returns Decoded Ascii in A
;
;___________________________________________________________________________________________________
DecodeKeyboard:
    PHP
    SEP #$30 				; NEED 8 bit ACCUMULATOR & INDEX
    LONGA Off              	;
    LONGI Off              	;
    phx
    cmp #51     ; is CapsLock
    beq is_CapsLock
    cmp #52     ; is graphLock?
    beq is_GraphLock
    cmp #48
    bcs skip_Lock
    cmp #22
    bcc skip_Lock
    CLC
    ADC KeyLock
skip_Lock:
    tax
    LDA DecodeTable,X
    plx
    plp
    RTS
is_CapsLock:
; check for toggle and set LEDs
    lda LEDS
    AND #$10
    cmp #$00
    beq Cap_off
    lda LEDS
    and #$C0
    ora #$20
    sta LEDS
    sta	via2regb	; write value
    lda #72
    sta KeyLock
    lda #$FF
    plx
    plp
    rts
Cap_off:
    lda LEDS
    and #$C0
    ora #$30
    sta LEDS
    sta	via2regb	; write value
    lda #0
    sta KeyLock
    lda #$FF
    plx
    plp
    rts
is_GraphLock:
; check for toggle and set LEDs
    lda LEDS
    AND #$20
    cmp #$00
    beq Cap_off
    lda LEDS
    and #$C0
    ora #$10
    sta LEDS
    sta	via2regb	; write value
    lda #192
    sta KeyLock
    lda #$FF
    plx
    plp
    rts

DecodeTable:
    .DB     '0','1','2','3','4','5','6','7' ; 0
    .DB     '8','9','-','=','\','[',']',';' ; 8
    .DB     39,'~',',','.','/',00,'a','b'   ; 16
    .DB     'c','d','e','f','g','h','i','j' ; 24
    .DB     'k','l','m','n','o','p','q','r' ; 32
    .DB     's','t','u','v','w','x','y','z' ; 40
    .DB     $FF,$FF,$FF,$FF,$FF,11,12,14       ; 48
    .DB     15,16,27,09,03,08,17,13         ; 56
    .DB     32,28,29,30,31,01,02,04         ; 64

    .DB     ')','!','@','#','$','%','^','&' ; 72  ; Shift
    .DB     '*','(','_','+','|','{','}',':' ; 80
    .DB     34,'~','<','>','?',00,'A','B'   ; 88
    .DB     'C','D','E','F','G','H','I','J' ; 96
    .DB     'K','L','M','N','O','P','Q','R' ; 104
    .DB     'S','T','U','V','W','X','Y','Z' ; 112
    .DB     $FF,$FF,$FF,$FF,$FF,18,19,20         ; 120
    .DB     21,22,27,09,03,08,23,13         ; 128
    .DB     32,28,29,30,31,01,02,04         ; 136

    .DB     '0','1','2','3','4','5','6','7' ; 144 ; Control
    .DB     '8','9',234,225,224,248,249,000 ; 152
    .DB     250,251,254,176,177,00,01,02    ; 160
    .DB     03,04,05,06,07,08,09,10         ; 168
    .DB     11,12,13,14,15,16,17,18         ; 176
    .DB     19,20,21,22,23,24,25,26         ; 184

    .DB     000,178,179,180,181,182,183,184 ; 192 ; Graph
    .DB     185,186,187,188,189,190,191,192 ; 200
    .DB     193,194,195,196,197,198,199,200 ; 208
    .DB     201,202,203,204,205,206,207,208 ; 216
    .DB     209,210,211,212,213,214,215,216 ; 224
    .DB     217,218,219,220,221,222,223,167 ; 232




;***********************************************************************************;
;
;  delay
kbdDelay:
	php
    	SEP #$30 				; NEED 8 bit ACCUMULATOR & INDEX
    	LONGA Off              	;
    	LONGI Off              	;
	pha
	phx
	ldx 	#KBD_DELAY
	LDA	#$40			; set for 1024 cycles (MHZ)
	STA	via2t2ch		; set VIA 2 T2C_h
kbdDelay_a:
	LDA	via2ifr		; get VIA 2 IFR
	AND	#$20			; mask T2 interrupt
	BEQ	kbdDelay_a		; loop until T2 interrupt
	dex
	bne 	kbdDelay_a
	plx
	pla
	plp
	RTS
;________________________________________________________________________________________
