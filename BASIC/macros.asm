;___________________________________________________________________________________________________
;
;	USEFUL 65186 MACROS
;__________________________________________________________________________________________________


STYZP.X  .macro _op
         .DB $94
         .db <_op
         .endm


StoreContext    .macro                ; Store Complete Context at the beginning of a Sub
        PHX
        phy
        pha
        php
        .endm

RestoreContext  .macro                ; Restore Complete Context at the end of a Sub
        plp
        pla
        ply
        plx
        .endm

Index16         .macro                ; Set 16bit Index Registers
		REP #$10 		; 16 bit Index registers
		LONGI ON
        .endm
Index8          .macro                ; Set 8bit Index Registers
		SEP #$10 		; 8 bit Index registers
		LONGI OFF
        .endm

Accumulator16   .macro                ; Set 16bit Index Registers
		REP #$20 		; 16 bit Index registers
		LONGA ON
        .endm

Accumulator8    .macro                ; Set 8bit Index Registers
		SEP #$20 		; 8 bit Index registers
		LONGA OFF
        .endm

AccumulatorIndex16  .macro            ; Set 16bit Index Registers
		REP #$30 		; 16 bit Index registers
		LONGA ON
        LONGI ON
        .endm

AccumulatorIndex8   .macro            ; Set 8bit Index Registers
		SEP #$30 		; 8 bit Index registers
		LONGA OFF
        LONGI OFF
        .endm



cr      .macro                ; Restore Complete Context at the end of a Sub
        SEP #$20 		; 8 bit accum
		LONGA OFF
        .endm




LDAINDIRECTY .MACRO PARM1
    PHB
	PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
	LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLB
    LDA <TMPFLG
    .endm

STAINDIRECTY .MACRO PARM1
    PHB
	PHX
    PHA
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLA
    PLX
	STA	(<PARM1),Y		;
	PLB
    STA <TMPFLG
    .endm

SETBANK .MACRO PARM1
    PHX
	LDX #PARM1
	PHX
	PLB
    PLX
    .endm


FETCHINDIRECTY .MACRO PARM1
    PHB
	PHA
    PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
    LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLA
    PLB
    .endm

CMPINDIRECTY .MACRO PARM1
    PHB
    PHA
    PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
    LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLA
    PLB
    CMP	<TMPFLG		    ;
    .endm

ADCINDIRECTY .MACRO PARM1
    PHB
    PHA
    PHX
    LDX #$01
    LDA <PARM1,X
    CMP #$00
    BNE *+6
	LDX #00
	PHX
	PLB
    PLX
    LDA	(<PARM1),Y		;
    STA <TMPFLG
    PLA
    PLB
    CLC
    ADC	<TMPFLG 		;
    .endm

LBEQ .MACRO PARM1
     bne *+5
     jmp PARM1
    .endm

LBNE .MACRO PARM1
     beq *+5
     jmp PARM1
    .endm

LBCC .MACRO PARM1
     bcc *+4
     bra *+5
     jmp PARM1
    .endm

LBCS .MACRO PARM1
     bcs *+4
     bra *+5
     jmp PARM1
    .endm

;