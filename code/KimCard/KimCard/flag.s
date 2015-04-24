#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global OP_CLC
.global OP_SEC
.global OP_CLI
.global OP_SEI
.global OP_CLV
.global OP_CLD
.global OP_SED


;*****************************************************************************
;
; SEC - Set Carry Flag
;
; C = 1
;
; Set the carry flag to one.
;
; C	Carry Flag			1
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_SEC:					; *** $38 - SEC
#ifdef DEBUG
	nop
#endif
	sbr		CPU_STATUS, MASK_FLAG_CARRY
	jmp 	Loop
	



;*****************************************************************************
;
; SED - Set Decimal Flag
;
; D = 1
;
; Set the decimal mode flag to one.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	1 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_SED:					; *** $F8 - SED
#ifdef DEBUG
	nop
#endif
	sbr		CPU_STATUS, MASK_FLAG_DECIMAL
	jmp 	Loop
	


;*****************************************************************************
;
; SEI - Set Interrupt Disable
;
; I = 1
; 
; Set the interrupt disable flag to one.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	1
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_SEI:					; *** $78 - SEI
#ifdef DEBUG
	nop
#endif
	sbr		CPU_STATUS, MASK_FLAG_INTERRUPT
	jmp 	Loop
	


;*****************************************************************************
;
; CLC - Clear Carry Flag
;
; C = 0
;
; Set the carry flag to zero.
;
; C	Carry Flag			0
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_CLC:					; *** $18 - CLC
#ifdef DEBUG
	nop
#endif
	cbr		CPU_STATUS, MASK_FLAG_CARRY
	jmp 	Loop
	


;*****************************************************************************
;
; CLD - Clear Decimal Mode
;
; D = 0
;
; Sets the decimal mode flag to zero.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	0 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_CLD:					; *** $D8 - CLD
#ifdef DEBUG
	nop
#endif
	cbr		CPU_STATUS, MASK_FLAG_DECIMAL
	jmp 	Loop
	


;*****************************************************************************
;
; CLI - Clear Interrupt Disable
;
; I = 0
;
; Clears the interrupt disable flag allowing normal interrupt requests to 
; be serviced.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	0
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;
 
OP_CLI:					; *** $58 - CLI
#ifdef DEBUG
	nop
#endif
	cbr		CPU_STATUS, MASK_FLAG_INTERRUPT
	jmp 	Loop
	


;*****************************************************************************
;
; CLV - Clear Overflow Flag
;
; V = 0
;
; Clears the overflow flag.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		0
; N	Negative Flag		-
;

OP_CLV:					; *** $B8 - CLV
#ifdef DEBUG
	nop
#endif
	cbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	jmp 	Loop


