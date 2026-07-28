%include "constants.inc"
DEFAULT ABS

section .data
test_name db "Jamez", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0   ; padded to 20 bytes

section .bss
test_record resb RECORD_SIZE

section .text
global _start
extern display_student

_start:
    mov rdi, test_record

    ; copy the 20-byte name into the record
    mov rsi, test_name
    mov rcx, NAME_LEN
.copy:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jnz .copy

    mov dword [test_record + TOTAL_OFFSET], 240
    mov dword [test_record + COUNT_OFFSET], 3

    mov rdi, test_record
    call display_student

    mov rax, 60
    mov rdi, 0
    syscall