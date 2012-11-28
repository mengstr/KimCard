#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global	OP_SBC_IX
.global	OP_SBC_ZP
.global	OP_SBC_IM
.global	OP_SBC_AB
.global	OP_SBC_IY
.global	OP_SBC_ZPX
.global	OP_SBC_ABY
.global	OP_SBC_ABX


;*****************************************************************************
;
; SBC - Subtract with Carry
;
; A,Z,C,N = A-M-(1-C)
;
; This instruction subtracts the contents of a memory location to the 
; accumulator together with the not of the carry bit. If overflow occurs the 
; carry bit is clear, this enables multiple byte subtraction to be performed.
;
; NOTE: These instructions are affected by the Decimal Mode Flag
;
; C	Carry Flag			Clear if overflow in bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		Set if sign bit is incorrect
; N	Negative Flag		Set if bit 7 set
;

OP_SBC_IM:				; *** $E9 - SBC IMMEDIATE
						; TODO : Handle Decimal Mode
	HandleIMMEDIATE
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, ZL
	UpdateNCZVjmpLoop


OP_SBC_ZP:				; *** $E5 - SBC ZEROPAGE
						; TODO : Handle Decimal Mode
	HandleZEROPAGE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ZPX:				; *** $F5 - SBC ZEROPAGE,X
						; TODO : Handle Decimal Mode
	HandleZEROPAGE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


OP_SBC_AB:				; *** $ED - SBC ABSOLUTE
						; TODO : Handle Decimal Mode
	HandleABSOLUTE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ABX:				; *** $FD - SBC ABSOLUTE,X
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ABY:				; *** $F9 - SBC ABSOLUTE,Y	 
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_IX:				; *** $E1 - SBC (INDIRECT,X)
						; TODO : Handle Decimal Mode
	HandleINDIRECT_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_IY:				; *** $F1 - SBC (INDIRECT),Y
						; TODO : Handle Decimal Mode
	HandleINDIRECT_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	



