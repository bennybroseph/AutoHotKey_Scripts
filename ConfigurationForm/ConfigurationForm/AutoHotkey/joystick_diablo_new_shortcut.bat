@echo off
setlocal

rem --- Get current user Desktop path from Registry (handles OneDrive redirection)
for /f "tokens=3*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop 2^>nul') do (
    set "DESKTOP=%%a %%b"
)
rem --- Expand environment variables in the path (e.g., %USERPROFILE%)
call set "DESKTOP=%DESKTOP%"
rem --- Remove trailing space if present
set "DESKTOP=%DESKTOP: =%"

rem --- Fallback to default if registry query failed
if not defined DESKTOP set "DESKTOP=%USERPROFILE%\Desktop"

rem --- Name for the shortcut
set "SHORTCUT_NAME=Diablo III Joystick.lnk"

rem --- Path to Diablo launcher (assumes default installation)
set "DIABLO_LAUNCHER=%ProgramFiles(x86)%\Diablo III\Diablo III Launcher.exe"

rem --- Path to the watcher batch (assumes this script is in the same folder as watch_diablo.bat)
set "WATCH_BAT=%~dp0joystick_diablo_watcher.bat"

rem --- Path to Joystick exe for icon
set "JOY_EXE=%~dp0Joystick to Keyboard Emulation.exe"

rem --- Path to the shortcut to create
set "SHORTCUT_PATH=%DESKTOP%\%SHORTCUT_NAME%"

rem --- Create VBS launcher that starts both
set "LAUNCHER_VBS=%~dp0joystick_diablo_launcher.vbs"
(
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo WshShell.Run "cmd.exe /c ""%WATCH_BAT%""", 0, False
echo WshShell.Run """%DIABLO_LAUNCHER%""", 1, False
) > "%LAUNCHER_VBS%"

rem --- Create VBS script temporarily to generate the shortcut
set "VBS_FILE=%TEMP%\joystick_diablo_new_shortcut.vbs"

(
echo Set WshShell = WScript.CreateObject^("WScript.Shell"^)
echo Set Shortcut = WshShell.CreateShortcut^("%SHORTCUT_PATH%"^)
echo Shortcut.TargetPath = "wscript.exe"
echo Shortcut.Arguments = Chr^(34^) ^& "%LAUNCHER_VBS%" ^& Chr^(34^)
echo Shortcut.IconLocation = "%JOY_EXE%,0"
echo Shortcut.WorkingDirectory = "%~dp0"
echo Shortcut.Save
) > "%VBS_FILE%"

rem --- Run the VBS to create the shortcut
cscript //nologo "%VBS_FILE%"

rem --- Delete temporary VBS
if exist "%VBS_FILE%" del "%VBS_FILE%"

echo Shortcut created on Desktop: %SHORTCUT_NAME%
pause
