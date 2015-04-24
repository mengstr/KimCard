#ifndef MAIN_H_
#define MAIN_H_

//#define TEST


#define	PA_DIR			0x10
#define	PA_OUT			0x11
#define	PA_IN			0x12

#define	PB_DIR			0x14
#define	PB_OUT			0x15
#define	PB_IN			0x16

#define	PC_DIR			0x18
#define	PC_OUT			0x19
#define	PC_IN			0x1A

#define	PD_DIR			0x1C
#define	PD_OUT			0x1D
#define	PD_IN			0x1E



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

#define	BIT_FLAG_CARRY		 0
#define	BIT_FLAG_ZERO		 1
#define	BIT_FLAG_INTERRUPT	 2
#define	BIT_FLAG_DECIMAL	 3
#define	BIT_FLAG_BREAK		 4
#define	BIT_FLAG_UNUSED		 5
#define	BIT_FLAG_OVERFLOW	 6
#define	BIT_FLAG_NEGATIVE	 7

#define	MASK_FLAG_CARRY		 (1<<BIT_FLAG_CARRY)
#define	MASK_FLAG_ZERO		 (1<<BIT_FLAG_ZERO)
#define	MASK_FLAG_INTERRUPT	 (1<<BIT_FLAG_INTERRUPT)
#define	MASK_FLAG_DECIMAL	 (1<<BIT_FLAG_DECIMAL)
#define	MASK_FLAG_BREAK		 (1<<BIT_FLAG_BREAK)
#define	MASK_FLAG_UNUSED	 (1<<BIT_FLAG_UNUSED)
#define	MASK_FLAG_OVERFLOW	 (1<<BIT_FLAG_OVERFLOW)
#define	MASK_FLAG_NEGATIVE	 (1<<BIT_FLAG_NEGATIVE)


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


#define SAVE			r0				// Used for saving original address when mapping kim<->avr memory spaces
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
#define tick			r25
//#define xxx			r26			// XL
//#define xxx			r27			// XH
//#define xxx			r28			// YL
//#define xxx			r29			// YH
//#define xxx			r30			// ZL
//#define xxx			r31			// ZH


#endif /* MAIN_H_ */