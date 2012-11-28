#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global	OP_ADC_IX
.global	OP_ADC_ZP
.global	OP_ADC_IM
.global	OP_ADC_AB
.global	OP_ADC_IY
.global	OP_ADC_ZPX
.global	OP_ADC_ABY
.global	OP_ADC_ABX


;*****************************************************************************
;
; ADC - Add with Carry
;
; A,Z,C,N = A+M+C
;
; This instruction adds the contents of a memory location to the accumulator 
; together with the carry bit. If overflow occurs the carry bit is set, this 
; enables multiple byte addition to be performed.
;
; NOTE: These instructions are affected by the Decimal Mode Flag
;
; C	Carry Flag			Set if overflow in bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		Set if sign bit is incorrect
; N	Negative Flag		Set if bit 7 set
;

OP_ADC_IM:				; *** $69 - ADC IMMEDIATE 
	HandleIMMEDIATE
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_IM_DECIMAL
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, ZL
	UpdateNCZVjmpLoop

ADC_IM_DECIMAL:
	jmp		ADC_DECIMAL




OP_ADC_ZP:				; *** $65 - ADC ZEROPAGE
						; TODO : Handle Decimal Mode
	HandleZEROPAGE
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ZP_DECIMAL

	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_ZP_DECIMAL:  // TODO
	




OP_ADC_ZPX:				; *** $75 - ADC ZEROPAGE,X
						; TODO : Handle Decimal Mode
	HandleZEROPAGE_X
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ZP_X_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_ZP_X_DECIMAL: //TODO	
	ld		ZL,Z
	jmp		ADC_DECIMAL



OP_ADC_AB:				; *** $6D - ABSOLUTE
						; TODO : Handle Decimal Mode
	HandleABSOLUTE
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_AB_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_AB_DECIMAL: 	// TODO

OP_ADC_ABX:				; *** $7D - ADC ABSOLUTE,X
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_X
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ABX_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	
ADC_ABX_DECIMAL:  //TODO



OP_ADC_ABY:				; *** $79 - ADC ABSOLUTE,Y
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_Y
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ABY_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_ABY_DECIMAL:	// TODO


OP_ADC_IX:				; *** $61 - ADC (INDIRECT,X)
						; TODO : Handle Decimal Mode
	HandleINDIRECT_X
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_IX_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_IX_DECIMAL: //TODO	

OP_ADC_IY:				; *** $71 - ADC (INDIRECT),Y
						; TODO : Handle Decimal Mode
	HandleINDIRECT_Y
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_IY_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	
ADC_IY_DECIMAL: //TODO





;
;LUNAR LANDER DECIMAL MODES
;--------------------------
;$75 ADC ZP,X
;$E9 SBC #
;$69 ADC #		DONE
;$E5 SBC ZP
;
;
;
; DECIMAL MODE ALGORITHM
;--------------------------
;	R=T2*16+T1
;ELSE
;	T2=NH1+NH2
;	IF T2>9 THEN T2=T2-10
;	R=T2*16+T1
;

;
; CPU_ACC = CPU_ACC + ZL
;
ADC_DECIMAL:
	// Split CPU_ACC into nybbles in r17(H) and r16(L)
	mov		r16,CPU_ACC
	andi	r16,0x0f
	mov		r17,CPU_ACC
	swap	r17
	andi	r17,0x0f

	// Split ZL into nybbles in r13(H) and r26(L)
	mov		r26,ZL
	andi	r26,0x0f
	mov		r27,ZL
	swap	r27
	andi	r27,0x0f

	// Add low nybbles and carry into r10
	clc
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		r16,r26

	// Test if result > 9
	cpi		r16,10
	brmi	ADC_DECIMAL_NoCarryOnLowNybble
	// If result>9 then subtract 10
	subi	r16,10
	// Add high nybbles plus 1 for carry
	sec
	adc		r17,r27
	// Test if result > 9
	cpi		r17,10
	brmi	ADC_DECIMAL_NoCarryOnHighNybble
	// If result>9 then subtract 10
	subi	r17,10
ADC_DECIMAL_NoCarryOnHighNybble:
	// Combine hi and lo nybbles into CPU_ACC again
	swap	r17
	or		r17,r16
	mov		CPU_ACC, r17
	tst		CPU_ACC
	UpdateNCZVjmpLoop


ADC_DECIMAL_NoCarryOnLowNybble:
	// Add high nybbles
	clc
	adc		r17,r13
	// Test if result > 9
	cpi		r17,10
	brmi	ADC_DECIMAL_NoCarryOnHighNybble2
	// If result>9 then subtract 10
	subi	r17,10
ADC_DECIMAL_NoCarryOnHighNybble2:
	// Combine hi and lo nybbles into CPU_ACC again
	swap	r17
	or		r17,r16
	mov		CPU_ACC, r17
	tst		CPU_ACC
	UpdateNCZVjmpLoop

