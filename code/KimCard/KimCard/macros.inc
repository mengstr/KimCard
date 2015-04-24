
.MACRO FixPage
	mov		SAVE, YH
	andi	YH, 0b00001111
	ori		YH, 0b00100000
.ENDM


.MACRO FixPageNoStore
	andi	YH, 0b00001111
	ori		YH, 0b00100000
.ENDM

.MACRO FixPageNoStore_Z
	andi	ZH, 0b00001111
	ori		ZH, 0b00100000
.ENDM

.MACRO RestorePage
	mov		YH, SAVE
.ENDM



.MACRO CPUCarryToAVR
	clc
	sbrc	CPU_STATUS, BIT_FLAG_CARRY	; Set AVR carry if 6502 carry is set
	sec
.ENDM



.MACRO HandleABSOLUTE
	FixPage
	ld		ZL, Y+			; Absolute Address (low)
	ld		ZH, Y+			; Absolute Address (high)
	ori		ZH,0x20			; Offset 0x20 for SRAM
	RestorePage
	cpi		ZH, KIM_RIOTPAGE	; Set Zero-flag if we're accessing the ports
.ENDM



.MACRO HandleABSOLUTE_X
	FixPage
	ld		ZL, Y+			; Absolute Address (low)
	ld		ZH, Y+			; Absolute Address (high)
	FixPageNoStore_Z
	add		ZL, CPU_X		; Add X-register to address
	adc		ZH, ZERO		; r1 is always zero
	RestorePage
	cpi		ZH, KIM_RIOTPAGE ; Set Zero-flag if we're accessing the ports
.ENDM




.MACRO HandleABSOLUTE_Y
	FixPage
	ld		ZL, Y+			; Absolute Address (low)
	ld		ZH, Y+			; Absolute Address (high)
	FixPageNoStore_Z
	add		ZL, CPU_Y		; Add Y-register to address
	adc		ZH, ZERO		; r1 is always zero
	RestorePage
	cpi		ZH, KIM_RIOTPAGE; Set Zero-flag if we're accessing the ports
.ENDM




.MACRO HandleZEROPAGE
	FixPage
	ld		ZL, Y+			; ZP Address (low)
	ldi		ZH, 0x20		; Offset for SRAM (high)
	RestorePage
.ENDM





.MACRO HandleZEROPAGE_X
	FixPage
	ld		ZL, Y+			; ZP Address
	add		ZL, CPU_X
	ldi		ZH, 0x20		; SRAM offset
	RestorePage
.ENDM




.MACRO HandleZEROPAGE_Y
	FixPage
	ld		ZL, Y+			; ZP Address
	add		ZL, CPU_Y
	ldi		ZH, 0x20		; SRAM offset
	RestorePage
.ENDM




.MACRO HandleIMMEDIATE
	FixPage
	ld		ZL, CPU_PC
	RestorePage
	adiw	YY,1
.ENDM




.MACRO HandleRelative
	FixPage
	ld		r16, Y+			; Get offset
	RestorePage
.ENDM




.MACRO HandleINDIRECT_X		; TODO
	FixPage
	ld		XL, Y+			; Address (low)
	ldi		XH, 1			; Address (high) Ofsetted for SRAM
	add		XL, CPU_X		; Add X-register to address
	adc		XH, ZERO		; r1 is always zero
	RestorePage
	ld		ZL, X+
	ld		ZH, X+
	ori		ZH, 0x20	 	; Offset for SRAM
	cpi		ZH, KIM_RIOTPAGE; Set Zero-flag if we're accessing the ports
.ENDM


.MACRO HandleINDIRECT_Y		; TODO
	FixPage
	ld		XL, Y+			; Address (low)
	ldi		XH, 0x20		; Address (high) ofgstted for SRAM
	RestorePage
	ld		ZL, X+
	ld		ZH, X+
	add		ZL, CPU_Y		; Add Y-register to address
	adc		ZH, ZERO		; r1 is always zero
	ori		ZH, 0x20		; Offset for SRAM
	cpi		ZH, KIM_RIOTPAGE; Set Zero-flag if we're accessing the ports
.ENDM




.MACRO 	ClearNZ
	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	cbr		CPU_STATUS, MASK_FLAG_ZERO
.ENDM


.MACRO	ClearZVN
	cbr		CPU_STATUS, MASK_FLAG_ZERO
	cbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
.ENDM



.macro 	UpdateNZjmpLoop
		brne	NotZero\@
		; Zero flag is set in AVR, we don't need to check for Negative
		sbr		CPU_STATUS, MASK_FLAG_ZERO
		jmp 	Loop
	NotZero\@:
		brpl	IsPositive\@
		; Negative flag set in AVR
		sbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	IsPositive\@:
	jmp Loop
.endm



; Bit          7   6   5   4   3   2   1   0
;+0x0F         I   T   H   S   V   N   Z   C    SREG

.MACRO 	UpdateCZjmpLoop
	in		r13, 0x3F			; SREG

	cbr		CPU_STATUS, MASK_FLAG_CARRY
	cbr		CPU_STATUS, MASK_FLAG_ZERO

	sbrc	r13, 0				; Carry
	sbr		CPU_STATUS, MASK_FLAG_CARRY 
	sbrc	r13, 1				; Carry
	sbr		CPU_STATUS, MASK_FLAG_ZERO

	jmp Loop
.ENDM



; Bit          7   6   5   4   3   2   1   0
;+0x0F         I   T   H   S   V   N   Z   C    SREG
.MACRO 	UpdateNCZjmpLoop
	in		r13, 0x3F			; SREG

	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	cbr		CPU_STATUS, MASK_FLAG_CARRY
	cbr		CPU_STATUS, MASK_FLAG_ZERO

	sbrc	r13, 0				; Carry
	sbr		CPU_STATUS, MASK_FLAG_CARRY 
	sbrc	r13, 1				; Carry
	sbr		CPU_STATUS, MASK_FLAG_ZERO
	sbrc	r13, 2				; Negative
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE

	jmp Loop
.ENDM



; Bit          7   6   5   4   3   2   1   0
;+0x0F         I   T   H   S   V   N   Z   C    SREG
;
; Update NZC but with inverted C for CMP instructions
;
.MACRO 	UpdateNZInvCjmpLoop
	in		r13, 0x3F			; SREG

	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	sbr		CPU_STATUS, MASK_FLAG_CARRY
	cbr		CPU_STATUS, MASK_FLAG_ZERO

	sbrc	r13, 0				; Carry
	cbr		CPU_STATUS, MASK_FLAG_CARRY 

	sbrc	r13, 1				; Zero
	sbr		CPU_STATUS, MASK_FLAG_ZERO

	sbrc	r13, 2				; Negative
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE

	jmp Loop
.ENDM



.MACRO 	UpdateNCZVjmpLoop
	in		r13, 0x3F			; SREG

	cbr		CPU_STATUS, MASK_FLAG_CARRY
	cbr		CPU_STATUS, MASK_FLAG_ZERO
	cbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	cbr		CPU_STATUS, MASK_FLAG_NEGATIVE

	sbrc	r13, 0				; Carry
	sbr		CPU_STATUS, MASK_FLAG_CARRY 
	sbrc	r13, 1				; Carry
	sbr		CPU_STATUS, MASK_FLAG_ZERO
	sbrc	r13, 2				; Negative
	sbr		CPU_STATUS, MASK_FLAG_NEGATIVE
	sbrc	r13, 3				; Overflow
	sbr		CPU_STATUS, MASK_FLAG_OVERFLOW
	jmp Loop

.ENDM



.MACRO UpdateCarryFromCPU
	clc
	sbrc	CPU_STATUS, BIT_FLAG_CARRY
	sec
.ENDM


.MACRO BranchJUMP
		sbrc	r16, 7		; Is offset negative?
		rjmp	negative\@
		add		CPU_PCL, r16
		adc		CPU_PCH, ZERO
		jmp 	Loop
	negative\@:
		com		r16
		inc		r16
		sub		CPU_PCL, r16
		sbc		CPU_PCH, ZERO
		jmp		Loop
.ENDM




.macro StoreAbsolute thereg
		breq	AB_PORT_\@
		st		Z, \thereg
		jmp 	Loop

AB_PORT_\@:
		cpi		ZL, lo8(KIM_SAD)	; Is Data Register A?
		brne	AB_PORT1_\@
		ldi		R16,0x7F			; Invert the bits for the led segments  TODO use hardware for inverting
		eor		\thereg, R16
		out		PA_OUT, \thereg
		eor		\thereg, R16
		jmp 	Loop
	AB_PORT1_\@:
		cpi		ZL, lo8(KIM_PADD)	; Is Data Dir A?
		brne	AB_PORT2_\@
		out		PA_DIR, \thereg
		jmp		Loop

	AB_PORT2_\@:
		cpi		ZL, lo8(KIM_SBD)	; Is Data Register B?
		brne	AB_PORT3_\@

		ldi		XH, hi8(LookupPortC)
		ldi		XL, lo8(LookupPortC)
		mov		r16, \thereg
		andi	r16, 0x1F	; Mask off uninteresting bits
		add		XL, r16
		ld		r16, X
		out		PC_OUT, r16

		ldi		XH, hi8(LookupPortD)
		ldi		XL, lo8(LookupPortD)
		mov		r16, \thereg
		andi	r16, 0x1F	; Mask off uninteresting bits
		add		XL, r16
		ld		r16, X
		out		PD_DIR, r16
		out		PD_OUT, ZERO
		jmp 	Loop

	AB_PORT3_\@:
		cpi		ZL, lo8(KIM_PBDD)	; Is Data Dir B?
		brne	AB_PORT4_\@
		out		PC_DIR, \thereg		
		jmp 	Loop

	AB_PORT4_\@:
		jmp		Loop			

.endm



.macro PushAllRegisters
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25
	push r26
	push r27
	push r28
	push r29
	push r30
	push r31
.endm




.macro PopAllRegisters
	pop		r31
	pop		r30
	pop		r29
	pop		r28
	pop		r27
	pop		r26
	pop		r25
	pop		r24
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	pop		r3
	pop		r2
	pop		r1
	pop		r0
.endm


