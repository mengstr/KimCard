#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global OP_DEY
.global OP_DEC_ZP
.global OP_INY
.global OP_DEX
.global OP_DEC_AB
.global OP_DEC_ZPX
.global OP_DEC_ABX
.global OP_INC_ZP
.global OP_INX
.global OP_INC_AB
.global OP_INC_ZPX
.global OP_INC_ABX



;*****************************************************************************
;
; INC - Increment Memory
;
; M,Z,N = M+1
;
; Adds one to the value held at a specified memory location setting the 
; zero and negative flags as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if result is zero
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_INC_ZP:				; *** $E6 - INC ZEROPAGE
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleZEROPAGE
	ld		r16, Z
	inc		r16
	st		Z, r16
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_INC_ZPX:				; *** $F6 - INC ZEROPAEGE,X
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleZEROPAGE_X
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_INC_AB:				; *** $EE - INC ABSOLUTE
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleABSOLUTE
	ld		r16, Z
	inc		r16
	st		Z, r16
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_INC_ABX:				; *** $FE - INC ABSOLUTE,X
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleABSOLUTE_X
	ld		r16, Z
	inc		r16
	st		Z, r16
	UpdateNZjmpLoop



;*****************************************************************************
;
; INX - Increment X Register
;
; X,Z,N = X+1
;
; Adds one to the X register setting the zero and negative flags as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if X is zero
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of X is set
;

OP_INX:					; *** $E8 - INX 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	inc		CPU_X
	UpdateNZjmpLoop




;*****************************************************************************
;
; INY - Increment Y Register
;
; Y,Z,N = Y+1
;
; Adds one to the Y register setting the zero and negative flags 
; as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if Y is zero
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of Y is set
;

OP_INY:					; *** $C8 - INY
#ifdef DEBUG
	nop
#endif
	ClearNZ
	inc		CPU_Y
	UpdateNZjmpLoop




;*****************************************************************************
;
; DEC - Decrement Memory
;
; M,Z,N = M-1
;
; Subtracts one from the value held at a specified memory location setting 
; the zero and negative flags as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if result is zero
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_DEC_ZP:				; *** $C6 - DEC ZEROPAGE	
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleZEROPAGE
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_DEC_ZPX:				; *** $D6 - DEC ZEROPAGE,X
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleZEROPAGE_X
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_DEC_AB:				; *** $CE - DEC ABSOLUTE
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleABSOLUTE
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop


;-----------------------------------------------------------------------------


OP_DEC_ABX:				; *** $DE - DEC ABSOLUTE,X
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleABSOLUTE_X
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop




;*****************************************************************************
;
; DEX - Decrement X Register
;
; X,Z,N = X-1
;
; Subtracts one from the X register setting the zero and negative flags 
; as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if X is zero
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of X is set
;

OP_DEX:					; *** $CA - DEX
#ifdef DEBUG
	nop
#endif
	ClearNZ
	dec		CPU_X
	UpdateNZjmpLoop




;*****************************************************************************
;
; DEY - Decrement Y Register
;
; Y,Z,N = Y-1
;
; Subtracts one from the Y register setting the zero and negative flags 
; as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if Y is zero
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of Y is set
;

OP_DEY:					; *** $88 - DEY
#ifdef DEBUG
	nop
#endif
	ClearNZ
	dec		CPU_Y
	UpdateNZjmpLoop



