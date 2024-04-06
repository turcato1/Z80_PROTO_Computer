#pragma once

// ** ROTINA SET BIT DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
void set(char port_bit);
	
// ** ROTINA RESET/CLEAR BIT DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
void rst(char port_bit);

// ** ROTINA OUT SAÍDA DIGITAL DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
void out(char port_bit, bool wr_state);

// ** ROTINA LER ENTRADA DIGITAL DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
bool rdin(char port_bit);
