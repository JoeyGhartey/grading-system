@echo off
setlocal
echo Compiling Classroom Grading System (x86_64 Assembly)...

where gcc.exe >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    if exist "C:\msys64\ucrt64\bin\gcc.exe" (
        set GCC="C:\msys64\ucrt64\bin\gcc.exe"
    ) else (
        echo Error: gcc compiler not found.
        exit /b 1
    )
) else (
    set GCC=gcc.exe
)

%GCC% -g -O0 -o grading_system.exe grading_system.s

if %ERRORLEVEL% EQU 0 (
    echo Build successful: grading_system.exe
) else (
    echo Build failed.
    exit /b 1
)
endlocal
