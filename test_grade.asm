section .data
pass1_msg db "PASS: average = 87", 10
pass1_len equ $ - pass1_msg
fail1_msg db "FAIL: average wrong", 10
fail1_len equ $ - fail1_msg

pass2_msg db "PASS: grade = B", 10
pass2_len equ $ - pass2_msg
fail2_msg db "FAIL: grade wrong", 10
fail2_len equ $ - fail2_msg

section .text
global _start
extern calculate_average
extern get_letter_grade
extern print_string

_start:
    mov rax, 522
    mov rbx, 6
    call calculate_average
    mov r12, rax

    cmp rax, 87
    je .avg_pass

.avg_fail:
    mov rsi, fail1_msg
    mov rdx, fail1_len
    call print_string
    jmp .test_grade

.avg_pass:
    mov rsi, pass1_msg
    mov rdx, pass1_len
    call print_string

.test_grade:
    mov rax, r12
    call get_letter_grade
    cmp al, 'B'
    je .grade_pass

.grade_fail:
    mov rsi, fail2_msg
    mov rdx, fail2_len
    call print_string
    jmp .exit

.grade_pass:
    mov rsi, pass2_msg
    mov rdx, pass2_len
    call print_string

.exit:
    mov rax, 60
    mov rdi, 0
    syscall