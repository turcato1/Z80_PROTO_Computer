
#include <avr/io.h>
#include <stdbool.h>

/* Function to initialize master */
void I2C_init_master(void){
	TWBR=0x02; //0x01; // Bit rate
	TWSR=(1<<TWPS1)|(0<<TWPS0); //(0<<TWPS1)|(0<<TWPS0); // Setting prescalar bits
	// SCL freq= F_CPU/(16+2(TWBR).4^TWPS)
 }

 /* Function to start I2C communication */
 void I2C_start(void){
	// Clear TWI interrupt flag, Put start condition on SDA, Enable TWI
	TWCR = (1<<TWINT)|(1<<TWSTA)|(1<<TWEN);
	while(!(TWCR & (1<<TWINT)));
	while((TWSR & 0xF8)!= 0x08); // Check for the acknowledgment
}

/* Function to repeatedly start I2C communication without stop */
 void I2C_repeated_start(void){
	// Clear TWI interrupt flag, Put start condition on SDA, Enable TWI
	TWCR= (1<<TWINT)|(1<<TWSTA)|(1<<TWEN);
	while(!(TWCR & (1<<TWINT))); // wait till restart condition is transmitted
	while((TWSR & 0xF8)!= 0x10); // Check for the acknowledgment
 }
 
/* Function to designate slave address in I2C line comm */
 void I2C_write_address(unsigned char I2C_address){
	TWDR=I2C_address; // Address and write instruction
	TWCR=(1<<TWINT)|(1<<TWEN);    // Clear TWI interrupt flag,Enable TWI
	while(!(TWCR & (1<<TWINT))); // Wait till complete TWDR byte transmitted
	while((TWSR & 0xF8)!= 0x18);  // Check for the acknowledgment
 }

/* Function to designate read address in I2C line comm */
 void I2C_read_address(unsigned char I2C_address){
	TWDR = I2C_address; // Address and read instruction
	TWCR = (1<<TWINT)|(1<<TWEN);    // Clear TWI interrupt flag,Enable TWI
	while(!(TWCR & (1<<TWINT))); // Wait till complete TWDR byte received
	while((TWSR & 0xF8)!= 0x40);  // Check for the acknowledgment
 }

/* Function to designate slave address in I2C line comm */
void I2C_write_data(unsigned char data){
	TWDR = data; // put data in TWDR
	TWCR = (1<<TWINT)|(1<<TWEN);    // Clear TWI interrupt flag,Enable TWI
	while(!(TWCR & (1<<TWINT))); // Wait till complete TWDR byte transmitted
	while((TWSR & 0xF8) != 0x28); // Check for the acknowledgment
}

/* Function to read data from slave address in I2C line comm */
unsigned char I2C_read_data(void){

unsigned char recv_data;

	TWCR = (1<<TWINT)|(1<<TWEN);    // Clear TWI interrupt flag,Enable TWI
	while(!(TWCR & (1<<TWINT))); // Wait till complete TWDR byte transmitted
	while((TWSR & 0xF8) != 0x58); // Check for the acknowledgment
	recv_data = TWDR;
	return recv_data;
}

/* Function to stop I2C line comm */
void I2C_stop(void){
	// Clear TWI interrupt flag, Put stop condition on SDA, Enable TWI
	TWCR = (1<<TWINT)|(1<<TWEN)|(1<<TWSTO);
	while(!(TWCR & (1<<TWSTO)));  // Wait till stop condition is transmitted
}