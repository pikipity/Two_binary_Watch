	ORG 00H
	JMP MAIN

	ORG 03H
	JMP Setting_mode

	ORG 0BH
	JMP Timer0_interrupt

	ORG 13H
	JMP Increase_time

	ORG 23H
	JMP UART

Timer0_interrupt:
	CJNE R7,#0,reload_Timer0_1;2us
	LCALL Add_second;2us
	JNB 20H.0,reload_Timer0_2;2us
	LCALL Add_minute;2us
	JNB 20H.1,reload_Timer0_3;2us
	LCALL Add_hour;2us
	JNB 20H.2,reload_Timer0_4;2us
	MOV R7,#20;2us
	MOV TH0,#HIGH (65536-50000+57);2us
	MOV TL0,#LOW (65536-50000+57);2us
	LCALL display_time;11us
	MOV 20H,#0;2us
	RETI;2us
reload_Timer0_4:
	MOV R7,#20;2us
	MOV TH0,#HIGH (65536-50000+54);2us
	MOV TL0,#LOW (65536-50000+54);2us
	LCALL display_time;11us
	MOV 20H,#0;2us
	RETI;2us
reload_Timer0_3:
	MOV R7,#20;2us
	MOV TH0,#HIGH (65536-50000+42);2us
	MOV TL0,#LOW (65536-50000+42);2us
	LCALL display_time;11us
	MOV 20H,#0;2us
	RETI;2us
reload_Timer0_2:
	MOV R7,#20;2us
	MOV TH0,#HIGH (65536-50000+30);2us
	MOV TL0,#LOW (65536-50000+30);2us
	LCALL display_time;11us
	MOV 20H,#0;2us
	RETI;2us
reload_Timer0_1:				   
	DEC R7;1us
	;reload Timer0
	MOV TH0,#HIGH (65536-50000+20);2us
	MOV TL0,#LOW (65536-50000+20);2us
	RETI;2us

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name:Add_second
;function: second+1. If second=60, clear second and set second overflow flag 20H.0
;total: 8us
Add_second:
	INC R0;1us
	CJNE R0,#60,finish_add_second;2us
	MOV R0,#0;2us
	SETB 20H.0;1us
finish_add_second:
	RET;2us
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name:Add_minute
;function: minute+1. If minute=60, clear minute and set minute overflow flag 20H.1
;total: 8us
Add_minute:
	INC R1;1us
	CJNE R1,#60,finish_add_minute;2us
	MOV R1,#0;2us
	SETB 20H.1;1us
finish_add_minute:
	RET;2us
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name:Add_hour
;function:hour+1. If hour=24, clear hour and set hour overflow flag 20H.2
;total: 8us
Add_hour:
	INC R2;1us
	CJNE R2,#24,finish_add_hour;2us
	MOV R2,#0;2us
	SETB 20H.2;1us
finish_add_hour:
	RET;2us
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name: display_time
;function: display time that stored in R2(hour):R1(minute):R0(second)
;total: 13us (include LCALL)
display_time:
	MOV A,R2
	CPL A
	MOV P0,A
	MOV A,R1
	CPL A
	MOV P2,A
	MOV A,R0
	CPL A
	MOV P1,A
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Setting_mode:
	INC R6
	CJNE R6,#1,begin_setting_mode
	CLR TR0
begin_setting_mode:
	CJNE R6,#4,finish_INT0
	MOV R6,#0
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	MOV 20H,#0
	SETB TR0
finish_INT0:
	RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Increase_time:
	CJNE R6,#0,determine_R6_1
	RETI
determine_R6_1:
	CJNE R6,#1,determine_R6_2
	LCALL Add_hour
	LCALL display_time
	RETI
determine_R6_2:
	CJNE R6,#2,determine_R6_3
	LCALL Add_minute
	LCALL display_time
	RETI
determine_R6_3:
	LCALL Add_second
	LCALL display_time
	RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name: delay_1ms
;function: delay 1ms (include LCALL)
Delay_1ms:
	PUSH Acc
	MOV A,#198
L1: NOP
	NOP
	NOP
	DJNZ Acc,L1
	POP Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name: delay_01s
;function: delay 0.1s (include LCALL)
Delay_01s:
	PUSH B
	MOV B,#99
L2: LCALL Delay_1ms
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DJNZ B,L2
	POP B
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name: ASCII2binary
;function: convert ASCII to binary
;input:    19H:18H
;output:   17H
ASCII2binary:
	PUSH Acc
	PUSH B
	;
	MOV A,19H
	ANL A,#00001111B
	MOV B,#10
	MUL AB
	MOV 19H,A
	;
	MOV A,18H
	ANL A,#00001111B
	;
	MOV B,19H
	ADD A,B
	MOV 17H,A
	;
	POP B
	POP Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UART:
	JB TI,UART_finish
	CLR RI
	;
	CJNE R5,#0,determine_R5_1
	CLR TR0
	INC R5
determine_R5_1:
	CJNE R5,#1,determine_R5_2
	INC R5
	MOV A,SBUF
	MOV 1FH,A
	JMP UART_finish
determine_R5_2:
	CJNE R5,#2,determine_R5_3
	INC R5
	MOV A,SBUF
	MOV 1EH,A
	;
	MOV A,1FH
	MOV 19H,A
	MOV A,1EH
	MOV 18H,A
	LCALL ASCII2binary
	MOV R2,17H
	;
	JMP UART_finish
determine_R5_3:
	CJNE R5,#3,determine_R5_4
	INC R5
	MOV A,SBUF
	MOV 1DH,A
	JMP UART_finish
determine_R5_4:
	CJNE R5,#4,determine_R5_5
	INC R5
	MOV A,SBUF
	MOV 1CH,A
	;
	MOV A,1DH
	MOV 19H,A
	MOV A,1CH
	MOV 18H,A
	LCALL ASCII2binary
	MOV R1,17H
	;
	JMP UART_finish
determine_R5_5:
	CJNE R5,#5,determine_R5_6
	INC R5
	MOV A,SBUF
	MOV 1BH,A
	JMP UART_finish
determine_R5_6:
	MOV R5,#0
	MOV A,SBUF
	MOV 1AH,A
	;
	MOV A,1BH
	MOV 19H,A
	MOV A,1AH
	MOV 18H,A
	LCALL ASCII2binary
	MOV R0,17H
	;
begin_time:
	MOV R7,#20
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	SETB TR0	
UART_finish:
	CLR TI
	RETI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	


MAIN:
	;use R5 to conut number of receiving from UART
	MOV R5,#0
	;use R6 to count number of INT0
	MOV R6,#0
	;use R0 to store second
	MOV R0,#0
	;use R1 to store minute
	MOV R1,#0
	;use R2 to store hour
	MOV R2,#0
	;set serial port
	CLR SM0
	SETB SM1
	CLR SM2
	SETB REN
	ANL PCON,#01111111B
	;set bound rate
	MOV TMOD,#00100001B
	MOV TH1,#0F3H
	SETB TR1
	SETB ES
	;set INT0 and INT1
	SETB EX0
	SETB IT0
	SETB EX1
	SETB IT1
	;set Timer0 50000us
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	SETB TR0
	SETB PS
	;use R7 to count time
	MOV R7,#20
	;set interrupt
	SETB ET0
	SETB EA
	;display initial time
	LCALL display_time
shine_display:
	CJNE R6,#0,determine_R6_1_shine
	LCALL display_time
	JMP shine_display
determine_R6_1_shine:
	CJNE R6,#1,determine_R6_2_shine
	LCALL delay_01s
	LCALL display_time
	LCALL delay_01s
	MOV P0,#0FFH
	JMP shine_display
determine_R6_2_shine:
	CJNE R6,#2,determine_R6_3_shine
	LCALL delay_01s
	LCALL display_time
	LCALL delay_01s
	MOV P2,#0FFH
	JMP shine_display
determine_R6_3_shine:
	LCALL delay_01s
	LCALL display_time
	LCALL delay_01s
	MOV P1,#0FFH
	JMP shine_display
	END
