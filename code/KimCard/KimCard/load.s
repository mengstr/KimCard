#include <avr/io.h>
#include "main.h"
#include "macros.inc"


.global OP_LDY_IM
.global OP_LDA_IX
.global OP_LDX_IM
.global OP_LDY_ZP
.global OP_LDA_ZP
.global OP_LDX_ZP
.global OP_LDA_IM
.global OP_LDY_AB
.global OP_LDA_AB
.global OP_LDX_AB
.global OP_LDA_IY
.global OP_LDY_ZPX
.global OP_LDA_ZPX
.global OP_LDX_ZPY
.global OP_LDA_ABY
.global OP_LDY_ABX
.global OP_LDA_ABX
.global OP_LDX_ABY



;*****************************************************************************
;
; LDA - Load Accumulator	
;
; A,Z,N = M
;
; Loads a byte of memory into the accumulator setting 
; the zero and negative flags as appropriate
;
; C	Carry Flag			-
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		Set if bit 7 of A is set
;
 
OP_LDA_IM:				; *** $A9 - LDA IMMEDIATE
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleIMMEDIATE
	mov		CPU_ACC, ZL
	tst		CPU_ACC
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDA_ZP:				; *** $A5 - LDA ZEROPAGE 
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleZEROPAGE
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDA_ZPX:				; *** $B5 - LDA ZEROPAGE,X 	
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleZEROPAGE_X
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDA_AB:				; *** $AD - LDA ABSOLUTE  
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleABSOLUTE
	breq	LDA_AB_PORT
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop
	jmp 	Loop

LDA_AB_PORT:
	cpi		ZL, 0x04	; Timer?
	brne	LDA_AB_PORT1
	mov		CPU_ACC, tick		; TODO do real read from timer - not just fake
	tst		CPU_ACC
	jmp 	Loop

LDA_AB_PORT1:
	tst		CPU_ACC
	jmp		Loop


;-----------------------------------------------------------------------------


OP_LDA_ABX:				; *** $BD - LDA ABSOLUTE,X  
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleABSOLUTE_X
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDA_ABY:				; *** $B9 - LDA ABSOLUTE,Y 
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleABSOLUTE_Y
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDA_IX:				; *** $A1 - LDA (INDIRECT,X) 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleINDIRECT_X
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDA_IY:				; *** $B1 - LDA (INDIRECT),Y 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleINDIRECT_Y
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop
	


;*****************************************************************************
;
; LDX - Load X Register
;
; X,Z,N = M
;
; Loads a byte of memory into the x-register setting 
; the zero and negative flags as appropriate
;
; C	Carry Flag			-
; Z	Zero Flag			Set if X = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		Set if bit 7 of X is set
;
 
OP_LDX_IM:				; *** $A2 - LDX IMMEDIATE
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleIMMEDIATE
	mov		CPU_X, ZL
	tst		CPU_X
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDX_ZP:				; *** $A6 - LDX ZEROPAGE 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleZEROPAGE
	ld		CPU_X, Z
	tst		CPU_X
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDX_ZPY:				; *** $B6 - LDX ZEROPAGE,Y 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleZEROPAGE_Y
	ld		CPU_X, Z
	tst		CPU_X
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDX_AB:				; *** $AE - LDX ABSOLUTE 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleABSOLUTE
	ld		CPU_X, Z
	tst		CPU_X
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDX_ABY:				; *** $BE - LDX ABSOLUTE,Y 
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE_Y
	ld		CPU_X, Z
	jmp Loop
	


;*****************************************************************************
;
; LDY - Load Y Register
;
; Y,Z,N = M
;
; Loads a byte of memory into the y-register setting 
; the zero and negative flags as appropriate
;
; C	Carry Flag			-
; Z	Zero Flag			Set if Y = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		Set if bit 7 of Y is set
;

OP_LDY_IM:				; *** $A0 - LDY IMMEDIATE
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleIMMEDIATE
	mov		CPU_Y, ZL
	tst		CPU_Y
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDY_ZP:				; *** $A4 - LDY ZEROPAGE
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleZEROPAGE
	ld		CPU_Y, Z
	tst		CPU_Y
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDY_ZPX:				; *** $B4 - LDY ZEROPAGE,X
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleZEROPAGE_X
	ld		CPU_Y, Z
	tst		CPU_Y
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDY_AB:				; *** $AC - LDY ABSOLUTE
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleABSOLUTE
	ld		CPU_Y, Z
	tst		CPU_Y
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_LDY_ABX:				; *** $BC - LDY ABSOLUTE,Y	
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleABSOLUTE_X
	ld		CPU_Y, Z
	UpdateNZjmpLoop
	

