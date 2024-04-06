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

unsigned char bit_set(unsigned char varbyte, unsigned char bit_numb){
	unsigned char varbyte_temp = 0;
	
	varbyte_temp = varbyte;
	varbyte_temp |= (1<<bit_numb);
	return varbyte_temp;
}

unsigned char bit_rst(unsigned char varbyte, unsigned char bit_numb){
	unsigned char varbyte_temp = 0;
	
	varbyte_temp = varbyte;
	varbyte_temp &= ~(1<<bit_numb);
	return varbyte_temp;
}


void lcd_cmd(unsigned char cmd){
	
	I2C_write_address(LCD_DB);								// Function to write address and data direction bit(write) on SDA
	I2C_write_data(cmd);									// Function to write data in slave
	I2C_repeated_start();	
	I2C_write_address(LCD_RS_RW_E);								// Function to write address and data direction bit(write) on SDA
	I2C_write_data(0x01);									// Function to write data in slave
	I2C_repeated_start();
	_delay_ms(10);
	I2C_write_address(LCD_RS_RW_E);								// Function to write address and data direction bit(write) on SDA
	I2C_write_data(0x00);									// Function to write data in slave
	I2C_repeated_start();
}

void lcd_data(unsigned char data){

	I2C_write_address(LCD_DB);								// Function to write address and data direction bit(write) on SDA
	I2C_write_data(data);									// Function to write data in slave
	I2C_repeated_start();
	I2C_write_address(LCD_RS_RW_E);								// Function to write address and data direction bit(write) on SDA
	I2C_write_data(0x05);										// Function to write data in slave
	I2C_repeated_start();
	_delay_ms(10);
	I2C_write_address(LCD_RS_RW_E);								// Function to write address and data direction bit(write) on SDA
	I2C_write_data(0x04);									// Function to write data in slave
	I2C_repeated_start();

	
}

void lcd_init(){

	lcd_cmd(0x38);  //8 bit mode - Function Set
	lcd_cmd(0x0C);  //enable cursor - Display ON/OFF control
//	lcd_cmd(0x0E);  //enable cursor - Display ON/OFF control
//	lcd_cmd(0x06);  //cursor increment
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
	I2C_init_master();								// Função de preparo do mestre da comunicação I2C (via pinos 22/23 SCL/SDA) - Display
	I2C_start();									// Função de inicialização da comunicação I2C - Display
	lcd_init();
	i = 0;
	
    /* Replace with your application code */
    while (1)
    {
		
	lcd_cmd(0x80 | 0x05);
	lcd_data('a');
	_delay_ms(1000);
		
	//I2C_write_address(LCD_RS_RW_E);				// Function to write address and data direction bit(write) on SDA
	//I2C_write_data(i);							// Function to write data in slave
	//I2C_repeated_start();
	//_delay_ms(1000);
	//PORTA = i;
	//i++;
		

    }
}

