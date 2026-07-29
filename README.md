# Classroom Grading System (x86_64 Assembly)

An interactive console grading application written in 64-bit x86 assembly (`x86_64`) for Windows. The application includes in-memory Bubble Sort routines, binary data persistence (`students.dat`), CSV export capabilities (`students.csv`), linear search routines, and aggregate statistics calculation.

## Architecture Diagram

![CPU and Memory Architecture Diagram](images/assembly_cpu_memory_infographic.png)
*Figure 1: Hardware execution model showing interaction between CPU registers, RAM memory segments, and assembly procedure routines.*

---

## Features

- **Menu Control Loop**: Console menu interface providing 8 system functions.
- **Record Entry**: Input Student ID, Name, Assignment Score (0-100), and Exam Score (0-100). Calculates Cumulative Total (0-200), Integer Average (0-100), and assigns letter grade (`A`, `B`, `C`, `D`, `F`).
- **Student Search**: Option `[2]` performs a linear search by Student ID.
- **Tabular Display**: Option `[3]` prints aligned record tables.
- **Bubble Sort Routine**: Option `[4]` executes an in-place assembly Bubble Sort by Average Score (Descending) or Student ID (Ascending).
- **Class Statistics**: Option `[5]` calculates class average, top/lowest performers, pass/fail counts, and pass rate percentage.
- **Data Persistence**: Options `[6]` and `[7]` save/load binary database `students.dat` and export formatted CSV `students.csv`.

---

## Data Memory Layout

Each student record occupies an 80-byte memory block allocated in the `.bss` section array `students`.

| Field Offset | Field Name | Data Type | Size | Description |
|---|---|---|---|---|
| `+0` | Student ID | Signed Integer | 8 Bytes | Unique ID number |
| `+8` | Student Name | String | 32 Bytes | Null-terminated string buffer |
| `+40` | Assignment Score | Signed Integer | 8 Bytes | Assignment grade (0-100) |
| `+48` | Exam Score | Signed Integer | 8 Bytes | Final exam grade (0-100) |
| `+56` | Total Score | Signed Integer | 8 Bytes | Cumulative score (0-200) |
| `+64` | Average Score | Signed Integer | 8 Bytes | Integer average (0-100) |
| `+72` | Letter Grade | Character / Quad | 8 Bytes | ASCII letter grade (`A`, `B`, `C`, `D`, `F`) |

---

## Build Instructions

### Prerequisites
- Windows 10 / 11 (64-bit)
- GCC / MinGW-w64 (`x86_64-w64-mingw32`)

### Compiling

#### Option 1: Using Batch Script
```cmd
build.bat
```

#### Option 2: Direct Command Line
```cmd
gcc -g -O0 -o grading_system.exe grading_system.s
```

#### Option 3: Using Make
```cmd
make
```

### Running the Application
```cmd
.\grading_system.exe
```

---

## Repository Files

- `grading_system.s`: Main Assembly source code.
- `build.bat`: Windows batch build script.
- `Makefile`: Project Makefile.
- `Classroom_Grading_System_Technical_Manual.pdf`: Technical PDF reference manual.
- `COMPREHENSIVE_GUIDE.md`: Markdown technical guide.
- `images/`: Architectural and hardware visual diagrams.

---

## License
Distributed under the MIT License. See `LICENSE` for details.
