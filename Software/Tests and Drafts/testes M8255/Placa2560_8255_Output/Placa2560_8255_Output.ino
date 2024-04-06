//**********************************
//*  PROGRAMA DE TESTE M82C55A     *
//* Autor: Thiago T. Rego          *
//* Data: 16/01/2024               *
//**********************************

// DEFINIÇÃO DOS NOMES DOS PINOS
#define pin_D0_34       22
#define pin_D1_33       23
#define pin_D2_32       24
#define pin_D3_31       25
#define pin_D4_30       26
#define pin_D5_29       27
#define pin_D6_28       28
#define pin_D7_27       29

#define pin_WR_36       8
#define pin_A0_9        9
#define pin_A1_8        10
#define pin_CS_6        11
#define pin_RD_5        12

#define pin_LED         13


void setup() {
  // CONFIGURAÇÃO DOS PINOS
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
  

  // ESTADO INICIAL DOS PINOS
  digitalWrite(pin_D0_34, HIGH);
  digitalWrite(pin_D1_33, HIGH);
  digitalWrite(pin_D2_32, HIGH);
  digitalWrite(pin_D3_31, HIGH);
  digitalWrite(pin_D4_30, HIGH);
  digitalWrite(pin_D5_29, HIGH);
  digitalWrite(pin_D6_28, HIGH);
  digitalWrite(pin_D7_27, HIGH);

  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_A0_9, HIGH);
  digitalWrite(pin_A1_8, HIGH);
  digitalWrite(pin_CS_6, HIGH);
  digitalWrite(pin_RD_5, HIGH);

  digitalWrite(pin_LED, LOW);

  delay(100); //Time before 8255 setup

// M82C55A Setup
// Ports A, B and C as outputs, mode 0
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

  delay(100); //Time before 8255 setup

  digitalWrite(pin_WR_36, HIGH);
  digitalWrite(pin_RD_5, HIGH);

}


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


// the loop function runs over and over again forever
void loop() {

  selectPortA();
  digitalWrite(pin_D0_34, LOW);
  digitalWrite(pin_D1_33, LOW);
  digitalWrite(pin_D2_32, LOW);
  digitalWrite(pin_D3_31, LOW);
  digitalWrite(pin_D4_30, LOW);
  digitalWrite(pin_D5_29, LOW);
  digitalWrite(pin_D6_28, LOW);

  digitalWrite(pin_WR_36, LOW);
  digitalWrite(pin_WR_36, HIGH);


  selectPortB();
  digitalWrite(pin_D0_34, LOW);
  digitalWrite(pin_D1_33, LOW);
  digitalWrite(pin_D2_32, LOW);
  digitalWrite(pin_D3_31, LOW);
  digitalWrite(pin_D4_30, LOW);
  digitalWrite(pin_D5_29, LOW);
  digitalWrite(pin_D6_28, LOW);

  digitalWrite(pin_WR_36, LOW);
  digitalWrite(pin_WR_36, HIGH);


  selectPortC();
  digitalWrite(pin_D0_34, LOW);
  digitalWrite(pin_D1_33, LOW);
  digitalWrite(pin_D2_32, LOW);
  digitalWrite(pin_D3_31, LOW);
  digitalWrite(pin_D4_30, LOW);
  digitalWrite(pin_D5_29, LOW);
  digitalWrite(pin_D6_28, LOW);

  digitalWrite(pin_WR_36, LOW);
  digitalWrite(pin_WR_36, HIGH);


  digitalWrite(pin_LED, LOW);
  delay(500);              

  selectPortA();
  digitalWrite(pin_D0_34, HIGH);
  digitalWrite(pin_D1_33, HIGH);
  digitalWrite(pin_D2_32, HIGH);
  digitalWrite(pin_D3_31, HIGH);
  digitalWrite(pin_D4_30, HIGH);
  digitalWrite(pin_D5_29, HIGH);
  digitalWrite(pin_D6_28, HIGH);

  digitalWrite(pin_WR_36, LOW);
  digitalWrite(pin_WR_36, HIGH);


  selectPortB();
  digitalWrite(pin_D0_34, HIGH);
  digitalWrite(pin_D1_33, HIGH);
  digitalWrite(pin_D2_32, HIGH);
  digitalWrite(pin_D3_31, HIGH);
  digitalWrite(pin_D4_30, HIGH);
  digitalWrite(pin_D5_29, HIGH);
  digitalWrite(pin_D6_28, HIGH);

  digitalWrite(pin_WR_36, LOW);
  digitalWrite(pin_WR_36, HIGH);


  selectPortC();
  digitalWrite(pin_D0_34, HIGH);
  digitalWrite(pin_D1_33, HIGH);
  digitalWrite(pin_D2_32, HIGH);
  digitalWrite(pin_D3_31, HIGH);
  digitalWrite(pin_D4_30, HIGH);
  digitalWrite(pin_D5_29, HIGH);
  digitalWrite(pin_D6_28, HIGH);

  digitalWrite(pin_WR_36, LOW);
  digitalWrite(pin_WR_36, HIGH);


  digitalWrite(pin_LED, HIGH);
  delay(500);
}
