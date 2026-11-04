@echo off
REM ============================================================
REM  Virtua Cop 2 VR - Install Script (stripped ROM version)
REM ============================================================
setlocal

REM ---------- Ask for adb path ----------
echo.
set "ADB="
set /p "ADB=Enter adb.exe full path (e.g. C:\Android\Sdk\platform-tools\adb.exe): "
if not defined ADB (
    echo [ERROR] No path entered.
    pause
    exit /b 1
)
if not exist "%ADB%" (
    echo [ERROR] File not found: %ADB%
    pause
    exit /b 1
)
echo [INFO] adb: %ADB%
echo.

REM ---------- Check device ----------
echo [INFO] Checking device...
"%ADB%" devices | findstr /R /C:"device$" >/dev/null
if errorlevel 1 (
    echo [ERROR] No device detected. Connect Quest 3 via USB and allow USB debugging.
    pause
    exit /b 1
)
"%ADB%" devices | findstr /V "List of devices"
echo [OK] Device found.
echo.
pause

REM ---------- Install APK ----------
set "APK=%~dp0vcop2vr.apk"
if not exist "%APK%" (
    echo [ERROR] APK not found: %APK%
    pause
    exit /b 1
)
echo [INFO] Installing %APK% ...
"%ADB%" install -r "%APK%"
if errorlevel 1 (
    echo [WARN] Install failed, trying uninstall first...
    "%ADB%" uninstall io.vcop2vr
    "%ADB%" install "%APK%"
    if errorlevel 1 (
        echo [ERROR] Install failed.
        pause
        exit /b 1
    )
)
echo [OK] Installed.
echo.
pause

REM ---------- Push ROM ----------
set "ROMDIR=%~dp0roms"
if not exist "%ROMDIR%" (
    echo [ERROR] ROM dir not found: %ROMDIR%
    pause
    exit /b 1
)

echo [INFO] Creating ROM directory...
"%ADB%" shell mkdir -p /sdcard/Android/data/io.vcop2vr/files/roms

echo [INFO] Pushing ROM files...
for %%F in ("%ROMDIR%\*.zip") do (
    echo   - %%~nxF
    "%ADB%" push "%%F" /sdcard/Android/data/io.vcop2vr/files/roms/%%~nxF
)
echo [OK] ROM pushed.
echo.
pause

REM ---------- Grant permissions ----------
echo [INFO] Granting storage permissions...
"%ADB%" shell pm grant io.vcop2vr android.permission.WRITE_EXTERNAL_STORAGE 2>/dev/null
"%ADB%" shell pm grant io.vcop2vr android.permission.READ_EXTERNAL_STORAGE 2>/dev/null
echo [OK] Permissions granted.
echo.

echo ============================================================
echo  All done! Open "Virtua Cop 2 VR" on your Quest 3 to play.
echo ============================================================
pause
