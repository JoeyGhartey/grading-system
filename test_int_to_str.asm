section .bss
result_buf resb 20

section .data
label_msg db "Converting 87, result: ", 0
label_len equ $ - label_msg

newline db 10

section .text
global _start
extern int_to_str
extern print_string

_start:
    mov rsi, label_msg
    mov rdx, label_len
    call print_string

    mov rax, 87
    mov rdi, result_buf
    call int_to_str
    ; rdx now holds the length of the resulting string

    mov rsi, result_buf
    call print_string

    mov rsi, newline
    mov rdx, 1
    call print_string

    mov rax, 60
    mov rdi, 0
    syscall