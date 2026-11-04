@echo off
setlocal

echo.
set "ADB="
set /p "ADB=Enter adb.exe full path: "

if "%ADB%"=="" (
    echo ERROR: No path entered.
    pause
    exit /b 1
)

if not exist "%ADB%" (
    echo ERROR: File not found: %ADB%
    pause
    exit /b 1
)

echo INFO: adb = %ADB%
echo.

"%ADB%" devices

pause
