; numeric constants and series
					; constants and series for LOG(n)
LAB_25A0
	.byte	$02			; counter
	.byte	$80,$19,$56,$62	; 0.59898
	.byte	$80,$76,$22,$F3	; 0.96147
	.byte	$82,$38,$AA,$40	; 2.88539

LAB_25AD
	.byte	$80,$35,$04,$F3	; 0.70711	1/root 2
LAB_25B1
	.byte	$81,$35,$04,$F3	; 1.41421	root 2
LAB_25B5
	.byte	$80,$80,$00,$00	; -0.5
LAB_25B9
	.byte	$80,$31,$72,$18	; 0.69315	LOG(2)

					; numeric PRINT constants
LAB_2947
	.byte	$91,$43,$4F,$F8	; 99999.9375 (max value with at least one decimal)
LAB_294B
	.byte	$94,$74,$23,$F7	; 999999.4375 (max value before scientific notation)
LAB_294F
	.byte	$94,$74,$24,$00	; 1000000

					; EXP(n) constants and series
LAB_2AFA
	.byte	$81,$38,$AA,$3B	; 1.4427	(1/LOG base 2 e)
LAB_2AFE
	.byte	$06			; counter
	.byte	$74,$63,$90,$8C	; 2.17023e-4
	.byte	$77,$23,$0C,$AB	; 0.00124
	.byte	$7A,$1E,$94,$00	; 0.00968
	.byte	$7C,$63,$42,$80	; 0.05548
	.byte	$7E,$75,$FE,$D0	; 0.24023
	.byte	$80,$31,$72,$15	; 0.69315
	.byte	$81,$00,$00,$00	; 1.00000

					; trigonometric constants and series
LAB_2C78
	.byte	$81,$49,$0F,$DB	; 1.570796371 (pi/2) as floating #
LAB_2C84
	.byte	$04			; counter
	.byte	$86,$1E,$D7,$FB	; 39.7109
	.byte	$87,$99,$26,$65	;-76.575
	.byte	$87,$23,$34,$58	; 81.6022
	.byte	$86,$A5,$5D,$E1	;-41.3417
LAB_2C7C
	.byte	$83,$49,$0F,$DB	; 6.28319 (2*pi) as floating #

LAB_2CC9
	.byte	$08			; counter
	.byte	$78,$3A,$C5,$37	; 0.00285
	.byte	$7B,$83,$A2,$5C	;-0.0160686
	.byte	$7C,$2E,$DD,$4D	; 0.0426915
	.byte	$7D,$99,$B0,$1E	;-0.0750429
	.byte	$7D,$59,$ED,$24	; 0.106409
	.byte	$7E,$91,$72,$00	;-0.142036
	.byte	$7E,$4C,$B9,$73	; 0.199926
	.byte	$7F,$AA,$AA,$53	;-0.333331

LAB_1D96	.EQU *+1			; $00,$00 used for undefined variables
LAB_259C
	.byte	$81,$00,$00,$00	; 1.000000, used for INC
LAB_2AFD
	.byte	$81,$80,$00,$00	; -1.00000, used for DEC. must be on the same page as +1.00

					; misc constants
LAB_1DF7
	.byte	$90			;-32768 (uses first three bytes from 0.5)
LAB_2A96
	.byte	$80,$00,$00,$00	; 0.5
LAB_2C80
	.byte	$7F,$00,$00,$00	; 0.25
LAB_26B5
	.byte	$84,$20,$00,$00	; 10.0000 divide by 10 constant

; This table is used in converting numbers to ASCII.

LAB_2A9A
LAB_2A9B .EQU LAB_2A9A+1
LAB_2A9C .EQU LAB_2A9B+1
	.byte	$FE,$79,$60		; -100000
	.byte	$00,$27,$10		; 10000
	.byte	$FF,$FC,$18		; -1000
	.byte	$00,$00,$64		; 100
	.byte	$FF,$FF,$F6		; -10
	.byte	$00,$00,$01		; 1
