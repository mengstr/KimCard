/*
 * main.c
 *
 * Created: 14/10/2012 23:42:18
 *  Author: Mats Engstrom (mats@smallroomlabs.com)
 */ 

#define F_CPU 32000000

#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <avr/sleep.h>
#include <avr/wdt.h>
#include <avr/eeprom.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "i2cmaster.h"
#include "kim1-bios.h"
#include "main.h"



void Emulate(void);

void I2cTest(void);

#define testbit(port, bit) (uint8_t)(((uint8_t)port & (uint8_t)_BV(bit)))

__attribute__((section(".Kim1Ram"))) uint8_t Kim1Ram[1024];
__attribute__((section(".Kim1Rom"))) uint8_t Kim1Rom[1024];

const uint8_t BitReverseTable[256] = {
	//00   01   02   03   04   05   06   07   08   09   0a   0b   0c   0d   0e   0f
	0x00,0x40,0x20,0x60,0x10,0x50,0x30,0x70,0x08,0x48,0x28,0x68,0x18,0x58,0x38,0x78,
	0x04,0x44,0x24,0x64,0x14,0x54,0x34,0x74,0x0C,0x4C,0x2C,0x6C,0x1C,0x5C,0x3C,0x7C,
	0x02,0x42,0x22,0x62,0x12,0x52,0x32,0x72,0x0A,0x4A,0x2A,0x6A,0x1A,0x5A,0x3A,0x7A,
	0x06,0x46,0x26,0x66,0x16,0x56,0x36,0x76,0x0E,0x4E,0x2E,0x6E,0x1E,0x5E,0x3E,0x7E,
	0x01,0x41,0x21,0x61,0x11,0x51,0x31,0x71,0x09,0x49,0x29,0x69,0x19,0x59,0x39,0x79,
	0x05,0x45,0x25,0x65,0x15,0x55,0x35,0x75,0x0D,0x4D,0x2D,0x6D,0x1D,0x5D,0x3D,0x7D,
	0x03,0x43,0x23,0x63,0x13,0x53,0x33,0x73,0x0B,0x4B,0x2B,0x6B,0x1B,0x5B,0x3B,0x7B,
	0x07,0x47,0x27,0x67,0x17,0x57,0x37,0x77,0x0F,0x4F,0x2F,0x6F,0x1F,0x5F,0x3F,0x7F,
	0x80,0xC0,0xA0,0xE0,0x90,0xD0,0xB0,0xF0,0x88,0xC8,0xA8,0xE8,0x98,0xD8,0xB8,0xF8,
	0x84,0xC4,0xA4,0xE4,0x94,0xD4,0xB4,0xF4,0x8C,0xCC,0xAC,0xEC,0x9C,0xDC,0xBC,0xFC,
	0x82,0xC2,0xA2,0xE2,0x92,0xD2,0xB2,0xF2,0x8A,0xCA,0xAA,0xEA,0x9A,0xDA,0xBA,0xFA,
	0x86,0xC6,0xA6,0xE6,0x96,0xD6,0xB6,0xF6,0x8E,0xCE,0xAE,0xEE,0x9E,0xDE,0xBE,0xFE,
	0x81,0xC1,0xA1,0xE1,0x91,0xD1,0xB1,0xF1,0x89,0xC9,0xA9,0xE9,0x99,0xD9,0xB9,0xF9,
	0x85,0xC5,0xA5,0xE5,0x95,0xD5,0xB5,0xF5,0x8D,0xCD,0xAD,0xED,0x9D,0xDD,0xBD,0xFD,
	0x83,0xC3,0xA3,0xE3,0x93,0xD3,0xB3,0xF3,0x8B,0xCB,0xAB,0xEB,0x9B,0xDB,0xBB,0xFB,
	0x87,0xC7,0xA7,0xE7,0x97,0xD7,0xB7,0xF7,0x8F,0xCF,0xAF,0xEF,0x9F,0xDF,0xBF,0xFF
};



const uint8_t LookupPortC[] = {
	0x00,	// 00 n/a
	0x00,	// 01 n/a
	0x00,	// 02 n/a
	0x00,	// 03 n/a
	0x00,	// 04 n/a
	0x00,	// 05 n/a
	0x00,	// 06 n/a
	0x00,	// 07 n/a
	~0x01,	// 08 Activate display 1
	~0x01,	// 09 Activate display 1
	~0x02,	// 0a Activate display 2
	~0x02,	// 0b Activate display 2
	~0x04,	// 0c Activate display 3
	~0x04,	// 0d Activate display 3
	~0x08,	// 0e Activate display 4
	~0x08,	// 0f Activate display 4
	~0x10,	// 10 Activate display 5
	~0x10,	// 11 Activate display 5
	~0x20,	// 12 Activate display 6
	~0x20,	// 13 Activate display 6
	0x00,	// 14 n/a
	0x00,	// 15 n/a
	0x00,	// 16 n/a
	0x00,	// 17 n/a
	0x00,	// 18 n/a
	0x00,	// 19 n/a
	0x00,	// 1a n/a
	0x00,	// 1b n/a
	0x00,	// 1c n/a
	0x00,	// 1d n/a
	0x00,	// 1e n/a
	0x00	// 1f n/a
};


const uint8_t LookupPortD[] = {
	0x01,	// 00 Key Row 0
	0x01,	// 01 Key Row 0
	0x02,	// 02 Key Row 1 
	0x02,	// 03 Key Row 1
	0x04,	// 04 Key Row 2
	0x04,	// 05 Key Row 2
	0x00,	// 06 
	0x00,	// 07 
	0x00,	// 08 n/a
	0x00,	// 09 n/a
	0x00,	// 0a n/a
	0x00,	// 0b n/a
	0x00,	// 0c n/a
	0x00,	// 0d n/a
	0x00,	// 0e n/a
	0x00,	// 0f n/a
	0x00,	// 10 n/a
	0x00,	// 11 n/a
	0x00,	// 12 n/a
	0x00,	// 13 n/a
	0x00,	// 14 n/a
	0x00,	// 15 n/a
	0x00,	// 16 n/a
	0x00,	// 17 n/a
	0x00,	// 18 n/a
	0x00,	// 19 n/a
	0x00,	// 1a n/a
	0x00,	// 1b n/a
	0x00,	// 1c n/a
	0x00,	// 1d n/a
	0x00,	// 1e n/a
	0x00	// 1f n/a
};

const uint8_t charMap[]={
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,    //  !"#$%&'
   0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00,    // ()*+,-./
   0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,    // 01234567
   0x7F, 0x6F, 0x00, 0x00, 0x00, 0x48, 0x00, 0x00,    // 89:;<=>?
   0x00, 0x77, 0x7C, 0x39, 0x5e, 0x79, 0x71, 0x7D,    // @ABCDEFG
   0x74, 0x04, 0xD1, 0x00, 0x38, 0x37, 0x54, 0x5C,    // HIJKLMNO
   0x73, 0x00, 0x50, 0x6D, 0x78, 0x1c, 0x3F, 0x3F,    // PQRSTUVW
   0x00, 0x6e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08     // XYZ[\]^_
};



void CCPWrite( volatile uint8_t * address, uint8_t value );


// From Application Note AVR1003
void CCPWrite( volatile uint8_t * address, uint8_t value ) {
	uint8_t volatile saved_sreg = SREG;
	cli();

	#ifdef __ICCAVR__
	asm("movw r30, r16");
	#ifdef RAMPZ
	RAMPZ = 0;
	#endif
	asm("ldi  r16,  0xD8 \n"
	"out  0x34, r16  \n"
	#if (__MEMORY_MODEL__ == 1)
	"st     Z,  r17  \n");
	#elif (__MEMORY_MODEL__ == 2)
	"st     Z,  r18  \n");
	#else /* (__MEMORY_MODEL__ == 3) || (__MEMORY_MODEL__ == 5) */
	"st     Z,  r19  \n");
	#endif /* __MEMORY_MODEL__ */

	#elif defined __GNUC__
	volatile uint8_t * tmpAddr = address;
	#ifdef RAMPZ
	RAMPZ = 0;
	#endif
	asm volatile(
	"movw r30,  %0"	      "\n\t"
	"ldi  r16,  %2"	      "\n\t"
	"out   %3, r16"	      "\n\t"
	"st     Z,  %1"       "\n\t"
	:
	: "r" (tmpAddr), "r" (value), "M" (CCP_IOREG_gc), "i" (&CCP)
	: "r16", "r30", "r31"
	);

	#endif
	SREG = saved_sreg;
}

void dly(int c) {
	while ((c--) > 0) _delay_ms(1);
}

void CopyTestCode() {
//	#ifdef TEST
	int i;
	i=0x200;
	uint8_t code6502[1024] = 

"EAA903C906A905C906A906C906A907C906A9F0C906a9FCC906A9A3C9AAA9A9C9AAA9AAC9AAA9B0C9AA00"


//	"EAEAEAEAFAEAEA4C0102"

// LUNAR LANDER
//"A20DBDCC0295D5CA10F8A205A001F818B5D575D795D5CA8810F6B5D81002A99975D595D5CA10E5A5D5100DA90085E2A20295D595DBCA10F938A5E0E5DD85E0A201B5DEE90095DECA10F7B00CA900A20395DDCA10FB20BD02A5DEA6DF09F0A4E1F020F09CF0A4A2FEA05A18A5D96905A5D86900B004A2ADA0DE98A4E2F004A5D5A6D685FB86FAA5D9A6D8100538A900E5D985F9A90285E3D8201F1F206A1FC913F0C0B00320AD02C6E3D0EDF0B7C90A9005490F85E160AAA5DDF0FA86DDA5DD38F8E90585DCA900E90085DB604501009981009997020800000101"

// 1MS
//"0848A9DA8500EAC600D0FB6600EA6828FF"

// TEST KEYBOARD
//"206A1F85FA85FB85F9201F1F4C0002"


// TEST SCAND
//"A9008DFA00A9028DFB0020191F4C0A02"

//"A2088E4217A2BF8E4017205102A20A8E4217A2868E4017205102A20C8E4217A2DB8E4017205102A20E8E4217A2CF8E4017205102A2108E4217A2E68E4017205102A2128E4217A2ED8E40172051024C0002A2FFEAEAEAEACAD0F960"


// Farmer Brown2
//"A20D866EA9009560CA10FBA20BB560D03BCA10F9E66DA56CF009C66DC66ED0034C2519AD04174A4A4A4A4AC9069002290318AA690A856FBDA4028570A9028571A005B1709966008810F8846CA205B566D013CA10F920401F206A1FC56FD006A56C1002E66CC672D01EA9208572A56C300DA20AB55A955BCAD0F9865AF009A2F0B56C956BE830F9A97F8D4117A013A205B5608D40178C4217E673D0FC8888CA10EF4C0B02AAB0B6BCC2C808000000000001616140000061514701000063584E000000711D411F010063584C400000"

// HI/LO
//"F8A5E0386900A201C999D0018A85E020401FD0EDD8A99985FBA90085FAA2A086F986E1201F1F206A1FC913F0D3C5E2F0F28552C90AF010B0EA0A0A0A0AA2030A26F9CA10FA30DCA5F9C5E09006C5FBB0D285FBA6E0E4F9900BA6FAE4F9B0C485FAA6E1E8E0AAF0B5D0B"
	
	
	"\0\0\0";
	uint8_t *pos = code6502;	
    uint8_t v1,v2;

	for (;;) {
		v1=*pos++;
		v2=*pos++;
		if (v1==0 || v2==0) break;
		v1=v1-'0';
		v2=v2-'0';
		if (v1>9) v1=v1-7;
		if (v2>9) v2=v2-7;
		Kim1Ram[i++]=v1*16+v2;
	}			
//	#endif	

}



#define VIRTUAL_A	0x00
#define VIRTUAL_B	0x01
#define VIRTUAL_C	0x02
#define VIRTUAL_D	0x03
#define VIRTUAL_E	0x04

#define I2CADDRESS 0xA0      // device address of EEPROM 



uint8_t SaveToEEprom(uint8_t slot) {
	uint8_t i;
	uint8_t block;
	unsigned int src;
	unsigned int dst;

	PORTCFG_VPCTRLA = VIRTUAL_A | (VIRTUAL_E<<4);

	src=0;
	dst=slot*1024;

	i2c_init();										// initialize I2C library
	for (block=0; block<16; block++) {
		i2c_start_wait(I2CADDRESS+I2C_WRITE);		// set device address and write mode
		i2c_write(dst>>8);							// write address bits 14-8
		i2c_write(dst&0xFF);						// write address bits 7-0
		for (i=0; i<64; i++) {
			i2c_write(Kim1Ram[src++]);				// write data in block to EEPROM
		}
		dst+=64;
		i2c_stop();									// set stop condition = release bus
	}
			
	PORTCFG_VPCTRLA = VIRTUAL_A | (VIRTUAL_B<<4);
	return 1;
}


uint8_t LoadFromEEprom(uint8_t slot) {
	uint8_t res;
	unsigned int i;
	unsigned int src;
	unsigned int dst;

	PORTCFG_VPCTRLA = VIRTUAL_A | (VIRTUAL_E<<4);

	dst=0;
	src=slot*1024;

	i2c_init();										// initialize I2C library
	res=i2c_start(I2CADDRESS+I2C_WRITE);		// set device address and write mode
	if (res) {
		i2c_stop();
		PORTCFG_VPCTRLA = VIRTUAL_A | (VIRTUAL_B<<4);
		return 0;
	}	
	i2c_write(src>>8);							// write address bits 14-8
	i2c_write(src&0xFF);						// write address bits 7-0
	i2c_rep_start(I2CADDRESS+I2C_READ);			// set device address and read mode
	for (i=0; i<1023; i++) {
		Kim1Ram[dst++]=i2c_readAck();			// read 1023 bytes from EEPROM
	}	
	Kim1Ram[dst++]=i2c_readNak();				// read one final byte from EEPROM
	i2c_stop();

	PORTCFG_VPCTRLA = VIRTUAL_A | (VIRTUAL_B<<4);
	return 1;
}


void CpuLed(uint8_t status) {
	if (status==0) 	PORTB.OUTCLR=0b00000001;
	else PORTB.OUTSET=0b00000001;
}


uint8_t display[6];


void ScanDisplay(void) {
	static uint8_t dispNo=0;	
	
	PORTC_OUT=~0x00;	// Turn off all drivers
	PORTA_OUT=~display[dispNo];	
	if (dispNo==0) PORTC_OUT=~0x01;
	if (dispNo==1) PORTC_OUT=~0x02;
	if (dispNo==2) PORTC_OUT=~0x04;
	if (dispNo==3) PORTC_OUT=~0x08;
	if (dispNo==4) PORTC_OUT=~0x10;
	if (dispNo==5) PORTC_OUT=~0x20;
	dispNo++;
	if (dispNo>5) dispNo=0;
}



void WaitResetRelease(void) {
	do {						// Wait for Rs to be released
		dly(10);
	} while(!(PORTB_IN & 0x04));
	dly(10);
}



uint8_t GetKey() {
	unsigned int rd1,rd2,rd3;

	PORTA_DIR=0x00;
	PORTCFG.MPCMASK = 0b11111111;			// Affect all bits
	PORTA.PIN0CTRL = PORT_OPC_PULLUP_gc;	// Activate pullups
	PORTD_OUT=0x00;
	PORTC_DIR=0x00;
	
	PORTD_DIR=0x01;
	rd1=PORTA_IN;
	PORTD_DIR=0x02;
	rd2=PORTA_IN;
	PORTD_DIR=0x04;
	rd3=PORTA_IN;
	
	PORTC_DIR=0x3F;
	PORTD_DIR=0x00;
	PORTCFG.MPCMASK = 0b11111111;			// Affect all bits
	PORTA.PIN0CTRL = PORT_OPC_TOTEM_gc;		// Deactivate pullups
	PORTA_DIR=0xFF;
	PORTA_OUT=0xFF;

	if (!(rd1&0x01)) return 0;
	if (!(rd1&0x02)) return 1;
	if (!(rd1&0x04)) return 2;
	if (!(rd1&0x08)) return 3;
	if (!(rd1&0x10)) return 4;
	if (!(rd1&0x20)) return 5;
	if (!(rd1&0x40)) return 6;

	if (!(rd2&0x01)) return 7;
	if (!(rd2&0x02)) return 8;
	if (!(rd2&0x04)) return 9;
	if (!(rd2&0x08)) return 10;
	if (!(rd2&0x10)) return 11;
	if (!(rd2&0x20)) return 12;
	if (!(rd2&0x40)) return 13;

	if (!(rd3&0x01)) return 14;
	if (!(rd3&0x02)) return 15;
	if (!(rd3&0x04)) return 16;
	if (!(rd3&0x08)) return 17;
	if (!(rd3&0x10)) return 18;
	if (!(rd3&0x20)) return 19;
	if (!(rd3&0x40)) return 20;
	if (!(PORTB_IN&0x02)) return 21;
	if (!(PORTB_IN&0x04)) return 22;
	return 255;
}




int main(void) {
	int i;
	uint8_t k;
	uint8_t slot;
	uint8_t mode;
	uint8_t waitrelease;
	uint8_t res;

	// Setup virtual ports mappings
	PORTCFG_VPCTRLA = VIRTUAL_A | (VIRTUAL_B<<4);
	PORTCFG_VPCTRLB = VIRTUAL_C | (VIRTUAL_D<<4);

	// PORT A (Keyboard and led display cathodes/segments)
	PORTA_DIR=0xFF;
	PORTA_OUT=0x7F;

	// Setup PORT B
	// PB0 = Output (CPU LED)
	// PB1/2/3 = Input with Pullup (Step & Reset buttons, SST switch)
	PORTB.DIR=0b00000001;					// Output mode on bit 0
	PORTCFG.MPCMASK = 0b00001110;			// Affect bit 1/2/3 only
	PORTB.PIN0CTRL = PORT_OPC_PULLUP_gc |	// Activate pullups
					 PORT_ISC_BOTHEDGES_gc; // Interrupt on both press and release
	PORTB_INTCTRL = (PORTB_INTCTRL & ~PORT_INT0LVL_gm )  // Set interrupt level
					| PORT_INT0LVL_MED_gc;
	PORTB_INT0MASK = 0b00001110;			// Enable interrupts on bit 1/2/3 
    PMIC.CTRL |= PMIC_MEDLVLEN_bm;
    sei();									// Turn on interrupts in XMEGA

	// Setup port C (Display common anodes 0..5)
	PORTC_DIR=0x3F;
	PORTC_OUT=0x00;

	// Setup port D (KEY0..2)
	PORTD_DIR=0x00;
	PORTD_OUT=0x00;

	//  Enable and use internal oscillator
	OSC.CTRL = 0x03;        						// Enable internal 32MHz
	while(!testbit(OSC.STATUS,OSC_RC32MRDY_bp));  	// Wait until 32MHz stable
	CCPWrite(&CLK.CTRL, CLK_SCLKSEL_RC32M_gc);    	// Use internal 32MHz


	// Clear all KIM-1 ram to 0x00 (BRK instruction)
	for (i=0; i<1024; i++) Kim1Ram[i]=0x00;		

	// Copy BIOS from internal EEPROM to RAM
	eeprom_read_block((void *)Kim1Rom,(const void *)0, 1024);
	

	CopyTestCode();

	for (;;) {
		// Turn of cpu-led and Start emulator 
		CpuLed(0);
		Emulate();
		CpuLed(1);
		WaitResetRelease();

		slot=0;
		mode=0;
		waitrelease=0;
		for (;;) {
			k=GetKey();

			if (k==255) waitrelease=0;			// NO KEY

			if (k==22) break;					// RESET = GO BACK TO EMULATION
				
			if (k==19 && !waitrelease) {		// GO = DO THE SAVE OR LOAD
				display[1]=charMap[' '-32];
				display[2]=0x80;
				display[3]=0x80;
				display[4]=0x80;
				display[5]=0x80;
				for (i=0; i<1500; i++) {
					ScanDisplay();
					dly(1);
				}
				if (mode==0) {		// Read 1K from EEPROM
					display[0]=charMap['L'-32];
					res=LoadFromEEprom(slot);
				} else {			// Write 1K to EEPROM
					display[0]=charMap['S'-32];
					res=SaveToEEprom(slot);
				}
				if (res==1) {
					display[2]=charMap['D'-32];
					display[3]=charMap['O'-32];
					display[4]=charMap['N'-32];
					display[5]=charMap['E'-32];
				} else {
					display[2]=charMap[' '-32];
					display[3]=charMap['E'-32];
					display[4]=charMap['R'-32];
					display[5]=charMap['R'-32];
				}				
				for (i=0; i<1500; i++) {
					ScanDisplay();
					dly(1);
				}					
			}

			if (k==21 && !waitrelease) {		// ST = TOGGLE SAVE/LOAD MODE
				mode=1-mode;
				waitrelease=1;
			}

			if (k==18 && !waitrelease) {		// + = INCREMENT SLOT # 00..29
				slot++;
				if (slot==30) slot=0;
				waitrelease=1;
			}

			if (k<10 && !waitrelease) {			// 0..9 = CHANGE SLOT #
				slot=slot%10;
				if (slot>2) slot=2;
				slot=slot*10;
				slot=slot+k;
				waitrelease=1;
			}

			if (mode==0) {
				display[0]=charMap['L'-32];
				display[1]=charMap['O'-32];
				display[2]=charMap['A'-32];
				display[3]=charMap[' '-32];
				display[4]=charMap[16+(slot/10)];
				display[5]=charMap[16+(slot%10)];
			}
			if (mode==1) {
				display[0]=charMap['S'-32];
				display[1]=charMap['T'-32];
				display[2]=charMap['O'-32];
				display[3]=charMap[' '-32];
				display[4]=charMap[16+(slot/10)];
				display[5]=charMap[16+(slot%10)];
			}
			
			ScanDisplay();
			dly(1);
		}		
		CpuLed(0);
		WaitResetRelease();
	}	
}