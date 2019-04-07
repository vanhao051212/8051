ORG 0000H
LJMP INIT	
	
ORG 0003H			; INT0 			IE0
	
ORG 000BH			; TIMER 0		TF0
	
ORG 0013H			; INT 1			IE1
LJMP ISRINT1
ORG 001BH			; TIMER 1		TF1
	
ORG 0023H			; UART			RI/TI
LJMP ISRUART
	
	
ORG 0030H
	; MAIN FUNCTION *********************************************************************
	MAIN:
		
	CJNE R0,#1,MAIN 			; IF FLAG != 1 DO NOTHING 
	
	; JF FLAG == 1 DOING
	ACALL DOING
	;CPL P1.3
	MOV R0,#0					; RESET FLAG
	
	
	LJMP MAIN
	
	; -----------------------------------------------------------------------------------
	
	
	; DOING FUNCTION ********************************************************************
	DOING:
	MOV R2,#45
	TIME:
	MOV R3,#10
	HERE:	
	MOV R1,#5	
	LOOP_MIC:
	MOV TL0,#55
	SETB TR0					; START TIMER 0, TL0
	AGAIN: JNB TF0,AGAIN		; WAIT FOR TF0 = 1
	CLR TF0
	
	DJNZ R1, LOOP_MIC			; LOOP FOR 1000US
	; IF 1000US
	CPL P1.1					; BLINK MIC
	
	DJNZ R3, HERE				; LOOP 450 TIMES ; 
	DJNZ R2, TIME

	RET
		
	; -----------------------------------------------------------------------------------
	
	; INIT FUNCTION *********************************************************************
	INIT:
	CLR P1.1
	MOV R0,#0				; FLAG == 0 DO NOTHING
	MOV TMOD,#23H			;  TIMER 0 MODE 3, TIMER 1 SET BAUD 
	MOV IE,#84H 			; EA=1, IE
	MOV SCON , #50H
	MOV TH1,#-13			; SET BAUD
	SETB TR1
	SETB IT1				; INT 1 FALLING EDGE
	LJMP MAIN
	RET
	; ----------------------------------------------------------------------------------
	
	
	; INTERRUPT FUNCTION ****************************************************************
	ISRINT1:
	
	SETB TI					; START TRANSMITING UART
	MOV R0,#1				; ENABLE FLAG
	RETI
	; -----------------------------------------------------------------------------------
	
	; TRANSMIT UART *********************************************************************
	ISRUART:
	
	JB TI, TRUYEN			; IF TI = 1 THEN SEND
	RETI
	
	TRUYEN:
	MOV SBUF,#"H"
	ACALL DELAY
	MOV SBUF,#"A"
	ACALL DELAY
	MOV SBUF,#"O"
	ACALL DELAY
	
	RETI
	; -----------------------------------------------------------------------------------
	

	DELAY: 	
    MOV R7,#170D
	LABEL2: DJNZ R7,LABEL2
    RET
		
		
		
	
END



