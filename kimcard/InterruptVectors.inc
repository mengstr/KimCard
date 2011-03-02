	.CSEG
	.ORG 0x0000

	jmp		V_RESET			;  1 Reset Handler
	jmp		V_EXT_INT0		;  2 IRQ0 Handler
	jmp		V_EXT_INT1		;  3 IRQ1 Handler
	jmp		V_EXT_INT2		;  4 IRQ1 Handler
	jmp		V_PCINT0		;  5 PCINT0 Handler
	jmp		V_PCINT1		;  6 PCINT1 Handler
	jmp		V_PCINT2		;  7 PCINT2 Handler
	jmp		V_PCINT3		;  8 PCINT3 Handler
	jmp		V_WDT			;  9 Watchdog Timer Handler
	jmp		V_TIM2_COMPA	; 10 Timer2 Compare A Handler
	jmp		V_TIM2_COMPB	; 11 Timer2 Compare B Handler
	jmp		V_TIM2_OVF		; 12 Timer2 Overflow Handler
	jmp		V_TIM1_CAPT		; 13 Timer1 Capture Handler
	jmp		V_TIM1_COMPA	; 14 Timer1 Compare A Handler
	jmp		V_TIM1_COMPB	; 15 Timer1 Compare B Handler
	jmp		V_TIM1_OVF		; 16 Timer1 Overflow Handler
	jmp		V_TIM0_COMPA	; 17 Timer0 Compare A Handler
	jmp		V_TIM0_COMPB	; 18 Timer0 Compare B Handler
	jmp		V_TIM0_OVF		; 19 Timer0 Overflow Handler
	jmp		V_SPI_STC		; 20 SPI Transfer Complete Handler
	jmp		V_USART0_RXC	; 21 USART0, RX Complete Handler
	jmp		V_USART0_UDRE	; 22 USART0, UDR Empty Handler
	jmp		V_USART0_TXC	; 23 USART0, TX Complete Handler
	jmp		V_ANA_COMP		; 24 Analog Comparator Handler
	jmp		V_ADC			; 25 ADC Conversion Complete Handler
	jmp		V_EE_RDY		; 26 EEPROM Ready Handler
	jmp		V_TWI			; 27 2-wire Serial Interface Handler
	jmp		V_SPM_RDY		; 28 Store Program Memory Ready Handler


V_EXT_INT0:					; IRQ0 Handler
	reti

V_EXT_INT1:					; IRQ1 Handler
	reti

V_EXT_INT2:					; IRQ2 Handler
	reti

V_PCINT0:					; PCINT0 Handler
	reti

V_PCINT1:					; PCINT1 Handler
	reti

V_PCINT2:					; PCINT2 Handler
	reti

V_PCINT3:					; PCINT3 Handler
	reti

V_WDT:						; Watchdog Timer Handler
	reti

V_TIM2_COMPA:				; Timer2 Compare A Handler
	reti

V_TIM2_COMPB:				; Timer2 Compare B Handler
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

V_USART0_RXC:				; USART0, RX Complete Handler
	reti

V_USART0_UDRE:				; USART0, UDR Empty Handler
	reti

V_USART0_TXC:				; USART0, TX Complete Handler
	reti

V_ANA_COMP:					; Analog Comparator Handler
	reti

V_ADC:						; ADC Conversion Complete Handler
	reti

V_EE_RDY:					; EEPROM Ready Handler
	reti

V_TWI:						; 2-wire Serial Interface Handler
	reti

V_SPM_RDY:					; Store Program Memory Ready Handler
	reti

