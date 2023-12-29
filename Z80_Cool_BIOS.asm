;===========================================================================
; Thiago Turcato do Rego - 2023
; Project: Z80 COOL, Z80 computer in breadboard
; File: BIOS program
;===========================================================================

; Compilation directives for allocating memory (no bank) and SLD file generation
 DEVICE NOSLOT64K
 SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION    

; Variable definition
RAMBEGIN    EQU 0x1000
RAMSIZE     EQU 0x1000

; Beggining of BIOS program
    ORG 0000H
entry_point:

; ********************** Main Program ********************** 

; Program setup & initialization
    LD SP, stack_top            ;Set stack pointer to the end of the ram        

; Welcome & alive message
    LD A,'Z'
    OUT (03H), A
    LD A,'8'
    OUT (02H), A
    LD A,'0'
    OUT (01H), A
    LD A,' '
    OUT (00H), A

    LD A,'C'
    OUT (07H), A
    LD A,'O'
    OUT (06H), A
    LD A,'O'
    OUT (05H), A
    LD A,'L'
    OUT (04H), A

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

; ********************** Subroutines ********************** 
;Print test messages in display (assuming the ram is not available for stack)
;  HL = defines message text location in ROM
;  Character position in display:
;  (03H)(02H)(01H)(00H)  (07H)(06H)(05H)(04H)


.msg_sys:
    EX AF, AF'      ;Preserves A and F registers
    LD B, 09        ;Loads BD with max. number of chars + 1 (9)
msg_begin:
    LD A, 00h       ;Sets A reg as NUL char for searching string end
    LD D, (HL)      ;Retrieves the char from the current memory location
    CPI             ;Compare if (HL) position has a null char and Increment HL
    JR Z, MSG_END   ;If Z = 1, then A=(HL), so message end
    DEC B
    LD A, B         ;Loads current char position in the string
msg_disp1:
    CP 08           ;1st character printing
    JR NZ, MSGD2    
    LD C, 03H
    OUT (C), D
    JR msg_begin
msg_disp2:              ;2nd character printoing
    CP 07
    JR NZ, msg_disp3
    LD C, 02H
    OUT (C), D
    JR MSG_BEGIN
msg_disp3:              ;3rd character printing
    CP 06
    JR NZ, MSGD4
    LD C, 01H
    OUT (C), D
    JR MSG_BEGIN
msg_disp4:              ;4rd character printing
    CP 05
    JR NZ, MSGD5
    LD C, 00H
    OUT (C), D
    JR MSG_BEGIN
msg_disp5:
    CP 04           ;1st character printing
    JR NZ, MSGD6    
    LD C, 07H
    OUT (C), D
    JR MSG_BEGIN
msg_disp6:              ;2nd character printing
    CP 03
    JR NZ, MSGD7
    LD C, 06H
    OUT (C), D
    JR MSG_BEGIN
msg_disp7:              ;3rd character printing
    CP 02
    JR NZ, MSGD8
    LD C, 05H
    OUT (C), D
    JR MSG_BEGIN
msg_disp8:              ;4rd character printing
    CP 01
    JR NZ, MSG_END
    LD C, 04H
    OUT (C), D
msg_end:
    RET

;Print messages in display
;  D = defines value type to print
;       00H = ASCII, lenght = until NUL char is found or len >= 8
;       01H = Hexadecimal
;  Character position in display:
;  (03H)(02H)(01H)(00H)  (07H)(06H)(05H)(04H)
PRINT:
    EX AF, AF'      ;Save current accumulator/flag values
    PUSH BC
    LD A, 01H
    CP D
    JR NZ, PRN_HEX
    DEC A
    CP D
    JR NZ, PRN_ASC
    JR PRN_END
PRN_HEX:
;   TO DO
    JR PRN_END
PRN_ASC:
    LD C, 04H
PLOOP1:             ;Print in first display chunk, I/O = 03h ~ 00H
    LD A, (HL)
    ADD A, 00H
    JR Z, PRN_END   ;Found NUL char
    DEC C
    OUT (C), A
    INC HL
    CP C
    JR NZ, PLOOP1
    LD C, 07H
PLOOP2:             ;Print in second display chunk, I/O = 07h ~ 04H
    LD A, (HL)
    ADD A, 00H
    JR Z, PRN_END   ;Found NUL char
    DEC C
    OUT (C), A
    INC HL
    LD A, 04H
    CP C
    JR NZ, PLOOP2
PRN_END:
    POP BC
    EX AF, AF'
    RET
;Delay
;  D = defines value type to print
;       00H = ASCII, lenght = until NUL char is found or len >= 8
;       01H = Hexadecimal
;  Character position in display:
;  (03H)(02H)(01H)(00H)  (07H)(06H)(05H)(04H)
;DELAY:
;    EX AF, AF'      ;Save current accumulator/flag values
;    LD A, FFH
;    LD B, FFH
;DLY1:
;    DJNZ A, DLY2
;;    JR DLY_END
;DLY2:
;    DJNZ B, DLY2
;    JR DLY1
;DLY_END:
;    EX AF, AF'
;    RET

; Text messages
dmsg_hello EQU $
    DB "Z80 COOL", 00h
dmsg_ram_ok EQU $
    DB "ROM OK  ", 00h
dmsg_ram_bad EQU $
    DB "ROM BAD ", 00h

;Stack pointer definition
    ORG 2000H
stack_bottom:   ; 100 bytes of stack
    DEFS 100, 0
stack_top:   
