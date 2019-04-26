; TROUBLE IN UPDAATE DATA FUNCTION ****************


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

FLAG		EQU R3		; WHEN FLAG = 0, STORE FISRT VALUE
TEMP		EQU R4	
RESULT_1	EQU R5
RESULT_2	EQU R6
RESULT_3	EQU R7
STT			EQU 08H
CAL			EQU R7		; 1:+   2:-    3:*    4:/
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
	MOV FLAG,#0
	MOV TEMP,#0
	MOV STT,#1
	LJMP MAIN
	RET
	; ================================================================	
	
	; UART FUNCTION **************************************************
	
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
	JMP COUNTINUTE
	CHECK8:
	CJNE A,#0DH,CHECK9			; 8
	BBB:JNB COL1,BBB			; WAIT FOR COL1 = 1 
	MOV TEMP,#8
	ACALL UPDATE_DATA
	MOV BUFFER,#"8"
	ACALL SEND
	JMP COUNTINUTE
	CHECK9:
	CJNE A,#0BH,CHECK_DIV		; 9
	CCC:JNB COL2,CCC
	MOV TEMP,#9
	ACALL UPDATE_DATA
	MOV BUFFER,#"9"
	ACALL SEND
	JMP COUNTINUTE
	CHECK_DIV:
	CJNE A,#07H,CHECK_ROW1
	DDD:JNB COL3,DDD
	MOV FLAG,#1					; ANNOUNCE THAT IS LAST VALUE
	MOV STT,#1
	MOV CAL,#4
	MOV BUFFER,#"/"				;/
	ACALL SEND
	JMP COUNTINUTE
	CHECK_ROW1:
	MOV ROW,#0DH
	MOV A,COL
	CJNE A,#0EH,CHECK5			; 4
	EEE:JNB COL0,EEE
	MOV TEMP,#4
	ACALL UPDATE_DATA
	MOV BUFFER,#"4"
	ACALL SEND
	JMP COUNTINUTE
	CHECK5:
	CJNE A,#0DH,CHECK6			; 5
	FFF:JNB COL1,FFF
	MOV TEMP,#5
	ACALL UPDATE_DATA
	MOV BUFFER,#"5"
	ACALL SEND
	JMP COUNTINUTE
	CHECK6:
	CJNE A,#0BH,CHECK_MUL		; 6
	GGG:JNB COL2,GGG
	MOV TEMP,#6
	ACALL UPDATE_DATA
	MOV BUFFER,#"6"
	ACALL SEND
	JMP COUNTINUTE
	CHECK_MUL:
	CJNE A,#07H,CHECK_ROW2
	HHH:JNB COL3,HHH
	MOV FLAG,#1					; ANNOUNCE THAT IS LAST VALUE
	MOV STT,#1
	MOV CAL,#3
	MOV BUFFER,#"*"				;*
	ACALL SEND
	JMP COUNTINUTE
	CHECK_ROW2:
	MOV ROW,#0BH
	MOV A,COL
	CJNE A,#0EH,CHECK2			; 1
	III:JNB COL0,III
	MOV TEMP,#1
	ACALL UPDATE_DATA
	MOV BUFFER,#"1"
	ACALL SEND
	JMP COUNTINUTE
	CHECK2:
	CJNE A,#0DH,CHECK3			; 2
	JJJ:JNB COL1,JJJ
	MOV TEMP,#2
	ACALL UPDATE_DATA
	MOV BUFFER,#"2"
	ACALL SEND
	JMP COUNTINUTE
	CHECK3:
	CJNE A,#0BH,CHECK_SUB		; 3
	KKK:JNB COL2,KKK
	MOV TEMP,#3
	ACALL UPDATE_DATA
	MOV BUFFER,#"3"
	ACALL SEND
	JMP COUNTINUTE
	CHECK_SUB:
	CJNE A,#07H,CHECK_ROW3
	LLL:JNB COL3,LLL
	MOV FLAG,#1					; ANNOUNCE THAT IS LAST VALUE
	MOV STT,#1
	MOV CAL,#2
	MOV BUFFER,#"-"				;-
	ACALL SEND
	JMP COUNTINUTE
	CHECK_ROW3:
	MOV ROW,#07H
	MOV A,COL
	CJNE A,#0EH,CHECK0			; ON
	MMM:JNB COL0,MMM
	ACALL RESET
	ACALL LCD_CLEAR
	; DO STH	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JMP COUNTINUTE
	CHECK0:
	CJNE A,#0DH,CHECK_EQUAL		; 0
	NNN:JNB COL1,NNN
	MOV TEMP,#0
	ACALL UPDATE_DATA
	MOV BUFFER,#"0"
	ACALL SEND
	JMP COUNTINUTE
	CHECK_EQUAL:
	CJNE A,#0BH,CHECK_ADD		; =
	OOO: JNB COL2,OOO
	MOV BUFFER,#"="
	ACALL SEND	
	; DO STH	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ACALL CALCULATE
	ACALL DISPLAY
	;ACALL RESET
	LJMP COUNTINUTE
	CHECK_ADD:
	CJNE A,#07H,COUNTINUTE
	PPP:JNB COL3,PPP
	MOV FLAG,#1
	MOV STT,#1
	MOV CAL,#1
	MOV BUFFER,#"+"				;+
	ACALL SEND
	
	COUNTINUTE:
	
	
	RET
	; ================================================================	

	; RESET FUNCTION *************************************************
	RESET:
	MOV FIRST_VALUE,#0
	MOV LAST_VALUE,#0
	MOV FLAG,#0
	MOV TEMP,#0
	MOV RESULT_1,#0
	MOV RESULT_2,#0
	MOV RESULT_3,#0
	MOV STT,#1
	RET
	; ================================================================	

	; UPDATE DATA FUNCTION *********************************************
	UPDATE_DATA:
	MOV A,FLAG
	CJNE A,#0, LASTVALUE
		
	MOV A,STT	
	CJNE A,#1, STT2
	MOV A,TEMP
	MOV FIRST_VALUE,A
	ACALL RETURN 
	STT2:
	MOV B,#10
	MOV A,FIRST_VALUE
	MUL AB					; INDEX*10 + TEMP
	ORL A,B
	ADD A,TEMP
	MOV FIRST_VALUE,A
	RET
	
	LASTVALUE:
	MOV A,STT	
	CJNE A,#1, STT22
	MOV A,TEMP
	MOV LAST_VALUE,A
	ACALL RETURN 
	STT22:
	MOV B,#10
	MOV A,LAST_VALUE
	MUL AB					; INDEX*10 + TEMP
	ORL A,B
	ADD A,TEMP
	MOV LAST_VALUE,A	

	RETURN:
	
	RET
	; ================================================================	
	
	; CALCULATE FUNCTION *********************************************
	CALCULATE:
	MOV A,CAL
	CJNE A,#0,A_ADD_B
	MOV A,FIRST_VALUE
	JMP DO
	A_ADD_B:
	CJNE A,#1,SUB
	MOV A,#0
	ADD A,FIRST_VALUE
	ADD A,LAST_VALUE
	JMP DO
	SUB:
	CJNE A,#2,MULT
	MOV A,FIRST_VALUE
	SUBB A,LAST_VALUE
	JMP DO
	MULT:
	CJNE A,#3,DIVIDE
	MOV A,FIRST_VALUE
	MOV B,LAST_VALUE
	MUL AB
	ORL A,B
	JMP DO
	DIVIDE:
	MOV A,FIRST_VALUE
	MOV B,LAST_VALUE
	DIV AB
	JMP DO
	
	DO:
	MOV B,#10D
	DIV AB  
	MOV RESULT_1,B			
	MOV B,#10
	DIV AB
	MOV RESULT_2,B
	MOV RESULT_3,A
	RET
	; ================================================================

	
	; DISPLAY LCD ****************************************************
	DISPLAY:
	MOV A,RESULT_3
	MOV TEMP,A
	ACALL CONVERT
	MOV A,TEMP
	MOV BUFFER,A
	ACALL SEND
	
	MOV A,RESULT_2
	MOV TEMP,A
	ACALL CONVERT
	MOV A,TEMP
	MOV BUFFER,A
	ACALL SEND	
	
	MOV A,RESULT_1
	MOV TEMP,A
	ACALL CONVERT
	MOV A,TEMP
	MOV BUFFER,A
	ACALL SEND

	RET
	; ================================================================	

	; CONVERT TO CHAR ************************************************
	CONVERT:
	CJNE TEMP,#0,KT1
	MOV TEMP,#"0"
	KT1:
	CJNE TEMP,#1,KT2
	MOV TEMP,#"1"
	KT2:
	CJNE TEMP,#2,KT3
	MOV TEMP,#"2"
	KT3:
	CJNE TEMP,#3,KT4
	MOV TEMP,#"3"
	KT4:
	CJNE TEMP,#4,KT5
	MOV TEMP,#"4"
	KT5:
	CJNE TEMP,#5,KT6
	MOV TEMP,#"5"
	KT6:
	CJNE TEMP,#6,KT7
	MOV TEMP,#"6"
	KT7:
	CJNE TEMP,#7,KT8
	MOV TEMP,#"7"
	KT8:
	CJNE TEMP,#8,KT9
	MOV TEMP,#"8"
	KT9:
	CJNE TEMP,#9,RETURN_1
	MOV TEMP,#"9"
	RETURN_1:
	RET
	; ================================================================

	; CLEAR LCD FUNCTION *********************************************
	LCD_CLEAR:
	MOV BUFFER,#0FEH
	ACALL SEND
	MOV BUFFER,#1
	ACALL SEND
	RET
	; ================================================================
END
	;*************************************************************
	; ================================================================