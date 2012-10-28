#include <avr/io.h>
#include "main.h"

.global Emulate
.global PORTB_INT0_vect


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

	.equ	BIT_FLAG_CARRY		, 0
	.equ	BIT_FLAG_ZERO		, 1
	.equ	BIT_FLAG_INTERRUPT	, 2
	.equ	BIT_FLAG_DECIMAL	, 3
	.equ	BIT_FLAG_BREAK		, 4
	.equ	BIT_FLAG_UNUSED		, 5
	.equ	BIT_FLAG_OVERFLOW	, 6
	.equ	BIT_FLAG_NEGATIVE	, 7

	.equ	MASK_FLAG_CARRY		, (1<<BIT_FLAG_CARRY)
	.equ	MASK_FLAG_ZERO		, (1<<BIT_FLAG_ZERO)
	.equ	MASK_FLAG_INTERRUPT	, (1<<BIT_FLAG_INTERRUPT)
	.equ	MASK_FLAG_DECIMAL	, (1<<BIT_FLAG_DECIMAL)
	.equ	MASK_FLAG_BREAK		, (1<<BIT_FLAG_BREAK)
	.equ	MASK_FLAG_UNUSED	, (1<<BIT_FLAG_UNUSED)
	.equ	MASK_FLAG_OVERFLOW	, (1<<BIT_FLAG_OVERFLOW)
	.equ	MASK_FLAG_NEGATIVE	, (1<<BIT_FLAG_NEGATIVE)


	.equ	PA_DIR,	0x10
	.equ	PA_OUT,	0x11
	.equ	PA_IN,	0x12

	.equ	PB_DIR,	0x14
	.equ	PB_OUT,	0x15
	.equ	PB_IN,	0x16

	.equ	PC_DIR,	0x18
	.equ	PC_OUT,	0x19
	.equ	PC_IN,	0x1A

	.equ	PD_DIR,	0x1C
	.equ	PD_OUT,	0x1D
	.equ	PD_IN,	0x1E



#define	tick			r25


#define		XX			r26
#define		YY			r28
#define		ZZ			r30

#define CPU_ACC			r19
#define CPU_X			r20
#define CPU_Y			r21
#define CPU_STATUS		r22

#define CPU_PC			Y
#define	CPU_PCH			YH
#define CPU_PCL			YL


#define SAVE			r0				// Used for saving orginal address when mapping kim<->avr memory spaces
#define	ZERO			r1				// Always set to 0x00 by gcc
#define CPU_SP			r2				// 6502 stack pointer
#define FLAGS			r3				// Bit 0 set by Button ISR
//#define xxx			r4
//#define xxx			r5
//#define xxx			r6
//#define xxx			r7
//#define xxx			r8
//#define xxx			r9
//#define xxx			r10
//#define xxx			r11
//#define xxx			r12
//#define xxx			r13
//#define xxx			r14
//#define xxx			r15
#define TEMP			r16
//#define xxx			r17
//#define xxx			r18
//#define xxx			r19
//#define xxx			r20
//#define xxx			r21
//#define xxx			r22
//#define xxx			r23
//#define xxx			r24
//#define xxx			r25
//#define xxx			r26			// XL
//#define xxx			r27			// XH
//#define xxx			r28			// YL
//#define xxx			r29			// YH
//#define xxx			r30			// ZL
//#define xxx			r31			// ZH



;
; Y is used for CPU_PC
; Z is normally used for computed gotos and lookup tables
;

#define KIMRAM			0x2000
#define KIMROM			0x2C00

#define	KIM_INITPOINTL	0x0200

#define KIM_RESET		0x1C22
#define KIM_NMI			0x1C00

#define KIM_POINTL		(KIMRAM+0xfa)
#define KIM_POINTH		(KIMRAM+0xfb)
#define KIM_RIOTPAGE	hi8(0x1700+KIMRAM)
#define KIM_SAD			0x1740
#define KIM_PADD		0x1741
#define KIM_SBD			0x1742
#define KIM_PBDD		0x1743



#include "macros.inc"


//
// This interrupt is setup in main.c during PORT B initialization.
// It is attached to pin change events on PB1,PB2 & PB3 (STEP, RESET & SST Switch)
// and sets a bit in the FLAGS register to signal that one of the above buttons
// have changed state making the test in the main-loop faster.
//
PORTB_INT0_vect:
	push	r16							; Save clobbered reisters
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
	ldi 	ZL, lo8(BiosFlashData) 
	ldi 	ZH, hi8(BiosFlashData) 
	ldi 	XL, lo8(KIMROM) 
	ldi 	XH, hi8(KIMROM) 
	ldi 	YL, lo8(1024)				; The KIM-1 ROM is 1 KByte
	ldi 	YH, hi8(1024)
BiosCopyLoop: 
	lpm 	r17, Z+ 
	st		X+, r17 
	sbiw 	YY,1 
	brne 	BiosCopyLoop

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

	mov		ZL,	CPU_SP
	st		Z, CPU_PCH
	dec		CPU_SP		

	mov		ZL,	CPU_SP
	st		Z, CPU_PCL
	dec		CPU_SP		

	mov		ZL,	CPU_SP
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
	ret			; And go back to the main C-code
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



#include "opcodes.inc"



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
.func OP_BRK
OP_BRK:					; *** $00 - BRK //TODO
	ret
	jmp OP_BRK
.endfunc	
	




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
; ADC - Add with Carry
;
; A,Z,C,N = A+M+C
;
; This instruction adds the contents of a memory location to the accumulator 
; together with the carry bit. If overflow occurs the carry bit is set, this 
; enables multiple byte addition to be performed.
;
; NOTE: These instructions are affected by the Decimal Mode Flag
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
						; TODO : Handle Decimal Mode
	HandleIMMEDIATE
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_IM_DECIMAL
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, ZL
	UpdateNCZVjmpLoop

ADC_IM_DECIMAL:
	// Split CPU_ACC into nybbles in r17(H) and r16(L)
	mov		r16,CPU_ACC
	andi	r16,0x0f
	mov		r17,CPU_ACC
	swap	r17
	andi	r17,0x0f

	// Split ZL into nybbles in r13(H) and r26(L)
	mov		r26,ZL
	andi	r26,0x0f
	mov		r27,ZL
	swap	r27
	andi	r27,0x0f

	// Add low nybbles and carry into r10
	clc
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		r16,r26

	// Test if result > 9
	cpi		r16,10
	brmi	ADC_IM_DECIMAL_NoCarryOnLowNybble
	// If result>9 then subtract 10
	subi	r16,10
	// Add high nybbles plus 1 for carry
	sec
	adc		r17,r27
	// Test if result > 9
	cpi		r17,10
	brmi	ADC_IM_DECIMAL_NoCarryOnHighNybble
	// If result>9 then subtract 10
	subi	r17,10
ADC_IM_DECIMAL_NoCarryOnHighNybble:
	// Combine hi and lo nybbles into CPU_ACC again
	swap	r17
	or		r17,r16
	mov		CPU_ACC, r17
	tst		CPU_ACC
	UpdateNCZVjmpLoop


ADC_IM_DECIMAL_NoCarryOnLowNybble:
	// Add high nybbles
	clc
	adc		r17,r13
	// Test if result > 9
	cpi		r17,10
	brmi	ADC_IM_DECIMAL_NoCarryOnHighNybble2
	// If result>9 then subtract 10
	subi	r17,10
ADC_IM_DECIMAL_NoCarryOnHighNybble2:
	// Combine hi and lo nybbles into CPU_ACC again
	swap	r17
	or		r17,r16
	mov		CPU_ACC, r17
	tst		CPU_ACC
	UpdateNCZVjmpLoop

;
;LUNAR LANDER DECIMAL MODES
;--------------------------
;$75 ADC ZP,X
;$E9 SBC #
;$69 ADC #
;$E5 SBC ZP
;
;
;


;
;T1=NL1+NL2+C
;IF T1>9 THEN 
;	T1=T1-10
;	T2=NH1+NH2+1
;	IF T2>9 THEN T2=T2-10
;	R=T2*16+T1
;ELSE
;	T2=NH1+NH2
;	IF T2>9 THEN T2=T2-10
;	R=T2*16+T1
;




OP_ADC_ZP:				; *** $65 - ADC ZEROPAGE
						; TODO : Handle Decimal Mode
	HandleZEROPAGE
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ZP_DECIMAL

	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_ZP_DECIMAL:  // TODO
	

OP_ADC_ZPX:				; *** $75 - ADC ZEROPAGE,X
						; TODO : Handle Decimal Mode
	HandleZEROPAGE_X
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ZP_X_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_ZP_X_DECIMAL: //TODO	

OP_ADC_AB:				; *** $6D - ABSOLUTE
						; TODO : Handle Decimal Mode
	HandleABSOLUTE
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_AB_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_AB_DECIMAL: 	// TODO

OP_ADC_ABX:				; *** $7D - ADC ABSOLUTE,X
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_X
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ABX_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	
ADC_ABX_DECIMAL:  //TODO



OP_ADC_ABY:				; *** $79 - ADC ABSOLUTE,Y
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_Y
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_ABY_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_ABY_DECIMAL:	// TODO


OP_ADC_IX:				; *** $61 - ADC (INDIRECT,X)
						; TODO : Handle Decimal Mode
	HandleINDIRECT_X
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_IX_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop

ADC_IX_DECIMAL: //TODO	

OP_ADC_IY:				; *** $71 - ADC (INDIRECT),Y
						; TODO : Handle Decimal Mode
	HandleINDIRECT_Y
	sbrc	CPU_STATUS, BIT_FLAG_DECIMAL
	jmp		ADC_IY_DECIMAL
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	adc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	
ADC_IY_DECIMAL: //TODO




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
; NOTE: These instructions are affected by the Decimal Mode Flag
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
						; TODO : Handle Decimal Mode
	HandleIMMEDIATE
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, ZL
	UpdateNCZVjmpLoop


OP_SBC_ZP:				; *** $E5 - SBC ZEROPAGE
						; TODO : Handle Decimal Mode
	HandleZEROPAGE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ZPX:				; *** $F5 - SBC ZEROPAGE,X
						; TODO : Handle Decimal Mode
	HandleZEROPAGE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop


OP_SBC_AB:				; *** $ED - SBC ABSOLUTE
						; TODO : Handle Decimal Mode
	HandleABSOLUTE
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ABX:				; *** $FD - SBC ABSOLUTE,X
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_ABY:				; *** $F9 - SBC ABSOLUTE,Y	 
						; TODO : Handle Decimal Mode
	HandleABSOLUTE_Y
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_IX:				; *** $E1 - SBC (INDIRECT,X)
						; TODO : Handle Decimal Mode
	HandleINDIRECT_X
	ld		r16, Z
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
	sbc		CPU_ACC, r16
	UpdateNCZVjmpLoop
	

OP_SBC_IY:				; *** $F1 - SBC (INDIRECT),Y
						; TODO : Handle Decimal Mode
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
	jmp 	Loop
	


OP_STA_ZPX:				; *** $95 - STA ZEROPAGE,X
	HandleZEROPAGE_X
	st		Z, CPU_ACC
	jmp 	Loop
	


OP_STA_AB:				; *** $8D - STA ABSOLUTE
#ifdef DEBUG
	nop
#endif
	HandleABSOLUTE
	StoreAbsolute CPU_ACC


OP_STA_ABX:				; *** $9D - STA ABSOLUTE,X
	HandleABSOLUTE_X
	breq	OP_STA_ABX_PORT
	st		Z, CPU_ACC	
	jmp 	Loop
OP_STA_ABX_PORT:
	nop		; // TODO
	



OP_STA_ABY:				; *** $99 - STA ABSOLUTE,Y 
	HandleABSOLUTE_Y
	breq	OP_STA_ABY_PORT
	st		Z, CPU_ACC
	jmp 	Loop
OP_STA_ABY_PORT:
	nop		; // TODO
	


OP_STA_IX:				; *** $81 - STA (INDIRECT,X) 
	HandleINDIRECT_X
	breq	OP_STA_IX_PORT
	st		Z, CPU_ACC
	jmp 	Loop
OP_STA_IX_PORT:
	nop		; // TODO
	



OP_STA_IY:				; *** $91 - STA (INDIRECT),Y 
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
	HandleZEROPAGE
	st		Z, CPU_X
	jmp 	Loop
	



OP_STX_ZPY:				; *** $96 - STX ZEROPAGE,Y 
	HandleZEROPAGE_Y
	st		Z, CPU_X
	jmp 	Loop
	


OP_STX_AB:				; *** $8E - STX ABSOLUTE
	nop
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
	HandleZEROPAGE
	st		Z, CPU_Y
	jmp 	Loop
	


OP_STY_ZPX:				; *** $94 - STY ZEROPAGE,X
	HandleZEROPAGE_X
	st		Z, CPU_Y
	jmp 	Loop



OP_STY_AB:				; *** $8C - STY ABSOLUTE
	HandleABSOLUTE
	StoreAbsolute CPU_Y


	


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
	

OP_LDA_ZP:				; *** $A5 - LDA ZEROPAGE 
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleZEROPAGE
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop
	


OP_LDA_ZPX:				; *** $B5 - LDA ZEROPAGE,X 	
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleZEROPAGE_X
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop



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





OP_LDA_ABX:				; *** $BD - LDA ABSOLUTE,X  
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleABSOLUTE_X
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop
	



OP_LDA_ABY:				; *** $B9 - LDA ABSOLUTE,Y 
#ifdef DEBUG
	nop
#endif 
	ClearNZ
	HandleABSOLUTE_Y
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop
	



OP_LDA_IX:				; *** $A1 - LDA (INDIRECT,X) 
#ifdef DEBUG
	nop
#endif
	ClearNZ
	HandleINDIRECT_X
	ld		CPU_ACC, Z
	tst		CPU_ACC
	UpdateNZjmpLoop
	



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
	ClearNZ
	HandleIMMEDIATE
	mov		CPU_X, ZL
	tst		CPU_X
	UpdateNZjmpLoop



OP_LDX_ZP:				; *** $A6 - LDX ZEROPAGE 
	ClearNZ
	HandleZEROPAGE
	ld		CPU_X, Z
	tst		CPU_X
	UpdateNZjmpLoop
	


OP_LDX_ZPY:				; *** $B6 - LDX ZEROPAGE,Y 
	ClearNZ
	HandleZEROPAGE_Y
	ld		CPU_X, Z
	tst		CPU_X
	UpdateNZjmpLoop
	



OP_LDX_AB:				; *** $AE - LDX ABSOLUTE 
	ClearNZ
	HandleABSOLUTE
	ld		CPU_X, Z
	tst		CPU_X
	UpdateNZjmpLoop
	



OP_LDX_ABY:				; *** $BE - LDX ABSOLUTE,Y 
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
	



OP_LDY_ZP:				; *** $A4 - LDY ZEROPAGE
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleZEROPAGE
	ld		CPU_Y, Z
	tst		CPU_Y
	UpdateNZjmpLoop
	




OP_LDY_ZPX:				; *** $B4 - LDY ZEROPAGE,X
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleZEROPAGE_X
	ld		CPU_Y, Z
	tst		CPU_Y
	UpdateNZjmpLoop
	
	


OP_LDY_AB:				; *** $AC - LDY ABSOLUTE
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleABSOLUTE
	ld		CPU_Y, Z
	tst		CPU_Y
	UpdateNZjmpLoop

	

	
OP_LDY_ABX:				; *** $BC - LDY ABSOLUTE,Y	
#ifdef DEBUG	
	nop
#endif
	ClearNZ
	HandleABSOLUTE_X
	ld		CPU_Y, Z
	UpdateNZjmpLoop
	




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
	jmp 	Loop
	



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
	jmp 	Loop
	


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
	jmp 	Loop
	


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
	jmp 	Loop
	


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
	jmp 	Loop
	


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
	jmp 	Loop
	


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
	jmp 	Loop





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
	jmp		Loop
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
	jmp		Loop
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
	jmp		Loop
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
	jmp		Loop
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
	jmp		Loop
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
	jmp		Loop
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
	jmp		Loop
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
	jmp		Loop
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
	


	.align	9			; Op Code Jump table must be aligned to a page boundry
OpJumpTable: 
#include "OpCodeJumpTable.inc"


BiosFlashData:
#include "kim1-bios.inc"
