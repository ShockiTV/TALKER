@echo off
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed.
) else (
    echo Python is installed.
)

python main.py