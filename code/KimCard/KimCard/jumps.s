#include <avr/io.h>
#include "main.h"
#include "macros.inc"

.global OP_JSR
.global OP_RTI
.global OP_JMP_AB
.global OP_RTS
.global OP_JMP_IND


;*****************************************************************************
;
; JMP - Jump
; 
; Sets the program counter to the address specified by the operand.;
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;
 

OP_JMP_AB:				; *** $4C - JMP ABSOLUTE 
#ifdef DEBUG
	nop
#endif
	FixPageNoStore			; Offset for SRAM
	ld		r16, Y+			; Jump address low
	ld		r17, Y+			; Jump address hi
	mov		CPU_PCL, r16
	mov		CPU_PCH, r17
	jmp 	Loop
	

OP_JMP_IND:				; *** $6C - JMP (INDIRECT)
	FixPageNoStore				; Offset for SRAM
	ld		ZL, Y+			; Jump indirect address low
	ld		ZH, Y+			; Jump indirect address hi
	FixPageNoStore_Z		; Offset for SRAM
	ld		r16, Z+			; Jump address low
	ld		r17, Z+			; Jump address hi
	mov		CPU_PCL, r16
	mov		CPU_PCH, r17
	jmp 	Loop


	
;*****************************************************************************
;
; JSR - Jump to Subroutine
; 
; The JSR instruction pushes the address (minus one) of the return point on
; to the stack and then sets the program counter to the target memory address.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_JSR:					; *** $20 - JSR ABSOLUTE
	adiw	YY, 1
	ldi		ZH, 0x20+1		; Push current PC to stack  offset 0x20 page for SRAM
	mov		ZL, CPU_SP
	st		Z, YH
	dec		ZL
	st		Z, YL
	dec		CPU_SP			; Update CPU stack pointer
	dec		CPU_SP
	sbiw	YY, 1

	FixPageNoStore
	ld		r16, Y+			; Jump address low
	ld		r17, Y+			; Jump address hi
	mov		CPU_PCL, r16
	mov		CPU_PCH, r17
	jmp 	Loop
	


;*****************************************************************************
;
; RTS - Return from Subroutine
;
; The RTS instruction is used at the end of a subroutine to return to the 
; calling routine. It pulls the program counter (minus one) from the stack.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	- 
; B	Break Command		- 
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_RTS:					; *** $40 - RTS 
	ldi		ZH, 0x20+1			; Offset 0x20 pages for SRAM
	mov		ZL, CPU_SP
	inc		ZL
	ld		CPU_PCL, Z
	inc		ZL
	ld		CPU_PCH, Z
	inc		CPU_SP
	inc		CPU_SP
	adiw	YY, 1
	jmp 	Loop





;*****************************************************************************
;
; RTI - Return from Interrupt
; 
; The RTI instruction is used at the end of an interrupt processing routine. 
; It pulls the processor flags from the stack followed by the program counter.
;
; C	Carry Flag			Set from stack
; Z	Zero Flag			Set from stack
; I	Interrupt Disable	Set from stack
; D	Decimal Mode Flag	Set from stack
; B	Break Command		Set from stack
; V	Overflow Flag		Set from stack
; N	Negative Flag		Set from stack
;

OP_RTI:					; *** $40 - RTI
ldi		ZH, 0x20+1			; Offset 0x20 pages for SRAM
	mov		ZL, CPU_SP

	inc		ZL
	ld		CPU_STATUS, Z

	inc		ZL
	ld		CPU_PCL, Z

	inc		ZL
	ld		CPU_PCH, Z

	inc		CPU_SP
	inc		CPU_SP
	inc		CPU_SP
	jmp 	Loop
	





