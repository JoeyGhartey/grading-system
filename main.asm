%include "constants.inc"
DEFAULT ABS

section .bss
global student_records
global student_count
student_records resb RECORD_SIZE * MAX_STUDENTS
student_count resd 1
choice_buf resb 10

section .data
menu_msg db 10, "1. Add student", 10, "2. View report", 10, "3. Search student", 10, "4. Exit", 10, "Choice: ", 0
menu_msg_len equ $ - menu_msg - 1
full_msg db "Class is full.", 10, 0
full_msg_len equ $ - full_msg - 1
report_header db 10, "--- Report ---", 10, 0
report_header_len equ $ - report_header - 1

section .text
global _start
extern print_string
extern read_input
extern str_to_int
extern add_student_name
extern add_student_scores
extern display_student
extern search_student

_start:
    mov dword [student_count], 0

.menu_loop:
    mov rsi, menu_msg
    mov rdx, menu_msg_len
    call print_string

    mov rsi, choice_buf
    mov rdx, 10
    call read_input
    mov rsi, choice_buf
    mov rdx, rax
    call str_to_int

    cmp rax, 1
    je .add_student
    cmp rax, 2
    je .view_report
    cmp rax, 3
    je .do_search
    cmp rax, 4
    je .exit_program
    jmp .menu_loop

.add_student:
    mov eax, [student_count]
    cmp eax, MAX_STUDENTS
    jl .room_available

    mov rsi, full_msg
    mov rdx, full_msg_len
    call print_string
    jmp .menu_loop

.room_available:
    mov eax, [student_count]
    imul rax, rax, RECORD_SIZE
    lea r12, [student_records + rax]

    mov rdi, r12
    call add_student_name

    mov rdi, r12
    call add_student_scores

    inc dword [student_count]
    jmp .menu_loop

.view_report:
    mov rsi, report_header
    mov rdx, report_header_len
    call print_string

    xor r13, r13
.report_loop:
    mov eax, [student_count]
    cmp r13, rax
    jge .report_done

    mov rax, r13
    imul rax, rax, RECORD_SIZE
    lea r12, [student_records + rax]
    mov rdi, r12
    call display_student

    inc r13
    jmp .report_loop

.report_done:
    jmp .menu_loop

.do_search:
    call search_student
    jmp .menu_loop

.exit_program:
    mov rax, 60
    mov rdi, 0
    syscall