#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global OP_ASL_ZP
.global OP_ASL_AC
.global OP_ASL_AB
.global OP_ASL_ZPX
.global OP_ASL_ABX
.global OP_ROL_ZP
.global OP_ROL_AC
.global OP_ROL_AB
.global OP_ROL_ZPX
.global OP_ROL_ABX
.global OP_LSR_ZP
.global OP_LSR_AC
.global OP_LSR_AB
.global OP_LSR_ZPX
.global OP_LSR_ABX
.global OP_ROR_ZP
.global OP_ROR_AC
.global OP_ROR_AB
.global OP_ROR_ZPX
.global OP_ROR_ABX


;*****************************************************************************
;
; ROL - Rotate Left
;
; Move each of the bits in either A or M one place to the left. Bit 0 is 
; filled with the current value of the carry flag whilst the old bit 7 
; becomes the new carry flag value.
;
;
; C	Carry Flag			Set to contents of old bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_ROL_AC:				; *** $2A - ROL
#ifdef DEBUG
	nop
#endif
	UpdateCarryFromCPU
	rol		CPU_ACC
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ROL_ZP:				; *** $26 - ROL ZEROPAGE 
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ROL_ZPX:				; *** $36 - ROL ZEROPAGE,X 
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_X
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ROL_AB:				; *** $2E - ROL ABSOLUTE  
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ROL_ABX:				; *** $3E - ROL ABSOLUTE,X
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_X
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop
	



;*****************************************************************************
;
; ROR - Rotate Right
;
; Move each of the bits in either A or M one place to the right. Bit 7 is 
; filled with the current value of the carry flag whilst the old bit 0 
; becomes the new carry flag value.
;
; C	Carry Flag			Set to contents of old bit 0
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_ROR_AC:				; *** $6A - ROR
#ifdef DEBUG
	nop
#endif
	UpdateCarryFromCPU
	ror		CPU_ACC
	UpdateNCZjmpLoop
	jmp Loop


;-----------------------------------------------------------------------------


OP_ROR_ZP:				; *** $66 - ROR ZEROPAGE
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ROR_ZPX:				; *** $76 - ROR ZEROPAGE,X
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_X
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ROR_AB:				; *** $6E - ROR ABSOLUTE
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ROR_ABX:				; *** $7E - ROR ABSOLUTE,X 
#ifdef DEBUG
	nop
#endif
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop
	jmp Loop
	


;*****************************************************************************
;
; ASL - Arithmetic Shift Left
; 
; A,Z,C,N = M*2 or M,Z,C,N = M*2
;
; This operation shifts all the bits of the accumulator or memory contents 
; one bit left. Bit 0 is set to 0 and bit 7 is placed in the carry flag. The 
; effect of this operation is to multiply the memory contents by 2 (ignoring 
; 2's complement considerations), setting the carry if the result will not fit
; in 8 bits.
;
; C	Carry Flag			Set to contents of old bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		- 
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_ASL_AC:				; *** $0A - ASL
#ifdef DEBUG
	nop
#endif
	lsl		CPU_ACC
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ASL_ZP:				; *** $06 - ASL ZEROPAGE  
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ASL_ZPX:				; *** $16 - ASL ZEROPAGE,X
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_X
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ASL_AB:				; *** $0E - ASL ABSOLUTE 
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop


;-----------------------------------------------------------------------------


OP_ASL_ABX:				; *** $1E - ASL ABSOLUTE,X   
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_X
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


;*****************************************************************************
;
; LSR - Logical Shift Right
; 
; A,C,Z,N = A/2 or M,C,Z,N = M/2
; 
; Each of the bits in A or M is shift one place to the right. The bit that 
; was in bit 0 is shifted into the carry flag. Bit 7 is set to zero.
;
;
; C	Carry Flag			Set to contents of old bit 0
; Z	Zero Flag			Set if result = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		0

OP_LSR_AC:				; *** $4A - LSL  
#ifdef DEBUG
	nop
#endif
	ClearNZ
	lsr		CPU_ACC
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LSR_ZP:				; *** $46 - LSR ZEROPAGE 
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop


;-----------------------------------------------------------------------------


OP_LSR_ZPX:				; *** $56 - LSR ZEROPAGE,X  
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_X
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop


;-----------------------------------------------------------------------------


OP_LSR_AB:				; *** $4E - LSR ABSOLUTE  
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop


;-----------------------------------------------------------------------------


OP_LSR_ABX:				; *** $5E LSR ABSOLUTE,X
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_X
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	


