.NOLIST
.INCLUDE "m644adef.inc"
.LIST
.LISTMAC 

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
;
;
;
;
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

.equ	Bios			= 0x0500
.equ	AVRSTACK		= 0x06C3	; A large unused area in the 6502 BIOS is 
									; used as the AVE stack pointer


.NOLIST

.MACRO HandleABSOLUTE
	mov		TEMP, YH
	andi	YH, 7			; Wrap addresspace to get access to BIOS at 0x1C00-0x1FFF as 0x0400
	inc		YH
	ld		ZL, Y+			; Absolute Address (low)
	ld		ZH, Y+			; Absolute Address (high)
	inc		ZH				; Offset for SRAM
	mov		YH, TEMP
	cpi		ZH, 0x18		; Set Zero-flag if we're accessing the ports
.ENDMACRO



.MACRO HandleABSOLUTE_X
	inc		YH
	ld		ZL, Y+			; Absolute Address (low)
	ld		ZH, Y+			; Absolute Address (high)
	inc		ZH				; Offset for SRAM
	add		ZL, CPU_X		; Add X-register to address
	adc		ZH, r0			; r0 is always zero
	dec		YH
	cpi		ZH, 0x18		; Set Zero-flag if we're accessing the ports
.ENDMACRO




.MACRO HandleABSOLUTE_Y
	inc		YH
	ld		ZL, Y+			; Absolute Address (low)
	ld		ZH, Y+			; Absolute Address (high)
	inc		ZH				; Offset for SRAM
	add		ZL, CPU_Y		; Add Y-register to address
	adc		ZH, r0			; r0 is always zero
	dec		YH
	cpi		ZH, 0x18		; Set Zero-flag if we're accessing the ports
.ENDMACRO




.MACRO HandleZEROPAGE
	inc		YH
	ld		ZL, Y+			; ZP Address (low)
	ldi		ZH, 1			; Offset for SRAM (high)
	dec		YH
.ENDMACRO





.MACRO HandleZEROPAGE_X
	inc		YH
	ld		ZL, Y+			; ZP Address
	add		ZL, CPU_X
	ldi		ZH, 1			; SRAM offset
	dec		YH
.ENDMACRO




.MACRO HandleZEROPAGE_Y
	inc		YH
	ld		ZL, Y+			; ZP Address
	add		ZL, CPU_Y
	ldi		ZH, 1			; SRAM offset
	dec		YH
.ENDMACRO




.MACRO HandleIMMEDIATE
	inc		YH
	ld		ZL, Y+			
	dec		YH
.ENDMACRO




.MACRO HandleRelative
	inc		YH
	ld		r16, Y+			; Get offset
	dec		YH
.ENDMACRO




.MACRO HandleINDIRECT_X
	inc		YH
	ld		XL, Y+			; Address (low)
	ldi		XH, 1			; Address (high) Ofsetted for SRAM
	add		XL, CPU_X		; Add X-register to address
	adc		XH, r0			; r0 is always zero
	dec		YH
	ld		ZL, X+
	ld		ZH, X+
	inc		ZH	 			; Offset for SRAM
	cpi		ZH, 0x18		; Set Zero-flag if we're accessing the ports
.ENDMACRO




.MACRO HandleINDIRECT_Y
	inc		YH
	ld		XL, Y+			; Address (low)
	ldi		XH, 1			; Address (high) ofgstted for SRAM
	dec		YH
	ld		ZL, X+
	ld		ZH, X+
	add		ZL, CPU_Y		; Add Y-register to address
	adc		ZH, r0			; r0 is always zero
	inc		ZH	 			; Offset for SRAM
	cpi		ZH, 0x18		; Set Zero-flag if we're accessing the ports
.ENDMACRO




.MACRO 	ClearNZ
	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	cbr		CPU_STATUS, MASK_FLAG_ZERO
.ENDMACRO



.MACRO 	ClearCZ
	cbr		CPU_STATUS, MASK_FLAG_CARRY
	cbr		CPU_STATUS, MASK_FLAG_ZERO
.ENDMACRO



.MACRO 	ClearNCZ
	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	cbr		CPU_STATUS, MASK_FLAG_CARRY
	cbr		CPU_STATUS, MASK_FLAG_ZERO
.ENDMACRO



.MACRO	ClearZVN
	cbr		CPU_STATUS, MASK_FLAG_ZERO
	cbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
.ENDMACRO



.MACRO	ClearCZVN
	cbr		CPU_STATUS, MASK_FLAG_CARRY
	cbr		CPU_STATUS, MASK_FLAG_ZERO
	cbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
.ENDMACRO



.MACRO 	UpdateNZjmpLoop
	brne	NotZero
	; Zero flag is set in AVR, we don't need to check for Negative
	sbr		CPU_STATUS, MASK_FLAG_ZERO
	jmp 	loop
NotZero:
	brpl	IsPositive
	; Negative flag set in AVR
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE
IsPositive:
	jmp loop
.ENDMACRO



.MACRO 	UpdateCZjmpLoop	
	brcc	NoCarry
	; Carry flag is set in AVR
	sbr		CPU_STATUS, MASK_FLAG_CARRY
NoCarry:
	brne	NotZero
	; Zero flag is set in AVR
	sbr		CPU_STATUS, MASK_FLAG_ZERO	
NotZero:
	jmp loop
.ENDMACRO



.MACRO 	UpdateNCZjmpLoop
	brcc	NoCarry
	; Carry flag is set in AVR
	sbr		CPU_STATUS, MASK_FLAG_CARRY
NoCarry:
	brne	NotZero
	; Zero flag is set in AVR, we don't need to check for Negative
	sbr		CPU_STATUS, MASK_FLAG_ZERO	
	jmp loop
NotZero:
	brpl	IsPositive
	; Negative flag set in AVR
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE
IsPositive:
	jmp loop
.ENDMACRO



.MACRO 	UpdateNCZVjmpLoop
	; TODO Handle Overflow
	brcc	NoCarry
	; Carry flag is set in AVR
	sbr		CPU_STATUS, MASK_FLAG_CARRY
NoCarry:
	brne	NotZero
	; Zero flag is set in AVR, we don't need to check for Negative
	sbr		CPU_STATUS, MASK_FLAG_ZERO	
	jmp loop
NotZero:
	brpl	IsPositive
	; Negative flag set in AVR
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE
IsPositive:
	jmp loop
.ENDMACRO



.MACRO UpdateCarryFromCPU
	clc
	sbrc	CPU_STATUS, MASK_FLAG_CARRY
	sec
.ENDMACRO


.MACRO BranchJUMP
	sbrc	r16, 7		; Is offset negative?
	rjmp	negative
	add		CPU_PCL, r16
	adc		CPU_PCH, r0
	jmp 	loop
negative:
	com		r16
	inc		r16
	sub		CPU_PCL, r16
	sbc		CPU_PCH, r0
	jmp		loop	
.ENDMACRO	



.LIST




	.CSEG
	.ORG 0x0000



	jmp		V_RESET			; Reset Handler
	jmp		V_EXT_INT0		; IRQ0 Handler
	jmp		V_EXT_INT1		; IRQ1 Handler
	jmp		V_PCINT0			; PCINT0 Handler
	jmp		V_PCINT1			; PCINT1 Handler
	jmp		V_PCINT2			; PCINT2 Handler
	jmp		V_WDT				; Watchdog Timer Handler
	jmp		V_TIM2_COMPA		; Timer2 Compare A Handler
	jmp		V_TIM2_COMPB		; Timer2 Compare B Handler
	jmp		V_TIM2_OVF		; Timer2 Overflow Handler
	jmp		V_TIM1_CAPT		; Timer1 Capture Handler
	jmp		V_TIM1_COMPA		; Timer1 Compare A Handler
	jmp		V_TIM1_COMPB		; Timer1 Compare B Handler
	jmp		V_TIM1_OVF		; Timer1 Overflow Handler
	jmp		V_TIM0_COMPA		; Timer0 Compare A Handler
	jmp		V_TIM0_COMPB		; Timer0 Compare B Handler
	jmp		V_TIM0_OVF		; Timer0 Overflow Handler
	jmp		V_SPI_STC			; SPI Transfer Complete Handler
	jmp		V_USART_RXC		; USART, RX Complete Handler
	jmp		V_USART_UDRE		; USART, UDR Empty Handler
	jmp		V_USART_TXC		; USART, TX Complete Handler
	jmp		V_ADC				; ADC Conversion Complete Handler
	jmp		V_EE_RDY			; EEPROM Ready Handler
	jmp		V_ANA_COMP		; Analog Comparator Handler
	jmp		V_TWI				; 2-wire Serial Interface Handler
	jmp		V_SPM_RDY			; Store Program Memory Ready Handler


V_EXT_INT0:					; IRQ0 Handler
	reti

V_EXT_INT1:					; IRQ1 Handler
	reti

V_PCINT0:					; PCINT0 Handler
	reti

V_PCINT1:					; PCINT1 Handler
	reti

V_PCINT2:					; PCINT2 Handler
	reti

V_WDT:						; Watchdog Timer Handler
	reti

V_TIM2_COMPA:				; Timer2 Compare A Handler
	reti

V_TIM2_COMPB:					; Timer2 Compare B Handler
	reti

V_TIM2_OVF:					; Timer2 Overflow Handler
	reti

V_TIM1_CAPT:				; Timer1 Capture Handler
	reti

V_TIM1_COMPA:				; Timer1 Compare A Handler
	reti

V_TIM1_COMPB:				; Timer1 Compare B Handler
	reti

V_TIM1_OVF:					; Timer1 Overflow Handler
	reti

V_TIM0_COMPA:				; Timer0 Compare A Handler
	reti

V_TIM0_COMPB:				; Timer0 Compare B Handler
	reti

V_TIM0_OVF:					; Timer0 Overflow Handler
	reti

V_SPI_STC:					; SPI Transfer Complete Handler
	reti

V_USART_RXC:				; USART, RX Complete Handler
	reti

V_USART_UDRE:				; USART, UDR Empty Handler
	reti

V_USART_TXC:				; USART, TX Complete Handler
	reti

V_ADC:						; ADC Conversion Complete Handler
	reti

V_EE_RDY:					; EEPROM Ready Handler
	reti

V_ANA_COMP:					; Analog Comparator Handler
	reti

V_TWI:						; 2-wire Serial Interface Handler
	reti

V_SPM_RDY:					; Store Program Memory Ready Handler
	reti


dely:
; ============================= 
;    delay loop generator 
;     20000000 cycles:
; ----------------------------- 
; delaying 19999992 cycles:
          ldi  R17, $10
WGLOOP0:  ldi  R18, $A7
WGLOOP1:  ldi  R19, $D0
WGLOOP2:  dec  R19
          brne WGLOOP2
          dec  R18
          brne WGLOOP1
          dec  R17
          brne WGLOOP0
; ----------------------------- 
; delaying 6 cycles:
          ldi  R17, $02
WGLOOP3:  dec  R17
          brne WGLOOP3
; ----------------------------- 
; delaying 2 cycles:
          nop
          nop
; ============================= 


	ret



V_RESET:
	cli	
	ldi		r16,LOW(AVRSTACK) ;Initiate Stackpointer
	out		SPL,r16
	ldi		r16,HIGH(AVRSTACK)
	out		SPH,r16

	ldi		r16,0xff
	out		DDRD, r16

	ldi		r16, 0x3F
	out		DDRC, r16


fooloop:
	ldi		r16,0b11111110
	out		PORTD, r16
	ldi		r16,1
	out		PORTC, r16
	call	dely
	ldi		r16,0
	out		PORTC, r16


	ldi		r16,0b11111101
	out		PORTD, r16
	ldi		r16,2
	out		PORTC, r16
	call	dely
	ldi		r16,0
	out		PORTC, r16


	ldi		r16,0b11111011
	out		PORTD, r16
	ldi		r16,4
	out		PORTC, r16
	call	dely
	ldi		r16,0
	out		PORTC, r16

	ldi		r16,0b11110111
	out		PORTD, r16
	ldi		r16,8
	out		PORTC, r16
	call	dely
	ldi		r16,0
	out		PORTC, r16

	ldi		r16,0b11101111
	out		PORTD, r16
	ldi		r16,16
	out		PORTC, r16
	call	dely
	ldi		r16,0
	out		PORTC, r16

	ldi		r16,0b11011111
	out		PORTD, r16
	ldi		r16,32
	out		PORTC, r16
	call	dely
	ldi		r16,0
	out		PORTC, r16

	jmp fooloop











	clr		r0				; r0 is set permanently to 0 for 16-bit additions

   ; Copy the initial values for the coefficient table from Flash into RAM. 
	ldi 	ZH, high(BiosFlashData<< 1) 
	ldi 	ZL, low(BiosFlashData<< 1) 
	ldi 	XH, high(Bios) 
	ldi 	XL, low(Bios) 
	ldi 	YL, low(1024)
	ldi 	YH, high(1024)
CBFF_Loop: 
	lpm 	r17, Z+ 
	st X+, 	r17 
	sbiw 	Y,1 
	brne 	CBFF_Loop

	ldi		CPU_PCL, 0x4f	; KIM-1 BIOS starts at $1c4f
	ldi		CPU_PCH, 0x1c
	ldi		CPU_ACC, 0		; Initialize all register to zero
	ldi		CPU_X, 0
	ldi		CPU_Y, 0
	ldi		CPU_STATUS, 0
	ldi		CPU_SP, 0

loop:
	mov		TEMP, YH
	andi	YH, 7			; Wrap addresspace to get access to BIOS at 0x1C00-0x1FFF as 0x0400
	inc		YH				; Bump up one page for SRAM
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
	




;-----------------------------------------------------------------------------
;
; Start of tables - Align PC to a page boundry
;
;-----------------------------------------------------------------------------

	.ORG ((PC>>8)+1)<<8

OpJumpTable: 
	jmp		OP_BRK		; 00 BRK
	jmp		OP_ORA_IX	; 01 ORA - (Indirect,X)
	jmp		OP_NOP		; 02 
	jmp		OP_NOP		; 03 
	jmp		OP_NOP		; 04 
	jmp		OP_ORA_ZP	; 05 ORA - Zero Page
	jmp		OP_ASL_ZP	; 06 ASL - Zero Page
	jmp		OP_NOP		; 07 
	jmp		OP_PHP		; 08 PHP
	jmp		OP_ORA_IM	; 09 ORA - Immediate
	jmp		OP_ASL_AC	; 0A ASL - Accumulator
	jmp		OP_NOP		; 0B 
	jmp		OP_NOP		; 0C 
	jmp		OP_ORA_AB	; 0D ORA - Absolute
	jmp		OP_ASL_AB	; 0E ASL - Absolute
	jmp		OP_NOP		; 0F 
	jmp		OP_BPL		; 10 BPL
	jmp		OP_ORA_IY	; 	11 ORA - (Indirect),Y
	jmp		OP_NOP		; 12 
	jmp		OP_NOP		; 13 
	jmp		OP_NOP		; 14 
	jmp		OP_ORA_ZPX	; 15 ORA - Zero Page,X
	jmp		OP_ASL_ZPX	; 16 ASL - Zero Page,X
	jmp		OP_NOP		; 17 
	jmp		OP_CLC		; 18 CLC
	jmp		OP_ORA_ABY	; 19 ORA - Absolute,Y
	jmp		OP_NOP		; 1A 
	jmp		OP_NOP		; 1B 
	jmp		OP_NOP		; 1C 
	jmp		OP_ORA_ABX	; 1D ORA - Absolute,X
	jmp		OP_ASL_ABX	; 1E ASL - Absolute,X
	jmp		OP_NOP		; 1F 
	jmp		OP_JSR		; 20 JSR
	jmp		OP_AND_IX	; 21 AND - (Indirect,X)
	jmp		OP_NOP		; 22 
	jmp		OP_NOP		; 23 
	jmp		OP_BIT_ZP	; 24 BIT - Zero Page
	jmp		OP_AND_ZP	; 25 AND - Zero Page
	jmp		OP_ROL_ZP	; 26 ROL - Zero Page
	jmp		OP_NOP		; 27 
	jmp		OP_PLP		; 28 PLP
	jmp		OP_AND_IM	; 29 AND - Immediate
	jmp		OP_ROL_AC	; 2A ROL - Accumulator
	jmp		OP_NOP		; 2B 
	jmp		OP_BIT_AB	; 2C BIT - Absolute
	jmp		OP_AND_AB	; 2D AND - Absolute
	jmp		OP_ROL_AB	; 2E ROL - Absolute
	jmp		OP_NOP		; 2F 
	jmp		OP_BMI		; 30 BMI
	jmp		OP_AND_IY	; 31 AND - (Indirect),Y
	jmp		OP_NOP		; 32 
	jmp		OP_NOP		; 33 
	jmp		OP_NOP		; 34 
	jmp		OP_AND_ZPX	; 35 AND - Zero Page,X
	jmp		OP_ROL_ZPX	; 36 ROL - Zero Page,X
	jmp		OP_NOP		; 37 
	jmp		OP_SEC		; 38 SEC
	jmp		OP_AND_ABY	; 39 AND - Absolute,Y
	jmp		OP_NOP		; 3A 
	jmp		OP_NOP		; 3B 
	jmp		OP_NOP		; 3C 
	jmp		OP_AND_ABX	; 3D AND - Absolute,X
	jmp		OP_ROL_ABX	; 3E ROL - Absolute,X
	jmp		OP_NOP		; 3F 
	jmp		OP_RTI		; 40 RTI
	jmp		OP_EOR_IX	; 41 EOR - (Indirect,X)
	jmp		OP_NOP		; 42 
	jmp		OP_NOP		; 43 
	jmp		OP_NOP		; 44 
	jmp		OP_EOR_ZP	; 45 EOR - Zero Page
	jmp		OP_LSR_ZP	; 46 LSR - Zero Page
	jmp		OP_NOP		; 47 
	jmp		OP_PHA		; 48 PHA
	jmp		OP_EOR_IM	; 49 EOR - Immediate
	jmp		OP_LSR_AC	; 4A LSR - Accumulator
	jmp		OP_NOP		; 4B 
	jmp		OP_JMP_AB	; 4C JMP - Absolute
	jmp		OP_EOR_AB	; 4D EOR - Absolute
	jmp		OP_LSR_AB	; 4E LSR - Absolute
	jmp		OP_NOP		; 4F 
	jmp		OP_BVC		; 50 BVC
	jmp		OP_EOR_IY	; 51 EOR - (Indirect),Y
	jmp		OP_NOP		; 52 
	jmp		OP_NOP		; 53 
	jmp		OP_NOP		; 54 
	jmp		OP_EOR_ZPX	; 55 EOR - Zero Page,X
	jmp		OP_LSR_ZPX	; 56 LSR - Zero Page,X
	jmp		OP_NOP		; 57 
	jmp		OP_CLI		; 58 CLI
	jmp		OP_EOR_ABY	; 59 EOR - Absolute,Y
	jmp		OP_NOP		; 5A 
	jmp		OP_NOP		; 5B 
	jmp		OP_NOP		; 5C 
	jmp		OP_EOR_ABX	; 5D EOR - Absolute,X
	jmp		OP_LSR_ABX	; 5E LSR - Absolute,X
	jmp		OP_NOP		; 5F 
	jmp		OP_RTS		; 60 RTS
	jmp		OP_ADC_IX	; 61 ADC - (Indirect,X)
	jmp		OP_NOP		; 62 
	jmp		OP_NOP		; 63 
	jmp		OP_NOP		; 64 
	jmp		OP_ADC_ZP	; 65 ADC - Zero Page
	jmp		OP_ROR_ZP	; 66 ROR - Zero Page
	jmp		OP_NOP		; 67 
	jmp		OP_PLA		; 68 PLA
	jmp		OP_ADC_IM	; 69 ADC - Immediate
	jmp		OP_ROR_AC	; 6A ROR - Accumulator
	jmp		OP_NOP		; 6B 
	jmp		OP_JMP_IND	; 6C JMP - Indirect
	jmp		OP_ADC_AB	; 6D ADC - Absolute
	jmp		OP_ROR_AB	; 6E ROR - Absolute
	jmp		OP_NOP		; 6F 
	jmp		OP_BVS		; 70 BVS
	jmp		OP_ADC_IY	; 71 ADC - (Indirect),Y
	jmp		OP_NOP		; 72 
	jmp		OP_NOP		; 73 
	jmp		OP_NOP		; 74 
	jmp		OP_ADC_ZPX	; 75 ADC - Zero Page,X
	jmp		OP_ROR_ZPX	; 76 ROR - Zero Page,X
	jmp		OP_NOP		; 77 
	jmp		OP_SEI		; 78 SEI
	jmp		OP_ADC_ABY	; 79 ADC - Absolute,Y
	jmp		OP_NOP		; 7A 
	jmp		OP_NOP		; 7B 
	jmp		OP_NOP		; 7C 
	jmp		OP_ADC_ABX	; 7D ADC - Absolute,X
	jmp		OP_ROR_ABX	; 7E ROR - Absolute,X
	jmp		OP_NOP		; 7F 
	jmp		OP_NOP		; 80 
	jmp		OP_STA_IX	; 81 STA - (Indirect,X)
	jmp		OP_NOP		; 82 
	jmp		OP_NOP		; 83 
	jmp		OP_STY_ZP	; 84 STY - Zero Page
	jmp		OP_STA_ZP	; 85 STA - Zero Page
	jmp		OP_STX_ZP	; 86 STX - Zero Page
	jmp		OP_NOP		; 87 
	jmp		OP_DEY		; 88 DEY
	jmp		OP_NOP		; 89 
	jmp		OP_TXA		; 8A TXA
	jmp		OP_NOP		; 8B 
	jmp		OP_STY_AB	; 8C STY - Absolute
	jmp		OP_STA_AB	; 8D STA - Absolute
	jmp		OP_STX_AB	; 8E STX - Absolute
	jmp		OP_NOP		; 8F 
	jmp		OP_BCC		; 90 BCC
	jmp		OP_STA_IY	; 91 STA - (Indirect),Y
	jmp		OP_NOP		; 92 
	jmp		OP_NOP		; 93 
	jmp		OP_STY_ZPX	; 94 STY - Zero Page,X
	jmp		OP_STA_ZPX	; 95 STA - Zero Page,X
	jmp		OP_STX_ZPY	; 96 STX - Zero Page,Y
	jmp		OP_NOP		; 97 
	jmp		OP_TYA		; 98 TYA
	jmp		OP_STA_ABY	; 99 STA - Absolute,Y
	jmp		OP_TXS		; 9A TXS
	jmp		OP_NOP		; 9B 
	jmp		OP_NOP		; 9C 
	jmp		OP_STA_ABX	; 9D STA - Absolute,X
	jmp		OP_NOP		; 9E 
	jmp		OP_NOP		; 9F 
	jmp		OP_LDY_IM	; A0 LDY - Immediate
	jmp		OP_LDA_IX	; A1 LDA - (Indirect,X)
	jmp		OP_LDX_IM	; A2 LDX - Immediate
	jmp		OP_NOP		; A3 
	jmp		OP_LDY_ZP	; A4 LDY - Zero Page
	jmp		OP_LDA_ZP	; A5 LDA - Zero Page
	jmp		OP_LDX_ZP	; A6 LDX - Zero Page
	jmp		OP_NOP		; A7 
	jmp		OP_TAY		; A8 TAY
	jmp		OP_LDA_IM	; A9 LDA - Immediate
	jmp		OP_TAX		; AA TAX
	jmp		OP_NOP		; AB 
	jmp		OP_LDY_AB	; AC LDY - Absolute
	jmp		OP_LDA_AB	; AD LDA - Absolute
	jmp		OP_LDX_AB	; AE LDX - Absolute
	jmp		OP_NOP		; AF 
	jmp		OP_BCS		; B0 BCS
	jmp		OP_LDA_IY	; B1 LDA - (Indirect),Y
	jmp		OP_NOP		; B2 
	jmp		OP_NOP		; B3 
	jmp		OP_LDY_ZPX	; B4 LDY - Zero Page,X
	jmp		OP_LDA_ZPX	; B5 LDA - Zero Page,X
	jmp		OP_LDX_ZPY	; B6 LDX - Zero Page,Y
	jmp		OP_NOP		; B7 
	jmp		OP_CLV		; B8 CLV
	jmp		OP_LDA_ABY	; B9 LDA - Absolute,Y
	jmp		OP_TSX		; BA TSX
	jmp		OP_NOP		; BB 
	jmp		OP_LDY_ABX	; BC LDY - Absolute,X
	jmp		OP_LDA_ABX	; BD LDA - Absolute,X
	jmp		OP_LDX_ABY	; BE LDX - Absolute,Y
	jmp		OP_NOP		; BF 
	jmp		OP_CPY_IM	; C0 CPY - Immediate
	jmp		OP_CMP_IX	; C1 CMP - (Indirect,X)
	jmp		OP_NOP		; C2 
	jmp		OP_NOP		; C3 
	jmp		OP_CPY_ZP	; C4 CPY - Zero Page
	jmp		OP_CMP_ZP	; C5 CMP - Zero Page
	jmp		OP_DEC_ZP	; C6 DEC - Zero Page
	jmp		OP_NOP		; C7 
	jmp		OP_INY		; C8 INY
	jmp		OP_CMP_IM	; C9 CMP - Immediate
	jmp		OP_DEX		; CA DEX
	jmp		OP_NOP		; CB 
	jmp		OP_CPY_AB	; CC CPY - Absolute
	jmp		OP_CMP_AB	; CD CMP - Absolute
	jmp		OP_DEC_AB	; CE DEC - Absolute
	jmp		OP_NOP		; CF 
	jmp		OP_BNE		; D0 BNE
	jmp		OP_CMP_IY	; D1 CMP   (Indirect@,Y
	jmp		OP_NOP		; D2 
	jmp		OP_NOP		; D3 
	jmp		OP_NOP		; D4 
	jmp		OP_CMP_ZPX	; D5 CMP - Zero Page,X
	jmp		OP_DEC_ZPX	; D6 DEC - Zero Page,X
	jmp		OP_NOP		; D7 
	jmp		OP_CLD		; D8 CLD
	jmp		OP_CMP_ABY	; D9 CMP - Absolute,Y
	jmp		OP_NOP		; DA 
	jmp		OP_NOP		; DB 
	jmp		OP_NOP		; DC 
	jmp		OP_CMP_ABX	; DD CMP - Absolute,X
	jmp		OP_DEC_ABX	; DE DEC - Absolute,X
	jmp		OP_NOP		; DF 
	jmp		OP_CPX_IM	; E0 CPX - Immediate
	jmp		OP_SBC_IX	; E1 SBC - (Indirect,X)
	jmp		OP_NOP		; E2 
	jmp		OP_NOP		; E3 
	jmp		OP_CPX_ZP	; E4 CPX - Zero Page
	jmp		OP_SBC_ZP	; E5 SBC - Zero Page
	jmp		OP_INC_ZP	; E6 INC - Zero Page
	jmp		OP_NOP		; E7 
	jmp		OP_INX		; E8 INX
	jmp		OP_SBC_IM	; E9 SBC - Immediate
	jmp		OP_NOP		; EA NOP
	jmp		OP_NOP		; EB 
	jmp		OP_CPX_AB	; EC CPX - Absolute
	jmp		OP_SBC_AB	; ED SBC - Absolute
	jmp		OP_INC_AB	; EE INC - Absolute
	jmp		OP_NOP		; EF 
	jmp		OP_BEQ		; F0 BEQ
	jmp		OP_SBC_IY	; F1 SBC - (Indirect),Y
	jmp		OP_NOP		; F2 
	jmp		OP_NOP		; F3 
	jmp		OP_NOP		; F4 
	jmp		OP_SBC_ZPX	; F5 SBC - Zero Page,X
	jmp		OP_INC_ZPX	; F6 INC - Zero Page,X
	jmp		OP_NOP		; F7 
	jmp		OP_SED		; F8 SED
	jmp		OP_SBC_ABY	; F9 SBC - Absolute,Y
	jmp		OP_NOP		; FA 
	jmp		OP_NOP		; FB 
	jmp		OP_NOP		; FC 
	jmp		OP_SBC_ABX	; FD SBC - Absolute,X
	jmp		OP_INC_ABX	; FE INC - Absolute,X
	jmp		OP_NOP		; FF 
	

BiosFlashData:
   	.INCLUDE "../bios/bios-kim1.inc"
	
	.EXIT

