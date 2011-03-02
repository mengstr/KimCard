.NOLIST
.INCLUDE "m644adef.inc"
.LIST
.LISTMAC 

#define TEST



;
; ATMEGA328 PORT				USED FOR 
; -------------------------		----------------------------
; PB0 (PCINT0/CLKO/ICP1)
; PB1 (OC1A/PCINT1)
; PB2 (SS/OC1B/PCINT2)
; PB3 (MOSI/OC2A/PCINT3)
; PB4 (MISO/PCINT4)
; PB5 (SCK/PCINT5)
; PB6 (PCINT6/XTAL1/TOSC1)		(AVR XTAL)
; PB7 (PCINT7/XTAL2/TOSC2)		(AVR XTAL)
;
; PD0 (PCINT16/RXD) 			6502 Port A0 - LED Segment A
; PD1 (PCINT17/TXD) 			6502 Port A1 - LED Segment B
; PD2 (PCINT18/INT0)			6502 Port A2 - LED Segment C
; PD3 (PCINT19/OC2B/INT1)		6502 Port A3 - LED Segment D
; PD4 (PCINT20/XCK/T0)			6502 Port A4 - LED Segment E
; PD5 (PCINT21/OC0B/T1)			6502 Port A5 - LED Segment F
; PD6 (PCINT22/OC0A/AIN0)		6502 Port A6 - LED Segment G
; PD7 (PCINT23/AIN1)			
;
; PC0 (ADC0/PCINT8)				6502 Port - LED Digit 1
; PC1 (ADC1/PCINT9)				6502 Port - LED Digit 2
; PC2 (ADC2/PCINT10)			6502 Port - LED Digit 3
; PC3 (ADC3/PCINT11)			6502 Port - LED Digit 4
; PC4 (ADC4/SDA/PCINT12)		6502 Port - LED Digit 5
; PC5 (ADC5/SCL/PCINT13)		6502 Port - LED Digit 6
; PC6 (PCINT14/RESET) 			(AVR RESET/DW)
;

;
; MEMORY MAP - AVR RAM
; -------------------------------------------------------------------
; 00xx AVR registers (00-1F), IO (20-5F), Extended IO (60-FF)
; 01xx SRAM AVR stack
; 02xx SRAM 
; 03xx SRAM 
; 04xx SRAM KIM-1 RAM Zero page
; 05xx SRAM KIM-1 RAM Stack page
; 06xx SRAM KIM-1 RAM Code page
; 07xx SRAM KIM-1 RAM Code page
; 08xx SRAM
; 09xx SRAM
; 0Axx SRAM
; 0Bxx SRAM
; 0Cxx SRAM KIM-1 ROM Page 1Cxx
; 0Dxx SRAM KIM-1 ROM Page 1Dxx
; 0Exx SRAM KIM-1 ROM Page 1Exx
; 0Fxx SRAM KIM-1 ROM Page 1Fxx
; 10xx SRAM
;
;
; CONVERT KIM-1 MEMORY ADDRESS TO AVR SRAM ADDRESS
; -------------------------------------------------------------------
;	AND 0000 1111
;	OR  0000 0100
;
; KIM-1 MEMORY MAP									( AFTER AND+OR)
; -------------------------------------------------------------------
; 00xx - 0000 0000 xxxx xxxx - RAM Zero page RAM	(0000 0100) - 04
; 01xx - 0000 0001 xxxx xxxx - RAM Stack RAM		(0000 0101) - 05
; 02xx - 0000 0010 xxxx xxxx - RAM Code RAM			(0000 0110) - 06
; 03xx - 0000 0011 xxxx xxxx - RAM Code RAM			(0000 0111) - 07 
; 1cxx - 0001 1100 xxxx xxxx - ROM RRIOT 6530 #2	(0000 1100) - 0C
; 1dxx - 0001 1101 xxxx xxxx - ROM RRIOT 6530 #2	(0000 1101) - 0D
; 1exx - 0001 1110 xxxx xxxx - ROM RRIOT 6530 #2	(0000 1110) - 0E
; 1fxx - 0001 1111 xxxx xxxx - ROM RRIOT 6530 #2	(0000 1111) - 0F
;
;



	.equ	BIT_FLAG_CARRY		= 0
	.equ	BIT_FLAG_ZERO		= 1
	.equ	BIT_FLAG_INTERRUPT	= 2
	.equ	BIT_FLAG_DECIMAL	= 3
	.equ	BIT_FLAG_BREAK		= 4
	.equ	BIT_FLAG_UNUSED		= 5
	.equ	BIT_FLAG_OVERFLOW	= 6
	.equ	BIT_FLAG_NEGATIVE	= 7

	.equ	MASK_FLAG_CARRY		= (1<<BIT_FLAG_CARRY)
	.equ	MASK_FLAG_ZERO		= (1<<BIT_FLAG_ZERO)
	.equ	MASK_FLAG_INTERRUPT	= (1<<BIT_FLAG_INTERRUPT)
	.equ	MASK_FLAG_DECIMAL	= (1<<BIT_FLAG_DECIMAL)
	.equ	MASK_FLAG_BREAK		= (1<<BIT_FLAG_BREAK)
	.equ	MASK_FLAG_UNUSED	= (1<<BIT_FLAG_UNUSED)
	.equ	MASK_FLAG_OVERFLOW	= (1<<BIT_FLAG_OVERFLOW)
	.equ	MASK_FLAG_NEGATIVE	= (1<<BIT_FLAG_NEGATIVE)


	.def	ALWAYSZERO		= r0
	.def	TEMP			= r18
	.def	CPU_ACC			= r19
	.def	CPU_X			= r20
	.def	CPU_Y			= r21
	.def	CPU_STATUS		= r22
	.def	CPU_SP			= r23

	.def	CPU_PCH			= r29;	YH
	.def	CPU_PCL			= r28;	YL

	.equ	BIOS			= 0x0c00
	.equ	AVRSTACKSIZE	= 256	


	.DSEG	
	.ORG	0x0100

AVRSTACK:	.byte AVRSTACKSIZE

	.ORG	0x0400
KIM1RAM:	.byte 1024

	.ORG	0x0C00
KIM1ROM:	.byte 1024


	.INCLUDE "macros.inc"

	.CSEG
	.INCLUDE "InterruptVectors.inc"

	.CSEG
V_RESET:
	cli	
	ldi		r16,LOW(AVRSTACK) ;Initiate Stackpointer
	out		SPL,r16
	ldi		r16,HIGH(AVRSTACK)
	out		SPH,r16

	clr		r0				; r0 is set permanently to 0 for 16-bit additions

   ; Copy the initial values for the BIOS from Flash into RAM. 
	ldi 	ZH, high(BiosFlashData<< 1) 
	ldi 	ZL, low(BiosFlashData<< 1) 
	ldi 	XH, high(Bios) 
	ldi 	XL, low(Bios) 
	ldi 	YL, low(1024)
	ldi 	YH, high(1024)
BiosCopyLoop: 
	lpm 	r17, Z+ 
	st X+, 	r17 
	sbiw 	Y,1 
	brne 	BiosCopyLoop

	ldi		CPU_PCL, low(0x1C4F)	; KIM-1 BIOS starts at $1c4f
	ldi		CPU_PCH, high(0x1C4F)
	ldi		CPU_ACC, 0		; Initialize all register to zero
	ldi		CPU_X, 0
	ldi		CPU_Y, 0
	ldi		CPU_STATUS, 0
	ldi		CPU_SP, 0

;
; Include and execute the 6502 code test functions if TEST is #defined
; If successful the test code should end up in a 6502 HERE: JMP HERE
; If any test fail the code ends up in a BRK instruction
;
#ifdef TEST

	; Copy the data for the 6502 Test code from Flash into RAM. 
	ldi 	ZH, high(Test6502Data<< 1) 
	ldi 	ZL, low(Test6502Data<< 1) 
	ldi 	XH, high(KIM1RAM+512) 
	ldi 	XL, low(KIM1RAM+512) 
	ldi		YL, low(0x0200);	; The test code starts at $200
	ldi		YH, high(0x0200);

Test6502CopyLoop: 
	lpm 	r17, Z+ 
	st X+, 	r17 
	sbiw 	Y,1 
	brne 	Test6502CopyLoop

	ldi		CPU_PCL, low(0x0200);	; The test code starts at $200
	ldi		CPU_PCH, high(0x0200);
	jmp		Test6502DataEnd

TestOk:
	jmp		TestOk

TestFail:
	jmp		TestFail

Test6502Data:
	.INCLUDE "../test/test6502.inc"

Test6502DataEnd:
#endif
;
;
;


	;
	; Fetch the Opcode pointed by CPU_PCL/H
	;
loop:
	mov		TEMP, YH
;	andi	YH, 7			; Wrap addresspace to get access to BIOS at 0x1C00-0x1FFF as 0x0400
;	inc		YH				; Bump up one page for SRAM
	andi	YH, 0b00001111
	ori		YH, 0b00000100
	ld		r16, Y+			; Opcode
	mov		YH, TEMP
	ldi 	ZH,high(OpJumpTable) 	
	ldi 	ZL,low(OpJumpTable) 
	add 	ZL, r16 			; First add can never generate carry since 
	add		ZL, r16				; OpJumpTable starts at a page boundry
	adc		ZH, r0
	ijmp 






;*****************************************************************************
;
; BRK - Force Interrupt
;
; The BRK instruction forces the generation of an interrupt request. The 
; program counter and processor status are pushed on the stack then the 
; IRQ interrupt vector at $FFFE/F is loaded into the PC and the break
; flag in the status set to one.
;
; C	Carry Flag			-
; Z	Zero Flag			-
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		Set to 1
; V	Overflow Flag		-
; N	Negative Flag		-
;	
OP_BRK:					; *** $00 - BRK //TODO
	jmp OP_BRK
	

	
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
	jmp 	loop




;*****************************************************************************
;
; BIT - Bit Test
;
; A & M, N = M7, V = M6
;
; This instructions is used to test if one or more bits are set in a target 
; memory location. The mask pattern in A is ANDed with the value in memory to 
; set or clear the zero flag, but the result is not kept. Bits 7 and 6 of 
; the value from memory are copied into the N and V flags.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if the result if the AND is zero
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		Set to bit 6 of the memory value
; N	Negative Flag		Set to bit 7 of the memory value

OP_BIT_ZP: 				; *** $24 - BIT ZEROPAGE
	ClearZVN
	HandleZEROPAGE	
	mov		r16, CPU_ACC
	ld		r17, Z+
	sbrc	r17, 7
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	sbrc	r17, 6
	sbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	and 	r16, r17
	brne	a1
	sbr		CPU_STATUS, MASK_FLAG_ZERO
a1:	jmp loop




OP_BIT_AB:				; *** $2C - BIT ABSOLUTE
	ClearZVN
	HandleABSOLUTE
	mov		r16, CPU_ACC
	ld		r17, Z+
	sbrc	r17, 7
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	sbrc	r17, 6
	sbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	and 	r16, r17
	brne	a2
	sbr		CPU_STATUS, MASK_FLAG_ZERO
a2:	jmp loop






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
	ldi		ZH, 2		; Stack is 0x100-0x1FF on 6502. Offset this with one page for SRAM
	mov		ZL,	CPU_SP

	inc		CPU_SP		
	ld		CPU_STATUS, Z+	; POP Processor status flags

	inc		CPU_SP			; POP PC low part
	ld		CPU_PCL, Z+

	inc		CPU_SP			; POP PC high part
	ld		CPU_PCH, Z

	adiw	Y, 1			; Advance PC one byte
	jmp 	loop
	







;*****************************************************************************
;
; ADC - Add with Carry
;
; A,Z,C,N = A+M+C
;
; This instruction adds the contents of a memory location to the accumulator 
; together with the carry bit. If overflow occurs the carry bit is set, this 
; enables multiple byte addition to be performed.
;
; C	Carry Flag			Set if overflow in bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		Set if sign bit is incorrect
; N	Negative Flag		Set if bit 7 set
;

OP_ADC_IM:				; *** $69 - ADC IMMEDIATE
	ClearCZVN
	HandleIMMEDIATE
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, ZL
	UpdateNCZVjmpLoop



OP_ADC_ZP:				; *** $65 - ADC ZEROPAGE
	ClearCZVN
	HandleZEROPAGE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_ADC_ZPX:				; *** $75 - ADC ZEROPAGE,X
	ClearCZVN
	HandleZEROPAGE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_ADC_AB:				; *** $6D - ABSOLUTE
	ClearCZVN
	HandleABSOLUTE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_ADC_ABX:				; *** $7D - ADC ABSOLUTE,X
	ClearCZVN
	HandleABSOLUTE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_ADC_ABY:				; *** $79 - ADC ABSOLUTE,Y
	ClearCZVN
	HandleABSOLUTE_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_ADC_IX:				; *** $61 - ADC (INDIRECT,X)
	ClearCZVN
	HandleINDIRECT_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_ADC_IY:				; *** $71 - ADC (INDIRECT),Y
	ClearCZVN
	HandleINDIRECT_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	





;*****************************************************************************
;
; SBC - Subtract with Carry
;
; A,Z,C,N = A-M-(1-C)
;
; This instruction subtracts the contents of a memory location to the 
; accumulator together with the not of the carry bit. If overflow occurs the 
; carry bit is clear, this enables multiple byte subtraction to be performed.
;
; C	Carry Flag			Clear if overflow in bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		Set if sign bit is incorrect
; N	Negative Flag		Set if bit 7 set
;

OP_SBC_IM:				; *** $E9 - SBC IMMEDIATE
	ClearCZVN
	HandleIMMEDIATE
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, ZL
	UpdateNCZVjmpLoop


OP_SBC_ZP:				; *** $E5 - SBC ZEROPAGE
	ClearCZVN
	HandleZEROPAGE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ZPX:				; *** $F5 - SBC ZEROPAGE,X
	ClearCZVN
	HandleZEROPAGE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


OP_SBC_AB:				; *** $ED - SBC ABSOLUTE
	ClearCZVN
	HandleABSOLUTE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ABX:				; *** $FD - SBC ABSOLUTE,X
	ClearCZVN
	HandleABSOLUTE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ABY:				; *** $F9 - SBC ABSOLUTE,Y	 
	ClearCZVN
	HandleABSOLUTE_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_IX:				; *** $E1 - SBC (INDIRECT,X)
	ClearCZVN
	HandleINDIRECT_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_IY:				; *** $F1 - SBC (INDIRECT),Y
	ClearCZVN
	HandleINDIRECT_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	




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
	ClearNCZ
	HandleIMMEDIATE
	cp		CPU_ACC, ZL
	UpdateNCZjmpLoop
	



OP_CMP_ZP:				; *** $C5 - CMP ZEROPAGE
	ClearNCZ
	HandleZEROPAGE
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNCZjmpLoop



OP_CMP_ZPX:				; *** $D5 - CMP ZEROPAGE,X
	ClearNCZ
	HandleZEROPAGE_X
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNCZjmpLoop	



OP_CMP_AB:				; *** $CD - CMP ABSOLUTE
	ClearNCZ
	HandleABSOLUTE
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNCZjmpLoop	



OP_CMP_ABX:				; *** $DD - CMP ABSOLUTE,X
	ClearNCZ
	HandleABSOLUTE_X
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNCZjmpLoop	



OP_CMP_ABY:				; *** $D9 - CMP ABSOLUTE,Y
	ClearNCZ
	HandleABSOLUTE_Y
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNCZjmpLoop	



OP_CMP_IX:				; *** $C1 - CMP (INDIRECT,X)
	ClearNCZ
	HandleINDIRECT_X
	ld		r16, Z
	cp		CPU_ACC, r16
	UpdateNCZjmpLoop	



OP_CMP_IY:				; *** $D1 - CMP (INDIRECT),Y
	ClearNCZ
	HandleINDIRECT_Y
	ld		r16, Z
;	cp		CPU_ACC, r16
	cp		r16, CPU_ACC
	UpdateNCZjmpLoop	
	







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
	ClearNCZ
	HandleIMMEDIATE
	cp		CPU_X, ZL
	UpdateNCZjmpLoop



OP_CPX_ZP:				; *** $E4 - CPX ZEROPAGE
	ClearNCZ
	HandleZEROPAGE
	ld		r16, Z
	cp		CPU_X, r16
	UpdateNCZjmpLoop



OP_CPX_AB:				; *** $EC -	CPX ABSOLUTE
	ClearNCZ
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
	ClearNCZ
	HandleIMMEDIATE
	ld		r16, Z
	cp		CPU_Y, ZL
	UpdateNCZjmpLoop



OP_CPY_ZP:				; *** $C4 -	CPY ZEROAPAGE
	ClearNCZ
	HandleZEROPAGE
	ld		r16, Z
	cp		CPU_Y, r16
	UpdateNCZjmpLoop



OP_CPY_AB:				; *** $CC - CPY ABSOLUTE
	ClearNCZ
	HandleABSOLUTE
	ld		r16, Z
	cp		CPU_Y, r16
	UpdateNCZjmpLoop	
	
	


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
OP_PHA:				; ** $48 - PHA
	ldi		ZH, 2		; Stack is 0x100-0x1FF on 6502. Offset this with one page for SRAM
	mov		ZL,	CPU_SP
	st		Z, CPU_ACC
	dec		CPU_SP		
	jmp 	loop
	


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
	ldi		ZH, 2		; Stack is 0x100-0x1FF on 6502. Offset this with one page for SRAM
	mov		ZL,	CPU_SP
	st		Z, CPU_STATUS
	dec		CPU_SP		
	jmp 	loop
	



;*****************************************************************************
;
; PLA - Pull Accumulator
;
; Pulls an 8 bit value from the stack and into the accumulator. The zero 
; and negative flags are set as appropriate.
;
; C	Carry Flag			-
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of A is set
;
	
OP_PLA:					; *** $68 - PLA
	ClearNZ
	ldi		ZH, 2		; Stack is 0x100-0x1FF on 6502. Offset this with one page for SRAM
	mov		ZL,	CPU_SP
	inc		CPU_SP
	inc		ZL
	ld		CPU_ACC, Z
	UpdateNZjmpLoop


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
	ldi		ZH, 2		; Stack is 0x100-0x1FF on 6502. Offset this with one page for SRAM
	mov		ZL,	CPU_SP
	inc		CPU_SP		
	inc 	ZL
	ld		CPU_STATUS, Z
	jmp 	loop
	



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
	ld		r16, Z
	and		CPU_ACC, r16
	UpdateNZjmpLoop
	


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
	ClearNZ
	HandleZEROPAGE
	ld		r16, Z
	inc		r16
	st		Z, r16
	UpdateNZjmpLoop



OP_INC_ZPX:				; *** $F6 - INC ZEROPAEGE,X
	ClearNZ
	HandleZEROPAGE_X
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop




OP_INC_AB:				; *** $EE - INC ABSOLUTE
	ClearNZ
	HandleABSOLUTE
	ld		r16, Z
	inc		r16
	st		Z, r16
	UpdateNZjmpLoop
	



OP_INC_ABX:				; *** $FE - INC ABSOLUTE,X
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
	ClearNZ
	HandleZEROPAGE
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop



OP_DEC_ZPX:				; *** $D6 - DEC ZEROPAGE,X
	ClearNZ
	HandleZEROPAGE_X
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop



OP_DEC_AB:				; *** $CE - DEC ABSOLUTE
	ClearNZ
	HandleABSOLUTE
	ld		r16, Z
	dec		r16
	st		Z, r16
	UpdateNZjmpLoop



OP_DEC_ABX:				; *** $DE - DEC ABSOLUTE,X
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
	ClearNZ
	dec		CPU_Y
	UpdateNZjmpLoop



;*****************************************************************************
;
; ROL - Rotate Left
;
; Move each of the bits in either A or M one place to the left. Bit 0 is 
; filled with the current value of the carry flag whilst the old bit 7 
; becomes the new carry flag value.
;
;
; C	Carry Flag			Set to contents of old bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_ROL_AC:				; *** $2A - ROL
	ClearNCZ
	UpdateCarryFromCPU
	rol		CPU_ACC
	UpdateNCZjmpLoop
	



OP_ROL_ZP:				; *** $26 - ROL ZEROPAGE 
	ClearNCZ
	HandleZEROPAGE
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop
	



OP_ROL_ZPX:				; *** $36 - ROL ZEROPAGE,X 
	ClearNCZ
	HandleZEROPAGE_X
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop



OP_ROL_AB:				; *** $2E - ROL ABSOLUTE  
	ClearNCZ
	HandleABSOLUTE
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ROL_ABX:				; *** $3E - ROL ABSOLUTE,X
	ClearNCZ
	HandleABSOLUTE_X
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop
	




;*****************************************************************************
;
; ROR - Rotate Right
;
; Move each of the bits in either A or M one place to the right. Bit 7 is 
; filled with the current value of the carry flag whilst the old bit 0 
; becomes the new carry flag value.
;
; C	Carry Flag			Set to contents of old bit 0
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_ROR_AC:				; *** $6A - ROR
	ClearNCZ
	UpdateCarryFromCPU
	ror		CPU_ACC
	UpdateNCZjmpLoop
	jmp loop


OP_ROR_ZP:				; *** $66 - ROR ZEROPAGE
	ClearNCZ
	HandleZEROPAGE
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ROR_ZPX:				; *** $76 - ROR ZEROPAGE,X
	ClearNCZ
	HandleZEROPAGE_X
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop



OP_ROR_AB:				; *** $6E - ROR ABSOLUTE
	ClearNCZ
	HandleABSOLUTE
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ROR_ABX:				; *** $7E - ROR ABSOLUTE,X 
	ClearNCZ
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop
	jmp loop
	


;*****************************************************************************
;
; ASL - Arithmetic Shift Left
; 
; A,Z,C,N = M*2 or M,Z,C,N = M*2
;
; This operation shifts all the bits of the accumulator or memory contents 
; one bit left. Bit 0 is set to 0 and bit 7 is placed in the carry flag. The 
; effect of this operation is to multiply the memory contents by 2 (ignoring 
; 2's complement considerations), setting the carry if the result will not fit
; in 8 bits.
;
; C	Carry Flag			Set to contents of old bit 7
; Z	Zero Flag			Set if A = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		- 
; N	Negative Flag		Set if bit 7 of the result is set
;

OP_ASL_AC:				; *** $0A - ASL
	ClearNCZ
	lsl		CPU_ACC
	UpdateNZjmpLoop
	


OP_ASL_ZP:				; *** $06 - ASL ZEROPAGE  
	ClearNCZ
	HandleZEROPAGE
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop
	



OP_ASL_ZPX:				; *** $16 - ASL ZEROPAGE,X
	ClearNCZ
	HandleZEROPAGE_X
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop


 
OP_ASL_AB:				; *** $0E - ASL ABSOLUTE 
	ClearNCZ
	HandleABSOLUTE
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ASL_ABX:				; *** $1E - ASL ABSOLUTE,X   
	ClearNCZ
	HandleABSOLUTE_X
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


;*****************************************************************************
;
; LSR - Logical Shift Right
; 
; A,C,Z,N = A/2 or M,C,Z,N = M/2
; 
; Each of the bits in A or M is shift one place to the right. The bit that 
; was in bit 0 is shifted into the carry flag. Bit 7 is set to zero.
;
;
; C	Carry Flag			Set to contents of old bit 0
; Z	Zero Flag			Set if result = 0
; I	Interrupt Disable	-
; D	Decimal Mode Flag	-
; B	Break Command		-
; V	Overflow Flag		-
; N	Negative Flag		0

OP_LSR_AC:				; *** $4A - LSL  
	ClearNZ
	lsr		CPU_ACC
	UpdateNZjmpLoop



OP_LSR_ZP:				; *** $46 - LSR ZEROPAGE 
	ClearCZ
	HandleZEROPAGE
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	


OP_LSR_ZPX:				; *** $56 - LSR ZEROPAGE,X  
	ClearCZ
	HandleZEROPAGE_X
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	
	

OP_LSR_AB:				; *** $4E - LSR ABSOLUTE  
	ClearCZ
	HandleABSOLUTE
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	


OP_LSR_ABX:				; *** $5E LSR ABSOLUTE,X
	ClearCZ
	HandleABSOLUTE_X
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	


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
	HandleZEROPAGE
	st		Z, CPU_ACC
	jmp 	loop
	


OP_STA_ZPX:				; *** $95 - STA ZEROPAGE,X
	HandleZEROPAGE_X
	st		Z, CPU_ACC
	jmp 	loop
	


OP_STA_AB:				; *** $8D - STA ABSOLUTE
	HandleABSOLUTE
	breq	OP_STA_AB_PORT
	st		Z, CPU_ACC
	jmp 	loop
OP_STA_AB_PORT:
	nop		; // TODO


OP_STA_ABX:				; *** $9D - STA ABSOLUTE,X
	HandleABSOLUTE_X
	breq	OP_STA_ABX_PORT
	st		Z, CPU_ACC	
	jmp 	loop
OP_STA_ABX_PORT:
	nop		; // TODO
	



OP_STA_ABY:				; *** $99 - STA ABSOLUTE,Y 
	HandleABSOLUTE_Y
	breq	OP_STA_ABY_PORT
	st		Z, CPU_ACC
	jmp 	loop
OP_STA_ABY_PORT:
	nop		; // TODO
	


OP_STA_IX:				; *** $81 - STA (INDIRECT,X) 
	HandleINDIRECT_X
	breq	OP_STA_IX_PORT
	st		Z, CPU_ACC
	jmp 	loop
OP_STA_IX_PORT:
	nop		; // TODO
	



OP_STA_IY:				; *** $91 - STA (INDIRECT),Y 
	HandleINDIRECT_Y
	breq	OP_STA_IY_PORT
	st		Z, CPU_ACC
	jmp 	loop
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
	HandleZEROPAGE
	st		Z, CPU_X
	jmp 	loop
	



OP_STX_ZPY:				; *** $96 - STX ZEROPAGE,Y 
	HandleZEROPAGE_Y
	st		Z, CPU_X
	jmp 	loop
	


OP_STX_AB:				; *** $8E - STX ABSOLUTE
	HandleABSOLUTE
	breq	OP_STX_AB_PORT
	st		Z, CPU_X
	jmp 	loop
OP_STX_AB_PORT:
	cpi		ZL, 0x40	; Is Data Register A?
	brne	OP_STX_AB_PORT1
	out		PORTD, CPU_X
	jmp 	loop
OP_STX_AB_PORT1:
	cpi		ZL, 0x41	; Is Data Dir A?
	brne	OP_STX_AB_PORT2
	out		DDRD, CPU_X
	jmp		loop
OP_STX_AB_PORT2:
	cpi		ZL, 0x42	; Is Data Register B?
	brne	OP_STX_AB_PORT3
	out		PORTC, CPU_X
	jmp 	loop
OP_STX_AB_PORT3:
	cpi		ZL, 0x43	; Is Data Dir B?
	brne	OP_STX_AB_PORT4
	out		PORTC, CPU_X
	jmp 	loop
OP_STX_AB_PORT4:
	jmp		loop			




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
	HandleZEROPAGE
	st		Z, CPU_Y
	jmp 	loop
	


OP_STY_ZPX:				; *** $94 - STY ZEROPAGE,X
	HandleZEROPAGE_X
	st		Z, CPU_Y
	jmp 	loop



OP_STY_AB:				; *** $8C - STY ABSOLUTE
	HandleABSOLUTE
	breq	OP_STX_AB_PORT
	st		Z, CPU_Y
	jmp 	loop
OP_STY_AB_PORT:
	nop		; // TODO

	


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
	ClearNZ
	HandleIMMEDIATE
	mov		CPU_ACC, ZL
	UpdateNZjmpLoop
	

OP_LDA_ZP:				; *** $A5 - LDA ZEROPAGE 
	ClearNZ
	HandleZEROPAGE
	ld		CPU_ACC, Z
	UpdateNZjmpLoop
	


OP_LDA_ZPX:				; *** $B5 - LDA ZEROPAGE,X 	
	ClearNZ
	HandleZEROPAGE_X
	ld		CPU_ACC, Z
	UpdateNZjmpLoop



OP_LDA_AB:				; *** $AD - LDA ABSOLUTE  
	ClearNZ
	HandleABSOLUTE
	ld		CPU_ACC, Z
	UpdateNZjmpLoop




OP_LDA_ABX:				; *** $BD - LDA ABSOLUTE,X  
	ClearNZ
	HandleABSOLUTE_X
	ld		CPU_ACC, Z
	UpdateNZjmpLoop
	



OP_LDA_ABY:				; *** $B9 - LDA ABSOLUTE,Y  
	ClearNZ
	HandleABSOLUTE_Y
	ld		CPU_ACC, Z
	UpdateNZjmpLoop
	



OP_LDA_IX:				; *** $A1 - LDA (INDIRECT,X) 
	ClearNZ
	HandleINDIRECT_X
	ld		CPU_ACC, Z
	UpdateNZjmpLoop
	



OP_LDA_IY:				; *** $B1 - LDA (INDIRECT),Y 
	ClearNZ
	HandleINDIRECT_Y
	ld		CPU_ACC, Z
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
	ClearNZ
	HandleIMMEDIATE
	mov		CPU_X, ZL
	UpdateNZjmpLoop



OP_LDX_ZP:				; *** $A6 - LDX ZEROPAGE 
	ClearNZ
	HandleZEROPAGE
	ld		CPU_X, Z
	UpdateNZjmpLoop
	


OP_LDX_ZPY:				; *** $B6 - LDX ZEROPAGE,Y 
	ClearNZ
	HandleZEROPAGE_Y
	ld		CPU_X, Z
	UpdateNZjmpLoop
	



OP_LDX_AB:				; *** $AE - LDX ABSOLUTE 
	ClearNZ
	HandleABSOLUTE
	ld		CPU_X, Z
	UpdateNZjmpLoop
	



OP_LDX_ABY:				; *** $BE - LDX ABSOLUTE,Y 
	HandleABSOLUTE_Y
	ld		CPU_X, Z
	jmp loop
	


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
	ClearNZ
	HandleIMMEDIATE
	mov		CPU_Y, ZL
	UpdateNZjmpLoop
	



OP_LDY_ZP:				; *** $A4 - LDY ZEROPAGE
	ClearNZ
	HandleZEROPAGE
	ld		CPU_Y, Z
	UpdateNZjmpLoop
	




OP_LDY_ZPX:				; *** $B4 - LDY ZEROPAGE,X
	HandleZEROPAGE_X
	ld		CPU_Y, Z
	jmp loop
	
	


OP_LDY_AB:				; *** $AC - LDY ABSOLUTE
	ClearNZ
	HandleABSOLUTE
	ld		CPU_Y, Z
	UpdateNZjmpLoop

	

	
OP_LDY_ABX:				; *** $BC - LDY ABSOLUTE,Y	
	HandleABSOLUTE_X
	ld		CPU_Y, Z
	jmp loop
	




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
	sbr		CPU_STATUS, MASK_FLAG_CARRY
	jmp 	loop
	



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
	sbr		CPU_STATUS, MASK_FLAG_DECIMAL
	jmp 	loop
	


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
	sbr		CPU_STATUS, MASK_FLAG_INTERRUPT
	jmp 	loop
	


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
	cbr		CPU_STATUS, MASK_FLAG_CARRY
	jmp 	loop
	


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
	cbr		CPU_STATUS, MASK_FLAG_DECIMAL
	jmp 	loop
	


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
	cbr		CPU_STATUS, MASK_FLAG_INTERRUPT
	jmp 	loop
	


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
	cbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	jmp 	loop





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
	inc		YH				; Offset for SRAM
	ld		r16, Y+			; Jump address low
	ld		r17, Y+			; Jump address hi
	mov		CPU_PCL, r16
	mov		CPU_PCH, r17
	jmp 	loop
	

OP_JMP_IND:				; *** $6C - JMP (INDIRECT)
	inc		YH				; Offset for SRAM
	ld		ZL, Y+			; Jump indirect address low
	ld		ZH, Y+			; Jump indirect address hi
	inc		ZH				; Offset for SRAM
	ld		r16, Z+			; Jump address low
	ld		r17, Z+			; Jump address hi
	mov		CPU_PCL, r16
	mov		CPU_PCH, r17
	jmp 	loop


	
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
	adiw	Y, 1
	ldi		ZH, 2			; Push current PC to stack
	mov		ZL, CPU_SP
	st		Z, YH
	dec		ZL
	st		Z, YL
	dec		CPU_SP			; Update CPU stack pointer
	dec		CPU_SP
	sbiw	Y, 1

	andi	YH, 7			; Wrap for BIOS access
	inc		YH				; Offset for SRAM
	ld		r16, Y+			; Jump address low
	ld		r17, Y+			; Jump address hi
	mov		CPU_PCL, r16
	mov		CPU_PCH, r17
	jmp 	loop
	


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

OP_RTS:					; *** $20 - RTS 
	ldi		ZH, 2
	mov		ZL, CPU_SP
	inc		ZL
	ld		CPU_PCL, Z
	inc		ZL
	ld		CPU_PCH, Z
	inc		CPU_SP
	inc		CPU_SP
	adiw	Y, 1
	jmp 	loop


	

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
	HandleRELATIVE
	sbrc	CPU_STATUS, BIT_FLAG_CARRY
	jmp		loop
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
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_CARRY
	jmp		loop
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
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_ZERO
	jmp		loop
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
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_NEGATIVE
	jmp		loop
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
	HandleRELATIVE
	sbrc	CPU_STATUS, BIT_FLAG_ZERO
	jmp		loop
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
	HandleRELATIVE		; *** $10 - BPL
	sbrc	CPU_STATUS, BIT_FLAG_NEGATIVE
	jmp		loop
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
	HandleRELATIVE
	sbrc	CPU_STATUS, BIT_FLAG_OVERFLOW
	jmp		loop
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
	HandleRELATIVE
	sbrs	CPU_STATUS, BIT_FLAG_OVERFLOW
	jmp		loop
	BranchJUMP








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
	ClearNZ
	mov		CPU_ACC, CPU_Y
	UpdateNZjmpLoop
	


;
;
;
	.INCLUDE "OpCodeJumpTable.inc"
	
;
;
;
BiosFlashData:
	.INCLUDE "../bios/bios-kim1.inc"


	
	.EXIT

