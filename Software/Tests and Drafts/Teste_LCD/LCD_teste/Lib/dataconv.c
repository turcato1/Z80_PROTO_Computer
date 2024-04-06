#include <avr/io.h>
#include <stdbool.h>


// ** Converte DEC->BCD com 2 dígitos **
unsigned char dec2bcd(unsigned char num_dec){
	if (num_dec <= 99) {
			return ((num_dec/10 * 16) + (num_dec % 10));
	} else {
		return 0;
	}
}

// ** Converte DEC->BCD com 4 dígitos  **
unsigned short dec2bcd4(unsigned short num_dec){
	unsigned short BCD4_data;
	if (num_dec <= 9999) {
		BCD4_data = (num_dec/1000) * 4096;						//Extrai o milhar e converte para BCD
		BCD4_data = (((num_dec/100) % 10) * 256) | BCD4_data;   //Extrai a centena, converte para BCD e junta com o anterior
		BCD4_data = (((num_dec/10) % 10) * 16) | BCD4_data;		//Extrai a dezena, converte para BCD e junta com o anterior
		BCD4_data = ((num_dec) % 10) | BCD4_data;				//Extrai a unidade, converte para BCD e junta com o anterior
		return BCD4_data;
		} else {
		return 0;
	}
}

// ** Converte BCD->DEC **
unsigned char bcd2dec(unsigned char num_bcd){
	return ((num_bcd/16 * 10) + (num_bcd % 16));
}