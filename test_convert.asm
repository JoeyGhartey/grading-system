section .data
test_str db "87", 10
test_len equ $ - test_str

pass_msg db "PASS: got 87", 10
pass_len equ $ - pass_msg

fail_msg db "FAIL: wrong value", 10
fail_len equ $ - fail_msg

section .text
global _start
extern str_to_int
extern print_string

_start:
    mov rsi, test_str
    mov rdx, test_len
    call str_to_int
    ; rax now holds the converted integer

    cmp rax, 87
    je .pass

.fail:
    mov rsi, fail_msg
    mov rdx, fail_len
    call print_string
    jmp .exit

.pass:
    mov rsi, pass_msg
    mov rdx, pass_len
    call print_string

.exit:
    mov rax, 60
    mov rdi, 0
    syscall