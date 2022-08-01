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



;___SOUND__________________________________________________
;
; PLAY SOUND
;
;  TAKES TWO PARAMETERS CHANNEL,FREQUENCY
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SOUND:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (CHANNEL)
        phx
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	JSR	LAB_F2FX		; save integer part of FAC1 in temporary integer

	PLA				; LIMIT THE CHANNELS TO <3
	AND 	#$03
	CLC
	ASL				; = *2
	PHA
	LDY	<Itempl
	JSR 	psgwr			; SET LOW BYTE
	PLA
	INC 	A
	LDY	<Itemph
	JSR 	psgwr			; SET HIGH BYTE
	RTS

;___VOLUME__________________________________________________
;
; SET VOLUME
;
;  TAKES TWO PARAMETERS CHANNEL,VOLUME
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_VOLUME:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (CHANNEL)
        phx
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
	JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (VOLUME)
	TXY
	PLA				; LIMIT THE CHANNELS TO <3
	AND 	#$03

	clc
	ADC 	#08
	JSR 	psgwr
	RTS


;___VOICE__________________________________________________
;
; SET VOICE
;
;  TAKES TWO PARAMETERS VOICE, ENVELOPE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_VOICE:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (CHANNEL)
        phx
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
	JSR	LAB_EVNM		; evaluate expression and check is numeric,
					; else do type mismatch
	JSR	LAB_F2FX		; save integer part of FAC1 in temporary integer
	PLY
	LDA 	#13
	JSR 	psgwr

	LDA 	#11
	LDY	<Itempl
	JSR 	psgwr			; SET LOW BYTE
	LDA 	#12
	LDY	<Itemph			; SET HIGH BYTE
	JSR 	psgwr

	RTS





;___NOISE__________________________________________________
;
; SELECT NOISE CHANNEL
;
;  TAKES TWO PARAMETERS CHANNEL,FREQUENCY
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_NOISE:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (CHANNEL)
        phx
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
	JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (FREQ)
	PLA				; LIMIT THE CHANNELS TO <3
	PHX
	tAX

	AND 	#%00011111
	TAY
	LDA 	#$06
	JSR 	psgwr			; SET NOISE FREQ

	LDA 	#$07
	JSR 	psgrd			; GET CONFIG
	PLA
	PHY
	AND 	#$03
	TAX				; A=CONFIG, X=CHANNEL
	PLA
	CPX 	#$00
	BNE 	NOISE_1
	AND 	#%00110111
	ORA 	#%00000001
	BRA 	NOISE_3
NOISE_1:
	CPX 	#$01
	BNE 	NOISE_2
	AND 	#%00101111
	ORA 	#%00000010
	BRA 	NOISE_3
NOISE_2:
	AND 	#%00011111
	ORA 	#%00000100
NOISE_3:
	TAY
	LDA 	#$07
	JSR 	psgwr			; SET LOW BYTE
	RTS

;___TONE___________________________________________________
;
; SELECT TONE CHANNEL
;
;  TAKES ONE PARAMETER CHANNEL
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_TONE:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (CHANNEL)
	PHX

	LDA 	#$07
	JSR 	psgrd			; GET CONFIG
	PLA
	PHY
	AND 	#$03
	TAX				; A=CONFIG, X=CHANNEL
	PLA
	CPX 	#$00
	BNE 	TONE_1
	AND 	#%00111110
	ORA 	#%00001000
	BRA 	TONE_3
TONE_1:
	CPX 	#$01
	BNE 	TONE_2
	AND 	#%00111101
	ORA 	#%00010000
	BRA 	TONE_3
TONE_2:
	AND 	#%00111011
	ORA 	#%00100000
TONE_3:
	TAY
	LDA 	#$07
	JSR 	psgwr			; SET LOW BYTE
	RTS


;___CONTROLLER_______________________________________________
;
; GET JOYTICK STATUS
;
;  TAKES ONE PARAMETERS JOYSTICK#, RETURNS STATUS
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_CON:
	JSR	LAB_F2FX	; GET THE PARAMETER, RETURN IN X (controller#)
	LDA	<Itempl
	and 	#$01
	clc
	adc 	#14
	jsr 	psgrd	   	; return value in y
	JMP	LAB_1FD0	; convert Y to byte in FAC1 and return




;___utility functions____________________________________________
psginit:
	LDA	#%10011100
	STA	>via1ddra
	LDA 	#%00010000
	STA 	>via1rega
	LDA 	#$FF
	STA	>via1ddrb
	LDA 	#$00
	STA 	>via1regb
	RTS
	JSR 	clrpsg

	LDA 	#7
	LDY 	#$3F
	JSR 	psgwr
	RTS

psgrd:
	STA 	>via1regb	; select register
	LDA 	#%00011100	; latch address
	STA	>via1rega

	STA	>via1rega
	STA	>via1rega

	LDA 	#%00010000	; inact
	STA	>via1rega

	STA	>via1rega

	LDA 	#$00
	STA	>via1ddrb
	LDA 	#%00011000	; latch data
	STA	>via1rega

	STA	>via1rega
	STA	>via1rega

	LDA 	>via1regb	; get data
	TAY
	LDA 	#$FF
	STA	>via1ddrb
	LDA 	#%00010000	; inact
	STA	>via1rega
	RTS


psgwr:
	STA 	>via1regb	; select register
	LDA 	#%00011100	; latch address
	STA	>via1rega

	STA	>via1rega
	STA	>via1rega

	LDA 	#%00010000	; inact
	STA	>via1rega

	STA	>via1rega
	STA	>via1rega
	TYA
	STA 	>via1regb	; store data

	STA 	>via1regb	; store data
	STA 	>via1regb	; store data

	LDA 	#%00010100	; latch data
	STA	>via1rega

	STA	>via1rega
	STA	>via1rega

	LDA 	#%00010000	; inact
	STA	>via1rega
	RTS

;
; Clear PSG registers to default
;
clrpsg:
	StoreContext
	AccumulatorIndex8
	ldx	#00
	ldy	#00
clrpsg1:
	txa
	jsr 	psgwr	; set register X to 0
	inx
	cpx 	#17
	bne	clrpsg1
	RestoreContext
	rts
