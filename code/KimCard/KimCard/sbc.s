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
#ifdef DEBUG
	nop
#endif
	HandleIMMEDIATE
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, ZL
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


OP_SBC_ZP:				; *** $E5 - SBC ZEROPAGE
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


OP_SBC_ZPX:				; *** $F5 - SBC ZEROPAGE,X
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


OP_SBC_AB:				; *** $ED - SBC ABSOLUTE
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


OP_SBC_ABX:				; *** $FD - SBC ABSOLUTE,X
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


OP_SBC_ABY:				; *** $F9 - SBC ABSOLUTE,Y	 
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


OP_SBC_IX:				; *** $E1 - SBC (INDIRECT,X)
#ifdef DEBUG
	nop
#endif
	HandleINDIRECT_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


OP_SBC_IY:				; *** $F1 - SBC (INDIRECT),Y
#ifdef DEBUG
	nop
#endif
	HandleINDIRECT_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


;-----------------------------------------------------------------------------


;
;LUNAR LANDER DECIMAL MODES
;--------------------------
;$75 ADC ZP,X
;$E9 SBC #
;$E5 SBC ZP
;$69 ADC #		DONE
;
;
;




;
; CPU_ACC = CPU_ACC - ZL
;
SBC_DECIMAL:
	clc
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
BCDsub:
	sub		CPU_ACC,ZL		;subtract the numbers binary
	clr		ZL
	brcc	sub_0			;if carry not clear
	ldi		ZL,1			;    store carry in ZL1, bit 0
sub_0:	
	brhc	sub_1			;if half carry not clear
	subi	CPU_ACC,6		;    LSD = LSD - 6
sub_1:	
	sbrs	ZL,0			;if previous carry not set
	ret						;    return
	subi	CPU_ACC,0x60	;subtract 6 from MSD
	ldi		ZL,1			;set underflow carry
	brcc	sub_2			;if carry not clear
	ldi		ZL,1			;    clear underflow carry	
sub_2:	
	ret			




/*

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
	sbc		r16,r26

	// Test if result > 9
	cpi		r16,10
	brmi	SBC_DECIMAL_NoCarryOnLowNybble
	// If result>9 then subtract 10
	subi	r16,10
	// Add high nybbles plus 1 for carry
	sec
	adc		r17,r27
	// Test if result > 9
	cpi		r17,10
	brmi	SBC_DECIMAL_NoCarryOnHighNybble
	// If result>9 then subtract 10
	subi	r17,10
SBC_DECIMAL_NoCarryOnHighNybble:
	// Combine hi and lo nybbles into CPU_ACC again
	swap	r17
	or		r17,r16
	mov		CPU_ACC, r17
	tst		CPU_ACC
	UpdateNCZVjmpLoop


SBC_DECIMAL_NoCarryOnLowNybble:
	// Add high nybbles
	clc
	adc		r17,r13
	// Test if result > 9
	cpi		r17,10
	brmi	SBC_DECIMAL_NoCarryOnHighNybble2
	// If result>9 then subtract 10
	subi	r17,10
SBC_DECIMAL_NoCarryOnHighNybble2:
	// Combine hi and lo nybbles into CPU_ACC again
	swap	r17
	or		r17,r16
	mov		CPU_ACC, r17
	tst		CPU_ACC
	UpdateNCZVjmpLoop

*/