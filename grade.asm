section .text
global calculate_average
global get_letter_grade

; calculate_average: divides total by count
; expects: rax = total score, rbx = number of scores
; returns: rax = average (whole number, truncated)
calculate_average:
    xor rdx, rdx      ; clear rdx before division (division uses rdx:rax together)
    div rbx            ; rax = rax / rbx, remainder discarded
    ret

; get_letter_grade: maps an average to a letter
; expects: rax = average
; returns: al = ASCII letter ('A','B','C','D','F')
get_letter_grade:
    cmp rax, 70
    jge .grade_a
    cmp rax, 60
    jge .grade_b
    cmp rax, 50
    jge .grade_c
    cmp rax, 40
    jge .grade_d
    mov al, 'F'
    ret
.grade_a:
    mov al, 'A'
    ret
.grade_b:
    mov al, 'B'
    ret
.grade_c:
    mov al, 'C'
    ret
.grade_d:
    mov al, 'D'
    ret