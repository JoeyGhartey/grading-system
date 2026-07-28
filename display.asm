%include "constants.inc"
DEFAULT ABS

section .bss
avg_buf resb 20
grade_buf resb 1

section .data
avg_label db " Average: ", 0
avg_label_len equ $ - avg_label - 1
grade_label db " Grade: ", 0
grade_label_len equ $ - grade_label - 1
newline db 10

section .text
global display_student
extern print_string
extern calculate_average
extern get_letter_grade
extern int_to_str

; display_student: prints name, average, and letter grade for one record
; expects: rdi = pointer to the record
display_student:
    push r13
    push r12
    mov r13, rdi           ; r13 = record pointer, kept safe across calls

    mov rsi, r13
    mov rdx, NAME_LEN
    call print_string

    mov rsi, avg_label
    mov rdx, avg_label_len
    call print_string

    movzx rax, dword [r13 + TOTAL_OFFSET]
    movzx rbx, dword [r13 + COUNT_OFFSET]
    call calculate_average
    mov r12, rax             ; save average, print_string/int_to_str will clobber rax

    mov rdi, avg_buf
    call int_to_str
    mov rsi, avg_buf
    call print_string

    mov rsi, grade_label
    mov rdx, grade_label_len
    call print_string

    mov rax, r12
    call get_letter_grade
    mov [grade_buf], al
    mov rsi, grade_buf
    mov rdx, 1
    call print_string

    mov rsi, newline
    mov rdx, 1
    call print_string

    pop r12
    pop r13
    ret