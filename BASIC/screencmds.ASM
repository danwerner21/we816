;___SCNCLR_________________________________________________
;
; UTILIZE BIOS TO CLEAR SCREEN
;
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SCNCLR:
        PHB
        SETBANK 0
        JSL LClearScrVec
        PLB
        RTS

;___LOCATE_________________________________________________
;
; UTILIZE BIOS TO LOCATE CURSOR
;
;  TAKES TWO PARAMETERS X,Y
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_LOCATE:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        phx
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (DEVICE)
        PLY
        PHB
        SETBANK 0
        JSL LSetXYVEC
        PLB
        RTS

;___COLOR_________________________________________________
;
; UTILIZE BIOS TO SET COLORS
;
;  TAKES TWO PARAMETERS BACKGROUND,FOREGROUND
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_COLOR:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        TXA
        AND     #$0F
        PHA
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (DEVICE)
        TXA
        AND     #$0F
        CLC
        ASL
        ASL
        ASL
        ASL
        STA <TMPFLG
        pla
        ORA <TMPFLG
        PHB
        SETBANK 0
        JSL LSetColorVEC
        PLB
        RTS

;___V_SPEEK()______________________________________________
;
; GET VALUE FROM SCREEN MEMORY
;
;  TAKES ONE PARAMETER (ADDRESS), RETURNS VALUE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPEEK:
	JSR	LAB_F2FX		; save integer part of FAC1 in temporary integer

       	PHB
        setbank 0
	LDX	#$00			; clear index
        JSR SPEEK_1
        plb
	TAY				; copy byte to Y
	JMP	LAB_1FD0		; convert Y to byte in FAC1 and return

SPEEK_1:
	LDA	<Itempl
	sta	>CMDP
        jsr     DELAY9918
        LDA 	<Itemph
        ORA	#$40
	AND	#$7F
	sta	>CMDP
        jsr     DELAY9918
        LDA     >DATAP
;       REPEATING THE READ FOR RELIABILITY (SOMETIMES ONE READ DOES NOT WORK, IF THE 9918 IS EVER REPLACED WITH A v99x8 THIS CAN BE REMOVED)
	LDA	<Itempl
	sta	>CMDP
        jsr     DELAY9918
        LDA 	<Itemph
        ORA	#$40
	AND	#$7F
	sta	>CMDP
        jsr     DELAY9918
        LDA     >DATAP
	RTS

;___V_SPOKE_________________________________________________
;
; PUT VALUE IN SCREEN MEMORY
;
;  TAKES TWO PARAMETERS ADDRESS,VALUE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPOKE:
	JSR	LAB_GADB		; get two parameters for POKE or WAIT
        PHB
	PHX				; SAVE byte argument
        SETBANK 0
        ; Let's set VDP write address to Itemp
	LDA	<Itempl
	sta	CMDP
        jsr     DELAY9918
        LDA 	<Itemph
	AND	#$7F
        ORA	#$40
	sta	CMDP
        jsr     DELAY9918
        PLA
	STA	DATAP
        PLB
	RTS

;___V_SCREEN_________________________________________________
;
;  SET SCREEN MODE
;
;  TAKES ONE PARAMETER,  SCREEN MODE
;  0=GRAPHICS MODE (32X24)
;  1=MULTICOLOR (64X48 BLOCKS)
;  2=TEXT MODE (40X24)
;  4=GRAPHICS MODE 2 (32X24 MULTICOLOR)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SCREEN:
        JSR	LAB_CKRN    ; check not Direct, back here if ok
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (MODE)
V_SCREEN1:
        STX     <VIDEOMODE
        CPX     #00
        BNE     *+5
        JMP     SETUPMODE0
        CPX     #01
        BNE     *+5
        JMP     SETUPMODE1
        CPX     #02
        BNE     *+5
        JMP     SETUPMODE2
        CPX     #03
        BNE     *+5
        JMP     SETUPMODE3
        CPX     #04
        BNE     *+5
        JMP     SETUPMODE4

        ldx #$02            ; SYNTAX ERROR
        jsr LAB_XERR
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC

        RTS

SETUPMODE0:
       	LDA	#<Mode0Parameters	; point to Parameters for Mode 4
   	LDY	#>Mode0Parameters
        jsr     Set9918Parms
 ;       CLEAR RAM
        INDEX16
        LDX     #$0000
        STX     <LOCALWORK
        INDEX8
        JSR     SET9918ADDRESS
        INDEX16
        LDX     #$4000
        LDA     #$00
SETUPMODE0_1:
        JSR     DELAY9918
        STA     >DATAP
        DEX
        CPX     #$0000
        BNE     SETUPMODE0_1
        INDEX8
        rts
SETUPMODE1:
       	LDA	#<Mode1Parameters	; point to Parameters for Mode 4
   	LDY	#>Mode1Parameters
        jsr     Set9918Parms
        PHB
        setbank 0
        ldy #$00
SETUPMODE1_1:
        ACCUMULATOR16
        TYA
        and #$00FF
        CLC
        ASL     ; a=y*32
        ASL
        ASL
        ASL
        ASL
        CLC
        ADC #1024
        sta <LOCALWORK
        ACCUMULATOR8
	LDA <LOCALWORK
	sta CMDP
        jsr     DELAY9918
	LDA <LOCALWORK+1
	ORA #$40
	AND #$7F
	sta CMDP
        TYA
        and #$FC
        CLC
        ASL
        ASL
        ASL
        sta <Itempl
        ldx #$00
SETUPMODE1_2:
        lda <Itempl
        sta DATAP
        jsr     DELAY9918
        inc <Itempl
        inx
        cpx #32
        bne SETUPMODE1_2
        iny
        cpy #24
        bne SETUPMODE1_1
; CLEAR SCREEN
        INDEX16
        jsr     DELAY9918
        LDA #$00
	sta CMDP
        jsr     DELAY9918
        LDX #$0000
	LDA #$08
	ORA #$40
	AND #$7F
	sta CMDP
        LDA #$00
SETUPMODE1_3:
        jsr     DELAY9918
        STA DATAP
        inx
        CPX #$0601
        BNE SETUPMODE1_3
        INDEX8
        plb
        RTS
SETUPMODE2:
        LDA     #40
        STA     >VIDEOWIDTH
       	LDA	#<Mode2Parameters	; point to Parameters for Mode 4
   	LDY	#>Mode2Parameters
        jsr     Set9918Parms
        PHB
        SETBANK 0
        JSL LLOADFONTVec
        JSL LClearScrVec
        PLB
        RTS
SETUPMODE3:
       	LDA	#<Mode3Parameters	; point to Parameters for Mode 4
   	LDY	#>Mode3Parameters
        jsr     Set9918Parms
 ;       CLEAR RAM
        INDEX16
        LDX     #$0000
        STX     <LOCALWORK
        INDEX8
        JSR     SET9918ADDRESS
        INDEX16
        LDX     #$4000
        LDA     #$00
SETUPMODE3_1:
        JSR     DELAY9918
        STA     >DATAP
        DEX
        CPX     #$0000
        BNE     SETUPMODE3_1
        INDEX8
        rts

SETUPMODE4:
       	LDA	#<Mode4Parameters	; point to Parameters for Mode 4
   	LDY	#>Mode4Parameters
        jsr     Set9918Parms
        PHB
        SETBANK 0
        ;       CLEAR RAM
        INDEX16
        LDX     #$0000
        STX     <LOCALWORK
        INDEX8
        JSR     SET9918ADDRESS
        INDEX16
        LDX     #$4000
        LDA     #$00
SETUPMODE4_1:
        JSR     DELAY9918
        STA     >DATAP
        DEX
        CPX     #$0000
        BNE     SETUPMODE4_1
        JSR     DELAY9918
        ;       POPULATE NAME TABLE
        LDX     #$3800
        STX     <LOCALWORK
        INDEX8
        JSR     SET9918ADDRESS
        INDEX16
        LDX     #$0300
        LDA     #$00
SETUPMODE4_2:
        JSR     DELAY9918
        STA     >DATAP
        INC
        DEX
        CPX     #$0000
        BNE     SETUPMODE4_2
        INDEX8
        PLB
        rts

Mode0Parameters:
        .db     $00,$C0,$05,$80,$01,$20,$00,$01
        .dB     $10                   ; Sprite attribute table
        .dB     $00                   ; Sprite Pattern Table

Mode1Parameters:
        .db    $00,$CB,$01,$80,$01,$0E,$00,$F1
        .dB    $07                   ; Sprite attribute table
        .dB    $00                   ; Sprite Pattern Table

Mode2Parameters:
        .db    $00,$D0,$01,$80,$01,$0E,$00,$F4
        .dB    $07                   ; Sprite attribute table
        .dB    $00                   ; Sprite Pattern Table

Mode3Parameters:
        .db    $02,$C2,$0E,$9F,$00,$76,$03,$F0
        .dB    $3b                   ; Sprite attribute table
        .dB    $18                   ; Sprite Pattern Table

Mode4Parameters:
        .db    $02,$C2,$0E,$FF,$03,$76,$03,$F0
        .dB    $3b                   ; Sprite attribute table
        .dB    $18                   ; Sprite Pattern Table

Set9918Parms:
        ; copy parms and set sprite table vectors
        sta     <LOCALWORK
        sty     <LOCALWORK+1
        ldy     #$00
Set9918Parms1:
        PHB
        SETBANK PROGRAMBANK
        lda (<LOCALWORK),Y
        setbank 0
        sta >CMDP
        TYA
        CLC
        adc #$80
        sta >CMDP
        plb
        iny
        cpy #$08
        bne Set9918Parms1
        CLC
        PHB
        SETBANK PROGRAMBANK
        lda (<LOCALWORK),Y
        sta >SpriteAttrs
        iny
        lda (<LOCALWORK),Y
        sta >SpritePatterns
        PLB
        rts

SET9918ADDRESS:
        LDA <LOCALWORK
	sta >CMDP
        JSR DELAY9918
	LDA <LOCALWORK+1
	ORA #$40
	AND #$7F
	sta >CMDP
        RTS


;___V_SPRITE________________________________________________
;
;  SET SPRITE PARAMETERS
;
;  TAKES SIX PARAMETERS
;       SPRITE NUM (0-32)
;       SPRITE PATTERN (0-255)
;       X CORD (0-255)
;       Y CORD (0-255)
;       COLOR  (0-15)
;       LEFT SHIFT BIT (0/1)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPRITE:
        PHB
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (SPRITE#)
        TXA
        AND     #$1F
        CLC
        ASL                 ; A=A*4
        ASL
        STA     <LOCALWORK
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (PATTERN)
        PHX
        JSR	LAB_1C01    ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE THIRD PARAMETER, RETURN IN X (X CORD)
        PHX
        JSR	LAB_1C01    ; GET THE FOURTH PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE FOURTH PARAMETER, RETURN IN X (Y CORD)
        PHX
        JSR	LAB_1C01    ; GET THE FIFTH PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE FIFTH PARAMETER, RETURN IN X (COLOR)
        TXA
        AND     #$0F
        PHA
        JSR	LAB_1C01    ; GET THE SIXTH PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SIXTH PARAMETER, RETURN IN X (EARLY CLOCK)
        TXA
        AND    #01
        CMP     #$00
        BEQ   NOSHIFT
        PLA
        ORA  #$80
        PHA
NOSHIFT:
        SETBANK 0
        LDA     <LOCALWORK
	sta	CMDP
        jsr     DELAY9918
        LDA     SpriteAttrs
        ORA 	#$40
	sta	CMDP
        PLA                     ; COLOR
        STA     <LOCALWORK
        PLY                     ; VERTICAL POSITION
        PLX                     ; HORIZONTAL POSITION
        PLA                     ; NAME TABLE LOCATION
        jsr     DELAY9918
        STY     DATAP
        jsr     DELAY9918
        STX     DATAP
        jsr     DELAY9918
        STA     DATAP
        jsr     DELAY9918
        LDA     <LOCALWORK
        STA     DATAP
        plb
        RTS


;___V_SPRDEF________________________________________________
;
;  DEFINE SPRITE PATTERN
;
;  TAKES 9 OR 17 PARAMETERS
;       SPRITE NUM (0-32)
;       SPRITE PATTERN DATA (8 BYTES OR 16 BYTES)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPRDEF:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (SPRITE#)
        TXA
        ACCUMULATOR16
        AND     #$001F
        CLC
        ASL                 ; A=A*8
        ASL
        ASL
        STA     <LOCALWORK
        ACCUMULATOR8
        PHB
        SETBANK 0
        LDA     <LOCALWORK
	sta	CMDP
        jsr     DELAY9918
        LDA     SpritePatterns
        CLC
        ADC     <LOCALWORK+1
        ORA 	#$40
	sta	CMDP
        PLB
SPRDEF_PLOOP:
	LDA	#$2C			; load A with ","
       	LDY	#$00			; clear index
	CMP (<Bpntrl),Y		        ; check next byte is ','
	BNE	SPRDEF_EXIT	        ; if not EXIT
	JSL	LAB_IGBY		; increment
        JSR	LAB_GTBY                ; GET SPRITE DATA
        PHB
        SETBANK 0
        STX     DATAP
        PLB
        BRA     SPRDEF_PLOOP
SPRDEF_EXIT:
        RTS


;___LAB_VIDST_______________________________________________
;
; RETURN VIDEO STATUS BYTE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_VIDST
        PHB
        SETBANK 0
        LDA CMDP     ; get VIDEO ST into low byte
        TAY
        PLB
        LDA	#0		    ; NO high byte
        JSR	LAB_AYFC
        RTS
        LSR	<Dtypef		    ; clear data type flag, $FF=string, $00=numeric
        JSL	LAB_IGBY	    ; increment and scan memory then do function
        RTS
LAB_PVIDST
	LSR	<Dtypef		; clear data type flag, $FF=string, $00=numeric
	JSL	LAB_IGBY		; increment and scan memory then do function
	RTS


;___SPRSIZE_________________________________________________
;
; SET SPRITE SIZE AND MAGNIFICATION
;
;  TAKES ONE PARAMETER
;
; 0= 8X8 SPRITES, 1x DISPLAY
; 1= 8X8 SPRITES, 2X DISPLAY
; 2= 16X16 SPRITES, 1X DISPLAY
; 3= 16X16 SPRITES, 2X DISPLAY
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SPRSIZE:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (MODE)
        PHX
        LDX     <VIDEOMODE
        TXA
        AND     #$03
        CLC
        ASL
        ASL
        ASL
        ORA     #$C0
        AND     #$D8
        STA     <TMPFLG
        PLA
        AND     #$03
        CLC
        ADC     <TMPFLG
        PHB
        PHA
        SETBANK 0
;       SET Register 1
        PLA
        STA	CMDP
        jsr     DELAY9918
        LDA     #$81
	STA	CMDP
        PLB
        RTS



;___V_PLOT__________________________________________________
;
;  PLOT ON SCREEN
;         VM= 1     TAKES THREE PARAMETERS,  X,Y,COLOR
;         VM= 4     TAKES FOUR PARAMETERS,  X,Y,PRIORITY,COLOR
;         VM= 0 AND 3     TAKES THREE PARAMETERS,  X,Y,PATTERN
;
;  0=GRAPHICS MODE (32X24)
;  1=MULTICOLOR MODE (64X48 BLOCKS)
;  2=TEXT MODE (40X24)
;  3=GRAPHICS MODE 0, WITH MODE 2 COLOR (32X24 MULTICOLOR)
;  4=GRAPHICS MODE 2 (32X24 MULTICOLOR)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_PLOT:
        LDA     <VIDEOMODE
        CMP     #01
        BNE     *+5
        JMP     PLOT_MULTICOLOR
        CMP     #04
        BNE     *+5
        JMP     PLOT_GRII
        CMP     #00
        BNE     *+5
        JMP     PLOT_GRI
        CMP     #03
        BNE     *+5
        JMP     PLOT_GRI

V_PLOT_ERR:
        ldx #$02            ; SYNTAX ERROR
        jsr LAB_XERR
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
PLOT_MULTICOLOR:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (X)
        PHX
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (Y)
        PHX
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (COLOR)
        TXA                     ; GET COLOR
        PLY                     ; GET Y COORD
        PLX                     ; GET X COORD
        PHB                     ; STASH BANK
        PHA                     ; STASH COLOR
        PHY                     ; STASH Y COORD
        SETBANK 0
        ACCUMULATOR16
                                ; SET Y CORD = Y/8 * 32
        TYA
        AND #$00F8
        CLC
        ASL
        ASL
        ASL
        ASL
        ASL
        STA <LOCALWORK
        PLY
        TYA
        AND #$0007              ; GET REMAINDER
        CLC
        ADC <LOCALWORK
        STA <LOCALWORK          ; STASH Y PART OF ADDRESS
        TXA
        AND #$00FE              ;
        CLC
        ASL
        ASL
        ADC <LOCALWORK
        ADC #2048
        STA <LOCALWORK
        STA <Itempl
        ACCUMULATOR8
        JSR SPEEK_1
        jsr     DELAY9918
        pha
        LDA <LOCALWORK
	sta CMDP
        jsr     DELAY9918
        LDA <LOCALWORK+1
	ORA #$40
	AND #$7F
	sta CMDP
        TXA
        AND #$01
        CMP #$01
        BNE PLOTMODE2_HB
        PLA
        AND #$F0
        STA <LOCALWORK
        PLA
        AND #$0F
        ORA <LOCALWORK
        BRA PLOTMODE2_GO
PLOTMODE2_HB:
        PLA
        AND #$0F
        STA <LOCALWORK
        PLA
        AND #$0F
        ASL
        ASL
        ASL
        ASL
        ORA <LOCALWORK
PLOTMODE2_GO:
        STA DATAP
        PLB
        RTS
PLOT_GRII:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (X)
        PHX
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (Y)
        PHX
        JSR	LAB_1C01    ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE THIRD PARAMETER, RETURN IN X (FG/BG)
        PHX
        JSR	LAB_1C01    ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE THIRD PARAMETER, RETURN IN X (COLOR)
        STX     <Itempl     ; STASH COLOR INFO HERE
        PLX
        STX     <Itemph     ; STASH PRIORITY HERE
        PLY                 ; GET Y COORD
        PLX                 ; GET X COORD
        ACCUMULATOR16
        TYA
        AND #$00F8
        CLC
        ASL                     ; Y COORD
        ASL
        ASL
        ASL
        ASL
        STA <LOCALWORK
        TYA
        AND #$0007
        CLC
        ADC <LOCALWORK
        STA <LOCALWORK
        TXA
        AND #$00F8
        CLC
        ADC <LOCALWORK
        STA <LOCALWORK          ; BYTE OFFSET FOR COLOR AND PATTERN NOW IN LOCAL WORK
                                ; FIND PATTERN
        TXA
        AND     #$0007
        CLC
        ADC     #BITPATTERN
        PHB
        setbank PROGRAMBANK
        INDEX16
        TAX
        ACCUMULATOR8
        LDA     0,x
        plb
        STA <Temp_2            ; Temp_2 NOW CONTAINS THE MASK
        Index8
                               ; FIGURE PRIORITY - ZERO CLEARS BIT, NONZERO SETS BIT
        LDA     <Itempl        ; PUT COLOR ON STACK
        PHA
        LDA     <Itemph         ; PUT PRIORITY ON STACK
        PHA
                                ; GET EXISTING VALUE
        ACCUMULATOR16
        LDA     <LOCALWORK
        STA     <Itempl
        ACCUMULATOR8
        JSR SPEEK_1
        STA     <Itempl        ; STASH VALUE HERE
        PLA                    ; GET PRIORITY
        CMP     #$00
        BNE    PLOT_GRII_SET
; CLEAR BIT
        LDA <Temp_2             ; GET MASK
        EOR #$FF
        AND <Itempl             ; VALUE TO STORE IS NOW IN A
        PHA                     ; PLACE IT ON STACK
        BRA PLOT_GRII_2
;SET BIT
PLOT_GRII_SET:
        LDA <Temp_2             ; GET MASK
        ORA <Itempl             ; VALUE TO STORE IS NOW IN A
        PHA                     ; PLACE IT ON STACK
PLOT_GRII_2:
        LDA <LOCALWORK          ; SET WRITE ADDRESS
	sta >CMDP
        JSR DELAY9918
        LDA <LOCALWORK+1
	ORA #$40
	AND #$7F
	sta >CMDP
        JSR DELAY9918
        PLA                     ; GET MASK
        STA >DATAP
        JSR DELAY9918
;; NOW DO COLOR
        ACCUMULATOR16
        LDA #$2000
        CLC
        ADC <LOCALWORK
        STA <LOCALWORK
        ACCUMULATOR8
        LDA <LOCALWORK          ; SET WRITE ADDRESS
	sta >CMDP
        JSR DELAY9918
        LDA <LOCALWORK+1
	ORA #$40
	sta >CMDP
        JSR DELAY9918
        PLA                     ; GET COLOR
        STA >DATAP               ; STORE COLOR
        RTS
BITPATTERN:
        .DB     $80,$40,$20,$10,$08,$04,$02,$01
        ; GR-1 && 3 Plot
PLOT_GRI:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (X)
        PHX
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (Y)
        PHX
        JSR	LAB_1C01    ; GET THE THIRD PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE THIRD PARAMETER, RETURN IN X (PATTERN#)
        STX     <Itemph     ; STASH PATTERN HERE
        PLY                 ; GET Y COORD
        PLX                 ; GET X COORD
        ACCUMULATOR16
        TYA
        AND #$00FF
        CLC
        ASL                     ; Y COORD *32
        ASL
        ASL
        ASL
        ASL
        STA <LOCALWORK
        TXA
        AND #$00FF
        CLC
        ADC <LOCALWORK
        LDX <VIDEOMODE
        CPX #$00
        BEQ PLOT_GRI_A
        CLC
        ADC #$3800           ; LOCALWORK CONTAINS NAMETABLE ADDRESS VM=3
        BRA PLOT_GRI_B
PLOT_GRI_A:
        CLC
        ADC #$1400           ; LOCALWORK CONTAINS NAMETABLE ADDRESS VM=0
PLOT_GRI_B:
        STA <LOCALWORK
        ACCUMULATOR8
        LDA <LOCALWORK          ; SET PATTERN WRITE ADDRESS
	sta >CMDP
        JSR DELAY9918
        LDA <LOCALWORK+1
	ORA #$40
	AND #$7F
	sta >CMDP
        JSR DELAY9918
        LDA <Itemph             ; GET PATTERN
        STA >DATAP              ; STORE PATTERN
        RTS

DELAY9918:
        PHA
        PHA             ; MIGHT BE POSSIBLE TO REDUCE DELAY
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PHA
        PLA
        PLA
        RTS

;___V_PATTERN________________________________________________
;
;  DEFINE GGRAPHICS PATTERN
;
;  TAKES 10 PARAMETERS
;       PATTERN NUM (0-255)
;       COLOR NUM (0-255)
;       PATTERN DATA (8 BYTES)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_PATTERN:
        LDA     <VIDEOMODE
        CMP     #03
        BEQ     V_PATTERN3GO
        CMP     #00
        BEQ     V_PATTERNGO
                                ; IF NOT IN MODE 0 OR MODE 3, SYNTAX ERROR
        ldx #$02                ; SYNTAX ERROR
        jsr LAB_XERR            ;
        JMP LAB_1319            ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
                                ;
V_PATTERNGO:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (PATTERN#)
        TXA
        ACCUMULATOR16
        AND     #$00FF
        PHA
        CLC
        ASL                 ; A=A*8
        ASL
        ASL
        CLC
        ADC     #$0800
        STA     <LOCALWORK
        ACCUMULATOR8
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (COLOR)
        PHX
        LDA     <LOCALWORK
	sta	>CMDP
        JSR     DELAY9918
        lda     <LOCALWORK+1
        ORA 	#$40
	sta	>CMDP
V_PATTERN_PLOOP:
	LDA	#$2C			; load A with ","
       	LDY	#$00			; clear index
	CMP     (<Bpntrl),Y	        ; check next byte is ','
	BNE	V_PATTERN_EXIT	        ; if not EXIT
	JSL	LAB_IGBY		; increment
        JSR	LAB_GTBY                ; GET PATTERN DATA
        TXA
        STA     >DATAP
        BRA     V_PATTERN_PLOOP
V_PATTERN_EXIT:
; DO COLOR
        PLX
        ACCUMULATOR16
        PLA
        LSR
        LSR
        LSR
        LSR
        LSR
        CLC
        ADC   #$2000
        STA   <LOCALWORK
        ACCUMULATOR8
        LDA     <LOCALWORK
	sta	>CMDP
        JSR     DELAY9918
        LDA     <LOCALWORK+1
        ORA 	#$40
	sta	>CMDP
        JSR     DELAY9918
        TXA
        STA     >DATAP
        RTS


V_PATTERN3GO:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (PATTERN#)
        TXA
        ACCUMULATOR16
        AND     #$00FF
        CLC
        ASL                 ; A=A*8
        ASL
        ASL
        STA     <LOCALWORK
        ACCUMULATOR8
        lda     <LOCALWORK
        sta	>CMDP
        jsr     DELAY9918
        lda     <LOCALWORK+1
        ORA 	#$40
	sta	>CMDP
        ldy     #$08
V_PATTERN3_PLOOP:
        cpy     #$00
        beq     V_PATTERN3_EXIT
        dey
        phy
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (PATTERN#)
        PLY
        TXA
        STA     >DATAP
        BRA     V_PATTERN3_PLOOP
V_PATTERN3_EXIT:
; DO COLOR
        lda     <LOCALWORK
        sta	>CMDP
        jsr     DELAY9918
        lda     <LOCALWORK+1
        CLC
        adc     #$20
        ORA 	#$40
	sta	>CMDP
        ldy     #$08
V_PATTERN3a_PLOOP:
        cpy     #$00
        beq     V_PATTERN3a_EXIT
        dey
        phy
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (PATTERN#)
        PLY
        TXA
        STA     >DATAP
        BRA     V_PATTERN3a_PLOOP
V_PATTERN3a_EXIT:
        RTS
