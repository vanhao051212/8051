; DEFINE 
COL0 	EQU P1.0
COL1 	EQU P1.1
COL2 	EQU P1.2
COL3 	EQU P1.3
ROW 	EQU P2
COL 	EQU P1
	
BUFFER	 	EQU R0
FIRST_VALUE	EQU R1
LAST_VALUE	EQU R2
RESULT		EQU R3
FLAG		EQU R4		; WHEN FLAG = 0, STORE FISRT VALUE
TEMP		EQU R5	
ORG 000H
LJMP INIT	
ORG 0003H			; INT0 			IE0
	
ORG 000BH			; TIMER 0		TF0
	
ORG 0013H			; INT 1			IE1

ORG 001BH			; TIMER 1		TF1
	
ORG 0023H			; UART			RI/TI
	
ORG 100H
	MAIN:
	ACALL CHECK_KEYPAD
	LJMP MAIN
	
	; INTI FUNCTION **************************************************
	INIT:
	MOV TMOD,#20H			; TIMER MODE SET BAUDRATE
	MOV TH1,#0FDH			; BAUDRATE 9600
	;MOV IE,#90H				; ISR_UART
	MOV SCON,#50H			; ENABLE TX , RX
	SETB TR1				; START TIMER 1
	CLR TI
	MOV P2,#0FH
	MOV P1,#0FH
	MOV FIRST_VALUE,#0
	MOV LAST_VALUE,#0
	MOV RESULT, #0
	MOV FLAG,#0
	MOV TEMP,#0
	LJMP MAIN
	RET
	; ================================================================	
	
	; ISR UART *******************************************************
	
	SEND: 
	MOV SBUF, BUFFER
	HERE:JNB TI,HERE
	CLR TI
	RET
	; ================================================================	
	
	; KEYPAD FUNCTION ************************************************
	; 0E	0D		0B		07
	CHECK_KEYPAD:
	
	CHECK_ROW0:
	MOV ROW,#0EH
	MOV A,COL
	CJNE A,#0EH,CHECK8			; 7
	AAA:JNB COL0,AAA			; WAIT FOR COL0 = 1
	MOV TEMP,#7
	ACALL UPDATE_DATA
	MOV BUFFER,#"7"
	ACALL SEND
	CHECK8:
	CJNE A,#0DH,CHECK9			; 8
	BBB:JNB COL1,BBB			; WAIT FOR COL1 = 1 
	MOV TEMP,#8
	ACALL UPDATE_DATA
	MOV BUFFER,#"8"
	ACALL SEND
	CHECK9:
	CJNE A,#0BH,CHECK_DIV		; 9
	CCC:JNB COL2,CCC
	MOV TEMP,#9
	ACALL UPDATE_DATA
	MOV BUFFER,#"9"
	ACALL SEND
	CHECK_DIV:
	CJNE A,#07H,CHECK_ROW1
	DDD:JNB COL3,DDD
	MOV FLAG,#1					; ANNOUNCE THAT IS LAST VALUE
	MOV BUFFER,#"/"				;/
	ACALL SEND
	CHECK_ROW1:
	MOV ROW,#0DH
	MOV A,COL
	CJNE A,#0EH,CHECK5			; 4
	EEE:JNB COL0,EEE
	MOV TEMP,#4
	ACALL UPDATE_DATA
	MOV BUFFER,#"4"
	ACALL SEND
	CHECK5:
	CJNE A,#0DH,CHECK6			; 5
	FFF:JNB COL1,FFF
	MOV TEMP,#5
	ACALL UPDATE_DATA
	MOV BUFFER,#"5"
	ACALL SEND
	CHECK6:
	CJNE A,#0BH,CHECK_MUL		; 6
	GGG:JNB COL2,GGG
	MOV TEMP,#6
	ACALL UPDATE_DATA
	MOV BUFFER,#"6"
	ACALL SEND
	CHECK_MUL:
	CJNE A,#07H,CHECK_ROW2
	HHH:JNB COL3,HHH
	MOV FLAG,#1					; ANNOUNCE THAT IS LAST VALUE
	MOV BUFFER,#"*"				;*
	ACALL SEND
	CHECK_ROW2:
	MOV ROW,#0BH
	MOV A,COL
	CJNE A,#0EH,CHECK2			; 1
	III:JNB COL0,III
	MOV TEMP,#1
	ACALL UPDATE_DATA
	MOV BUFFER,#"1"
	ACALL SEND
	CHECK2:
	CJNE A,#0DH,CHECK3			; 2
	JJJ:JNB COL1,JJJ
	MOV TEMP,#2
	ACALL UPDATE_DATA
	MOV BUFFER,#"2"
	ACALL SEND
	CHECK3:
	CJNE A,#0BH,CHECK_SUB		; 3
	KKK:JNB COL2,KKK
	MOV TEMP,#3
	ACALL UPDATE_DATA
	MOV BUFFER,#"3"
	ACALL SEND
	CHECK_SUB:
	CJNE A,#07H,CHECK_ROW3
	LLL:JNB COL3,LLL
	MOV FLAG,#1					; ANNOUNCE THAT IS LAST VALUE
	MOV BUFFER,#"-"				;-
	ACALL SEND
	CHECK_ROW3:
	MOV ROW,#07H
	MOV A,COL
	CJNE A,#0EH,CHECK0			; ON
	MMM:JNB COL0,MMM
	ACALL RESET
	; DO STH	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CHECK0:
	CJNE A,#0DH,CHECK_EQUAL		; 0
	NNN:JNB COL1,NNN
	MOV TEMP,#0
	ACALL UPDATE_DATA
	MOV BUFFER,#"0"
	ACALL SEND
	CHECK_EQUAL:
	CJNE A,#0BH,CHECK_ADD		; =
	OOO: JNB COL2,OOO
	; DO STH	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ACALL CALCULATE
	CHECK_ADD:
	CJNE A,#07H,COUNTINUTE
	PPP:JNB COL3,PPP
	MOV BUFFER,#"+"				;+
	ACALL SEND
	COUNTINUTE:
	
	
	RET
	; ================================================================	

	; RESET FUNCTION *************************************************
	RESET:
	MOV FIRST_VALUE,#0
	MOV LAST_VALUE,#0
	MOV RESULT, #0
	MOV FLAG,#0
	MOV TEMP,#0
	RET
	; ================================================================	

	; UPDATE DATA FUNCTION *********************************************
	UPDATE_DATA:
	MOV A,FLAG
	JNZ LASTVALUE		; IF FLAG != 0
	
	MOV A,FIRST_VALUE
	ORL A,TEMP
	MOV FIRST_VALUE,A
	
	LASTVALUE:
	MOV A,LAST_VALUE
	ORL A,TEMP
	MOV LAST_VALUE,A
	RET
	; ================================================================	
	
	; CALCULATE FUNCTION *********************************************
	CALCULATE:
	MOV A,#0
	ORL A,FIRST_VALUE
	ORL A,LAST_VALUE
	MOV RESULT,A
	MOV BUFFER,#"1"
	ACALL SEND
	RET
	; ================================================================
END
	;*************************************************************
	; ================================================================