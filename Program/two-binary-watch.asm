	ORG 00H
	JMP MAIN

	ORG 0BH
	JMP Timer0_interrupt

Timer0_interrupt:
	CJNE R7,#0,reload_Timer0_1
	LCALL Add_second
	JNB 20H.0,reload_Timer0_2
	LCALL Add_minute
	JNB 20H.1,reload_Timer0_3
	LCALL Add_hour
	JNB 20H.2,reload_Timer0_4
	LCALL display_time
	MOV R7,#20
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	RETI
reload_Timer0_4:
	LCALL display_time
	MOV R7,#20
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	RETI
reload_Timer0_3:
	LCALL display_time
	MOV R7,#20
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	RETI
reload_Timer0_2:
	LCALL display_time
	MOV R7,#20
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	RETI
reload_Timer0_1:				   
	DEC R7
	;reload Timer0
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	RETI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name:Add_second
;function: second+1. If second=60, clear second and set second overflow flag 20H.0
Add_second:
	INC R0
	CJNE R0,#60,finish_add_second
	MOV R0,#0
	SETB 20H.0
finish_add_second:
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name:Add_minute
;function: minute+1. If minute=60, clear minute and set minute overflow flag 20H.1
Add_minute:
	INC R1
	CJNE R1,#60,finish_add_minute
	MOV R1,#0
	SETB 20H.1
finish_add_minute:
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name:Add_hour
;function:hour+1. If hour=24, clear hour and set hour overflow flag 20H.2
Add_hour:
	INC R2
	CJNE R2,#24,finish_add_hour
	MOV R2,#0
	SETB 20H.2
finish_add_hour:
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine name: display_time
;function: display time that stored in R2(hour):R1(minute):R0(second)
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

MAIN:
	;use R0 to store second
	MOV R0,#0
	;use R1 to store minute
	MOV R1,#0
	;use R2 to store hour
	MOV R2,#0
	;set Timer0 16 bit
	ANL TMOD,#11110001B
	ORL TMOD,#00000001B
	;set Timer0 50000us
	MOV TH0,#HIGH (65536-50000)
	MOV TL0,#LOW (65536-50000)
	SETB TR0
	;use R7 to count time
	MOV R7,#20
	;set interrupt
	SETB ET0
	SETB EA
	;display initial time
	LCALL display_time
	JMP $
	END