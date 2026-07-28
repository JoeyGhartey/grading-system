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

; int_to_str: converts an integer to ASCII digits
; expects: rax = integer value, rdi = buffer to write into
; returns: rdx = length of resulting string
int_to_str:
    push rbx
    mov rbx, rdi        ; rbx = buffer start (save it, rdi will move)
    mov rcx, 10          ; divisor

    ; handle the special case of zero
    cmp rax, 0
    jne .convert
    mov byte [rbx], '0'
    mov rdx, 1
    pop rbx
    ret

.convert:
    lea rdi, [rbx + 20]  ; work from the end of a scratch area backwards
    mov r9, rdi          ; r9 = end marker, used to compute length later

.divide_loop:
    xor rdx, rdx
    div rcx              ; rax = rax / 10, rdx = remainder (the next digit)
    add rdx, '0'         ; convert digit to ASCII
    dec rdi
    mov [rdi], dl
    cmp rax, 0
    jne .divide_loop

    ; copy from scratch area back to the real buffer start
    mov rsi, rdi
    mov rdi, rbx
    mov rcx, r9
    sub rcx, rsi         ; rcx = number of digits
    mov rdx, rcx          ; save length to return

.copy_loop:
    cmp rcx, 0
    je .done
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    dec rcx
    jmp .copy_loop

.done:
    pop rbx
    ret