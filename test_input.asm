%include "constants.inc"

section .bss
test_record resb RECORD_SIZE

section .text
global _start
extern add_student_name
extern print_string

_start:
    mov rdi, test_record
    call add_student_name

    mov rsi, test_record
    mov rdx, NAME_LEN
    call print_string

    mov rax, 60
    mov rdi, 0
    syscall