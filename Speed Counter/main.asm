; CACULATOR SPEED EVERY 1S
; USING INT1 TO COUNT ENCODER
; USING TIMER 1 TO TIMING


ORG 0000H
LJMP INIT	
	
ORG 0003H			; INT0 			IE0
	
ORG 000BH			; TIMER 0		TF0
	
ORG 0013H			; INT 1			IE1
LJMP ISRINT1
ORG 001BH			; TIMER 1		TF1
LJMP ISRTIMER1	
ORG 0023H			; UART			RI/TI


ORG 0030H
	MAIN:
		ACALL  CACULATOR
		ACALL  DISPLAY
	
	
	
	LJMP MAIN
	
	
	
	
	;INIT FUNCTION *****************************************************
	INIT:
	MOV TMOD,#10H					; TIMER 1 MODE 1 16BIT
	MOV IE,#10001100B				; TIMER 1 INTERRUPT, INT 1
	MOV R0,#0						; FLAG INTERRUPT
	MOV R1,#0						; TIME COUNTER EVERY 50MS
	SETB TR1						; START TIMER 1
	SETB TF1						; START INTERRUPT TIMER
	SETB IT1						; START EXTERNAL INTERRUPT INT1 
	
	LJMP MAIN
	RET
	;===================================================================
	
	
	
	
	;ISR INT1 **********************************************************
	ISRINT1:
	INC R0
	RETI	
	;===================================================================
	
	; ISR TIMER 1 ******************************************************
	ISRTIMER1:
	MOV TH1,#3CH
	MOV TL1,#0AFH			; 50ms
	INC R1				; START WHEN R1 = 1
	;CPL P1.1
	RETI
	
	;===================================================================	

	; RESET ALL*********************************************************
	RESET:
	MOV R1,#0				; RESET EVERY 1S WHEN R1=20
	MOV R0,#0
	RET

	;===================================================================
	
	
	; CACULATOR FUNCTION ***********************************************
	CACULATOR:
	CJNE R1,#20,RETURN				; IF R1 != 20, WAIT FOR 1S
	MOV A,R0
	MOV B, #20
	DIV AB
	MOV R2,A						; R2 STORE SPEED
	MOV A, B
	MOV B,#10
	MUL AB							; A: LSB --- B: MSB
	ORL A,B
	MOV R3,A						; 
	ACALL RESET
	RETURN:
	
	RET
	;===================================================================
	
	; TACH SO **********************************************************
	TACHSO:
	
	MOV A,R2		
	MOV B,#10D
	DIV AB  
	MOV R5,B			; R5 CHUA PHAN DVI CUA SEC
	MOV B,#10
	DIV AB
	MOV R4,B
	MOV R3,A
	
	RET
	;===================================================================
	
	
	; DELAY ************************************************************
	DELAY: 	
    MOV R7,#170D
	LABEL2: DJNZ R7,LABEL2
    RET
	;===================================================================
	
	; DISPLAY **********************************************************
	
	DISPLAY:
	ACALL TACHSO
	SETB P1.4
	MOV P2,#0
	SETB P1.0							; DISPLAY LED 1
	ACALL DELAY
	CLR P1.0
	
	MOV P2,R3
	SETB P1.1							; DISPLAY LED 2
	ACALL DELAY
	CLR P1.1

	
	MOV P2,R4
	SETB P1.2							; DISPLAY LED 3
	ACALL DELAY
	CLR P1.2

	MOV P2,R5
	SETB P1.3							; DISPLAY LED 4
	ACALL DELAY
	CLR P1.3
	
	RET

	;===================================================================
	
	
	
END
	
	; **********************************************************

	;===================================================================
	
