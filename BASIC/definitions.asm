PROGRAMBANK	.EQU $FF		; BANK THAT THE INTREPRETER LIVES IN
DATABANK	.EQU $02		; BANK THAT THE DATA LIVES IN

FNBUFFER    .EQU $001000    ; FILE NAME BUFFER, MUST BE IN ZERO BANK!



; offsets from a base of X or Y

PLUS_0		.EQU $00		; X or Y plus 0
PLUS_1		.EQU $01		; X or Y plus 1
PLUS_2		.EQU $02		; X or Y plus 2
PLUS_3		.EQU $03		; X or Y plus 3

STACK_BOTTOM	.EQU $4000	; stack bottom, no offset
STACK   		.EQU $7FFF	; stack top, no offset

ccflag		.EQU $000200	; BASIC CTRL-C flag, 00 = enabled, 01 = dis
ccbyte		.EQU ccflag+1	; BASIC CTRL-C byte
ccnull		.EQU ccbyte+1	; BASIC CTRL-C byte timeout

VEC_CC		.EQU ccnull+1	; ctrl c check vector


; Ibuffs can now be anywhere in RAM AS LONG AS IT IS BEFORE RAM_BASE AND IS NOT PAGE ALIGNED!, ensure that the max length is < $80

    IF PROGRAMBANK=DATABANK
Ibuffs		.EQU  (ENDOFBASIC&$FF00)+$181
    ELSE
Ibuffs		.EQU  $2000+$181
LIbuffs		.EQU  (DATABANK*$10000)+$2000+$181
    ENDIF
Ibuffe		.EQU Ibuffs+80; end of input buffer

Ram_base	.EQU ((Ibuffe+1)&$FF00)+$100	    ; start of user RAM (set as needed, should be page aligned)
Ram_top		.EQU $FF00						; end of user RAM+1 (set as needed, should be page aligned)
