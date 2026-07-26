section .data
text db "Hello, World!", 10
text_len equ $ - text

section .text
global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, text
    mov rdx, text_len
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
