
LAB_CONMSG:
	.byte	$80,$80,$80,$83,$84,$85,"  Werner Engineering 816",$0D
	.byte	$81,$81,$81,$83,$84,$85,"  Enhanced BASIC 65816 2.3",$0D
	.byte	$82,$82,$82,$83,$84,$85,00

LAB_SMSG:
	.byte	" Bytes free",$00
LAB_SMSG1
	.byte	$0D,$0A,"Enhanced BASIC 65816 2.3",$00
	.byte	$0D,$0A,"DERIVED FROM ehBASIC BY LEE DAVIDSON",$00

; BASIC messages, mostly error messages

LAB_BAER
	.word	ERR_NF		;$00 NEXT without FOR
	.word	ERR_SN		;$02 syntax
	.word	ERR_RG		;$04 RETURN without GOSUB
	.word	ERR_OD		;$06 out of data
	.word	ERR_FC		;$08 function call
	.word	ERR_OV		;$0A overflow
	.word	ERR_OM		;$0C out of memory
	.word	ERR_US		;$0E undefined statement
	.word	ERR_BS		;$10 array bounds
	.word	ERR_DD		;$12 double dimension array
	.word	ERR_D0		;$14 divide by 0
	.word	ERR_ID		;$16 illegal direct
	.word	ERR_TM		;$18 type mismatch
	.word	ERR_LS		;$1A long string
	.word	ERR_ST		;$1C string too complex
	.word	ERR_CN		;$1E continue error
	.word	ERR_UF		;$20 undefined function
	.word ERR_LD		;$22 LOOP without DO

ERR_NF	.byte	"NEXT without FOR",$00
ERR_SN	.byte	"Syntax",$00
ERR_RG	.byte	"RETURN without GOSUB",$00
ERR_OD	.byte	"Out of DATA",$00
ERR_FC	.byte	"Function call",$00
ERR_OV	.byte	"Overflow",$00
ERR_OM	.byte	"Out of memory",$00
ERR_US	.byte	"Undefined statement",$00
ERR_BS	.byte	"Array bounds",$00
ERR_DD	.byte	"Double dimension",$00
ERR_D0	.byte	"Divide by zero",$00
ERR_ID	.byte	"Illegal direct",$00
ERR_TM	.byte	"Type mismatch",$00
ERR_LS	.byte	"String too long",$00
ERR_ST	.byte	"String too complex",$00
ERR_CN	.byte	"Can't continue",$00
ERR_UF	.byte	"Undefined function",$00
ERR_LD	.byte	"LOOP without DO",$00

LAB_BMSG	.byte	$0D,$0A,"Break",$00
LAB_EMSG	.byte	" Error",$00
LAB_LMSG	.byte	" in line ",$00
LAB_RMSG	.byte	$0D,$0A,"Ready",$0D,$0A,$00

LAB_IMSG	.byte	" Extra ignored",$0D,$0A,$00
LAB_REDO	.byte	" Redo from start",$0D,$0A,$00
LAB_IOER	.byte	" I/O Error",$0D,$0A,$00
