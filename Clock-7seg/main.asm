
; USING P1 TO DISPLAY MIN
; USING P2 TO DISPLAY HOUR


ORG 00H


MOV P1,#0
MOV P2,#0
MOV TMOD,#10H	; ENABLE TIMER 1 MODE 1
MOV R1,#12D 	; STORE HOUR
MOV R2,#59D 	; STORE MIN
MOV 08H, #0 	; R1 IN BANK 2 STORE SEC

LJMP MAIN

ORG 30H
	
	MAIN:
	LOOP_DAY:
	LOOP_HOUR:
	LOOP_MIN:
	MOV R7,#17D 	; LOOP TIMES FOR 1SEC
		
	; TACH SO RA HANG CHUC VA DVI -------------------------------------------------------
	MOV A,R1		
	MOV B,#10D
	DIV AB   
	MOV R3,A
	MOV R4,B		; R3 CHUA PHAN THAP PHAN CUA PHUT, R4 CHUA PHAN DVI CUA PHUT
	
	MOV A,R2		
	MOV B,#10D
	DIV AB	; 
	MOV R5,A
	MOV R6,B		;R5                           GIO, R6                    GIO
	;-------------------------------------------------------------------------------------
	
	; GOM LAI VA HIEN THI RA TREN PORT ---------------------------------------------------
	MOV A,R3
	MOV B,#4D
	A1:
	RL A
	DJNZ B, A1		; R3<<4
	ORL A,R4
	MOV R3,A
	MOV P2,R3 		; HIEN THI RA P2

	MOV A,R5
	MOV B,#4D
	A2:
	RL A
	DJNZ B,A2		; R5<<4
	ORL A,R6
	MOV R5,A
	MOV P1,R5		; HIEN THI RA P1
	;--------------------------------------------------------------------------------------
	
	; BAT DAU DEM THOI GIAN ---------------------------------------------------------------
	
	MOV TH1,#3CH
	MOV TL1,#0AFH
	
	SETB TR1		; START TIMER 1
	
	AGAIN: JNB TF1,AGAIN ; WAIT FOR TF1 = 1
	
	CLR TF1 
	
	MOV TH1,#3CH
	MOV TL1,#0AFH
	DJNZ R7, AGAIN	; LOOP FOR 1SEC
	INC 08H 		; SEC++
	MOV A,08H
	CJNE A,#60, LOOP_MIN ; LOOP UNTIL SEC = 60
	
	; IF SEC =60 RESET SEC, INC MIN
	MOV 08H,#0 		; RESET SEC
	MOV A,R2
	ADDC A,#1 		; INC MIN
	MOV R2,A
	CJNE R2,#60, LOOP_HOUR ; LOOP UNTIL MIN = 60
	; IF MIN = 60  RESET MIN INC HOUR
	MOV R2,#0 		; RESET MIN
	MOV A,R1
	ADDC A,#1 		; INC HOUR
	MOV R1,A
	CJNE R1,#24, LOOP_DAY
	; IF HOUR =24 RESET HOUR
	MOV R1,#0
	;-------------------------------------------------------------------------------------
	JMP MAIN
	
END
	
	
	
	
	
	
	
	