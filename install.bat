@echo off
REM ============================================================
REM  Virtua Cop 2 VR - 安装脚本（剥离 ROM 版）
REM  - 安装 vcop2vr_lite/vcop2vr.apk
REM  - 把 roms\ 下的 ROM 推到设备
REM  - 授权存储权限
REM ============================================================
setlocal enabledelayedexpansion

REM ---------- 定位 adb ----------
set "ADB="
if defined ANDROID_HOME (
    if exist "%ANDROID_HOME%\platform-tools\adb.exe" set "ADB=%ANDROID_HOME%\platform-tools\adb.exe"
)
if not defined ADB (
    if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
)
if not defined ADB (
    if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" set "ADB=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe"
)
if not defined ADB (
    where adb >nul 2>nul && set "ADB=adb"
)
if not defined ADB (
    echo [ERROR] 找不到 adb.exe。请设置 ANDROID_HOME 或把 platform-tools 加入 PATH。
    exit /b 1
)
echo [INFO] adb: %ADB%
echo.

REM ---------- 检查设备 ----------
echo [INFO] 检查设备连接...
"%ADB%" devices | findstr /R /C:"device$" >nul
if errorlevel 1 (
    echo [ERROR] 没有检测到已连接的设备。请用 USB 连接 Quest 3 并在头显里允许 USB 调试。
    exit /b 1
)
"%ADB%" devices | findstr /V "List of devices"
echo.

REM ---------- 安装 APK ----------
set "APK=%~dp0vcop2vr.apk"
if not exist "%APK%" (
    echo [ERROR] 找不到 %APK%
    exit /b 1
)
echo [INFO] 安装 %APK% ...
"%ADB%" install -r "%APK%"
if errorlevel 1 (
    echo [WARN] 覆盖安装失败，尝试先卸载旧版本...
    "%ADB%" uninstall io.vcop2vr
    "%ADB%" install "%APK%"
    if errorlevel 1 (
        echo [ERROR] 安装失败。
        exit /b 1
    )
)
echo [OK] 安装完成
echo.

REM ---------- 推送 ROM ----------
REM 目标目录：/sdcard/Android/data/io.vcop2vr/files/roms/
REM 这是应用私有目录，Port0r 启动时会自动读取
set "ROMDIR=%~dp0roms"
if not exist "%ROMDIR%" (
    echo [ERROR] 找不到 %ROMDIR%
    exit /b 1
)

echo [INFO] 创建 ROM 目录...
"%ADB%" shell mkdir -p /sdcard/Android/data/io.vcop2vr/files/roms

echo [INFO] 推送 ROM...
for %%F in ("%ROMDIR%\*.zip") do (
    echo   - %%~nxF
    "%ADB%" push "%%F" /sdcard/Android/data/io.vcop2vr/files/roms/%%~nxF
)
echo [OK] ROM 推送完成
echo.

REM ---------- 授权 ----------
echo [INFO] 授予存储权限...
"%ADB%" shell pm grant io.vcop2vr android.permission.WRITE_EXTERNAL_STORAGE 2>nul
"%ADB%" shell pm grant io.vcop2vr android.permission.READ_EXTERNAL_STORAGE 2>nul
echo.

echo ============================================================
echo  安装完成！在 Quest 3 里打开 "Virtua Cop 2 VR" 即可游玩。
echo ============================================================
pause
