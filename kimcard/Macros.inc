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

