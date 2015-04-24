#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global OP_BPL
.global OP_BMI
.global OP_BVC
.global OP_BVS
.global OP_BCC
.global OP_BCS
.global OP_BNE
.global OP_BEQ

;*****************************************************************************
; BCC - Branch if Carry Clear
;
; If the carry flag is clear then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BCC:					; *** $90 - BCC
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE
	sbrc	CPU_STATUS, BIT_FLAG_CARRY
	jmp		Loop
	BranchJUMP



	
;*****************************************************************************
;
; BCS - Branch if Carry Set
;
; If the carry flag is set then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BCS:					; *** $B0 - BCS
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_CARRY
	jmp		Loop
	BranchJUMP

	


;*****************************************************************************
;
; BEQ - Branch if Equal
; 
; If the zero flag is set then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BEQ:					; *** $F0 - BEQ
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_ZERO
	jmp		Loop
	BranchJUMP

	



;*****************************************************************************
;
; BMI - Branch if Minus
;
; If the negative flag is set then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BMI:					; *** $30 - BMI
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_NEGATIVE
	jmp		Loop
	BranchJUMP



;*****************************************************************************
;
; BNE - Branch if Not Equal
;
; If the zero flag is clear then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BNE:					; *** $D0 - BNE
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE
	sbrc	CPU_STATUS, BIT_FLAG_ZERO
	jmp		Loop
	BranchJUMP



;*****************************************************************************
;
; BPL - Branch if Positive
;
; If the negative flag is clear then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BPL:	
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE		; *** $10 - BPL
	sbrc	CPU_STATUS, BIT_FLAG_NEGATIVE
	jmp		Loop
	BranchJUMP





;*****************************************************************************
;
; BVC - Branch if Overflow Clear
;
; If the overflow flag is clear then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BVC:					; *** $50 - BVC
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE
	sbrc	CPU_STATUS, BIT_FLAG_OVERFLOW
	jmp		Loop
	BranchJUMP


	


;*****************************************************************************
;
; BVS - Branch if Overflow Set
;
; If the overflow flag is set then add the relative displacement to the 
; program counter to cause a branch to a new location.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_BVS:					; *** $70 - BVS
#ifdef DEBUG
	nop
#endif
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_OVERFLOW
	jmp		Loop
	BranchJUMP





