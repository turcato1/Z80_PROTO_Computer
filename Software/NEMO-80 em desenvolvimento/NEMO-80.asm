;=========================================================================================================================
; Thiago Turcato do Rego - 2024
; Project: NEMO-80 for Z80 Proto, New Monitor for Z80 Proto Versão 1.1
; File: NEMO-80.asm
;=========================================================================================================================

;========================================= TERMINOLOGIAS, CONVENÇÕES E ORGANIZAÇÃO =======================================
; 
; -- CONVENÇÕES DE SÍMBOLOS --
; - Símbolos em LETRAS MAIUSCULAS = constantes (podem ser constantes que indicam uma posição de memória)
; - Labels que começam com "." são entradas locais dentro de uma rotina
; - Labels que começam com "_" são subrotinas auxiliares locais (úteis apenas para outra subrotina)
; - Labels que iniciam com "sys_" são subrotinas de sistema, que podem ser usadas pelo usuário (leitura de teclado etc.)
; - Labels outros são do programa monitor e também podem ser chamados pelo usuário
;
;==========================================================================================================================

; Diretivas de compilação para alocação de memória e geração de arquivo SLD para o simulador DeZog de CPU Z80 (VSCode)
 DEVICE NOSLOT64K
 SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION    

;******** Definição de constantes ********
; Endereço inicial da ROM e tamanho (8 KiB = 8192 bytes, 0000H ~ 1FFFH)
ROMBEGIN        EQU 0000H
ROMSIZE         EQU 2000H

; Endereço inicial da EEPROM e tamanho (8 KiB = 8192 bytes, 2000H ~ 3FFFH)
EEPBEGIN        EQU 2000H
EEPSIZE         EQU 2000H

; Endereço inicial da RAM e tamanho (8 KiB = 8192 bytes, 4000H ~ 5FFFH)
RAMBEGIN        EQU 4000H
RAMSIZE         EQU 2000H

; Frequencia de clock de sistema 
CLKSYS          EQU 4000000


; Constantes de codificação para exibição de caracteres no display do Z80 PROTO
/*
CHR_0           EQU '0'
CHR_1           EQU '1'
CHR_2           EQU '2'
CHR_3           EQU '3'
CHR_4           EQU '4'
CHR_5           EQU '5'
CHR_6           EQU '6'
CHR_7           EQU '7'
CHR_8           EQU '8'
CHR_9           EQU '9'
CHR_A           EQU 'A'
CHR_B           EQU 'B'
CHR_C           EQU 'C'
CHR_D           EQU 'D'
CHR_E           EQU 'E'
CHR_F           EQU 'F'
CHR_G           EQU 082H
CHR_H           EQU 089H
CHR_I           EQU 0F9H
CHR_J           EQU 0E1H
CHR_L           EQU 0C7H
CHR_M           EQU 0AAH
CHR_N           EQU 0C8H
CHR_O           EQU 0C0H
CHR_P           EQU 08CH
CHR_Q           EQU 098H
CHR_R           EQU 0AFH
CHR_S           EQU 092H
CHR_T           EQU 087H
CHR_U           EQU 0C1H
CHR_EQUAL       EQU 0B7H
*/

; Constantes dos códigos das teclas, devolvido pela subrotina "sys_keyb_disp"
; (essas constantes foram consideradas SEM o bit 7 setado - indicador de tecla pressionada)
KEY_0           EQU 000H
KEY_1           EQU 001H
KEY_2           EQU 002H
KEY_3           EQU 003H
KEY_4           EQU 004H
KEY_5           EQU 005H
KEY_6           EQU 006H
KEY_7           EQU 007H
KEY_8           EQU 008H
KEY_9           EQU 009H
KEY_A           EQU 00AH
KEY_B           EQU 00BH
KEY_C           EQU 00CH
KEY_D           EQU 00DH
KEY_E           EQU 00EH
KEY_F           EQU 00FH
KEY_ADR         EQU 010H
KEY_DAT         EQU 011H
KEY_MINUS       EQU 012H
KEY_PLUS        EQU 013H
KEY_GO          EQU 014H
KEY_REG         EQU 015H
KEY_IV          EQU 016H
KEY_EMPTY       EQU 017H


; Endereços de I/O (I/O ports)
;DISP            EQU 01H
;SEL_DISP        EQU 03H
;KEYB            EQU 01H

IO_LCD_CHAR         EQU 20H
IO_KEYB             EQU 21H
IO_LCDKEYB_CTRL     EQU 22H
IO_DSKY_SET         EQU 23H

IO_CTC0             EQU 30H
IO_CTC1             EQU 31H
IO_CTC_SERIAL       EQU 32H
IO_CTC3             EQU 33H

IO_SERIAL_A_D       EQU 40H         ; Endereço SIO "A", dados
IO_SERIAL_A_C       EQU 42H         ; Endereço SIO "A", controle          
IO_SERIAL_B_D       EQU 40H         ; Endereço SIO "B", dados
IO_SERIAL_B_C       EQU 42H         ; Endereço SIO "B", controle          


; Constantes indicativas de endereços de memória
;
; RESERVADO PARA SISTEMA: END. 5E00H ~ 5FFFH

; RAM para sistema até 27FF
RAM_SYS_START   EQU 5E00H    ; Inicio da área de RAM reservada para sistema

RAM_DRAFT1      EQU 5F58H    ; Área de rascunho para as subrotinas      
RAM_DRAFT2      EQU 5F59H    ; Área de rascunho para as subrotinas
RAM_DRAFT3      EQU 5F5AH    ; Área de rascunho para as subrotinas
RAM_DRAFT4      EQU 5F5BH    ; Área de rascunho para as subrotinas
RAM_DRAFT5      EQU 5F5CH    ; Área de rascunho para as subrotinas
RAM_KEYB_CONV   EQU 5F5DH    ; Código da tecla pressionada já decodificado de 00H a 17H (24 teclas)
RAM_KEYBOARD    EQU 5F5EH    ; Valor binário na matriz da tecla pressionada
RAM_KEYB_COL    EQU 5F5FH    ; Coluna selecionada na varredura do teclado
RAM_DISPLAY     EQU 5F60H    ; Caracteres a serem exibidos no display pos. 2760H a 277FH

; Stack (pilha de dados) = 2780H a 27FFH
RAM_STACK_127   EQU 5F80H
RAM_STACK_TOP   EQU 5FFFH

; Variáveis do programa, do endereço 5DFF para trás (128 bytes)
VAR_REG_A       EQU 5DF0H
VAR_REG_B       EQU 5DF1H
VAR_REG_C       EQU 5DF2H
VAR_REG_D       EQU 5DF3H
VAR_REG_E       EQU 5DF4H
VAR_REG_F       EQU 5DF5H
VAR_REG_H       EQU 5DF6H
VAR_REG_L       EQU 5DF7H
VAR_REG_I       EQU 5DF8H
VAR_REG_R       EQU 5DF9H
VAR_REG_SPL     EQU 5DFAH
VAR_REG_SPH     EQU 5DFBH
VAR_TEST        EQU 5DFCH
VAR_CURR_ADDRL  EQU 5DFEH
VAR_CURR_ADDRH  EQU 5DFFH

;******** Início do programa monitor ********
    ORG ROMBEGIN
    JP main                     ; Salta pontos de entrada de interrupção e vai para o programa principal

; Pontos de entrada de interrupções
    BLOCK 0038H-$, 0FFH
    ORG 0038H
    NOP                         ; Espaço para tratamento de interrupções (não implementado)

    BLOCK 0066H-$, 0FFH
    ORG 0066H
    NOP                         ; Espaço para tratamento de interrupções (não implementado)

    HALT                        ; HALT para segurança, caso a execução da interrupção possa vazar

; ********************** Programa principal **********************
main:
; Ajustes e configuração iniciais
    LD SP,RAM_STACK_TOP                ; Ajusta o stack pointer (pilha de dados) no fim da memória RAM. Considerado 128 bytes de stack 2780 até 27FF

; Inicializações antes do programa
initialization:
    CALL isys_clean_ram_disp     ; Limpa a memória de exibição no display
    CALL isys_lcd_clear          ; Limpa o LCD
    CALL isys_lcd_cursor_off     ; Desliga cursor LCD

; Inicio do programa        
; RAM_DISPLAY+ = 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
; RAM_DISPLAY+ = 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
ini_program:
    LD A,'N'                  ; Mensagem de inicialização NEMO-80  Z80 PROTO
    LD (RAM_DISPLAY+4),A
    LD A,'E'                            
    LD (RAM_DISPLAY+5),A
    LD A,'M'                            
    LD (RAM_DISPLAY+6),A
    LD A,'O'                            
    LD (RAM_DISPLAY+7),A
    LD A,'-'                            
    LD (RAM_DISPLAY+8),A
    LD A,'8'                            
    LD (RAM_DISPLAY+9),A
    LD A,'0'                            
    LD (RAM_DISPLAY+10),A

    LD A,'Z'                  
    LD (RAM_DISPLAY+19),A
    LD A,'8'                            
    LD (RAM_DISPLAY+20),A
    LD A,'0'                            
    LD (RAM_DISPLAY+21),A
    LD A,' '                            
    LD (RAM_DISPLAY+22),A
    LD A,'P'                            
    LD (RAM_DISPLAY+23),A
    LD A,'R'                            
    LD (RAM_DISPLAY+24),A
    LD A,'O'                            
    LD (RAM_DISPLAY+25),A
    LD A,'T'                            
    LD (RAM_DISPLAY+26),A
    LD A,'O'                            
    LD (RAM_DISPLAY+27),A

loop_main_menu:                 ; Rotina de menu inicial
    CALL isys_keyb_disp
    LD A,(RAM_KEYB_CONV)        ; Lê memória de tecla pressionada
    RES 7,A                     ; Reseta o bit indicador de tecla pressionada
    CP 10H                      ; Se pressionada tecla ADR, chama entrada de endereço
    CALL Z, menu_addr
    CP 15H
    CALL Z, imenu_reg
    JR loop_main_menu

    BLOCK 0100H-$, 0FFH
    ORG 0100H
;
; ********************** Subroutinas ********************** 
;
; Vetores padronizados para chamada de interrupção

; Chamadas de sistema (sys) acessiveis ao usuário
sys_clean_ram_disp:
    JP  isys_clean_ram_disp      ; CALL 0100H
sys_disp_data:
    JP  isys_disp_data           ; CALL 0103H
sys_disp_addr:
    JP  isys_disp_addr           ; CALL 0106H
sys_wait_keypress:
    JP  isys_wait_keypress       ; CALL 0109H
sys_wait_keyrelease:
    JP  isys_wait_keyrelease     ; CALL 010CH
sys_in_data:
    JP  isys_in_data             ; CALL 010FH
sys_in_addr:
    JP  isys_in_addr             ; CALL 0112H
sys_conv_hexdisp:
    JP  isys_conv_hexdisp        ; CALL 0115H
sys_sftl_addr_disp:
    JP  isys_sftl_addr_disp      ; CALL 0118H
sys_sftl_data_disp:
    JP  isys_sftl_data_disp      ; CALL 011BH
sys_keyb_disp
    JP  isys_keyb_disp           ; CALL 011EH
sys_delay_ms:
    JP  isys_delay_ms            ; CALL 0121H

; Chamadas de funções do programa monitor
    BLOCK 0130H-$, 0FFH
    ORG 0130H
menu_reg:
    JP  imenu_reg                ; CALL 0130H
test_prog:
    JP  itest_prog               ; CALL 0133H

; Início da implementação das subrotinas

; Subrotina de edição/exibição dos valores dos registradores
imenu_reg:
    PUSH AF                     ; Reserva AF na pilha para poder extrair o valor de F
    LD (VAR_REG_SPL),SP         ; Guarda o valor de todos os registradores em posições de memória
    LD (VAR_REG_A),A
    LD A,B
    LD (VAR_REG_B),A
    LD A,C
    LD (VAR_REG_C),A
    LD A,D
    LD (VAR_REG_D),A
    LD A,E
    LD (VAR_REG_E),A
    LD A,H
    LD (VAR_REG_H),A
    LD A,L
    LD (VAR_REG_L),A
    LD A,I
    LD (VAR_REG_I),A
    LD A,R
    LD (VAR_REG_R),A
    LD HL,(VAR_REG_SPL)         ; Extração do valor de F: ao empurrar AF para a pilha, o valor F fica na memória na posição de SP
    LD A,(HL)                   ; Extrai o valor da posição na pilha
    LD (VAR_REG_F),A            ; Guarda o valor de F na memória
    POP AF
    CALL isys_wait_keyrelease   ; Aguarda o usuário soltar o botão REG
    CALL isys_clean_ram_disp    ; Limpa a exibição no display
    LD A,00H                    ; Zera a posição de memória DRAFT2, que será usada de rascunho
    LD (RAM_DRAFT2),A
.imenu_reg_a:                    
    LD A,CHR_EQUAL              ; Coloca um caracter de "=" no DISPLAY+3
    LD (RAM_DISPLAY+3),A
    LD A,(RAM_DRAFT2)           ; RAM_DRAFT2 contém qual o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    CP 00H
    JR NZ,.imenu_reg_b          ; Se o item atual a exibir não for A, segue para testar se é B
    LD C,CHR_A                  ; Carrega o código do caracter "A" em C para exibição no display
    LD HL,VAR_REG_A             ; Carrega em HL o endereço onde está o valor salvo do acumulador (A)
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_b:
    CP 01H
    JR NZ,.imenu_reg_c          ; Se o item atual a exibir não for B, segue para testar se é C
    LD C,CHR_B                  ; Carrega o código do caracter "B" em C para exibição no display
    LD HL,VAR_REG_B             ; Carrega em HL o endereço onde está o valor salvo do registrador B
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_c:
    CP 02H
    JR NZ,.imenu_reg_d          ; Se o item atual a exibir não for C, segue para testar se é D
    LD C,CHR_C                  ; Carrega o código do caracter "C" em C para exibição no display
    LD HL,VAR_REG_C             ; Carrega em HL o endereço onde está o valor salvo do registrador C
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_d:
    CP 03H
    JR NZ,.imenu_reg_e          ; Se o item atual a exibir não for D, segue para testar se é E
    LD C,CHR_D                  ; Carrega o código do caracter "D" em C para exibição no display
    LD HL,VAR_REG_D             ; Carrega em HL o endereço onde está o valor salvo do registrador D
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_e:
    CP 04H
    JR NZ,.imenu_reg_f          ; Se o item atual a exibir não for E, segue para testar se é F
    LD C,CHR_E                  ; Carrega o código do caracter "E" em C para exibição no display
    LD HL,VAR_REG_E             ; Carrega em HL o endereço onde está o valor salvo do registrador E
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_f:
    CP 05H
    JR NZ,.imenu_reg_h          ; Se o item atual a exibir não for F, segue para testar se é H
    LD C,CHR_F                  ; Carrega o código do caracter "F" em C para exibição no display
    LD HL,VAR_REG_F             ; Carrega em HL o endereço onde está o valor salvo do registrador F
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_h:
    CP 06H
    JR NZ,.imenu_reg_l          ; Se o item atual a exibir não for H, segue para testar se é L
    LD C,CHR_H                  ; Carrega o código do caracter "H" em C para exibição no display
    LD HL,VAR_REG_H             ; Carrega em HL o endereço onde está o valor salvo do registrador H
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_l:
    CP 07H
    JR NZ,.imenu_reg_i          ; Se o item atual a exibir não for L, segue para testar se é I
    LD C,CHR_L                  ; Carrega o código do caracter "L" em C para exibição no display
    LD HL,VAR_REG_L             ; Carrega em HL o endereço onde está o valor salvo do registrador L
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_i:
    CP 08H
    JR NZ,.imenu_reg_r          ; Se o item atual a exibir não for I, segue para testar se é R
    LD C,CHR_I                  ; Carrega o código do caracter "I" em C para exibição no display
    LD HL,VAR_REG_I             ; Carrega em HL o endereço onde está o valor salvo do registrador I
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_r:
    CP 09H
    JR NZ,.imenu_reg_sp         ; Se o item atual a exibir não for R, segue para testar se é SP
    LD C,CHR_R                  ; Carrega o código do caracter "R" em C para exibição no display
    LD HL,VAR_REG_R             ; Carrega em HL o endereço onde está o valor salvo do registrador R
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin        ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_sp:
    CP 0AH
    JP NZ,.imenu_reg_a          ; Se o item atual a exibir não for SP, retorna para o inicio do menu, em Reg. A
    LD B,CHR_S                  ; Carrega o código dos caracteres "S" e "P" em B e C para exibição no display
    LD C,CHR_P
    LD HL,VAR_REG_SPL           ; Carrega em HL o endereço onde está o valor salvo do registrador SP
    LD (RAM_DRAFT2),A           ; Salva em RAM_DRAFT2, o acumul. que contém o item atualmente exibido no menu dos registradores 00 = Reg. A ~ 0A = SP.
    JP .imenu_reg_dispin16      ; Salta para rotina de exibição ou alteração do valor do registrador
.imenu_reg_dispin:              ; Exibição ou alteração de registradores de 8 bits
    LD A,C                      ; Carrega em A o código do caractere a ser exibido nos displays de endereços
    LD (RAM_DISPLAY+2),A        ; Escreve na área de memória dos displays de endereços o valor de A
    CALL isys_disp_data         ; Chama a sub-rotina de exibição de dados nos displays de dados (dado apontado na memória por HL)
    LD A,(RAM_KEYB_CONV)        ; Atualiza a exibição do display e leitura do teclado
    BIT 7,A                     ; Testa se alguma tecla foi pressionada (bit 7 = ON, tecla foi pressionada)
    JR Z,.imenu_reg_dispin      ; Loop para rotina de exibição ou alteração do valor do registrador
    RES 7,A                     ; Retira (zera) o bit de tecla pressionada
.imenu_reg_numkey:              
    CP 0FH                      ; Verifica (pelo JR C abaixo) se a tecla pressionada é numérica, código da tecla =< 0FH
    JR C,.imenu_reg_indata      ; Pressionada tecla de valor numérico indicando alteração de valor do registrador
    JR .imenu_reg_minus         ; Não sendo tecla numérica, verifica se não é a tecla "-"
.imenu_reg_indata:              ; Ponto de entrada de tratamento de entrada numérica (tecla numérica foi apertada)
    CALL isys_wait_keyrelease   ; Aguarda usuário soltar a tecla
    CALL isys_in_data           ; Executa sub-rotina de entrada numérica para alteração do valor do registrador 
    LD A,(RAM_DRAFT2)           ; Recupera valor de onde, no menu de registradores, parou a sequencia de exibição de registradores
    JP .imenu_reg_a             ; Volta para ponto de entrada de exibição dos registradores nos displays
.imenu_reg_minus:               
    CP 12H                      ; Verifica (escapa do JR NZ abaixo) se a tecla pressionada é tecla "-", código da tecla = 12H
    JR NZ,.imenu_reg_plus       ; Não sendo tecla "-", verifica se não é a tecla "+" 
    LD A,(RAM_DRAFT2)           ; Recupera valor de onde, no menu de registradores, parou a sequencia de exibição de registradores
    CP 00H                      ; Verifica se já está no primeiro item do menu de registradores (índice 0)
    JR Z,.imenu_reg_nodec       ; Se já estiver no índice 0, não decrementa.
    DEC A                       ; Se não estiver no índice 0, decrementa o índice de exibição do menu de registradores
    LD (RAM_DRAFT2),A           ; Salva o índice decrementado em RAM_DRAFT2
.imenu_reg_nodec:               
    CALL isys_wait_keyrelease   ; Em caso de não decrementar por estar no índice 0, aguarda soltar a tecla
    JP .imenu_reg_a             ; Retorna para o menu de registradores, sem alterar o índice
.imenu_reg_plus:                
    CP 13H                      ; Verifica (escapa do JR NZ abaixo) se a tecla pressionada é tecla "+", código da tecla = 12H
    JR NZ,.imenu_reg_otherkey   ; Não sendo tecla "+", é outra tecla, então os registradores são atualizados com os valores de memória e o menu encerrado
    LD A,(RAM_DRAFT2)           ; Recupera valor de onde, no menu de registradores, parou a sequencia de exibição de registradores
    CP 0AH                      ; Verifica se já está no último item do menu de registradores (índice 10 (=0AH))
    JP Z,.imenu_reg_noinc       ; Se já estiver no índice 10, não incrementa.
    INC A                       ; Se não estiver no índice 10, incrementa o índice de exibição do menu de registradores
    LD (RAM_DRAFT2),A           ; Salva o índice decrementado em RAM_DRAFT2
.imenu_reg_noinc:
    CALL isys_wait_keyrelease   ; Em caso de não incrementar por estar no índice 10, aguarda soltar a tecla
    JP .imenu_reg_a             ; Retorna para o menu de registradores, sem alterar o índice
.imenu_reg_otherkey:            ; Ao finalizar a rotina dos registradores, transfere os valores manipulados na memória para registradore
    LD A,(VAR_REG_B)
    LD B,A
    LD A,(VAR_REG_C)
    LD C,A
    LD A,(VAR_REG_D)
    LD D,A
    LD A,(VAR_REG_E)
    LD E,A
    LD A,(VAR_REG_H)
    LD H,A
    LD A,(VAR_REG_L)
    LD L,A
    LD A,(VAR_REG_I)
    LD I,A
    LD A,(VAR_REG_A)
    RET
.imenu_reg_dispin16:             ; Exibição ou alteração de registradores de 16 bits
    LD A,B
    LD (RAM_DISPLAY+4),A
    LD A,C
    LD (RAM_DISPLAY+5),A
    CALL isys_disp_addr
    LD A,(RAM_KEYB_CONV)
    BIT 7,A
    JR Z,.imenu_reg_dispin16
    RES 7,A
.imenu_reg_numkey16:
    CP 0FH
    JR C,.imenu_reg_indata16
    JR .imenu_reg_minus16
.imenu_reg_indata16:
    CALL isys_wait_keyrelease
    LD A,(RAM_DRAFT2)
    JP .imenu_reg_a
.imenu_reg_minus16:
    CP 12H
    JR NZ,.imenu_reg_plus16
    LD A,(RAM_DRAFT2)
    CP 00H
    JR Z,.imenu_reg_nodec16
    DEC A
    LD (RAM_DRAFT2),A
.imenu_reg_nodec16:
    CALL isys_wait_keyrelease
    CALL isys_clean_ram_disp
    JP .imenu_reg_a
.imenu_reg_plus16:
    CP 13H
    JR NZ,.imenu_reg_otherkey
    LD A,(RAM_DRAFT2)
    CP 0AH
    JR Z,.imenu_reg_noinc16
    INC A
    LD (RAM_DRAFT2),A
.imenu_reg_noinc16:
    CALL isys_wait_keyrelease
    CALL isys_clean_ram_disp
    JP .imenu_reg_a
    DB 00H

; Subrotina de edição/exibição da memória
menu_addr:
    CALL isys_clean_ram_disp    ; Limpa a memória do display
    CALL isys_wait_keyrelease   ; Aguarda a tecla ADR ser solta
menu_addr_in:
    LD A,00H                    ; Zera as variáveis de posição de memória a ser lida ou alterada
    LD (VAR_CURR_ADDRL),A
    LD (VAR_CURR_ADDRH),A
    LD HL,VAR_CURR_ADDRL        ; Carrega como ponteiro, o endereço da variável da posição de memória a ler/alterar
    CALL isys_in_addr           ; Chama a rotina de entrada de valor do endereço
menu_wait_keypress:
    CALL isys_wait_keypress     ; Depois da entrada do endereço, aguarda tecla DAT para entrada de dados ser pressionada ou outra para sair
    RES 7,A                     ; Reseta o bit de tecla pressionada do reg. A
    CP 11H                      ; Se pressionada tecla DAT, vai para rotina de entrada de dado
    JR Z, menu_addr_data
    CP 12H                      ; Se pressionada tecla "-", vai para rotina de decremento do endereço exibido
    JR Z, menu_addr_minus
    JR menu_addr_isplus         ; Se a tecla pressionada não foi "-", verifica se foi pressionado "+"
menu_addr_minus:                ; Rotina de decremento do endereço exibido
    LD HL,(VAR_CURR_ADDRL)      ; Carrega o valor armazenado na variável do endereço exibido
    DEC HL                      ; Decrementa o valor do endereço exibido usando HL
    LD (VAR_CURR_ADDRL),HL      ; Escreve o valor decrementado na váriavel de endereço exibido
    CALL isys_wait_keyrelease   ; Aguarda o usuário soltar a tecla "-" pressionada
    LD HL,VAR_CURR_ADDRL        ; Carrega como ponteiro, o endereço da variável da posição de memória a ler/alterar
    JR menu_addr_data           ; Vai para a rotina de entrada de dado dentro do endereço exibido
menu_addr_isplus:
    CP 13H                      ; Se pressionada tecla "+", vai para rotina de incremento do endereço exibido
    JR Z, menu_addr_plus        
    JR menu_addr_isgo           ; Se a tecla pressionada não foi "-", verifica se foi pressionado "GO"
menu_addr_plus:                 ; Rotina de incremento do endereço obtido
    LD HL,(VAR_CURR_ADDRL)      ; Carrega o valor armazenado na variável do endereço exibido
    INC HL                      ; Incrementa o valor do endereço exibido usando HL
    LD (VAR_CURR_ADDRL),HL      ; Escreve o valor incrementado na váriavel de endereço exibido
    CALL isys_wait_keyrelease   ; Aguarda o usuário soltar a tecla "+" pressionada
    LD HL,VAR_CURR_ADDRL        ; Carrega como ponteiro, o endereço da variável da posição de memória a ler/alterar
    JR menu_addr_data           ; Vai para a rotina de entrada de dado dentro do endereço exibido
menu_addr_isgo:
    CP 14H                      ; Se pressionada tecla "GO", chama execução no endereço atual
    JR Z, menu_addr_go
    JR menu_addr_otherkey       ; Se a tecla pressionada não foi nenhuma das anteriores, sai do menu de endereço e volta para o menu inicial
menu_addr_go:                   ; Rotina da tecla "GO" de execução do programa a partir do endereço exibido
    LD HL,(VAR_CURR_ADDRL)      ; Carrega o endereço exibido em HL para execução
    JP HL                       ; Salta a execução para o endereço exibido
menu_addr_otherkey:
    JR menu_addr_end            ; Se outra tecla foi pressionada, que não seja "DAT", "+", "-" ou "GO", finaliza a entrada de endereço
menu_addr_data:
    LD HL,VAR_CURR_ADDRL        ; Carrega como ponteiro, o endereço da variável da posição de memória a ler/alterar
    CALL isys_disp_addr         ; Exibe o endereço/posição de memória carregado
    LD HL,(VAR_CURR_ADDRL)      ; Carrega o endereço exibido para referenciar com o dado nele existente
    CALL isys_disp_data         ; Exibe o dado contido no endereço exibido
    CALL isys_wait_keyrelease   ; Aguarda o usuário soltar a tecla "DAT" pressionada
    CALL isys_wait_keypress     ; Aguarda o usuário pressionar alguma tecla para iniciar o processo de entrada de novo dado ou sair do menu
    CALL isys_in_data           ; Processa a entrada de dado para o endereço exibido
    JR menu_wait_keypress       ; Quando finalizada a entrada, volta para o inicio do menu de endereço para testar próxima tecla pressionada
menu_addr_end:
    LD A,0FFH                   ; Carrega FFH em A, para escapar de próximas condições de tecla pressionada do menu principal
    RET                         ; Volta para o menu principal
    DB 00H

; Subrotina de limpeza da area de memoria para o display
;
isys_clean_ram_disp:            ; Inicializa area de memoria do display
    PUSH HL                     ; Reserva HL
    PUSH BC                     ; Reserva BC
    LD HL,RAM_DISPLAY           ; Inicio da RAM para display
    LD B,06                     ; Preparar ponteiro para 6 endereços a partir do inicio da RAM para display
.loop_clean_disp:               ; Inicializa area de memoria do display, com FFH (nenhum segmento aceso)
    LD (HL),0FFH                ; Limpa a exibição no display escrevendo 0FFH na posição de memória
    INC HL                      ; Coloca o ponteiro na próxima posição de memória
    DJNZ .loop_clean_disp       ; Decrementa o reg. B e, se não for zero, continua o loop de limpeza da memória
    POP BC                      ; Retoma valor reservado de BC
    POP HL                      ; Retoma valor reservado de HL
    RET
    DB 00H

; Subrotina de exibição de dados no campo de dados (isys_disp_data)
; HL (e HL+1) = posição de memória onde está o dado a ser exibido
isys_disp_data:
    PUSH BC                     ; Reserva o valor de BC (C é usado na subrotina _sys_mem_conv2nibbles)
    PUSH DE                     ; Reserva o valor de DE
    LD DE,RAM_DISPLAY+5         ; Coloca o ponteiro DE no 4.o display da esq. para a direita
    CALL _sys_mem_conv2nibbles  ; Chama função que converte os dois nibbles (LSB) do dado apontado por HL em caracteres para o display
    POP DE                      ; Retoma valor reservado de DE
    POP BC                      ; Retoma valor reservado de BC
    CALL isys_keyb_disp         ; Exibe no display o valor do endereço
    RET
    DB 00H

; Subrotina de exibição de dados no campo de endereço (isys_disp_addr)
; HL (e HL+1) = posição de memória onde está o dado a ser exibido
isys_disp_addr:
    PUSH HL
    PUSH BC                     ; Reserva o valor de BC (C é usado na subrotina _sys_mem_conv2nibbles)
    PUSH DE                     ; Reserva o valor de DE
    LD DE,RAM_DISPLAY+3         ; Coloca o ponteiro DE no 4.o display da esq. para a direita
    CALL _sys_mem_conv2nibbles  ; Chama função que converte os dois nibbles (LSB) do dado apontado por HL em caracteres para o display
    INC HL                      ; Coloca ponteiro HL na próxima posição da variável de dado
    LD DE,RAM_DISPLAY+1         ; Coloca o ponteiro DE no 2.o display da esq. para a direita
    CALL _sys_mem_conv2nibbles  ; Chama função que converte os dois nibbles (MSB) do dado apontado por HL em caracteres para o display
    POP DE                      ; Retoma valor reservado de DE
    POP BC                      ; Retoma valor reservado de BC
    CALL isys_keyb_disp         ; Exibe no display o valor do endereço
    POP HL
    RET
    DB 00H

; Subrotina auxiliar das subrotinas de exibição no display
; Converte 2 nibbles de uma posição de memória em 2 bytes para exibição no display
; HL - Posição de entrada do dado a ser separado em nibbles
; DE - Posição mais alta para escrita dos dados convertidos para display
_sys_mem_conv2nibbles
    LD A,(HL)                   ; Lê o valor contido na posição de memória apontada por HL
    AND 0FH                     ; Filtra apenas a parte menos signicativa
    CALL isys_conv_hexdisp      ; Converte a parte filtrada de hexa para o código de exibição no display
    LD A,C                      ; O código de exibição é devolvido em C. Transfere-o para A.
    LD (DE),A                   ; Carrega o valor convertido para o display na posição apontada por DE
    DEC DE
    LD A,(HL)
    SRL A
    SRL A
    SRL A
    SRL A
    CALL isys_conv_hexdisp
    LD A,C
    LD (DE),A
    RET
    DB 00H

; Subrotina para aguardar em loop uma tecla ser pressionada
; A : Código da tecla + bit de tecla pressionada
isys_wait_keypress
    CALL isys_keyb_disp         ; Exibe display e lê teclado
    LD A,(RAM_KEYB_CONV)        ; Lê a memória de tecla lida
    BIT 7,A                     ; Verifica se alguma tecla foi pressionada (digitação de um endereço, p. ex.)
    JR Z,isys_wait_keypress     ; Fica em loop até uma tecla ser pressionada
    RET
    DB 00H

; Subrotina para aguardar em loop uma tecla ser solta
; A : Código da tecla + bit de tecla pressionada
isys_wait_keyrelease
    CALL isys_keyb_disp         ; Exibe display e lê teclado
    LD A,(RAM_KEYB_CONV)        ; Lê a memória de tecla lida
    BIT 7,A
    RET Z                       ; Verifica se alguma tecla foi pressionada (digitação de um endereço, p. ex.)
    JR isys_wait_keyrelease     ; Fica em loop até uma tecla ser pressionada
    DB 00H

; Subrotina de entrada de valor no campo de dados (isys_in_data)
; O software fica preso nessa rotina até que uma tecla de 10 a 17 seja pressionada
; HL: Definição da primeira área de memória para uso com a entrada de dados (2 dígitos)
; Teclas de 0 a F = serão reproduzidas no display e atualizam o valor em (HL)
; Teclas de 10 a 17 = encerram o loop da subrotina, tecla pressionada em RAM_KEYB_CONV
;       If !(keypress.bit7) then RST keyprsmem.bit7
;       If  (keypress.bit7) &&  (keyprsmem.bit7) then end
;       If  (keypress.bit7) && !(keyprsmem.bit7) then SET keyprsmem.bit7 and process the input
isys_in_data:
    PUSH BC                     ; Guarda na pilha valor atual de BC para poder usar BC na subrotina
    LD A,0FFH
    LD (RAM_DISPLAY+4),A        ; Limpa memória de exibição do 5.o display de endereçamento
    LD (RAM_DISPLAY+5),A        ; Limpa memória de exibição do 6.o display de endereçamento
    LD A,00H
    LD (RAM_DRAFT1),A
.in_data_input_loop:
    CALL isys_keyb_disp         ; Chama atualização do display e teclado
    LD A,(RAM_KEYB_CONV)        ; Recupera tecla atualmente pressionada (keypress = RAM_KEYB_CONV)
    BIT 7,A                     ; Testa bit 7 de RAM_KEYB_CONV para verificar se alguma tecla está pressionada (keypress.bit7)
    JR Z,.in_data_rst_keyprsmem ; Bit 7 keypress é zero (tecla solta): reseta bit 7 memória (keypressmem)
    LD A,(RAM_DRAFT1)           ; Recupera memória de tecla pressionada (keyprsmem)
    BIT 7,A                     ; Testa bit 7, sinalizador de tecla pressionada anteriormente (keyprsmem.bit7)
    JR NZ,.in_data_input_loop   ; bit 7 memória não zero (setado): não faz nada, finaliza a subrotina
    SET 7,A                     ; Seta bit 7 e segue com o processamento da tecla pressionada
    LD (RAM_DRAFT1),A           ; Salva na memória de tecla pressionada (keyprsmem), que há uma tecla pressionada (bit 7 setado)
    LD A,(RAM_KEYB_CONV)        ; Recupera tecla atualmente pressionada (keypress = RAM_KEYB_CONV)
    RES 7,A                     ; Reseta o bit 7 no registrador A para testar se a tecla é numérica ou de função
    CP 10H                      ; Compara o código da tecla com 10H (16)
    JR C,.in_data_num_key       ; Se for menor que 16, a tecla é numérica, segue para o processamento da entrada numérica
    JR .in_data_end             ; Se for maior ou igual a 16, a tecla é de função, encerra o loop de entrada numérica
.in_data_num_key:
    CALL isys_conv_hexdisp      ; Converte o código da tecla hex (= A) em código de exibição correspondente no display -> C
    CALL isys_sftl_data_disp    ; Desloca no display 1 dígito para esquerda e acrescenta novo dígito contido em C
                                ; Atualização do valor na variável apontada por HL, suponha dado 8 bits = "XY"
    LD C,A                      ; Guarda o valor digitado em C para poder usar o A, suponha valor digitado = "0K"
    LD A,(HL)                   ; Lê o dado da parte menos significativa -> A = "XY"
    SLA A                       ; Desloca parte menos significativa para esquerda -> A = "Y0"
    SLA A
    SLA A
    SLA A
    OR C                        ; Combina valor digitado com valor deslocado -> "Y0" OR "0K" = "YK"
    LD (HL),A                   ; Guarda valor combinado na parte menos significativa. Resultado final = "YK"
    JR .in_data_input_loop      ; Retorna ao inicio da subrotina de entrada para testar se há próximo digito de entrada
.in_data_rst_keyprsmem:
    LD A,(RAM_DRAFT1)           ; HL contém a posição de memória da variável de sistema
    RES 7,A                     ; Reseta o bit 7, sinalizador de tecla pressionada anteriormente
    LD (RAM_DRAFT1),A           ; Grava de volta na memória de sinalização de tecla pressionada anteriormente
    JR .in_data_input_loop      ; Retorna ao inicio da subrotina de entrada para testar se há próximo digito de entrada
.in_data_end:
    POP BC                      ; Recupera registrador BC
    RET
    DB 00H

; Subrotina de entrada de valor no campo de endereço (isys_in_addr)
; O software fica preso nessa rotina até que uma tecla de 10 a 17 seja pressionada
; HL: Definição da primeira área de memória para uso com a entrada de dados
;    (4 dígitos, sequencia little endian)
; Teclas de 0 a F = serão reproduzidas no display e atualizam o valor em (HL)
; Teclas de 10 a 17 = encerram o loop da subrotina, tecla pressionada em RAM_KEYB_CONV
;       If !(keypress.bit7) then RST keyprsmem.bit7
;       If  (keypress.bit7) &&  (keyprsmem.bit7) then end
;       If  (keypress.bit7) && !(keyprsmem.bit7) then SET keyprsmem.bit7 and process the input
isys_in_addr:
    PUSH BC                     ; Guarda na pilha valor atual de BC para poder usar BC na subrotina
    LD A,0FFH
    LD (RAM_DISPLAY),A          ; Limpa memória de exibição do 1.o display de endereçamento
    LD (RAM_DISPLAY+1),A        ; Limpa memória de exibição do 2.o display de endereçamento
    LD (RAM_DISPLAY+2),A        ; Limpa memória de exibição do 3.o display de endereçamento
    LD (RAM_DISPLAY+3),A        ; Limpa memória de exibição do 4.o display de endereçamento
;    CALL isys_clean_ram_disp   ; Limpa a memória de exibição no display
    LD A,00H
    LD (RAM_DRAFT1),A
.in_addr_input_loop:
    CALL isys_keyb_disp         ; Chama atualização do display e teclado
    LD A,(RAM_KEYB_CONV)        ; Recupera tecla atualmente pressionada (keypress = RAM_KEYB_CONV)
    BIT 7,A                     ; Testa bit 7 de RAM_KEYB_CONV para verificar se alguma tecla está pressionada (keypress.bit7)
    JR Z,.in_addr_rst_keyprsmem ; Bit 7 keypress é zero (tecla solta): reseta bit 7 memória (keypressmem)
    LD A,(RAM_DRAFT1)           ; Recupera memória de tecla pressionada (keyprsmem)
    BIT 7,A                     ; Testa bit 7, sinalizador de tecla pressionada anteriormente (keyprsmem.bit7)
    JR NZ,.in_addr_input_loop   ; bit 7 memória não zero (setado): não faz nada, finaliza a subrotina
    SET 7,A                     ; Seta bit 7 e segue com o processamento da tecla pressionada
    LD (RAM_DRAFT1),A           ; Salva na memória de tecla pressionada (keyprsmem), que há uma tecla pressionada (bit 7 setado)
    LD A,(RAM_KEYB_CONV)        ; Recupera tecla atualmente pressionada (keypress = RAM_KEYB_CONV)
    RES 7,A                     ; Reseta o bit 7 no registrador A para testar se a tecla é numérica ou de função
    CP 10H                      ; Compara o código da tecla com 10H (16)
    JR C,.in_addr_num_key       ; Se for menor que 16, a tecla é numérica, segue para o processamento da entrada numérica
    JR .in_addr_end             ; Se for maior ou igual a 16, a tecla é de função, encerra o loop de entrada numérica
.in_addr_num_key:
    CALL isys_conv_hexdisp      ; Converte o código da tecla hex (= A) em código de exibição correspondente no display -> C
    CALL isys_sftl_addr_disp    ; Desloca no display 1 dígito para esquerda e acrescenta novo dígito contido em C
                                ; Atualização do valor na variável apontada por HL, suponha dado 16 bits = "WX YZ"
    LD C,A                      ; Guarda o valor digitado em C para poder usar o A, suponha valor digitado = "0K"
    INC HL                      ; Vai para a parte mais significativa dos 16 bits
    LD A,(HL)                   ; Lê o dado da parte mais significativa -> "WX"
    SLA A                       ; Desloca parte mais significativa para esquerda -> "X0"
    SLA A
    SLA A
    SLA A
    LD B,A                      ; Guarda valor deslocado em B -> B = "X0"
    DEC HL                      ; Coloca ponteiro na parte menos significativa
    LD A,(HL)                   ; Lê o dado da parte menos significativa -> A = "YZ"
    SRL A                       ; Desloca parte menos significativa para direita -> A = "0Y"
    SRL A
    SRL A
    SRL A
    OR B                        ; Combina partes deslocadas A e B -> "X0" OR "0Y" = "XY"
    INC HL                      ; Coloca ponteiro na parte mais significativa
    LD (HL),A                   ; Guarda valor combinado na parte mais significativa -> (HL) = "XY"
    DEC HL                      ; Coloca ponteiro na parte menos significativa
    LD A,(HL)                   ; Lê o dado da parte menos significativa -> A = "YZ"
    SLA A                       ; Desloca parte menos significativa para esquerda -> A = "Z0"
    SLA A
    SLA A
    SLA A
    OR C                        ; Combina valor digitado com valor deslocado -> "Z0" OR "0K" = "ZK"
    LD (HL),A                   ; Guarda valor combinado na parte menos significativa. Resultado final = "XYZK"
    JR .in_addr_input_loop      ; Retorna ao inicio da subrotina de entrada para testar se há próximo digito de entrada
.in_addr_rst_keyprsmem:
    LD A,(RAM_DRAFT1)           ; HL contém a posição de memória da variável de sistema
    RES 7,A                     ; Reseta o bit 7, sinalizador de tecla pressionada anteriormente
    LD (RAM_DRAFT1),A           ; Grava de volta na memória de sinalização de tecla pressionada anteriormente
    JR .in_addr_input_loop      ; Retorna ao inicio da subrotina de entrada para testar se há próximo digito de entrada
.in_addr_end:
    POP BC                      ; Recupera registrador BC
    RET
    DB 00H

; Subrotina que converte um digito hexadecimal para exibição no display (_conv_hexdisp)
; A = num. hexadecimal 1 dígito
; C = retorna o valor para exibição no display
isys_conv_hexdisp:
    PUSH AF
    PUSH BC
    PUSH HL
    AND 0FH                     ; Isola o nibble menos significativo do código da tecla
    LD C,A
    LD B,00H
    LD HL,DB_NUMCHAR
    ADD HL,BC
    LD A,(HL)
    POP HL
    POP BC
    LD C,A
    POP AF
    RET
    DB 00H

; Sub-subrotina de deslocamento da memória do display de endereço (RAM_DISPLAY) em 1 dígito para esquerda
; C = valor a ser inserido
isys_sftl_addr_disp:
    PUSH HL
    PUSH DE
    PUSH BC
    LD HL,RAM_DISPLAY
    LD D,H
    LD E,L
    INC HL
    LD C,03
    LD B,00
    LDIR
    INC DE
    POP BC
    PUSH AF
    DEC HL
    LD A,C
    LD (HL),A
    POP AF
    POP DE
    POP HL
    RET
    DB 00H

; Sub-subrotina de deslocamento da memória do display de dados (RAM_DISPLAY+4) em 1 dígito para esquerda
; C = valor a ser inserido
isys_sftl_data_disp:
    PUSH HL
    PUSH DE
    PUSH BC
    LD HL,RAM_DISPLAY+4
    LD D,H
    LD E,L
    INC HL
    LD C,01
    LD B,00
    LDIR
    INC DE
    POP BC
    PUSH AF
    DEC HL
    LD A,C
    LD (HL),A
    POP AF
    POP DE
    POP HL
    RET
    DB 00H

; Subrotina de atualização do display/teclado (isys_keyb_disp)
; Dados relevantes
; (RAM_DISPLAY) = Inicio da sequencia das 6 posições de memória lidas pelo sistema para exibição no display
;                 Dado gravado nas posições de memória são o estado de cada segmento do display
; (RAM_KEYB_CONV) = Posição de memória onde é armazenado o código da tecla apertada e se há uma tecla apertada
;                   Bits (1 byte):  P X X X K K K K
;                   P: Se 1, alguma tecla pressionada; Se 0, nenhuma tecla pressionada
;                   X: "Don't care" (sem função)
;                   KKKK: 1 nibble do código de tecla cf. abaixo:
;                   0 a 9H: Teclas "0" a "9" pressionadas (com o bit P)
;                   A a FH: Teclas "A" a "F" pressionadas (com o bit P)
;                   10H: Tecla "ADR"
;                   11H: Tecla "DAT"
;                   12H: Tecla "-"
;                   13H: Tecla "+"
;                   14H: Tecla "GO"
;                   15H: Tecla "REG"
;                   16H: Tecla "IV"
;                   17H: Tecla Vazia           
isys_keyb_disp:
    PUSH BC
    PUSH HL
    LD HL,RAM_DISPLAY           ; Carrega no ponteiro HL primeiro endereço da RAM de sistema para o display
    CALL isys_lcd_home
    CALL isys_lcd_pos_top       ; Posiciona impressão LCD na linha superior
    CALL isys_lcd_print16       ; Imprime na linha o conteúdo da memória RAM_DISPLAY até +15
    LD HL,RAM_DISPLAY+16        ; Carrega no ponteiro HL primeiro endereço da RAM de sistema para o display
    CALL isys_lcd_pos_bottom    ; Posiciona impressão LCD na linha inferior
    CALL isys_lcd_print16       ; Imprime na linha o conteúdo da memória RAM_DISPLAY+16 até +31
    LD A,00H                    
    LD (RAM_KEYB_CONV),A        ; Limpa variável de memória do teclado antes de ler o teclado
    LD A,01H                    ; Ajusta A para apontar para a primeira coluna de displays (mais significativa) 
.keyb_disp_loop:
    IN A,(IO_KEYB)              ; Lê o teclado na coluna atual
    CP 00
    JR Z,.next_line             ; Se nada foi lido do teclado (nenhuma tecla apertada), vai para a próxima linha de varredura
    LD (RAM_KEYBOARD),A         ; Se algo foi lido do teclado, registra tecla para a coluna atual
    LD A,C                      ; Recupera dado de qual coluna está sendo atualizada
    LD (RAM_KEYB_COL),A         ; Registra na memória de qual coluna é a tecla apertada
.keyb_disp_cnv:
    LD A,(RAM_KEYBOARD)         ; Converte posição da tecla no valor correspondente que representa (função da tecla)
    CP 01                       ; Não foi considerada ainda a coluna nesse ponto
    JP Z,.keyb_disp_num_0
    CP 02
    JP Z,.keyb_disp_num_1
    CP 04
    JP Z,.keyb_disp_num_2
    CP 08
    JP Z,.keyb_disp_num_3
    CP 16
    JP Z,.keyb_disp_num_4
    CP 32
    JP Z,.keyb_disp_num_5
    CP 64
    JP Z,.keyb_disp_num_6
    CP 128
    JP Z,.keyb_disp_num_7
    JR .next_line
.keyb_disp_num_0:
    LD A,00H
    LD B,A
    JR .keyb_line
.keyb_disp_num_1:
    LD A,01H
    LD B,A
    JR .keyb_line
.keyb_disp_num_2:
    LD A,02H
    LD B,A
    JR .keyb_line
.keyb_disp_num_3:
    LD A,03H
    LD B,A
    JR .keyb_line
.keyb_disp_num_4:
    LD A,04H
    LD B,A
    JR .keyb_line
.keyb_disp_num_5:
    LD A,05H
    LD B,A
    JR .keyb_line
.keyb_disp_num_6:
    LD A,06H
    LD B,A
    JR .keyb_line
.keyb_disp_num_7:
    LD A,07H
    LD B,A
.keyb_line:
    LD A,(RAM_KEYB_COL)         ; Decodifica a linha e calcula o código correto da tecla (0~7H: linha 1, 8~FH: linha 2; 10~17H: linha 3; 17~1FH: linha 4)
    CP 01
    JR Z,.keyb_cnv_plus0
    CP 02
    JR Z,.keyb_cnv_plus8
    CP 04
    JR Z,.keyb_cnv_plus16
    JR .next_line
.keyb_cnv_plus0:                ; Identificado como tecla da linha 1 (0~7H)
    LD A,B
    JR .keyb_cnv_end
.keyb_cnv_plus8:                ; Identificado como tecla da linha 2 (8~FH)
    LD A,B
    ADD A,08
    JR .keyb_cnv_end
.keyb_cnv_plus16:               ; Identificado como tecla da linha 3 (10~17H)
    LD A,B
    ADD A,16
.keyb_cnv_plus16:               ; Identificado como tecla da linha 4 (18~1FH)
    LD A,B
    ADD A,32
.keyb_cnv_end:
    SET 7,A                     ; Seta o bit 7 do valor convertido para dizer que a tecla foi lida, especialmente no caso do zero (0H)
    LD (RAM_KEYB_CONV),A
.next_line:
    LD A,C
    ADD A,A
    CP 64
    JP NZ, .keyb_disp_loop      ; Se não chegou na última coluna de atualização do display (64), vai para o próximo loop
    POP HL
    POP BC
    RET
    DB 00H

; Delay (operative, ms) for clk = 2 MHz (isys_delay_ms);
; Input: B = delay time (ms) 0,5% ;
; Affects registers A, B, F
isys_delay_ms:
    PUSH AF
.delay_mult:
    LD A,B
    LD B, 152                   ; Number of loops adjusted to A = delay ms with minimum error
.delay_1ms:
    DJNZ .delay_1ms
    LD B,A
    DJNZ .delay_mult
    POP AF
    RET
    DB 00H



; LCD clear ;
; Input: None ;
; Affects registers A, B, C
isys_lcd_clear:
    LD A,01H                    ; Clear LCD
    OUT (DSKY_LCDDATA),A        ; Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Sets cursor to home (1st position, top line) ;
; Input: None ;
; Affects registers A, B, C
isys_lcd_home:
    LD A,80H                    ; Select 1st column and 1st row for data
    OUT (DSKY_LCDDATA),A        ; Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Sets printing cursor to some position in LCD line 1 (top line) ;
; Input: Line 1 position 0 to F = A ;
; Affects registers B, C
isys_lcd_pos_top:
    AND 0FH                     ; Clear the A reg high nibble
    OR 80H                      ; Combines user informed position m with 8X => 8m
    OUT (DSKY_LCDDATA),A        ; Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Sets printing cursor to some position in LCD line 2 (bottom line) ;
; Input: Line 2 position 0 to F = A ;
; Affects registers B, C, D ;
isys_lcd_pos_bottom:
    AND 0FH                     ; Clear the A reg higher nibble
    OR 0C0H                     ; Combines user informed position m with CX => Cm
    OUT (DSKY_LCDDATA),A        ; Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Turns on cursor blinking ;
; Input: None ;
; Affects registers A, B, C ;
isys_lcd_cursor_blink:
    LD A,0FH                    ; Enables display and cursor blinking
    OUT (DSKY_LCDDATA),A        ; Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Turns off cursor ;
; Input: None ;
; Affects registers A, B, C ;
isys_lcd_cursor_off:
    LD A,0FH                    ; Enables display, cursor and blinking
    OUT (DSKY_LCDDATA),A        ; Send LCD setup command
    CALL _lcd_e_pulse
    RET

; LCD text print ;
; Input: HL = Text begin memory pointer ;
; Affects registers A, F, B, C, D, E, H, L
isys_lcd_print:
    PUSH AF
    PUSH BC
    PUSH DE
    LD E,00H                   ; Initializes char counter (Reg E)
.lcd_print_loop:
    LD A,00H                    ; Sets A reg as NUL char for searching string end
    LD D,(HL)                   ; Retrieves the char from the current memory location
    CPI                         ; Compare if (HL) position has a null char and Increment HL
    JR Z,.lcd_print_end         ; If Z = 1, then A=(HL), so message end
    CALL _lcd_print_char
    INC E                       ; Increment char printed
    CP 15
    JR NZ,.lcd_print_loop
.lcd_print_end:
    POP DE
    POP BC
    POP AF
    RET

; LCD text print 16 chars, no null char check;
; Input: HL = Text begin memory pointer ;
; Affects registers A, F, B, C, D, E, H, L
isys_lcd_print16:
    PUSH AF
    PUSH BC
    PUSH DE
    LD E,00H                   ; Initializes char counter (Reg E)
.print_loop:
    LD D,(HL)                   ; Retrieves the char from the current memory location
    CALL _lcd_print_char
    INC E                       ; Increment char printed
    CP 15
    JR NZ,.print_loop
    POP DE
    POP BC
    POP AF
    RET

; LCD hex number print ;
; Input: HL = number to be printed, E = digits to be printed (2 or 4) ;
; Registers pushed A, F, B, C, D, E, H, L
isys_lcd_numh:
    PUSH AF
    PUSH BC
    PUSH DE
    ;Prints H, high nibble.
    LD A,H                 
    LD B,04H                    ; Rotates 4 bits to the right to: high nibble of H -> low nibble
.lcd_numh_H_hi_nibble           ; "
    RRA                         ; "
    DJNZ .lcd_numh_H_hi_nibble  ; "
    CALL _conv_hex_asc
    LD D,A
    CALL _lcd_print_char
    ;Prints H, low nibble.
    LD A,H                 
    CALL _conv_hex_asc
    LD D,A
    CALL _lcd_print_char
    LD A,E                      ; If less than 3 digits (1 or 2 digit) was defined in E reg, jumps drcly to subr end
    CP 03
    JR C,.lcd_numh_end  
    ;Prints L, high nibble
    LD A,L                 
    LD B, 04H                   ; Rotates 4 bits to the right to: high nibble of H -> low nibble
.lcd_numh_L_hi_nibble           ; "
    RRA                         ; "
    DJNZ .lcd_numh_L_hi_nibble  ; "
    CALL _conv_hex_asc
    LD D,A
    CALL _lcd_print_char
    ;Prints L, low nibble
    LD A,L                 
    CALL _conv_hex_asc
    LD D,A
    CALL _lcd_print_char
.lcd_numh_end
    POP DE
    POP BC
    POP AF
    RET

; Prints one char in LCD current cursor position ;
; Input: D = ASCII char ;
; Registers affected: C,D
_lcd_print_char:
    LD C,DSKY_LCDDATA
    OUT (C),D                   ; Send LCD setup command
    LD C,DSKY_LCDE_RW_RS
    LD D,05H
    OUT (C),D                   ; Set E and RS pins
    ; -- Delay to be considered
    LD D,00H
    OUT (C),D                   ; Reset E and RS pins
    RET

; Converts hex digits into ASCII '0' to '9', 'A' to 'F' ;
; Input: A = num. hex digit (in low nibble) ;
; Output: A = ASCII corresponding code ;
_conv_hex_asc:
    AND 0FH                 ;Fiters out the resulting high nibble
    CP 09H                  ;If greater than 09H, execute ASCII 'A' to 'F' equivalence for hex digit
    JP C, .conv_0to9_a
.conv_a2f_a:
    CP 0AH
    JP NZ, .conv_a2f_b
    LD A,'A'
    JR .conv_hex_asc_end
.conv_a2f_b:
    CP 0BH
    JP NZ, .conv_a2f_c
    LD A,'B'
    JR .conv_hex_asc_end
.conv_a2f_c:
    CP 0CH
    JP NZ, .conv_a2f_d
    LD A,'C'
    JR .conv_hex_asc_end
.conv_a2f_d:
    CP 0DH
    JP NZ, .conv_a2f_e
    LD A,'D'
    JR .conv_hex_asc_end
.conv_a2f_e:
    CP 0EH
    JP NZ, .conv_a2f_f
    LD A,'E'
    JR .conv_hex_asc_end
.conv_a2f_f:
    CP 0FH
    JP NZ, .conv_hex_asc_void
    LD A,'F'
    JR .conv_hex_asc_end
.conv_hex_asc_void:
    LD A,'?'
    JR .conv_hex_asc_end
.conv_0to9_a:
    ADD A,30H                   ;If less than or equal to '0' to 'F', adds 30H to get corresponding ASCII code for the digit
.conv_hex_asc_end:
    RET

; Pulse E pin of LCD for LCD commands confirmation
; Input: None ;
; Registers affected: B, C
_lcd_e_pulse:
    LD C,DSKY_LCDE_RW_RS
    LD B,04H
    OUT (C),B              ;Set E pin
    LD B, 5
.lcd_e_pulse_dly:
    DJNZ .lcd_e_pulse_dly
    LD C,DSKY_LCDE_RW_RS
    LD B,00H
    OUT (C),B              ;Reset E pin
    RET


; Subrotina de mapeamento do teclado, convertendo a posição da tecla lida no respectivo código
; Entrada: A = valor da tecla pressionada
; Saída: A = código da tecla pressionada (conforme CEDM-80)
isys_keyb_map:





















; Código dos caracteres para exibição no display em sequencia de endereços para facilitar a conversão numérica
DB_NUMCHAR EQU $
    DB      0C0H                ; Caractere 0
    DB      0F9H                ; Caractere 1
    DB      0A4H                ; Caractere 2
    DB      0B0H                ; Caractere 3
    DB      099H                ; Caractere 4
    DB      092H                ; Caractere 5
    DB      082H                ; Caractere 6
    DB      0F8H                ; Caractere 7
    DB      080H                ; Caractere 8
    DB      090H                ; Caractere 9
    DB      088H                ; Caractere A
    DB      083H                ; Caractere B
    DB      0C6H                ; Caractere C
    DB      0A1H                ; Caractere D
    DB      086H                ; Caractere E
    DB      08EH                ; Caractere F
    DB      0FFH                ; Tecla especial 1
    DB      0FFH                ; Tecla especial 2
    DB      0FFH                ; Tecla especial 3
    DB      0FFH                ; Tecla especial 4
    DB      0FFH                ; Tecla especial 5
    DB      0FFH                ; Tecla especial 6
    DB      0FFH                ; Tecla especial 7
    DB      0FFH                ; Tecla especial 8

itest_prog:                     ; Rotina do programa de teste do NEMO-80
    LD A,00H
    LD (VAR_TEST),A
    CALL isys_clean_ram_disp
    CALL isys_keyb_disp
loop_test_inc:
    LD A,(VAR_TEST)
    INC A
    LD (VAR_TEST),A
    LD HL,VAR_TEST
    LD B,20
loop_test_disp:
    CALL isys_disp_data
    DJNZ loop_test_disp
    JR loop_test_inc
    HALT
    DB 00H