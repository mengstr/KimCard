#include <avr/io.h>
#include "main.h"
#include "macros.inc"
	
.global OP_TXA
.global OP_TYA
.global OP_TXS
.global OP_TAY
.global OP_TAX
.global OP_TSX



;*****************************************************************************
;
; TAX - Transfer Accumulator to X
;
; X = A
; 
; Copies the current contents of the accumulator into the X register and 
; sets the zero and negative flags as appropriate.
;
;
; C	Carry Flag			-
; Z	Zero Flag			Set if X = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of X is set
;

OP_TAX:					; *** $AA - TAX 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	mov		CPU_X, CPU_ACC
	UpdateNZjmpLoop
	


;*****************************************************************************
;
; TAY - Transfer Accumulator to Y
;
; Y = A
;
; Copies the current contents of the accumulator into the Y register and sets 
; the zero and negative flags as appropriate
;
; C	Carry Flag			-
; Z	Zero Flag			Set if Y = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of Y is set
;

OP_TAY:					; *** $A8 - TAY 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	mov		CPU_Y, CPU_ACC
	UpdateNZjmpLoop
	


;*****************************************************************************
;
; TSX - Transfer Stack Pointer to X
;
; X = S
;
; Copies the current contents of the stack register into the X register and 
; sets the zero and negative flags as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if X = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of X is set
;

OP_TSX:					; *** $BA - TSX
#ifdef DEBUG
	nop
#endif
	ClearNZ
	mov		CPU_X, CPU_SP
	UpdateNZjmpLoop
	



;*****************************************************************************
;
; TXA - Transfer X to Accumulator
;
; A = X

; Copies the current contents of the X register into the accumulator and sets 
; the zero and negative flags as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of A is set
;

OP_TXA:					; *** $8A - TXA 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	mov		CPU_ACC, CPU_X
	UpdateNZjmpLoop
	



;*****************************************************************************
;
; TXS - Transfer X to Stack Pointer
;
; S = X
;
; Copies the current contents of the X register into the stack register.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		-
;

OP_TXS:					; *** $9A - TXS
#ifdef DEBUG
	nop
#endif
	ClearNZ
	mov		CPU_SP, CPU_X
	UpdateNZjmpLoop


	
;*****************************************************************************
;
; TYA - Transfer Y to Accumulator
;
; A = Y

; Copies the current contents of the Y register into the accumulator and sets 
; the zero and negative flags as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of A is set
;

OP_TYA:					; *** $98 - TYA 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	mov		CPU_ACC, CPU_Y
	UpdateNZjmpLoop
	
