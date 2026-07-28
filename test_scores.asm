%include "constants.inc"
DEFAULT ABS

section .bss
test_record resb RECORD_SIZE
result_buf resb 20

section .data
total_label db "Total: ", 0
total_label_len equ $ - total_label - 1
count_label db " Count: ", 0
count_label_len equ $ - count_label - 1
newline db 10

section .text
global _start
extern add_student_scores
extern print_string
extern int_to_str

_start:
    mov rdi, test_record
    call add_student_scores

    mov rsi, total_label
    mov rdx, total_label_len
    call print_string

    movzx rax, dword [test_record + TOTAL_OFFSET]
    mov rdi, result_buf
    call int_to_str
    mov rsi, result_buf
    call print_string

    mov rsi, count_label
    mov rdx, count_label_len
    call print_string

    movzx rax, dword [test_record + COUNT_OFFSET]
    mov rdi, result_buf
    call int_to_str
    mov rsi, result_buf
    call print_string

    mov rsi, newline
    mov rdx, 1
    call print_string

    mov rax, 60
    mov rdi, 0
    syscall