
;__ROMBIOS816_______________________________________________________________________________________
;
;	ROM BIOS FOR THE RBC 65c816 SBC - NATIVE MODE
;
;	WRITTEN BY: DAN WERNER -- 10/7/2017
;   Modified 3/21/2021 for 65816HC
;
;__________________________________________________________________________________________________
;
; DATA CONSTANTS
;__________________________________________________________________________________________________

		CHIP	65816		; SET CHIP
		LONGA	OFF		; ASSUME EMULATION MODE
		LONGI	OFF		;
		PW	128
		PL 	60
		INCLIST ON

;__________________________________________________________________________________________________
; $8000-$8007 UART 16C550
;__________________________________________________________________________________________________
UART0:			.EQU	$FE00		;   DATA IN/OUT
UART1:			.EQU	$FE01		;   CHECK RX
UART2:			.EQU	$FE02		;   INTERRUPTS
UART3:			.EQU	$FE03		;   LINE CONTROL
UART4:			.EQU	$FE04		;   MODEM CONTROL
UART5:			.EQU	$FE05		;   LINE STATUS
UART6:			.EQU	$FE06		;   MODEM STATUS

RTC:			.EQU	$FE08		;   RTC REG.

DATAP:			.EQU 	$FE0A 		; 	VDP Data port
CMDP:			.EQU 	$FE0B 		; 	VDP Command port

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



via2regb		.equ	$FE20		; Register
via2rega		.equ	$FE21		; Register
via2ddrb		.equ	$FE22		; Register
via2ddra		.equ	$FE23		; Register
via2t1cl		.equ	$FE24		; Register
via2t1ch		.equ	$FE25		; Register
via2t1ll		.equ	$FE26		; Register
via2t1lh		.equ	$FE27		; Register
via2t2cl		.equ	$FE28		; Register
via2t2ch		.equ	$FE29		; Register
via2sr  		.equ	$FE2A		; Register
via2acr 		.equ	$FE2B		; Register
via2pcr 		.equ	$FE2C		; Register
via2ifr 		.equ	$FE2D		; Register
via2ier 		.equ	$FE2E		; Register
via2ora 		.equ	$FE2F		; Register


STACK:			.EQU	$7FFF		;   POINTER TO TOP OF STACK

;
KEYBUFF			.EQU	$0200 		; 256 BYTE KEYBOARD BUFFER
; NATIVE VECTORS
ICOPVECTOR 		.EQU	$0300       ;COP handler indirect vector...
IBRKVECTOR 		.EQU	$0302       ;BRK handler indirect vector...
IABTVECTOR 		.EQU	$0304       ;ABT handler indirect vector...
INMIVECTOR 		.EQU	$0306       ;NMI handler indirect vector...
IIRQVECTOR 		.EQU	$0308       ;IRQ handler indirect vector...
; 6502 Emulation Vectors
IECOPVECTOR 	.EQU	$030A       ;ECOP handler indirect vector...
IEABTVECTOR 	.EQU	$030C       ;EABT handler indirect vector...
IENMIVECTOR 	.EQU	$030E       ;ENMI handler indirect vector...
IEINTVECTOR 	.EQU	$0310       ;EINT handler indirect vector...

;;; These are as yet unused
;------------------------------------------------------------------------------
IECDCF			.equ	$0312		; Serial output: deferred char flag
IECDC			.equ    $0313   	; Serial deferred character
IECBCI			.equ 	$0314		; Serial bit count/EOI flag
IECBTC			.equ 	$0315       ; Countdown, bit count
IECCYC			.equ    $0316		; Cycle count
IECSTW			.equ 	$0317		; Status word
IECFNLN			.equ 	$0318		; File Name Length
IECSECAD		.equ 	$0319		; IEC Secondary Address
IECBUFFL		.equ 	$031A		; low byte IEC buffer Pointer
IECBUFFH		.equ 	$031B		; High byte IEC buffer Pointer
IECDEVN			.equ 	$031C		; IEC Device Number
IECSTRTL		.equ 	$031D		; low byte IEC Start Address Pointer
IECSTRTH		.equ 	$031E		; High byte IEC Start Address Pointer
IECMSGM			.equ 	$031F		; message mode flag,
					; $C0 = both control and kernal messages,
					; $80 = control messages only,
					; $40 = kernal messages only,
					; $00 = neither control or kernal messages
IECFNPL			.equ 	$0320		; File Name Pointer Low,
IECFNPH			.equ 	$0321		; File Name Pointer High,
LOADBUFL		.equ 	$0322		; low byte IEC buffer Pointer
LOADBUFH		.equ 	$0323		; High byte IEC buffer Pointer
LOADBANK		.equ 	$0324		; BANK buffer Pointer
IECOPENF        .EQU    $0325       ; OPEN FILE COUNT
IECLFN          .EQU    $0326       ; IEC LOGICAL FILE NUMBER
IECIDN	        .EQU    $0327		; input device number
IECODN	        .EQU    $0328		; output device number
;------------------------------------------------------------------------------

; VIDEO/KEYBOARD PARAMETER AREA
CSRX           	.EQU $0330 			; CURRENT X POSITION
CSRY           	.EQU $0331 			; CURRENT Y POSITION
LEDS        	.EQU $0332
KeyLock     	.EQU $0333
ScannedKey  	.EQU $0334
ScrollCount 	.EQU $0335			;
TEMP           	.EQU $0336 			; TEMP AREA

ConsoleDevice	.EQU $0341			; Current Console Device
									; $00 Serial, $01 On-Board 9918/KB
CSRCHAR		.EQU $0342			; Character under the Cursor
VIDEOWIDTH	.EQU $0343			; SCREEN WIDTH -- 32 or 40 (80 in the future)
ScrollBuffer 	.equ $0350			; at least 80 bytes?
PTRLFT          .EQU $03B0			; .. to $03B9 logical file table
PTRDNT          .EQU $03BA			; .. to $03C3 device number table
PTRSAT          .EQU $03C4			; .. to $03CD secondary address table
LINEFLGS        .EQU $03D0          		; 24 BYTES OF LINE POINTERS (3D0 - 3E9 , one extra for scrolling)


TRUE		.EQU    1
FALSE		.EQU 	0

KBD_DELAY 	.EQU 	64			; keyboard delay in MS.   Set higher if keys bounce, set lower if keyboard feels slow

	INCLUDE 'MACROS.ASM'

; CHOOSE ONE CONSOLE IO DEVICE
BIOS	SECTION 	OFFSET $E000

;__COLD_START___________________________________________________
;
; PERFORM SYSTEM COLD INIT
;
;_______________________________________________________________
COLD_START:
       		CLD			; VERIFY DECIMAL MODE IS OFF

		CLC 			;
		XCE 			; SET NATIVE MODE
		AccumulatorIndex16
		LDA #STACK 		; get the stack address
		TCS 			; and set the stack to it

        	JSR CONSOLE_INIT	; Init UART
		AccumulatorIndex8
		JSR INITIEC		;	init IEC port
					; Announce that system is alive

		JSR BATEST		; Perform Basic Assurance Test

		Accumulator16
        	LDA #INTRETURN 		;
        	STA ICOPVECTOR
		STA IBRKVECTOR
		STA IABTVECTOR
		STA INMIVECTOR
		STA IIRQVECTOR
		STA IECOPVECTOR
		STA IEABTVECTOR
		STA IENMIVECTOR
		STA IEINTVECTOR

		AccumulatorIndex8
        	JML  $FF1000		; START BASIC


RCOPVECTOR:	JMP (ICOPVECTOR)
RBRKVECTOR:	JMP (IBRKVECTOR)
RABTVECTOR:	JMP (IABTVECTOR)
RNMIVECTOR:	JMP (INMIVECTOR)
RIRQVECTOR:	JMP (IIRQVECTOR)
RECOPVECTOR:	JMP (IECOPVECTOR)
REABTVECTOR:	JMP (IEABTVECTOR)
RENMIVECTOR:	JMP (IENMIVECTOR)
REINTVECTOR: 	JMP (IEINTVECTOR)


;__INTRETURN____________________________________________________
;
; Handle Interrupts
;
;_______________________________________________________________
;
INTRETURN:
		RTI 			;

;__BATEST_______________________________________________________
;
; Perform Basic Hardware Assurance Test
;
;_______________________________________________________________
;
BATEST:
		RTS



;__CONSOLE_INIT_________________________________________________
;
; Initialize Attached Console Devices
;
;_______________________________________________________________
;
CONSOLE_INIT:
		PHP
		AccumulatorIndex8

    		jsr SERIAL_CONSOLE_INIT
    		JSR Setup9918
    		JSR LoadFont
    		JSR ClearScreen
		lda #$F0
    		JSR SetColor
		lda #$01
		sta ConsoleDevice
    		JSR INITKEYBOARD

    		plp
		rts


;__OUTCH_______________________________________________________
;
; OUTPUT CHAR IN LOW BYTE OF ACC TO CONSOLE
;
; Current Console Device stored in ConsoleDevice
;
; 0=Serial
; 1=On Board 9918/KB
;______________________________________________________________
OUTCH:
		phx
		phy
		PHP
		AccumulatorIndex8
		tax
		lda ConsoleDevice
		cmp #$01
		bne OUTCH2
		txa
    		JSR Outch9918
		plp
		ply
		plx
		rts

; Default (serial)
OUTCH2:
	txa
	jsr SERIAL_OUTCH
	plp
	ply
	plx
	rts


;__INCHW_______________________________________________________
;
; INPUT CHAR FROM CONSOLE TO ACC  (WAIT FOR CHAR)
;
;______________________________________________________________
INCHW:
	phx
	phy
	PHP
	AccumulatorIndex8

	lda ConsoleDevice
	cmp #$01
	bne INCHW2
    jsr GetKey
	plp
	ply
	plx
	rts

; Default (serial)
INCHW2:
	jsr SERIAL_INCHW
	plp
	ply
	plx
	rts


;__INCH________________________________________________________
;
; INPUT CHAR FROM CONSOLE TO ACC
;
;______________________________________________________________
INCH:
	phx
	phy
	PHP
 	AccumulatorIndex8

	lda ConsoleDevice
	cmp #$01
	bne INCH2

	jsr ScanKeyboard
    cmp #$FF
    beq INCH2S
    jsr GetKey
	bra INCH2C

; Default (serial)
INCH2:
	jsr SERIAL_INCH
	BCS INCH2S


INCH2C:
	plp
	ply
	plx
	CLC
	rts
INCH2S:
	plp
	ply
	plx
	SEC
	rts



;__Device_Driver_Code___________________________________________
;
		INCLUDE 'CONSERIAL.ASM'
		INCLUDE 'CONLOCAL.ASM'
		INCLUDE 'IEC.ASM'



;______________________________________________________________
        INCLUDE 'RTC.ASM'
;______________________________________________________________


	.BYTE 00,00,00


; BIOS JUMP TABLE (NATIVE)
		.ORG 	$FD00
LPRINTVEC	JSR	OUTCH
			RTL
LINPVEC		JSR	INCH
			RTL
LINPWVEC	JSR	INCHW
			RTL
LSetXYVEC	JSR SetXY
			RTL
LCPYVVEC	JSR CopyVideoMem
			RTL
LSrlUpVEC 	JSR ScrollUp
			RTL
LSetColorVEC:
			JSR SetColor
			RTL
LCURSORVEC	JSR CURSOR
			RTL
LUNCURSORVEC:
			JSR UNCURSOR
			RTL
LWRITERTC	JSR RTC_WRITE
			RTL
LREADRTC	JSR RTC_READ
			RTL
LIECIN		JSR LAB_EF19 ;. Read byte from serial bus. (Must call TALK and TALKSA beforehands.)
			RTL
LIECOUT		JSR LAB_EEE4 ;. Write byte to serial bus. (Must call LISTEN and LSTNSA beforehands.)
			RTL
LUNTALK		JSR LAB_EEF6 ;. Send UNTALK command to serial bus.
			RTL
LUNLSTN		JSR LAB_EF04 ;. Send UNLISTEN command to serial bus.
			RTL
LLISTEN		JSR LAB_EE17 ;. Send LISTEN command to serial bus.
			RTL
LTALK		JSR LAB_EE14 ;. Send TALK command to serial bus.
			RTL
LSETLFS		JSR LAB_FE50 ;. Set file parameters.
			RTL
LSETNAM		JSR LAB_FE49 ;. Set file name parameters.
			RTL
LLOAD		JSR LOADTORAM ;. Load or verify file. (Must call SETLFS and SETNAM beforehands.)
			RTL
LSAVE		JSR IECSAVERAM ;. Save file. (Must call SETLFS and SETNAM beforehands.)
			RTL
LIECINIT	JSR INITIEC	   ; INIT IEC
			RTL
LIECCLCH    JSR LAB_F3F3        ; close input and output channels
			RTL
LIECOUTC    JSR LAB_F309        ; open a channel for output
			RTL
LIECINPC    JSR LAB_F2C7        ; open a channel for input
			RTL
LIECOPNLF   JSR LAB_F40A        ; open a logical file
			RTL
LIECCLSLF   JSR LAB_F34A        ; close a specified logical file
			RTL
LClearScrVec JSR ClearScreen     ; clear the 9918 Screen
			RTL
LLOADFONTVec JSR LoadFont     ; LOAD THE FONT
			RTL

; BIOS JUMP TABLE (Emulation)
		.ORG 	$FF71
PRINTVEC	JMP	OUTCH
INPVEC		JMP	INCH
INPWVEC		JMP	INCHW
SetXYVEC	JMP SetXY
CPYVVEC		JMP CopyVideoMem
SrlUpVEC 	JMP ScrollUp
SetColorVEC JMP SetColor
CURSORVEC	JMP CURSOR
UNCURSORVEC	JMP UNCURSOR
WRITERTC	JMP RTC_WRITE
READRTC		JMP RTC_READ
IECIN		JMP LAB_EF19 		; Read byte from serial bus. (Must call TALK and TALKSA beforehands.)
IECOUT		JMP LAB_EEE4 		; Write byte to serial bus. (Must call LISTEN and LSTNSA beforehands.)
UNTALK		JMP LAB_EEF6 		; Send UNTALK command to serial bus.
UNLSTN		JMP LAB_EF04 		; Send UNLISTEN command to serial bus.
LISTEN		JMP LAB_EE17 		; Send LISTEN command to serial bus.
TALK		JMP LAB_EE14 		; Send TALK command to serial bus.
SETLFS		JMP LAB_FE50	 	; Set file parameters.
SETNAM		JMP LAB_FE49 		; Set file name parameters.
LOAD		JMP LOADTORAM 		; Load or verify file. (Must call SETLFS and SETNAM beforehands.)
SAVE		JMP IECSAVERAM 		; Save file. (Must call SETLFS and SETNAM beforehands.)
IECINIT		JMP INITIEC	   		; INIT IEC
IECCLCH     JMP LAB_F3F3        ; close input and output channels
IECOUTC     JMP LAB_F309        ; open a channel for output
IECINPC     JMP LAB_F2C7        ; open a channel for input
IECOPNLF    JMP LAB_F40A        ; open a logical file
IECCLSLF    JMP LAB_F34A        ; close a specified logical file
ClearScrVec JMP ClearScreen     ; clear the 9918 Screen
LOADFONTVec JMP LoadFont 	; LOAD THE FONT


; 65c816 Native Vectors
		.ORG     $FFE4
COPVECTOR	.DW   RCOPVECTOR
BRKVECTOR	.DW   RBRKVECTOR
ABTVECTOR	.DW   RABTVECTOR
NMIVECTOR   .DW   RNMIVECTOR
resv1		.DW   $0000		;
IRQVECTOR 	.DW   RIRQVECTOR	; ROM VECTOR FOR IRQ


; 6502 Emulation Vectors
		.ORG     $FFF4
ECOPVECTOR	.DW   RECOPVECTOR
resv2		.DW   $0000
EABTVECTOR	.DW   REABTVECTOR
ENMIVECTOR  .DW   RENMIVECTOR
RSTVECTOR   .DW   COLD_START	;
EINTVECTOR 	.DW   REINTVECTOR	; ROM VECTOR FOR IRQ

	.END
