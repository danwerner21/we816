
		CHIP	65816		; SET CHIP
		LONGA	OFF		; ASSUME EMULATION MODE
		LONGI	OFF		;
		PW	128
		PL 	60
		INCLIST ON

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                                                                                 *
;*      SUPERMON 816 MACHINE LANGUAGE MONITOR FOR THE W65C816S MICROPROCESSOR      *
;* ------------------------------------------------------------------------------- *
;*      Copyright ©1991-2014 by BCS Technology Limited.  All rights reserved.      *
;*                                                                                 *
;* Permission is hereby granted to use, copy, modify and distribute this software, *
;* provided this copyright notice remains in the source code and  proper  attribu- *
;* tion is given.  Redistribution, regardless of form, must be at no charge to the *
;* end  user.  This code or any part thereof, including any derivation, MAY NOT be *
;* incorporated into any package intended for sale,  unless written permission has *
;* been given by the copyright holder.                                             *
;*                                                                                 *
;* THERE IS NO WARRANTY OF ANY KIND WITH THIS SOFTWARE.  The user assumes all risk *
;* in connection with the incorporation of this software into any system.          *
;* ------------------------------------------------------------------------------- *
;* Supermon 816 is a salute to Jim Butterfield, who passed away on June 29, 2007.  *
;*                                                                                 *
;* Jim, who was the unofficial  spokesman for  Commodore  International during the *
;* heyday of the company's 8 bit supremacy, scratch-developed the Supermon machine *
;* language monitor for the PET & CBM computers.   When the best-selling Commodore *
;* 64 was introduced, Jim adapted his software to the new machine & gave the adap- *
;* tation the name Supermon 64.   Commodore  subsequently  integrated a customized *
;* version of Supermon 64 into the C-128 to act as the resident M/L monitor.       *
;*                                                                                 *
;* Although Supermon 816 is not an adaptation of Supermon 64,  it was  decided  to *
;* keep the Supermon name alive, since Supermon 816's general operation & user in- *
;* terface is similar to that of Supermon 64.   Supermon 816 is 100 percent native *
;* mode 65C816 code & was developed from a blank canvas.                           *
;* ------------------------------------------------------------------------------- *
;* Supermon 816 is a full featured monitor and supports the following operations:  *
;*                                                                                 *
;*     A - Assemble code                                                           *
;*     C - Compare memory regions                                                  *
;*     D - Disassemble code                                                        *
;*     F - Fill memory region (cannot span banks)                                  *
;*     G - Execute code (stops at BRK)                                             *
;*     H - Search (hunt) memory region                                             *
;*     J - Execute code as a subroutine (stops at BRK or RTS)                      *
;*     M - Dump & display memory range                                             *
;*     R - Dump & display 65C816 registers                                         *
;*     T - Copy (transfer) memory region                                           *
;*     X - Exit Supermon 816 & return to operating environment                     *
;*     > - Modify up to 32 bytes of memory                                         *
;*     ; - Modify 65C816 registers                                                 *
;*                                                                                 *
;* Supermon 816 accepts binary (%), octal (%), decimal (+) and hexadecimal ($) as  *
;* input for numeric parameters.  Additionally, the H and > operations accept an   *
;* ASCII string in place of numeric values by preceding the string with ', e.g.:   *
;*                                                                                 *
;*     h 042000 042FFF 'BCS Technology Limited                                     *
;*                                                                                 *
;* If no radix symbol is entered hex is assumed.                                   *
;*                                                                                 *
;* Numeric conversion is also available.  For example, typing:                     *
;*                                                                                 *
;*     +1234567 <CR>                                                               *
;*                                                                                 *
;* will display:                                                                   *
;*                                                                                 *
;*         $12D687                                                                 *
;*         +1234567                                                                *
;*         %04553207                                                               *
;*         %100101101011010000111                                                  *
;*                                                                                 *
;* In the above example, <CR> means the console keyboard's return or enter key.    *
;*                                                                                 *
;* All numeric values are internally processed as 32 bit unsigned integers.  Addr- *
;* esses may be entered as 8, 16 or 24 bit values.  During instruction assembly,   *
;* immediate mode operands may be forced to 16 bits by preceding the operand with  *
;* an exclamation point if the instruction can accept a 16 bit operand, e.g.:      *
;*                                                                                 *
;*     a 1f2000 lda !#4                                                            *
;*                                                                                 *
;* The above will assemble as:                                                     *
;*                                                                                 *
;*     A 1F2000  A9 04 00     LDA #$0004                                           *
;*                                                                                 *
;* Entering:                                                                       *
;*                                                                                 *
;*     a 1f2000 ldx !#+157                                                         *
;*                                                                                 *
;* will assemble as:                                                               *
;*                                                                                 *
;*     A 1F2000  A2 9D 00     LDX #$009D                                           *
;*                                                                                 *
;* Absent the ! in the operand field, the above would have been assembled as:      *
;*                                                                                 *
;*     A 1F2000  A2 9D        LDX #$9D                                             *
;*                                                                                 *
;* If an immediate mode operand is greater than $FF assembly of a 16 bit operand   *
;* is implied.                                                                     *
;* ------------------------------------------------------------------------------- *
;* A Note on the PEA & PEI Instructions                                            *
;* ------------------------------------                                            *
;*                                                                                 *
;* The Eyes and Lichty programming manual uses the following syntax for the PEA    *
;* and PEI instructions:                                                           *
;*                                                                                 *
;*     PEA <operand>                                                               *
;*     PEI (<operand>)                                                             *
;*                                                                                 *
;* The WDC data sheet that was published at the time of the 65C816's release in    *
;* 1984 does not indicate a recommended or preferred syntax for any of the above   *
;* instructions.  PEA pushes its operand to the stack and hence operates like any  *
;* other immediate mode instruction, in that the operand is the data (however, PEA *
;* doesn't affect the status register).  Similarly, PEI pushes the 16 bit value    *
;* stored at <operand> and <operand>+1, and hence operates like any other direct   *
;* (zero) page instruction, again without affecting the status register.           *
;*                                                                                 *
;* BCS Technology Limited is of the opinion that the developer of the ORCA/M as-   *
;* sembler, which is the assembler referred to in the Eyes and Lichty manual, mis- *
;* understood how PEA and PEI behave during runtime, and hence chose an incorrect  *
;* syntax for these two instructions.  This error was subsequently carried forward *
;* by Eyes and Lichty.                                                             *
;*                                                                                 *
;* Supermon 816's assembler uses the following syntax for PEA and PEI:             *
;*                                                                                 *
;*     PEA #<operand>                                                              *
;*     PEI <operand>                                                               *
;*                                                                                 *
;* The operand for PEA is treated as a 16 bit value, even if entered as an 8 bit   *
;* value.  The operand for PEI must be 8 bits.                                     *
;*                                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;	* * * * * * * * * * * *
;	* VERSION INFORMATION *
;	* * * * * * * * * * * *
;
softvers .macro                ;software version - change with each revision...
         .db "1"             ;major
         .db "."
         .db "0"             ;minor
         .db "."
         .db "2"             ;revision
         .endm
;
;REVISION TABLE
;
;Ver  Rev Date    Description
;-------------------------------------------------------------------------------
;1.0  2013/11/01  A) Original derived from the POC V1.1 single-board computer
;                    firmware.
;     2013/11/04  A) Fixed a problem where the B-accumulator wasn't always being
;                    be copied to shadow storage after return from execution of
;                    a J command.
;     2017/10/07  A) Converted to use WDC's 65816 assembler (D.WERNER)
;		  B) Adapt for the RBC 65c816 SBC
;		  C) Disable X command
;-------------------------------------------------------------------------------
;
;
;	        COMMENT ABBREVIATIONS
;	----------------------------------------------------
;	  BCD   binary-coded decimal
;	   DP   direct page or page zero
;	  EOF   end-of-field
;	  EOI   end-of-input
;	  LSB   least significant byte/bit
;	  LSD   least significant digit
;	  LSN   least significant nybble
;	  LSW   least significant word
;	  MPU   microprocessor
;	  MSB   most significant byte/bit
;	  MSD   most significant digit
;	  MSN   most significant nybble
;	  MSW   most-significant word
;	  RAM   random access memory
;	   WS   whitespace, i.e., blanks & horizontal tabs
;	----------------------------------------------------
;	A word is defined as 16 bits.
;
;	   MPU REGISTER SYMBOLS
;	--------------------------
;	   .A   accumulator LSB
;	   .B   accumulator MSB
;	   .C   16 bit accumulator
;	   .X   X-index
;	   .Y   Y-index
;	   DB   data bank
;	   DP   direct page
;	   PB   program bank
;	   PC   program counter
;	   SP   stack pointer
;	   SR   MPU status
;	----------------------------
;
;	  MPU STATUS REGISTER SYMBOLS
;	-------------------------------
;	    C   carry
;	    D   decimal mode
;	    I   maskable interrupts
;	    m   accumulator/memory size
;	    N   result negative
;	    V   sign overflow
;	    x   index registers size
;	    Z   result zero
;	-------------------------------
;
;================================================================================
;
;SYSTEM INTERFACE DEFINITIONS
;
;	------------------------------------------------------------------
;	This section defines the interface between Supermon 816 & the host
;	system.   Change these definitions to suit your system, but do not
;	change any label names.  All definitions must have valid values in
;	order to assemble Supermon 816.
;	------------------------------------------------------------------
;
;	--------------------------------------------------------
	;.org  $008000              ;assembly address...
SUPERMON 	SECTION 	OFFSET $8000
;
;	Set _ORIGIN_ to Supermon 816's desired assembly address.
;	--------------------------------------------------------
;
;	------------------------------------------------------------------------
;vecexit  .EQU $002000              ;exit to environment address...
;
;	Set VECEXIT to where Supermon 816 should go when it exits.  Supermon 816
;	will do a JML (long jump) to this address, which means VECEXIT must be a
;	24 bit address.
;	------------------------------------------------------------------------
;
;	------------------------------------------------------------------------
;
;getcha                  ;get keystroke from console...
;
;	GETCHA refers to an operating system API call that returns a keystroke
;	in the 8 bit accumulator.  Supermon 816  assumes that GETCHA is a non-
;	blocking subroutine & returns with carry clear to indicate that a key-
;	stroke is in .A, or with carry set to indicate that no keystroke was
;	available.  GETCHA will be called with a JSR instruction.
;
;	Supermon 816 expects .X & .Y to be preserved upon return from GETCHA.
;	You may have to modify Supermon 816 at all calls to GETCHA if your "get
;	keystroke" routine works differently than described.
;	------------------------------------------------------------------------
getcha 		.equ $FF74
CURSOR          .equ $FF86
UNCURSOR        .equ $FF89
;------------------------------------------------------------------------
;putcha   print character on console...
;
;	PUTCHA refers to an operating system API call that prints a character to
;	the console screen.  The character to be printed will be in .A, which
;	will be set to 8-bit width.  Supermon 816 assumes that PUTCHA will block
;	until the character can be processed.  PUTCHA will be called with a JSR
;	instructions.
;
;	Supermon 816 expects .X & .Y to be preserved upon return from PUTCHA.
;	You may have to modify Supermon 816 at all calls to PUTCHA if your "put
;	character" routine works differently than described.
;
putcha 		.equ $FF71
;
;	------------------------------------------------------------------------
;
;	------------------------------------------------------------------------
vecbrki  .EQU  $0302                ;BRK handler indirect vector...
;
;	Supermon 816 will modify this vector so that execution of a BRK instruc-
;	tion is intercepted & the registers  are  captured.   Your BRK front end
;	should jump through this vector after pushing the registers as follows:
;
;	         phb                   ;save DB
;	         phd                   ;save DP
;	         rep #%00110000        ;16 bit registers
;	         pha
;	         phx
;	         phy
;	         jmp (vecbrki)         ;indirect vector
;
;	When a G or J command is issued, the above sequence will be reversed be-
;	fore a jump is made to the code to be executed.  Upon exit from Supermon
;	816, the original address at VECBRKI will be restored.
;
;	If your BRK front end doesn't conform to the above you will have to mod-
;	ify Supermon 816 to accommodate the differences.  The most likely needed
;	changes will be in the order in which registers are pushed to the stack.
;	------------------------------------------------------------------------
;
;	------------------------------------------------------------------------
hwstack  .EQU $7FFF                ;top of hardware stack...
;
;	Supermon 816 initializes the stack pointer to this address when the cold
;	start at MONCOLD is called to enter the monitor.  The stack pointer will
;	be undisturbed when entry into Supermon 816 is through JMONBRK (see jump
;	table definitions).
;	------------------------------------------------------------------------
;
;	------------------------------------------------------------------------
zeropage .EQU $10                  ;Supermon 816's direct page...
;
;	Supermon 816 uses direct page starting at this address.  Be sure that no
;	conflict occurs with other software.
;	------------------------------------------------------------------------
;
;	------------------------------------------------------------------------
stopkey  .EQU $03                  ;display abort key...
;
;	Supermon 816 will poll for a "stop key" during display operations, such
;	as code disassembly & memory dumps, so as to abort further processing &
;	return to the command prompt.  STOPKEY must be defined with the ASCII
;	value that the "stop key" will emit when typed.  The polling is via a
;	call to GETCHA (described above).  The default STOPKEY definition of $03
;	is for ASCII <ETX> or [Ctrl-C].
;	------------------------------------------------------------------------
;
ibuffer  .EQU $000200               ;input buffer &...
auxbuf   .EQU ibuffer+s_ibuf+s_byte ;auxiliary buffer...
;
;	------------------------------------------------------------------------
;	Supermon 816 will use the above definitions for input buffers.  These
;	buffers may be located anywhere in RAM that is convenient.  The buffers
;	are stateless, which means that unless Supermon 816 has control of your
;	system, they may be overwritten without consequence.
;	------------------------------------------------------------------------
;
;================================================================================
;
;W65C816S INSTRUCTION SYNTHESIS MACROS -- !!!!! DO NOT EDIT !!!!!
;


_asm24_  .macro _ad
         .db <_ad,>_ad,_ad>>16
         .endm

;brl      .macro _ad
;_ba      =*+3
;         .db $82
;         .dw _ad-_ba
;         .endm
;
;jml      .macro _ad
;         .db $5c
;         _asm24_ _ad
;         .endm
;
;mvn      .macro _s,_d
;         .db $54,_d,_s
;         .endm
;
;mvp      .macro _s,_d
;         .db $44,_d,_s
;         .endm
;
;pea      .macro _op
;         .db $f4
;         .dw _op
;         .endm
;
;phb      .macro
;         .db $8b
;         .endm
;
;phk      .macro
;         .db $4b
;         .endm
;
;plb      .macro
;         .db $ab
;         .endm
;
;rep      .macro _op
;         .db $c2,_op
;         .endm
;
;sep      .macro _op
;         .db $e2,_op
;         .endm
;
;tcd      .macro
;         .db $5b
;         .endm
;
;tcs      .macro
;         .db $1b
;         .endm
;
;tdc      .macro
;         .db $7b
;         .endm
;
;tsc      .macro
;         .db $3b
;         .endm
;
;txy      .macro
;         .db $9b
;         .endm
;
;tyx      .macro
;         .db $bb
;         .endm
;
;wai      .macro
;         .db $cb
;        .endm
;
;xba      .macro
;         .db $eb
;         .endm
;
adcw     .macro _op
         adc #<_op
         .db >_op
         .endm
;
andw     .macro _op
         and #<_op
         .db >_op
         .endm
;
bitw     .macro _op
         bit #<_op
         .db >_op
         .endm
;
cmpw     .macro _op
         cmp #<_op
         .db >_op
         .endm
;
cpxw     .macro _op
         cpx #<_op
         .db >_op
         .endm
;
cpyw     .macro _op
         cpy #<_op
         .db >_op
         .endm
;
eorw     .macro _op
         eor #<_op
         .db >_op
         .endm
;
ldaw     .macro _op
         lda #<_op
         .db >_op
         .endm
;
ldxw     .macro _op
         ldx #<_op
         .db >_op
         .endm
;
ldyw     .macro _op
         ldy #<_op
         .db >_op
         .endm
;
oraw     .macro _op
         ora #<_op
         .db >_op
         .endm
;
sbcw     .macro _op
         sbc #<_op
         .db >_op
         .endm
;
ldalx    .macro _ad
         .db $bf
         _asm24_ _ad
         .endm
;
adcil    .macro _ad
         .db $67,_ad
         .endm
;
adcily   .macro _ad
         .db $77,_ad
         .endm
;
andil    .macro _ad
         .db $27,_ad
         .endm
;
andily   .macro _ad
         .db $37,_ad
         .endm
;
cmpil    .macro _ad
         .db $c7,_ad
         .endm
;
cmpily   .macro _ad
         .db $d7,_ad
         .endm
;
eoril    .macro _ad
         .db $47,_ad
         .endm
;
eorily   .macro _ad
         .db $57,_ad
         .endm
;
ldail    .macro _ad
         .db $a7,_ad
         .endm
;
ldaily   .macro _ad
         .db $b7,_ad
         .endm
;
orail    .macro _ad
         .db $07,_ad
         .endm
;
oraily   .macro _ad
         .db $17,_ad
         .endm
;
sbcil    .macro _ad
         .db $e7,_ad
         .endm
;
sbcily   .macro _ad
         .db $f7,_ad
         .endm
;
stail    .macro _ad
         .db $87,_ad
         .endm
;
staily   .macro _ad
         .db $97,_ad
         .endm
;
adcs     .macro _of
         .db $63,_of
         .endm
;
adcsi    .macro _of
         .db $73,_of
         .endm
;
ands     .macro _of
         .db $23,_of
         .endm
;
andsi    .macro _of
         .db $33,_of
         .endm
;
cmps     .macro _of
         .db $c3,_of
         .endm
;
cmpsi    .macro _of
         .db $d3,_of
         .endm
;
eors     .macro _of
         .db $43,_of
         .endm
;
eorsi    .macro _of
         .db $53,_of
         .endm
;
ldas     .macro _of
         .db $a3,_of
         .endm
;
ldasi    .macro _of
         .db $b3,_of
         .endm
;
oras     .macro _of
         .db $03,_of
         .endm
;
orasi    .macro _of
         .db $13,_of
         .endm
;
sbcs     .macro _of
         .db $e3,_of
         .endm
;
sbcsi    .macro _of
         .db $f3,_of
         .endm
;
stas     .macro _of
         .db $83,_of
         .endm
;
stasi    .macro _of
         .db $93,_of
         .endm
;
slonga    .macro
         .db $c2,$20
         .endm
;
longr    .macro
         .db $c2,$30
         .endm
;
longx    .macro
         .db $c2,$10
         .endm
;
shorta   .macro
         .db $e2,$20
         .endm
;
shorti   .macro
         .db $e2,$10
         .endm
;
shortr   .macro
         .db $e2,$30
         .endm
;
shortx   .macro
         .db $e2,$10
         .endm
;
;================================================================================
;
;CONSOLE DISPLAY CONTROL MACROS
;
;	------------------------------------------------------------------------
;	The following macros execute terminal  control procedures  that  perform
;	such tasks as clearing the screen,  switching  between  normal & reverse
;	video, etc.  These macros are for WYSE 60 & compatible displays, such as
;	the WYSE 150, WYSE 160, WYSE 325 & WYSE GPT.   Only the functions needed
;	by Supermon 816 are included.
;
;	If your console is not WYSE 60 compatible, you will need to  edit  these
;	macros as required to control your particular console or terminal.  Note
;	that in some cases one macro may call another.  Exercise caution in your
;	edits to avoid introducing display bugs.
;
;	If your console display cannot execute one of these procedures,  such as
;	'CL' (clear to end of line), you will have to develop an alternative.
;	------------------------------------------------------------------------
;
;
;
;	cursor control...
;
cr       .macro                ;carriage return
         .db a_cr
         .endm
;
lf       .macro                ;carriage return/line feed
         cr
         .db a_lf
         .endm
;
;	miscellaneous control...
;
rb       .macro                ;ring "bell"
         .db a_bel
         .endm
;
;
;================================================================================
;
;ASCII CONTROL DEFINITIONS (menmonic order)
;
a_bel    .equ $07                  ;<BEL> alert/ring bell
a_bs     .equ $08                  ;<BS>  backspace
a_cr     .equ $0d                  ;<CR>  carriage return
a_del    .equ $7f                  ;<DEL> delete
a_esc    .equ $1b                  ;<ESC> escape
a_ht     .equ $09                  ;<HT>  horizontal tabulation
a_lf     .equ $0a                  ;<LF>  linefeed
;
;
;	miscellaneous (description order)...
;
a_blank  .equ ' '                  ;blank (whitespace)
a_asclch .equ 'z'                  ;end of lowercase ASCII
a_lctouc .equ $5f                  ;LC to UC conversion mask
a_asclcl .equ 'a'                  ;start of lowercase ASCII
;
;================================================================================
;
;GLOBAL ATOMIC CONSTANTS
;
;
;	data type sizes...
;
s_byte   .equ 1                    ;byte
s_word   .equ 2                    ;word (16 bits)
s_xword  .equ 3                    ;extended word (24 bits)
s_dword  .equ 4                    ;double word (32 bits)
s_rampag .equ $0100                ;65xx RAM page
;
;
;	data type sizes in bits...
;
s_bibyte .equ 8                    ;byte
s_bnybbl .equ 4                    ;nybble
;
;
;	miscellaneous...
;
bitabs   .equ $2c                  ;absolute BIT opcode
bitzp    .equ $24                  ;zero page BIT opcode
;
;================================================================================
;
;W65C816S NATIVE MODE STATUS REGISTER DEFINITIONS
;
s_mpudbx .equ s_byte               ;data bank size
s_mpudpx .equ s_word               ;direct page size
s_mpupbx .equ s_byte               ;program bank size
s_mpupcx .equ s_word               ;program counter size
s_mpuspx .equ s_word               ;stack pointer size
s_mpusrx .equ s_byte               ;status size
;
;
;	status register flags...
;
sr_car   .equ %00000001            ;C
sr_zer   .equ sr_car<<1          ;Z
sr_irq   .equ sr_zer<<1          ;I
sr_bdm   .equ sr_irq<<1          ;D
sr_ixw   .equ sr_bdm<<1          ;x
sr_amw   .equ sr_ixw<<1          ;m
sr_ovl   .equ sr_amw<<1          ;V
sr_neg   .equ sr_ovl<<1          ;N
;
;	NVmxDIZC
;	xxxxxxxx
;	||||||||
;	|||||||+---> 1 = carry set/generated
;	||||||+----> 1 = result = zero
;	|||||+-----> 1 = IRQs ignored
;	||||+------> 0 = binary arithmetic mode
;	||||         1 = decimal arithmetic mode
;	|||+-------> 0 = 16 bit index
;	|||          1 = 8 bit index
;	||+--------> 0 = 16 bit .A & memory
;	||           1 = 8 bit .A & memory
;	|+---------> 1 = sign overflow
;	+----------> 1 = result = negative
;
;================================================================================
;
;"SIZE-OF" CONSTANTS
;
s_addr   .equ s_xword              ;24 bit address
s_auxbuf .equ 32                   ;auxiliary buffer
s_ibuf   .equ 69                   ;input buffer
s_mnemon .equ 3                    ;MPU ASCII mnemonic
s_mnepck .equ 2                    ;MPU encoded mnemonic
s_mvinst .equ 3                    ;MVN/MVP instruction
s_opcode .equ s_byte               ;MPU opcode
s_oper   .equ s_xword              ;operand
s_pfac   .equ s_dword              ;primary math accumulator
s_sfac   .equ s_dword+s_word       ;secondary math accumulators
;
;================================================================================
;
;"NUMBER-OF" CONSTANTS
;
n_dbytes .equ 21                   ;default disassembly bytes
n_dump   .equ 8                    ;bytes per memory dump line
n_mbytes .equ s_rampag-1           ;default memory dump bytes
n_hccols .equ 10                   ;compare/hunt display columns
n_opcols .equ 3*s_oper             ;disassembly operand columns
n_opslsr .equ 4                    ;LSRs to extract instruction size
n_shfenc .equ 5                    ;shifts to encode/decode mnemonic
;
;================================================================================
;
;NUMERIC CONVERSION CONSTANTS
;
a_hexdec .equ 'A'-'9'-2            ;hex to decimal difference
c_bin    .equ '%'                  ;binary prefix
c_dec    .equ '+'                  ;decimal prefix
c_hex    .equ '$'                  ;hexadecimal prefix
c_oct    .equ '@'                  ;octal prefix
k_hex    .equ 'f'                  ;hex ASCII conversion
m_bits   .equ s_pfac*s_bibyte      ;operand bit size
m_cbits  .equ s_sfac*s_bibyte      ;workspace bit size
bcdumask .equ %00001111            ;isolate BCD units mask
btoamask .equ %00110000            ;binary to ASCII mask
;
;================================================================================
;
;ASSEMBLER/DISASSEMBLER CONSTANTS
;
a_mnecvt .equ '?'                  ;encoded mnemonic conversion base
aimmaska .equ %00011111            ;.A immediate opcode test #1
aimmaskb .equ %00001001            ;.A immediate opcode test #2
asmprfx  .equ 'A'                  ;assemble code prefix
ascprmct .equ 9                    ;assembler prompt "size-of"
disprfx  .equ '.'                  ;disassemble code prefix
flimmask .equ %11000000            ;force long immediate flag
opc_cpxi .equ $e0                  ;CPX # opcode
opc_cpyi .equ $c0                  ;CPY # opcode
opc_ldxi .equ $a2                  ;LDX # opcode
opc_ldyi .equ $a0                  ;LDY # opcode
opc_mvn  .equ $54                  ;MVN opcode
opc_mvp  .equ $44                  ;MVP opcode
opc_rep  .equ $c2                  ;REP opcode
opc_sep  .equ $e2                  ;SEP opcode
pfmxmask .equ sr_amw|sr_ixw      ;MPU m & x flag bits mask
;
;
;	assembler prompt buffer offsets...
;
apadrbkh .equ s_word               ;instruction address bank MSN
apadrbkl .equ apadrbkh+s_byte      ;instruction address bank LSN
apadrmbh .equ apadrbkl+s_byte      ;instruction address MSB MSN
apadrmbl .equ apadrmbh+s_byte      ;instruction address MSB LSN
apadrlbh .equ apadrmbl+s_byte      ;instruction address LSB MSN
apadrlbl .equ apadrlbh+s_byte      ;instruction address LSB LSN
;
;
;	addressing mode preamble symbols...
;
amp_flim .equ '!'                  ;force long immediate
amp_imm  .equ '#'                  ;immediate
amp_ind  .equ '('                  ;indirect
amp_indl .equ '['                  ;indirect long
;
;
;	addressing mode symbolic translation indices...
;
am_nam   .equ %0000                ;no symbol
am_imm   .equ %0001                ;#
am_adrx  .equ %0010                ;<addr>,X
am_adry  .equ %0011                ;<addr>,Y
am_ind   .equ %0100                ;(<addr>)
am_indl  .equ %0101                ;[<dp>]
am_indly .equ %0110                ;[<dp>],Y
am_indx  .equ %0111                ;(<addr>,X)
am_indy  .equ %1000                ;(<dp>),Y
am_stk   .equ %1001                ;<offset>,S
am_stky  .equ %1010                ;(<offset>,S),Y
am_move  .equ %1011                ;<sbnk>,<dbnk>
;
;
;	operand size translation indices...
;
ops0     .equ %0000<<4           ;no operand
ops1     .equ %0001<<4           ;8 bit operand
ops2     .equ %0010<<4           ;16 bit operand
ops3     .equ %0011<<4           ;24 bit operand
bop1     .equ %0101<<4           ;8 bit relative branch
bop2     .equ %0110<<4           ;16 bit relative branch
vops     .equ %1001<<4           ;8 or 16 bit operand
;
;
;	operand size & addressing mode extraction masks...
;
amodmask .equ %00001111            ;addressing mode index
opsmask  .equ %00110000            ;operand size
vopsmask .equ %11000000            ;BOPx & VOPS flag bits
;
;
;	instruction mnemonic encoding...
;
mne_adc  .equ $2144                ;ADC
mne_and  .equ $2bc4                ;AND
mne_asl  .equ $6d04                ;ASL
mne_bcc  .equ $2106                ;BCC
mne_bcs  .equ $a106                ;BCS
mne_beq  .equ $9186                ;BEQ
mne_bit  .equ $aa86                ;BIT
mne_bmi  .equ $5386                ;BMI
mne_bne  .equ $33c6                ;BNE
mne_bpl  .equ $6c46                ;BPL
mne_bra  .equ $14c6                ;BRA
mne_brk  .equ $64c6                ;BRK
mne_brl  .equ $6cc6                ;BRL
mne_bvc  .equ $25c6                ;BVC
mne_bvs  .equ $a5c6                ;BVS
mne_clc  .equ $2348                ;CLC
mne_cld  .equ $2b48                ;CLD
mne_cli  .equ $5348                ;CLI
mne_clv  .equ $bb48                ;CLV
mne_cmp  .equ $8b88                ;CMP
mne_cop  .equ $8c08                ;COP
mne_cpx  .equ $cc48                ;CPX
mne_cpy  .equ $d448                ;CPY
mne_dec  .equ $218a                ;DEC
mne_dex  .equ $c98a                ;DEX
mne_dey  .equ $d18a                ;DEY
mne_eor  .equ $9c0c                ;EOR
mne_inc  .equ $23d4                ;INC
mne_inx  .equ $cbd4                ;INX
mne_iny  .equ $d3d4                ;INY
mne_jml  .equ $6b96                ;JML
mne_jmp  .equ $8b96                ;JMP
mne_jsl  .equ $6d16                ;JSL
mne_jsr  .equ $9d16                ;JSR
mne_lda  .equ $115a                ;LDA
mne_ldx  .equ $c95a                ;LDX
mne_ldy  .equ $d15a                ;LDY
mne_lsr  .equ $9d1a                ;LSR
mne_mvn  .equ $7ddc                ;MVN
mne_mvp  .equ $8ddc                ;MVP
mne_nop  .equ $8c1e                ;NOP
mne_ora  .equ $14e0                ;ORA
mne_pea  .equ $11a2                ;PEA
mne_pei  .equ $51a2                ;PEI
mne_per  .equ $99a2                ;PER
mne_pha  .equ $1262                ;PHA
mne_phb  .equ $1a62                ;PHB
mne_phd  .equ $2a62                ;PHD
mne_phk  .equ $6262                ;PHK
mne_php  .equ $8a62                ;PHP
mne_phx  .equ $ca62                ;PHX
mne_phy  .equ $d262                ;PHY
mne_pla  .equ $1362                ;PLA
mne_plb  .equ $1b62                ;PLB
mne_pld  .equ $2b62                ;PLD
mne_plp  .equ $8b62                ;PLP
mne_plx  .equ $cb62                ;PLX
mne_ply  .equ $d362                ;PLY
mne_rep  .equ $89a6                ;REP
mne_rol  .equ $6c26                ;ROL
mne_ror  .equ $9c26                ;ROR
mne_rti  .equ $5566                ;RTI
mne_rtl  .equ $6d66                ;RTL
mne_rts  .equ $a566                ;RTS
mne_sbc  .equ $20e8                ;SBC
mne_sec  .equ $21a8                ;SEC
mne_sed  .equ $29a8                ;SED
mne_sei  .equ $51a8                ;SEI
mne_sep  .equ $89a8                ;SEP
mne_sta  .equ $1568                ;STA
mne_stp  .equ $8d68                ;STP
mne_stx  .equ $cd68                ;STX
mne_sty  .equ $d568                ;STY
mne_stz  .equ $dd68                ;STZ
mne_tax  .equ $c8aa                ;TAX
mne_tay  .equ $d0aa                ;TAY
mne_tcd  .equ $292a                ;TCD
mne_tcs  .equ $a12a                ;TCS
mne_tdc  .equ $216a                ;TDC
mne_trb  .equ $1cea                ;TRB
mne_tsb  .equ $1d2a                ;TSB
mne_tsc  .equ $252a                ;TSC
mne_tsx  .equ $cd2a                ;TSX
mne_txa  .equ $166a                ;TXA
mne_txs  .equ $a66a                ;TXS
mne_txy  .equ $d66a                ;TXY
mne_tya  .equ $16aa                ;TYA
mne_tyx  .equ $ceaa                ;TYX
mne_wai  .equ $50b0                ;WAI
mne_wdm  .equ $7170                ;WDM
mne_xba  .equ $10f2                ;XBA
mne_xce  .equ $3132                ;XCE
;
;
;	encoded instruction mnemonic indices...
;
mne_adcx .equ 16                   ;ADC
mne_andx .equ 29                   ;AND
mne_aslx .equ 44                   ;ASL
mne_bccx .equ 15                   ;BCC
mne_bcsx .equ 65                   ;BCS
mne_beqx .equ 59                   ;BEQ
mne_bitx .equ 70                   ;BIT
mne_bmix .equ 36                   ;BMI
mne_bnex .equ 31                   ;BNE
mne_bplx .equ 42                   ;BPL
mne_brax .equ 5                    ;BRA
mne_brkx .equ 39                   ;BRK
mne_brlx .equ 43                   ;BRL
mne_bvcx .equ 23                   ;BVC
mne_bvsx .equ 68                   ;BVS
mne_clcx .equ 20                   ;CLC
mne_cldx .equ 27                   ;CLD
mne_clix .equ 35                   ;CLI
mne_clvx .equ 71                   ;CLV
mne_cmpx .equ 53                   ;CMP
mne_copx .equ 55                   ;COP
mne_cpxx .equ 78                   ;CPX
mne_cpyx .equ 88                   ;CPY
mne_decx .equ 18                   ;DEC
mne_dexx .equ 74                   ;DEX
mne_deyx .equ 84                   ;DEY
mne_eorx .equ 61                   ;EOR
mne_incx .equ 21                   ;INC
mne_inxx .equ 77                   ;INX
mne_inyx .equ 87                   ;INY
mne_jmlx .equ 40                   ;JML
mne_jmpx .equ 54                   ;JMP
mne_jslx .equ 45                   ;JSL
mne_jsrx .equ 63                   ;JSR
mne_ldax .equ 1                    ;LDA
mne_ldxx .equ 73                   ;LDX
mne_ldyx .equ 83                   ;LDY
mne_lsrx .equ 64                   ;LSR
mne_mvnx .equ 48                   ;MVN
mne_mvpx .equ 58                   ;MVP
mne_nopx .equ 56                   ;NOP
mne_orax .equ 6                    ;ORA
mne_peax .equ 2                    ;PEA
mne_peix .equ 33                   ;PEI
mne_perx .equ 60                   ;PER
mne_phax .equ 3                    ;PHA
mne_phbx .equ 10                   ;PHB
mne_phdx .equ 26                   ;PHD
mne_phkx .equ 38                   ;PHK
mne_phpx .equ 51                   ;PHP
mne_phxx .equ 75                   ;PHX
mne_phyx .equ 85                   ;PHY
mne_plax .equ 4                    ;PLA
mne_plbx .equ 11                   ;PLB
mne_pldx .equ 28                   ;PLD
mne_plpx .equ 52                   ;PLP
mne_plxx .equ 76                   ;PLX
mne_plyx .equ 86                   ;PLY
mne_repx .equ 49                   ;REP
mne_rolx .equ 41                   ;ROL
mne_rorx .equ 62                   ;ROR
mne_rtix .equ 37                   ;RTI
mne_rtlx .equ 46                   ;RTL
mne_rtsx .equ 67                   ;RTS
mne_sbcx .equ 14                   ;SBC
mne_secx .equ 19                   ;SEC
mne_sedx .equ 25                   ;SED
mne_seix .equ 34                   ;SEI
mne_sepx .equ 50                   ;SEP
mne_stax .equ 7                    ;STA
mne_stpx .equ 57                   ;STP
mne_stxx .equ 80                   ;STX
mne_styx .equ 89                   ;STY
mne_stzx .equ 91                   ;STZ
mne_taxx .equ 72                   ;TAX
mne_tayx .equ 82                   ;TAY
mne_tcdx .equ 24                   ;TCD
mne_tcsx .equ 66                   ;TCS
mne_tdcx .equ 17                   ;TDC
mne_trbx .equ 12                   ;TRB
mne_tsbx .equ 13                   ;TSB
mne_tscx .equ 22                   ;TSC
mne_tsxx .equ 79                   ;TSX
mne_txax .equ 8                    ;TXA
mne_txsx .equ 69                   ;TXS
mne_txyx .equ 90                   ;TXY
mne_tyax .equ 9                    ;TYA
mne_tyxx .equ 81                   ;TYX
mne_waix .equ 32                   ;WAI
mne_wdmx .equ 47                   ;WDM
mne_xbax .equ 0                    ;XBA
mne_xcex .equ 30                   ;XCE
;
;================================================================================
;
;MISCELLANEOUS CONSTANTS
;
halftab  .equ 4                    ;1/2 tabulation spacing
memprfx  .equ '>'                  ;memory dump prefix
memsepch .equ ':'                  ;memory dump separator
memsubch .equ '.'                  ;memory dump non-print char
srinit   .equ %00110000            ;SR initialization value
;
;================================================================================
;
;DIRECT PAGE STORAGE
;
reg_pbx  .equ zeropage             ;PB
reg_pcx  .equ reg_pbx+s_mpupbx     ;PC
reg_srx  .equ reg_pcx+s_mpupcx     ;SR
reg_ax   .equ reg_srx+s_mpusrx     ;.C
reg_xx   .equ reg_ax+s_word        ;.X
reg_yx   .equ reg_xx+s_word        ;.Y
reg_spx  .equ reg_yx+s_word        ;SP
reg_dpx  .equ reg_spx+s_mpuspx     ;DP
reg_dbx  .equ reg_dpx+s_mpudpx     ;DB
;
;
;	general workspace...
;
addra    .equ reg_dbx+s_mpudbx     ;address #1
addrb    .equ addra+s_addr         ;address #2
faca     .equ addrb+s_addr         ;primary accumulator
facax    .equ faca+s_pfac          ;extended primary accumulator
facb     .equ facax+s_pfac         ;secondary accumulator
facc     .equ facb+s_sfac          ;tertiary accumulator
operand  .equ facc+s_sfac          ;instruction operand
auxbufix .equ operand+s_oper       ;auxiliary buffer index
ibufidx  .equ auxbufix+s_byte      ;input buffer index
bitsdig  .equ ibufidx+s_byte       ;bits per numeral
numeral  .equ bitsdig+s_byte       ;numeral buffer
radix    .equ numeral+s_byte       ;radix index
admodidx .equ radix+s_byte         ;addressing mode index
charcnt  .equ admodidx+s_byte      ;character counter
instsize .equ charcnt+s_word       ;instruction size
mnepck   .equ instsize+s_word      ;encoded mnemonic
opcode   .equ mnepck+s_mnepck      ;current opcode
status   .equ opcode+s_byte        ;I/O status flag
xrtemp   .equ status+s_byte        ;temp .X storage
eopsize  .equ xrtemp+s_byte        ;entered operand size
flimflag .equ eopsize+s_byte       ;forced long immediate...
vecbrkia .equ flimflag+s_byte      ;system indirect BRK vector
;
;	xx000000
;	||
;	|+---------> 0: .X/.Y .equ  8 bits
;	|            1: .X/.Y .equ  18 bits
;	+----------> 0: .A .equ  8 bits
;	             1: .A .equ  16 bits
;
;	------------------------------------------------------------------------
;	During assembly, FLIMFLAG indicates the operand size used with an immed-
;	iate mode instruction, thus causing the following disassembly to display
;	the assembled  operand size.   During disassembly,  FLIMFLAG will mirror
;	the effect of the most recent REP or SEP instruction.
;	------------------------------------------------------------------------
;
iopsize  .equ flimflag+s_byte      ;operand size
range    .equ iopsize+s_byte       ;allowable radix range
vopsflag .equ range+s_byte         ;VOPS & ROPS mode bits
;
;
;	copy/fill workspace (overlaps some of the above)...
;
mcftwork .equ faca                 ;start of copy/fill code
mcftopc  .equ mcftwork+s_byte      ;instruction opcode
mcftbnk  .equ mcftopc+s_byte       ;banks
;
;================================================================================
;
;SUPERMON 816 JUMP TABLE
;
         *=_origin_
;
JMON     bra mon               ;cold start entry
JMONBRK  bra monbrk            ;software interrupt intercept
;
;
;================================================================================
;
;mon: SUPERMON 816 COLD START
;
mon

		     	REP #$10 		; 16 bit Index registers
	    	  LONGI ON
        	SEP #$20 		; 8 bit Accumulator
		      LONGA OFF
	    	  LDY   #$0000		; LOAD $00 INTO Y
OUTSTRLP:
        	LDA ALIVEM,Y   		; LOAD NEXT CHAR FROM STRING INTO ACC
        	CMP #$00		; IS NULL?
        	BEQ ENDOUTSTR		; YES, END PRINT OUT
        	JSR putcha  		; PRINT CHAR IN ACC
        	INY      		; Y=Y+1 (BUMP INDEX)
        	JMP OUTSTRLP		; DO NEXT CHAR
ENDOUTSTR:
          SEP #$10 		; 8 bit Index registers
		      LONGI OFF


          slonga
         lda vecbrki           ;BRK vector
         cmpw monbrk           ;pointing at monitor?
         bne moncontinue
         jmp monreg 		;yes, ignore cold start
;
moncontinue:
         sta vecbrkia          ;save vector for exit
         ldaw monbrk           ;Supermon 816 intercepts...
         sta vecbrki           ;BRK handler
         shortr                ;8 bit registers
         ldx #vopsflag-reg_pbx
;
_0000010 stz reg_pbx,x         ;clear DP storage
         dex
         bpl _0000010
;
;
;	initialize register shadows...
;
         lda #srinit
         sta reg_srx           ;status register
         slonga                 ;16 bit .A
         ldaw hwstack          ;top of hardware stack
         tcs                   ;set SP
         tdc                   ;get & save...
         sta reg_dpx           ;DP register
         ldaw 0
         shorta
         phk
         pla                   ;capture PB &...
         sta reg_pbx           ;set
         phb
         pla                   ;capture DB &...
         sta reg_dbx           ;set
;
;
;	print startup banner...
;
         pea mm_entry          ;"...ready..."
         bra moncom
;
;================================================================================
;
;monbrk: SOFTWARE INTERRUPT INTERCEPT
;
;	------------------------------------------------------------------------
;	This is the entry point taken when a BRK instruction is executed.  It is
;	assumed that the BRK  handler has pushed the registers to the stack that
;	are not automatically pushed by the MPU in response to BRK.
;	------------------------------------------------------------------------
;
monbrk
       	CLD			; VERIFY DECIMAL MODE IS OFF
	      CLC 			;
	      XCE 			; SET NATIVE MODE
        phb                     ;save DB
        phd                     ;save DP
        slonga                  ;16 bit .A
        pha
        ldaw $0000              ;set DPR
        tcd                     ;
        pla
        longr                 	;store 16 bit registers
        sta <reg_ax            	;.A
        stx <reg_xx            	;.X
        sty <reg_yx            	;.Y
        pla                   	;get DP &...
        sta <reg_dpx           	;store
        shortx
        plx                   	;get DB &...
        stx <reg_dbx           	;store
        plx                   	;get SR &...
        stx <reg_srx           	;store
        pla                   	;get PC &...
        sta <reg_pcx           	;store
        plx                   	;get PB &...
        stx <reg_pbx           	;store
        slonga
        ldaw hwstack            ;top of hardware stack
        tcs                     ;set SPR
       	cli                   	;reenable IRQs
        shorta
        lda #$00                ;set DBR
        pha
        PLB
        pea mm_brk              ;"*BRK"
;
;================================================================================
;
;moncom: COMMON ENTRY POINT
;
;	--------------------------------------
;	DO NOT directly call this entry point!
;	--------------------------------------
;
moncom   jsr sprint            ;print heading
         slonga
         tsc                   ;get SP &...
         sta <reg_spx           ;store
         rep #%11111111         ;clear SR &...
         sep #srinit            ;set default state
         sec                   ;see next
;
;================================================================================
;
;monreg: DISPLAY MPU REGISTERS
;
;	---------
;	syntax: R
;	---------
;
monreg   bcs _0010010          ;okay to proceed
;
         jmp monerr            ;error if called with a parm
;
_0010010 pea mm_regs
         jsr sprint            ;display heading
;
;
;	display program bank & counter...
;
         shorta
         lda <reg_pbx           ;PB
         jsr dpyhex            ;display as hex ASCII
         jsr printspc          ;inter-field space

         slonga
         lda <reg_pcx
         shorta
         jsr dpyhexw           ;display PC
         ldx #2
         jsr multspc           ;inter-field spacing
;
;
;	display SR in bitwise fashion...
;
         ldx <reg_srx           ;SR
         ldy #s_bibyte         ;bits in a byte
;
_0010020 txa                   ;remaining SR bits
         asl                   ;grab one of them
         tax                   ;save remainder
         lda #'0'              ;a clear bit but...
         adc #0                ;adjust if set &...
         jsr putcha            ;print
         dey                   ;bit processed
         bne _0010020          ;do another
;
;
;	display .C, .X, .Y, SP & DP...
;
_0010030 jsr printspc          ;spacing
         slonga
         lda reg_ax,y          ;get register value
         shorta
         jsr dpyhexw           ;convert & display

;         .rept s_word
           iny
           iny
;         .endr

         cpy #reg_dbx-reg_ax-2
         bcc _0010030          ;next

         pea mm_regs1
         jsr sprint            ;display heading
         slonga
         lda <reg_dpx          ;get register value
         shorta
         jsr dpyhexw           ;convert & display
;
;
;	display DB...
;
         jsr printspc          ;more spacing
         lda <reg_dbx           ;get DB &...
         jsr dpyhex            ;display it
;
;================================================================================
;
;monce: COMMAND EXECUTIVE
;
monce    shorta
         lda #0                ;default buffer index
;
moncea   shortr                ;alternate entry point
         sta ibufidx           ;(re)set buffer index
         pea mm_prmpt
         jsr sprint            ;display input prompt
         jsr input             ;await some input
;
_0020010 jsr getcharc          ;read from buffer
         beq monce             ;terminator, just loop
;
         cmp #a_blank
         beq _0020010          ;strip leading blanks
;
         ldx #n_mpctab-1       ;number of primary commands
;
_0020020 cmp mpctab,x          ;search primary command list
         bne _0020030
;
         txa                   ;get index
         asl                   ;double for offset
         tax
         slonga
         lda mpcextab,x        ;command address -1
         pha                   ;prime the stack
         shorta
         jmp getparm           ;evaluate parm & execute command
;
_0020030 dex
         bpl _0020020          ;continue searching primary commands
;
         ldx #n_radix-1        ;number of radices
;
_0020040 cmp radxtab,x         ;search conversion command list
         bne _0020050
;
         jmp monenv            ;convert & display parameter
;
_0020050 dex
         bpl _0020040
;
;================================================================================
;
;monerr: COMMON ERROR HANDLER
;
monerr   shortr                ;8 bit registers
;
monerraa jsr dpyerr            ;indicate an error &...
         bra monce             ;return to input loop

;
;================================================================================
;
;monasc: ASSEMBLE CODE
;
;	-----------------------------------------------------------------------
;	syntax: A <addr> <mnemonic> [<argument>]
;
;	After a line of code has been successfully assembled it will be disass-
;	embled & displayed,  & the monitor will prompt with the next address to
;	which code may be assembled.
;	-----------------------------------------------------------------------
;
monasc   bcc _0030020          ;assembly address entered
;
_0030010 jmp monerr            ;terminate w/error
;
;
;	evaluate assembly address...
;
_0030020 jsr facasize          ;check address...
         cmp #s_dword          ;range
         bcs _0030010          ;out of range - error
;
         jsr facaddra          ;store assembly address
;
;
;	initialize workspace...
;
         ldx #s_auxbuf-s_byte
;
_0030030 stz auxbuf,x          ;clear addressing mode buffer
         dex
         bne _0030030
;
         lda #a_blank
         sta auxbuf            ;preamble placeholder
         jsr clroper           ;clear operand
         stz auxbufix          ;reset addressing mode index
         stz flimflag          ;clear forced long immediate
         stz mnepck            ;clear encoded...
         stz mnepck+s_byte     ;mnemonic workspace
         stz vopsflag          ;clear 8/16 or relative flag
;
;
;	encode mnemonic...
;
         ldy #s_mnemon         ;expected mnemonic size
;
_0030040 jsr getcharw          ;get from buffer wo/whitespace
         bne _0030060          ;gotten
;
         cpy #s_mnemon         ;any input at all?
         bcc _0030050          ;yes
;
         jmp monce             ;no, abort further assembly
;
_0030050 jmp monasc10          ;incomplete mnemonic - error
;
_0030060 sec
         sbc #a_mnecvt         ;ASCII to binary factor
         ldx #n_shfenc         ;shifts required to encode
;
_0030070 lsr                   ;shift out a bit...
         ror mnepck+s_byte     ;into...
         ror mnepck            ;encoded mnemonic
         dex
         bne _0030070          ;next bit
;
         dey
         bne _0030040          ;get next char
;
;
;	test for copy instruction...
;	------------------------------------------------------------------------
;	The MVN & MVP instructions accept two operands & hence have an irregular
;	syntax.  Therefore, special handling is necessary to assemble either of
;	these instructions.
;
;	The official WDC syntax has the programmer entering a pair of 24 bit ad-
;	dresses as operands, with the assembler isolating bits 16-23 to	use as
;	operands.  This formality has been dispensed with in this monitor & the
;	operands are expected to be 8 bit bank values.
;	------------------------------------------------------------------------
;
         slonga                 ;16 bit load
         lda mnepck            ;packed menmonic
         ldx #opc_mvn          ;MVN opcode
         cmpw mne_mvn          ;is it MVN?
         beq monasc01          ;yes
;
         ldx #opc_mvp          ;MVP opcode
         cmpw mne_mvp          ;is it MVP?
         bne monasc02          ;no
;
;
;	assemble copy instruction...
;
monasc01 stx opcode            ;store relevant opcode
         shorta
         jsr instdata          ;get instruction data
         stx eopsize           ;effective operand size
         inx
         stx instsize          ;instruction size
         ldx #s_oper-s_word    ;operand index
         stx xrtemp            ;set it
;
_0040010 jsr ascbin            ;evaluate bank number
         bcs monasc04          ;conversion error
;
         beq monasc04          ;nothing returned - error
;
         jsr facasize          ;bank must be...
         cmp #s_word           ;8 bits
         bcs monasc04          ;it isn't - error
;
         lda faca              ;bank
         ldx xrtemp            ;operand index
         sta operand,x         ;store
         dec xrtemp            ;index=index-1
         bpl _0040010          ;get destination bank
;
         jsr getcharr          ;should be no more input
         bne monasc04          ;there is - error
;
         jmp monasc08          ;finish MVN/MVP assembly
;
;
;	continue with normal assembly...
;
monasc02 shorta                ;back to 8 bits
;
monasc03 jsr getcharw          ;get next char
         beq monasc06          ;EOI, no argument
;
         cmp #amp_flim
         bne _0050010          ;no forced long immediate
;
         lda flimflag          ;FLIM already set?
         bne monasc04          ;yes - error
;
         lda #flimmask
         sta flimflag          ;set flag &...
         bra monasc03          ;get next char
;
_0050010 cmp #amp_imm          ;immediate mode?
         beq _0050020          ;yes
;
         cmp #amp_ind          ;indirect mode?
         beq _0050020          ;yes
;
         cmp #amp_indl         ;indirect long mode?
         bne _0050030          ;no
;
_0050020 sta auxbuf            ;set addressing mode preamble
         inc auxbufix          ;bump aux buffer index &...
         bra _0050040          ;evaluate operand
;
_0050030 dec ibufidx           ;position back to char
;
_0050040 jsr ascbin            ;evaluate operand
         bne monasc05          ;evaluated
;
         bcs monasc04          ;conversion error
;
         lda auxbufix          ;no operand...any preamble?
         beq monasc06          ;no, syntax is okay so far
;
monasc04 jmp monasc10          ;abort w/error
;
monasc05 jsr facasize          ;size operand
         cmp #s_dword          ;max is 24 bits
         bcs monasc04          ;too big
;
         sta eopsize           ;save operand size
         jsr facaoper          ;store operand
;
monasc06 dec ibufidx           ;back to last char
         ldx auxbufix          ;mode buffer index
         bne _0060010          ;preamble in buffer
;
         inx                   ;step past preamble position
;
_0060010 jsr getcharc          ;get a char w/forced UC
         beq _0060030          ;EOI
;
         cpx #s_auxbuf         ;mode buffer full?
         bcs monasc04          ;yes, too much input
;
_0060020 sta auxbuf,x          ;store for comparison
         inx
         bne _0060010
;
;
;	evaluate mnemonic...
;
_0060030 ldx #n_mnemon-1       ;starting mnemonic index
;
monasc07 txa                   ;convert index...
         asl                   ;to offset
         tay                   ;now mnemonic table index
         slonga                 ;16 bit compare
         lda mnetab,y          ;get mnemonic from table
         cmp mnepck            ;compare to entered mnemonic
         shorta                ;back to 8 bits
         beq _0070020          ;match
;
_0070010 dex                   ;try next mnemonic
         bmi monasc04          ;unknown mnemonic - error
;
         bra monasc07          ;keep going
;
_0070020 stx mnepck            ;save mnemonic index
         txa
         ldx #0                ;trial opcode
;
_0070030 cmp mnetabix,x        ;search index table...
         beq _0070050          ;for a match
;
_0070040 inx                   ;keep going until we...
         bne _0070030          ;search entire table
;
         bra monasc04          ;this shouldn't happen!
;
;	---------------------------------------------------------------------
;	If the mnemonic index table search fails then there is a coding error
;	somewhere, as every entry in the mnemonic table is supposed to have a
;	matching cardinal index.
;	---------------------------------------------------------------------
;
;
;	evaluate addressing mode...
;
_0070050 stx opcode            ;save trial opcode
         jsr instdata          ;get related instruction data
         sta vopsflag          ;save 8/16 or relative flag
         stx iopsize           ;operand size
         inx
         stx instsize          ;instruction size
         ldx opcode            ;recover trial opcode
         tya                   ;addressing mode
         asl                   ;create table index
         tay
         slonga
         lda ms_lutab,y        ;mode lookup table
         sta addrb             ;set pointer
         shorta
         ldy #0
;
_0070060 lda (addrb),y         ;table addressing mode
         cmp auxbuf,y          ;entered addressing mode
         beq _0070080          ;okay so far
;
_0070070 lda mnepck            ;reload mnemonic index
         bra _0070040          ;wrong opcode for addresing mode
;
_0070080 ora #0                ;last char the terminator?
         beq _0070090          ;yes, evaluate operand
;
         iny
         bra _0070060          ;keep testing
;
;
;	evaluate operand...
;
_0070090 lda eopsize           ;entered operand size
         bne _0070100          ;non-zero
;
         ora iopsize           ;instruction operand size
         bne _0070070          ;wrong opcode - keep trying
;
         bra monasc08          ;assemble instruction
;
_0070100 bit vopsflag          ;is this a branch?
         bvs _0070160          ;yes, evaluate
;
         lda iopsize           ;instruction operand size
         bit vopsflag          ;variable size operand allowed?
         bmi _0070130          ;yes
;
         bit flimflag          ;was forced immediate set?
         bpl _0070110          ;no
;
         jmp monasc10          ;yes - error
;
_0070110 cmp eopsize           ;entered operand size
         bcc _0070070          ;operand too big
;
         sta eopsize           ;new operand size
         bra monasc08          ;assemble, otherwise...
;
_0070120 cmp eopsize           ;exact size match required
         bne _0070070          ;mismatch - wrong opcode
;
         bra monasc08          ;assemble
;
;
;	process variable size immediate mode operand...
;
_0070130 ldx eopsize           ;entered operand size
         cpx #s_xword          ;check size
         bcs monasc10          ;too big - error
;
         bit flimflag          ;forced long immediate?
         bpl _0070140          ;no
;
         ldx #s_word           ;promote operand size to...
         stx eopsize           ;16 bits
         bra _0070150
;
_0070140 cpx #s_word           ;16 bits?
         bne _0070150          ;no
;
         ldy #flimmask         ;yes so force long...
         sty flimflag          ;immediate disassembly
;
_0070150 ina                   ;new instruction operand size
         cmp eopsize           ;compare against operand size
         bcc _0070070          ;mismatch - can't assemble
;
         bra monasc08          ;okay, assemble
;
;
;	process relative branch...
;
_0070160 jsr targoff           ;compute branch offset
         bcs monasc10          ;branch out of range
;
         sta eopsize           ;effective operand size
;
;
;	assemble instruction...
;
monasc08 lda opcode            ;opcode
         stail addra           ;store at assembly address
         ldx eopsize           ;any operand to process?
         beq _0080020          ;no
;
         txy                   ;also storage offset
;
_0080010 dex
         lda operand,x         ;get operand byte &...
         staily addra          ;poke into memory
         dey
         bne _0080010          ;next
;
_0080020 lda #a_cr
         jsr putcha            ;return to left margin
         lda #asmprfx          ;assembly prefix
         jsr dpycodaa          ;disassemble & display
;
;
;	prompt for next instruction...
;
monasc09 lda #a_blank
         ldx #ascprmct-1
;
_0090010 sta ibuffer,x         ;prepare buffer for...
         dex                   ;next instruction
         bpl _0090010
;
         lda #asmprfx          ;assemble code...
         sta ibuffer           ;prompt prefix
         lda addra+s_word      ;next instruction address bank
         jsr binhex            ;convert to ASCII
         sta ibuffer+apadrbkh  ;store MSN in buffer
         stx ibuffer+apadrbkl  ;store LSN in buffer
         lda addra+s_byte      ;next instruction address MSB
         jsr binhex
         sta ibuffer+apadrmbh
         stx ibuffer+apadrmbl
         lda addra             ;next instruction address LSB
         jsr binhex
         sta ibuffer+apadrlbh
         stx ibuffer+apadrlbl
         lda #ascprmct         ;effective input count
         jmp moncea            ;reenter input loop
;
;
;	process assembly error...
;
monasc10 jsr dpyerr            ;indicate error &...
         bra monasc09          ;prompt w/same assembly address
;
;================================================================================
;
;mondsc: DISASSEMBLE CODE
;
;	-----------------------------
;	syntax: D [<addr1> [<addr2>]]
;	-----------------------------
;
mondsc   bcs _0100010          ;no parameters
;
         stz flimflag          ;reset to 8 bit mode
         jsr facasize          ;check starting...
         cmp #s_dword          ;address
         bcs _0100050          ;out of range - error
;
         jsr facaddra          ;copy starting address
         jsr getparm           ;get ending address
         bcc _0100020          ;gotten
;
_0100010 jsr clrfaca           ;clear accumulator
         slonga
         clc
         lda addra             ;starting address
         adcw n_dbytes         ;default bytes
         sta faca              ;effective ending address
         shorta
         lda addra+s_word      ;starting bank
         adc #0
         sta faca+s_word       ;effective ending bank
         bcs _0100050          ;end address > $FFFFFF
;
_0100020 jsr facasize          ;check ending...
         cmp #s_dword          ;address
         bcs _0100050          ;out of range - error
;
         jsr facaddrb          ;set ending address
         jsr getparm           ;check for excess input
         bcc _0100050          ;present - error
;
         jsr calccnt           ;calculate bytes
         bcc _0100050          ;end < start
;
_0100030 jsr teststop          ;test for display stop
         bcs _0100040          ;stopped
;
         jsr newline           ;next line
         jsr dpycod            ;disassemble & display
         jsr decdcnt           ;decrement byte count
         bcc _0100030          ;not done
;
_0100040 jmp monce             ;back to main loop
;
_0100050 jmp monerr            ;address range error
;
;================================================================================
;
;monjmp: EXECUTE CODE
;
;	-------------------------------------------------------------
;	syntax: G [<dp>]
;
;	If no address is specified, the current values in the PB & PC
;	shadow registers are used.
;	-------------------------------------------------------------
;
monjmp   jsr setxaddr          ;set execution address
         bcs monjmpab          ;out of range - error
;
         jsr getparm           ;check for excess input
         bcc monjmpab          ;too much input - error
;
         slonga                 ;16 bit .A
         lda reg_spx
         tcs                   ;restore SP
;
monjmpaa shorta
         lda reg_pbx
         pha                   ;restore PB
         slonga
         lda reg_pcx
         pha                   ;restore PC
         shorta
         lda reg_srx
         pha                   ;restore SR
         lda reg_dbx
         pha
         plb                   ;restore DB
         longr
         lda reg_dpx
         tcd                   ;restore DP
         lda reg_ax            ;restore .C
         ldx reg_xx            ;restore .X
         ldy reg_yx            ;restore .Y
         rti                   ;execute code
;
monjmpab jmp monerr            ;error
;
;================================================================================
;
;monjsr: EXECUTE CODE AS SUBROUTINE
;
;	------------------------------------------------------------
;	syntax: J [<dp>]
;
;	If no address is specified the current values in the PB & PC
;	shadow registers are used.   An RTS at the end of the called
;	subroutine will return control to the monitor  provided  the
;	stack remains in balance.
;	------------------------------------------------------------
;
monjsr   jsr setxaddr          ;set execution address
         bcs monjmpab          ;out of range - error
;
         jsr getparm           ;check for excess input
         bcc monjmpab          ;too much input - error
;
         slonga
         lda reg_spx
         tcs                   ;restore SP &...
         jsr monjmpaa          ;call subroutine
         php                   ;push SR
         longr
         sta reg_ax            ;save...
         stx reg_xx            ;register...
         sty reg_yx            ;returns
         shortx                ;8 bit .X & .Y
         plx                   ;get & save...
         stx reg_srx           ;return SR
         tsc                   ;get & save...
         sta reg_spx           ;return SP
         tdc                   ;get & save...
         sta reg_dpx           ;DP pointer
         shorta                ;8 bit .A
         phk                   ;get &...
         pla                   ;save...
         sta reg_pbx           ;return PB
         phb                   ;get &...
         pla                   ;save...
         sta reg_dbx           ;return DB
         pea mm_rts            ;"*RET"
         jmp moncom            ;return to monitor
;
;================================================================================
;
;monchm: CHANGE and/or DUMP MEMORY
;
;	--------------------------------------------
;	syntax: > [<addr> <operand> [<operand>]...]
;
;	> <addr> without operands will dump 16 bytes
;	of memory, starting at <addr>.
;	--------------------------------------------
;
monchm   bcs _0110030          ;no address given - quit
;
         jsr facasize          ;size address
         cmp #s_dword
         bcs _0110040          ;address out of range - error
;
         jsr facaddra          ;set starting address
         jsr getpat            ;evaluate change pattern
         bcc _0110010          ;entered
;
         bpl _0110020          ;not entered
;
         bra _0110040          ;evaluation error
;
_0110010 dey                   ;next byte
         bmi _0110020          ;done
;
         lda auxbuf,y          ;write pattern...
         staily addra          ;to memory
         bra _0110010          ;next
;
_0110020 jsr newline           ;next line
         jsr dpymem            ;regurgitate changes
;
_0110030 jmp monce             ;back to command loop
;
_0110040 jmp monerr            ;goto error handler
;
;================================================================================
;
;moncmp: COMPARE MEMORY
;
;	-----------------------------
;	syntax: C <start> <end> <ref>
;	-----------------------------
;
moncmp   bcs _0120030          ;start not given - quit
;
         jsr enddest           ;get end & reference addresses
         bcs _0120040          ;range or other error
;
         stz xrtemp            ;column counter
;
_0120010 jsr teststop          ;check for stop
         bcs _0120030          ;abort
;
         ldail addra           ;get from reference location
         cmpil operand         ;test against compare location
         beq _0120020          ;match, don't display address
;
         jsr dpycaddr          ;display current location
;
_0120020 jsr nxtaddra          ;next reference location
         bcs _0120030          ;done
;
         slonga
         inc operand           ;bump bits 0-15
         shorta
         bne _0120010
;
         inc operand+s_word    ;bump bits 16-23
         bra _0120010
;
_0120030 jmp monce             ;return to command exec
;
_0120040 jmp monerr            ;goto error handler
;
;================================================================================
;
;moncpy: COPY (transfer) MEMORY
;
;	--------------------------------
;	syntax: T <start> <end> <target>
;	--------------------------------
;
moncpy   bcs _0130040          ;start not given - quit
;
         jsr enddest           ;get end & target addresses
         bcs _0130050          ;range or other error
;
         slonga
         sec
         lda addrb             ;ending address
         sbc addra             ;starting address
         bcc _0130050          ;start > end - error
;
         sta facb              ;bytes to copy
         shorta
         longx
         lda operand+s_word    ;target bank
         ldy operand           ;target address
         cmp addra+s_word      ;source bank
         slonga
         bne _0130020          ;can use forward copy
;
         cpy addra             ;source address
         bcc _0130020          ;can use forward copy
;
         bne _0130010          ;must use reverse copy
;
         bra _0130050          ;copy in place - error
;
_0130010 lda facb              ;get bytes to copy
         pha                   ;protect
         jsr lodbnk            ;load banks
         jsr cprvsup           ;do reverse copy setup
         pla                   ;get bytes to copy
         tax                   ;save a copy
         clc
         adc operand           ;change target to...
         tay                   ;target end
         txa                   ;recover bytes to copy
         ldx addrb             ;source end
         bra _0130030
;
_0130020 lda facb              ;get bytes to copy
         pha                   ;protect
         jsr lodbnk            ;load banks
         jsr cpfwsup           ;do forward copy setup
         pla                   ;get bytes to copy
         ldx addra             ;source start
;
_0130030 jmp mcftwork          ;copy memory
;
_0130040 jmp monce             ;back to executive
;
_0130050 jmp monerr            ;error
;
;================================================================================
;
;mondmp: DISPLAY MEMORY RANGE
;
;	-----------------------------
;	syntax: M [<addr1> [<addr2>]]
;	-----------------------------
;
mondmp   bcs _0140010          ;no parameters
;
         jsr facasize          ;check address...
         cmp #s_dword          ;range
         bcs _0140050          ;address out of range
;
         jsr facaddra          ;copy starting address
         jsr getparm           ;get ending address
         bcc _0140020          ;gotten
;
_0140010 jsr clrfaca           ;clear accumulator
         slonga
         clc
         lda addra             ;starting address
         adcw n_mbytes         ;default bytes
         sta faca              ;effective ending address
         shorta
         lda addra+s_word      ;starting bank
         adc #0
         sta faca+s_word       ;effective ending bank
         bcs _0140050          ;end address > $FFFFFF
;
_0140020 jsr facasize          ;check ending address...
         cmp #s_dword          ;range
         bcs _0140050          ;out of range - error
;
         jsr facaddrb          ;copy ending address
         jsr getparm           ;check for excess input
         bcc _0140050          ;error
;
         jsr calccnt           ;calculate bytes to dump
         bcc _0140050          ;end < start
;
_0140030 jsr teststop          ;test for display stop
         bcs _0140040          ;stopped
;
         jsr newline           ;next line
         jsr dpymem            ;display
         jsr decdcnt           ;decrement byte count
         bcc _0140030          ;not done
;
_0140040 jmp monce             ;back to main loop
;
_0140050 jmp monerr            ;address range error
;
;================================================================================
;
;monfil: FILL MEMORY
;
;	-----------------------------------------
;	syntax: F <start> <end> <fill>
;
;	<start> & <end> must be in the same bank.
;	-----------------------------------------
;
monfil   bcs _0150010          ;start not given - quit
;
         jsr facasize          ;check size
         cmp #s_dword
         bcs _0150020          ;out of range - error...
;
         jsr facaddra          ;store start
         jsr getparm           ;evaluate end
         bcs _0150020          ;not entered - error
;
         jsr facasize          ;check size
         cmp #s_dword
         bcs _0150020          ;out of range - error
;
         lda faca+s_word       ;end bank
         cmp addra+s_word      ;start bank
         bne _0150020          ;not same - error
;
         jsr facaddrb          ;store <end>
         slonga
         sec
         lda addrb             ;ending address
         sbc addra             ;starting address
         bcc _0150020          ;start > end - error
;
         sta facb              ;bytes to copy
         shorta
         jsr getparm           ;evaluate <fill>
         bcs _0150020          ;not entered - error
;
         jsr facasize          ;<fill> should be...
         cmp #s_word           ;8 bits
         bcs _0150020          ;it isn't - error
;
         jsr facaoper          ;store <fill>
         jsr getparm           ;should be no more parameters
         bcc _0150020          ;there are - error
;
         lda operand           ;<fill>
         stail addra           ;fill 1st location
         longr                 ;16 bit operations
         lda facb              ;get byte count
         beq _0150010          ;only 1 location - finished
;
         dea                   ;zero align &...
         pha                   ;protect
         shorta
         lda addra+s_word      ;start bank
         xba
         lda addrb+s_word      ;end bank
         jsr cpfwsup           ;do forward copy setup
         pla                   ;recover fill count
         ldx addra             ;fill-from starting location
         txy
         iny                   ;fill-to starting location
         jmp mcftwork          ;fill memory
;
_0150010 jmp monce             ;goto command executive
;
_0150020 jmp monerr            ;goto error handler
;
;================================================================================
;
;monhnt: SEARCH (hunt) MEMORY
;
;	-----------------------------------
;	syntax: H <addr1> <addr2> <pattern>
;	-----------------------------------
;
monhnt   bcs _0160050          ;no start address
;
         jsr facasize          ;size starting address
         cmp #s_dword
         bcs _0160060          ;address out of range - error
;
         jsr facaddra          ;store starting address
         jsr getparm           ;evaluate ending address
         bcs _0160060          ;no address - error
;
         jsr facasize          ;size ending address
         cmp #s_dword
         bcs _0160060          ;address out of range - error
;
         jsr facaddrb          ;store ending address
         jsr calccnt           ;calculate byte range
         bcc _0160060          ;end < start
;
         jsr getpat            ;evaluate search pattern
         bcs _0160060          ;error
;
         stz xrtemp            ;clear column counter
;
_0160010 jsr teststop          ;check for stop
         bcs _0160050          ;abort
;
         ldy auxbufix          ;pattern index
;
_0160020 dey
         bmi _0160030          ;pattern match
;
         ldaily addra          ;get from memory
         cmp auxbuf,y          ;test against pattern
         bne _0160040          ;mismatch, next location
;
         beq _0160020          ;match, keep testing
;
_0160030 jsr dpycaddr          ;display current location
;
_0160040 jsr nxtaddra          ;next location
         bcc _0160010          ;not done
;
_0160050 jmp monce             ;back to executive
;
_0160060 jmp monerr            ;goto error handler
;
;================================================================================
;
;monenv: CONVERT NUMERIC VALUE
;
;	----------------------
;	syntax: <radix><value>
;	----------------------
;
monenv   jsr getparmr          ;reread & evaluate parameter
         bcs _0170020          ;none entered
;
         ldx #0                ;radix index
         ldy #n_radix          ;number of radices
;
_0170010 phy                   ;save counter
         phx                   ;save radix index
         jsr newline           ;next line &...
         jsr clearlin          ;clear it
         lda #a_blank
         ldx #halftab
         jsr multspc           ;indent 1/2 tab
         plx                   ;get radix index but...
         phx                   ;put it back
         lda radxtab,x         ;get radix
         jsr binasc            ;convert to ASCII
         phy                   ;string address MSB
         phx                   ;string address LSB
         jsr sprint            ;print
         plx                   ;get index again
         ply                   ;get counter
         inx
         dey                   ;all radices handled?
         bne _0170010          ;no

_0170020 jmp monce             ;back to command exec
;
;================================================================================
;
;monchr: CHANGE REGISTERS
;
;	------------------------------------------------------
;	syntax: ; [PB [PC [.S [.C [.X [.Y [SP [DP [DB]]]]]]]]]
;
;	; with no parameters is the same as the R command.
;	------------------------------------------------------
;
monchr   bcs _0570040          ;dump registers & quit
;
         ldy #0                ;register counter
         sty facc              ;initialize register index
;
_0570010 jsr facasize          ;get parameter size
         cmp rcvltab,y         ;check against size table
         bcs _0570050          ;out of range
;
         lda rcvltab,y         ;determine number of bytes...
         cmp #s_word+1         ;to store
         ror facc+s_byte       ;condition flag
         bpl _0570020          ;8 bit register size
;
         slonga                 ;16 bit register size
;
_0570020 ldx facc              ;get register index
         lda faca              ;get parm
         sta reg_pbx,x         ;put in shadow storage
         shorta
         asl facc+s_byte       ;mode flag to carry
         txa                   ;register index
         adc #s_byte           ;at least 1 byte stored
         sta facc              ;save new index
         jsr getparm           ;get a parameter
         bcs _0570040          ;EOI
;
         iny                   ;bump register count
         cpy #n_regchv         ;all registers processed?
         bne _0570010          ;no, keep going
;
_0570030 jsr alert             ;excessive input
;
_0570040 jmp monreg            ;display changes
;
_0570050 jmp monerr            ;goto error handler
;
;================================================================================
;
;monxit: EXIT TO OPERATING ENVIRONMENT
;
;	---------
;	syntax: X
;	---------
;
;monxit   bcc _0180020          ;no parameters allowed
;
;         slonga
;        lda vecbrki           ;BRK indirect vector
;         cmpw monbrk           ;we intercept it?
;         bne _0180010          ;no, don't change it
;
;         lda vecbrkia          ;old vector
;         sta vecbrki           ;restore it
;         stz vecbrkia          ;invalidate old vector
;
;_0180010 shortr
;         jml vecexit           ;long jump to exit
;
;_0180020 jmp monerr            ;goto error handler
;
; * * * * * * * * * * * * * * * * * * * * * * * *
; * * * * * * * * * * * * * * * * * * * * * * * *
; * *                                         * *
; * * S T A R T   o f   S U B R O U T I N E S * *
; * *                                         * *
; * * * * * * * * * * * * * * * * * * * * * * * *
; * * * * * * * * * * * * * * * * * * * * * * * *
;
;dpycaddr: DISPLAY CURRENT ADDRESS IN COLUMNS
;
dpycaddr ldx xrtemp            ;column count
         bne _0190010          ;not at right side
;
         jsr newline           ;next row
         ldx #n_hccols         ;max columns
;
_0190010 cpx #n_hccols         ;max columns
         beq _0190020          ;at left margin
;
         lda #a_ht
         jsr putcha            ;tab a column
;
_0190020 dex                   ;one less column
         stx xrtemp            ;save column counter
         jmp prntladr          ;print reference address
;
;================================================================================
;
;dpycod: DISASSEMBLE & DISPLAY CODE
;
;	------------------------------------------------------------------------
;	This function disassembles & displays the machine code at  the  location
;	pointed to by ADDRA.  Upon return, ADDRA will point to the opcode of the
;	next instruction.   The entry point at DPYCODAA  should be called with a
;	disassembly prefix character loaded in .A.   If entered  at  DPYCOD, the
;	default character will be display at the beginning of each  disassembled
;	instruction.
;
;	The disassembly of immediate mode instructions that can take an 8 or  16
;	bit operand is affected by the bit pattern that is  stored  in  FLIMFLAG
;	upon entry to this function:
;
;	    FLIMFLAG: xx000000
;	              ||
;	              |+---------> 0:  8 bit .X or .Y operand
;	              |            1: 16 bit .X or .Y operand
;	              +----------> 0:  8 bit .A or BIT # operand
;	                           1: 16 bit .A or BIT # operand
;
;	FLIMFLAG is conditioned according to the operand of  the  most  recently
;	disassembled REP or SEP instruction.   Hence repetitive  calls  to  this
;	subroutine will usually result in the correct disassembly of 16 bit imm-
;	ediate mode instructions.
;	------------------------------------------------------------------------
;
dpycod   lda #disprfx          ;default prefix
;
;
;	alternate prefix display entry point...
;
dpycodaa jsr putcha            ;print prefix
         jsr printspc          ;space
         jsr prntladr          ;print long address
         jsr printspc          ;space to opcode field
         jsr getbyte           ;get opcode
         sta opcode            ;save &...
         jsr printbyt          ;display as hex
;
;
;	decode menmonic & addressing info...
;
         ldx opcode            ;current mnemonic
         lda mnetabix,x        ;get mnemonic index
         asl                   ;double for...
         tay                   ;mnemonic table offset
         slonga                 ;16 bit load
         lda mnetab,y          ;copy encoded mnemonic to...
         sta mnepck            ;working storage
         shorta                ;back to 8 bits
         jsr instdata          ;extract mode & size data
         sta vopsflag          ;save mode flags
         sty admodidx          ;save mode index
         asl                   ;variable immediate instruction?
         bcc dpycod01          ;no, effective operand size in .X
;
;
;	determine immediate mode operand size...
;
         lda opcode            ;current opcode
         bit flimflag          ;operand display mode
         bpl _0200010          ;8 bit .A & BIT immediate mode
;
         and #aimmaska         ;determine if...
         cmp #aimmaskb         ;.A or BIT immediate
         beq _0200030          ;display 16 bit operand
;
         lda opcode            ;not .A or BIT immediate
;
_0200010 bvc dpycod01          ;8 bit .X/.Y immediate mode
;
         ldy #n_vopidx-1       ;opcodes to test
;
_0200020 cmp vopidx,y          ;looking for LDX #, CPY #, etc.
         beq _0200040          ;disassemble a 16 bit operand
;
         dey
         bpl _0200020          ;keep trying
;
         bra dpycod01          ;not .X or .Y immediate
;
_0200030 lda opcode            ;reload
;
_0200040 inx                   ;16 bit operand
;
;
;	get & display operand bytes...
;
dpycod01 stx iopsize           ;operand size...
         inx                   ;plus opcode becomes...
         stx instsize          ;instruction size
         stx charcnt           ;total bytes to process
         lda #n_opcols+2       ;total operand columns plus WS
         sta xrtemp            ;initialize counter
         jsr clroper           ;clear operand
         ldy iopsize           ;operand size
         beq _0210020          ;no operand
;
         ldx #0                ;operand index
;
_0210010 jsr getbyte           ;get operand byte
         sta operand,x         ;save
         phx                   ;protect operand index
         jsr printbyt          ;print operand byte
         dec xrtemp            ;3 columns used, 2 for...
         dec xrtemp            ;operand nybbles &...
         dec xrtemp            ;1 for whitespace
         plx                   ;get operand index
         inx                   ;bump it
         dey
         bne _0210010          ;next
;
_0210020 ldx xrtemp            ;operand columns remaining
         jsr multspc           ;space to mnemonic field
;
;
;	display mnemonic...
;
         ldy #s_mnemon         ;size of ASCII mnemonic
;
_0210030 lda #0                ;initialize char
         ldx #n_shfenc         ;shifts to execute
;
_0210040 asl mnepck            ;shift encoded mnemonic
         rol mnepck+s_byte
         rol
         dex
         bne _0210040
;
         adc #a_mnecvt         ;convert to ASCII &...
         pha                   ;stash
         dey
         bne _0210030          ;continue with mnemonic
;
         ldy #s_mnemon
;
_0210050 pla                   ;get mnenmonic byte
         jsr putcha            ;print it
         dey
         bne _0210050
;
;
;	display operand...
;
         lda iopsize           ;operand size
         beq clearlin          ;zero, disassembly finished
;
         jsr printspc          ;space to operand field
         bit vopsflag          ;check mode flags
         bvc dpycod02          ;not a branch
;
         jsr offtarg           ;compute branch target
         ldx instsize          ;effective instruction size
         dex
         stx iopsize           ;effective operand size
;
dpycod02 stz vopsflag          ;clear
         lda admodidx          ;instruction addressing mode
         cmp #am_move          ;block move instruction?
         bne _0220010          ;no
;
         ror vopsflag          ;yes
;
_0220010 asl                   ;convert addressing mode to...
         tax                   ;symbology table index
         slonga                 ;do a 16 bit load
         lda ms_lutab,x        ;addressing symbol pointer
         pha
         shorta                ;back to 8 bit loads
         ldy #0
         ldasi 1               ;get 1st char
         cmp #a_blank
         beq _0220020          ;no addresing mode preamble
;
         jsr putcha            ;print preamble
;
_0220020 lda #c_hex
         jsr putcha            ;operand displayed as hex
         ldy iopsize           ;operand size = index
;
_0220030 dey
         bmi _0220040          ;done with operand
;
         lda operand,y         ;get operand byte
         jsr dpyhex            ;print operand byte
         bit vopsflag          ;block move?
         bpl _0220030          ;no
;
         stz vopsflag          ;reset
         phy                   ;protect operand index
         pea ms_move
         jsr sprint            ;display MVN/MVP operand separator
         ply                   ;recover operand index again
         bra _0220030          ;continue
;
_0220040 plx                   ;symbology LSB
         ply                   ;symbology MSB
         inx                   ;move past preamble
         bne _0220050
;
         iny
;
_0220050 phy
         phx
         jsr sprint            ;print postamble, if any
;
;
;	condition immediate mode display format...
;
dpycod03 lda operand           ;operand LSB
         and #pfmxmask         ;isolate M & X bits
         asl                   ;shift to match...
         asl                   ;FLIMFLAG alignment
         ldx opcode            ;current instruction
         cpx #opc_rep          ;was it REP?
         bne _0230010          ;no
;
         tsb flimflag          ;set flag bits as required
         bra clearlin
;
_0230010 cpx #opc_sep          ;was it SEP?
         bne clearlin          ;no, just exit
;
         trb flimflag          ;clear flag bits as required
;
;================================================================================
;
;clearlin: CLEAR DISPLAY LINE
;
clearlin
	rts
;
;================================================================================
;
;dpyibuf: DISPLAY MONITOR INPUT BUFFER CONTENTS
;
dpyibuf  pea ibuffer
         bra dpyerraa
;
;================================================================================
;
;dpymem: DISPLAY MEMORY
;
;	------------------------------------------------------------
;	This function displays 16 bytes of memory as hex values & as
;	ASCII equivalents.  The starting address for the display is
;	in ADDRA & is expected to be a 24 bit address.  Upon return,
;	ADDRA will point to the start of the next 16 bytes.
;	------------------------------------------------------------
;
dpymem   shortr
         stz charcnt           ;reset
;         lda #memprfx
;         jsr putcha            ;display prefix
         jsr prntladr          ;print 24 bit address
         ldx #0                ;string buffer index
         ldy #n_dump           ;bytes per line
;
_0240010 jsr getbyte           ;get from RAM, also...
         pha                   ;save for decoding
         phx                   ;save string index
         jsr printbyt          ;display as hex ASCII
         inc charcnt           ;bytes displayed +1
         plx                   ;recover string index &...
         pla                   ;byte
         cmp #a_blank          ;printable?
         bcc _0240020          ;no
;
         cmp #a_del
         bcc _0240030          ;is printable
;
_0240020 lda #memsubch         ;substitute character
;
_0240030 sta ibuffer,x         ;save char
         inx                   ;bump index
         dey                   ;byte count -= 1
         bne _0240010          ;not done
;
         stz ibuffer,x         ;terminate ASCII string
         lda #memsepch
         jsr putcha            ;separate ASCII from bytes
         jsr dpyibuf           ;display ASCII equivalents
         rts
;
;================================================================================
;
;dpyerr: DISPLAY ERROR SIGNAL
;
dpyerr   pea mm_err            ;"*ERR"
;
dpyerraa jsr sprint
         rts
;
;================================================================================
;
;gendbs: GENERATE DESTRUCTIVE BACKSPACE
;
gendbs   pea dc_bs             ;destructive backspace
         bra dpyerraa
;
;================================================================================
;
;prntladr: PRINT 24 BIT CURRENT ADDRESS
;
prntladr php                   ;protect register sizes
         shorta
         lda addra+s_word      ;get bank byte &...
         jsr dpyhex            ;display it
         slonga
         lda addra             ;get 16 bit address
         plp                   ;restore register sizes
;
;================================================================================
;
;dpyhexw: DISPLAY BINARY WORD AS HEX ASCII
;
;	------------------------------------
;	Preparatory Ops: .C: word to display
;
;	Returned Values: .C: used
;	                 .X: used
;	                 .Y: entry value
;	------------------------------------
;
dpyhexw  php                   ;save register sizes
         slonga
         pha                   ;protect value
         shorta
         xba                   ;get MSB &...
         jsr dpyhex            ;display
         slonga
         pla                   ;recover value
         shorta                ;only LSB visible
         plp                   ;reset register sizes
;
;================================================================================
;
;dpyhex: DISPLAY BINARY BYTE AS HEX ASCII
;
;	------------------------------------
;	Preparatory Ops: .A: byte to display
;
;	Returned Values: .A: used
;	                 .X: used
;	                 .Y: entry value
;	------------------------------------
;
dpyhex   jsr binhex            ;convert to hex ASCII
         jsr putcha            ;print MSN
         txa
         jmp putcha            ;print LSN
;
;================================================================================
;
;multspc: PRINT MULTIPLE BLANKS
;
;	------------------------------------------------
;	Preparatory Ops : .X: number of blanks to print
;
;	Register Returns: none
;
;	Calling Example : ldx #3
;	                  jsr multspc    ;print 3 spaces
;
;	Notes: This sub will print 1 blank if .X=0.
;	------------------------------------------------
;

multspc  txa
         bne _0250010          ;blank count specified
;
         inx                   ;default to 1 blank
;
_0250010 jsr printspc
         dex
         bne _0250010
;
         rts

;
;================================================================================
;
;newline: PRINT NEWLINE (CRLF)
;
newline  pea dc_lf
         bra dpyerraa
;
;================================================================================
;
;printbyt: PRINT A BYTE WITH LEADING SPACE
;
printbyt pha                   ;protect byte
         jsr printspc          ;print leading space
         pla                   ;restore &...
         bra dpyhex            ;print byte
;
;================================================================================
;
;alert: ALERT USER w/TERMINAL BELL
;
alert    lda #a_bel
         bra printcmn
;
;================================================================================
;
;printspc: PRINT A SPACE
;
printspc lda #a_blank
;
printcmn jmp putcha
;
;================================================================================
;
;sprint: PRINT NULL-TERMINATED CHARACTER STRING
;
;	---------------------------------------------------------
;	Preparatory Ops : SP+1: string address LSB
;	                  SP+2: string address MSB
;
;	Register Returns: .A: used
;	                  .B: entry value
;	                  .X: used
;	                  .Y: used
;
;	MPU Flags: NVmxDIZC
;	           ||||||||
;	           |||||||+---> 0: okay
;	           |||||||      1: string too long (1)
;	           ||||+++----> not defined
;	           |||+-------> 1
;	           ||+--------> 1
;	           ++---------> not defined
;
;	Example: PER STRING
;	         JSR SPRINT
;	         BCS TOOLONG
;
;	Notes: 1) Maximum permissible string length including the
;	          terminator is 32,767 bytes.
;	       2) All registers are forced to 8 bits.
;	       3) DO NOT JUMP OR BRANCH INTO THIS FUNCTION!
;	---------------------------------------------------------
;
sprint   shorta                ;8 bit accumulator
         longx                 ;16 bit index
;
;---------------------------------------------------------
_retaddr .equ 1                    ;return address
_src     .equ _retaddr+s_word      ;string address stack offset
;---------------------------------------------------------
;
         ldyw 0
         clc                   ;no initial error
;
_0260010 ldasi _src            ;get a byte
         beq _0260020          ;done
;
         jsr putcha            ;write to console port
         iny
         bpl _0260010          ;next
;
         sec                   ;string too long
;
_0260020 plx                   ;pull RTS address
         ply                   ;clear string pointer
         phx                   ;replace RTS
         shortx
         rts
;
;================================================================================
;
;ascbin: CONVERT NULL-TERMINATED ASCII NUMBER STRING TO BINARY
;
;	---------------------------------------------------
;	Preparatory Ops: ASCII number string in IBUFFER
;
;	Returned Values: FACA: converted parameter
;	                   .A: used
;	                   .X: used
;	                   .Y: used
;	                   .C: 1 = conversion error
;	                   .Z: 1 = nothing to convert
;
;	Notes: 1) Conversion stops when a non-numeric char-
;	          acter is encountered.
;	       2) Radix symbols are as follows:
;
;	          % binary
;	          % octal
;	          + decimal
;	          $ hexadecimal
;
;	          Hex is the default if no radix is speci-
;	          fied in the 1st character of the string.
;	---------------------------------------------------
;
ascbin   shortr
         jsr clrfaca           ;clear accumulator
         stz charcnt           ;zero char count
         stz radix             ;initialize
;
;
;	process radix if present...
;
         jsr getcharw          ;get next non-WS char
         bne _0270010          ;got something
;
         clc                   ;no more input
         rts
;
_0270010 ldx #n_radix-1        ;number of radices
;
_0270020 cmp radxtab,x         ;recognized radix?
         beq _0270030          ;yes
;
         dex
         bpl _0270020          ;try next
;
         dec ibufidx           ;reposition to previous char
         inx                   ;not recognized, assume hex
;
_0270030 cmp #c_dec            ;decimal radix?
         bne _0270040          ;not decimal
;
         ror radix             ;flag decimal conversion
;
_0270040 lda basetab,x         ;number bases table
         sta range             ;set valid numeral range
         lda bitsdtab,x        ;get bits per digit
         sta bitsdig           ;store
;
;
;	process numerals...
;
ascbin01 jsr getchar           ;get next char
         bne _TMP0001          ;not EOI
         jmp ascbin03          ;EOI
;
_TMP0001
         cmp #' '
         beq ascbin03          ;blank - EOF
;
         cmp #','
         beq ascbin03          ;comma - EOF
;
         cmp #a_ht
         beq ascbin03          ;tab - EOF
;
         jsr nybtobin          ;change to binary
         bcs ascbin04          ;not a recognized numeral
;
         cmp range             ;check range
         bcs ascbin04          ;not valid for base
;
         sta numeral           ;save processed numeral
         inc charcnt           ;bump numeral count
         bit radix             ;working in base 10?
         bpl _1570030          ;no
;
;
;	compute N*2 for decimal conversion...
;
         ldx #0                ;accumulator index
         ldy #s_pfac/2         ;iterations
         slonga
         clc
;
_1570020 lda faca,x            ;N
         rol                   ;N=N*2
         sta facb,x
         inx
         inx
         dey
         bne _1570020
;
         bcs ascbin04          ;overflow - error
;
         shorta
;
;
;	compute N*base for binary, octal or hex...
;	or N*8 for decimal...
;
_1570030 ldx bitsdig           ;bits per digit
         slonga                 ;16 bit shifts
;
_1570040 asl faca
         rol faca+s_word
         bcs ascbin04          ;overflow - error
;
         dex
         bne _1570040          ;next shift
;
         shorta                ;back to 8 bits
         bit radix             ;check base
         bpl ascbin02          ;not decimal
;
;
;	compute N*10 for decimal (N*8 + N*2)...
;
         ldy #s_pfac
         slonga
;
_1570050 lda faca,x            ;N*8
         adc facb,x            ;N*2
         sta faca,x            ;now N*10
         inx
         inx
         dey
         bne _1570050
;
         bcs ascbin04          ;overflow - error
;
         shorta
;
;
;	add current numeral to partial result...
;
ascbin02 lda faca              ;N
         adc numeral           ;N=N+D
         sta faca
         ldx #1
         ldy #s_pfac-1
;
_0280010 lda faca,x
         adc #0                ;account for carry
         sta faca,x
         inx
         dey
         bne _0280010
;
         bcc _0280020          ;next if no overflow
;
         bcs ascbin04          ;overflow - error
;
;
;	finish up...
;
ascbin03 clc                   ;no error
;
ascbin04 shorta                ;reset if necessary
         lda charcnt           ;load char count
         rts                   ;done
_0280020 jmp ascbin01          ;next if no overflow
;
;================================================================================
;
;bcdasc: CONVERT BCD DIGIT TO ASCII
;
;	---------------------------------------
;	Preparatory Ops: .A: BCD digit, $00-$99
;
;	Returned Values: .A: ASCII MSD
;	                 .X: ASCII LSD
;	                 .Y: entry value
;	---------------------------------------
;
bcdasc   jsr bintonyb          ;extract nybbles
         pha                   ;save tens
         txa
         ora #btoamask         ;change units to ASCII
         tax                   ;store
         pla                   ;get tens
         ora #btoamask         ;change to ASCII
         rts
;
;================================================================================
;
;bintonyb: EXTRACT BINARY NYBBLES
;
;	---------------------------------
;	Preparatory Ops: .A: binary value
;
;	Returned Values: .A: MSN
;	                 .X: LSN
;	                 .Y: entry value
;	---------------------------------
;
bintonyb pha                   ;save
         and #bcdumask         ;extract LSN
         tax                   ;save it
         pla
;         .rept s_bnybbl        ;extract MSN
           lsr
           lsr
           lsr
           lsr
;         .endr
         rts
;
;================================================================================
;
;binasc: CONVERT 32-BIT BINARY TO NULL-TERMINATED ASCII NUMBER STRING
;
;	------------------------------------------------------
;	Preparatory Ops: FACA: 32-bit operand
;	                   .A: radix character, w/bit 7 set to
;	                       suppress radix symbol in the
;	                       conversion string
;
;	Returned Values: ibuffer: conversion string
;	                      .A: string length
;	                      .X: string address LSB
;	                      .Y: string address MSB
;
;	Execution Notes: ibufidx & instsize are overwritten.
;	------------------------------------------------------
;
binasc   stz ibufidx           ;initialize string index
         stz instsize          ;clear format flag
;
;
;	evaluate radix...
;
         asl                   ;extract format flag &...
         ror instsize          ;save it
         lsr                   ;extract radix character
         ldx #n_radix-1        ;total radices
;
_0290010 cmp radxtab,x         ;recognized radix?
         beq _0290020          ;yes
;
         dex
         bpl _0290010          ;try next
;
         inx                   ;assume hex
;
_0290020 stx radix             ;save radix index for later
         bit instsize
         bmi _0290030          ;no radix symbol wanted
;
         lda radxtab,x         ;radix table
         sta ibuffer           ;prepend to string
         inc ibufidx           ;bump string index
;
_0290030 cmp #c_dec            ;converting to decimal?
         bne _0290040          ;no
;
         jsr facabcd           ;convert operand to BCD
         lda #0
         bra _0290070          ;skip binary stuff
;
;
;	prepare for binary, octal or hex conversion...
;
_0290040 ldx #0                ;operand index
         ldy #s_sfac-1         ;workspace index
;
_0290050 lda faca,x            ;copy operand to...
         sta facb,y            ;workspace in...
         dey                   ;big-endian order
         inx
         cpx #s_pfac
         bne _0290050
;
         lda #0
         tyx
;
_0290060 sta facb,x            ;pad workspace
         dex
         bpl _0290060
;
;
;	set up conversion parameters...
;
_0290070 sta facc              ;initialize byte counter
         ldy radix             ;radix index
         lda numstab,y         ;numerals in string
         sta facc+s_byte       ;set remaining numeral count
         lda bitsntab,y        ;bits per numeral
         sta facc+s_word       ;set
         lda lzsttab,y         ;leading zero threshold
         sta facc+s_xword      ;set
;
;
;	generate conversion string...
;
_0290080 lda #0
         ldy facc+s_word       ;bits per numeral
;
_0290090 ldx #s_sfac-1         ;workspace size
         clc                   ;avoid starting carry
;
_0290100 rol facb,x            ;shift out a bit...
         dex                   ;from the operand or...
         bpl _0290100          ;BCD conversion result
;
         rol                   ;bit to .A
         dey
         bne _0290090          ;more bits to grab
;
         tay                   ;if numeral isn't zero...
         bne _0290110          ;skip leading zero tests
;
         ldx facc+s_byte       ;remaining numerals
         cpx facc+s_xword      ;leading zero threshold
         bcc _0290110          ;below it, must convert
;
         ldx facc              ;processed byte count
         beq _0290130          ;discard leading zero
;
_0290110 cmp #10               ;check range
         bcc _0290120          ;is 0-9
;
         adc #a_hexdec         ;apply hex adjust
;
_0290120 adc #'0'              ;change to ASCII
         ldy ibufidx           ;string index
         sta ibuffer,y         ;save numeral in buffer
         inc ibufidx           ;next buffer position
         inc facc              ;bytes=bytes+1
;
_0290130 dec facc+s_byte       ;numerals=numerals-1
         bne _0290080          ;not done
;
;
;	terminate string & exit...
;
         ldx ibufidx           ;printable string length
         stz ibuffer,x         ;terminate string
         txa
         ldx #<ibuffer         ;converted string
         ldy #>ibuffer
         clc                   ;all okay
         rts
;
;================================================================================
;
;binhex: CONVERT BINARY BYTE TO HEX ASCII CHARS
;
;	--------------------------------------------
;	Preparatory Ops: .A: byte to convert
;
;	Returned Values: .A: MSN ASCII char
;	                 .X: LSN ASCII char
;	                 .Y: entry value
;	--------------------------------------------
;
binhex   jsr bintonyb          ;generate binary values
         pha                   ;save MSN
         txa
         jsr _0300010          ;generate ASCII LSN
         tax                   ;save
         pla                   ;get input
;
;
;	convert nybble to hex ASCII equivalent...
;
_0300010 cmp #10
         bcc _0300020          ;in decimal range
;
         adc #k_hex            ;hex compensate
;
_0300020 eor #'0'              ;finalize nybble
         rts                   ;done
;
;================================================================================
;
;clrfaca: CLEAR FLOATING ACCUMULATOR A
;
clrfaca  php
         slonga
         stz faca
         stz faca+s_word
         plp
         rts
;
;================================================================================
;
;clrfacb: CLEAR FLOATING ACCUMULATOR B
;
clrfacb  php
         slonga
         stz facb
         stz facb+s_word
         plp
         rts
;
;================================================================================
;
;facabcd: CONVERT FACA INTO BCD
;
facabcd  ldx #s_pfac-1         ;primary accumulator size -1
;
_1300010 lda faca,x            ;value to be converted
         pha                   ;preserve
         dex
         bpl _1300010          ;next
;
         ldx #s_sfac-1         ;workspace size
;
_1300020 stz facb,x            ;clear final result
         stz facc,x            ;clear scratchpad
         dex
         bpl _1300020
;
         inc facc+s_sfac-s_byte
         sed                   ;select decimal mode
         ldy #m_bits-1         ;bits to convert -1
;
_1300030 ldx #s_pfac-1         ;operand size
         clc                   ;no carry at start
;
_1300040 ror faca,x            ;grab LS bit in operand
         dex
         bpl _1300040
;
         bcc _1300060          ;LS bit clear
;
         clc
         ldx #s_sfac-1
;
_1300050 lda facb,x            ;partial result
         adc facc,x            ;scratchpad
         sta facb,x            ;new partial result
         dex
         bpl _1300050
;
         clc
;
_1300060 ldx #s_sfac-1
;
_1300070 lda facc,x            ;scratchpad
         adc facc,x            ;double &...
         sta facc,x            ;save
         dex
         bpl _1300070
;
         dey
         bpl _1300030          ;next operand bit
;
         cld
         ldx #0
         ldy #s_pfac
;
_1300080 pla                   ;operand
         sta faca,x            ;restore
         inx
         dey
         bne _1300080          ;next
;
         rts
;
;================================================================================
;
;nybtobin: CONVERT ASCII NYBBLE TO BINARY
;
nybtobin jsr toupper           ;convert case if necessary
         sec
         sbc #'0'              ;change to binary
         bcc _0310020          ;not a numeral - error
;
         cmp #10
         bcc _0310010          ;numeral is 0-9
;
         sbc #a_hexdec+1       ;10-15 --> A-F
         clc                   ;no conversion error
;
_0310010 rts
;
_0310020 sec                   ;conversion error
         rts
;
;================================================================================
;
;calccnt: COMPUTE BYTE COUNT FROM ADDRESS RANGE
;
calccnt  jsr clrfacb           ;clear accumulator
         slonga
         sec
         lda addrb             ;ending address
         sbc addra             ;starting address
         sta facb              ;byte count
         shorta
         lda addrb+s_word      ;handle banks
         sbc addra+s_word
         sta facb+s_word
         rts
;
;================================================================================
;
;clroper: CLEAR OPERAND
;
clroper  phx
         ldx #s_oper-1
;
_0320010 stz operand,x
         dex
         bpl _0320010
;
         stz eopsize
         plx
         rts
;
;================================================================================
;
;cpfwsup: FOWARD COPY MEMORY SETUP
;
cpfwsup  longr
         ldxw opc_mvn          ;"move next" opcode
         bra cpsup
;
;================================================================================
;
;cprvsup: REVERSE COPY MEMORY SETUP
;
cprvsup  longr
         ldxw opc_mvp          ;"move previous" opcode
;
;================================================================================
;
;cpsup: COPY MEMORY SETUP
;
cpsup    pha                   ;save banks
         txa                   ;protect...
         xba                   ;opcode
         shorta
         ldxw cpcodeee-cpcode-1
;
_1320010 ldalx cpcode          ;transfer copy code to...
         sta mcftwork,x        ;to workspace
         dex
         bpl _1320010
;
         xba                   ;recover opcode &...
         sta mcftopc           ;set it
         slonga
         pla                   ;get banks &...
         sta mcftbnk           ;set them
         rts
;
;================================================================================
;
;decdcnt: DECREMENT DUMP COUNT
;
;	-------------------------------------------
;	Preparatory Ops: bytes to process in FACB
;	                 bytes processed in CHARCNT
;
;	Returned Values: .A: used
;	                 .X: entry value
;	                 .Y: entry value
;	                 .C: 1 = count = zero
;	-------------------------------------------
;
decdcnt  shorta
         lda #0
         xba                   ;clear .B
         lda facb+s_word       ;count MSW
         slonga
         sec
         ora facb              ;count LSW
         beq _0330020          ;zero, just exit
;
         lda facb
         sbc charcnt           ;bytes processed
         sta facb
         shorta
         lda facb+s_word
         sbc #0                ;handle borrow
         bcc _0330010          ;underflow
;
         sta facb+s_word
         clc                   ;count > 0
         rts
;
_0330010 sec
;
_0330020 shorta
         rts
;
;================================================================================
;
;enddest: GET 2ND & 3RD ADDRESSES FOR COMPARE & TRANSFER
;
enddest  jsr facasize          ;check start...
         cmp #s_dword          ;for range
         bcs _0340010          ;out of range - error
;
         jsr facaddra          ;store start
         jsr getparm           ;get end
         bcs _0340010          ;not entered - error
;
         jsr facasize          ;check end...
         cmp #s_dword          ;for range
         bcs _0340010          ;out of range - error
;
         jsr facaddrb          ;store end
         jsr getparm           ;get destination
         bcs _0340010          ;not entered - error
;
         jsr facasize          ;check destination...
         cmp #s_dword          ;for range
         bcc facaoper          ;store dest address
;
_0340010 rts                   ;exit w/error
;
;================================================================================
;
;facaddra: COPY FACA TO ADDRA
;
facaddra ldx #s_xword-1
;
_0350010 lda faca,x
         sta addra,x
         dex
         bpl _0350010
;
         rts
;
;================================================================================
;
;facaddrb: COPY FACA TO ADDRB
;
facaddrb ldx #s_xword-1
;
_1350010 lda faca,x
         sta addrb,x
         dex
         bpl _1350010
;
         rts
;
;================================================================================
;
;facaoper: COPY FACA TO OPERAND
;
facaoper ldx #s_oper-1
;
_0360010 lda faca,x
         sta operand,x
         dex
         bpl _0360010
;
         rts
;
;================================================================================
;
;facasize: REPORT OPERAND SIZE IN FACA
;
;	------------------------------------------
;	Preparatory Ops: operand in FACA
;
;	Returned Values: .A: s_byte  (1)
;	                     s_word  (2)
;	                     s_xword (3)
;	                     s_dword (4)
;
;	Notes: 1) This function will always report
;	          a non-zero result.
;	------------------------------------------
;
facasize shortr
         ldx #s_dword-1
;
_0370010 lda faca,x            ;get byte
         bne _0370020          ;done
;
         dex
         bne _0370010          ;next byte
;
_0370020 inx                   ;count=index+1
         txa
         rts
;
;================================================================================
;
;getparm: GET A PARAMETER
;
;	-------------------------------------------------
;	Preparatory Ops: null-terminated input in IBUFFER
;
;	Returned Values: .A: chars in converted parameter
;	                 .X: used
;	                 .Y: entry value
;	                 .C: 1 = no parameter entered
;	-------------------------------------------------
;
getparmr dec ibufidx           ;reread previous char
;
getparm  phy                   ;preserve
         jsr ascbin            ;convert parameter to binary
         bcs _0380040          ;conversion error
;
         jsr getcharr          ;reread last char
         bne _0380010          ;not end-of-input
;
         dec ibufidx           ;reindex to terminator
         lda charcnt           ;get chars processed so far
         beq _0380030          ;none
;
         bne _0380020          ;some
;
_0380010 cmp #a_blank          ;recognized delimiter
         beq _0380020          ;end of parameter
;
         cmp #','              ;recognized delimiter
         bne _0380040          ;unknown delimter
;
_0380020 clc
         .db bitzp           ;skip SEC below
;
_0380030 sec
         ply                   ;restore
         lda charcnt           ;get count
         rts                   ;done
;
_0380040 ;.rept 3               ;clean up stack
           pla
           pla
           pla
         ;.endr
         jmp monerr            ;abort w/error
;
;================================================================================
;
;nxtaddra: TEST & INCREMENT WORKING ADDRESS 'A'
;
;	--------------------------------------------------
;	Calling syntax: JSR NXTADDRA
;
;	Exit registers: .A: used
;	                .B: used
;	                .X: entry value
;	                .Y: entry value
;	                DB: entry value
;	                DP: entry value
;	                PB: entry value
;	                SR: NVmxDIZC
;	                    ||||||||
;	                    |||||||+---> 0: ADDRA < ADDRB
;	                    |||||||      1: ADDRA >= ADDRB
;	                    ||||||+----> undefined
;	                    |||+++-----> entry value
;	                    ||+--------> 1
;	                    ++---------> undefined
;	--------------------------------------------------
;
nxtaddra shorta
         lda addra+s_word      ;bits 16-23
         cmp addrb+s_word
         bcc incaddra          ;increment
;
         bne _0390010          ;don't increment
;
         slonga
         lda addra             ;bits 0-15
         cmp addrb             ;condition flags
         shorta
         bcc incaddra          ;increment
;
_0390010 rts
;
;================================================================================
;
;getbyte: GET A BYTE FROM MEMORY
;
getbyte  ldail addra           ;get a byte
;
;================================================================================
;
;incaddra: INCREMENT WORKING ADDRESS 'A'
;
;	--------------------------------------------------
;	Calling syntax: JSR INCADDRA
;
;	Exit registers: .A: entry value
;	                .B: entry value
;	                .X: entry value
;	                .Y: entry value
;	                DB: entry value
;	                DP: entry value
;	                PB: entry value
;	                SR: NVmxDIZC
;	                    ||||||||
;	                    ++++++++---> entry value
;	--------------------------------------------------
;
incaddra php
         slonga
         inc addra             ;bump bits 0-15
         bne _0400010
;
         shorta
         inc addra+s_word      ;bump bits 16-23
;
_0400010 plp
         rts
;
;================================================================================
;
;incoper: INCREMENT OPERAND ADDRESS
;
incoper  clc
         php
         longr
         pha
         inc operand           ;handle base address
         bne _0410010
;
         shorta
         inc operand+s_word    ;handle bank
         slonga
;
_0410010 pla
         plp
         rts
;
;================================================================================
;
;instdata: GET INSTRUCTION SIZE & ADDRESSING MODE DATA
;
;	----------------------------------
;	Preparatory Ops: .X: 65C816 opcode
;
;	Returned Values: .A: mode flags
;	                 .X: operand size
;	                 .Y: mode index
;	----------------------------------
;
instdata shortr
         lda mnetabam,x        ;addressing mode data
         pha                   ;save mode flag bits
         pha                   ;save size data
         and #amodmask         ;extract mode index &...
         tay                   ;save
         pla                   ;recover data
         and #opsmask          ;mask mode fields &...
;         .rept n_opslsr        ;extract operand size
           lsr
           lsr
           lsr
           lsr
;         .endr
         tax                   ;operand size
         pla                   ;recover mode flags
         and #vopsmask         ;discard mode & size fields
         rts
;
;================================================================================
;
;offtarg: CONVERT BRANCH OFFSET TO TARGET ADDRESS
;
;	-----------------------------------------------
;	Preparatory Ops:    ADDRA: base address
;	                 INSTSIZE: instruction size
;	                  OPERAND: offset
;
;	Returned Values:  OPERAND: target address (L/H)
;	                       .A: used
;	                       .X: entry value
;                              .Y: entry value
;	-----------------------------------------------
;
offtarg  slonga
         lda addra             ;base address
         shorta
         lsr instsize          ;bit 0 will be set if...
         bcs _0420010          ;a long branch
;
         bit operand           ;short forward or backward?
         bpl _0420010          ;forward
;
         xba                   ;expose address MSB
         dea                   ;back a page
         xba                   ;expose address LSB
;
_0420010 slonga
         clc
         adc operand           ;calculate target address
         sta operand           ;new operand
         shorta
         lda #s_xword
         sta instsize          ;effective instruction size
         rts
;
;================================================================================
;
;setxaddr: SET EXECUTION ADDRESS
;
setxaddr bcs _0430010          ;no address given
;
         jsr facasize          ;check address...
         cmp #s_dword          ;range
         bcs _0430020          ;out of range
;
         slonga
         lda faca              ;execution address
         sta reg_pcx           ;set new PC value
         shorta
         lda faca+s_word
         sta reg_pbx           ;set new PB value
;
_0430010 clc                   ;no error
;
_0430020 rts
;
;================================================================================
;
;targoff: CONVERT BRANCH TARGET ADDRESS TO BRANCH OFFSET
;
;	-------------------------------------------------
;	Preparatory Ops:   ADDRA: instruction address
;	                 OPERAND: target address
;
;	Returned Values: OPERAND: computed offset
;	                      .A: effective operand size
;	                      .X: entry value
;                             .Y: entry value
;	                      .C: 1 = branch out of range
;
;	Execution notes: ADDRB is set to the branch base
;	                 address.
;	-------------------------------------------------
;
targoff  stz instsize+s_byte   ;always zero
         lda instsize          ;instruction size will tell...
         lsr                   ;if long or short branch
;
;-------------------------------------------------
_btype   .equ facc+5               ;branch type flag
;-------------------------------------------------
;
         ror _btype            ;set branch type...
;
;	x0000000
;	|
;	+----------> 0: short
;	             1: long
;
         slonga
         clc
         lda addra             ;instruction address
         adc instsize          ;instruction size
         sta addrb             ;base address
         sec
         lda operand           ;target address
         sbc addrb             ;base address
         sta operand           ;offset
         shorta
         bcc _0440040          ;backward branch
;
         bit _btype            ;check branch range
         bmi _0440020          ;long
;
;
;	process short forward branch...
;
         xba                   ;offset MSB should be zero
         bne _0440060          ;it isn't - out of range
;
         xba                   ;offset LSB should be $00-$7F
         bmi _0440060          ;it isn't - out of range
;
_0440010 lda #s_byte           ;final instruction size
         clc                   ;branch in range
         rts
;
;
;	process long forward branch...
;
_0440020 xba                   ;offset MSB should be positive
         bmi _0440060          ;it isn't - branch out of range
;
_0440030 lda #s_word
         clc
         rts
;
;
;	process backward branch...
;
_0440040 bit _btype            ;long or short?
         bmi _0440050          ;long
;
;
;	process short backward branch...
;
         xba                   ;offset MSB should be negative
         bpl _0440060          ;it isn't - out of range
;
         eor #%11111111        ;complement offset MSB 2s
         bne _0440060          ;out of range
;
         xba                   ;offset LSB should be $80-$FF
         bmi _0440010          ;it is - branch in range
;
         bra _0440060          ;branch out of range
;
;
;	process long backward branch...
;
_0440050 xba                   ;offset MSB should be negative
         bmi _0440030          ;it is - branch in range
;
_0440060 sec                   ;range error
         rts
;
;================================================================================
;
;getcharr: GET PREVIOUS INPUT BUFFER CHARACTER
;
getcharr dec ibufidx           ;move back a char
;
;================================================================================
;
;getchar: GET A CHARACTER FROM INPUT BUFFER
;
;	----------------------------------------------
;	Preparatory Ops : none
;
;	Register Returns: .A: character or <NUL>
;	                  .B: entry value
;	                  .X: entry value
;	                  .Y: entry value
;
;	MPU Flags: NVmxDIZC
;	           ||||||||
;	           |||||||+---> entry value
;	           ||||||+----> 1: <NUL> gotten
;	           |||||+-----> entry value
;	           ||||+------> entry value
;	           |||+-------> entry value
;	           ||+--------> entry value
;	           |+---------> not defined
;	           +----------> not defined
;	----------------------------------------------
;
getchar  phx
         phy
         php                   ;save register sizes
         shortr                ;force 8 bits
         ldx ibufidx           ;buffer index
         lda ibuffer,x         ;get char
         inc ibufidx           ;bump index
         plp                   ;restore register widths
         ply
         plx
         xba                   ;condition...
         xba                   ;.Z
         rts
;
;================================================================================
;
;getpat: GET PATTERN FOR MEMORY CHANGE or SEARCH
;
;	-----------------------------------------------------
;	Preparatory Ops: Null-terminated pattern in IBUFFER.
;
;	Returned Values: .A: used
;	                 .X: used
;	                 .Y: pattern length if entered
;	                 .C: 0 = pattern valid
;	                     1 = exception:
;	                 .N  0 = no pattern entered
;	                     1 = evaluation error
;
;	Notes: 1) If pattern is preceded by "'" the following
;	          characters are interpreted as ASCII.
;	       2) A maximum of 32 bytes or characters is
;	          accepted.  Excess input will be discarded.
;	-----------------------------------------------------
;
getpat   stz status            ;clear pattern type indicator
         ldy #0                ;pattern index
         jsr getcharr          ;get last char
         beq _0450070          ;EOS
;
         ldx ibufidx           ;current buffer index
         jsr getcharw          ;get next
         beq _0450070          ;EOS
;
         cmp #$27	       ; single quote
         bne _0450010          ;not ASCII input
;
         ror status            ;condition flag
         bra _0450030          ;balance of input is ASCII
;
_0450010 stx ibufidx           ;restore buffer index
;
_0450020 jsr getparm           ;evaluate numeric pattern
         bcs _0450060          ;done w/pattern
;
         jsr facasize          ;size
         cmp #s_word
         bcs _0450070          ;not a byte - error
;
         lda faca              ;get byte &...
         bra _0450040          ;store
;
_0450030 jsr getchar           ;get ASCII char
         beq _0450060          ;done w/pattern
;
_0450040 cpy #s_auxbuf         ;pattern buffer full?
         beq _0450050          ;yes
;
         sta auxbuf,y          ;store pattern
         iny
         bit status
         bpl _0450020          ;get next numeric value
;
         bra _0450030          ;get next ASCII char
;
_0450050 jsr alert             ;excess input
;
_0450060 sty auxbufix          ;save pattern size
         tya                   ;condition .Z
         clc                   ;pattern valid
         rts
;
;
;	no pattern entered...
;
_0450070 rep #%10000000
         sec
         rts
;
;
;	evaluation error...
;
_0450080 sep #%10000001
         rts
;
;================================================================================
;
;getcharw: GET FROM INPUT BUFFER, DISCARDING WHITESPACE
;
;	--------------------------------------------------
;	Preparatory Ops: Null-terminated input in IBUFFER.
;
;	Returned Values: .A: char or null
;	                 .X: entry value
;	                 .Y: entry value
;	                 .Z: 1 = null terminator detected
;
;	Notes: Whitespace is defined as a blank ($20) or a
;	       horizontal tab ($09).
;	--------------------------------------------------
;
getcharw jsr getchar           ;get from buffer
         beq _0460010          ;EOI
;
         cmp #a_blank
         beq getcharw          ;discard whitespace
;
         cmp #a_ht             ;also whitespace
         beq getcharw
;
_0460010 clc
         rts
;
;================================================================================
;
;input: INTERACTIVE INPUT FROM CONSOLE CHANNEL
;
;	-----------------------------------------------------------
;	Preparatory Ops: Zero IBUFIDX or load IBUFFER with default
;	                 input & set IBUFIDX to the number of chars
;	                 loaded into the buffer.
;
;	Returned Values: .A: used
;	                 .X: characters entered
;	                 .Y: used
;
;	Example: STZ IBUFIDX
;	         JSR INPUT
;
;	Notes: Input is collected in IBUFFER & is null-terminated.
;	       IBUFIDX is reset to zero upon exit.
;	-----------------------------------------------------------
;
input    ldx ibufidx
         stz ibuffer,x         ;be sure buffer is terminated
         jsr dpyibuf           ;print default input if any

         ldx ibufidx           ;starting buffer index
;
;
;	main input loop...
;
_0470010 jsr CURSOR
_047001A jsr getcha            ;poll for input
         bcc _0470020          ;got something
;
;         wai                   ;wait 'til any IRQ &...
         bra _047001A          ;try again
;
_0470020 cmp #a_del            ;above ASCII range?
         bcs _047001A          ;yes, ignore

         jsr UNCURSOR
;
         cmp #a_ht             ;horizontal tab?
         bne _0470030          ;no
;
         lda #a_blank          ;replace <HT> w/blank
;
_0470030 cmp #a_blank          ;control char?
         bcc _0470050          ;yes
;
;
;	process QWERTY character...
;
         cpx #s_ibuf           ;room in buffer?
         bcs _0470040          ;no
;
         sta ibuffer,x         ;store char
         inx                   ;bump index
         .db bitabs          ;echo char
;
_0470040 lda #a_bel            ;alert user
         jsr putcha
         bra _0470010          ;get some more
;
;
;	process carriage return...
;
_0470050 cmp #a_cr             ;carriage return?
         bne _0470060          ;no
;
;         phx                   ;protect input count
;         pea dc_co
;         jsr sprint            ;cursor off
;         plx                   ;recover input count
         stz ibuffer,x         ;terminate input &...
         stz ibufidx           ;reset buffer index
         rts                   ;done
;
;
;	process backspace...
;
_0470060 cmp #a_bs             ;backspace?
         bne _0470010          ;no
;
         txa
         beq _0470010          ;no input, ignore <BS>
;
         dex                   ;1 less char
         phx                   ;preserve count
         jsr gendbs            ;destructive backspace
         plx                   ;restore count
         bra _0470010          ;get more input
;
;================================================================================
;
;lodbnk: LOAD SOURCE & DESTINATION BANKS
;
lodbnk   shorta
         lda operand+s_word    ;destination bank
         xba                   ;make it MSB
         lda addra+s_word      ;source bank is LSB
         rts
;
;================================================================================
;
;getcharc: GET A CHARACTER FROM INPUT BUFFER & CONVERT CASE
;
;	--------------------------------------------------
;	Preparatory Ops: Null-terminated input in IBUFFER.
;
;	Returned Values: .A: char or null
;	                 .X: entry value
;	                 .Y: entry value
;	                 .Z: 1 = null terminator detected
;	--------------------------------------------------
;
getcharc jsr getchar           ;get from buffer
;
;================================================================================
;
;toupper: FORCE CHARACTER TO UPPER CASE
;
;	------------------------------------------------
;	Preparatory Ops : .A: 8 bit character to convert
;
;	Register Returns: .A: converted character
;	                  .B: entry value
;	                  .X: entry value
;	                  .Y: entry value
;
;	MPU Flags: no change
;
;	Notes: 1) This subroutine has no effect on char-
;	          acters that are not alpha.
;	------------------------------------------------
;
toupper  php                   ;protect flags
         cmp #a_asclcl         ;check char range
         bcc _0480010          ;not LC alpha
;
         cmp #a_asclch+s_byte
         bcs _0480010          ;not LC alpha
;
         and #a_lctouc         ;force to UC
;
_0480010 plp                   ;restore flags
;
touppera rts
;
;================================================================================
;
;teststop: TEST FOR STOP KEY
;
;	----------------------------------------------
;	Preparatory Ops: none
;
;	Returned Values: .A: detected keypress, if any
;	                 .X: entry value
;	                 .Y: entry value
;
;	MPU Flags: NVmxDIZC
;	           ||||||||
;	           |||||||+---> 0: normal key detected
;	           |||||||      1: <STOP> detected
;	           +++++++----> not defined
;
;	Example: jsr teststop
;	         bcs stopped
;
;	Notes: The symbol STOPKEY defines the ASCII
;	       value of the "stop key."
;	----------------------------------------------
;
teststop jsr getcha            ;poll console
         bcs _0490010          ;no input
;
         cmp #stopkey          ;stop key pressed?
         beq _0490020          ;yes
;
_0490010 clc
;
_0490020 rts


;__LOAD_________________________________________________________
; LOAD A MOTOROLA FORMATTED HEX FILE (S28)
;
;_______________________________________________________________
LOADS19:
		php
		shortr
		pea mm_S19_prmpt
        jsr sprint            ;display input prompt


LOADS19_1:
		JSR	getc 				;
		CMP	#'S'				;
		BNE	LOADS19_1			; FIRST CHAR NOT (S)
		JSR	getc 				; READ CHAR
		CMP	#'8'				;
		BEQ	LOAD21				;
		CMP	#'2'				;
		BNE	LOADS19_1			; SECOND CHAR NOT (2)
		LDA	#$00				;
		STA	faca				; ZERO CHECKSUM

		JSR	GETBYTE				; READ BYTE
		SBC	#$02				;
		STA	facb				; BYTE COUNT
							; BUILD ADDRESS
		JSR	GETBYTE				; READ 2 FRAMES
		STA	addra+2				;
		JSR	GETBYTE				; READ 2 FRAMES
		STA	addra+1				;
		JSR	GETBYTE				;
		STA	addra	 			;

		LDY	#$00				;
LOAD11:
		JSR	GETBYTE				;
		DEC	facb				;
		BEQ	LOAD15				; ZERO BYTE COUNT
		STA	[addra],Y			; STORE DATA
		slonga
		inc 	addra 				;
		cmpw    $0000
		bne     LOAD11A
		shorta
		inc 	addra+2				;
LOAD11A:
		shorta
		JMP	LOAD11				;

LOAD15:
		INC	faca				;
		BEQ	LOADS19_1			;
LOAD19:
		LDA	#'?'				;
		JSR	putcha				;
LOAD21:
		plp
		jmp monce             			;back to executive
GETBYTE:
		JSR	INHEX				; GET HEX CHAR
		ASL	A				;
		ASL	A				;
		ASL	A				;
		ASL	A				;
		STA	numeral 			;
		JSR	INHEX				;
		AND	#$0F				; MASK TO 4 BITS
		ORA	numeral 			;
		PHA					;
		CLC					;
		ADC	faca				;
		STA	faca				;
		PLA					;
		RTS					;
; INPUT HEX CHAR
INHEX:
		JSR	getc 				;
   	 	CMP #$3A  				; LESS THAN 9?
   	   	BCS INHEX_BIG  				; NO, SKIP NEXT
   	   	SBC #$2F  				; CONVERT 0-9
INHEX_BIG:
		CMP #$41  				; A OR MORE?
    	  	BCC INHEX_SMALL 			; NO, SKIP NEXT
   	   	SBC #$37  				; CONVERT A-F
INHEX_SMALL:
		RTS					;
getc:
	 	 jsr getcha         ;poll for input
         bcc getcd          ;got something
         bra getc         ;try again
getcd:
		PHA					;
		JSR	putcha				;
		PLA					;
	    rts



;
;cpcode: COPY MEMORY CODE
;
;	-------------------------------------------
;	This code is transfered to workspace when a
;	copy or fill operation is to be performed.
;	-------------------------------------------
;
cpcode   phb                   ;must preserve data bank
         ;.rept s_mvinst
           nop                 ;placeholder
           nop                 ;placeholder
           nop                 ;placeholder
         ;.endr
         plb                   ;restore data bank
         jml monce             ;return to command executive
cpcodeee .equ *                    ;placeholder - do not delete
;
;================================================================================
;
;COMMAND PROCESSING DATA TABLES
;
;
;	monitor commands...
;
mpctab   .db "A"             ;assemble code
         .db "C"             ;compare memory ranges
         .db "D"             ;disassemble code
         .db "F"             ;fill memory
         .db "G"             ;execute code
         .db "H"             ;search memory
         .db "J"             ;execute code as subroutine
         .db "L"	     ;load S19 file
         .db "M"             ;dump memory range
         .db "R"             ;dump registers
         .db "T"             ;copy memory range
;         .db "X"             ;exit from monitor
         .db ">"             ;change memory
         .db ";"             ;change registers
n_mpctab .equ *-mpctab             ;entries in above table
;
;
;	monitor command jump table...
;
mpcextab .dw monasc-s_byte   ; A  assemble code
         .dw moncmp-s_byte   ; C  compare memory ranges
         .dw mondsc-s_byte   ; D  disassemble code
         .dw monfil-s_byte   ; F  fill memory
         .dw monjmp-s_byte   ; G  execute code
         .dw monhnt-s_byte   ; H  search memory
         .dw monjsr-s_byte   ; J  execute code as subroutine
         .dw LOADS19-s_byte  ; L  Load S19 File
         .dw mondmp-s_byte   ; M  dump memory range
         .dw monreg-s_byte   ; R  dump registers
         .dw moncpy-s_byte   ; T  copy memory range
;         .dw monxit-s_byte   ; X  exit from monitor
         .dw monchm-s_byte   ; >  change memory
         .dw monchr-s_byte   ; ;  change registers
;
;
;	number conversion...
;
basetab  .db 16,10,8,2       ;supported number bases
bitsdtab .db 4,3,3,1         ;bits per binary digit
bitsntab .db 4,4,3,1         ;bits per ASCII character
lzsttab  .db 3,2,9,2         ;leading zero suppression thresholds
numstab  .db 12,12,16,48     ;bin to ASCII conversion numerals
radxtab  .db c_hex           ;hexadecimal radix
         .db c_dec           ;decimal radix
         .db c_oct           ;octal radix
         .db c_bin           ;binary radix
n_radix  .equ *-radxtab            ;number of recognized radices
;
;
;	shadow MPU register sizes...
;
rcvltab  .db s_mpupbx+s_byte ; PB
         .db s_mpupcx+s_byte ; PC
         .db s_mpusrx+s_byte ; SR
         .db s_word+s_byte   ; .C
         .db s_word+s_byte   ; .X
         .db s_word+s_byte   ; .Y
         .db s_mpuspx+s_byte ; SP
         .db s_mpudpx+s_byte ; DP
         .db s_mpudbx+s_byte ; DB
n_regchv .equ *-rcvltab            ;total shadow registers
;
;================================================================================
;
;ASSEMBLER/DISASSEMBLER DATA TABLES
;
;
;	numerically sorted & encoded W65C816S mnemonics...
;
mnetab   .dw mne_xba         ;  0 - XBA
         .dw mne_lda         ;  1 - LDA
         .dw mne_pea         ;  2 - PEA
         .dw mne_pha         ;  3 - PHA
         .dw mne_pla         ;  4 - PLA
         .dw mne_bra         ;  5 - BRA
         .dw mne_ora         ;  6 - ORA
         .dw mne_sta         ;  7 - STA
         .dw mne_txa         ;  8 - TXA
         .dw mne_tya         ;  9 - TYA
         .dw mne_phb         ; 10 - PHB
         .dw mne_plb         ; 11 - PLB
         .dw mne_trb         ; 12 - TRB
         .dw mne_tsb         ; 13 - TSB
         .dw mne_sbc         ; 14 - SBC
         .dw mne_bcc         ; 15 - BCC
         .dw mne_adc         ; 16 - ADC
         .dw mne_tdc         ; 17 - TDC
         .dw mne_dec         ; 18 - DEC
         .dw mne_sec         ; 19 - SEC
         .dw mne_clc         ; 20 - CLC
         .dw mne_inc         ; 21 - INC
         .dw mne_tsc         ; 22 - TSC
         .dw mne_bvc         ; 23 - BVC
         .dw mne_tcd         ; 24 - TCD
         .dw mne_sed         ; 25 - SED
         .dw mne_phd         ; 26 - PHD
         .dw mne_cld         ; 27 - CLD
         .dw mne_pld         ; 28 - PLD
         .dw mne_and         ; 29 - AND
         .dw mne_xce         ; 30 - XCE
         .dw mne_bne         ; 31 - BNE
         .dw mne_wai         ; 32 - WAI
         .dw mne_pei         ; 33 - PEI
         .dw mne_sei         ; 34 - SEI
         .dw mne_cli         ; 35 - CLI
         .dw mne_bmi         ; 36 - BMI
         .dw mne_rti         ; 37 - RTI
         .dw mne_phk         ; 38 - PHK
         .dw mne_brk         ; 39 - BRK
         .dw mne_jml         ; 40 - JML
         .dw mne_rol         ; 41 - ROL
         .dw mne_bpl         ; 42 - BPL
         .dw mne_brl         ; 43 - BRL
         .dw mne_asl         ; 44 - ASL
         .dw mne_jsl         ; 45 - JSL
         .dw mne_rtl         ; 46 - RTL
         .dw mne_wdm         ; 47 - WDM
         .dw mne_mvn         ; 48 - MVN
         .dw mne_rep         ; 49 - REP
         .dw mne_sep         ; 50 - SEP
         .dw mne_php         ; 51 - PHP
         .dw mne_plp         ; 52 - PLP
         .dw mne_cmp         ; 53 - CMP
         .dw mne_jmp         ; 54 - JMP
         .dw mne_cop         ; 55 - COP
         .dw mne_nop         ; 56 - NOP
         .dw mne_stp         ; 57 - STP
         .dw mne_mvp         ; 58 - MVP
         .dw mne_beq         ; 59 - BEQ
         .dw mne_per         ; 60 - PER
         .dw mne_eor         ; 61 - EOR
         .dw mne_ror         ; 62 - ROR
         .dw mne_jsr         ; 63 - JSR
         .dw mne_lsr         ; 64 - LSR
         .dw mne_bcs         ; 65 - BCS
         .dw mne_tcs         ; 66 - TCS
         .dw mne_rts         ; 67 - RTS
         .dw mne_bvs         ; 68 - BVS
         .dw mne_txs         ; 69 - TXS
         .dw mne_bit         ; 70 - BIT
         .dw mne_clv         ; 71 - CLV
         .dw mne_tax         ; 72 - TAX
         .dw mne_ldx         ; 73 - LDX
         .dw mne_dex         ; 74 - DEX
         .dw mne_phx         ; 75 - PHX
         .dw mne_plx         ; 76 - PLX
         .dw mne_inx         ; 77 - INX
         .dw mne_cpx         ; 78 - CPX
         .dw mne_tsx         ; 79 - TSX
         .dw mne_stx         ; 80 - STX
         .dw mne_tyx         ; 81 - TYX
         .dw mne_tay         ; 82 - TAY
         .dw mne_ldy         ; 83 - LDY
         .dw mne_dey         ; 84 - DEY
         .dw mne_phy         ; 85 - PHY
         .dw mne_ply         ; 86 - PLY
         .dw mne_iny         ; 87 - INY
         .dw mne_cpy         ; 88 - CPY
         .dw mne_sty         ; 89 - STY
         .dw mne_txy         ; 90 - TXY
         .dw mne_stz         ; 91 - STZ
;
s_mnetab .equ *-mnetab             ;mnemonic table size
n_mnemon .equ s_mnetab/s_word      ;total mnemonics
;
;
;	mnemonic lookup indices in opcode order...
;
mnetabix .db mne_brkx        ; $00  BRK
         .db mne_orax        ; $01  ORA (dp,X)
         .db mne_copx        ; $02  COP
         .db mne_orax        ; $03  ORA <offset>,S
         .db mne_tsbx        ; $04  TSB dp
         .db mne_orax        ; $05  ORA dp
         .db mne_aslx        ; $06  ASL dp
         .db mne_orax        ; $07  ORA [dp]
         .db mne_phpx        ; $08  PHP
         .db mne_orax        ; $09  ORA #
         .db mne_aslx        ; $0A  ASL A
         .db mne_phdx        ; $0B  PHD
         .db mne_tsbx        ; $0C  TSB abs
         .db mne_orax        ; $0D  ORA abs
         .db mne_aslx        ; $0E  ASL abs
         .db mne_orax        ; $0F  ORA absl
;
         .db mne_bplx        ; $10  BPL abs
         .db mne_orax        ; $11  ORA (<dp>),Y
         .db mne_orax        ; $12  ORA (dp)
         .db mne_orax        ; $13  ORA (<offset>,S),Y
         .db mne_trbx        ; $14  TRB dp
         .db mne_orax        ; $15  ORA dp,X
         .db mne_aslx        ; $16  ASL dp,X
         .db mne_orax        ; $17  ORA [dp],Y
         .db mne_clcx        ; $18  CLC
         .db mne_orax        ; $19  ORA abs
         .db mne_incx        ; $1A  INC A
         .db mne_tcsx        ; $1B  TCS
         .db mne_trbx        ; $1C  TRB abs
         .db mne_orax        ; $1D  ORA abs,X
         .db mne_aslx        ; $1E  ASL abs,X
         .db mne_orax        ; $1F  ORA absl,X
;
         .db mne_jsrx        ; $20  JSR abs
         .db mne_andx        ; $21  AND (dp,X)
         .db mne_jslx        ; $22  JSL absl
         .db mne_andx        ; $23  AND <offset>,S
         .db mne_bitx        ; $24  BIT dp
         .db mne_andx        ; $25  AND dp
         .db mne_rolx        ; $26  ROL dp
         .db mne_andx        ; $27  AND [dp]
         .db mne_plpx        ; $28  PLP
         .db mne_andx        ; $29  AND #
         .db mne_rolx        ; $2A  ROL A
         .db mne_pldx        ; $2B  PLD
         .db mne_bitx        ; $2C  BIT abs
         .db mne_andx        ; $2D  AND abs
         .db mne_rolx        ; $2E  ROL abs
         .db mne_andx        ; $2F  AND absl
;
         .db mne_bmix        ; $30  BMI abs
         .db mne_andx        ; $31  AND (<dp>),Y
         .db mne_andx        ; $32  AND (dp)
         .db mne_andx        ; $33  AND (<offset>,S),Y
         .db mne_bitx        ; $34  BIT dp,X
         .db mne_andx        ; $35  AND dp,X
         .db mne_rolx        ; $36  ROL dp,X
         .db mne_andx        ; $37  AND [dp],Y
         .db mne_secx        ; $38  SEC
         .db mne_andx        ; $39  AND abs,Y
         .db mne_decx        ; $3A  DEC A
         .db mne_tscx        ; $3B  TSC
         .db mne_bitx        ; $3C  BIT abs,X
         .db mne_andx        ; $3D  AND abs,X
         .db mne_rolx        ; $3E  ROL abs,X
         .db mne_andx        ; $3F  AND absl,X
;
         .db mne_rtix        ; $40  RTI
         .db mne_eorx        ; $41  EOR (dp,X)
         .db mne_wdmx        ; $42  WDM
         .db mne_eorx        ; $43  EOR <offset>,S
         .db mne_mvpx        ; $44  MVP sb,db
         .db mne_eorx        ; $45  EOR dp
         .db mne_lsrx        ; $46  LSR dp
         .db mne_eorx        ; $47  EOR [dp]
         .db mne_phax        ; $48  PHA
         .db mne_eorx        ; $49  EOR #
         .db mne_lsrx        ; $4A  LSR A
         .db mne_phkx        ; $4B  PHK
         .db mne_jmpx        ; $4C  JMP abs
         .db mne_eorx        ; $4D  EOR abs
         .db mne_lsrx        ; $4E  LSR abs
         .db mne_eorx        ; $4F  EOR absl
;
         .db mne_bvcx        ; $50  BVC abs
         .db mne_eorx        ; $51  EOR (<dp>),Y
         .db mne_eorx        ; $52  EOR (dp)
         .db mne_eorx        ; $53  EOR (<offset>,S),Y
         .db mne_mvnx        ; $54  MVN sb,db
         .db mne_eorx        ; $55  EOR dp,X
         .db mne_lsrx        ; $56  LSR dp,X
         .db mne_eorx        ; $57  EOR [dp],Y
         .db mne_clix        ; $58  CLI
         .db mne_eorx        ; $59  EOR abs,Y
         .db mne_phyx        ; $5A  PHY
         .db mne_tcdx        ; $5B  TCD
         .db mne_jmlx        ; $5C  JML absl
         .db mne_eorx        ; $5D  EOR abs,X
         .db mne_lsrx        ; $5E  LSR abs,X
         .db mne_eorx        ; $5F  EOR absl,X
;
         .db mne_rtsx        ; $60  RTS
         .db mne_adcx        ; $61  ADC (dp,X)
         .db mne_perx        ; $62  PER
         .db mne_adcx        ; $63  ADC <offset>,S
         .db mne_stzx        ; $64  STZ dp
         .db mne_adcx        ; $65  ADC dp
         .db mne_rorx        ; $66  ROR dp
         .db mne_adcx        ; $67  ADC [dp]
         .db mne_plax        ; $68  PLA
         .db mne_adcx        ; $69  ADC #
         .db mne_rorx        ; $6A  ROR A
         .db mne_rtlx        ; $6B  RTL
         .db mne_jmpx        ; $6C  JMP (abs)
         .db mne_adcx        ; $6D  ADC abs
         .db mne_rorx        ; $6E  ROR abs
         .db mne_adcx        ; $6F  ADC absl
;
         .db mne_bvsx        ; $70  BVS abs
         .db mne_adcx        ; $71  ADC (<dp>),Y
         .db mne_adcx        ; $72  ADC (dp)
         .db mne_adcx        ; $73  ADC (<offset>,S),Y
         .db mne_stzx        ; $74  STZ dp,X
         .db mne_adcx        ; $75  ADC dp,X
         .db mne_rorx        ; $76  ROR dp,X
         .db mne_adcx        ; $77  ADC [dp],Y
         .db mne_seix        ; $78  SEI
         .db mne_adcx        ; $79  ADC abs,Y
         .db mne_plyx        ; $7A  PLY
         .db mne_tdcx        ; $7B  TDC
         .db mne_jmpx        ; $7C  JMP (abs,X)
         .db mne_adcx        ; $7D  ADC abs,X
         .db mne_rorx        ; $7E  ROR abs,X
         .db mne_adcx        ; $7F  ADC absl,X
;
         .db mne_brax        ; $80  BRA abs
         .db mne_stax        ; $81  STA (dp,X)
         .db mne_brlx        ; $82  BRL abs
         .db mne_stax        ; $83  STA <offset>,S
         .db mne_styx        ; $84  STY dp
         .db mne_stax        ; $85  STA dp
         .db mne_stxx        ; $86  STX dp
         .db mne_stax        ; $87  STA [dp]
         .db mne_deyx        ; $88  DEY
         .db mne_bitx        ; $89  BIT #
         .db mne_txax        ; $8A  TXA
         .db mne_phbx        ; $8B  PHB
         .db mne_styx        ; $8C  STY abs
         .db mne_stax        ; $8D  STA abs
         .db mne_stxx        ; $8E  STX abs
         .db mne_stax        ; $8F  STA absl
;
         .db mne_bccx        ; $90  BCC abs
         .db mne_stax        ; $91  STA (<dp>),Y
         .db mne_stax        ; $92  STA (dp)
         .db mne_stax        ; $93  STA (<offset>,S),Y
         .db mne_styx        ; $94  STY dp,X
         .db mne_stax        ; $95  STA dp,X
         .db mne_stxx        ; $96  STX dp,Y
         .db mne_stax        ; $97  STA [dp],Y
         .db mne_tyax        ; $98  TYA
         .db mne_stax        ; $99  STA abs,Y
         .db mne_txsx        ; $9A  TXS
         .db mne_txyx        ; $9B  TXY
         .db mne_stzx        ; $9C  STZ abs
         .db mne_stax        ; $9D  STA abs,X
         .db mne_stzx        ; $9E  STZ abs,X
         .db mne_stax        ; $9F  STA absl,X
;
         .db mne_ldyx        ; $A0  LDY #
         .db mne_ldax        ; $A1  LDA (dp,X)
         .db mne_ldxx        ; $A2  LDX #
         .db mne_ldax        ; $A3  LDA <offset>,S
         .db mne_ldyx        ; $A4  LDY dp
         .db mne_ldax        ; $A5  LDA dp
         .db mne_ldxx        ; $A6  LDX dp
         .db mne_ldax        ; $A7  LDA [dp]
         .db mne_tayx        ; $A8  TAY
         .db mne_ldax        ; $A9  LDA #
         .db mne_taxx        ; $AA  TAX
         .db mne_plbx        ; $AB  PLB
         .db mne_ldyx        ; $AC  LDY abs
         .db mne_ldax        ; $AD  LDA abs
         .db mne_ldxx        ; $AE  LDX abs
         .db mne_ldax        ; $AF  LDA absl
;
         .db mne_bcsx        ; $B0  BCS abs
         .db mne_ldax        ; $B1  LDA (<dp>),Y
         .db mne_ldax        ; $B2  LDA (dp)
         .db mne_ldax        ; $B3  LDA (<offset>,S),Y
         .db mne_ldyx        ; $B4  LDY dp,X
         .db mne_ldax        ; $B5  LDA dp,X
         .db mne_ldxx        ; $B6  LDX dp,Y
         .db mne_ldax        ; $B7  LDA [dp],Y
         .db mne_clvx        ; $B8  CLV
         .db mne_ldax        ; $B9  LDA abs,Y
         .db mne_tsxx        ; $BA  TSX
         .db mne_tyxx        ; $BB  TYX
         .db mne_ldyx        ; $BC  LDY abs,X
         .db mne_ldax        ; $BD  LDA abs,X
         .db mne_ldxx        ; $BE  LDX abs,Y
         .db mne_ldax        ; $BF  LDA absl,X
;
         .db mne_cpyx        ; $C0  CPY #
         .db mne_cmpx        ; $C1  CMP (dp,X)
         .db mne_repx        ; $C2  REP #
         .db mne_cmpx        ; $C3  CMP <offset>,S
         .db mne_cpyx        ; $C4  CPY dp
         .db mne_cmpx        ; $C5  CMP dp
         .db mne_decx        ; $C6  DEC dp
         .db mne_cmpx        ; $C7  CMP [dp]
         .db mne_inyx        ; $C8  INY
         .db mne_cmpx        ; $C9  CMP #
         .db mne_dexx        ; $CA  DEX
         .db mne_waix        ; $CB  WAI
         .db mne_cpyx        ; $CC  CPY abs
         .db mne_cmpx        ; $CD  CMP abs
         .db mne_decx        ; $CE  DEC abs
         .db mne_cmpx        ; $CF  CMP absl
;
         .db mne_bnex        ; $D0  BNE abs
         .db mne_cmpx        ; $D1  CMP (<dp>),Y
         .db mne_cmpx        ; $D2  CMP (dp)
         .db mne_cmpx        ; $D3  CMP (<offset>,S),Y
         .db mne_peix        ; $D4  PEI dp
         .db mne_cmpx        ; $D5  CMP dp,X
         .db mne_decx        ; $D6  DEC dp,X
         .db mne_cmpx        ; $D7  CMP [dp],Y
         .db mne_cldx        ; $D8  CLD
         .db mne_cmpx        ; $D9  CMP abs,Y
         .db mne_phxx        ; $DA  PHX
         .db mne_stpx        ; $DB  STP
         .db mne_jmpx        ; $DC  JMP [abs]
         .db mne_cmpx        ; $DD  CMP abs,X
         .db mne_decx        ; $DE  DEC abs,X
         .db mne_cmpx        ; $DF  CMP absl,X
;
         .db mne_cpxx        ; $E0  CPX #
         .db mne_sbcx        ; $E1  SBC (dp,X)
         .db mne_sepx        ; $E2  SEP #
         .db mne_sbcx        ; $E3  SBC <offset>,S
         .db mne_cpxx        ; $E4  CPX dp
         .db mne_sbcx        ; $E5  SBC dp
         .db mne_incx        ; $E6  INC dp
         .db mne_sbcx        ; $E7  SBC [dp]
         .db mne_inxx        ; $E8  INX
         .db mne_sbcx        ; $E9  SBC #
         .db mne_nopx        ; $EA  NOP
         .db mne_xbax        ; $EB  XBA
         .db mne_cpxx        ; $EC  CPX abs
         .db mne_sbcx        ; $ED  SBC abs
         .db mne_incx        ; $EE  INC abs
         .db mne_sbcx        ; $EF  SBC absl
;
         .db mne_beqx        ; $F0  BEQ abs
         .db mne_sbcx        ; $F1  SBC (<dp>),Y
         .db mne_sbcx        ; $F2  SBC (dp)
         .db mne_sbcx        ; $F3  SBC (<offset>,S),Y
         .db mne_peax        ; $F4  PEA #
         .db mne_sbcx        ; $F5  SBC dp,X
         .db mne_incx        ; $F6  INC dp,X
         .db mne_sbcx        ; $F7  SBC [dp],Y
         .db mne_sedx        ; $F8  SED
         .db mne_sbcx        ; $F9  SBC abs,Y
         .db mne_plxx        ; $FA  PLX
         .db mne_xcex        ; $FB  XCE
         .db mne_jsrx        ; $FC  JSR (abs,X)
         .db mne_sbcx        ; $FD  SBC abs,X
         .db mne_incx        ; $FE  INC abs,X
         .db mne_sbcx        ; $FF  SBC absl,X
;
;
;	instruction addressing modes & sizes in opcode order...
;
;	    xxxxxxxx
;	    ||||||||
;	    ||||++++---> Addressing Mode
;	    ||||         ----------------------------------
;	    ||||          0000  dp, abs, absl, implied or A
;	    ||||          0001  #
;	    ||||          0010  dp,X, abs,X or absl,X
;	    ||||          0011  dp,Y or abs,Y
;	    ||||          0100  (dp) or (abs)
;	    ||||          0101  [dp] or [abs]
;	    ||||          0110  [dp],Y
;	    ||||          0111  (dp,X) or (abs,X)
;	    ||||          1000  (<dp>),Y
;	    ||||          1001  <offset>,S
;	    ||||          1010  (<offset>,S),Y
;	    ||||          1011  sbnk,dbnk (MVN or MVP)
;	    ||||          ---------------------------------
;	    ||||           #    = immediate
;	    ||||           A    = accumulator
;	    ||||           abs  = absolute
;	    ||||           absl = absolute long
;	    ||||           dbnk = destination bank
;	    ||||           dp   = direct (zero) page
;	    ||||           S    = stack relative
;	    ||||           sbnk = source bank
;	    ||||         ----------------------------------
;	    ||||
;	    ||++-------> binary-encoded operand size
;	    |+---------> 1: relative branch instruction
;	    +----------> 1: variable operand size...
;
;	    -------------------------------------------------------------
;	    Variable operand size refers to an immediate mode instruction
;	    that can accept either an 8 or 16 bit operand.  During instr-
;	    uction assembly, an 8 bit operand can be forced to 16 bits by
;	    preceding the operand field with !,  e.g.,  LDA !#$01,  which
;	    will assemble as $A9 $01 $00.
;	    -------------------------------------------------------------
;
mnetabam .db ops0|am_nam   ; $00  BRK
         .db ops1|am_indx  ; $01  ORA (dp,X)
         .db ops1|am_nam   ; $02  COP
         .db ops1|am_stk   ; $03  ORA <offset>,S
         .db ops1|am_nam   ; $04  TSB dp
         .db ops1|am_nam   ; $05  ORA dp
         .db ops1|am_nam   ; $06  ASL dp
         .db ops1|am_indl  ; $07  ORA [dp]
         .db ops0|am_nam   ; $08  PHP
         .db vops|am_imm   ; $09  ORA #
         .db ops0|am_nam   ; $0A  ASL A
         .db ops0|am_nam   ; $0B  PHD
         .db ops2|am_nam   ; $0C  TSB abs
         .db ops2|am_nam   ; $0D  ORA abs
         .db ops2|am_nam   ; $0E  ASL abs
         .db ops3|am_nam   ; $0F  ORA absl
;
         .db bop1|am_nam   ; $10  BPL abs
         .db ops1|am_indy  ; $11  ORA (<dp>),Y
         .db ops1|am_ind   ; $12  ORA (dp)
         .db ops1|am_stky  ; $13  ORA (<offset>,S),Y
         .db ops1|am_nam   ; $14  TRB dp
         .db ops1|am_adrx  ; $15  ORA dp,X
         .db ops1|am_adrx  ; $16  ASL dp,X
         .db ops1|am_indly ; $17  ORA [dp],Y
         .db ops0|am_nam   ; $18  CLC
         .db ops2|am_nam   ; $19  ORA abs
         .db ops0|am_nam   ; $1A  INC A
         .db ops0|am_nam   ; $1B  TCS
         .db ops2|am_nam   ; $1C  TRB abs
         .db ops2|am_adrx  ; $1D  ORA abs,X
         .db ops2|am_adrx  ; $1E  ASL abs,X
         .db ops3|am_adrx  ; $1F  ORA absl,X
;
         .db ops2|am_nam   ; $20  JSR abs
         .db ops1|am_indx  ; $21  AND (dp,X)
         .db ops3|am_nam   ; $22  JSL absl
         .db ops1|am_stk   ; $23  AND <offset>,S
         .db ops1|am_nam   ; $24  BIT dp
         .db ops1|am_nam   ; $25  AND dp
         .db ops1|am_nam   ; $26  ROL dp
         .db ops1|am_indl  ; $27  AND [dp]
         .db ops0|am_nam   ; $28  PLP
         .db vops|am_imm   ; $29  AND #
         .db ops0|am_nam   ; $2A  ROL A
         .db ops0|am_nam   ; $2B  PLD
         .db ops2|am_nam   ; $2C  BIT abs
         .db ops2|am_nam   ; $2D  AND abs
         .db ops2|am_nam   ; $2E  ROL abs
         .db ops3|am_nam   ; $2F  AND absl
;
         .db bop1|am_nam   ; $30  BMI abs
         .db ops1|am_indy  ; $31  AND (<dp>),Y
         .db ops1|am_ind   ; $32  AND (dp)
         .db ops1|am_stky  ; $33  AND (<offset>,S),Y
         .db ops1|am_adrx  ; $34  BIT dp,X
         .db ops1|am_adrx  ; $35  AND dp,X
         .db ops1|am_adrx  ; $36  ROL dp,X
         .db ops1|am_indly ; $37  AND [dp],Y
         .db ops0|am_nam   ; $38  SEC
         .db ops2|am_adry  ; $39  AND abs,Y
         .db ops0|am_nam   ; $3A  DEC A
         .db ops0|am_nam   ; $3B  TSC
         .db ops2|am_adrx  ; $3C  BIT abs,X
         .db ops2|am_adrx  ; $3D  AND abs,X
         .db ops2|am_adrx  ; $3E  ROL abs,X
         .db ops3|am_adrx  ; $3F  AND absl,X
;
         .db ops0|am_nam   ; $40  RTI
         .db ops1|am_indx  ; $41  EOR (dp,X)
         .db ops0|am_nam   ; $42  WDM
         .db ops1|am_stk   ; $43  EOR <offset>,S
         .db ops2|am_move  ; $44  MVP sb,db
         .db ops1|am_nam   ; $45  EOR dp
         .db ops1|am_nam   ; $46  LSR dp
         .db ops1|am_indl  ; $47  EOR [dp]
         .db ops0|am_nam   ; $48  PHA
         .db vops|am_imm   ; $49  EOR #
         .db ops0|am_nam   ; $4A  LSR A
         .db ops0|am_nam   ; $4B  PHK
         .db ops2|am_nam   ; $4C  JMP abs
         .db ops2|am_nam   ; $4D  EOR abs
         .db ops2|am_nam   ; $4E  LSR abs
         .db ops3|am_nam   ; $4F  EOR absl
;
         .db bop1|am_nam   ; $50  BVC abs
         .db ops1|am_indy  ; $51  EOR (<dp>),Y
         .db ops1|am_ind   ; $52  EOR (dp)
         .db ops1|am_stky  ; $53  EOR (<offset>,S),Y
         .db ops2|am_move  ; $54  MVN sb,db
         .db ops1|am_adrx  ; $55  EOR dp,X
         .db ops1|am_adrx  ; $56  LSR dp,X
         .db ops1|am_indly ; $57  EOR [dp],Y
         .db ops0|am_nam   ; $58  CLI
         .db ops2|am_adry  ; $59  EOR abs,Y
         .db ops0|am_nam   ; $5A  PHY
         .db ops0|am_nam   ; $5B  TCD
         .db ops3|am_nam   ; $5C  JML absl
         .db ops2|am_adrx  ; $5D  EOR abs,X
         .db ops2|am_adrx  ; $5E  LSR abs,X
         .db ops3|am_adrx  ; $5F  EOR absl,X
;
         .db ops0|am_nam   ; $60  RTS
         .db ops1|am_indx  ; $61  ADC (dp,X)
         .db bop2|am_nam   ; $62  PER
         .db ops1|am_stk   ; $63  ADC <offset>,S
         .db ops1|am_nam   ; $64  STZ dp
         .db ops1|am_nam   ; $65  ADC dp
         .db ops1|am_nam   ; $66  ROR dp
         .db ops1|am_indl  ; $67  ADC [dp]
         .db ops0|am_nam   ; $68  PLA
         .db vops|am_imm   ; $69  ADC #
         .db ops0|am_nam   ; $6A  ROR A
         .db ops0|am_nam   ; $6B  RTL
         .db ops2|am_ind   ; $6C  JMP (abs)
         .db ops2|am_nam   ; $6D  ADC abs
         .db ops2|am_nam   ; $6E  ROR abs
         .db ops3|am_nam   ; $6F  ADC absl
;
         .db bop1|am_nam   ; $70  BVS abs
         .db ops1|am_indy  ; $71  ADC (<dp>),Y
         .db ops1|am_ind   ; $72  ADC (dp)
         .db ops1|am_stky  ; $73  ADC (<offset>,S),Y
         .db ops1|am_adrx  ; $74  STZ dp,X
         .db ops1|am_adrx  ; $75  ADC dp,X
         .db ops1|am_adrx  ; $76  ROR dp,X
         .db ops1|am_indly ; $77  ADC [dp],Y
         .db ops0|am_nam   ; $78  SEI
         .db ops2|am_adry  ; $79  ADC abs,Y
         .db ops0|am_nam   ; $7A  PLY
         .db ops0|am_nam   ; $7B  TDC
         .db ops2|am_indx  ; $7C  JMP (abs,X)
         .db ops2|am_adrx  ; $7D  ADC abs,X
         .db ops2|am_adrx  ; $7E  ROR abs,X
         .db ops3|am_adrx  ; $7F  ADC absl,X
;
         .db bop1|am_nam   ; $80  BRA abs
         .db ops1|am_indx  ; $81  STA (dp,X)
         .db bop2|am_nam   ; $82  BRL abs
         .db ops1|am_stk   ; $83  STA <offset>,S
         .db ops1|am_nam   ; $84  STY dp
         .db ops1|am_nam   ; $85  STA dp
         .db ops1|am_nam   ; $86  STX dp
         .db ops1|am_indl  ; $87  STA [dp]
         .db ops0|am_nam   ; $88  DEY
         .db vops|am_imm   ; $89  BIT #
         .db ops0|am_nam   ; $8A  TXA
         .db ops0|am_nam   ; $8B  PHB
         .db ops2|am_nam   ; $8C  STY abs
         .db ops2|am_nam   ; $8D  STA abs
         .db ops2|am_nam   ; $8E  STX abs
         .db ops3|am_nam   ; $8F  STA absl
;
         .db bop1|am_nam   ; $90  BCC abs
         .db ops1|am_indy  ; $91  STA (<dp>),Y
         .db ops1|am_ind   ; $92  STA (dp)
         .db ops1|am_stky  ; $93  STA (<offset>,S),Y
         .db ops1|am_adrx  ; $94  STY dp,X
         .db ops1|am_adrx  ; $95  STA dp,X
         .db ops1|am_adry  ; $96  STX dp,Y
         .db ops1|am_indly ; $97  STA [dp],Y
         .db ops0|am_nam   ; $98  TYA
         .db ops2|am_adry  ; $99  STA abs,Y
         .db ops0|am_nam   ; $9A  TXS
         .db ops0|am_nam   ; $9B  TXY
         .db ops2|am_nam   ; $9C  STZ abs
         .db ops2|am_adrx  ; $9D  STA abs,X
         .db ops2|am_adrx  ; $9E  STZ abs,X
         .db ops3|am_adrx  ; $9F  STA absl,X
;
         .db vops|am_imm   ; $A0  LDY #
         .db ops1|am_indx  ; $A1  LDA (dp,X)
         .db vops|am_imm   ; $A2  LDX #
         .db ops1|am_stk   ; $A3  LDA <offset>,S
         .db ops1|am_nam   ; $A4  LDY dp
         .db ops1|am_nam   ; $A5  LDA dp
         .db ops1|am_nam   ; $A6  LDX dp
         .db ops1|am_indl  ; $A7  LDA [dp]
         .db ops0|am_nam   ; $A8  TAY
         .db vops|am_imm   ; $A9  LDA #
         .db ops0|am_nam   ; $AA  TAX
         .db ops0|am_nam   ; $AB  PLB
         .db ops2|am_nam   ; $AC  LDY abs
         .db ops2|am_nam   ; $AD  LDA abs
         .db ops2|am_nam   ; $AE  LDX abs
         .db ops3|am_nam   ; $AF  LDA absl
;
         .db bop1|am_nam   ; $B0  BCS abs
         .db ops1|am_indy  ; $B1  LDA (<dp>),Y
         .db ops1|am_ind   ; $B2  LDA (dp)
         .db ops1|am_stky  ; $B3  LDA (<offset>,S),Y
         .db ops1|am_adrx  ; $B4  LDY dp,X
         .db ops1|am_adrx  ; $B5  LDA dp,X
         .db ops1|am_adry  ; $B6  LDX dp,Y
         .db ops1|am_indly ; $B7  LDA [dp],Y
         .db ops0|am_nam   ; $B8  CLV
         .db ops2|am_adry  ; $B9  LDA abs,Y
         .db ops0|am_nam   ; $BA  TSX
         .db ops0|am_nam   ; $BB  TYX
         .db ops2|am_adrx  ; $BC  LDY abs,X
         .db ops2|am_adrx  ; $BD  LDA abs,X
         .db ops2|am_adry  ; $BE  LDX abs,Y
         .db ops3|am_adrx  ; $BF  LDA absl,X
;
         .db vops|am_imm   ; $C0  CPY #
         .db ops1|am_indx  ; $C1  CMP (dp,X)
         .db ops1|am_imm   ; $C2  REP #
         .db ops1|am_stk   ; $C3  CMP <offset>,S
         .db ops1|am_nam   ; $C4  CPY dp
         .db ops1|am_nam   ; $C5  CMP dp
         .db ops1|am_nam   ; $C6  DEC dp
         .db ops1|am_indl  ; $C7  CMP [dp]
         .db ops0|am_nam   ; $C8  INY
         .db vops|am_imm   ; $C9  CMP #
         .db ops0|am_nam   ; $CA  DEX
         .db ops0|am_nam   ; $CB  WAI
         .db ops2|am_nam   ; $CC  CPY abs
         .db ops2|am_nam   ; $CD  CMP abs
         .db ops2|am_nam   ; $CE  DEC abs
         .db ops3|am_nam   ; $CF  CMP absl
;
         .db bop1|am_nam   ; $D0  BNE abs
         .db ops1|am_indy  ; $D1  CMP (<dp>),Y
         .db ops1|am_ind   ; $D2  CMP (dp)
         .db ops1|am_stky  ; $D3  CMP (<offset>,S),Y
         .db ops1|am_nam   ; $D4  PEI dp
         .db ops1|am_adrx  ; $D5  CMP dp,X
         .db ops1|am_adrx  ; $D6  DEC dp,X
         .db ops1|am_indly ; $D7  CMP [dp],Y
         .db ops0|am_nam   ; $D8  CLD
         .db ops2|am_adry  ; $D9  CMP abs,Y
         .db ops0|am_nam   ; $DA  PHX
         .db ops0|am_nam   ; $DB  STP
         .db ops2|am_indl  ; $DC  JMP [abs]
         .db ops2|am_adrx  ; $DD  CMP abs,X
         .db ops2|am_adrx  ; $DE  DEC abs,X
         .db ops3|am_adrx  ; $DF  CMP absl,X
;
         .db vops|am_imm   ; $E0  CPX #
         .db ops1|am_indx  ; $E1  SBC (dp,X)
         .db ops1|am_imm   ; $E2  SEP #
         .db ops1|am_stk   ; $E3  SBC <offset>,S
         .db ops1|am_nam   ; $E4  CPX dp
         .db ops1|am_nam   ; $E5  SBC dp
         .db ops1|am_nam   ; $E6  INC dp
         .db ops1|am_indl  ; $E7  SBC [dp]
         .db ops0|am_nam   ; $E8  INX
         .db vops|am_imm   ; $E9  SBC #
         .db ops0|am_nam   ; $EA  NOP
         .db ops0|am_nam   ; $EB  XBA
         .db ops2|am_nam   ; $EC  CPX abs
         .db ops2|am_nam   ; $ED  SBC abs
         .db ops2|am_nam   ; $EE  INC abs
         .db ops3|am_nam   ; $EF  SBC absl
;
         .db bop1|am_nam   ; $F0  BEQ abs
         .db ops1|am_indy  ; $F1  SBC (<dp>),Y
         .db ops1|am_ind   ; $F2  SBC (dp)
         .db ops1|am_stky  ; $F3  SBC (<offset>,S),Y
         .db ops2|am_imm   ; $F4  PEA #
         .db ops1|am_adrx  ; $F5  SBC dp,X
         .db ops1|am_adrx  ; $F6  INC dp,X
         .db ops1|am_indly ; $F7  SBC [dp],Y
         .db ops0|am_nam   ; $F8  SED
         .db ops2|am_adry  ; $F9  SBC abs,Y
         .db ops0|am_nam   ; $FA  PLX
         .db ops0|am_nam   ; $FB  XCE
         .db ops2|am_indx  ; $FC  JSR (abs,X)
         .db ops2|am_adrx  ; $FD  SBC abs,X
         .db ops2|am_adrx  ; $FE  INC abs,X
         .db ops3|am_adrx  ; $FF  SBC absl,X
;
;
;	.X & .Y immediate mode opcodes...
;
vopidx   .db opc_cpxi        ;CPX #
         .db opc_cpyi        ;CPY #
         .db opc_ldxi        ;LDX #
         .db opc_ldyi        ;LDY #
n_vopidx .equ *-vopidx             ;number of opcodes
;
;
;	addressing mode symbology lookup...
;
ms_lutab .dw ms_nam          ;no symbol
         .dw ms_imm          ;#
         .dw ms_addrx        ;<addr>,X
         .dw ms_addry        ;<addr>,Y
         .dw ms_ind          ;(<addr>)
         .dw ms_indl         ;[<dp>]
         .dw ms_indly        ;[<dp>],Y
         .dw ms_indx         ;(<addr>,X)
         .dw ms_indy         ;(<dp>),Y
         .dw ms_stk          ;<offset>,S
         .dw ms_stky         ;(<offset>,S),Y
         .dw ms_nam          ;<sbnk>,<dbnk>
;
;
;	addressing mode symbology strings...
;
ms_nam   .db " ",0           ;no symbol
ms_addrx .db " ,X",0         ;<addr>,X
ms_addry .db " ,Y",0         ;<addr>,Y
ms_imm   .db "#",0           ;#
ms_ind   .db "()",0          ;(<addr>)
ms_indl  .db "[]",0          ;[<dp>]
ms_indly .db "[],Y",0        ;[<dp>],Y
ms_indx  .db "(,X)",0        ;(<addr>,X)
ms_indy  .db "(),Y",0        ;(<dp>),Y
ms_move  .db ",$",0          ;<sbnk>,<dbnk>
ms_stk   .db " ,S",0         ;<offset>,S
ms_stky  .db "(,S),Y",0      ;(<offset>,S),Y
;
;================================================================================
;
;CONSOLE DISPLAY CONTROL STRINGS
;
dc_lf    lf                    ;newline
         .db 0
;
dc_bs                          ;destructive backspace
         .db a_bs
         .db $20
         .db a_bs
         .db 0
;
dc_cl_DUMB                      ;clear to end of line
	 .db $0d,$0a
         .db 0
dc_cl_ANSI           		;clear to end of line
	 .db a_esc,"[K"
         .db 0
dc_cl_WYSE           		;clear to end of line
	 .db a_esc,"T"
         .db 0

;
;

;
;================================================================================
;
;TEXT STRINGS
;
mm_brk   rb
         lf
         .db "*BRK"
         lf
         .db 0
;
mm_entry lf
         .db "Supermon 816 "
         softvers
         .db " "
         lf
         .db 0
;
mm_err   .db " *ERR ",0
;
mm_prmpt lf
         .db ".",0
;
mm_regs  lf
         .db "PB  PC   NVmxDIZC  .C   .X   .Y   SP"
         lf
         .db 0
mm_regs1 lf
         .db " DP  DB"
         lf
         .db 0

;
mm_rts   rb
         lf
         .db "*RTS"
         lf
         .db 0


mm_S19_prmpt	lf
         .db "Begin sending S28 encoded file. . ."
         lf
         .db 0

;
ALIVEM:
        .db   $0D,$0A
        .db   $0D,$0A
		.db   "   __ _____  ___  __   __",$0D,$0A
		.db   "  / /| ____|/ _ \/_ | / /",$0D,$0A
		.db   " / /_| |__ | (_) || |/ /_",$0D,$0A
		.db   "|  _ \___ \ > _ < | |  _ \",$0D,$0A
		.db   "| (_) |__) | (_) || | (_) |",$0D,$0A
		.db   " \___/____/ \___/ |_|\___/ ",$0D,$0A
        .db   $0D,$0A
		.db   "65c816 BIOS (NATIVE MODE)",$0D,$0A
		.db   "v0.55 4/9/2021 - D.WERNER",$0D,$0A
		.db   "-------------------------------------",$0D,$0A
		.db   $0D,$0A,0
;


_txtend_ .equ *                     ;end of program text
;
;================================================================================
	.end
