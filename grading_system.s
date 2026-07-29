/*
 * Classroom Grading System in x86_64 Assembly Language
 * Target: Windows 64-bit (GCC / MSYS2 UCRT64)
 * Assembly Syntax: Intel Syntax (GNU Assembler .intel_syntax noprefix)
 *
 * File: grading_system.s
 */

.intel_syntax noprefix

/* External C runtime functions */
.global main
.extern printf
.extern scanf
.extern puts
.extern system
.extern fflush
.extern fopen
.extern fwrite
.extern fread
.extern fclose
.extern fprintf
.extern fputs

/* Struct layout constants (Student Record = 80 bytes)
 * Offset  0: ID (8 bytes, integer)
 * Offset  8: Name (32 bytes, null-terminated string)
 * Offset 40: Assignment Score (8 bytes, integer)
 * Offset 48: Exam Score (8 bytes, integer)
 * Offset 56: Total Score (8 bytes, integer)
 * Offset 64: Average Score (8 bytes, integer)
 * Offset 72: Grade Character (8 bytes, stored as qword for alignment)
 */
.equ RECORD_SIZE, 80
.equ MAX_STUDENTS, 30

.section .data
/* Banner and Menu Texts */
str_header:
    .asciz "\n=========================================================\n"
str_title:
    .asciz "        ENHANCED CLASSROOM GRADING SYSTEM (x86_64)        \n"
str_banner_line:
    .asciz "=========================================================\n"
str_menu:
    .asciz "  [1] Add Student Record\n  [2] Search Student by ID\n  [3] Display All Student Grades\n  [4] Sort Student Records (Bubble Sort)\n  [5] View Class Performance Summary\n  [6] Save Records & Export CSV\n  [7] Load Records from Disk\n  [8] Exit System\n---------------------------------------------------------\nSelect an option (1-8): "

/* Prompts */
fmt_scan_int:
    .asciz "%lld"
fmt_scan_str:
    .asciz "%31s"

prompt_id:
    .asciz "Enter Student ID (number): "
prompt_name:
    .asciz "Enter Student Name (single word/no spaces): "
prompt_score1:
    .asciz "Enter Assignment Score (0-100): "
prompt_score2:
    .asciz "Enter Exam Score (0-100): "
prompt_search_id:
    .asciz "Enter Student ID to search: "
prompt_sort_menu:
    .asciz "\n--- SORT OPTIONS ---\n  [1] Sort by Average Score (Descending - Highest First)\n  [2] Sort by Student ID (Ascending)\nSelect sort criteria (1-2): "

/* File Names and Modes */
dat_filename:
    .asciz "students.dat"
csv_filename:
    .asciz "students.csv"
mode_wb:
    .asciz "wb"
mode_rb:
    .asciz "rb"
mode_w:
    .asciz "w"

/* CSV Formatting */
csv_header:
    .asciz "ID,Name,Assignment,Exam,Total,Average,Grade\n"
csv_row_fmt:
    .asciz "%lld,%s,%lld,%lld,%lld,%lld,%c\n"

/* Messages */
msg_full:
    .asciz "\n[ERROR] Storage limit reached! Cannot add more students.\n"
msg_added:
    .asciz "\n[SUCCESS] Student record added successfully!\n"
msg_empty:
    .asciz "\n[INFO] No student records found in memory.\n"
msg_not_found:
    .asciz "\n[RESULT] Student ID not found.\n"
msg_invalid_opt:
    .asciz "\n[ERROR] Invalid choice! Please select a valid option.\n"
msg_save_success:
    .asciz "\n[SUCCESS] Records saved to 'students.dat' & exported to 'students.csv'!\n"
msg_load_success:
    .asciz "\n[SUCCESS] Database loaded from 'students.dat'!\n"
msg_load_none:
    .asciz "\n[INFO] No existing 'students.dat' file found. Starting fresh.\n"
msg_sort_done:
    .asciz "\n[SUCCESS] Student records sorted successfully!\n"
msg_goodbye:
    .asciz "\n=========================================================\n  Auto-saved records. Thank you for using Grading System! \n=========================================================\n"

/* Display table formatting */
tbl_header:
    .asciz "\n=============================================================================\n ID       NAME                 ASSIGN   EXAM   TOTAL   AVERAGE   GRADE       \n=============================================================================\n"
tbl_row:
    .asciz " %-8lld %-20s %-8lld %-6lld %-7lld %-9lld %c\n"
tbl_divider:
    .asciz "-----------------------------------------------------------------------------\n"

/* Search Result View */
str_search_header:
    .asciz "\n------------------- STUDENT RECORD FOUND -------------------\n"
str_search_id:
    .asciz " Student ID       : %lld\n"
str_search_name:
    .asciz " Student Name     : %s\n"
str_search_score1:
    .asciz " Assignment Score : %lld\n"
str_search_score2:
    .asciz " Exam Score       : %lld\n"
str_search_total:
    .asciz " Total Score      : %lld / 200\n"
str_search_avg:
    .asciz " Average Score    : %lld / 100\n"
str_search_grade:
    .asciz " Letter Grade     : %c\n"

/* Statistics View */
stats_header:
    .asciz "\n=========================================================\n             CLASS PERFORMANCE SUMMARY                   \n=========================================================\n"
stats_total_students:
    .asciz " Total Enrolled Students   : %lld\n"
stats_class_avg:
    .asciz " Class Average Score       : %lld / 100\n"
stats_top_student:
    .asciz " Top Performer             : %s (ID: %lld, Avg: %lld)\n"
stats_low_student:
    .asciz " Lowest Performer          : %s (ID: %lld, Avg: %lld)\n"
stats_pass_fail:
    .asciz " Passing Students (Avg>=60): %lld\n Failing Students (Avg<60) : %lld\n Pass Rate                 : %lld%%\n"

.section .bss
/* Data Storage */
student_count:
    .quad 0

/* Student Array Storage: 30 students * 80 bytes = 2400 bytes */
students:
    .space 2400

/* Temporary variables */
temp_id:
    .quad 0
temp_score1:
    .quad 0
temp_score2:
    .quad 0
temp_choice:
    .quad 0

.section .text

/* =========================================================
   MAIN ENTRY POINT
   ========================================================= */
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32                 /* 16-byte aligned stack (8 ret + 8 rbp + 32 = 48) */

    /* Auto-load existing records on startup */
    call load_records

menu_loop:
    /* Print Header Banner */
    lea rcx, [rip + str_header]
    call printf
    lea rcx, [rip + str_title]
    call printf
    lea rcx, [rip + str_banner_line]
    call printf

    /* Print Menu Options */
    lea rcx, [rip + str_menu]
    call printf

    /* Flush output buffer */
    mov rcx, 0
    call fflush

    /* Read user choice */
    lea rcx, [rip + fmt_scan_int]
    lea rdx, [rip + temp_choice]
    call scanf

    mov rax, qword ptr [rip + temp_choice]

    cmp rax, 1
    je do_add
    cmp rax, 2
    je do_search
    cmp rax, 3
    je do_display
    cmp rax, 4
    je do_sort
    cmp rax, 5
    je do_stats
    cmp rax, 6
    je do_save
    cmp rax, 7
    je do_load
    cmp rax, 8
    je do_exit

    /* Invalid Choice */
    lea rcx, [rip + msg_invalid_opt]
    call printf
    jmp menu_loop

do_add:
    call add_student
    jmp menu_loop

do_search:
    call search_student
    jmp menu_loop

do_display:
    call display_students
    jmp menu_loop

do_sort:
    call sort_students
    jmp menu_loop

do_stats:
    call display_stats
    jmp menu_loop

do_save:
    call save_records
    jmp menu_loop

do_load:
    call load_records
    jmp menu_loop

do_exit:
    /* Auto-save on exit */
    call save_records

    lea rcx, [rip + msg_goodbye]
    call printf

    mov eax, 0
    add rsp, 32
    pop rbp
    ret

/* =========================================================
   FUNCTION: add_student
   Adds a new student record into the array
   ========================================================= */
add_student:
    push rbp                    /* 8 */
    mov rbp, rsp
    push rbx                    /* 8 */
    push rsi                    /* 8 */
    sub rsp, 32                 /* 8 + 8 + 8 + 8 + 32 = 64 (16-byte aligned) */

    /* Check if full */
    mov rax, qword ptr [rip + student_count]
    cmp rax, MAX_STUDENTS
    jl space_available

    lea rcx, [rip + msg_full]
    call printf
    jmp add_student_end

space_available:
    /* Compute record address: base + count * 80 */
    imul rax, RECORD_SIZE
    lea rbx, [rip + students]
    add rbx, rax                /* rbx points to current student record slot */

    /* Prompt ID */
    lea rcx, [rip + prompt_id]
    call printf
    lea rcx, [rip + fmt_scan_int]
    lea rdx, [rbx + 0]          /* ID offset 0 */
    call scanf

    /* Prompt Name */
    lea rcx, [rip + prompt_name]
    call printf
    lea rcx, [rip + fmt_scan_str]
    lea rdx, [rbx + 8]          /* Name offset 8 */
    call scanf

    /* Prompt Assignment Score */
    lea rcx, [rip + prompt_score1]
    call printf
    lea rcx, [rip + fmt_scan_int]
    lea rdx, [rbx + 40]         /* Score1 offset 40 */
    call scanf

    /* Prompt Exam Score */
    lea rcx, [rip + prompt_score2]
    call printf
    lea rcx, [rip + fmt_scan_int]
    lea rdx, [rbx + 48]         /* Score2 offset 48 */
    call scanf

    /* Calculate Total = Score1 + Score2 */
    mov rax, qword ptr [rbx + 40]
    add rax, qword ptr [rbx + 48]
    mov qword ptr [rbx + 56], rax   /* Total offset 56 */

    /* Calculate Average = Total / 2 */
    cqo
    mov rcx, 2
    idiv rcx
    mov qword ptr [rbx + 64], rax   /* Average offset 64 */

    /* Grade Assignment */
    mov rdx, 'A'
    cmp rax, 90
    jge store_grade

    mov rdx, 'B'
    cmp rax, 80
    jge store_grade

    mov rdx, 'C'
    cmp rax, 70
    jge store_grade

    mov rdx, 'D'
    cmp rax, 60
    jge store_grade

    mov rdx, 'F'

store_grade:
    mov qword ptr [rbx + 72], rdx   /* Grade offset 72 */

    /* Increment student_count */
    mov rax, qword ptr [rip + student_count]
    inc rax
    mov qword ptr [rip + student_count], rax

    lea rcx, [rip + msg_added]
    call printf

add_student_end:
    add rsp, 32
    pop rsi
    pop rbx
    pop rbp
    ret

/* =========================================================
   FUNCTION: display_students
   Prints tabular report of all student records
   ========================================================= */
display_students:
    push rbp                    /* 8 */
    mov rbp, rsp
    push rbx                    /* 8 */
    push rsi                    /* 8 */
    push rdi                    /* 8 */
    push r12                    /* 8 */
    push r13                    /* 8 */
    sub rsp, 72                 /* 56 + 72 = 128 (16-byte aligned) */

    mov rsi, qword ptr [rip + student_count]
    cmp rsi, 0
    jne print_table_clean

    lea rcx, [rip + msg_empty]
    call printf
    jmp display_clean_end

print_table_clean:
    lea rcx, [rip + tbl_header]
    call printf

    xor rbx, rbx               /* rbx = i = 0 */

clean_loop:
    cmp rbx, rsi
    jge clean_done

    mov rax, rbx
    imul rax, RECORD_SIZE
    lea rdi, [rip + students]
    add rdi, rax                /* rdi = record pointer */

    mov rdx, [rdi + 0]          /* ID */
    lea r8,  [rdi + 8]          /* Name */
    mov r9,  [rdi + 40]         /* Score1 */

    mov rax, [rdi + 48]         /* Score2 */
    mov qword ptr [rsp + 32], rax
    mov rax, [rdi + 56]         /* Total */
    mov qword ptr [rsp + 40], rax
    mov rax, [rdi + 64]         /* Average */
    mov qword ptr [rsp + 48], rax
    mov rax, [rdi + 72]         /* Grade */
    mov qword ptr [rsp + 56], rax

    lea rcx, [rip + tbl_row]
    call printf

    inc rbx
    jmp clean_loop

clean_done:
    lea rcx, [rip + tbl_divider]
    call printf

display_clean_end:
    add rsp, 72
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

/* =========================================================
   FUNCTION: search_student
   Searches for a student record by ID and displays details
   ========================================================= */
search_student:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    sub rsp, 40

    mov rsi, qword ptr [rip + student_count]
    cmp rsi, 0
    jne do_search_input

    lea rcx, [rip + msg_empty]
    call printf
    jmp search_end

do_search_input:
    lea rcx, [rip + prompt_search_id]
    call printf
    lea rcx, [rip + fmt_scan_int]
    lea rdx, [rip + temp_id]
    call scanf

    mov r10, qword ptr [rip + temp_id] /* Target ID */
    xor rbx, rbx                       /* i = 0 */

search_loop:
    cmp rbx, rsi
    jge search_not_found

    mov rax, rbx
    imul rax, RECORD_SIZE
    lea rdi, [rip + students]
    add rdi, rax

    cmp qword ptr [rdi + 0], r10
    je search_found

    inc rbx
    jmp search_loop

search_found:
    lea rcx, [rip + str_search_header]
    call printf

    lea rcx, [rip + str_search_id]
    mov rdx, qword ptr [rdi + 0]
    call printf

    lea rcx, [rip + str_search_name]
    lea rdx, [rdi + 8]
    call printf

    lea rcx, [rip + str_search_score1]
    mov rdx, qword ptr [rdi + 40]
    call printf

    lea rcx, [rip + str_search_score2]
    mov rdx, qword ptr [rdi + 48]
    call printf

    lea rcx, [rip + str_search_total]
    mov rdx, qword ptr [rdi + 56]
    call printf

    lea rcx, [rip + str_search_avg]
    mov rdx, qword ptr [rdi + 64]
    call printf

    lea rcx, [rip + str_search_grade]
    mov rdx, qword ptr [rdi + 72]
    call printf

    jmp search_end

search_not_found:
    lea rcx, [rip + msg_not_found]
    call printf

search_end:
    add rsp, 40
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

/* =========================================================
   FUNCTION: sort_students
   In-memory Bubble Sort for student array
   Option 1: Sort by Average Score (Descending)
   Option 2: Sort by Student ID (Ascending)
   ========================================================= */
sort_students:
    push rbp                    /* 8 */
    mov rbp, rsp
    push rbx                    /* 8 */
    push rsi                    /* 8 */
    push rdi                    /* 8 */
    push r12                    /* 8 */
    push r13                    /* 8 */
    push r14                    /* 8 */
    push r15                    /* 8 */
    sub rsp, 40                 /* Total stack frame 112 (16-byte aligned) */

    mov rsi, qword ptr [rip + student_count]
    cmp rsi, 1
    jg do_sort_prompt

    lea rcx, [rip + msg_empty]
    call printf
    jmp sort_end

do_sort_prompt:
    lea rcx, [rip + prompt_sort_menu]
    call printf
    lea rcx, [rip + fmt_scan_int]
    lea rdx, [rip + temp_choice]
    call scanf

    mov r12, qword ptr [rip + temp_choice] /* Sort mode: 1 or 2 */

    /* Outer loop i from 0 to student_count - 2 */
    xor rbx, rbx               /* rbx = i = 0 */

outer_sort_loop:
    mov rax, rsi
    dec rax
    cmp rbx, rax
    jge sort_completed

    /* Inner loop j from 0 to student_count - i - 2 */
    xor r13, r13               /* r13 = j = 0 */

inner_sort_loop:
    mov rax, rsi
    sub rax, rbx
    dec rax
    cmp r13, rax
    jge next_outer_iter

    /* Get addresses of student[j] and student[j+1] */
    mov rax, r13
    imul rax, RECORD_SIZE
    lea rdi, [rip + students]
    add rdi, rax                /* rdi = &student[j] */
    lea r14, [rdi + RECORD_SIZE] /* r14 = &student[j+1] */

    cmp r12, 2
    je sort_by_id

sort_by_average:
    /* Descending order by average (offset 64): swap if student[j].avg < student[j+1].avg */
    mov rax, qword ptr [rdi + 64]
    mov rdx, qword ptr [r14 + 64]
    cmp rax, rdx
    jl swap_records
    jmp no_swap

sort_by_id:
    /* Ascending order by ID (offset 0): swap if student[j].id > student[j+1].id */
    mov rax, qword ptr [rdi + 0]
    mov rdx, qword ptr [r14 + 0]
    cmp rax, rdx
    jg swap_records
    jmp no_swap

swap_records:
    /* Swap full 80 bytes between rdi and r14 using 10 quadwords */
    xor r15, r15

swap_quad_loop:
    cmp r15, RECORD_SIZE
    jge no_swap

    mov rax, qword ptr [rdi + r15]
    mov rdx, qword ptr [r14 + r15]
    mov qword ptr [rdi + r15], rdx
    mov qword ptr [r14 + r15], rax

    add r15, 8
    jmp swap_quad_loop

no_swap:
    inc r13
    jmp inner_sort_loop

next_outer_iter:
    inc rbx
    jmp outer_sort_loop

sort_completed:
    lea rcx, [rip + msg_sort_done]
    call printf

sort_end:
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

/* =========================================================
   FUNCTION: display_stats
   Calculates and prints class performance summary
   ========================================================= */
display_stats:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 40

    mov rsi, qword ptr [rip + student_count]
    cmp rsi, 0
    jne calc_stats

    lea rcx, [rip + msg_empty]
    call printf
    jmp stats_end

calc_stats:
    xor r12, r12                /* sum = 0 */
    xor r13, r13                /* pass_count = 0 */
    xor rbx, rbx                /* i = 0 */

    lea r14, [rip + students]   /* initialize top = student 0 */
    lea r15, [rip + students]   /* initialize lowest = student 0 */

stats_loop:
    cmp rbx, rsi
    jge stats_compute

    mov rax, rbx
    imul rax, RECORD_SIZE
    lea rdi, [rip + students]
    add rdi, rax

    /* Add to sum of averages */
    mov rax, qword ptr [rdi + 64]
    add r12, rax

    /* Pass count check (average >= 60) */
    cmp rax, 60
    jl check_top
    inc r13

check_top:
    mov rcx, qword ptr [r14 + 64]
    cmp rax, rcx
    jle check_lowest
    mov r14, rdi

check_lowest:
    mov rcx, qword ptr [r15 + 64]
    cmp rax, rcx
    jge next_stat_iter
    mov r15, rdi

next_stat_iter:
    inc rbx
    jmp stats_loop

stats_compute:
    /* Class Average = sum / student_count */
    mov rax, r12
    cqo
    idiv rsi
    mov r12, rax                /* r12 = Class Average */

    /* Print Stats Banner */
    lea rcx, [rip + stats_header]
    call printf

    /* Print Total Students */
    lea rcx, [rip + stats_total_students]
    mov rdx, rsi
    call printf

    /* Print Class Average */
    lea rcx, [rip + stats_class_avg]
    mov rdx, r12
    call printf

    /* Print Top Performer */
    lea rcx, [rip + stats_top_student]
    lea rdx, [r14 + 8]          /* Name */
    mov r8,  qword ptr [r14 + 0] /* ID */
    mov r9,  qword ptr [r14 + 64]/* Avg */
    call printf

    /* Print Lowest Performer */
    lea rcx, [rip + stats_low_student]
    lea rdx, [r15 + 8]          /* Name */
    mov r8,  qword ptr [r15 + 0] /* ID */
    mov r9,  qword ptr [r15 + 64]/* Avg */
    call printf

    /* Pass/Fail Breakdown */
    mov r8, rsi
    sub r8, r13                 /* Fail count */

    mov rax, r13
    imul rax, 100
    cqo
    idiv rsi
    mov r9, rax                 /* Pass rate % */

    lea rcx, [rip + stats_pass_fail]
    mov rdx, r13                /* Pass count */
    call printf

stats_end:
    add rsp, 40
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

/* =========================================================
   FUNCTION: save_records
   Saves student count & array to 'students.dat' (binary)
   Exports records to 'students.csv' (text)
   ========================================================= */
save_records:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    sub rsp, 40

    /* 1. Save Binary Database (students.dat) */
    lea rcx, [rip + dat_filename]
    lea rdx, [rip + mode_wb]
    call fopen

    test rax, rax
    jz save_csv_export
    mov rbx, rax                /* rbx = FILE* handle */

    /* Write student_count (8 bytes) */
    lea rcx, [rip + student_count]
    mov rdx, 8
    mov r8, 1
    mov r9, rbx
    call fwrite

    /* Write students array (RECORD_SIZE * student_count bytes) */
    mov r8, qword ptr [rip + student_count]
    cmp r8, 0
    jbe close_dat

    lea rcx, [rip + students]
    mov rdx, RECORD_SIZE
    mov r9, rbx
    call fwrite

close_dat:
    mov rcx, rbx
    call fclose

save_csv_export:
    /* 2. Export CSV (students.csv) */
    lea rcx, [rip + csv_filename]
    lea rdx, [rip + mode_w]
    call fopen

    test rax, rax
    jz save_finish
    mov rbx, rax                /* rbx = CSV FILE* handle */

    /* Write CSV Header directly: rcx = csv_header, rdx = FILE* */
    lea rcx, [rip + csv_header]
    mov rdx, rbx
    call fputs

    mov rsi, qword ptr [rip + student_count]
    xor rdi, rdi                /* i = 0 */

csv_loop:
    cmp rdi, rsi
    jge close_csv

    mov rax, rdi
    imul rax, RECORD_SIZE
    lea r10, [rip + students]
    add r10, rax                /* r10 = student record ptr */

    mov rcx, rbx                /* FILE* */
    lea rdx, [rip + csv_row_fmt] /* format */
    mov r8,  qword ptr [r10 + 0]  /* ID */
    lea r9,  [r10 + 8]           /* Name */

    /* Additional stack args for fprintf */
    mov rax, qword ptr [r10 + 40] /* Score1 */
    mov qword ptr [rsp + 32], rax
    mov rax, qword ptr [r10 + 48] /* Score2 */
    mov qword ptr [rsp + 40], rax
    mov rax, qword ptr [r10 + 56] /* Total */
    mov qword ptr [rsp + 48], rax
    mov rax, qword ptr [r10 + 64] /* Average */
    mov qword ptr [rsp + 56], rax
    mov rax, qword ptr [r10 + 72] /* Grade */
    mov qword ptr [rsp + 64], rax

    call fprintf

    inc rdi
    jmp csv_loop

close_csv:
    mov rcx, rbx
    call fclose

    lea rcx, [rip + msg_save_success]
    call printf

save_finish:
    add rsp, 40
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

/* =========================================================
   FUNCTION: load_records
   Loads student count & array from 'students.dat'
   ========================================================= */
load_records:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 40

    lea rcx, [rip + dat_filename]
    lea rdx, [rip + mode_rb]
    call fopen

    test rax, rax
    jnz load_file_found

    /* No file exists yet */
    lea rcx, [rip + msg_load_none]
    call printf
    jmp load_end

load_file_found:
    mov rbx, rax                /* rbx = FILE* */

    /* Read student_count */
    lea rcx, [rip + student_count]
    mov rdx, 8
    mov r8, 1
    mov r9, rbx
    call fread

    /* Read students array */
    mov r8, qword ptr [rip + student_count]
    cmp r8, 0
    jbe close_load

    lea rcx, [rip + students]
    mov rdx, RECORD_SIZE
    mov r9, rbx
    call fread

close_load:
    mov rcx, rbx
    call fclose

    lea rcx, [rip + msg_load_success]
    call printf

load_end:
    add rsp, 40
    pop rbx
    pop rbp
    ret
