
#include <avr/io.h>
#include <stdbool.h>

// ** ROTINA SET BIT DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
 void set(char port_bit){
	 char nb_bit;
	 char nb_port;

	 nb_bit = port_bit & 0x0F;
	 nb_port = (port_bit & 0xF0)/16;

	 switch (nb_port){
		 case 0x0A:
		 PORTA |= (1<<nb_bit);
		 break;
		 
		 case 0x0B:
		 PORTB |= (1<<nb_bit);
		 break;

		 case 0x0C:
		 PORTC |= (1<<nb_bit);
		 break;

		 case 0x0D:
		 PORTD |= (1<<nb_bit);
		 break;

		 default:
		 break;
	 }
 }

 // ** ROTINA RESET/CLEAR BIT DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
 void rst(char port_bit){
	 char nb_bit;
	 char nb_port;

	 nb_bit = port_bit & 0x0F;
	 nb_port = (port_bit & 0xF0)/16;

	 switch (nb_port){
		 case 0x0A:
		 PORTA &= ~(1<<nb_bit);
		 break;
		 
		 case 0x0B:
		 PORTB &= ~(1<<nb_bit);
		 break;

		 case 0x0C:
		 PORTC &= ~(1<<nb_bit);
		 break;

		 case 0x0D:
		 PORTD &= ~(1<<nb_bit);
		 break;

		 default:
		 break;
	 }
 }

 // ** ROTINA OUT SAÍDA DIGITAL DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
 void out(char port_bit, bool wr_state){
	 if(wr_state){
		 set(port_bit);
		 }else{
		 rst(port_bit);
	 }
 }

  // ** ROTINA LER ENTRADA DIGITAL DE UM PORT, port_bit = 0x<port><bit>, ex.: 0xB0 = bit 0 do PORT B **
  bool inp(char port_bit){
	  char nb_bit;
	  char nb_port;
	  
	  nb_bit = port_bit & 0x0F;
	  nb_port = (port_bit & 0xF0)/16;

	  switch (nb_port){
		  case 0x0A:
			return ((PINA & (1<<nb_bit)) == 0);
		  break;
		  
		  case 0x0B:
			return ((PINB & (1<<nb_bit)) == 0);
		  break;

		  case 0x0C:
			return ((PINC & (1<<nb_bit)) == 0);
		  break;

		  case 0x0D:
			return ((PIND & (1<<nb_bit)) == 0);
		  break;

		  default:
			return false;
		  break;
	  }
  }