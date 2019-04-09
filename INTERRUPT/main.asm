
; USING P2 TO DISPLAY NUMBER
; USING P2 TO CONTROL LED & DP PIN




ORG 0000H
LJMP INIT

ORG 0003H						; START INT 0
LJMP ISRINT0	

ORG 0013H						; START INT 1
LJMP ISRINT1


ORG 30H
	

	MAIN:
		
	ACALL TIMING
		
		
	JMP MAIN
	
	; TIMING ****************************************************************************
	TIMING:
	
	LOOP_SEC:
	LOOP_SEC1:
	ACALL CHECKBUTTON
	MOV A, R1
	ADD A, 10H
	MOV R1, A
	MOV 10H,#0
	ACALL DISPLAY					; DISPLAY LED
	MOV A,09H
	CJNE A,#0,LOOP_SEC1
	
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
	ACALL INCSEC
	;MOV A,R1
	;ADDC A,#1						
	;MOV R1,A						; SEC ++
	MOV R2,#0						; RESET %SEC
	CJNE R1,#100, LOOP_SEC			; LOOP UBTIL SEC =100
	; IF SEC = 100	RESET ALL
	ACALL RST
	
	MOV TH1,#0D8H
	MOV TL1,#0EFH
	
	RET
	;----------------------------------------------------------------------------------
	
	;INIT *****************************************************************************
	
	INIT:
	
	MOV IE,#85H			; ENABLE INT1, INT0
	MOV P1,#0			
	MOV P2,#0			
	SETB P1.6
	SETB P1.7
	MOV TMOD,#10H		; TIMER 1 MODE 1
	SETB IT0
	SETB IT1
	MOV 10H,#0			; FLAG FOR INC OR DEC SEC
	MOV 09H,#0			; FLAG FOR PAUSE/RESUME
	RST:
	MOV R1,#00 			; STORE SEC
	MOV R2,#00			; STORE %SEC
	JMP MAIN
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

	;MOV P1,#0
	
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
	
	
	; INT 0 / PAUSE/RESUME ***************************************************************
	ISRINT0:
	MOV A, 09H
	XRL A,#1
	MOV 09H,A
	RETI
	;-------------------------------------------------------------------------------------
	
	; INT1  /RESET ***********************************************************************
	ISRINT1:
	MOV R1,#00 			; STORE SEC
	MOV R2,#00			; STORE %SEC	
	RETI
	
	;-------------------------------------------------------------------------------------
	
	; CHECK BUTTON ***********************************************************************
	CHECKBUTTON:
	JNB P1.6, INCSEC
	JNB	P1.7, DECSEC
	RET
	
	;-------------------------------------------------------------------------------------
	
	; INC SEC ****************************************************************************
	INCSEC:
	JNB P1.6, INCSEC
	MOV A,10H
	ADD A,#1						
	MOV 10H,A
	RET
		
	;-------------------------------------------------------------------------------------
	
	; DEC SEC ****************************************************************************
	DECSEC:
	JNB	P1.7, DECSEC
	MOV A,10H
	CLR C
	SUBB A,#1
	MOV 10H,A
	RET
	
	;-------------------------------------------------------------------------------------








END
	
	
	
	
	
	
	
	