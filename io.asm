section .text
global print_string
global read_input

print_string:
    ; expects: rsi = pointer to string, rdx = length
    mov rax, 1
    mov rdi, 1
    syscall
    ret

read_input:
    ; expects: rsi = buffer address, rdx = max bytes to read
    mov rax, 0
    mov rdi, 0
    syscall
    ret