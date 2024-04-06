/*
 * LCD_teste.c
 *
 * Created: 04/05/2019 14:48:24
 * Author : Familia
 */ 

#define F_CPU 8000000UL									//Clock CPU = 8 MHz

#include <avr/io.h>
#include <avr/eeprom.h>
#include <stdbool.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "Lib/Port_bool_RW.h"
#include "Lib/I2C.h"
#include "Lib/dataconv.h"

#define oRS				0xB0
#define oRW				0xB1
#define oEnab			0xB2

#define LCD_DB			0x42
#define LCD_RS_RW_E		0x40


void lcd_cmd(unsigned char cmd){
	PORTA = cmd;
	rst(oRS);
	rst(oRW);
	set(oEnab);
	_delay_ms(10);
	rst(oEnab);
}

void lcd_data(unsigned char data){
	PORTA = data;
	
	set(oRS);
	rst(oRW);
	set(oEnab);
	_delay_ms(10);
	rst(oEnab);
}

void lcd_init(){
	lcd_cmd(0x38);  //8 bit mode
	lcd_cmd(0x0E);  //enable cursor
	lcd_cmd(0x06);  //cursor increment
	lcd_cmd(0x01);  //clear lcd
	lcd_cmd(0x80);  //select 1st column and 1st row for data
}

int main(void)
{
	unsigned char teste_io = 0;
	unsigned char i = 0;

	DDRA = 0xFF;
	DDRB = 0xFF;	

	lcd_init();

    /* Replace with your application code */
    while (1)
    {
		
		teste_io |= (1<<i);
		_delay_ms(1000);
		PORTA = teste_io;
		teste_io &= ~(1<<i);
		_delay_ms(1000);
		PORTA = teste_io;
		i++;

    }
}

