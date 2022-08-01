;___________________________________________________________________________________________________
;
;	USEFUL 65186 MACROS
;__________________________________________________________________________________________________

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

;