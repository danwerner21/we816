;__IEC_____________________________________________________________________________________________
;
;	IEC SERIAL DRIVER
;   ORIGINALLY FROM COMMODORE 64 KERNAL
;	CONVERTED FOR 65816 BY: DAN WERNER -- 4/6/2021
;
;__________________________________________________________________________________________________

;***********************************************************************************;
;
; set serial data out high

LAB_E4A0
	LDA	via2pcr 		; get VIA 2 PCR
	AND	#$DF			; set CB2 low, serial data out high
	STA	via2pcr 		; set VIA 2 PCR
	RTS


;***********************************************************************************;
;
; set serial data out low

LAB_E4A9
	LDA	via2pcr 		; get VIA 2 PCR
	ORA	#$20			; set CB2 high, serial data out low
	STA	via2pcr 		; set VIA 2 PCR
	RTS


;***********************************************************************************;
;
; get serial clock status

LAB_E4B2
	LDA	via1ora		; get VIA 1 DRA, no handshake
	CMP	via1ora		; compare with self
	BNE	LAB_E4B2		; loop if changing

	LSR				; shift serial clock to Cb
	RTS


;***********************************************************************************;
;
; command a serial bus device to TALK

; to use this routine the accumulator must first be loaded with a device number
; between 4 and 30. When called this routine converts this device number to a talk
; address. Then this data is transmitted as a command on the Serial bus.

LAB_EE14
	ORA	#$40			; OR with the TALK command
	.byte	$2C			; makes next line BIT LAB_2009


;***********************************************************************************;
;
; command devices on the serial bus to LISTEN

; this routine will command a device on the serial bus to receive data. The
; accumulator must be loaded with a device number between 4 and 31 before calling
; this routine. LISTEN convert this to a listen address then transmit this data as
; a command on the serial bus. The specified device will then go into listen mode
; and be ready to accept information.

LAB_EE17
	ORA	#$20			; OR with the LISTEN command
	JSR	LAB_F160		; check RS232 bus idle, setup timers

;***********************************************************************************;
;
; send control character

LAB_EE1C
	PHA				; save device address
	BIT	IECDCF		; test deferred character flag
	BPL	LAB_EE2B		; branch if no defered character

	SEC				; flag EOI
	ROR	IECBCI		; rotate into EOI flag byte
	JSR	LAB_EE49		; Tx byte on serial bus

	LSR	IECDCF		; clear deferred character flag
	LSR	IECBCI		; clear EOI flag
LAB_EE2B

	PLA				; restore device address
	STA	IECDC		; save as serial defered character
	JSR	LAB_E4A0		; set serial data out high
	CMP	#$3F			; compare read byte with $3F
	BNE	LAB_EE38		; branch if not $3F, this branch will always be taken as
					; after VIA 2's PCR is read it is ANDed with $DF, so the
					; result can never be $3F

	JSR	LAB_EF84		; set serial clock high

LAB_EE38
	LDA	via1ora		; get VIA 1 DRA, no handshake
	ORA	#$80			; set serial ATN low
	STA	via1ora		; set VIA 1 DRA, no handshake


;***********************************************************************************;
;
; if the code drops through to here the serial clock is low and the serial data has been
; released so the following code will have no effect apart from delaying the first byte
; by 1ms

;## set clk/data, wait and Tx byte on serial bus
LAB_EE40
	JSR	LAB_EF8D		; set serial clock low
	JSR	LAB_E4A0		; set serial data out high
	JSR	LAB_EF96		; 1ms delay

;***********************************************************************************;
;
; Tx byte on serial bus

LAB_EE49
	SEI				; disable interrupts
	JSR	LAB_E4A0		; set serial data out high
	JSR	LAB_E4B2		; get serial clock status
	LSR				; shift serial data to Cb
	BCS	LAB_EEB4		; if data high do device not present
	JSR	LAB_EF84		; set serial clock high
	BIT	IECBCI		; test EOI flag
	BPL	LAB_EE66		; branch if not EOI
; I think this is the EOI sequence so the serial clock has been released and the serial
; data is being held low by the peripherals. first up wait for the serial data to rise

LAB_EE5A
	JSR	LAB_E4B2		; get serial clock status
	LSR				; shift serial data to Cb
	BCC	LAB_EE5A		; loop if data low

; now the data is high, EOI is signalled by waiting for at least 200us without pulling
; the serial clock line low again. the listener should respond by pulling the serial
; data line low

LAB_EE60
	JSR	LAB_E4B2		; get serial clock status
	LSR				; shift serial data to Cb
	BCS	LAB_EE60		; loop if data high

; the serial data has gone low ending the EOI sequence, now just wait for the serial
; data line to go high again or, if this isn't an EOI sequence, just wait for the serial
; data to go high the first time

LAB_EE66
	JSR	LAB_E4B2		; get serial clock status
	LSR				; shift serial data to Cb
	BCC	LAB_EE66		; loop if data low

; serial data is high now pull the clock low, preferably within 60us

	JSR	LAB_EF8D		; set serial clock low

; now the Vic has to send the eight bits, LSB first. first it sets the serial data line
; to reflect the bit in the byte, then it sets the serial clock to high. The serial
; clock is left high for 26 cycles, 23us on a PAL Vic, before it is again pulled low
; and the serial data is allowed high again

	LDA	#$08			; eight bits to do
	STA	IECBTC		; set serial bus bit count
LAB_EE73
	LDA	via1ora		; get VIA 1 DRA, no handshake
	CMP	via1ora		; compare with self
	BNE	LAB_EE73		; loop if changing

	LSR				; serial clock to carry
	LSR				; serial data to carry
	BCC	LAB_EEB7		; if data low do timeout on serial bus
	jsr IEC_DELAY
	ROR	IECDC		; rotate transmit byte
	BCS	LAB_EE88		; branch if bit = 1

	JSR	LAB_E4A9		; else set serial data out low
	BNE	LAB_EE8B		; branch always

LAB_EE88
	JSR	LAB_E4A0		; set serial data out high
LAB_EE8B
	jsr IEC_DELAY
	JSR	LAB_EF84		; set serial clock high
	NOP				; waste ..
	NOP				; .. a ..
	NOP				; .. cycle ..
	NOP				; .. or two
	jsr IEC_DELAY
	LDA	via2pcr 		; get VIA 2 PCR
	AND	#$DF			; set CB2 low, serial data out high
	ORA	#$02			; set CA2 high, serial clock out low
	STA	via2pcr 		; save VIA 2 PCR
	DEC	IECBTC		; decrement serial bus bit count
	BNE	LAB_EE73		; loop if not all done

; now all eight bits have been sent it's up to the peripheral to signal the byte was
; received by pulling the serial data low. this should be done within one milisecond

	LDA	#$40			; wait for up to about 1ms (MHZ)
	STA	via2t2ch		; set VIA 2 T2C_h
LAB_EEA5
	LDA	via2ifr		; get VIA 2 IFR
	AND	#$20			; mask T2 interrupt
	BNE	LAB_EEB7		; if T2 interrupt do timeout on serial bus

	JSR	LAB_E4B2		; get serial clock status
	LSR		  			; shift serial data to Cb
	BCS	LAB_EEA5		; if data high go wait some more

	CLI				; enable interrupts
	RTS


;***********************************************************************************;
;
; device not present

LAB_EEB4
	LDA	#$80			; error $80, device not present
	.byte	$2C			; makes next line BIT LAB_03A9


;***********************************************************************************;
;
; timeout on serial bus

LAB_EEB7
	LDA	#$03			; error $03, write timeout
LAB_EEB9
	JSR	LAB_FE6A		; OR into serial status byte
	CLI				; enable interrupts
	CLC				; clear for branch
	BCC	LAB_EF09		; ATN high, delay, clock high then data high, branch always


;***********************************************************************************;
;
; send secondary address after LISTEN

; this routine is used to send a secondary address to an I/O device after a call to
; the LISTEN routine is made and the device commanded to LISTEN. The routine cannot
; be used to send a secondary address after a call to the TALK routine.

; A secondary address is usually used to give set-up information to a device before
; I/O operations begin.

; When a secondary address is to be sent to a device on the serial bus the address
; must first be ORed with $60.

LAB_EEC0
	STA	IECDC		; save defered byte
	JSR	LAB_EE40		; set clk/data, wait and Tx byte on serial bus
; set serial ATN high

LAB_EEC5
	LDA	via1ora		; get VIA 1 DRA, no handshake
	AND	#$7F			; set serial ATN high
	STA	via1ora		; set VIA 1 DRA, no handshake
	RTS


;***********************************************************************************;
;
; send secondary address after TALK

; this routine transmits a secondary address on the serial bus for a TALK device.
; This routine must be called with a number between 4 and 31 in the accumulator.
; The routine will send this number as a secondary address command over the serial
; bus. This routine can only be called after a call to the TALK routine. It will
; not work after a LISTEN.

LAB_EECE
	STA	IECDC		; save the secondary address byte to transmit
	JSR	LAB_EE40		; set clk/data, wait and Tx byte on serial bus

	BIT	IECSTW			; test serial status byte
	BPL	LAB_EED3		; if device present
	SEC
	RTS

;***********************************************************************************;
;
; wait for bus end after send

LAB_EED3
	SEI				; disable interrupts
	JSR	LAB_E4A9		; set serial data out low
	JSR	LAB_EEC5		; set serial ATN high
	JSR	LAB_EF84		; set serial clock high
LAB_EEDD
	JSR	LAB_E4B2		; get serial clock status
	BCS	LAB_EEDD		; branch if clock high

	CLI				; enable interrupts
	RTS


;***********************************************************************************;
;
; output a byte to the serial bus

; this routine is used to send information to devices on the serial bus. A call to
; this routine will put a data byte onto the serial bus using full handshaking.
; Before this routine is called the LISTEN routine, LAB_FFB1, must be used to
; command a device on the serial bus to get ready to receive data.

; the accumulator is loaded with a byte to output as data on the serial bus. A
; device must be listening or the status word will return a timeout. This routine
; always buffers one character. So when a call to the UNLISTEN routine, LAB_FFAE,
; is made to end the data transmission, the buffered character is sent with EOI
; set. Then the UNLISTEN command is sent to the device.

LAB_EEE4
	BIT IECDCF		; test deferred character flag
	BMI	LAB_EEED		; branch if defered character

	SEC				; set carry
	ROR	IECDCF		; shift into deferred character flag
	BNE	LAB_EEF2		; save byte and exit, branch always

LAB_EEED
	PHA				; save byte
	JSR	LAB_EE49		; Tx byte on serial bus
	PLA				; restore byte
LAB_EEF2
	STA	IECDC		; save defered byte
	CLC				; flag ok
	RTS


;***********************************************************************************;
;
; command the serial bus to UNTALK

; this routine will transmit an UNTALK command on the serial bus. All devices
; previously set to TALK will stop sending data when this command is received.

LAB_EEF6
	JSR	LAB_EF8D		; set serial clock low
	LDA	via1ora		; get VIA 1 DRA, no handshake
	ORA	#$80			; set serial ATN low
	STA	via1ora		; set VIA 1 DRA, no handshake

	LDA	#$5F			; set the UNTALK command
	.byte	$2C			; makes next line BIT LAB_3FA9


;***********************************************************************************;
;
; command the serial bus to UNLISTEN

; this routine commands all devices on the serial bus to stop receiving data from
; the computer. Calling this routine results in an UNLISTEN command being transmitted
; on the serial bus. Only devices previously commanded to listen will be affected.

; This routine is normally used after the computer is finished sending data to
; external devices. Sending the UNLISTEN will command the listening devices to get
; off the serial bus so it can be used for other purposes.

LAB_EF04
	LDA	#$3F			; set the UNLISTEN command
	JSR	LAB_EE1C		; send control character

; ATN high, delay, clock high then data high

LAB_EF09
	JSR	LAB_EEC5		; set serial ATN high

; 1ms delay, clock high then data high

LAB_EF0C
	TXA				; save device number
	LDX	#$0B			; short delay
LAB_EF0F
	DEX				; decrement count
	BNE	LAB_EF0F		; loop if not all done

	TAX				; restore device number
	JSR	LAB_EF84		; set serial clock high
	JMP	LAB_E4A0		; set serial data out high and return


;***********************************************************************************;
;
; input a byte from the serial bus

; this routine reads a byte of data from the serial bus using full handshaking. the
; data is returned in the accumulator. before using this routine the TALK routine,
; LAB_FFB4, must have been called first to command the device on the serial bus to
; send data on the bus. if the input device needs a secondary command it must be sent
; by using the TKSA routine, LAB_FF96, before calling this routine.

; errors are returned in the status word which can be read by calling the READST
; routine, LAB_FFB7.

LAB_EF19
	SEI				; disable interrupts
	LDA	#$00			; clear A
	STA	IECBTC		; clear serial bus bit count
	JSR	LAB_EF84		; set serial clock high
LAB_EF21
	JSR	LAB_E4B2		; get serial clock status
	BCC	LAB_EF21		; loop while clock low

	JSR	LAB_E4A0		; set serial data out high
LAB_EF29
	LDA	#$10			; set timeout count high byte (MHZ DEPENDENT)
	STA	via2t2ch		; set VIA 2 T2C_h
LAB_EF2E
	LDA	via2ifr		; get VIA 2 IFR
	AND	#$20			; mask T2 interrupt
	BNE	LAB_EF3C		; branch if T2 interrupt

	JSR	LAB_E4B2		; get serial clock status
	BCS	LAB_EF2E		; loop if clock high

	BCC	LAB_EF54		; else go se 8 bits to do, branch always

					; T2 timed out
LAB_EF3C
	LDA	IECBTC		; get serial bus bit count
	BEQ	LAB_EF45		; if not already EOI then go flag EOI

	LDA	#$02			; error $02, read timeour
	JMP	LAB_EEB9		; set serial status and exit

LAB_EF45
	JSR	LAB_E4A9		; set serial data out low
	JSR	LAB_EF0C		; 1ms delay, clock high then data high
	LDA	#$40			; set EOI
	JSR	LAB_FE6A		; OR into serial status byte
	INC	IECBTC		; increment serial bus bit count, do error on next timeout
	BNE	LAB_EF29		; go try again

LAB_EF54
	LDA	#$08			; 8 bits to do
	STA	IECBTC		; set serial bus bit count
LAB_EF58

	; STICKS HERE IF NO DATA TO READ

	LDA	via1ora		; get VIA 1 DRA, no handshake
	CMP	via1ora		; compare with self
	BNE	LAB_EF58		; loop if changing
; OR HERE?
	LSR				; serial clock into carry
	BCC	LAB_EF58		; loop while serial clock low

	LSR				; serial data into carry
	ROR	IECCYC		; shift data bit into receive byte
LAB_EF66

	LDA	via1ora		; get VIA 1 DRA, no handshake
	CMP	via1ora		; compare with self
	BNE	LAB_EF66		; loop if changing

	LSR				; serial clock into carry
	BCS	LAB_EF66		; loop while serial clock high

	DEC	IECBTC		; decrement serial bus bit count
	BNE	LAB_EF58		; loop if not all done

	JSR	LAB_E4A9		; set serial data out low
	LDA	IECSTW		; get serial status byte
	BEQ	LAB_EF7F		; branch if no error

	JSR	LAB_EF0C		; 1ms delay, clock high then data high
LAB_EF7F
	LDA	IECCYC		; get receive byte
	CLI				; enable interrupts
	CLC
	RTS


;***********************************************************************************;
;
; set serial clock high

LAB_EF84
	LDA	via2pcr 		; get VIA 2 PCR
	AND	#$FD			; set CA2 low, serial clock out high
	STA	via2pcr 		; set VIA 2 PCR
	RTS


;***********************************************************************************;
;
; set serial clock low

LAB_EF8D
	LDA	via2pcr 		; get VIA 2 PCR
	ORA	#$02			; set CA2 high, serial clock out low
	STA	via2pcr 		; set VIA 2 PCR
	RTS


;***********************************************************************************;
;
; 1ms delay

LAB_EF96
	LDA	#$40			; set for 1024 cycles (MHZ)
	STA	via2t2ch		; set VIA 2 T2C_h
LAB_EF9B
	LDA	via2ifr		; get VIA 2 IFR
	AND	#$20			; mask T2 interrupt
	BEQ	LAB_EF9B		; loop until T2 interrupt

	RTS

; OR into serial status byte

LAB_FE6A
	ORA	IECSTW		; OR with serial status byte
	STA	IECSTW		; save serial status byte
	RTS


;***********************************************************************************;
;
; load RAM from a device

; this routine will load data bytes from any input device directly into the memory
; of the computer.
; If the input device was OPENed with a secondary address of 0 the header information from
; device will be ignored. In this case Location LOADBUF must contain the starting address for the
; load. LOADBANK must also be specified with the appropriate bank number.  If the device was addressed with a secondary address of 1 or 2 the data will
; load into memory starting at the location specified by the header. This routine
; returns the address of the highest RAM location which was loaded.

; Before this routine can be called,
;		the SETLFS
;		LAB_FFBA(set logical, first and second addresses)
;		SETNAM
;		LAB_FFBD(clear filename)
; 	routines must be called.
LOADTORAM:
LAB_F549
	LDA	#$00			; clear A
	STA	IECSTW		; clear serial status byte
	LDY	IECFNLN		; get file name length
	BNE	LAB_F563		; branch if not null name
	JMP	LAB_F793		; else do missing file name error and return
LAB_F563
	JSR	LAB_E4BC		; get seconday address and print "Searching..."
	LDA	#$60			;.
	STA	IECSECAD		; save the secondary address
	JSR	LAB_F495		; send secondary address and filename
	LDA	IECDEVN			; get device number
	JSR	LAB_EE14		; command a serial bus device to TALK
	LDA	IECSECAD		; get secondary address
	JSR	LAB_EECE		; send secondary address after TALK
	JSR	LAB_EF19		; input a byte from the serial bus

	STA	IECBUFFL		; save program start address low byte
	LDA	IECSTW		; get serial status byte
	LSR				; shift time out read ..
	LSR				; .. into carry bit
	BCS	LAB_F5C7		; if timed out go do file not found error and return
	JSR	LAB_EF19		; input a byte from the serial bus
	STA	IECBUFFH		; save program start address high byte
	JSR	LAB_E4C1		; set LOAD address if secondary address = 0
LAB_F58A
	LDA	#$FD			; mask xxxx xx0x, clear time out read bit
	AND	IECSTW		; mask serial status byte
	STA	IECSTW		; set serial status byte
	JSR	LAB_FFE1		; scan stop key, return Zb = 1 = [STOP]
	BNE	LAB_F598		; branch if not [STOP]
	JMP	LAB_F6CB		; else close the serial bus device and flag stop

LAB_F598
	JSR	LAB_EF19		; input a byte from the serial bus
	TAX				; copy byte
	LDA	IECSTW		; get serial status byte
	LSR				; shift time out read ..
	LSR				; .. into carry bit
	BCS	LAB_F58A		; if timed out go ??

	lda LOADBANK	; set load bank
	phb
	pha
	TXA				; copy received byte back
	Index16
	ldx LOADBUFL
	plb
	STA	0,x			; save byte to memory
	plb 			; restore bank
	index8

LAB_F5B5
	INC	LOADBUFL		; increment save pointer low byte
	BNE	LAB_F5BB		; if no rollover skip the high byte increment

	INC	LOADBUFH		; else increment save pointer high byte
LAB_F5BB
	BIT	IECSTW		; test serial status byte
	BVC	LAB_F58A		; loop if not end of file

	JSR	LAB_EEF6		; command the serial bus to UNTALK
	JSR	LAB_F6DA		; close serial bus device
	BCC	LAB_F641		; if ?? go flag ok and exit

LAB_F5C7
	JMP	LAB_F787		; do file not found error and return

LAB_F641
	CLC				; flag ok
	LDX	IECBUFFL		; get the LOAD end pointer low byte
	LDY	IECBUFFH		; get the LOAD end pointer high byte
LAB_F646
	RTS

;***********************************************************************************;
;
; save RAM to a device
; this routine saves a section of memory.
; Start Address in IECSTRT
; End Address in LOADBUF
; LOADBANK must also be specified with the appropriate bank number.

; Before this routine can be called,
;		the SETLFS
;		LAB_FFBA(set logical, first and second addresses)
;		SETNAM
;		LAB_FFBD(clear filename)
; 	routines must be called.
;***********************************************************************************;
;
; save RAM to device, A = index to start address, XY = end address low/high

IECSAVERAM:
;***********************************************************************************;
;
; save

LAB_F685
	LDA	#$00			; clear A
	STA	IECSTW		; clear serial status byte
	LDA	#$61			; set secondary address to $01
					; when a secondary address is to be sent to a device on
					; the serial bus the address must first be ORed with $60
	STA	IECSECAD		; save secondary address
	LDY	IECFNLN		; get file name length
	BNE	LAB_F69D		; branch if filename not null
	JMP	LAB_F793		; else do missing file name error and return

LAB_F69D
	JSR	LAB_F495		; send secondary address and filename
	JSR	LAB_F728		; print saving [file name]
	LDA	IECDEVN		; get device number
	JSR	LAB_EE17		; command devices on the serial bus to LISTEN
	LDA	IECSECAD		; get secondary address
	JSR	LAB_EEC0		; send secondary address after LISTEN
	LDY	#$00			; clear index
	JSR	LAB_FBD2		; copy I/O start address to buffer address
	LDA	IECBUFFL		; get buffer address low byte
	JSR	LAB_EEE4		; output a byte to the serial bus
	LDA	IECBUFFH		; get buffer address high byte
	JSR	LAB_EEE4		; output a byte to the serial bus
LAB_F6BC

	JSR	LAB_FD11		; check read/write pointer, return Cb = 1 if pointer >= end
	BCS	LAB_F6D7		; go do UNLISTEN if at end

 	lda LOADBANK	; set load bank
	phb
	pha
	Index16
	ldx IECBUFFL
	plb
	LDA	0,x			; load byte from memory
	plb 			; restore bank
	index8

	JSR	LAB_EEE4		; output a byte to the serial bus
	JSR	LAB_FFE1		; scan stop key
	BNE	LAB_F6D2		; if stop not pressed go increment pointer and loop for next

					; else ..

; close the serial bus device and flag stop

LAB_F6CB
	JSR	LAB_F6DA		; close serial bus device
	LDA	#$00			;.
	SEC				; flag stop
	RTS

LAB_F6D2
	JSR	LAB_FD1B		; increment read/write pointer
	BNE	LAB_F6BC		; loop, branch always

;***********************************************************************************;
;
; ??

LAB_F6D7
	JSR	LAB_EF04		; command the serial bus to UNLISTEN

; close the serial bus device

LAB_F6DA
	BIT	IECSECAD		; test the secondary address
	BMI	LAB_F6EF		; if already closed just exit

	LDA	IECDEVN		; get the device number
	JSR	LAB_EE17		; command devices on the serial bus to LISTEN
	LDA	IECSECAD		; get secondary address
	AND	#$EF			; mask the channel number
	ORA	#$E0			; OR with the CLOSE command
	JSR	LAB_EEC0		; send secondary address after LISTEN
	JSR	LAB_EF04		; command the serial bus to UNLISTEN
LAB_F6EF
	CLC				; flag ok
	RTS

;***********************************************************************************;
;
; file error messages
LAB_F77E
	LDA	#$01			; too many files
	.byte	$2C			; makes next line BIT LAB_02A9
LAB_F781
	LDA	#$02			; file already open
	.byte	$2C			; makes next line BIT LAB_03A9
LAB_F784
	LDA	#$03			; file not open
	.byte	$2C			; makes next line BIT LAB_04A9
LAB_F787
	LDA	#$04			; file not found
	.byte	$2C			; makes next line BIT LAB_05A9
LAB_F78A
	LDA	#$05			; device not present
	.byte	$2C			; makes next line BIT LAB_06A9
LAB_F78D
	LDA	#$06			; not input file
	.byte	$2C			; makes next line BIT LAB_07A9
LAB_F790
	LDA	#$07			; not output file
	.byte	$2C			; makes next line BIT LAB_08A9
LAB_F793
	LDA	#$08			; missing file name
	.byte	$2C			; makes next line BIT LAB_09A9
LAB_F796
	LDA	#$09			; illegal device number

	PHA				; save error #
	JSR	LAB_FFCC		; close input and output channels
	LDY	#LAB_F174-LAB_F174
					; index to "I/O ERROR #"
	BIT	IECMSGM		; test message mode flag
	BVC	LAB_F7AC		; exit if kernal messages off

	JSR	LAB_F1E6		; display kernel I/O message
	PLA				; restore error #
	PHA				; copy error #
	ORA	#'0'			; convert to ASCII
	JSR	OUTCH		; output character to channel
LAB_F7AC
	PLA				; pull error number
	SEC				; flag error
	RTS


;***********************************************************************************;
;
; get seconday address and print "Searching..."

LAB_E4BC
	LDX	IECSECAD		; get secondary address
	JMP	LAB_F647		; print "Searching..." and return



;***********************************************************************************;
;
; send secondary address and filename

LAB_F495
	LDA	IECSECAD		; get secondary address
	BMI	LAB_F4C5		; ok exit if -ve

	LDY	IECFNLN		; get file name length
	BEQ	LAB_F4C5		; ok exit if null

	LDA	IECDEVN		; get device number
	JSR	LAB_EE17		; command devices on the serial bus to LISTEN

	LDA	IECSECAD		; get the secondary address
	ORA	#$F0			; OR with the OPEN command
	JSR	LAB_EEC0		; send secondary address after LISTEN
	LDA	IECSTW			; get serial status byte
	BPL	LAB_F4B2		; branch if device present
	PLA				; else dump calling address low byte
	PLA				; dump calling address high byte
	JMP	LAB_F78A		; do device not present error and return
LAB_F4B2
	LDA	IECFNLN		; get file name length
	BEQ	LAB_F4C2		; branch if null name
	tay
	phx
	Index16
	ldx IECFNPL
	phx
LAB_F4B8
	Index16
	plx
	LDA	0,X			; get file name byte
	inx
	phx
	Index8
	JSR	LAB_EEE4		; output a byte to the serial bus
	dey
	BNE	LAB_F4B8		; loop if not all done
	Index16
	plx
	Index8
	plx
LAB_F4C2
	JSR	LAB_EF04		; command the serial bus to UNLISTEN
LAB_F4C5
	CLC				; flag ok
	RTS

;***********************************************************************************;
;
; set LOAD address if secondary address = 0

LAB_E4C1
	TXA				; copy secondary address
	BNE	LAB_E4CC		; load location not set in LOAD call, so
					; continue with load
	LDA	IECBUFFH		; get load address high byte
	STA	LOADBUFH		; save program start address high byte
	LDA	IECBUFFL		; get load address low byte
	STA	LOADBUFL		; save program start address low byte

LAB_E4CC
	JMP	LAB_F66A		; display "LOADING" or "VERIFYING" and return


;***********************************************************************************;
;
; print saving [file name]

LAB_F728
	LDA	IECMSGM		; get message mode flag
	BPL	LAB_F727		; exit if control messages off

	LDY	#LAB_F1C5-LAB_F174
					; index to "SAVING "
	JSR	LAB_F1E6		; display kernel I/O message
	JMP	LAB_F659		; print file name and return
LAB_F727
	RTS

;***********************************************************************************;
;
; copy I/O start address to buffer address

LAB_FBD2
	LDA	IECSTRTH		; get I/O start address high byte
	STA	IECBUFFH		; set buffer address high byte
	LDA	IECSTRTL		; get I/O start address low byte
	STA	IECBUFFL		; set buffer address low byte
	RTS



;***********************************************************************************;
;
; check read/write pointer
; return Cb = 1 if pointer >= end

LAB_FD11
	SEC				; set carry for subtract
	LDA	IECBUFFL		; get buffer address low byte
	SBC	LOADBUFL		; subtract buffer end low byte
	LDA	IECBUFFH		; get buffer address high byte
	SBC	LOADBUFH		; subtract buffer end high byte
	RTS

;***********************************************************************************;
;
; increment read/write pointer

LAB_FD1B
	INC	IECBUFFL		; increment buffer address low byte
	BNE	LAB_FD21		; if no overflow skip the high byte increment

	INC	IECBUFFH		; increment buffer address high byte
LAB_FD21
	RTS

;***********************************************************************************;
;
; close input and output channels

; this routine is called to clear all open channels and restore the I/O channels to
; their original default values. It is usually called after opening other I/O
; channels and using them for input/output operations. The default input device is
; 0, the keyboard. The default output device is 3, the screen.

; If one of the channels to be closed is to the serial port, an UNTALK signal is sent
; first to clear the input channel or an UNLISTEN is sent to clear the output channel.
; By not calling this routine and leaving listener(s) active on the serial bus,
; several devices can receive the same data from the VIC at the same time. One way to
; take advantage of this would be to command the printer to TALK and the disk to
; LISTEN. This would allow direct printing of a disk file.

LAB_FFCC
	JSR	LAB_EF04		; command the serial bus to UNLISTEN
LAB_F3FC
	JSR	LAB_EEF6		; command the serial bus to UNTALK
LAB_F403
	RTS

;***********************************************************************************;
;
; kernel I/O messages

LAB_F174
	.byte	$0A,$0D,"I/O ERROR #",0
LAB_F180
	.byte	$0A,$0D,"SEARCHING ",0
LAB_F18B
	.byte	"FOR ",0
LAB_F1BD
	.byte	$0A,$0D,"LOADING",0
LAB_F1C5
	.byte	$0A,$0D,"SAVING ",0
LAB_F1CD
	.byte	$0A,$0D,"VERIFYING",0
LAB_F1D7
	.byte	$0A,$0D,"FOUND ",0
LAB_F1DE
	.byte	$0A,$0D,"OK",0


;***********************************************************************************;
;
; display control I/O message if in direct mode

LAB_F1E2
	BIT	IECMSGM		; test message mode flag
	BPL	LAB_F1F3		; exit if control messages off

; display kernel I/O message

LAB_F1E6
	LDA	LAB_F174,Y		; get byte from message table
	Beq	LAB_F1F3		; loop if not end of message
	PHP				; save status
	jsr	OUTCH		; output character to channel
	INY				; increment index
	PLP				; restore status
	BRA	LAB_F1E6		; loop if not end of message

LAB_F1F3
	CLC				;.
	RTS

;***********************************************************************************;
;
; print "searching"

LAB_F647
	LDA	IECMSGM		; get message mode flag
	BPL	LAB_F669		; exit if control messages off

	LDY	#LAB_F180-LAB_F174
					; index to "SEARCHING "
	JSR	LAB_F1E6		; display kernel I/O message
	LDA	IECFNLN		; get file name length
	BEQ	LAB_F669		; exit if null name

	LDY	#LAB_F18B-LAB_F174
					; else index to "FOR "
	JSR	LAB_F1E6		; display kernel I/O message

; print file name

LAB_F659
	LDY	IECFNLN		; get file name length
	BEQ	LAB_F669		; exit if null file name

	phx
	Index16
	ldx IECFNPL
	phx
LAB_F65F
	Index16
	plx
	LDA	0,X			; get file name byte
	inx
	phx
	Index8
	JSR	OUTCH		; output character to channel
	dey
	BNE	LAB_F65F		; loop if more to do
	Index16
	plx
	Index8
	plx
LAB_F669
	RTS

; display "LOADING" or "VERIFYING"

LAB_F66A
	LDY	#LAB_F1BD-LAB_F174
					; point to "LOADING"
LAB_F672
	JMP	LAB_F1E2		; display kernel I/O message if in direct mode and return

LAB_FE49
	STA	IECFNLN		; set file name length
	STX	IECFNPL		; set file name pointer low byte
	STY	IECFNPH		; set file name pointer high byte
	RTS

LAB_FE50
    STA IECLFN 		; SET LOGICAL FILE NUMBER
	STX	IECDEVN		; set device number
	STY	IECSECAD	; set secondary address or command
	RTS



LAB_F160
	PHA				; save A
	LDA	via1ier		; get VIA 1 IER
	BEQ	LAB_F172		; branch if no interrupts enabled. this branch will
					; never be taken as b7 of IER always reads as 1
					; according to the 6522 data sheet
LAB_F166
	LDA	via1ier		; get VIA 1 IER
	AND	#$60			; mask 0xx0 0000, T1 and T2 interrupts
	BNE	LAB_F166		; loop if T1 or T2 active

	LDA	#$10			; disable CB1 interrupt
	STA	via1ier		; set VIA 1 IER
LAB_F172
	PLA				; restore A
	RTS


;***********************************************************************************;
;
; initialize I/O registers

INITIEC
	LDA	#$7F			; disable all interrupts
	STA	via1ier			; on VIA 1 IER ..
	STA	via2ier			; .. and VIA 2 IER

	LDA	#$40			; set T1 free run, T2 clock �2,
						; SR disabled, latches disabled
	STA	via2acr		; set VIA 2 ACR

	LDA	#$40			; set T1 free run, T2 clock �2,
					; SR disabled, latches disabled
	STA	via1acr		; set VIA 1 ACR

	LDA	#$FE			; CB2 high, RS232 Tx
					; CB1 +ve edge,
					; CA2 high, tape motor off
					; CA1 -ve edge
	STA	via1pcr		; set VIA 1 PCR

	LDA	#$DE			; CB2 low, serial data out high
					; CB1 +ve edge,
					; CA2 high, serial clock out low
					; CA1 -ve edge
	STA	via2pcr		; set VIA 2 PCR

	LDX	#$00			; all inputs, RS232 interface or parallel user port
	STX	via1ddrb		; set VIA 1 DDRB

	LDX	#$FF			; all outputs, keyboard column
	STX	via2ddrb		; set VIA 2 DDRB

	LDX	#$00			; all inputs, keyboard row
	STX	via2ddra		; set VIA 2 DDRA

	LDX	#$C0			; OIII IIII, ATN out, light pen, joystick, serial data
					; in, serial clk in
	STX	via1ddra		; set VIA 1 DDRA

	LDX	#$00			; ATN out low, set ATN high
	STX	via1ora			; set VIA 1 DRA, no handshake

	LDX	#$40			; assert CS on DS1302
	STX	via1ora			; set VIA 1 DRA, no handshake

	JSR	LAB_EF84		; set serial clock high
	JSR	LAB_EF8D		; set serial clock low


;***********************************************************************************;
;
; set 60Hz and enable timer
	LDA	#$C0			; enable T1 interrupt
	STA	via2ier		; set VIA 2 IER
;	LDA	#$26			; set timer constant low byte [PAL]
;	LDA	#$89			; set timer constant low byte [NTSC]
	LDA	#$FF			; set timer constant low byte [4MHz]
	STA	via2t1cl		; set VIA 2 T1C_l
;	LDA	#$48			; set timer constant high byte [PAL]
;	LDA	#$42			; set timer constant high byte [NTSC]
	LDA	#$FF			; set timer constant high byte [4MHz]
	STA	via2t1ch		; set VIA 2 T1C_h

	lda #$00
	sta IECBCI
	STA IECOPENF
	RTS


IEC_DELAY:
	pha
	pla
	pha
	pla
	pha
	pla
	pha
	pla

	pha
	pla
	pha
	pla
	pha
	pla
	pha
	pla
	pha
	pla
	pha
	pla
	pha
	pla
	pha
	pla
	rts

LAB_FFE1
	jsr	INPVEC
	cmp #$03
	rts


;***********************************************************************************;
;
; close a specified logical file

; this routine is used to close a logical file after all I/O operations have been
; completed on that file. This routine is called after the accumulator is loaded
; with the logical file number to be closed, the same number used when the file was
; opened using the OPEN routine.

LAB_F34A
	JSR	LAB_F3D4		; find file A
	BEQ	LAB_F351		; if the file is found go close it

	CLC				; else thr file was closed so just flag ok
	RTS

; found the file so close it
LAB_F351
	JSR	LAB_F3DF		; set file details from table,X
	TXA				; copy file index to A
	PHA				; save file index
	LDA	IECDEVN		; get device number
; do serial bus device file close

LAB_F3AE
	JSR	LAB_F6DA		; close serial bus device
LAB_F3B1
	PLA				; restore file index
;
; close file index X

LAB_F3B2
	TAX				; copy index to file to close
	DEC	IECOPENF		; decrement open file count
	CPX	IECOPENF		; compare index with open file count
	BEQ	LAB_F3CD		; exit if equal, last entry was closing file

					; else entry was not last in list so copy last table entry
					; file details over the details of the closing one
	LDY	IECOPENF		; get open file count as index
	LDA	PTRLFT,Y		; get last+1 logical file number from logical file table
	STA	PTRLFT,X		; save logical file number over closed file
	LDA	PTRDNT,Y		; get last+1 device number from device number table
	STA	PTRDNT,X		; save device number over closed file
	LDA	PTRSAT,Y		; get last+1 secondary address from secondary address table
	STA	PTRSAT,X		; save secondary address over closed file
LAB_F3CD
	CLC				;.
LAB_F3CE
	RTS

;***********************************************************************************;
;
; open a logical file

; this routine is used to open a logical file. Once the logical file is set up it
; can be used for input/output operations. Most of the I/O KERNAL routines call on
; this routine to create the logical files to operate on. No arguments need to be
; set up to use this routine, but both the SETLFS, LAB_FFBA, and SETNAM, LAB_FFBD,
; KERNAL routines must be called before using this routine.

LAB_F40A
	LDX	IECLFN		; get logical file number
	BNE	LAB_F411		; branch if there is a file

	JMP	LAB_F78D		; else do not input file error and return

LAB_F411
	JSR	LAB_F3CF		; find file
	BNE	LAB_F419		; branch if file not found

	JMP	LAB_F781		; else do file already open error and return

LAB_F419
	LDX	IECOPENF		; get open file count
	CPX	#$0A			; compare with max
	BCC	LAB_F422		; branch if less

	JMP	LAB_F77E		; else do too many files error and return

LAB_F422
	INC	IECOPENF		; increment open file count
	LDA	IECLFN		; get logical file number
	STA	PTRLFT,X		; save to logical file table
	LDA	IECSECAD		; get secondary address
	ORA	#$60			; OR with the OPEN CHANNEL command
	STA	IECSECAD		; set secondary address
	STA	PTRSAT,X		; save to secondary address table
	LDA	IECDEVN		; get device number
	STA	PTRDNT,X		; save to device number table
					; serial bus device
	JSR	LAB_F495		; send secondary address and filename
	CLC				; flag ok
LAB_F494
	RTS

;***********************************************************************************;
;
; open a channel for input

; any logical file that has already been opened by the OPEN routine, LAB_FFC0, can be
; defined as an input channel by this routine. the device on the channel must be an
; input device or an error will occur and the routine will abort.

; if you are getting data from anywhere other than the keyboard, this routine must be
; called before using either the CHRIN routine, LAB_FFCF, or the GETIN routine,
; LAB_FFE4. if you are getting data from the keyboard and no other input channels are
; open then the calls to this routine and to the OPEN routine, LAB_FFC0, are not needed.

; when used with a device on the serial bus this routine will automatically send the
; listen address specified by the OPEN routine, LAB_FFC0, and any secondary address.

; possible errors are:
;
;	3 : file not open
;	5 : device not present
;	6 : file is not an input file

LAB_F2C7
	JSR	LAB_F3CF		; find file
	BEQ	LAB_F2CF		; branch if file opened
	JMP	LAB_F784		; do file not open error and return

LAB_F2CF
	JSR	LAB_F3DF		; set file details from table,X
	LDA	IECDEVN		; get device number
					; device was serial bus device
LAB_F2F0
	TAX				; copy device number to X
	JSR	LAB_EE14		; command a serial bus device to TALK
	LDA	IECSECAD		; get secondary address
	BPL	LAB_F2FE		;.

	JSR	LAB_EED3		; wait for bus end after send
	JMP	LAB_F301		;.

LAB_F2FE
	JSR	LAB_EECE		; send secondary address after TALK
LAB_F301
	TXA				; copy device back to A
	BIT	IECSTW			; test serial status byte
	BPL	LAB_F2EC		; if device present save device number and exit

	JMP	LAB_F78A		; do device not present error and return

LAB_F2EC
	STA	IECIDN		; save input device number
	CLC				; flag ok
	RTS

;***********************************************************************************;
;
; open a channel for output

; any logical file that has already been opened by the OPEN routine, LAB_FFC0, can be
; defined as an output channel by this routine the device on the channel must be an
; output device or an error will occur and the routine will abort.

; if you are sending data to anywhere other than the screen this routine must be
; called before using the CHROUT routine, LAB_FFD2. if you are sending data to the
; screen and no other output channels are open then the calls to this routine and to
; the OPEN routine, LAB_FFC0, are not needed.

; when used with a device on the serial bus this routine will automatically send the
; listen address specified by the OPEN routine, LAB_FFC0, and any secondary address.

; possible errors are:
;
;	3 : file not open
;	5 : device not present
;	7 : file is not an output file

LAB_F309
	JSR	LAB_F3CF		; find file
	BEQ	LAB_F311		; branch if file found

	JMP	LAB_F784		; do file not open error and return

LAB_F311
	JSR	LAB_F3DF		; set file details from table,X
	LDA	IECDEVN		; get device number
	TAX				; copy device number
	JSR	LAB_EE17		; command devices on the serial bus to LISTEN
	LDA	IECSECAD		; get secondary address
	BPL	LAB_F33F		; branch if address to send

	JSR	LAB_EEC5		; else set serial ATN high
	BNE	LAB_F342		; branch always
LAB_F33F
	JSR	LAB_EEC0		; send secondary address after LISTEN
LAB_F342
	TXA				; copy device number back to A
	BIT	IECSTW		; test serial status byte
	BPL	LAB_F32E		; if device present save output device number and exit
	JMP	LAB_F78A		; else do device not present error and return

LAB_F32E
	STA	IECODN		; save output device number
	CLC				; flag ok
	RTS

;***********************************************************************************;
;
; find file

LAB_F3CF
	LDA	#$00			; clear A
	STA	IECSTW		; clear serial status byte
	TXA				; copy logical file number to A

; find file A

LAB_F3D4
	LDX	IECOPENF		; get open file count
LAB_F3D6
	DEX				; decrememnt count to give index
	BMI	LAB_F3EE		; exit if no files

	CMP	PTRLFT,X		; compare logical file number with table logical file number
	BNE	LAB_F3D6		; loop if no match

	RTS


;***********************************************************************************;
;
; set file details from table,X

LAB_F3DF
	LDA	PTRLFT,X		; get logical file from logical file table
	STA	IECLFN		; set logical file
	LDA	PTRDNT,X		; get device number from device number table
	STA	IECDEVN		; set device number
	LDA	PTRSAT,X		; get secondary address from secondary address table
	STA	IECSECAD		; set secondary address
LAB_F3EE
	RTS

;***********************************************************************************;
;
; close input and output channels

; this routine is called to clear all open channels and restore the I/O channels to
; their original default values. It is usually called after opening other I/O
; channels and using them for input/output operations. The default input device is
; 0, the keyboard. The default output device is 3, the screen.

; If one of the channels to be closed is to the serial port, an UNTALK signal is sent
; first to clear the input channel or an UNLISTEN is sent to clear the output channel.
; By not calling this routine and leaving listener(s) active on the serial bus,
; several devices can receive the same data from the VIC at the same time. One way to
; take advantage of this would be to command the printer to TALK and the disk to
; LISTEN. This would allow direct printing of a disk file.

LAB_F3F3
	JSR	LAB_EF04		; command the serial bus to UNLISTEN
	JSR	LAB_EEF6		; command the serial bus to UNTALK
	LDA	#$00			; set for keyboard
	STA	IECODN		; set output device number to NULL
	STA	IECIDN		; set input device number to NULL
	RTS
