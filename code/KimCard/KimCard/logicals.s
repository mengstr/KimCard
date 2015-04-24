#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global	OP_ORA_IX
.global	OP_ORA_ZP
.global	OP_ORA_IM
.global	OP_ORA_AB
.global	OP_ORA_IY
.global	OP_ORA_ZPX
.global	OP_ORA_ABY
.global	OP_ORA_ABX
.global	OP_AND_IX
.global	OP_AND_ZP
.global	OP_AND_IM
.global	OP_AND_AB
.global	OP_AND_IY
.global	OP_AND_ZPX
.global	OP_AND_ABY
.global	OP_AND_ABX
.global	OP_EOR_IX
.global	OP_EOR_ZP
.global	OP_EOR_IM
.global	OP_EOR_AB
.global	OP_EOR_IY
.global	OP_EOR_ZPX
.global	OP_EOR_ABY
.global	OP_EOR_ABX




;*****************************************************************************
;
; AND - Logical AND
;
; A,Z,N = A&M
;
; A logical AND is performed, bit by bit, on the accumulator contents using 
; the contents of a byte of memory.
;
; C	Carry Flag	-
; Z	Zero Flag	Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command	-
; V	Overflow Flag	-
; N	Negative Flag	Set if bit 7 set
;

OP_AND_IM:				; *** $29 - AND IMMEDIATE
	ClearNZ
	HandleIMMEDIATE
	ld		r16, Z
	and		CPU_ACC, ZL
	UpdateNZjmpLoop
	


OP_AND_ZP:				; *** $25 - AND ZEROPAGE
	ClearNZ
	HandleZEROPAGE
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_AND_ZPX:				; *** $35 - AND ZEROPAEGE,X 
	ClearNZ
	HandleZEROPAGE_X
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_AND_AB:				; *** $2D - AND ABSOLUTE
	ClearNZ
	HandleABSOLUTE
	breq	ANDAB_Port
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
ANDAB_Port:	
	cpi		ZL, 0x40	; Is Data Register A?
	brne	ANDAB_Port1
	in		r16, PA_IN
	ldi		XH, hi8(BitReverseTable)	; TODO FIX BUG IN HARDWARE AND REMOVE THIS PATCH
	ldi		XL, lo8(BitReverseTable)	; TODO FIX BUG IN HARDWARE AND REMOVE THIS PATCH
	add		XL, r16						; TODO FIX BUG IN HARDWARE AND REMOVE THIS PATCH
	ld		r16, X						; TODO FIX BUG IN HARDWARE AND REMOVE THIS PATCH
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	jmp 	Loop
ANDAB_Port1:
	jmp		Loop

OP_AND_ABX:				; *** $3D - AND ABSOLUTE,X 
	ClearNZ
	HandleABSOLUTE_X
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_AND_ABY:				; *** $39 - AND ABSOLUTE,Y 
	ClearNZ
	HandleABSOLUTE_Y
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_AND_IX:				; *** $21 - AND (INDIRECT,X) 
	ClearNZ
	HandleINDIRECT_X
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_AND_IY:				; *** $31 - AND (INDIRECT),Y
	ClearNZ
	HandleINDIRECT_Y
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	

;*****************************************************************************
;
; ORA - Logical Inclusive OR
;
; A,Z,N = A|M
;
; An inclusive OR is performed, bit by bit, on the accumulator contents 
; using the contents of a byte of memory.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 set
;

OP_ORA_IM:				; *** $09 - ORA IMMEDIATE
	ClearNZ
	HandleIMMEDIATE
	or		CPU_ACC, ZL
	UpdateNZjmpLoop
	


OP_ORA_ZP:				; *** $05 - ORA ZEROPAGE
	ClearNZ
	HandleZEROPAGE	
	ld		r16, Z
	or		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_ORA_ZPX:				; *** $15 - ORA ZEROPAGE,X 
	ClearNZ
	HandleZEROPAGE_X
	ld		r16, Z
	or		CPU_ACC, r16
	UpdateNZjmpLoop



OP_ORA_AB:				; *** $0D - ORA ABSOLUTE
	ClearNZ
	HandleABSOLUTE
	ld		r16, Z
	or		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_ORA_ABX:				; *** $1D - ORA ABSOLUTE,X 
	ClearNZ
	HandleABSOLUTE_X
	ld		r16, Z
	or		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_ORA_ABY:				; *** $19 - ORA ABSOLUTE,Y
	ClearNZ
	HandleABSOLUTE_Y
	ld		r16, Z
	or		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_ORA_IX:				; *** $01 - ORA (INDIRECT,X)
	ClearNZ
	HandleINDIRECT_X
	ld		r16, Z
	or		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_ORA_IY:				; *** $11 - ORA (INDIRECT),Y
	ClearNZ
	HandleINDIRECT_Y
	ld		r16, Z
	or		CPU_ACC, r16
	UpdateNZjmpLoop
	





;*****************************************************************************
;
; EOR - Exclusive OR
;
; A,Z,N = A^M
;
; An exclusive OR is performed, bit by bit, on the accumulator contents 
; using the contents of a byte of memory.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 set
;

OP_EOR_IM:				; *** $49 - EOR IMMEDIATE
	ClearNZ
	HandleIMMEDIATE
	eor		CPU_ACC, ZL
	UpdateNZjmpLoop
	

OP_EOR_ZP:				; *** $45 - EOR ZEROPAGE
	ClearNZ
	HandleZEROPAGE
	ld		r16, Z
	eor		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_EOR_ZPX:				; *** $55 - EOR ZEROPAGE,X
	ClearNZ
	HandleZEROPAGE_X
	ld		r16, Z
	eor		CPU_ACC, r16
	UpdateNZjmpLoop



OP_EOR_AB:				; *** $4D - EOR ABSOLUTE 
	ClearNZ
	HandleABSOLUTE
	ld		r16, Z
	eor		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_EOR_ABX:				; *** $5D - EOR ABSOLUTE,X
	ClearNZ
	HandleABSOLUTE_X
	ld		r16, Z
	eor		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_EOR_ABY:				; *** $59 - EOR ABSOLUTE,Y
	ClearNZ
	HandleABSOLUTE_Y
	ld		r16, Z
	eor		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_EOR_IX:				; *** $41 - EOR (INDIRECT,X)
	ClearNZ
	HandleINDIRECT_X
	ld		r16, Z
	eor		CPU_ACC, r16
	UpdateNZjmpLoop
	


OP_EOR_IY:				; *** $51 - EOR (INDIRECT),Y
	ClearNZ
	HandleINDIRECT_Y
	ld		r16, Z
	eor		CPU_ACC, r16
	UpdateNZjmpLoop
	


