#pragma once

/* Function to initialize master */
void I2C_init_master(void);

/* Function to start I2C communication */
void I2C_start(void);

/* Function to repeatedly start I2C communication without stop */
void I2C_repeated_start(void);

/* Function to designate slave address in I2C line comm */
void I2C_write_address(unsigned char I2C_address);

/* Function to designate read address in I2C line comm */
void I2C_read_address(unsigned char I2C_address);

/* Function to designate slave address in I2C line comm */
void I2C_write_data(unsigned char data);

/* Function to read data from slave address in I2C line comm */
unsigned char I2C_read_data(void);

/* Function to stop I2C line comm */
void I2C_stop(void);

