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






	.align	9			; Op Code Jump table must be aligned to a page boundry
OpJumpTable: 
#include "OpCodeJumpTable.inc"
