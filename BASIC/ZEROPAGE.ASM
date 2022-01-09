;____________________________________________________________________________________________
;
; ZERO PAGE DEFINITIONS
;____________________________________________________________________________________________

LAB_WARM 	.EQU $00		; BASIC warm start entry point
Wrmjpl 		.EQU LAB_WARM+1; BASIC warm start vector jump low byte
Wrmjph 		.EQU LAB_WARM+2; BASIC warm start vector jump high byte
TMPFLG      	.EQU $04
VIDEOMODE	.EQU $06
LOCALWORK	.EQU $07		; word (2 bytes)
Usrjmp		.EQU $0A		; USR function JMP address
Usrjpl		.EQU <Usrjmp+1	; USR function JMP vector low byte
Usrjph		.EQU <Usrjmp+2	; USR function JMP vector high byte
Nullct		.EQU $0D		; nulls output after each line
TPos		.EQU $0E		; BASIC terminal position byte
TWidth		.EQU $0F		; BASIC terminal width byte
Iclim		.EQU $10		; input column limit
Itempl		.EQU $11		; temporary integer low byte
Itemph		.EQU <Itempl+1	; temporary integer high byte

nums_1		.EQU <Itempl	; number to bin/hex string convert MSB
nums_2		.EQU <nums_1+1	; number to bin/hex string convert
nums_3		.EQU <nums_1+2	; number to bin/hex string convert LSB

Srchc		.EQU $5B		; search character
Temp3		.EQU <Srchc	; temp byte used in number routines
Scnquo		.EQU $5C		; scan-between-quotes flag
Asrch		.EQU <Scnquo	; alt search character

XOAw_l		.EQU <Srchc	; eXclusive OR, OR and AND word low byte
XOAw_h		.EQU <Scnquo	; eXclusive OR, OR and AND word high byte

Ibptr		.EQU $5D		; input buffer pointer
Dimcnt		.EQU <Ibptr	; # of dimensions
Tindx		.EQU <Ibptr	; token index

Defdim		.EQU $5E		; default DIM flag
Dtypef		.EQU $5F		; data type flag, $FF=string, $00=numeric
Oquote		.EQU $60		; open quote flag (b7) (Flag: DATA scan; LIST quote; memory)
Gclctd		.EQU $60		; garbage collected flag
Sufnxf		.EQU $61		; subscript/FNX flag, 1xxx xxx = FN(0xxx xxx)
Imode		.EQU $62		; input mode flag, $00=INPUT, $80=READ
Cflag		.EQU $63		; comparison evaluation flag

TabSiz		.EQU $64		; TAB step size (was input flag)

next_s		.EQU $65		; next descriptor stack address
					; these two bytes form a word pointer to the item
					; currently on top of the descriptor stack
last_sl		.EQU $66		; last descriptor stack address low byte
last_sh		.EQU $67		; last descriptor stack address high byte (always $00)

des_sk		.EQU $68		; descriptor stack start address (temp strings)

;			= $70		; End of descriptor stack

ut1_pl		.EQU $71		; utility pointer 1 low byte
ut1_ph		.EQU <ut1_pl+1	; utility pointer 1 high byte
ut2_pl		.EQU $73		; utility pointer 2 low byte
ut2_ph		.EQU <ut2_pl+1	; utility pointer 2 high byte

Temp_2		.EQU <ut1_pl	; temp byte for block move

FACt_1		.EQU $75		; FAC temp mantissa1
FACt_2		.EQU <FACt_1+1	; FAC temp mantissa2
FACt_3		.EQU <FACt_2+1	; FAC temp mantissa3

dims_l		.EQU <FACt_2	; array dimension size low byte
dims_h		.EQU <FACt_3	; array dimension size high byte

TempB		.EQU $78		; temp page 0 byte

Smeml		.EQU $79		; start of mem low byte		(Start-of-Basic)
Smemh		.EQU <Smeml+1	; start of mem high byte	(Start-of-Basic)
Svarl		.EQU $7B		; start of vars low byte	(Start-of-Variables)
Svarh		.EQU <Svarl+1	; start of vars high byte	(Start-of-Variables)
Sarryl		.EQU $7D		; var mem end low byte		(Start-of-Arrays)
Sarryh		.EQU <Sarryl+1	; var mem end high byte		(Start-of-Arrays)
Earryl		.EQU $7F		; array mem end low byte	(End-of-Arrays)
Earryh		.EQU <Earryl+1	; array mem end high byte	(End-of-Arrays)
Sstorl		.EQU $81		; string storage low byte	(String storage (moving down))
Sstorh		.EQU <Sstorl+1	; string storage high byte	(String storage (moving down))
Sutill		.EQU $83		; string utility ptr low byte
Sutilh		.EQU <Sutill+1	; string utility ptr high byte
Ememl		.EQU $85		; end of mem low byte		(Limit-of-memory)
Ememh		.EQU <Ememl+1	; end of mem high byte		(Limit-of-memory)

Clinel		.EQU $87		; current line low byte		(Basic line number)
Clineh		.EQU <Clinel+1	; current line high byte	(Basic line number)
Blinel		.EQU $89		; break line low byte		(Previous Basic line number)
Blineh		.EQU <Blinel+1	; break line high byte		(Previous Basic line number)

Cpntrl		.EQU $8B		; continue pointer low byte
Cpntrh		.EQU <Cpntrl+1	; continue pointer high byte

Dlinel		.EQU $8D		; current DATA line low byte
Dlineh		.EQU <Dlinel+1	; current DATA line high byte

Dptrl		.EQU $8F		; DATA pointer low byte
Dptrh		.EQU <Dptrl+1	; DATA pointer high byte

Rdptrl		.EQU $91		; read pointer low byte
Rdptrh		.EQU <Rdptrl+1	; read pointer high byte

Varnm1		.EQU $93		; current var name 1st byte
Varnm2		.EQU <Varnm1+1	; current var name 2nd byte

Cvaral		.EQU $95		; current var address low byte
Cvarah		.EQU <Cvaral+1	; current var address high byte

Frnxtl		.EQU $97		; var pointer for FOR/NEXT low byte
Frnxth		.EQU <Frnxtl+1	; var pointer for FOR/NEXT high byte

Tidx1		.EQU <Frnxtl	; temp line index

Lvarpl		.EQU <Frnxtl	; let var pointer low byte
Lvarph		.EQU <Frnxth	; let var pointer high byte

prstk		.EQU $99		; precedence stacked flag

comp_f		.EQU $9B		; compare function flag, bits 0,1 and 2 used
					; bit 2 set if >
					; bit 1 set if =
					; bit 0 set if <

func_l		.EQU $9C		; function pointer low byte
func_h		.EQU <func_l+1	; function pointer high byte

garb_l		.EQU <func_l	; garbage collection working pointer low byte
garb_h		.EQU <func_h	; garbage collection working pointer high byte

des_2l		.EQU $9E		; string descriptor_2 pointer low byte
des_2h		.EQU <des_2l+1	; string descriptor_2 pointer high byte

g_step		.EQU $A0		; garbage collect step size

Fnxjmp		.EQU $A1		; jump vector for functions
Fnxjpl		.EQU <Fnxjmp+1	; functions jump vector low byte
Fnxjph		.EQU <Fnxjmp+2	; functions jump vector high byte

g_indx		.EQU <Fnxjpl	; garbage collect temp index

FAC2_r		.EQU $A3		; FAC2 rounding byte

Adatal		.EQU $A4		; array data pointer low byte
Adatah		.EQU <Adatal+1	; array data pointer high  byte

Nbendl		.EQU <Adatal	; new block end pointer low byte
Nbendh		.EQU <Adatah	; new block end pointer high  byte

Obendl		.EQU $A6		; old block end pointer low byte
Obendh		.EQU <Obendl+1	; old block end pointer high  byte

numexp		.EQU $A8		; string to float number exponent count
expcnt		.EQU $A9		; string to float exponent count

numbit		.EQU <numexp	; bit count for array element calculations

numdpf		.EQU $AA		; string to float decimal point flag
expneg		.EQU $AB		; string to float eval exponent -ve flag

Astrtl		.EQU <numdpf	; array start pointer low byte
Astrth		.EQU <expneg	; array start pointer high  byte

Histrl		.EQU <numdpf	; highest string low byte
Histrh		.EQU <expneg	; highest string high  byte

Baslnl		.EQU <numdpf	; BASIC search line pointer low byte
Baslnh		.EQU <expneg	; BASIC search line pointer high  byte

Fvar_l		.EQU <numdpf	; find/found variable pointer low byte
Fvar_h		.EQU <expneg	; find/found variable pointer high  byte

Ostrtl		.EQU <numdpf	; old block start pointer low byte
Ostrth		.EQU <expneg	; old block start pointer high  byte

Vrschl		.EQU <numdpf	; variable search pointer low byte
Vrschh		.EQU <expneg	; variable search pointer high  byte

FAC1_e		.EQU $AC		; FAC1 exponent
FAC1_1		.EQU <FAC1_e+1	; FAC1 mantissa1
FAC1_2		.EQU <FAC1_e+2	; FAC1 mantissa2
FAC1_3		.EQU <FAC1_e+3	; FAC1 mantissa3
FAC1_s		.EQU <FAC1_e+4	; FAC1 sign (b7)

str_ln		.EQU <FAC1_e	; string length
str_pl		.EQU <FAC1_1	; string pointer low byte
str_ph		.EQU <FAC1_2	; string pointer high byte

des_pl		.EQU <FAC1_2	; string descriptor pointer low byte
des_ph		.EQU <FAC1_3	; string descriptor pointer high byte

mids_l		.EQU <FAC1_3	; MID$ string temp length byte

negnum		.EQU $B1		; string to float eval -ve flag
numcon		.EQU $B1		; series evaluation constant count

FAC1_o		.EQU $B2		; FAC1 overflow byte

FAC2_e		.EQU $B3		; FAC2 exponent
FAC2_1		.EQU <FAC2_e+1	; FAC2 mantissa1
FAC2_2		.EQU <FAC2_e+2	; FAC2 mantissa2
FAC2_3		.EQU <FAC2_e+3	; FAC2 mantissa3
FAC2_s		.EQU <FAC2_e+4	; FAC2 sign (b7)

FAC_sc		.EQU $B8		; FAC sign comparison, Acc#1 vs #2
FAC1_r		.EQU $B9		; FAC1 rounding byte

ssptr_l		.EQU <FAC_sc	; string start pointer low byte
ssptr_h		.EQU <FAC1_r	; string start pointer high byte

sdescr		.EQU <FAC_sc	; string descriptor pointer

csidx		.EQU $BA		; line crunch save index
Asptl		.EQU <csidx	; array size/pointer low byte
Aspth		.EQU $BB		; array size/pointer high byte

Btmpl		.EQU <Asptl	; BASIC pointer temp low byte
Btmph		.EQU <Aspth	; BASIC pointer temp low byte

Cptrl		.EQU <Asptl	; BASIC pointer temp low byte
Cptrh		.EQU <Aspth	; BASIC pointer temp low byte

Sendl		.EQU <Asptl	; BASIC pointer temp low byte
Sendh		.EQU <Aspth	; BASIC pointer temp low byte

LAB_IGBY	.EQU $BC		; get next BASIC byte subroutine

LAB_GBYT	.EQU $C2		; get current BASIC byte subroutine
Bpntrl		.EQU $C3		; BASIC execute (get byte) pointer low byte
Bpntrh		.EQU <Bpntrl+1	; BASIC execute (get byte) pointer high byte
Bpntrp		.EQU <Bpntrl+2	; BASIC execute (get byte) pointer PAGE byte

;			= $E0		; end of get BASIC char subroutine

Rbyte4		.EQU $E1		; extra PRNG byte
Rbyte1		.EQU <Rbyte4+1	; most significant PRNG byte
Rbyte2		.EQU <Rbyte4+2	; middle PRNG byte
Rbyte3		.EQU <Rbyte4+3	; least significant PRNG byte

NmiBase		.EQU $E5		; NMI handler enabled/setup/triggered flags
					; bit	function
					; ===	========
					; 7	interrupt enabled
					; 6	interrupt setup
					; 5	interrupt happened
;			= $E6		; NMI handler addr low byte
;			= $E7		; NMI handler addr high byte
IrqBase		.EQU $E8		; IRQ handler enabled/setup/triggered flags
;			= $E9		; IRQ handler addr low byte
;			= $EA		; IRQ handler addr high byte
FCBPTR		.EQU	$EB		; POINTER TO FCB FOR FILE OPS

Decss		.EQU $EF		; number to decimal string start
Decssp1		.EQU Decss+1	; number to decimal string start

TEMPW       .EQU $FD
;			= $FF		; decimal string end


;____________________________________________________________________________________________
;
; character get subroutine for zero page

; For a 1.8432MHz 6502 including the JSR and RTS
; fastest (>=":")	=  29 cycles =  15.7uS
; slowest (<":")	=  40 cycles =  21.7uS
; space skip	= +21 cycles = +11.4uS
; inc across page	=  +4 cycles =  +2.2uS

; the target address for the LDA at LAB_2CF4 becomes the BASIC execute pointer once the
; block is copied to it's destination, any non zero page address will do at assembly
; time, to assemble a three byte instruction.

; page 0 initialisation table from $BC
; increment and scan memory
;____________________________________________________________________________________________

LAB_2CEE
	INC	<Bpntrl		; increment BASIC execute pointer low byte
	BNE	LAB_2CF4		; branch if no carry
					; else
	INC	<Bpntrh		; increment BASIC execute pointer high byte

; page 0 initialisation table from $C2
; scan memory
LAB_2CF4
	LDA	$FFFFFF			; get byte to scan (addr set by call routine)
	CMP	#TK_ELSE		; compare with the token for ELSE
	BEQ	LAB_2D05		; exit if ELSE, not numeric, carry set

	CMP	#':'			; compare with ":"
	BCS	LAB_2D05		; exit if >= ":", not numeric, carry set

	CMP	#' '			; compare with " "
	BEQ	LAB_2CEE		; if " " go do next

	SEC				; set carry for SBC
	SBC	#'0'			; subtract "0"
	SEC				; set carry for SBC
	SBC	#$D0			; subtract -"0"
					; clear carry if byte = "0"-"9"
LAB_2D05
	RTL
LAB_2CEE_END
;____________________________________________________________________________________________
;
; page zero initialisation table $00-$12 inclusive
;____________________________________________________________________________________________

StrTab
	.byte	$4C			; JMP opcode
	.word LAB_COLD		; initial warm start vector (cold start)

	.byte	$00			; these bytes are not used by BASIC
	.word	$0000			;
	.word	$0000			;
	.word	$0000			;

	.byte	$4C			; JMP opcode
	.word	LAB_FCER		; initial user function vector ("Function call" error)
	.byte	$00			; default NULL count
	.byte	$00			; clear terminal position
	.byte	$00			; default terminal width byte
	.byte	$F2			; default limit for TAB = 14
	.word	Ram_base		; start of user RAM
EndTab

;  BASIC start-up code

PG2_TABS
	.byte	$00			; ctrl-c flag		-	$00 = enabled
	.byte	$03			; ctrl-c byte		-	GET needs this
	.byte	$00			; ctrl-c byte timeout	-	GET needs this
	.word	CTRLC			; ctrl c check vector
PG2_TABE
