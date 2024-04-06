//****************************************
//*  PROGRAMA DE TESTE LCD + M82C55A     *
//* Autor: Thiago T. Rego                *
//* Data: 16/01/2024                     *
//****************************************

// DEFINIÇÃO DOS NOMES DOS PINOS
#define pin_D0_34       A0
#define pin_D1_33       A1
#define pin_D2_32       A2
#define pin_D3_31       A3
#define pin_D4_30       A4
#define pin_D5_29       A5
#define pin_D6_28       A6
#define pin_D7_27       A7

#define portC_lcd_RS    A0
#define portC_lcd_RW    A1
#define portC_lcd_E     A2

#define pin_WR_36       8
#define pin_A0_9        9
#define pin_A1_8        10
#define pin_CS_6        11
#define pin_RD_5        12

#define pin_LED         13


void selectPortA(){
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_A0_9, LOW);
  digitalWrite(pin_A1_8, LOW);
}

void selectPortB(){
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_A0_9, HIGH);
  digitalWrite(pin_A1_8, LOW);
}

void selectPortC(){
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_A0_9, LOW);
  digitalWrite(pin_A1_8, HIGH);
}

void lcdCmd(){
  selectPortC();
  PORTF = 0x04;
  portWrite();
  PORTF = 0x00;
  portWrite();
}

void lcdTxt(){
  selectPortC();
  PORTF = 0x05;
  portWrite();
  PORTF = 0x00;
  portWrite();
}

void portWrite(){
  digitalWrite(pin_WR_36, LOW);
  digitalWrite(pin_WR_36, HIGH);
}


void setup() {
  // Set pins as output for allowing 8255 to be configured
  pinMode(pin_D0_34, OUTPUT);
  pinMode(pin_D1_33, OUTPUT);
  pinMode(pin_D2_32, OUTPUT);
  pinMode(pin_D3_31, OUTPUT);
  pinMode(pin_D4_30, OUTPUT);
  pinMode(pin_D5_29, OUTPUT);
  pinMode(pin_D6_28, OUTPUT);
  pinMode(pin_D7_27, OUTPUT);

  pinMode(pin_WR_36, OUTPUT);
  pinMode(pin_A0_9, OUTPUT);
  pinMode(pin_A1_8, OUTPUT);
  pinMode(pin_CS_6, OUTPUT);
  pinMode(pin_RD_5, OUTPUT);

  pinMode(pin_LED, OUTPUT);

  // Set all control pins to HIGH, so cancelling initially their functions (as they are bar type activated)
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_A0_9, HIGH);
  digitalWrite(pin_A1_8, HIGH);
  digitalWrite(pin_CS_6, HIGH);
  digitalWrite(pin_RD_5, HIGH);

  digitalWrite(pin_LED, LOW);

  delay(1); //Time before 8255 setup

// M82C55A Setup
// Ports A, B and C as OUTPUTS, mode 0
  digitalWrite(pin_D0_34, LOW);
  digitalWrite(pin_D1_33, LOW);
  digitalWrite(pin_D2_32, LOW);
  digitalWrite(pin_D3_31, LOW);
  digitalWrite(pin_D4_30, LOW);
  digitalWrite(pin_D5_29, LOW);
  digitalWrite(pin_D6_28, LOW);
  digitalWrite(pin_D7_27, HIGH); //Control word for definition of inputs/outputs
// Write the settings to control register
  digitalWrite(pin_RD_5, HIGH);
  digitalWrite(pin_A0_9, HIGH);
  digitalWrite(pin_A1_8, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_WR_36, LOW);
  delay(1); //Time after 8255 setup
// Put control pins in desable state
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_RD_5, HIGH);

// LCD setup via Port A (data) and C (control)
 
  selectPortA();
  PORTF = 0x38;       //8 bit mode
  portWrite();
  lcdCmd();
 
  selectPortA();
  PORTF = 0x80;       //select 1st column and 1st row for data
  portWrite();
  lcdCmd();

  selectPortA();
  PORTF = 0x0C;       //cursor off
  portWrite();
  lcdCmd();

  selectPortA();
  PORTF = 0x06;       //cursor increment
  portWrite();
  lcdCmd();

  selectPortA();
  PORTF = 0x01;       //clear LCD
  portWrite();
  lcdCmd();

}

void loop() {

// Write text to LCD

 selectPortA();
  PORTF = 0x80;       //select 1st column and 1st row for data
  portWrite();
  lcdCmd();

  selectPortA();
  PORTF = ' ';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = ' ';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = ' ';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = ' ';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = 'Z';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = '8';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = '0';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = ' ';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = 'C';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = 'O';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = 'O';
  portWrite();
  lcdTxt();

  selectPortA();
  PORTF = 'L';
  portWrite();
  lcdTxt();


/*
*/

}
