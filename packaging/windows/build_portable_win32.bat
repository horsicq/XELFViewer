@echo off
setlocal

call "%~dp0build_portable_windows.cmd" "C:\Qt\5.15.2\msvc2019" Win32 win32
set "RESULT=%ERRORLEVEL%"

endlocal & exit /b %RESULT%
