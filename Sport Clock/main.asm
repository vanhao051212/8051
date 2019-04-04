
; USING P2 TO DISPLAY NUMBER
; USING P2 TO CONTROL LED & DP PIN




ORG 00H
ACALL INTI

	




LJMP MAIN

ORG 30H
	
	MAIN:
		ACALL TIMING
		
		
	JMP MAIN
	
	; TIMING ****************************************************************************
	TIMING:
	
	LOOP_SEC:
	LOOP_SEC1:
	ACALL DISPLAY					; DISPLAY LED
	
	MOV TH1,#0D8H
	MOV TL1,#0EFH
	SETB TR1						; START TIMER 1
	
	AGAIN: JNB TF1,AGAIN 			; WAIT FOR TF1 = 1
	CLR TF1 
	
	
	
	MOV A,R2
	ADDC A,#1
	MOV R2,A						; %SEC ++	
	
	CJNE R2,#100, LOOP_SEC1			; LOOP UNTIL %SEC = 100
	
	; IF %SEC = 100, RESET %SEC, SEC ++
	
	MOV A,R1
	ADDC A,#1						
	MOV R1,A						; SEC ++
	MOV R2,#0						; RESET %SEC
	CJNE R1,#100, LOOP_SEC			; LOOP UBTIL SEC =100
	; IF SEC = 100	RESET ALL
	ACALL RST
	
	MOV TH1,#0D8H
	MOV TL1,#0EFH
	
	RET
	;----------------------------------------------------------------------------------
	
	;INIT *****************************************************************************
	
	INTI:
	;MOV IE,#85H			; ENABLE INT1, INT0
	MOV P1,#0			
	MOV P2,#0			
	MOV TMOD,#10H		; TIMER 1 MODE 1
	;ACALL TIMING
	RST:
	MOV R1,#00 			; STORE SEC
	MOV R2,#00			; STORE %SEC
	RET
	;----------------------------------------------------------------------------------
	
	
	; DELAY ****************************************************************************
	DELAY: 	
    MOV R7,#170D
	LABEL2: DJNZ R7,LABEL2
    RET
	;-----------------------------------------------------------------------------------
	
	; DISPLAY LED ***********************************************************************
	
	DISPLAY:
	ACALL TACHSO

	MOV P1,#0
	
	SETB P1.4
	MOV P2,R3
	SETB P1.0							; DISPLAY LED 1
	ACALL DELAY
	CLR P1.0
	
	MOV P2,R4
	SETB P1.1							; DISPLAY LED 2
	ACALL DELAY
	CLR P1.1

	SETB P1.1
	CLR P1.4							; DISPLAY DP
	ACALL DELAY
	CLR P1.1
	SETB P1.4
	
	MOV P2,R5
	SETB P1.2							; DISPLAY LED 3
	ACALL DELAY
	CLR P1.2

	MOV P2,R6
	SETB P1.3							; DISPLAY LED 4
	ACALL DELAY
	CLR P1.3
	
	RET
	;--------------------------------------------------------------------------------------
	
	; TACH SO RA HANG CHUC VA DVI ********************************************************
	TACHSO:
	
	MOV A,R1		
	MOV B,#10D
	DIV AB   
	MOV R3,A
	MOV R4,B		; R3 CHUA PHAN THAP PHAN CUA SEC, R4 CHUA PHAN DVI CUA SEC
	
	MOV A,R2		
	MOV B,#10D
	DIV AB	; 
	MOV R5,A
	MOV R6,B		;R5                          SEC, R6                 %SEC
	RET
	;-------------------------------------------------------------------------------------
	
	
END
	
	
	
	
	
	
	
	