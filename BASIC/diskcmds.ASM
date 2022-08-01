;___V_SAVE_________________________________________________
;
; UTILIZE BIOS TO SAVE BASIC RAM
;
; STORE CONTENTS IN RAM FROM "Smeml/h" TO "Svarl/h"-1 IN BANK "DATABANK"
;
; BASIC COMMAND EXPECTS ONE STRING VAR (FILENAME) AND ONE NUMERIC VAR (DEVICE)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_SAVE:					; save BASIC program
        jsr LAB_EVEX        ; GET THE FIRST PARAMETER
        lda <Dtypef         ; IS IT A STRING?
        bne V_SAVE_GO       ; YES, CONTINUE ON
V_SAVE_ERR:
        ldx #$02            ; NOPE, SYNTAX ERROR
        jsr LAB_XERR
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
V_SAVE_GO:
        JSL LIECINIT        ; INIT IEC BUS
        lda #$C0
        sta >IECMSGM
        ldy #$00
V_SAVE_1:
        LDAINDIRECTY ssptr_l
        TYX
        STA >FNBUFFER,X
        CMP #$00
        beq V_SAVE_2
        cmp #'"'
        beq V_SAVE_2
        iny
        bne V_SAVE_1
V_SAVE_2:
        TYA             ; fn length
        ldx #<FNBUFFER
        ldy #>FNBUFFER
        PHB
        SETBANK 0
        JSL LSETNAM     ; setnam
        PLB
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X
        ldy#1           ; secondary address
        PHB
        SETBANK 0
        jsL LSETLFS
        lda <Smemh
        sta IECSTRTH
        lda <Smeml
        sta IECSTRTL
        lda <Svarl
        sta LOADBUFL
        lda <Svarh
        sta LOADBUFH
        lda #DATABANK
        sta LOADBANK
        jsL LSAVE
        PLB
        LDA	#<LAB_RMSG		; point to "Ready" message low byte
        LDY	#>LAB_RMSG		; point to "Ready" message high byte
        JSR	LAB_18C3
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC




;___V_LOAD_________________________________________________
;
; UTILIZE BIOS TO LOAD BASIC RAM
;
; LOAD CONTENTS TO RAM "Smeml/h" BANK "DATABANK"
;
; BASIC COMMAND EXPECTS ONE STRING VAR (FILENAME) AND ONE NUMERIC VAR (DEVICE)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_LOAD:					; load BASIC program
        jsr LAB_EVEX        ; GET THE FIRST PARAMETER
        lda <Dtypef         ; IS IT A STRING?
        bne V_LOAD_GO       ; YES, CONTINUE ON
V_LOAD_ERR:
        ldx #$02            ; NOPE, SYNTAX ERROR
        jsr LAB_XERR
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
V_LOAD_GO:
        JSL LIECINIT        ; INIT IEC BUS
        lda #$C0
        sta <IECMSGM
        ldy #$00
V_LOAD_1:
        LDAINDIRECTY ssptr_l
        TYX
        STA >FNBUFFER,X
        CMP #$00
        beq V_LOAD_2
        cmp #'"'
        beq V_LOAD_2
        iny
        bne V_LOAD_1
V_LOAD_2:
        TYA             ; fn length
        ldx #<FNBUFFER
        ldy #>FNBUFFER
        PHB
        SETBANK 0
        JSL LSETNAM     ; setnam
        PLB
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X
        ldy#1           ; secondary address
        PHB
        SETBANK 0
        jsL LSETLFS
        lda <Smemh
        sta LOADBUFH
        lda <Smeml
        sta LOADBUFL
        lda #DATABANK
        sta LOADBANK
        jsL LLOAD
        LDA LOADBUFH
        STA <Svarh
        LDA LOADBUFL
        STA <Svarl
        PLB
        LDA	#<LAB_RMSG		; point to "Ready" message low byte
        LDY	#>LAB_RMSG		; point to "Ready" message high byte
        JSR	LAB_18C3
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC


;___V_ERR___________________________________________________
;
; UTILIZE BIOS TO REPORT IEC IO CHANNEL STATUS
;
;
; BASIC COMMAND EXPECTS ONE NUMERIC VAR (DEVICE)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_ERR:
        JSL LIECINIT        ; INIT IEC BUS
        lda #$C0
        sta >IECMSGM
        ldy #$00
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X
GETIECSTATUS:
        PHB
        PHX
        SETBANK 0
        LDA     #13
        JSL LPRINTVEC	; OUTCHAR
        LDA     #10
        JSL LPRINTVEC	; OUTCHAR
        lda     #0      ; fn length
        ldx     #0
        ldy     #0
        JSL     LSETNAM  ; setnam
        PLX             ; Device Number
        ldy     #15     ; secondary address
        LDA     #15     ; LFN NUMBER
        JSL     LSETLFS  ;setlfs
        JSL     LIECOPNLF
        BCS     IECERROR
        LDX     #15
        JSL     LIECINPC
        BCS     IECERROR
GETIECSTATUS_1:
	    JSL	LIECIN 		; input a byte from the serial bus
        BCS     IECERROR
        CMP #13
        BEQ     IECERROR
        JSL LPRINTVEC	; OUTCHAR
	LDA	>IECSTW		        ; get serial status byte
	LSR				; shift time out read ..
	LSR				; .. into carry bit
	BCC	GETIECSTATUS_1		; all ok, do another
IECERROR:
        JSL     LIECCLCH         ; close input and output channels
        lda     #15
        JSL     LIECCLSLF        ; close a specified logical file
        LDA     #13
        JSL LPRINTVEC	; OUTCHAR
        LDA     #10
        JSL LPRINTVEC	; OUTCHAR
        PLB
        LDA	#<LAB_RMSG		; point to "Ready" message low byte
        LDY	#>LAB_RMSG		; point to "Ready" message high byte
        JSR	LAB_18C3
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC



;___V_DIR___________________________________________________
;
; UTILIZE BIOS TO DISPLAY DISK DIRECTORY
;
;
; BASIC COMMAND EXPECTS ONE NUMERIC VAR (DEVICE)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_DIR:
        JSL LIECINIT        ; INIT IEC BUS
        lda #$C0
        sta >IECMSGM
        ldy #$00
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X
        PHB
        PHX
        LDA     #'$'
        STA     >FNBUFFER
        SETBANK 0
        LDA     #13
        JSL     LPRINTVEC
        LDA     #10
        JSL     LPRINTVEC
        lda     #1      ; fn length
        ldx     #<FNBUFFER
        ldy     #>FNBUFFER
        JSL     LSETNAM  ; setnam
        PLX             ; Device Number
        ldy     #0      ; secondary address
        LDA     #15     ; LFN NUMBER
        JSL     LSETLFS  ;setlfs
        JSL     LIECOPNLF
        BCS     IECERROR
        LDX     #15
        JSL     LIECINPC
        BCS     IECERROR
       	JSL	LIECIN 		; input a byte from the serial bus
GETIECDIRECTORY_1:
        JSL	LIECIN 		; input a byte from the serial bus
        JSL	LIECIN 		; input a byte from the serial bus
        PHA
        JSL	LIECIN 		; input a byte from the serial bus
        PLX
        PLB
        PHB
        JSR	LAB_295E		; print XA as unsigned integer (bytes free)
        SETBANK 0
        LDA     #' '
        JSL     LPRINTVEC
        LDA     #' '
        JSL     LPRINTVEC
        JSL	LIECIN
        CMP     #$00
        BEQ     GETIECDIRECTORY_2A
        JSL     LPRINTVEC
GETIECDIRECTORY_2A:
        JSL	LIECIN
        CMP     #$00
        BEQ     GETIECDIRECTORY_2
        JSL     LPRINTVEC
GETIECDIRECTORY_2:
        JSL	LIECIN 		; input ENTRY TEXT byte from the serial bus
        JSL     LPRINTVEC
        CMP     #$00
        BEQ     GETIECDIRECTORY_3       ; END ENTRY

 	LDA	>IECSTW		        ; get serial status byte
	LSR				; shift time out read ..
	LSR				; .. into carry bit
	BCC	GETIECDIRECTORY_2		; all ok, do another
GETIECDIRECTORY_END:
        JSL     LIECCLCH         ; close input and output channels
        lda     #15
        JSL     LIECCLSLF        ; close a specified logical file
        LDA     #13
        JSL     LPRINTVEC
        LDA     #10
        JSL     LPRINTVEC
        PLB
        LDA	#<LAB_RMSG		; point to "Ready" message low byte
        LDY	#>LAB_RMSG		; point to "Ready" message high byte
        JSR	LAB_18C3
        JMP     LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC

GETIECDIRECTORY_3:
        LDA     #13
        JSL     LPRINTVEC
        LDA     #10
        JSL     LPRINTVEC
       	JSL	LIECIN 		; input a byte from the serial bus
        CMP     #$01
        BNE     GETIECDIRECTORY_END
        JMP     GETIECDIRECTORY_1


;___V_DISKCMD______________________________________________
;
; UTILIZE BIOS TO SEND A DISK COMMAND
;
;
; BASIC COMMAND EXPECTS ONE STRING VAR (COMMAND) AND ONE NUMERIC VAR (DEVICE)
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_DISKCMD:					; save BASIC program
        jsr LAB_EVEX        ; GET THE FIRST PARAMETER
        lda <Dtypef         ; IS IT A STRING?
        bne V_DISKCMD_GO       ; YES, CONTINUE ON
V_DISKCMD_ERR:
        ldx #$02            ; NOPE, SYNTAX ERROR
        jsr LAB_XERR
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
V_DISKCMD_GO:
        JSL LIECINIT        ; INIT IEC BUS
        lda #$C0
        sta >IECMSGM
        JSR	LAB_22B6		; pop string off descriptor stack, or from top of string
                            ; space returns with A = length, X=$71=pointer low byte,
      					    ; Y=$72=pointer high byte
        STX <ssptr_l
        STY <ssptr_h
        TAX
        ldy #$00
V_DISKCMD_1:
        LDAINDIRECTY ssptr_l
        PHX
        TYX
        STA >FNBUFFER,X
        PLX
        DEX
        CPX #$00
        beq V_DISKCMD_2
        iny
        bne V_DISKCMD_1
V_DISKCMD_2:
        TYX
        LDA #0
        STA >FNBUFFER+1,X
        PHB
        SETBANK 0
        lda     #0      ; fn length
        ldx     #0
        ldy     #0
        JSL     LSETNAM  ; setnam
        PLB
        JSR	LAB_1C01    ; GET THE SECOND PARAMETER (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER (DEVICE NUMBER), RETURN IN X
        PHB
        SETBANK 0
        ldy     #15     ; secondary address
        LDA     #15     ; LFN NUMBER
        JSL     LSETLFS  ;setlfs
        JSL     LIECOPNLF
        BCS     V_DISKCMD_ERR1
        LDX     #15
        JSL     LIECOUTC
        LDX     #$00
V_DISKCMD_3:
        LDA >FNBUFFER,X
        CMP #$00
        BEQ V_DISKCMD_4
	    JSL	LIECOUT 		; OUTPUT a byte To the serial bus
        BCS V_DISKCMD_ERR1

        INX
        BRA V_DISKCMD_3
V_DISKCMD_4:
        lda     #15
        JSL     LUNLSTN
        lda     #15
        JSL     LIECCLSLF        ; close a specified logical file
        PLB
        RTS
V_DISKCMD_ERR1:
        JSL     LIECCLCH         ; close input and output channels
        lda     #15
        JSL     LIECCLSLF        ; close a specified logical file
        LDA     #13
        JSL LPRINTVEC	; OUTCHAR
        LDA     #10
        JSL LPRINTVEC	; OUTCHAR
        PLB
        LDA	#<LAB_RMSG		; point to "Ready" message low byte
        LDY	#>LAB_RMSG		; point to "Ready" message high byte
        JSR	LAB_18C3
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC



;___V_OPEN__________________________________________________
;
; UTILIZE BIOS TO OPEN AN IEC IO CHANNEL
;
;
; BASIC COMMAND EXPECTS THREE NUMERIC VARS, AND ONE STRING
; VAR
; FILE#, DEVICE, SECONDARY ADDRESS, FILENAME
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_OPEN:
        PHB
        JSL LIECINIT        ; INIT IEC BUS
        lda #$C0
        sta >IECMSGM
        ldy #$00
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        phx
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE SECOND PARAMETER, RETURN IN X (DEVICE)
        PHX
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
        JSR	LAB_GTBY    ; GET THE THIRD PARAMETER, RETURN IN X (SECONDARY ADDRESS)
        PHX
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR
        jsr LAB_EVEX        ; GET THE FOURTH PARAMETER
        lda <Dtypef         ; IS IT A STRING?
        bne V_OPEN_GO       ; YES, CONTINUE ON
        ldx #$02            ; NOPE, SYNTAX ERROR
        jsr LAB_XERR
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
V_OPEN_GO:
        JSR	LAB_22B6		; pop string off descriptor stack, or from top of string
                            ; space returns with A = length, X=$71=pointer low byte,
      					    ; Y=$72=pointer high byte
        STX <ssptr_l
        STY <ssptr_h
        TAX
        ldy #$00
V_OPEN_1:
        LDAINDIRECTY ssptr_l
        PHX
        TYX
        STA >FNBUFFER,X
        PLX
        DEX
        CPX #$00
        beq V_OPEN_2
        iny
        bne V_OPEN_1
V_OPEN_2:
        INY
        TYA             ; fn length
        ldx #<FNBUFFER
        ldy #>FNBUFFER
        SETBANK 0
        JSL LSETNAM     ; setnam
        PLX
        TXY             ; secondary address
        PLX             ; DEVICE NUMBER
        PLA             ; LFN NUMBER
        JSL     LSETLFS  ;setlfs
        JSL     LIECOPNLF
        BCS     V_OPEN_IECERROR
        PLB
        RTS
 V_OPEN_IECERROR:
        JMP  IECERROR

;___V_CLOSE________________________________________________
;
; UTILIZE BIOS TO CLOSE AN IEC IO CHANNEL
;
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_CLOSE:
        PHB
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        SETBANK 0
        TXA
        JSL     LIECCLSLF        ; close a specified logical file
        PLB
        RTS

;___V_IECINPUT_______________________________________________
;
; UTILIZE BIOS TO USE OPEN AN IEC CHANNEL AS INPUT
;
;
; BASIC COMMAND EXPECTS ONE NUMERIC VARS, FILE#
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_IECINPUT:
        PHB
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        SETBANK 0
        JSL     LIECINPC
        BCS     V_IECINPUT_IECERROR
        PLB
        RTS
 V_IECINPUT_IECERROR:
        PLB
        JMP  IECERROR

;___V_IECOUTPUT______________________________________________
;
; UTILIZE BIOS TO USE OPEN AN IEC CHANNEL AS OUTPUT
;
;
; BASIC COMMAND EXPECTS ONE NUMERIC VARS, FILE#
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_IECOUTPUT:
        PHB
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        SETBANK 0
        JSL     LIECOUTC
        BCS     V_IECOUTPUT_IECERROR
        PLB
        RTS
 V_IECOUTPUT_IECERROR:
        PLB
        JMP  IECERROR


;___V_PUTN__________________________________________________
;
; UTILIZE BIOS TO PRINT TO AN IEC IO CHANNEL
;
; STARTING WITH FILE#, OUTPUT STRING
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_PUTN:
        JSR	LAB_GTBY    ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        STX <TMPFLG
        JSR	LAB_1C01    ; (AFTER ',') OR SYN ERR

        jsr LAB_EVEX        ; GET THE FIRST PARAMETER
        lda <Dtypef         ; IS IT A STRING?
        bne V_PUTN_GO       ; YES, CONTINUE ON
V_PUTN_ERR:
        ldx #$02            ; NOPE, SYNTAX ERROR
        jsr LAB_XERR
        JMP LAB_1319        ; RESET VARS, STACK AND RETURN CONTROL TO BASIC
V_PUTN_GO:
        JSR	LAB_22B6		; pop string off descriptor stack, or from top of string
                            ; space returns with A = length, X=$71=pointer low byte,
      					    ; Y=$72=pointer high byte
        STX <ssptr_l
        STY <ssptr_h
        TAX
        LDY #$00
V_PUTN_1:
        LDAINDIRECTY ssptr_l
        PHX
        PHY
        PHB
        SETBANK 0
        LDX <TMPFLG
        PHA
        JSL LIECOUT
        PLA
        JSL LPRINTVEC
        PLB
        PLY
        PLX
        DEX
        cpx #00
        beq V_PUTN_2
        iny
        bne V_PUTN_1
V_PUTN_2:
        RTS



;___LAB_IECST_______________________________________________
;
; RETURN IEC STATUS BYTE
;
; THIS IS NATIVE '816 CODE
;__________________________________________________________
LAB_IECST
    PHA
    LDA >IECSTW     ; get IECSTW into low byte
    TAY
    PLA
   	LDA	#0		    ; NO high byte
   	JSR	LAB_AYFC
    RTS
LAB_PIECST
	LSR	<Dtypef		; clear data type flag, $FF=string, $00=numeric
	JSL	LAB_IGBY		; increment and scan memory then do function
	RTS

;___V_GETN_________________________________________________
;
; UTILIZE BIOS TO INPUT FROM AN IEC IO CHANNEL
;
; LOTS OF PARAMETERS :)  STARTING WITH FILE#
; THIS IS NATIVE '816 CODE
;__________________________________________________________
V_GETN:
        JSR	LAB_GTBY            ; GET THE FIRST PARAMETER, RETURN IN X (FILE#)
        PHX                     ; STORE DEVICE NUMBER
        JSR	LAB_1C01            ; (AFTER ',') OR SYN ERR
    	JSR	LAB_GVAR		    ; get var address
    	STA	<Lvarpl		        ; save var address low byte
    	STY	<Lvarph		        ; save var address high byte
        PLX
        PHB
        SETBANK 0
        LDX <TMPFLG
    	JSL	LIECIN              ; get input byte
        PLB

    	LDX	<Dtypef		        ; get data type flag, $FF=string, $00=numeric
    	BMI	LAB_GETNS		    ; go get string character
        					    ; was numeric get
    	TAY				        ; copy character to Y
    	JSR	LAB_1FD0		    ; convert Y to byte in FAC1
    	JMP	LAB_PFAC		    ; pack FAC1 into variable (<Lvarpl) and return
LAB_GETNS
        PHA
        LDA #$01
    	JSR	LAB_MSSP		    ; make string space A bytes long A=$AC=length,
					            ; X=$AD=<Sutill=ptr low byte, Y=$AE=<Sutilh=ptr high byte
    	PLA				        ; get character back
    	LDY	#$00			    ; clear index
    	STAINDIRECTY str_pl		; save byte in string (byte IS string!)
    	JSR	LAB_RTST		    ; check for space on descriptor stack then put address
					            ; and length on descriptor stack and update stack pointers
    	JMP	LAB_17D5		    ; do string LET and return
