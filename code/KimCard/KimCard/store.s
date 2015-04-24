#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global OP_STA_IX
.global OP_STY_ZP
.global OP_STA_ZP
.global OP_STX_ZP
.global OP_STY_AB
.global OP_STA_AB
.global OP_STX_AB
.global OP_STA_IY
.global OP_STY_ZPX
.global OP_STA_ZPX
.global OP_STX_ZPY
.global OP_STA_ABY
.global OP_STA_ABX



;*****************************************************************************
;
; STA - Store Accumulator 
;
; M = A
; Stores the contents of the accumulator into memory.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		-
;

OP_STA_ZP:				; *** $85 - STA ZEROPAGE
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	st		Z, CPU_ACC
	jmp 	Loop


;-----------------------------------------------------------------------------


OP_STA_ZPX:				; *** $95 - STA ZEROPAGE,X
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_X
	st		Z, CPU_ACC
	jmp 	Loop


;-----------------------------------------------------------------------------


OP_STA_AB:				; *** $8D - STA ABSOLUTE
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	StoreAbsolute CPU_ACC


;-----------------------------------------------------------------------------


OP_STA_ABX:				; *** $9D - STA ABSOLUTE,X
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_X
	breq	OP_STA_ABX_PORT
	st		Z, CPU_ACC	
	jmp 	Loop
OP_STA_ABX_PORT:
	nop		; // TODO
	jmp		Loop	


;-----------------------------------------------------------------------------


OP_STA_ABY:				; *** $99 - STA ABSOLUTE,Y 
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_Y
	breq	OP_STA_ABY_PORT
	st		Z, CPU_ACC
	jmp 	Loop
OP_STA_ABY_PORT:
	nop		; // TODO
	jmp		Loop	


;-----------------------------------------------------------------------------


OP_STA_IX:				; *** $81 - STA (INDIRECT,X) 
#ifdef DEBUG
	nop
#endif
	HandleINDIRECT_X
	breq	OP_STA_IX_PORT
	st		Z, CPU_ACC
	jmp 	Loop
OP_STA_IX_PORT:
	nop		; // TODO
	jmp		Loop


;-----------------------------------------------------------------------------


OP_STA_IY:				; *** $91 - STA (INDIRECT),Y 
#ifdef DEBUG
	nop
#endif
	HandleINDIRECT_Y
	breq	OP_STA_IY_PORT
	st		Z, CPU_ACC
	jmp 	Loop
OP_STA_IY_PORT:
	nop		; // TODO
	



;*****************************************************************************
;
; STX - X-Register
;
; M = X
;
; Stores the contents of the x-register into memory.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		-
;

OP_STX_ZP:				; *** $86 - STX ZEROPAGE
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	st		Z, CPU_X
	jmp 	Loop


;-----------------------------------------------------------------------------


OP_STX_ZPY:				; *** $96 - STX ZEROPAGE,Y 
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_Y
	st		Z, CPU_X
	jmp 	Loop


;-----------------------------------------------------------------------------


OP_STX_AB:				; *** $8E - STX ABSOLUTE
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	StoreAbsolute CPU_X



;*****************************************************************************
;
; STY - Store Y-Register
;
; M = Y
;
; Stores the contents of the y-register into memory.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		-
;

OP_STY_ZP:				; *** $84 - STY ZEROPAGE
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE
	st		Z, CPU_Y
	jmp 	Loop


;-----------------------------------------------------------------------------


OP_STY_ZPX:				; *** $94 - STY ZEROPAGE,X
#ifdef DEBUG
	nop
#endif
	HandleZEROPAGE_X
	st		Z, CPU_Y
	jmp 	Loop


;-----------------------------------------------------------------------------


OP_STY_AB:				; *** $8C - STY ABSOLUTE
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	StoreAbsolute CPU_Y


	
