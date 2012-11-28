#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global OP_CMP_IX
.global OP_CMP_ZP
.global OP_CMP_IM
.global OP_CMP_AB
.global OP_CMP_IY
.global OP_CMP_ZPX
.global OP_CMP_ABY
.global OP_CMP_ABX
.global OP_CPX_IM
.global OP_CPX_ZP
.global OP_CPX_AB
.global OP_CPY_ZP
.global OP_CPY_IM
.global OP_CPY_AB



;*****************************************************************************
;
; CMP - Compare
;
; Z,C,N = A-M
;
; This instruction compares the contents of the accumulator with another 
; memory held value and sets the zero and carry flags as appropriate.
;
; C	Carry Flag			Set if A >= M
; Z	Zero Flag			Set if A = M
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_CMP_IM:				; *** $C9 -	CMP IMMEDIATE
	HandleIMMEDIATE
	cp		CPU_ACC,ZL
	UpdateNZInvCjmpLoop
	



OP_CMP_ZP:				; *** $C5 - CMP ZEROPAGE
	HandleZEROPAGE
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNZInvCjmpLoop



OP_CMP_ZPX:				; *** $D5 - CMP ZEROPAGE,X
	HandleZEROPAGE_X
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNZInvCjmpLoop



OP_CMP_AB:				; *** $CD - CMP ABSOLUTE
	HandleABSOLUTE
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNZInvCjmpLoop



OP_CMP_ABX:				; *** $DD - CMP ABSOLUTE,X
	HandleABSOLUTE_X
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNZInvCjmpLoop



OP_CMP_ABY:				; *** $D9 - CMP ABSOLUTE,Y
	HandleABSOLUTE_Y
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNZInvCjmpLoop



OP_CMP_IX:				; *** $C1 - CMP (INDIRECT,X)
	HandleINDIRECT_X
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNZInvCjmpLoop



OP_CMP_IY:				; *** $D1 - CMP (INDIRECT),Y
	HandleINDIRECT_Y
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNZInvCjmpLoop
	







;*****************************************************************************
;
; CPX - Compare X Register
;
; Z,C,N = X-M
;
; This instruction compares the contents of the X register with another 
; memory held value and sets the zero and carry flags as appropriate.
;
; C	Carry Flag			Set if X >= M
; Z	Zero Flag			Set if X = M
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_CPX_IM:				; *** $E0 - CPX IMMEDIATE
	HandleIMMEDIATE
	cp		CPU_X, ZL
	UpdateNCZjmpLoop



OP_CPX_ZP:				; *** $E4 - CPX ZEROPAGE
	HandleZEROPAGE
	ld		r16, Z
	cp		CPU_X, r16
	UpdateNCZjmpLoop



OP_CPX_AB:				; *** $EC -	CPX ABSOLUTE
	HandleABSOLUTE
	ld		r16, Z
	cp		CPU_X, r16
	UpdateNCZjmpLoop	
	


;*****************************************************************************
;
; CPY - Compare Y Register
;
; Z,C,N = Y-M
;
; This instruction compares the contents of the Y register with another 
; memory held value and sets the zero and carry flags as appropriate.
;
; C	Carry Flag			Set if Y >= M
; Z	Zero Flag			Set if Y = M
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_CPY_IM:				; *** $C0 - CPY IMMEDIATE
	HandleIMMEDIATE
	ld		r16, Z
	cp		CPU_Y, ZL
	UpdateNCZjmpLoop



OP_CPY_ZP:				; *** $C4 -	CPY ZEROAPAGE
	HandleZEROPAGE
	ld		r16, Z
	cp		CPU_Y, r16
	UpdateNCZjmpLoop



OP_CPY_AB:				; *** $CC - CPY ABSOLUTE
	HandleABSOLUTE
	ld		r16, Z
	cp		CPU_Y, r16
	UpdateNCZjmpLoop	
	
	
