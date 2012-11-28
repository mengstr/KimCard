#include <avr/io.h>
#include "main.h"

.global Emulate
.global PORTB_INT0_vect
.global Loop

;
; ATXMEGA32		USED FOR 
; ----------	----------------------------
; PA0 			6502 Port A0 - LED Segment A & Key matrix
; PA1 			6502 Port A1 - LED Segment B & Key matrix
; PA2 			6502 Port A2 - LED Segment C & Key matrix
; PA3 			6502 Port A3 - LED Segment D & Key matrix
; PA4 			6502 Port A4 - LED Segment E & Key matrix
; PA5 			6502 Port A5 - LED Segment F & Key matrix
; PA6 			6502 Port A6 - LED Segment G & Key matrix
; PA7						   LED Segment DP			
;
; PB0			CPU-LED
; PB1			6502 STOP button
; PB2			6502 Reset button
; PB3			6502 SST switch
; PB4 
; PB5 
; PB6 
; PB7 
;
; PC0			6502 Port - LED Digit 1 driver
; PC1			6502 Port - LED Digit 2 driver
; PC2			6502 Port - LED Digit 3 driver
; PC3			6502 Port - LED Digit 4 driver
; PC4			6502 Port - LED Digit 5 driver
; PC5			6502 Port - LED Digit 6 driver
; PC6		
; PC7
;
; PD0			6502 Port - Key Matrix
; PD1			6502 Port - Key Matrix
; PD2			6502 Port - Key Matrix
; PD3			 
; PD4			
; PD5			USBD-
; PD6			USBD+
; PD7
;
; PE0			EEPROM SDA
; PE1			EEPROM SCL
; PE2			
; PE3			
;
;
;
; MEMORY MAP - ATXMEGA SRAM
; -------------------------------------------------------------------
; 20xx KIM-1 RAM Zero page		0010 0000 / 0000 0000
; 21xx KIM-1 RAM Stack page		0010 0001 / 0000 0001
; 22xx KIM-1 RAM Code page		0010 0010 / 0000 0010
; 23xx KIM-1 RAM Code page		0010 0011 / 0000 0011
; 24xx XMEGA Heap
; 25xx
; 26xx
; 27xx
; 28xx
; 29xx
; 2Axx
; 2Bxx XMEGA Stack
; 2Cxx KIM-1 ROM Page 1Cxx		0010 1100 / 0001 1100
; 2Dxx KIM-1 ROM Page 1Dxx		0010 1101 / 0001 1101
; 2Exx KIM-1 ROM Page 1Exx		0010 1110 / 0001 1110
; 2Fxx KIM-1 ROM Page 1Fxx		0010 1111 / 0001 1111
;
;
; CONVERT KIM-1 MEMORY ADDRESS TO XMEGA SRAM ADDRESS
; -------------------------------------------------------------------
;	AND 0000 1111
;	OR  0010 0000
;
;
;
; KIM-1 MEMORY MAP									
; --------------------------------------------------
; 00xx - 0000 0000 xxxx xxxx - RAM Zero page RAM	
; 20xx - 0010 0000 xxxx xxxx
;
;
; 01xx - 0000 0001 xxxx xxxx - RAM Stack RAM		
; 21xx - 0010 0001 xxxx xxxx
;
; 02xx - 0000 0010 xxxx xxxx - RAM Code RAM			
; 22xx - 0010 0010 xxxx xxxx
;
; 03xx - 0000 0011 xxxx xxxx - RAM Code RAM			
; 23xx - 0010 0011 xxxx xxxx
;
; 1cxx - 0001 1100 xxxx xxxx - ROM RRIOT 6530 #1	
; 2cxx - 0010 1100 xxxx xxxx
;
; 1dxx - 0001 1101 xxxx xxxx - ROM RRIOT 6530 #1	
; 2dxx - 0010 1101 xxxx xxxx
;
;
; 1exx - 0001 1110 xxxx xxxx - ROM RRIOT 6530 #2	
; 2exx - 0010 1110 xxxx xxxx
;
;
; 1fxx - 0001 1111 xxxx xxxx - ROM RRIOT 6530 #2	
; 2fxx - 0010 1111 xxxx xxxx
;
;


#define BIT_BUTTON_EVENT	0
#define MASK_BUTTON_EVENT	(1<<BIT_BUTTON_EVENT)
#define BIT_BUTTON_SST	1
#define MASK_BUTTON_SST	(1<<BIT_BUTTON_SST)


;
; Y is used for CPU_PC
; Z is normally used for computed gotos and lookup tables
;

#include "macros.inc"

//
// This interrupt is setup in main.c during PORT B initialization.
// It is attached to pin change events on PB1,PB2 & PB3 (STEP, RESET & SST Switch)
// and sets a bit in the FLAGS register to signal that one of the above buttons
// have changed state making the test in the main-loop faster.
//
PORTB_INT0_vect:
	push	r16							; Save clobbered registers
	in		r16,SREG
	push	r16
	
	mov		r16,FLAGS					; Set the button event bit in FLAGS
	sbr		r16, MASK_BUTTON_EVENT
	mov		FLAGS, r16

	pop		r16							; Restore clobbered registers
	out		SREG, r16
	pop		r16
	reti


Emulate:
	PushAllRegisters					; Save all registers that's to become clobbered
			
   ; Copy the initial values for the BIOS from Flash into RAM. 
;	ldi 	ZL, lo8(BiosFlashData) 
;	ldi 	ZH, hi8(BiosFlashData) 
;	ldi 	XL, lo8(KIMROM) 
;	ldi 	XH, hi8(KIMROM) 
;	ldi 	YL, lo8(1024)				; The KIM-1 ROM is 1 KByte
;	ldi 	YH, hi8(1024)
;BiosCopyLoop: 
;	lpm 	r17, Z+ 
;	st		X+, r17 
;	sbiw 	YY,1 
;	brne 	BiosCopyLoop

ResetKim:
	ldi		CPU_PCL, lo8(KIM_RESET)	; KIM-1 Reset vector points to $1C22
	ldi		CPU_PCH, hi8(KIM_RESET)
	clr		CPU_ACC					; Initialize all register to zero
	clr		CPU_X
	clr		CPU_Y
	clr		CPU_STATUS
	clr		CPU_SP
	ldi		TEMP, lo8(KIM_INITPOINTL)
	sts		KIM_POINTL,TEMP				; Set up pointl/H as 0x0200 instead of random address
	ldi		TEMP, hi8(KIM_INITPOINTL)
	sts		KIM_POINTH, TEMP

	mov		TEMP, MASK_BUTTON_EVENT	; Fake a button event so the loop will check the state
	mov		FLAGS, TEMP				; of buttons.

	;
	; Fetch the Opcode pointed by CPU_PCL/H
	;	
Loop:
	inc		tick				; TODO remove fake "timer"

#define	DEBUG_BREAK		0x0200

#ifdef DEBUG
	;
	; Check for KIM-1 Breakpoint address
	;
	ldi		TEMP, lo8(DEBUG_BREAK)	
	cpse	CPU_PCL, TEMP
	jmp		nobreak
	ldi		TEMP, hi8(DEBUG_BREAK)
	cpse	CPU_PCH, TEMP
	jmp		nobreak
  	nop							; <--- SET DEBUGGER BREAKPOINT HERE 
nobreak:
#endif

#ifndef SIMULATOR
	sbrc	FLAGS, BIT_BUTTON_EVENT
	jmp		HandleSpecialButtons
#endif

LoopContinue:
#ifdef DEBUG
	cpi		CPU_PCH, 0x02			// Breakpoint for opcodes in $02XX-page
	brne	8f
	nop								// <<---- SET BREAKPOINT HERE 
8:	nop
#endif
	mov		SAVE, CPU_PCH
	andi	CPU_PCH, 0b00001111
	ori		CPU_PCH, 0b00100000
	ld		r16, CPU_PC 		; Opcode
	mov		CPU_PCH, SAVE
	adiw	YY, 1			; Bump PC one step, can't do that in ld r16,cp_pc
	ldi 	ZH, pm_hi8(OpJumpTable) 	
	ldi 	ZL, pm_lo8(OpJumpTable) 
	add 	ZL, r16 			; First add can never generate carry since 
	adc		ZH, ZERO
	add		ZL, r16				; OpJumpTable starts at a page boundry
	adc		ZH, ZERO
	ijmp 



HandleSpecialButtons:
	sbis	PB_IN, 2				// Check for Reset button
	jmp		ResetButtonHandler		// It is always honored

	cpi		CPU_PCH, 0x04			// Stop/Step and SST only active in pages 0x00-0x03
	brlo	7f
	jmp		LoopContinue

7:	mov		r16, FLAGS				// Turn of the button-event bit
	cbr		r16, MASK_BUTTON_EVENT
	mov		FLAGS, r16

	sbis	PB_IN, 1				// Check for Stop/Step (ST) button
	jmp		StopButtonHandler

	sbrc	FLAGS, BIT_BUTTON_SST	// Check for SST-flag set
	jmp		SSTFlagHandler		 

	sbis	PB_IN, 3				// Check for SST Switch
	jmp		SSTButtonHandler

	jmp		LoopContinue			// No buttons to handle, so let's just continue





SSTButtonHandler:
	mov		r16, FLAGS				// Turn on the button-event bit again
	sbr		r16, MASK_BUTTON_EVENT	// So the button handler will be executed at the
	mov		FLAGS, r16				//   next loop again

	mov		r16, FLAGS				// No, so set the flag for next time
	sbr		r16, MASK_BUTTON_SST	// Set the SST flag for handling next time
	mov		FLAGS, r16
	jmp		LoopContinue			// Go back and execute this instruction


SSTFlagHandler:
	mov		r16, FLAGS				// Turn on the button-event bit again
	sbr		r16, MASK_BUTTON_EVENT	// So the button handler will be executed at the
	mov		FLAGS, r16				//   next loop again

	mov		r16, FLAGS				// 
	cbr		r16, MASK_BUTTON_SST	// Clear the SST flag for handling next time
	mov		FLAGS, r16

	jmp		NMI




StopButtonHandler:
0:	call	Delay10mS			; Debounce button
	sbic	PB_IN, 1			; Are we still pressed?
	jmp		LoopContinue		; Nah, go back to regular execution again (glitch)

	ldi		TEMP, 0xff			; Turn off display
	out		PC_OUT, TEMP
1: 	call	Delay10mS			; Wait for button release
	sbis	PB_IN,1
	jmp		1b
	call	Delay10mS			; Debounce release

NMI:						; Emulate NMI: Push PCH, PCL & Status on the stack
	ldi		ZH, 0x20+1		; Stack is 0x100-0x1FF on 6502. Offset this with 0x20 pages for SRAM

	mov		ZL,	CPU_SP		; Push 6502 PCH on stack
	st		Z, CPU_PCH
	dec		CPU_SP		

	mov		ZL,	CPU_SP		; Push 6502 PCL on stack
	st		Z, CPU_PCL
	dec		CPU_SP		

	mov		ZL,	CPU_SP		; Push 6502 Status on stack
	st		Z, CPU_STATUS
	dec		CPU_SP		

	ldi		CPU_PCL, lo8(KIM_NMI)	; KIM-1 NMI vector points to $1C00
	ldi		CPU_PCH, hi8(KIM_NMI)
	jmp		Loop



ResetButtonHandler:
	call	Delay10mS			; Debounce button
	sbic	PB_IN, 2			; Are we still pressed?
	jmp		LoopContinue		; Nah, go back to regular execution again
	ldi		TEMP, 0xff			; Turn off display
	out		PC_OUT, TEMP
	ldi		TEMP,100			; Long press (1000 mS) = back to C-code
0:
	call	Delay10mS
	dec		TEMP
	brne	1f
	PopAllRegisters
	ret							; And go back to the main C-code
1:
	sbis	PB_IN, 2			; Are we still pressed?
	jmp		0b
	jmp		ResetKim



.func Delay10mS
Delay10mS:
	ldi 	ZH, 0x60 	
	ldi 	ZL, 0x00 
d10ms0:
	jmp		d10ms1
d10ms1:
	jmp		d10ms2
d10ms2:
	jmp		d10ms3
d10ms3:
	sbiw	ZL,1
	brne	d10ms0
	ret
.endfunc




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
	ret
	jmp OP_BRK
	




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
a1:	jmp Loop




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
a2:	jmp Loop






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
	ldi		ZH, 0x20+1		; Stack is 0x100-0x1FF on 6502. Offset this with 0x20 pages for SRAM
	mov		ZL,	CPU_SP
	inc		CPU_SP
	inc		ZL
	ld		CPU_ACC, Z
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
	UpdateCarryFromCPU
	rol		CPU_ACC
	UpdateNCZjmpLoop
	



OP_ROL_ZP:				; *** $26 - ROL ZEROPAGE 
	HandleZEROPAGE
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop
	



OP_ROL_ZPX:				; *** $36 - ROL ZEROPAGE,X 
	HandleZEROPAGE_X
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop



OP_ROL_AB:				; *** $2E - ROL ABSOLUTE  
	HandleABSOLUTE
	UpdateCarryFromCPU
	ld		r16, Z
	rol		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ROL_ABX:				; *** $3E - ROL ABSOLUTE,X
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
	UpdateCarryFromCPU
	ror		CPU_ACC
	UpdateNCZjmpLoop
	jmp Loop


OP_ROR_ZP:				; *** $66 - ROR ZEROPAGE
	HandleZEROPAGE
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ROR_ZPX:				; *** $76 - ROR ZEROPAGE,X
	HandleZEROPAGE_X
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop



OP_ROR_AB:				; *** $6E - ROR ABSOLUTE
	HandleABSOLUTE
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ROR_ABX:				; *** $7E - ROR ABSOLUTE,X 
	UpdateCarryFromCPU
	ld		r16, Z
	ror		r16
	st		Z, r16
	UpdateNCZjmpLoop
	jmp Loop
	


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
	lsl		CPU_ACC
	UpdateNCZjmpLoop
	


OP_ASL_ZP:				; *** $06 - ASL ZEROPAGE  
	HandleZEROPAGE
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop
	



OP_ASL_ZPX:				; *** $16 - ASL ZEROPAGE,X
	HandleZEROPAGE_X
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop


 
OP_ASL_AB:				; *** $0E - ASL ABSOLUTE 
	HandleABSOLUTE
	ld		r16, Z
	lsl		r16
	st		Z, r16
	UpdateNCZjmpLoop
	


OP_ASL_ABX:				; *** $1E - ASL ABSOLUTE,X   
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
	HandleZEROPAGE
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	


OP_LSR_ZPX:				; *** $56 - LSR ZEROPAGE,X  
	HandleZEROPAGE_X
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	
	

OP_LSR_AB:				; *** $4E - LSR ABSOLUTE  
	HandleABSOLUTE
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	


OP_LSR_ABX:				; *** $5E LSR ABSOLUTE,X
	HandleABSOLUTE_X
	ld		r16, Z
	lsr		r16
	st		Z, r16
	UpdateCZjmpLoop
	




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
	




	.align	9			; Op Code Jump table must be aligned to a page boundrym
OpJumpTable: 
#include "OpCodeJumpTable.inc"


