%include "constants.inc"

section .data
name_prompt db "Enter student name: ", 0
name_prompt_len equ $ - name_prompt - 1

section .text
global add_student_name
extern print_string
extern read_input

; add_student_name: prompts for a name and stores it at the given record address
; expects: rdi = pointer to the record (record start)
add_student_name:
    push rdi              ; save record pointer, print_string/read_input will use registers

    mov rsi, name_prompt
    mov rdx, name_prompt_len
    call print_string

    pop rdi                ; restore record pointer
    push rdi
    mov rsi, rdi            ; store name directly at start of record (offset 0)
    mov rdx, NAME_LEN
    call read_input
    ; rax = number of bytes actually typed, currently unused here but available

    pop rdi
    ret