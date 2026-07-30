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
    ; replace newline with null terminator to prevent buffer overflow issues
    cmp rax, 0
    jle .skip_null
    cmp byte [rdi + rax - 1], 10
    jne .no_nl
    mov byte [rdi + rax - 1], 0
    jmp .skip_null
.no_nl:
    cmp rax, NAME_LEN
    jl .skip_null
    mov byte [rdi + rax - 1], 0
.skip_null:

    pop rdi
    ret

    section .bss
score_buf resb 10

section .data
count_prompt db "How many scores? ", 0
count_prompt_len equ $ - count_prompt - 1
score_prompt db "Enter score: ", 0
score_prompt_len equ $ - score_prompt - 1

section .text
global add_student_scores
extern str_to_int

; add_student_scores: prompts for N scores and stores total+count in the record
; expects: rdi = pointer to the record
add_student_scores:
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi          ; r12 = record pointer, kept safe across calls

    mov rsi, count_prompt
    mov rdx, count_prompt_len
    call print_string

    mov rsi, score_buf
    mov rdx, 10
    call read_input        ; rax = bytes typed
    mov rsi, score_buf
    mov rdx, rax
    call str_to_int
    mov r15, rax            ; r15 = how many scores to read (original count, kept for storage)
    mov r14, rax             ; r14 = loop counter (counts down to 0)
    
    cmp r15, 20
    jle .count_ok
    mov r15, 20
    mov r14, 20
.count_ok:

    xor r13, r13              ; r13 = running total, starts at 0

.loop:
    cmp r14, 0
    je .done

    mov rsi, score_prompt
    mov rdx, score_prompt_len
    call print_string

    mov rsi, score_buf
    mov rdx, 10
    call read_input
    mov rsi, score_buf
    mov rdx, rax
    call str_to_int

    add r13, rax
    dec r14
    jmp .loop

.done:
    mov [r12 + TOTAL_OFFSET], r13d
    mov [r12 + COUNT_OFFSET], r15d

    pop r15
    pop r14
    pop r13
    pop r12
    ret