	jmp		OP_NOP		; 00 BRK					TODO CHANGE BACK TO OP_BRK
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
	jmp		OP_ORA_IY	; 11 ORA - (Indirect),Y
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
	jmp		OP_BRK		; FF					TODO Change back to OP_NOP 
