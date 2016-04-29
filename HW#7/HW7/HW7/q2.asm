/*
 * q2.asm
 *
 *  Created: 4/28/2016 1:21:59 PM
 *   Author: siavash
 */ 

.include "m8_lcd_4bit.inc"

.org 0x00
reset:
	jmp reset_isr

.org 0x1C
adc_conversion_complete:
	jmp adc_conversion_complete_isr

reset_isr:
	cli
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r17, HIGH(RAMEND)
	out SPH, r17

	in temp, ADMUX
	ori temp, (1 <<REFS1) | (1 << REFS0)
	out ADMUX, temp

	in temp, ADCSRA
	ori temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0) | (1 << ADSC) | (1 << ADIE) | (1 << ADATE)
	out ADCSRA, temp

	ldi temp, (0 << ADTS2) | (0 << ADTS1) | (0 << ADTS0)
	out SFIOR, temp

	rcall LCD_init

	sei
	jmp start

adc_conversion_complete_isr:
	cli

	in temp, ADCL
	mov zl, temp
	in temp, ADCH
	mov zh, temp
	// divide z by two
	rcall divide_by_4

	// print on lcd...

	// mast mali :D
	sbi ADCSRA, ADSC

	sei
	reti

divide_by_4:
	asr zh
	ror zl
	asr zh
	ror zl
	ret

start:
	rjmp start