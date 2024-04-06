;===========================================================================
; Thiago Turcato do Rego - 2023
; Project: Z80 COOL, Z80 computer in breadboard
; File: BIOS program
;===========================================================================

; Compilation directives for allocating memory (no bank) and SLD file generation
 DEVICE NOSLOT64K
 SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION    

; Variable definition
RAMBEGIN            EQU 0x1000
RAMSIZE             EQU 0x1000

DSKY_LCDDATA        EQU 0x10
DSKY_KBROWDATA      EQU 0x11
DSKY_LCDE_RW_RS     EQU 0x12
DSKY_IOSETUP        EQU 0x13


; Beggining of BIOS program
    ORG 0000H
entry_point:

; ********************** Main Program ********************** 

; Program setup & initialization
    LD SP, stack_top            ;Set stack pointer to the end of the ram        

; Welcome & alive message
    LD HL, dmsg_hello
    CALL msg_print

    HALT
/*
; Test RAM memory (ADDR 1000H ~ 1FFF)
; MEMORY TEST 1, FILL W/ 55H
.test_sys:
    LD HL, RAMBEGIN                 ;Set the memory pointer to first RAM address
    LD BC, RAMSIZE                  ;Set the byte counter to memory size value
test_mem55:                         ;Begin test sequence writing 55H in all memory positions
    LD A, 55H
    LD (HL), A                      ;Write 55H in (HL) memory position
    CPI                             ;Increment HL, Decrement BC and if A=(HL) -> Z = 1
    JR NZ, test_ram_bad             ;If Z = 0, then A!=(HL), so memory fail
    JP PE, test_mem55               ;If BC-1 != 0 -> P = 1 -> Go to test next mem position
                                    ;If execution is here CPI reached the memory end, go to next test
; MEMORY TEST 2, FILL W/ 00H
    LD HL, RAMBEGIN                 ;Set the memory pointer to first RAM address
    LD BC, RAMSIZE                  ;Set the byte counter to memory size value
test_mem00:                         ;Begin test sequence writing 00H in all memory positions
    LD A, 00H
    LD (HL), A                      ;Write 00H in (HL) memory position
    CPI                             ;Increment HL, Decrement BC and if A=(HL) -> Z = 1
    JR NZ, test_ram_bad                  ;If Z = 0, then A!=(HL), so memory fail
    JP PE, test_mem00                ;If BC-1 != 0 -> P = 1 -> Go to test next mem position
    JR ram_ok                       ;Go to test next mem position
test_ram_ok:                             ;Print message "RAM OK"
    LD HL, dmsg_ram_ok
    CALL msg_sys
    JR test_end
test_ram_bad:                            ;Print message "RAM BAD"
    LD HL, dmsg_ram_bad
    CALL .msg_sys
test_end:                           ;From this point, RAM is good for use

; Safety HALT
    HALT
*/

; ********************** Subroutines ********************** 
;Print test messages in display (assuming the ram is available for stack)
; U = User; S = System; R = read; W = write
; Who  What  Where  Purpose 
;  U    W     HL    Defines message text location in ROM
; 

msg_print:
; Preserve current registers values in the stack
;    PUSH AF         
;    PUSH BC
;    PUSH DE
    LD E, 00H              ;Reg E acts as char counter, initialize with zero
; 8255 PIO setup, Port A = output, Port B = input, Port C = output
    LD C, DSKY_IOSETUP 
    LD D, 82H
    OUT (C), D
; DSKY LCD setup
    LD D, 38H               ;8 bit mode
    CALL .msg_lcd_cmd
    LD D, 0CH               ;cursor off
    CALL .msg_lcd_cmd
    LD D, 06H               ;cursor increment
    CALL .msg_lcd_cmd
    LD D, 01H               ;clear LCD
    CALL .msg_lcd_cmd
    LD D, 80H               ;select 1st column and 1st row for data
    CALL .msg_lcd_cmd
.msg_loop:
    LD A, 00H               ;Sets A reg as NUL char for searching string end
    LD D, (HL)              ;Retrieves the char from the current memory location
    CPI                     ;Compare if (HL) position has a null char and Increment HL
    JR Z, .msg_end          ;If Z = 1, then A=(HL), so message end
    CALL .msg_lcd_txt
    INC E                   ;Increment char printed
    CP 15
    JR NZ, .msg_loop
.msg_end:
;    POP AF         
;    POP BC
;    POP DE
    RET
; Subroutine send setup to LCD
.msg_lcd_cmd:
    LD C, DSKY_LCDDATA
    OUT (C), D             ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D             ;Set E pin
    LD B, 12
.msg_delay1:
    DJNZ .msg_delay1
    LD D, 00H
    OUT (C), D             ;Reset E pin
    RET
; Subroutine write text in LCD
.msg_lcd_txt:
    LD C, DSKY_LCDDATA
    OUT (C), D             ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 05H
    OUT (C), D             ;Set E and RS pins
    LD B, 12
.msg_delay2:
    DJNZ .msg_delay2
    LD D, 00H
    OUT (C), D             ;Reset E and RS pins
    RET

; Text messages
dmsg_hello EQU $
    DB "Z80 COOL", 00h
dmsg_ram_ok EQU $
    DB "ROM OK  ", 00h
dmsg_ram_bad EQU $
    DB "ROM BAD ", 00h

;Stack pointer definition
    ORG 5F9BH
stack_bottom:   ; 100 bytes of stack
    DEFS 100, 0
stack_top:   
