//**********************************
//*  PROGRAMA DE TESTE M82C55A     *
//* Autor: Thiago T. Rego          *
//* Data: 16/01/2024               *
//**********************************

// DEFINIÇÃO DOS NOMES DOS PINOS
#define pin_D0_34       A0
#define pin_D1_33       A1
#define pin_D2_32       A2
#define pin_D3_31       A3
#define pin_D4_30       A4
#define pin_D5_29       A5
#define pin_D6_28       A6
#define pin_D7_27       A7

#define pin_WR_36       8
#define pin_A0_9        9
#define pin_A1_8        10
#define pin_CS_6        11
#define pin_RD_5        12

#define pin_LED         13


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
// Ports A, B and C as inputs, mode 0
  digitalWrite(pin_D0_34, HIGH);
  digitalWrite(pin_D1_33, HIGH);
  digitalWrite(pin_D2_32, HIGH);
  digitalWrite(pin_D3_31, HIGH);
  digitalWrite(pin_D4_30, HIGH);
  digitalWrite(pin_D5_29, LOW);
  digitalWrite(pin_D6_28, LOW);
  digitalWrite(pin_D7_27, HIGH); //Control word for definition of inputs/outputs

// Write the settings to control register
  digitalWrite(pin_RD_5, HIGH);
  digitalWrite(pin_A0_9, HIGH);
  digitalWrite(pin_A1_8, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_WR_36, LOW);

  delay(10); //Time after 8255 setup

  // Put control pins in desable state
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_RD_5, HIGH);

  // Change data bits to input mode to transmit to CPU input data from ports
  pinMode(pin_D0_34, INPUT);
  pinMode(pin_D1_33, INPUT);
  pinMode(pin_D2_32, INPUT);
  pinMode(pin_D3_31, INPUT);
  pinMode(pin_D4_30, INPUT);
  pinMode(pin_D5_29, INPUT);
  pinMode(pin_D6_28, INPUT);
  pinMode(pin_D7_27, INPUT);
*/

}


void selectPortA(){
  digitalWrite(pin_RD_5, HIGH);
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_A0_9, LOW);
  digitalWrite(pin_A1_8, LOW);
}

void selectPortB(){
  digitalWrite(pin_RD_5, HIGH);
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_A0_9, HIGH);
  digitalWrite(pin_A1_8, LOW);
}

void selectPortC(){
  digitalWrite(pin_RD_5, HIGH);
  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_CS_6, LOW);
  digitalWrite(pin_A0_9, LOW);
  digitalWrite(pin_A1_8, HIGH);
}


// the loop function runs over and over again forever
void loop() {

  //digitalWrite(A0, HIGH);
  PORTF = 0xAA;
  digitalWrite(13, HIGH);
  delay(500);
  //digitalWrite(A0, LOW);
  PORTF = 0x55;
  digitalWrite(13, LOW);
  delay(500);

/*
bool readstate;

  selectPortA();
  digitalWrite(pin_RD_5, LOW);
  readstate = digitalRead(pin_D0_34);
  digitalWrite(pin_RD_5, HIGH);

  digitalWrite(pin_LED, readstate);
*/

}
