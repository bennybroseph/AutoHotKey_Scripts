@echo off
setlocal

rem === Executable names ===
set "LAUNCHER_EXE=Battle.net.exe"
set "JOY_EXE=Joystick to Keyboard Emulation.exe"
set "JOY_DIR=%~dp0"

rem === Possible Diablo III executables ===
set "GAME1=Diablo III.exe"
set "GAME2=Diablo III64.exe"
set "GAME3=Diablo III Retail.exe"

rem === Wait for Battle.net ===
echo Waiting for Battle.net launcher...
:waitLauncher
timeout /t 3 >nul
tasklist | find /i "%LAUNCHER_EXE%" >nul
if errorlevel 1 goto waitLauncher

echo Battle.net detected. Watching for Diablo III...
:waitGame
timeout /t 3 >nul
tasklist | find /i "%GAME1%" >nul || tasklist | find /i "%GAME2%" >nul || tasklist | find /i "%GAME3%" >nul
if errorlevel 1 goto waitGame

echo Diablo III detected! Starting joystick helper...
start "" "%JOY_DIR%\%JOY_EXE%"

:monitor
timeout /t 5 >nul

rem === Check if Battle.net is still running ===
tasklist | find /i "%LAUNCHER_EXE%" >nul
if errorlevel 1 (
    echo Battle.net closed. Stopping joystick helper and exiting watcher...
    taskkill /f /im "%JOY_EXE%" >nul 2>&1
    exit
)

rem === Check if Diablo III is still running ===
tasklist | find /i "%GAME1%" >nul || tasklist | find /i "%GAME2%" >nul || tasklist | find /i "%GAME3%" >nul
if errorlevel 1 (
    echo Diablo III closed. Stopping joystick helper...
    taskkill /f /im "%JOY_EXE%" >nul 2>&1
    echo Waiting for Diablo III to restart or Battle.net to close...
    goto waitGame
)
goto monitor
