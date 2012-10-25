
;*****************************************************************************
;
; NOP - No Operation
;
; The NOP instruction causes no changes to the processor other than the 
; normal incrementing of the program counter to the next instruction.
; 
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_NOP:					; *** $EA - NOP
	jmp 	Loop





;*****************************************************************************
;
; PHA - Push Accumulator
;
; Pushes a copy of the accumulator on to the stack.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N Negative Flag		-
;
OP_PHA:					; ** $48 - PHA
	ldi		ZH, 0x20+1		; Stack is 0x100-0x1FF on 6502. Offset this with 0x20 pages for SRAM
	mov		ZL,	CPU_SP
	st		Z, CPU_ACC
	dec		CPU_SP		
	jmp 	Loop
	


;*****************************************************************************
;
; PHP - Push Processor Status
;
; Pushes a copy of the status flags on to the stack.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		-
;

OP_PHP:					; *** $08 - PHP
	ldi		ZH, 0x20+1		; Stack is 0x100-0x1FF on 6502. Offset this with 0x20 pages for SRAM
	mov		ZL,	CPU_SP
	st		Z, CPU_STATUS
	dec		CPU_SP		
	jmp 	Loop
	


;*****************************************************************************
;
; PLP - Pull Processor Status
;
; Pulls an 8 bit value from the stack and into the processor flags. The 
; flags will take on new states as determined by the value pulled.
;
;
; C	Carry Flag			Set from stack
; Z	Zero Flag			Set from stack
; I	Interrupt Disable	Set from stack
; D	Decimal Mode Flag	Set from stack
; B	Break Command		Set from stack
; V	Overflow Flag		Set from stack
; N	Negative Flag		Set from stack
;

OP_PLP:					; *** $28 - PLP
	ldi		ZH, 0x20+1		; Stack is 0x100-0x1FF on 6502. Offset this with 0x20 pages for SRAM
	mov		ZL,	CPU_SP
	inc		CPU_SP		
	inc 	ZL
	ld		CPU_STATUS, Z
	jmp 	Loop
	
