%include "constants.inc"

section .bss
buffer resb NAME_LEN

section .data
prompt db "Enter your name: ", 0
prompt_len equ $ - prompt - 1

section .text
global _start
extern print_string
extern read_input

_start:
    mov rsi, prompt
    mov rdx, prompt_len
    call print_string

    mov rsi, buffer
    mov rdx, NAME_LEN
    call read_input
    ; rax now holds number of bytes actually typed

    mov rdx, rax
    mov rsi, buffer
    call print_string

    mov rax, 60
    mov rdi, 0
    syscall