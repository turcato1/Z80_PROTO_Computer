===========================================================================
; Thiago Turcato do Rego - 2023
; Project: Z80 COOL, Z80 computer in breadboard
; File: BIOS program
;===========================================================================

; Compilation directives for allocating memory (no bank) and SLD file generation
 DEVICE NOSLOT64K
 SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION    

; Variable definition
;EPRBEGIN    EQU 0x0000
;EPRSIZE     EQU 0x2000
;EEPBEGIN    EQU 0x2000
;EEPSIZE     EQU 0x2000
;RAMBEGIN    EQU 0x4000
;RAMSIZE     EQU 0x2000


; Beggining of BIOS program
    ORG 0000H
;entry_point:

; ********************** Main Program ********************** 

; Program setup & initialization
;    LD SP, stack_top            ;Set stack pointer to the end of the ram
; Stall begin for address sequencing test and redirection to EEPROM
    NOP
    NOP
    NOP
    NOP
    NOP
    JP 2000H
    NOP
    HALT
; Program End