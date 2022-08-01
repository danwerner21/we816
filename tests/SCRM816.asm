
;__SCRM816_________________________________________________________________________________________
;
;	SCREAM FOR THE RBC 65c816N SBC
;
;	WRITTEN BY: DAN WERNER -- 9/14/2017
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
UART0:		.EQU	$FE00		;   DATA IN/OUT
UART1:		.EQU	$FE01		;   CHECK RX
UART2:		.EQU	$FE02		;   INTERRUPTS
UART3:		.EQU	$FE03		;   LINE CONTROL
UART4:		.EQU	$FE04		;   MODEM CONTROL
UART5:		.EQU	$FE05		;   LINE STATUS
UART6:		.EQU	$FE06		;   MODEM STATUS
RTC:		.EQU	$FE07		;   RTC REG.


IRQVECTADD   	.EQU   	$30   		; VECTOR FOR USER IRQ RTN       
WORKPTR		.EQU   	$32		; WORK POINTER FOR COMMAND PROCESSOR		
JUMPPTR		.EQU	$34		; JUMP VECTOR FOR LOOKUP TABLE	
TEMPWORD	.EQU	$36		;
TEMPWORD1	.EQU   	$38		;
TEMPWORD2	.EQU   	$3A		;
TEMPBYTE	.EQU	$3B		;
ACC      	.EQU   	$3D		; ACC STORAGE
XREG     	.EQU   	$3E 		; X REG STORAGE
YREG     	.EQU   	$3F 		; Y REG STORAGE
PREG     	.EQU   	$40 		; CURRENT STACK POINTER
PCL      	.EQU   	$41 		; PROGRAM COUNTER LOW
PCH      	.EQU   	$42 		; PROGRAM COUNTER HIGH
SPTR     	.EQU   	$43 		; CPU STATUS REGISTER
CKSM		.EQU	$44		; CHECKSUM
BYTECT		.EQU	$45		; BYTE COUNT
STRPTR	 	.EQU	$48		;
COUNTER	 	.EQU	$4A		;
SRC	 	.EQU	$4C		;
DEST	 	.EQU	$4E		;
INBUFFER	.EQU	$0200		;

;/* ****  MEMORY MAP ******
;
;000000..007FFF	LOW RAM < 32K
;00FE00..00FEFF	I/O AREA (BOARD AND EXTERNAL)
;008000..00FFFF	32K ROM - 256 FOR I/O
;010000..07FFFF	HIGH RAM > 64K
;080000..FFFFFF	EXTERNAL ECB BUS RAM
;
;Revised:
; 00FE00..00FEFF	I/O ARES -- FIXED; DOES NOT DEPEND ON ROM SIZE
;ROMSTRT..00FFFF	ROM:  EXCLUDING THE I/O AREA
;
;LARGE ROMSTRT = 008000	32K
;SMALL ROMSTRT = 00C000	16K
;
;************************ */

	.ORG	$8000			; RESERVE ROOM FOR IO AREA
	.DB	00

	.ORG	$d000

;__COLD_START___________________________________________________
;
; PERFORM SYSTEM COLD INIT
;
;_______________________________________________________________        
COLD_START:
         	CLD				;  VERIFY DECIMAL MODE IS OFF

		LDA	#$80			;
		STA	UART3			; SET DLAB FLAG
		LDA	#12			; SET TO 12 = 9600 BAUD
		STA	UART0			;
		LDA	#00			;
		STA	UART1			;
		LDA	#03			;
		STA	UART3			; SET 8 BIT DATA, 1 STOPBIT
		STA	UART4			; SET 8 BIT DATA, 1 STOPBIT

TX:
		LDA	#'A'			; READ LINE STATUS REGISTER
		STA	UART0			; THEN WRITE THE CHAR TO UART
		Jmp     TX

         	BRK				; PERFORM BRK (START MONITOR)

	

; 65c816 Native Vectors
		 .ORG     $FFE4   		
COPVECTOR	.DW   COLD_START
BRKVECTOR	.DW   COLD_START
ABTVECTOR	.DW   COLD_START
NMIVECTOR       .DW   COLD_START
resv1		.DW   COLD_START
IRQVECTOR 	.DW   COLD_START




; 6502 Emulation Vectors
		 .ORG     $FFF4   		
ECOPVECTOR	.DW   COLD_START
resv2		.DW   COLD_START
EABTVECTOR	.DW   COLD_START
ENMIVECTOR      .DW   COLD_START
RSTVECTOR       .DW   COLD_START	; 
EINTVECTOR 	.DW   COLD_START

	.END
