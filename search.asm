%include "constants.inc"
DEFAULT ABS

section .bss
search_name_buf resb NAME_LEN

section .data
search_prompt db "Enter name to search: ", 0
search_prompt_len equ $ - search_prompt - 1
not_found_msg db "Student not found.", 10, 0
not_found_len equ $ - not_found_msg - 1

section .text
global search_student
extern print_string
extern read_input
extern display_student

; search_student: prompts for a name, scans all records, displays a match
; expects: nothing, reads student_count and student_records as externals via main.asm's memory
extern student_records
extern student_count

search_student:
    push r12
    push r13

    ; clear the search buffer first so old characters don't linger
    mov rdi, search_name_buf
    mov rcx, NAME_LEN
.clear_loop:
    mov byte [rdi], 0
    inc rdi
    loop .clear_loop

    mov rsi, search_prompt
    mov rdx, search_prompt_len
    call print_string

    mov rsi, search_name_buf
    mov rdx, NAME_LEN
    call read_input

    xor r13, r13                    ; r13 = loop index i = 0
.scan_loop:
    mov eax, [student_count]
    cmp r13, rax
    jge .not_found

    mov rax, r13
    imul rax, rax, RECORD_SIZE
    lea r12, [student_records + rax]

    mov rsi, r12
    mov rdi, search_name_buf
    mov rcx, NAME_LEN
    repe cmpsb
    je .found

    inc r13
    jmp .scan_loop

.found:
    mov rdi, r12
    call display_student
    jmp .done

.not_found:
    mov rsi, not_found_msg
    mov rdx, not_found_len
    call print_string

.done:
    pop r13
    pop r12
    ret