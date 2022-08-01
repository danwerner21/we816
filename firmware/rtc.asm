
;__RTC___________________________________________________________
;
;	DS1302 DRIVERS FOR THE RBC 65c816 SBC
;
;	WRITTEN BY: DAN WERNER -- 10/8/2017
;
;________________________________________________________________
;
; DATA CONSTANTS
;________________________________________________________________

mask_data:  .EQU    $80     ; RTC data line
mask_clk:   .EQU    $40     ; RTC Serial Clock line
mask_rd:    .EQU    $20     ; Enable data read from RTC
mask_rst:   .EQU    $10     ; De-activate RTC reset line



;__RTC_WRITE____________________________________________________
;
; WRITE DATA TO RTC REGISTER OR NVRAM
;
; input address in X
; input value in A
;
;_______________________________________________________________
RTC_WRITE:
    PHX
    PHY
    PHP
    SEP #$30            ; 8 bit REGISTERS
    LONGA OFF
    LONGI OFF
    SEI
    JSR RTC_RESET_OFF   ; turn off RTC reset
    TAY
    TXA                 ; bring into A the address from D
    AND #%00111111      ; keep only bits 6 LSBs, discard 2 MSBs
    ASL A               ; rotate address bits to the left
    ORA #%10000000      ; set MSB to one for DS1302 COMMAND BYTE (WRITE)
    JSR RTC_WR          ; write address to DS1302
    TYA                 ; start processing value
    JSR RTC_WR          ; write address to DS1302
    JSR RTC_RESET_ON    ; turn on RTC reset
    CLI
    PLP
    PLY
    PLX
    RET


;__RTC_READ_____________________________________________________
;
; read DATA FROM RTC REGISTER OR NVRAM
;
; input address in X
; output value in A
;
;_______________________________________________________________
RTC_READ:
    PHX
    PHP
    SEP #$30            ; 8 bit REGISTERS
    LONGA OFF
    LONGI OFF
    SEI
    JSR RTC_RESET_OFF   ; turn off RTC reset
    TXA
    AND #%00111111      ; keep only bits 6 LSBs, discard 2 MSBs
    ASL A               ; rotate address bits to the left
    ORA #%10000001      ; set MSB to one for DS1302 COMMAND BYTE (READ)
    JSR RTC_WR          ; write address to DS1302
    JSR RTC_RD          ; read value from DS1302 (value is in reg C)
    JSR RTC_RESET_ON    ; turn on RTC reset
    CLI
    PLP
    PLX
    RTS



; function RTC_WR
; input value in A

RTC_WR:
    PHX
    PHP
    SEP #$30            ; 8 bit REGISTERS
    LONGA OFF
    LONGI OFF
    LDX #$00

RTC_WR1:
    LSR A
    BCC RTC_WR2         ; LSB is a 0, handle it AT RTC_WR2
                        ; LSB is a 1, handle it below
                        ; setup RTC latch with RST and DATA high, SCLK low
    PHA
    JSR RTC_RESET_ON
    JSR RTC_DTA_ON
    JSR RTC_CLK_OFF
    JSR RTC_BIT_DELAY   ; let it settle a while
                        ; setup RTC with RST, DATA, and SCLK high
    JSR RTC_CLK_ON
    BRA RTC_WR3         ; exit loop

RTC_WR2:
    PHA
                        ; LSB is a 0, handle it below
                        ; setup RTC latch with RST high, SCLK and DATA low
    JSR RTC_RESET_ON
    JSR RTC_DTA_OFF
    JSR RTC_CLK_OFF
    JSR RTC_BIT_DELAY   ; let it settle a while
                        ; setup RTC with RST and SCLK high, DATA low
    JSR RTC_CLK_ON
RTC_WR3:
    JSR RTC_BIT_DELAY   ; let it settle a while
    PLA
    INX                 ; increment COUNTER
    CPX  #$08           ; is < $08
    BNE  RTC_WR1        ; No, do Loop again
    PLP
    PLX
    RTS                 ; Yes, end function and return


; function RTC_RD
; output value in A
RTC_RD:
    PHX
    PHY
    PHP
    SEP #$30            ; 8 bit REGISTERS
    LONGA OFF
    LONGI OFF
    LDX #$00
    LDY #$00

RTC_RD1:
                        ; setup RTC with RST and RD high, SCLK low
    JSR RTC_RESET_ON
    JSR RTC_CLK_OFF
    JSR RTC_BIT_DELAY   ; let it settle a while
    JSR RTC_GET_DTA     ; input from RTC latch
    CMP #$00
    BNE RTC_RD2         ; if LSB is a 1, handle it below
    TYA
    ClC
    ROR
    TAY
    BRA RTC_RD3
RTC_RD2:
    TYA
    SEC
    ROR
    TAY
RTC_RD3:
    JSR RTC_CLK_ON
    JSR RTC_BIT_DELAY   ; let it settle
    INX
    CPX #$08            ; is < $08 ?
    BNE RTC_RD1         ; No, do FOR loop again
    TYA
    PLP
    PLY
    PLX
    RTS                 ; Yes, end function and return.  Read RTC value is in C



RTC_RESET_ON:
    PHA
    lda via1rega
    ora #%01000000
    STA via1rega
    PLA
    RTS

RTC_RESET_OFF:
    PHA
    lda via1rega
    And #%10111111
    STA via1rega
    PLA
    RTS

RTC_GET_DTA:
    lda via1ddra
    AND #%11011111
    STA via1ddra
    lda via1rega
    AND #%00100000
    STA via1rega
    RTS

RTC_DTA_ON:
    PHA
    lda via1ddra
    ora #%00100000
    STA via1ddra
    lda via1rega
    ora #%00100000
    STA via1rega
    PLA
    RTS

RTC_DTA_OFF:
    PHA
    lda via1ddra
    ora #%00100000
    STA via1ddra
    lda via1rega
    AND #%11011111
    STA via1rega
    PLA
    RTS

RTC_CLK_ON:
    PHA
    lda via1pcr
    ora #%00001110
    STA via1pcr
    PLA
    RTS

RTC_CLK_OFF:
    PHA
    lda via1pcr
    ora #%00001100
    AND #%11111101
    STA via1pcr
    PLA
    RTS


RTC_BIT_DELAY:
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
    PHA
    PLA
    PHA
    PLA
    PHA
    PLA
    PHA
    PLA
    RTS
