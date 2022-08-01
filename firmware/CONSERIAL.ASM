;__CONSERIAL_______________________________________________________________________________________
;
;	SERIAL CONSOLE DRIVER FOR THE RBC 65c816 SBC
;
;	WRITTEN BY: DAN WERNER -- 2/25/2018
;
;__________________________________________________________________________________________________


        LONGA ON
        LONGI ON
;
;__SERIAL_CONSOLE_INIT___________________________________________
;
;	INITIALIZE UART
;	PARAMS:	SER_BAUD NEEDS TO BE SET TO BAUD RATE
;	1200:	96	 = 1,843,200 / ( 16 X 1200 )
;	2400:	48	 = 1,843,200 / ( 16 X 2400 )
;	4800:	24	 = 1,843,200 / ( 16 X 4800 )
;	9600:	12	 = 1,843,200 / ( 16 X 9600 )
;	19K2:	06	 = 1,843,200 / ( 16 X 19,200 )
;	38K4:	03	
;	57K6:	02
;	115K2:	01	
;
;_______________________________________________________________
;
SERIAL_CONSOLE_INIT:
		PHP
        SEP #$30               ; 8 bit registers (A AND I)
        LONGI Off              ;
        LONGA Off              ;
		
		ldx #63				;
		jsr RTC_READ		; get magic number
		cmp #166			; is valid?
		beq UART_INIT1
		LDA	#$80			;
		STA	UART3			; SET DLAB FLAG
		LDA	#12				; SET TO 12 = 9600 BAUD
		BRA UART_INIT2
UART_INIT1:	
		LDA	#$80			;
		STA	UART3			; SET DLAB FLAG
		ldx #41				;
		jsr RTC_READ		; get baud rate		
UART_INIT2:	
		STA	UART0			; save baud rate
		LDA	#00				;
		STA	UART1			;
		LDA	#03				;
		STA	UART3			; SET 8 BIT DATA, 1 STOPBIT
		STA	UART4			; 
		PLP
		RTS


       	LONGA ON
       	LONGI ON
;__OUTCH_______________________________________________________
;
; OUTPUT CHAR IN LOW BYTE OF ACC TO UART
; 
;______________________________________________________________
SERIAL_OUTCH:	
		PHP
       	SEP #$20 			; NEED 8 bit accum for this
		LONGA OFF 
		PHA					; STORE ACC
TX_BUSYLP:
		LDA	UART5			; READ LINE STATUS REGISTER
		AND	#$20			; TEST IF UART IS READY TO SEND (BIT 5)
		CMP #$00
		BEQ	TX_BUSYLP		; IF NOT REPEAT
		PLA					; RESTORE ACC
		STA	UART0			; THEN WRITE THE CHAR TO UART

		PLP 				; RESTORE CPU CONTEXT
		RTS					; DONE					


       	LONGA ON
       	LONGI ON
;__INCHW_______________________________________________________
;
; INPUT CHAR FROM UART TO ACC  (WAIT FOR CHAR)
;
;______________________________________________________________
SERIAL_INCHW:	
		PHP
       	SEP #$20 			; NEED 8 bit accum for this
		LONGA OFF 

SERIAL_INCHW1:
		LDA	UART5			; READ LINE STATUS REGISTER
		AND	#$01			; TEST IF DATA IN RECEIVE BUFFER
		CMP #$00
		BEQ	SERIAL_INCHW1	; LOOP UNTIL DATA IS READY
		LDA	UART0			; THEN READ THE CHAR FROM THE UART

		PLP 				; RESTORE CPU CONTEXT
		RTS


        LONGA ON
        LONGI ON
;__INCH_______________________________________________________
;
; INPUT CHAR FROM UART TO ACC (DO NOT WAIT FOR CHAR)
; CArry set if invalid character
;______________________________________________________________
SERIAL_INCH:	
		PHP
        SEP #$20 			; NEED 8 bit accum for this
		LONGA OFF 
		LDA	UART5			; READ LINE STATUS REGISTER
		AND	#$01			; TEST IF DATA IN RECEIVE BUFFER
		BEQ	SERIAL_INCH1	; NO CHAR FOUND
		LDA	UART0			; THEN READ THE CHAR FROM THE UART
		PLP 				; RESTORE CPU CONTEXT
		CLC
		RTS
SERIAL_INCH1:
 		PLP 				; RESTORE CPU CONTEXT
		SEC 	
		RTS
