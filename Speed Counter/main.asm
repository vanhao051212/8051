;; CACULATOR SPEED EVERY 3S
;; USING INT1 TO COUNT ENCODER
;; USING TIMER 1 TO TIMING


;ORG 0000H
;LJMP INIT	
	
;ORG 0003H			; INT0 			IE0
	
;ORG 000BH			; TIMER 0		TF0
	
;ORG 0013H			; INT 1			IE1
;LJMP ISRINT1
;ORG 001BH			; TIMER 1		TF1
;LJMP ISRTIMER1	
;ORG 0023H			; UART			RI/TI


;ORG 0030H
	;MAIN:
	
	
	
	
	;LJMP MAIN
	
	
	
	
	;;INIT FUNCTION *****************************************************
	;INIT:
	;MOV TMOD,#10H					; TIMER 1 MODE 1 16BIT
	;MOV IE,#10001100B				; TIMER 1 INTERRUPT, INT 1
	;MOV R0,#0						; FLAG INTERRUPT
	;MOV R1,#0						; TIME COUNTER EVERY 50MS
	;SETB TR1						; START TIMER 1
	;SETB TF1						; START INTERRUPT TIMER
	
	;LJMP MAIN
	;RET
	;;===================================================================
	
	
	
	
	;;ISR INT1 **********************************************************
	;ISRINT1:
	;INC R0
	;RETI	
	;;===================================================================
	
	;; ISR TIMER 1 ******************************************************
	;ISRTIMER1:
	;MOV TH1,#3C
	;MOV TL1,0AFH
	;INC R1
	;RETI
	
	;;===================================================================	

	;; RESET ALL*********************************************************
	;RESET:
	;MOV R1,#0
	;MOV R0,#0
	;RET

	;;===================================================================
	
	
	;; CACULATOR FUNCTION ***********************************************
	;CACULATOR:
	

	;;===================================================================
	
	
	
	
	
;END
	
	;; **********************************************************

	;;===================================================================
	
RS EQU P1.4
EN EQU P1.5
PORT EQU P1
U EQU 30H
L EQU 31H
ORG 000H

MOV DPTR,#INIT_COMMANDS
ACALL LCD_CMD
MOV DPTR,#LINE1
ACALL LCD_CMD
MOV DPTR,#TEXT1
ACALL LCD_DISP
MOV DPTR,#LINE2
ACALL LCD_CMD
MOV DPTR,#TEXT2
ACALL LCD_DISP
SJMP $


SPLITER: MOV L,A 
ANL L,#00FH 
SWAP A 
ANL A,#00FH 
MOV U,A 
RET

MOVE: ANL PORT,#0F0H 
ORL PORT,A
SETB EN 
ACALL DELAY 
CLR EN 
ACALL DELAY 
RET


LCD_CMD: CLR A
MOVC A,@A+DPTR
JZ EXIT2
INC DPTR 
CLR RS
ACALL SPLITER
MOV A,U
ACALL MOVE
MOV A,L
ACALL MOVE
SJMP LCD_CMD 
EXIT2: RET 
 
 
 
LCD_DATA: SETB RS
ACALL SPLITER
MOV A,U
ACALL MOVE
MOV A,L
ACALL MOVE 
RET

LCD_DISP: CLR A
MOVC A,@A+DPTR
JZ EXIT1
INC DPTR 
ACALL LCD_DATA 
SJMP LCD_DISP 
EXIT1: RET 
 
 


DELAY: MOV R7, #10H
L2: MOV R6,#0FH
L1: DJNZ R6, L1
DJNZ R7, L2
RET

INIT_COMMANDS: DB 20H,28H,0CH,01H,06H,80H,0 
LINE1: DB 01H,06H,06H,80H,0
LINE2: DB 0C0H,0 
CLEAR: DB 01H,0

TEXT1: DB " CircuitsToday ",0 
TEXT2: DB "4bit Using 1Port",0

END