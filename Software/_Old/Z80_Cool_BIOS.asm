;===========================================================================
; Thiago Turcato do Rego - 2023
; Project: Z80 COOL, Z80 computer in breadboard
; File: BIOS program
;===========================================================================

;============ TERMINOLOGY, CONVENTIONS AND ORGANIZATION ====================
; -- TERMINOLOGIES --
; subr.  = subroutines
; drcly = directly
; aux. = auxiliary
; 
; -- SYMBOLS CONVENTIONS --
; - Symbols in UPPER CASE LETTERS = constants
; - Labels starting with "." are local jump entry points
; - Labels starting with "_" are local subroutines (aux. subr.)
; - Labels starting with lower case letters (except for the cases below) 
;    are general function calls, open to any user
; - Labels starting with "dmsg_" are ascii text formated messages to use 
;    for display (user interface messages)
;
;=============================================================================

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
    
    LD HL, 5AB2H
    LD E, 4
    CALL lcd_numh

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

; Turns on cursor blinking ;
; Input: None ;
; Affects registers A, B, C ;
lcd_cursor_blink:
    LD A, 0FH               ;Enables display and cursor blinking
    LD C, DSKY_LCDDATA
    OUT (C), A              ;Send LCD setup command
    CALL _lcd_e_pulse
    RET

; Turns off cursor ;
; Input: None ;
; Affects registers A, B, C ;
lcd_cursor_off:
    LD A, 0FH               ;Enables display, cursor and blinking
    LD C, DSKY_LCDDATA
    OUT (C), A              ;Send LCD setup command
    CALL _lcd_e_pulse
    RET

; LCD text print ;
; Input: HL = Text begin memory pointer ;
; Affects registers A, F, B, C, D, E, H, L
lcd_print:
    PUSH AF
    PUSH BC
    PUSH DE
    LD E, 00H               ;Initializes char counter (Reg E)
.lcd_print_loop:
    LD A, 00H               ;Sets A reg as NUL char for searching string end
    LD D, (HL)              ;Retrieves the char from the current memory location
    CPI                     ;Compare if (HL) position has a null char and Increment HL
    JR Z, .lcd_print_end    ;If Z = 1, then A=(HL), so message end
    CALL _lcd_print_char
    INC E                   ;Increment char printed
    CP 15
    JR NZ, .lcd_print_loop
.lcd_print_end:
    POP DE
    POP BC
    POP AF
    RET

; LCD hex number print ;
; Input: HL = number to be printed, E = digits to be printed (2 or 4) ;
; Registers pushed A, F, B, C, D, E, H, L
lcd_numh:
    PUSH AF
    PUSH BC
    PUSH DE
    ;Prints H, high nibble.
    LD A, H                 
    LD B, 04H               ;Rotates 4 bits to the right to: high nibble of H -> low nibble
.lcd_numh_H_hi_nibble    ; "
    RRA                     ; "
    DJNZ .lcd_numh_H_hi_nibble ; "
    CALL _conv_hex_asc
    LD D, A
    CALL _lcd_print_char
    ;Prints H, low nibble.
    LD A, H                 
    CALL _conv_hex_asc
    LD D, A
    CALL _lcd_print_char
    LD A, E                 ;If less than 3 digits (1 or 2 digit) was defined in E reg, jumps drcly to subr end
    CP 03
    JR C, .lcd_numh_end  
    ;Prints L, high nibble
    LD A, L                 
    LD B, 04H               ;Rotates 4 bits to the right to: high nibble of H -> low nibble
.lcd_numh_L_hi_nibble    ; "
    RRA                     ; "
    DJNZ .lcd_numh_L_hi_nibble ; "
    CALL _conv_hex_asc
    LD D, A
    CALL _lcd_print_char
    ;Prints L, low nibble
    LD A, L                 
    CALL _conv_hex_asc
    LD D, A
    CALL _lcd_print_char
.lcd_numh_end
    POP DE
    POP BC
    POP AF
    RET

; Prints one char in LCD current cursor position ;
; Input: D = ASCII char ;
; Registers affected: C, D
_lcd_print_char:
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 05H
    OUT (C), D              ;Set E and RS pins
    ; -- Delay to be considered
    LD D, 00H
    OUT (C), D              ;Reset E and RS pins
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
    LD A, 'A'
    JR .conv_hex_asc_end
.conv_a2f_b:
    CP 0BH
    JP NZ, .conv_a2f_c
    LD A, 'B'
    JR .conv_hex_asc_end
.conv_a2f_c:
    CP 0CH
    JP NZ, .conv_a2f_d
    LD A, 'C'
    JR .conv_hex_asc_end
.conv_a2f_d:
    CP 0DH
    JP NZ, .conv_a2f_e
    LD A, 'D'
    JR .conv_hex_asc_end
.conv_a2f_e:
    CP 0EH
    JP NZ, .conv_a2f_f
    LD A, 'E'
    JR .conv_hex_asc_end
.conv_a2f_f:
    CP 0FH
    JP NZ, .conv_hex_asc_void
    LD A, 'F'
    JR .conv_hex_asc_end
.conv_hex_asc_void:
    LD A, '?'
    JR .conv_hex_asc_end
.conv_0to9_a:
    ADD A, 30H              ;If less than or equal to '0' to 'F', adds 30H to get corresponding ASCII code for the digit
.conv_hex_asc_end:
    RET

; Pulse E pin of LCD for LCD commands confirmation
; Input: None ;
; Registers affected: B, C
_lcd_e_pulse:
    LD C, DSKY_LCDE_RW_RS
    LD B, 04H
    OUT (C), B              ;Set E pin
    LD B, 5
.lcd_e_pulse_dly:
    DJNZ .lcd_e_pulse_dly
    LD C, DSKY_LCDE_RW_RS
    LD B, 00H
    OUT (C), B              ;Reset E pin
    RET

; Delay (operative, ms) for clk = 1 MHz ;
; Input: A = delay time (ms) 0,5% ;
; Affects registers A, B, F
delay_ms:
    PUSH AF
.delay_mult:
    LD A, B
    LD B, 75                ;Number of loops adjusted to A = delay ms with minimum error
.delay_1ms:
    DJNZ .delay_1ms
    LD B, A
    DJNZ .delay_mult
    POP AF
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


*/

