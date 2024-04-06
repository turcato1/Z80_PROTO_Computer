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
RAMBEGIN            EQU 0x1000
RAMSIZE             EQU 0x1000

; I/O addresses
DSKY_LCDDATA        EQU 0x10
DSKY_KEYB           EQU 0x11
DSKY_LCDE_RW_RS     EQU 0x12
DSKY_IOSETUP        EQU 0x13


;******** Beggining of BIOS program ********
    ORG 2000H
entry_point:

; ********************** Main Program ********************** 

; Program setup & initialization
    LD SP, 5FF0H        ;Set stack pointer to the end of the ram

    LD B, 89H

    LD HL, dmsg_hello
    CALL msg_print

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

    HALT

msg_print:
; 8255 PIO setup
; Port A = output, Port B = input, Port C = output
    PUSH AF
    PUSH BC
    PUSH DE
    LD C, DSKY_IOSETUP 
    LD D, 80H
    OUT (C), D
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Set E pin
; DSKY LCD setup
    LD D, 01H               ;Clear LCD
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.msg_dly_clearlcd:
    DJNZ .msg_dly_clearlcd
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 38H               ;8 bit mode
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.msg_dly_eightbitmd:
    DJNZ .msg_dly_eightbitmd
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 80H               ;select 1st column and 1st row for data
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.msg_dly_firstpos:
    DJNZ .msg_dly_firstpos
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 0FH               ;Cursor off
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.msg_dly_cursormd:
    DJNZ .msg_dly_cursormd
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin
    LD D, 06H               ;Cursor increment
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 04H
    OUT (C), D              ;Set E pin
    LD B, 5
.msg_dly_cursorinc:
    DJNZ .msg_dly_cursorinc
    LD C, DSKY_LCDE_RW_RS
    LD D, 00H
    OUT (C), D              ;Reset E pin

; Welcome & alive message
;    LD HL, TESTMEM       ;Points HL to the text location
    LD E, 00H               ;Initializes char counter (Reg E)
.msg_loop:
    LD A, 00H               ;Sets A reg as NUL char for searching string end
    LD D, (HL)              ;Retrieves the char from the current memory location
    CPI                     ;Compare if (HL) position has a null char and Increment HL
    JR Z, .msg_end          ;If Z = 1, then A=(HL), so message end
    LD C, DSKY_LCDDATA
    OUT (C), D              ;Send LCD setup command
    LD C, DSKY_LCDE_RW_RS
    LD D, 05H
    OUT (C), D              ;Set E and RS pins
    LD D, 00H
    OUT (C), D              ;Reset E and RS pins
    INC E                   ;Increment char printed
    CP 15
    JR NZ, .msg_loop
.msg_end:
    POP DE
    POP BC
    POP AF
    RET

infinite_loop:
    JR infinite_loop

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
