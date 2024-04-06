;===========================================================================
; Thiago Turcato do Rego - 2023
; Project: Z80 COOL, Z80 computer in breadboard
; File: BIOS program
;===========================================================================

; Compilation directives for allocating memory (no bank) and SLD file generation
 DEVICE NOSLOT64K
 SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION    

;******** Constants definition ********
; RAM first address and size
RAMBEGIN            EQU 4000H
RAMSIZE             EQU 2000H

; I/O addresses
DSKY_LCDDATA        EQU 10H
DSKY_KEYB           EQU 11H
DSKY_LCDE_RW_RS     EQU 12H
DSKY_IOSETUP        EQU 13H


;******** Beggining of BIOS program ********
    ORG 2000H
entry_point:

; ********************** Main Program ********************** 

; Program setup & initialization
    LD SP, 5FF0H        ;Set stack pointer to the end of the ram


; Board initialization without RAM memory

; 8255 PIO setup
; Port A = output, Port B = input, Port C = output
    LD C, DSKY_IOSETUP 
    LD D, 80H               
    OUT (C), D              ;Define 8255 mode and ports functions

; DSKY LCD setup
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 01H               ; * CLEAR LCD *
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.ini_dly_clearlcd:
    DJNZ .ini_dly_clearlcd
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 38H               ; * 8 BIT MODE *
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.ini_dly_eightbitmd:
    DJNZ .ini_dly_eightbitmd
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 80H               ; * SETS CURSOR TO TOP LINE 1ST POSITION *
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.ini_dly_firstpos:
    DJNZ .ini_dly_firstpos
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 0CH               ; * SETS DISPLAY ON, CURSOR OFF, NO BLINKING *
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.ini_dly_cursormd:
    DJNZ .ini_dly_cursormd
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 06H               ; * SETS CURSOR MOVING RIGHT AND NO TEXT SHIFTING *
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.ini_dly_cursorinc:
    DJNZ .ini_dly_cursorinc
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin

; Welcome & alive message
    LD HL, dmsg_hello       ;Points HL to welcome message
    LD E, 00H               ;Initializes char counter (Reg E)
.ini_loop:
    LD A, 00H               ;Sets A reg as NUL char for searching string end
    LD D, (HL)              ;Retrieves the char from the current memory location
    CPI                     ;Compare if (HL) position has a null char and Increment HL
    JR Z, .ini_end          ;If Z = 1, then A=(HL), so message end
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 05H
    OUT (C), D              ;Set E and RS pins
    LD D, 00H
    OUT (C), D              ;Reset E and RS pins
    INC E                   ;Increment char printed
    CP 15
    JR NZ, .ini_loop
.ini_end:

; Test RAM memory (ADDR RAMBEGIN ~ RAMBEGIN+RAMSIZE-1)
; MEMORY TEST 1, FILL W/ 55H
test_sys:
    LD HL, RAMBEGIN         ;Set the memory pointer to first RAM address
    LD BC, (RAMSIZE-1)      ;Set the byte counter to memory size value
.test_mem55:                ;Begin test sequence writing 55H in all memory positions
    LD A, 55H
    LD (HL), A              ;Write 55H in (HL) memory position
    CPI                     ;Increment HL, Decrement BC and if A=(HL) -> Z = 1
    JR NZ, .test_ram_bad    ;If Z = 0, then A!=(HL), so memory fail
    JP PE, .test_mem55      ;If BC-1 != 0 -> P = 1 -> Go to test next mem position
                            ;If execution is here CPI reached the memory end, go to next test
; MEMORY TEST 2, FILL W/ 00H
    LD HL, RAMBEGIN         ;Set the memory pointer to first RAM address
    LD BC, (RAMSIZE-1)      ;Set the byte counter to memory size value
.test_mem00:                ;Begin test sequence writing 00H in all memory positions
    LD A, 00H
    LD (HL), A              ;Write 00H in (HL) memory position
    CPI                     ;Increment HL, Decrement BC and if A=(HL) -> Z = 1
    JR NZ, .test_ram_bad    ;If Z = 0, then A!=(HL), so memory fail
    JP PE, .test_mem00      ;If BC-1 != 0 -> P = 1 -> Go to test next mem position
.test_ram_ok:               ;Print message "RAM OK"
    LD A, 00H
    CALL lcd_pos_bottom
    LD HL, dmsg_ram_ok
    CALL lcd_print
    JR .test_end
.test_ram_bad:               ;Print message "RAM BAD"
    LD HL, dmsg_ram_bad
    LD A, 00H
    CALL lcd_pos_bottom
    CALL lcd_print
    HALT  
.test_end:                   ;From this point, RAM is good for use

; LCD test
    CALL lcd_clear
    CALL lcd_home
    LD HL, dmsg_lcd_test
    CALL lcd_print
    LD A, 00H
    CALL lcd_pos_bottom
    LD HL, dmsg_lcd_test
    CALL lcd_print

/*
    CALL lcd_clear
    LD A, 02H
    CALL lcd_pos_bottom
    LD HL, dmsg_ram_ok
    CALL lcd_print
*/

    HALT

; ********************** Subroutines ********************** 

; LCD clear ;
; Input: None ;
; Affects registers A, B, C
lcd_clear:
    LD A, 01H               ;Clear LCD
    LD C, DSKY_LCDDATA
    OUT (C), A              ;Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Sets cursor to home (1st position, top line) ;
; Input: None ;
; Affects registers A, B, C
lcd_home:
    LD A, 80H               ;select 1st column and 1st row for data
    LD C, DSKY_LCDDATA
    OUT (C), A              ;Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Sets printing cursor to some position in LCD line 1 (top line) ;
; Input: Line 1 position 0 to F = A ;
; Affects registers B, C
lcd_pos_top:
    AND 0FH                 ;Clear the A reg higher nibble
    OR 80H                  ;Combines user informed position m with 8X => 8m
    LD C, DSKY_LCDDATA
    OUT (C), A              ;Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Sets printing cursor to some position in LCD line 2 (bottom line) ;
; Input: Line 2 position 0 to F = A ;
; Affects registers B, C, D ;
lcd_pos_bottom:
    AND 0FH                 ;Clear the A reg higher nibble
    OR 0C0H                 ;Combines user informed position m with CX => Cm
    LD C, DSKY_LCDDATA
    OUT (C), A              ;Send LCD setup command
    CALL _lcd_e_pulse
    RET

; LCD text print ;
; Input: Text begin memory pointer = HL ;
; Affects registers A, F, B, C, D, E, H, L
lcd_print:
    LD E, 00H               ;Initializes char counter (Reg E)
.lcd_print_loop:
    LD A, 00H               ;Sets A reg as NUL char for searching string end
    LD D, (HL)              ;Retrieves the char from the current memory location
    CPI                     ;Compare if (HL) position has a null char and Increment HL
    JR Z, .lcd_print_end    ;If Z = 1, then A=(HL), so message end
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 05H
    OUT (C), D              ;Set E and RS pins
    LD D, 00H
    OUT (C), D              ;Reset E and RS pins
    INC E                   ;Increment char printed
    CP 15
    JR NZ, .lcd_print_loop
.lcd_print_end:
    RET

; Pulse E pin of LCD for LCD commands confirmation
_lcd_e_pulse
    LD C, DSKY_LCDE_RW_RS
    LD A, 04H
    OUT (C), A              ;Set E pin
    LD B, 5
.lcd_e_pulse_dly:
    DJNZ .lcd_e_pulse_dly
    LD C, DSKY_LCDE_RW_RS
    LD A, 00H
    OUT (C), A              ;Reset E pin
    RET



; ******* S A F E T Y  H A L T *******
    HALT


; ********************** Fixed data ********************** 
; Text messages
dmsg_hello EQU $
    DB "    Z80 COOL", 00h
dmsg_ram_ok EQU $
    DB "     RAM OK", 00h
dmsg_ram_bad EQU $
    DB "    RAM BAD", 00h
dmsg_lcd_test
    DB "*##############*", 00h


; ********************** BIOS PROGRAM AND DATA END ********************** 


/* PARKING LOT

// IDEA FOR PRINTING NUMBERS
    LD HL, 4000H
    LD (HL), ' '
    INC HL
    LD D, B
    LD A, D
    LD B, 04H
rot_reg:
    RRA
    DJNZ rot_reg
    AND 0FH
    ADD A, 30H
    LD (HL), A
    INC HL
    LD A, D
    AND 0FH
    ADD A, 30H
    LD (HL), A
    INC HL
    LD (HL), 00H

    LD HL, 4000H
    CALL msg_print



*/

