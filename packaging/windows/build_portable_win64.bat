@echo off
setlocal

call "%~dp0build_portable_windows.cmd" "C:\Qt\5.15.2\msvc2019_64" x64 win64
set "RESULT=%ERRORLEVEL%"

endlocal & exit /b %RESULT%
