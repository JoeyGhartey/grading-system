section .text
global str_to_int
global int_to_str

; str_to_int: converts ASCII digits to an integer
; expects: rsi = pointer to string, rdx = length
; returns: rax = integer value
str_to_int:
    xor rax, rax        ; rax = 0, will hold the result
    xor rcx, rcx        ; rcx = index counter
.loop:
    cmp rcx, rdx
    je .done
    movzx r8, byte [rsi + rcx]
    cmp r8, 10           ; stop at newline
    je .done
    cmp r8, '0'
    jl .done
    cmp r8, '9'
    jg .done
    sub r8, '0'          ; convert ASCII char to its digit value
    imul rax, rax, 10    ; shift existing result left one decimal place
    add rax, r8
    inc rcx
    jmp .loop
.done:
    ret