; token values needed for BASIC

; primary command tokens (can start a statement)

TK_END		.EQU $80			; END
TK_FOR		.EQU TK_END+1		; FOR token
TK_NEXT		.EQU TK_FOR+1		; NEXT token
TK_DATA		.EQU TK_NEXT+1		; DATA token
TK_DIRECTORY	.EQU TK_DATA+1		; DISKSTATUS token
TK_DISKSTATUS	.EQU TK_DIRECTORY+1	; DIRECTORY token
TK_INPUT	.EQU TK_DISKSTATUS+1	; INPUT token
TK_DIM		.EQU TK_INPUT+1	; DIM token
TK_READ		.EQU TK_DIM+1		; READ token
TK_LET		.EQU TK_READ+1		; LET token
TK_DEC		.EQU TK_LET+1		; DEC token
TK_GOTO		.EQU TK_DEC+1		; GOTO token
TK_RUN		.EQU TK_GOTO+1		; RUN token
TK_IF		.EQU TK_RUN+1		; IF token
TK_RESTORE	.EQU TK_IF+1		; RESTORE token
TK_GOSUB	.EQU TK_RESTORE+1	; GOSUB token
TK_RETURN	.EQU TK_GOSUB+1	; RETURN token
TK_REM		.EQU TK_RETURN+1	; REM token
TK_STOP		.EQU TK_REM+1		; STOP token
TK_ON		.EQU TK_STOP+1		; ON token
TK_NULL		.EQU TK_ON+1		; NULL token
TK_INC		.EQU TK_NULL+1		; INC token
TK_WAIT		.EQU TK_INC+1		; WAIT token
TK_LOAD		.EQU TK_WAIT+1		; LOAD token
TK_SAVE		.EQU TK_LOAD+1		; SAVE token
TK_DEF		.EQU TK_SAVE+1		; DEF token
TK_POKE		.EQU TK_DEF+1		; POKE token
TK_CALL		.EQU TK_POKE+1		; CALL token
TK_DO		 .EQU TK_CALL+1		; DO token
TK_LOOP		.EQU TK_DO+1		; LOOP token
TK_PRINT	.EQU TK_LOOP+1		; PRINT token
TK_CONT		.EQU TK_PRINT+1	; CONT token
TK_LIST		.EQU TK_CONT+1		; LIST token
TK_CLEAR	.EQU TK_LIST+1		; CLEAR token
TK_NEW		.EQU TK_CLEAR+1	; NEW token
TK_WIDTH	.EQU TK_NEW+1		; WIDTH token
TK_GET		.EQU TK_WIDTH+1	; GET token
TK_SWAP		.EQU TK_GET+1		; SWAP token
TK_BITSET	.EQU TK_SWAP+1		; BITSET token
TK_BITCLR	.EQU TK_BITSET+1	; BITCLR token
TK_MONITOR	.EQU TK_BITCLR+1		; MONITOR token
TK_OPEN		.EQU TK_MONITOR+1	; OPEN token
TK_CLOSE	.EQU TK_OPEN+1		; CLOSE token
TK_IECINPUT	.EQU TK_CLOSE+1		; IECINPUT token
TK_IECOUTPUT	.EQU TK_IECINPUT+1	; IECOUTPUT token
TK_PUTN		.EQU TK_IECOUTPUT+1	; PUTN token
TK_GETN		.EQU TK_PUTN+1	; GETN token
TK_DISKCMD	.EQU TK_GETN+1		; DISKCMD token
TK_SCNCLR	.EQU TK_DISKCMD+1		;SCNCLR token
TK_LOCATE	.EQU TK_SCNCLR+1		;LOCATE token
TK_COLOR	.EQU TK_LOCATE+1		;COLOR token
TK_SPOKE	.EQU TK_COLOR+1			;SPOKE token
TK_SCREEN	.EQU TK_SPOKE+1			;SCREEN token
TK_SPRITE	.EQU TK_SCREEN+1		;SPRITE token
TK_SPRDEF	.EQU TK_SPRITE+1		;SPRDEF token
TK_SPRSIZE	.EQU TK_SPRDEF+1		;SPRSIZE token
TK_PLOT		.EQU TK_SPRSIZE+1		;PLOT token
TK_PATTERN	.EQU TK_PLOT+1			;PATTERN token
TK_SYS		.EQU TK_PATTERN+1		;SYS token
TK_SOUND	.EQU TK_SYS+1			;SOUND token
TK_NOISE	.EQU TK_SOUND+1			;NOISE token
TK_TONE		.EQU TK_NOISE+1			;TONE token
TK_VOLUME	.EQU TK_TONE+1			;VOLUME token
TK_VOICE	.EQU TK_VOLUME+1		;VOICE token

; secondary command tokens, can't start a statement

TK_TAB		.EQU TK_VOICE+1		; TAB token
TK_ELSE		.EQU TK_TAB+1		; ELSE token
TK_TO		.EQU TK_ELSE+1		; TO token
TK_FN		.EQU TK_TO+1		; FN token
TK_SPC		.EQU TK_FN+1		; SPC token
TK_THEN		.EQU TK_SPC+1		; THEN token
TK_NOT		.EQU TK_THEN+1		; NOT token
TK_STEP		.EQU TK_NOT+1		; STEP token
TK_UNTIL	.EQU TK_STEP+1		; UNTIL token
TK_WHILE	.EQU TK_UNTIL+1	; WHILE token
TK_OFF		.EQU TK_WHILE+1	; OFF token

; opperator tokens

TK_PLUS		.EQU TK_OFF+1		; + token
TK_MINUS	.EQU TK_PLUS+1		; - token
TK_MUL		.EQU TK_MINUS+1	; * token
TK_DIV		.EQU TK_MUL+1		; / token
TK_POWER	.EQU TK_DIV+1		; ^ token
TK_AND		.EQU TK_POWER+1	; AND token
TK_EOR		.EQU TK_AND+1		; EOR token
TK_OR		.EQU TK_EOR+1		; OR token
TK_RSHIFT	.EQU TK_OR+1		; RSHIFT token
TK_LSHIFT	.EQU TK_RSHIFT+1	; LSHIFT token
TK_GT		.EQU TK_LSHIFT+1	; > token
TK_EQUAL	.EQU TK_GT+1		; = token
TK_LT		.EQU TK_EQUAL+1	; < token

; functions tokens

TK_SGN		.EQU TK_LT+1		; SGN token
TK_INT		.EQU TK_SGN+1		; INT token
TK_ABS		.EQU TK_INT+1		; ABS token
TK_USR		.EQU TK_ABS+1		; USR token
TK_FRE		.EQU TK_USR+1		; FRE token
TK_POS		.EQU TK_FRE+1		; POS token
TK_SQR		.EQU TK_POS+1		; SQR token
TK_RND		.EQU TK_SQR+1		; RND token
TK_LOG		.EQU TK_RND+1		; LOG token
TK_EXP		.EQU TK_LOG+1		; EXP token
TK_COS		.EQU TK_EXP+1		; COS token
TK_SIN		.EQU TK_COS+1		; SIN token
TK_TAN		.EQU TK_SIN+1		; TAN token
TK_ATN		.EQU TK_TAN+1		; ATN token
TK_PEEK		.EQU TK_ATN+1		; PEEK token
TK_SPEEK	.EQU TK_PEEK+1		;SPEEK token
TK_SADD		.EQU TK_SPEEK+1		; SADD token
TK_LEN		.EQU TK_SADD+1		; LEN token
TK_STRS		.EQU TK_LEN+1		; STR$ token
TK_VAL		.EQU TK_STRS+1		; VAL token
TK_ASC		.EQU TK_VAL+1		; ASC token
TK_UCASES	.EQU TK_ASC+1		; UCASE$ token
TK_LCASES	.EQU TK_UCASES+1	; LCASE$ token
TK_CHRS		.EQU TK_LCASES+1	; CHR$ token
TK_HEXS		.EQU TK_CHRS+1		; HEX$ token
TK_BINS		.EQU TK_HEXS+1		; BIN$ token
TK_BITTST	.EQU TK_BINS+1		; BITTST token
TK_MAX		.EQU TK_BITTST+1	; MAX token
TK_MIN		.EQU TK_MAX+1		; MIN token
TK_PI		.EQU TK_MIN+1		; PI token
TK_IECST	.EQU TK_PI+1		; IECST token
TK_VIDST	.EQU TK_IECST+1		; VIDST token
TK_VPTR		.EQU TK_VIDST+1		; VARPTR token
TK_LEFTS	.EQU TK_VPTR+1		; LEFT$ token
TK_RIGHTS	.EQU TK_LEFTS+1		; RIGHT$ token
TK_MIDS		.EQU TK_RIGHTS+1	; MID$ token
TK_CON		.EQU TK_MIDS+1		; CON token




LAB_CTBL
	.word	LAB_END-1		; END
	.word	LAB_FOR-1		; FOR
	.word	LAB_NEXT-1		; NEXT
	.word	LAB_DATA-1		; DATA
	.WORD	V_DIR-1			; DIRECTORY
	.word   V_ERR-1 		; DISKSTATUS
	.word	LAB_INPUT-1		; INPUT
	.word	LAB_DIM-1		; DIM
	.word	LAB_READ-1		; READ
	.word	LAB_LET-1		; LET
	.word	LAB_DEC-1		; DEC			new command
	.word	LAB_GOTO-1		; GOTO
	.word	LAB_RUN-1		; RUN
	.word	LAB_IF-1		; IF
	.word	LAB_RESTORE-1	; RESTORE		modified command
	.word	LAB_GOSUB-1		; GOSUB
	.word	LAB_RETURN-1	; RETURN
	.word	LAB_REM-1		; REM
	.word	LAB_STOP-1		; STOP
	.word	LAB_ON-1		; ON			modified command
	.word	LAB_NULL-1		; NULL		modified command
	.word	LAB_INC-1		; INC			new command
	.word	LAB_WAIT-1		; WAIT
	.word	V_LOAD-1		; LOAD
	.word	V_SAVE-1		; SAVE
	.word	LAB_DEF-1		; DEF
	.word	LAB_POKE-1		; POKE
	.word	LAB_CALL-1		; CALL		new command
	.word	LAB_DO-1		; DO			new command
	.word	LAB_LOOP-1		; LOOP		new command
	.word	LAB_PRINT-1		; PRINT
	.word	LAB_CONT-1		; CONT
	.word	LAB_LIST-1		; LIST
	.word	LAB_CLEAR-1		; CLEAR
	.word	LAB_NEW-1		; NEW
	.word	LAB_WDTH-1		; WIDTH		new command
	.word	LAB_GET-1		; GET			new command
	.word	LAB_SWAP-1		; SWAP		new command
	.word	LAB_BITSET-1	; BITSET		new command
	.word	LAB_BITCLR-1	; BITCLR		new command
	.word	LAB_MONITOR-1		; MONITOR		MONITOR command
	.word	V_OPEN-1		; OPEN			OPEN command
	.word	V_CLOSE-1		; CLOSE			CLOSE command
	.word	V_IECINPUT-1		; IECINPUT		IECINPUT command
	.word	V_IECOUTPUT-1		; IECOUTPUT		IECOUTPUT command
	.word	V_PUTN-1		; PUTN			PUTN command
	.word	V_GETN-1		; GETN			GETN command
	.WORD 	V_DISKCMD-1		; DISKCMD		DISKCMD COMMAND
	.WORD 	V_SCNCLR-1		; SCNCLR		SCNCLR COMMAND
	.WORD 	V_LOCATE-1		; LOCATE		LOCATE COMMAND
	.WORD 	V_COLOR-1		; COLOR			COLOR COMMAND
	.WORD 	V_SPOKE-1		; SPOKE			SPOKE COMMAND
	.WORD 	V_SCREEN-1		; SCREEN		SCREEN COMMAND
	.WORD 	V_SPRITE-1		; SPRITE		SPRITE COMMAND
	.WORD 	V_SPRDEF-1		; SPRDEF		SPRDEF COMMAND
	.WORD 	V_SPRSIZE-1		; SPRSIZE		SPRSIZE COMMAND
	.WORD 	V_PLOT-1		; PLOT			PLOT COMMAND
	.WORD 	V_PATTERN-1		; PATTERN		PATTERN COMMAND
	.WORD 	LAB_SYS-1		; SYS			SYS COMMAND
	.WORD 	V_SOUND-1		; SOUND			SOUND COMMAND
	.WORD 	V_NOISE-1		; NOISE			NOISE COMMAND
	.WORD 	V_TONE-1		; TONE			TONE COMMAND
	.WORD 	V_VOLUME-1		; VOLUME		VOLUME COMMAND
	.WORD 	V_VOICE-1		; VOICE			VOICE COMMAND
; function pre process routine table

LAB_FTPL
LAB_FTPM	.EQU LAB_FTPL+$01
	.word	LAB_PPFN-1		; SGN(n)	process numeric expression in ()
	.word	LAB_PPFN-1		; INT(n)		"
	.word	LAB_PPFN-1		; ABS(n)		"
	.word	LAB_EVEZ-1		; USR(x)	process any expression
	.word	LAB_1BF7-1		; FRE(x)		"
	.word	LAB_1BF7-1		; POS(x)		"
	.word	LAB_PPFN-1		; SQR(n)	process numeric expression in ()
	.word	LAB_PPFN-1		; RND(n)		"
	.word	LAB_PPFN-1		; LOG(n)		"
	.word	LAB_PPFN-1		; EXP(n)		"
	.word	LAB_PPFN-1		; COS(n)		"
	.word	LAB_PPFN-1		; SIN(n)		"
	.word	LAB_PPFN-1		; TAN(n)		"
	.word	LAB_PPFN-1		; ATN(n)		"
	.word	LAB_PPFN-1		; PEEK(n)		"
	.WORD 	LAB_PPFN-1		; SPEEK(N)		"
	.word	$0000			; SADD()	none
	.word	LAB_PPFS-1		; LEN($)	process string expression in ()
	.word	LAB_PPFN-1		; STR$(n)	process numeric expression in ()
	.word	LAB_PPFS-1		; VAL($)	process string expression in ()
	.word	LAB_PPFS-1		; ASC($)		"
	.word	LAB_PPFS-1		; UCASE$($)		"
	.word	LAB_PPFS-1		; LCASE$($)		"
	.word	LAB_PPFN-1		; CHR$(n)	process numeric expression in ()
	.word	LAB_BHSS-1		; HEX$(n)		"
	.word	LAB_BHSS-1		; BIN$(n)		"
	.word	$0000			; BITTST()	none
	.word	LAB_MMPP-1		; MAX()	process numeric expression
	.word	LAB_MMPP-1		; MIN()		"
	.word	LAB_PPBI-1		; PI		advance pointer
	.word	LAB_PIECST-1		; IECST		"
	.word	LAB_PVIDST-1		; VIDST		"
	.word	$0000			; VARPTR()	none
	.word	LAB_LRMS-1		; LEFT$()	process string expression
	.word	LAB_LRMS-1		; RIGHT$()		"
	.word	LAB_LRMS-1		; MID$()		"
	.word	LAB_PPFN-1		; CON()		"

; action addresses for functions

LAB_FTBL
LAB_FTBM	.EQU LAB_FTBL+$01
	.word	LAB_SGN-1		; SGN()
	.word	LAB_INT-1		; INT()
	.word	LAB_ABS-1		; ABS()
	.word	LAB_USR-1		; USR()
	.word	LAB_FRE-1		; FRE()
	.word	LAB_POS-1		; POS()
	.word	LAB_SQR-1		; SQR()
	.word	LAB_RND-1		; RND()		modified function
	.word	LAB_LOG-1		; LOG()
	.word	LAB_EXP-1		; EXP()
	.word	LAB_COS-1		; COS()
	.word	LAB_SIN-1		; SIN()
	.word	LAB_TAN-1		; TAN()
	.word	LAB_ATN-1		; ATN()
	.word	LAB_PEEK-1		; PEEK()
	.WORD 	V_SPEEK-1		; SPEEK()
	.word	LAB_SADD-1		; SADD()		new function
	.word	LAB_LENS-1		; LEN()
	.word	LAB_STRS-1		; STR$()
	.word	LAB_VAL-1		; VAL()
	.word	LAB_ASC-1		; ASC()
	.word	LAB_UCASE-1		; UCASE$()		new function
	.word	LAB_LCASE-1		; LCASE$()		new function
	.word	LAB_CHRS-1		; CHR$()
	.word	LAB_HEXS-1		; HEX$()		new function
	.word	LAB_BINS-1		; BIN$()		new function
	.word	LAB_BTST-1		; BITTST()		new function
	.word	LAB_MAX-1		; MAX()		new function
	.word	LAB_MIN-1		; MIN()		new function
	.word	LAB_PI-1		; PI			new function
	.word	LAB_IECST-1		; IECST		new function
	.word	LAB_VIDST-1		; VIDST		new function
	.word	LAB_VARPTR-1		; VARPTR()		new function
	.word	LAB_LEFT-1		; LEFT$()
	.word	LAB_RIGHT-1		; RIGHT$()
	.word	LAB_MIDS-1		; MID$()
	.word	LAB_CON-1		; CON()

; hierarchy and action addresses for operator

LAB_OPPT
	.byte	$79			; +
	.word	LAB_ADD-1
	.byte	$79			; -
	.word	LAB_SUBTRACT-1
	.byte	$7B			; *
	.word	LAB_MULTIPLY-1
	.byte	$7B			; /
	.word	LAB_DIVIDE-1
	.byte	$7F			; ^
	.word	LAB_POWER-1
	.byte	$50			; AND
	.word	LAB_AND-1
	.byte	$46			; EOR			new operator
	.word	LAB_EOR-1
	.byte	$46			; OR
	.word	LAB_OR-1
	.byte	$56			; >>			new operator
	.word	LAB_RSHIFT-1
	.byte	$56			; <<			new operator
	.word	LAB_LSHIFT-1
	.byte	$7D			; >
	.word	LAB_GTHAN-1
	.byte	$5A			; =
	.word	LAB_EQUAL-1
	.byte	$64			; <
	.word	LAB_LTHAN-1

; keywords start with ..
; this is the first character table and must be in alphabetic order

TAB_1STC
	.byte	"*"
	.byte	"+"
	.byte	"-"
	.byte	"/"
	.byte	"<"
	.byte	"="
	.byte	">"
	.byte	"?"
	.byte	"A"
	.byte	"B"
	.byte	"C"
	.byte	"D"
	.byte	"E"
	.byte	"F"
	.byte	"G"
	.byte	"H"
	.byte	"I"
	.byte	"K"
	.byte	"L"
	.byte	"M"
	.byte	"N"
	.byte	"O"
	.byte	"P"
	.byte	"R"
	.byte	"S"
	.byte	"T"
	.byte	"U"
	.byte	"V"
	.byte	"W"
	.byte	"^"
	.byte	$00			; table terminator

; pointers to keyword tables

TAB_CHRT
	.word	TAB_STAR		; table for "*"
	.word	TAB_PLUS		; table for "+"
	.word	TAB_MNUS		; table for "-"
	.word	TAB_SLAS		; table for "/"
	.word	TAB_LESS		; table for "<"
	.word	TAB_EQUL		; table for "="
	.word	TAB_MORE		; table for ">"
	.word	TAB_QEST		; table for "?"
	.word	TAB_ASCA		; table for "A"
	.word	TAB_ASCB		; table for "B"
	.word	TAB_ASCC		; table for "C"
	.word	TAB_ASCD		; table for "D"
	.word	TAB_ASCE		; table for "E"
	.word	TAB_ASCF		; table for "F"
	.word	TAB_ASCG		; table for "G"
	.word	TAB_ASCH		; table for "H"
	.word	TAB_ASCI		; table for "I"
	.word	TAB_ASCK		; table for "K"
	.word	TAB_ASCL		; table for "L"
	.word	TAB_ASCM		; table for "M"
	.word	TAB_ASCN		; table for "N"
	.word	TAB_ASCO		; table for "O"
	.word	TAB_ASCP		; table for "P"
	.word	TAB_ASCR		; table for "R"
	.word	TAB_ASCS		; table for "S"
	.word	TAB_ASCT		; table for "T"
	.word	TAB_ASCU		; table for "U"
	.word	TAB_ASCV		; table for "V"
	.word	TAB_ASCW		; table for "W"
	.word	TAB_POWR		; table for "^"

; tables for each start character, note if a longer keyword with the same start
; letters as a shorter one exists then it must come first, else the list is in
; alphabetical order as follows ..

; [keyword,token
; [keyword,token]]
; end marker (#$00)

TAB_STAR
	.byte TK_MUL,$00		; *
TAB_PLUS
	.byte TK_PLUS,$00		; +
TAB_MNUS
	.byte TK_MINUS,$00	; -
TAB_SLAS
	.byte TK_DIV,$00		; /
TAB_LESS
LBB_LSHIFT
	.byte	"<",TK_LSHIFT	; <<	note - "<<" must come before "<"
	.byte TK_LT			; <
	.byte	$00
TAB_EQUL
	.byte TK_EQUAL,$00	; =
TAB_MORE
LBB_RSHIFT
	.byte	">",TK_RSHIFT	; >>	note - ">>" must come before ">"
	.byte TK_GT			; >
	.byte	$00
TAB_QEST
	.byte TK_PRINT,$00	; ?
TAB_ASCA
LBB_ABS
	.byte	"BS(",TK_ABS	; ABS(
LBB_AND
	.byte	"ND",TK_AND		; AND
LBB_ASC
	.byte	"SC(",TK_ASC	; ASC(
LBB_ATN
	.byte	"TN(",TK_ATN	; ATN(
	.byte	$00
TAB_ASCB
LBB_BINS
	.byte	"IN$(",TK_BINS	; BIN$(
LBB_BITCLR
	.byte	"ITCLR",TK_BITCLR	; BITCLR
LBB_BITSET
	.byte	"ITSET",TK_BITSET	; BITSET
LBB_BITTST
	.byte	"ITTST(",TK_BITTST
					; BITTST(
	.byte	$00
TAB_ASCC
LBB_CALL
	.byte	"ALL",TK_CALL	; CALL
LBB_CHRS
	.byte	"HR$(",TK_CHRS	; CHR$(
LBB_CLEAR
	.byte	"LEAR",TK_CLEAR	; CLEAR
LBB_CLOSE
	.byte	"LOSE",TK_CLOSE	; CLOSE
LBB_COLOR
	.BYTE 	"OLOR",TK_COLOR ; COLOR
LBB_CON
	.BYTE	"ON(",TK_CON 	;CON
LBB_CONT
	.byte	"ONT",TK_CONT	; CONT
LBB_COS
	.byte	"OS(",TK_COS	; COS(
	.byte	$00
TAB_ASCD
LBB_DATA
	.byte	"ATA",TK_DATA	; DATA
LBB_DEC
	.byte	"EC",TK_DEC		; DEC
LBB_DEF
	.byte	"EF",TK_DEF		; DEF
LBB_DIM
	.byte	"IM",TK_DIM		; DIM
LBB_DIRECTORY
	.byte	"IRECTORY",TK_DIRECTORY ; DIRECTORY
LBB_DISKCMD
	.byte	"ISKCMD",TK_DISKCMD		; DISKCMD
LBB_DISKSTATUS
	.byte	"ISKSTATUS",TK_DISKSTATUS ; DISKSTATUS
LBB_DO
	.byte	"O",TK_DO		; DO
	.byte	$00
TAB_ASCE
LBB_ELSE
	.byte	"LSE",TK_ELSE	; ELSE
LBB_END
	.byte	"ND",TK_END		; END
LBB_EOR
	.byte	"OR",TK_EOR		; EOR
LBB_EXP
	.byte	"XP(",TK_EXP	; EXP(
	.byte	$00
TAB_ASCF
LBB_FN
	.byte	"N",TK_FN		; FN
LBB_FOR
	.byte	"OR",TK_FOR		; FOR
LBB_FRE
	.byte	"RE(",TK_FRE	; FRE(
	.byte	$00
TAB_ASCG
LBB_GETN
	.byte	"ET#",TK_GETN		; GETN
LBB_GET
	.byte	"ET",TK_GET		; GET
LBB_GOSUB
	.byte	"OSUB",TK_GOSUB	; GOSUB
LBB_GOTO
	.byte	"OTO",TK_GOTO	; GOTO
	.byte	$00
TAB_ASCH
LBB_HEXS
	.byte	"EX$(",TK_HEXS	; HEX$(
	.byte	$00
TAB_ASCI
LBB_IECINPUT
	.byte	"ECINPUT",TK_IECINPUT	; IECINPUT
LBB_IECOUTPUT
	.byte	"ECOUTPUT",TK_IECOUTPUT	; IECOUTPUT
LBB_IECST
	.byte	"ECST",TK_IECST	; IECST
LBB_IF
	.byte	"F",TK_IF		; IF
LBB_INC
	.byte	"NC",TK_INC		; INC
LBB_INPUT
	.byte	"NPUT",TK_INPUT		; INPUT
LBB_INT
	.byte	"NT(",TK_INT		; INT(
	.byte	$00
TAB_ASCK
TAB_ASCL
LBB_LCASES
	.byte	"CASE$(",TK_LCASES
					; LCASE$(
LBB_LEFTS
	.byte	"EFT$(",TK_LEFTS	; LEFT$(
LBB_LEN
	.byte	"EN(",TK_LEN	; LEN(
LBB_LET
	.byte	"ET",TK_LET		; LET
LBB_LIST
	.byte	"IST",TK_LIST	; LIST
LBB_LOAD
	.byte	"OAD",TK_LOAD	; LOAD
LBB_LOCATE
	.BYTE 	"OCATE",TK_LOCATE ; LOCATE
LBB_LOG
	.byte	"OG(",TK_LOG	; LOG(
LBB_LOOP
	.byte	"OOP",TK_LOOP	; LOOP
	.byte	$00
TAB_ASCM
LBB_MAX
	.byte	"AX(",TK_MAX	; MAX(
LBB_MIDS
	.byte	"ID$(",TK_MIDS	; MID$(
LBB_MIN
	.byte	"IN(",TK_MIN	; MIN(
LBB_MONITOR
	.byte	"ONITOR",TK_MONITOR; MONITOR(
	.byte	$00
TAB_ASCN
LBB_NEW
	.byte	"EW",TK_NEW		; NEW
LBB_NEXT
	.byte	"EXT",TK_NEXT		; NEXT
LBB_NOISE
	.byte	"OISE",TK_NOISE		; NOISE
LBB_NOT
	.byte	"OT",TK_NOT		; NOT
LBB_NULL
	.byte	"ULL",TK_NULL	; NULL
	.byte	$00
TAB_ASCO
LBB_OFF
	.byte	"FF",TK_OFF		; OFF
LBB_ON
	.byte	"N",TK_ON		; ON
LBB_OPEN
	.byte	"PEN",TK_OPEN		; OPEN
LBB_OR
	.byte	"R",TK_OR		; OR
	.byte	$00
TAB_ASCP
LBB_PATTERN
	.byte	"ATTERN",TK_PATTERN	; PATTERN
LBB_PEEK
	.byte	"EEK(",TK_PEEK	; PEEK(
LBB_PI
	.byte	"I",TK_PI		; PI
LBB_PLOT
	.byte	"LOT",TK_PLOT		; PLOT
LBB_POKE
	.byte	"OKE",TK_POKE	; POKE
LBB_POS
	.byte	"OS(",TK_POS	; POS(
LBB_PRINT
	.byte	"RINT",TK_PRINT	; PRINT
LBB_PUTN
	.byte	"UT#",TK_PUTN	; PUTN
	.byte	$00
TAB_ASCR
LBB_READ
	.byte	"EAD",TK_READ	; READ
LBB_REM
	.byte	"EM",TK_REM		; REM
LBB_RESTORE
	.byte	"ESTORE",TK_RESTORE
					; RESTORE
LBB_RETURN
	.byte	"ETURN",TK_RETURN	; RETURN
LBB_RIGHTS
	.byte	"IGHT$(",TK_RIGHTS
					; RIGHT$(
LBB_RND
	.byte	"ND(",TK_RND	; RND(
LBB_RUN
	.byte	"UN",TK_RUN		; RUN
	.byte	$00
TAB_ASCS
LBB_SADD
	.byte	"ADD(",TK_SADD	; SADD(
LBB_SAVE
	.byte	"AVE",TK_SAVE	; SAVE
LBB_SCNCLR
	.BYTE 	"CNCLR",TK_SCNCLR ; SCNCLR
LBB_SCREEN
	.BYTE 	"CREEN",TK_SCREEN ; SCREEN
LBB_SGN
	.byte	"GN(",TK_SGN	; SGN(
LBB_SIN
	.byte	"IN(",TK_SIN	; SIN(
LBB_SOUND
	.byte	"OUND",TK_SOUND	; SOUND
LBB_SPC
	.byte	"PC(",TK_SPC	; SPC(
LBB_SPEEK
	.byte	"PEEK(",TK_SPEEK	; SPEEK
LBB_SPOKE
	.byte	"POKE",TK_SPOKE	; SPOKE
LBB_SPRDEF
	.byte	"PRDEF",TK_SPRDEF	; SPRDEF
LBB_SPRITE
	.byte	"PRITE",TK_SPRITE	; SPRITE
LBB_SPRSIZE
	.byte	"PRSIZE",TK_SPRSIZE	; SPRSIZE
LBB_SQR
	.byte	"QR(",TK_SQR	; SQR(
LBB_STEP
	.byte	"TEP",TK_STEP	; STEP
LBB_STOP
	.byte	"TOP",TK_STOP	; STOP
LBB_STRS
	.byte	"TR$(",TK_STRS	; STR$(
LBB_SWAP
	.byte	"WAP",TK_SWAP	; SWAP
LBB_SYS
	.byte	"YS",TK_SYS	; SYS
	.byte	$00
TAB_ASCT
LBB_TAB
	.byte	"AB(",TK_TAB	; TAB(
LBB_TAN
	.byte	"AN(",TK_TAN	; TAN(
LBB_THEN
	.byte	"HEN",TK_THEN	; THEN
LBB_TONE
	.byte	"ONE",TK_TONE		; TONE
LBB_TO
	.byte	"O",TK_TO		; TO
	.byte	$00
TAB_ASCU
LBB_UCASES
	.byte	"CASE$(",TK_UCASES
					; UCASE$(
LBB_UNTIL
	.byte	"NTIL",TK_UNTIL	; UNTIL
LBB_USR
	.byte	"SR(",TK_USR	; USR(
	.byte	$00
TAB_ASCV
LBB_VAL
	.byte	"AL(",TK_VAL	; VAL(
LBB_VPTR
	.byte	"ARPTR(",TK_VPTR	; VARPTR(
LBB_VIDST
	.byte	"IDST",TK_VIDST		; VIDST
LBB_VOICE
	.byte	"OICE",TK_VOICE		; VOICE
LBB_VOLUME
	.byte	"OLUME",TK_VOLUME	; VOLUME

	.byte	$00
TAB_ASCW
LBB_WAIT
	.byte	"AIT",TK_WAIT	; WAIT
LBB_WHILE
	.byte	"HILE",TK_WHILE	; WHILE
LBB_WIDTH
	.byte	"IDTH",TK_WIDTH	; WIDTH
	.byte	$00
TAB_POWR
	.byte	TK_POWER,$00	; ^

; new decode table for LIST
; Table is ..
; byte - keyword length, keyword first character
; word - pointer to rest of keyword from dictionary

; note if length is 1 then the pointer is ignored

LAB_KEYT
	.byte	3,'E'
	.word	LBB_END		; END
	.byte	3,'F'
	.word	LBB_FOR		; FOR
	.byte	4,'N'
	.word	LBB_NEXT		; NEXT
	.byte	4,'D'
	.word	LBB_DATA		; DATA
	.byte	9,'D'
	.word	LBB_DIRECTORY		; DIRECTORY
	.byte	10,'D'
	.word	LBB_DISKSTATUS		; DISKSTATUS
	.byte	5,'I'
	.word	LBB_INPUT		; INPUT
	.byte	3,'D'
	.word	LBB_DIM		; DIM
	.byte	4,'R'
	.word	LBB_READ		; READ
	.byte	3,'L'
	.word	LBB_LET		; LET
	.byte	3,'D'
	.word	LBB_DEC		; DEC
	.byte	4,'G'
	.word	LBB_GOTO		; GOTO
	.byte	3,'R'
	.word	LBB_RUN		; RUN
	.byte	2,'I'
	.word	LBB_IF		; IF
	.byte	7,'R'
	.word	LBB_RESTORE		; RESTORE
	.byte	5,'G'
	.word	LBB_GOSUB		; GOSUB
	.byte	6,'R'
	.word	LBB_RETURN		; RETURN
	.byte	3,'R'
	.word	LBB_REM		; REM
	.byte	4,'S'
	.word	LBB_STOP		; STOP
	.byte	2,'O'
	.word	LBB_ON		; ON
	.byte	4,'N'
	.word	LBB_NULL		; NULL
	.byte	3,'I'
	.word	LBB_INC		; INC
	.byte	4,'W'
	.word	LBB_WAIT		; WAIT
	.byte	4,'L'
	.word	LBB_LOAD		; LOAD
	.byte	4,'S'
	.word	LBB_SAVE		; SAVE
	.byte	3,'D'
	.word	LBB_DEF		; DEF
	.byte	4,'P'
	.word	LBB_POKE		; POKE
	.byte	4,'C'
	.word	LBB_CALL		; CALL
	.byte	2,'D'
	.word	LBB_DO		; DO
	.byte	4,'L'
	.word	LBB_LOOP		; LOOP
	.byte	5,'P'
	.word	LBB_PRINT		; PRINT
	.byte	4,'C'
	.word	LBB_CONT		; CONT
	.byte	4,'L'
	.word	LBB_LIST		; LIST
	.byte	5,'C'
	.word	LBB_CLEAR		; CLEAR
	.byte	3,'N'
	.word	LBB_NEW		; NEW
	.byte	5,'W'
	.word	LBB_WIDTH		; WIDTH
	.byte	3,'G'
	.word	LBB_GET		; GET
	.byte	4,'S'
	.word	LBB_SWAP		; SWAP
	.byte	6,'B'
	.word	LBB_BITSET		; BITSET
	.byte	6,'B'
	.word	LBB_BITCLR		; BITCLR
	.byte	7,'M'
	.word	LBB_MONITOR	; MONITOR
	.byte	4,'O'
	.word	LBB_OPEN	; OPEN
	.byte	5,'C'
	.word	LBB_CLOSE		; CLOSE
	.byte	8,'I'
	.word	LBB_IECINPUT	; IECINPUT
	.byte	9,'I'
	.word	LBB_IECOUTPUT	; IECOUTPUT
	.byte	4,'P'
	.word	LBB_PUTN		; PUTN
	.byte	4,'G'
	.word	LBB_GETN		; GETN
	.byte	7,'D'
	.word	LBB_DISKCMD		; DISKCMD
	.BYTE 	6,'S'
	.WORD 	LBB_SCNCLR		; SCNCLR
	.BYTE 	6,'L'
	.WORD 	LBB_LOCATE		; LOCATE
	.BYTE 	5,'C'
	.WORD 	LBB_COLOR		; COLOR
	.BYTE 	5,'S'
	.WORD 	LBB_SPOKE		; SPOKE
	.BYTE 	6,'S'
	.WORD 	LBB_SCREEN		; SCREEN
	.BYTE 	6,'S'
	.WORD 	LBB_SPRITE		; SPRITE
	.BYTE 	6,'S'
	.WORD 	LBB_SPRDEF		; SPRDEF
	.BYTE 	7,'S'
	.WORD 	LBB_SPRSIZE		; SPRSIZE
	.BYTE 	4,'P'
	.WORD 	LBB_PLOT		; PLOT
	.BYTE 	7,'P'
	.WORD 	LBB_PATTERN		; PATTERN
	.BYTE 	3,'S'
	.WORD 	LBB_SYS			; SYS
	.BYTE 	5,'S'
	.WORD 	LBB_SOUND		; SOUND
	.BYTE 	5,'N'
	.WORD 	LBB_NOISE		; NOISE
	.BYTE 	4,'T'
	.WORD 	LBB_TONE		; TONE
	.BYTE 	6,'V'
	.WORD 	LBB_VOLUME		; VOLUME
	.BYTE 	5,'V'
	.WORD 	LBB_VOICE		; VOICE

; secondary commands (can't start a statement)

	.byte	4,'T'
	.word	LBB_TAB		; TAB
	.byte	4,'E'
	.word	LBB_ELSE		; ELSE
	.byte	2,'T'
	.word	LBB_TO		; TO
	.byte	2,'F'
	.word	LBB_FN		; FN
	.byte	4,'S'
	.word	LBB_SPC		; SPC
	.byte	4,'T'
	.word	LBB_THEN		; THEN
	.byte	3,'N'
	.word	LBB_NOT		; NOT
	.byte	4,'S'
	.word	LBB_STEP		; STEP
	.byte	5,'U'
	.word	LBB_UNTIL		; UNTIL
	.byte	5,'W'
	.word	LBB_WHILE		; WHILE
	.byte	3,'O'
	.word	LBB_OFF		; OFF

; opperators

	.byte	1,'+'
	.word	$0000			; +
	.byte	1,'-'
	.word	$0000			; -
	.byte	1,'*'
	.word	$0000			; *
	.byte	1,'/'
	.word	$0000			; /
	.byte	1,'^'
	.word	$0000			; ^
	.byte	3,'A'
	.word	LBB_AND		; AND
	.byte	3,'E'
	.word	LBB_EOR		; EOR
	.byte	2,'O'
	.word	LBB_OR		; OR
	.byte	2,'>'
	.word	LBB_RSHIFT		; >>
	.byte	2,'<'
	.word	LBB_LSHIFT		; <<
	.byte	1,'>'
	.word	$0000			; >
	.byte	1,'='
	.word	$0000			; =
	.byte	1,'<'
	.word	$0000			; <

; functions

	.byte	4,'S'			;
	.word	LBB_SGN		; SGN
	.byte	4,'I'			;
	.word	LBB_INT		; INT
	.byte	4,'A'			;
	.word	LBB_ABS		; ABS
	.byte	4,'U'			;
	.word	LBB_USR		; USR
	.byte	4,'F'			;
	.word	LBB_FRE		; FRE
	.byte	4,'P'			;
	.word	LBB_POS		; POS
	.byte	4,'S'			;
	.word	LBB_SQR		; SQR
	.byte	4,'R'			;
	.word	LBB_RND		; RND
	.byte	4,'L'			;
	.word	LBB_LOG		; LOG
	.byte	4,'E'			;
	.word	LBB_EXP		; EXP
	.byte	4,'C'			;
	.word	LBB_COS		; COS
	.byte	4,'S'			;
	.word	LBB_SIN		; SIN
	.byte	4,'T'			;
	.word	LBB_TAN		; TAN
	.byte	4,'A'			;
	.word	LBB_ATN		; ATN
	.byte	5,'P'			;
	.word	LBB_PEEK		; PEEK
	.BYTE 	6,'S'
	.WORD 	LBB_SPEEK		; SPEEK
	.byte	5,'S'			;
	.word	LBB_SADD		; SADD
	.byte	4,'L'			;
	.word	LBB_LEN		; LEN
	.byte	5,'S'			;
	.word	LBB_STRS		; STR$
	.byte	4,'V'			;
	.word	LBB_VAL		; VAL
	.byte	4,'A'			;
	.word	LBB_ASC		; ASC
	.byte	7,'U'			;
	.word	LBB_UCASES		; UCASE$
	.byte	7,'L'			;
	.word	LBB_LCASES		; LCASE$
	.byte	5,'C'			;
	.word	LBB_CHRS		; CHR$
	.byte	5,'H'			;
	.word	LBB_HEXS		; HEX$
	.byte	5,'B'			;
	.word	LBB_BINS		; BIN$
	.byte	7,'B'			;
	.word	LBB_BITTST		; BITTST
	.byte	4,'M'			;
	.word	LBB_MAX			; MAX
	.byte	4,'M'			;
	.word	LBB_MIN			; MIN
	.byte	2,'P'			;
	.word	LBB_PI			; PI
	.byte	5,'I'			;
	.word	LBB_IECST		; IECST
	.byte	7,'V'			;
	.word	LBB_VIDST		; VIDST
	.byte	5,'V'			;
	.word	LBB_VPTR		; VARPTR
	.byte	6,'L'			;
	.word	LBB_LEFTS		; LEFT$
	.byte	7,'R'			;
	.word	LBB_RIGHTS		; RIGHT$
	.byte	5,'M'			;
	.word	LBB_MIDS		; MID$
	.byte	4,'C'			;
	.word	LBB_CON			; CON
