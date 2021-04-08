@echo off
rem RETURNCODE 101 | restart
rem RETURNCODE 100 | stop
rem RETURNCODE -4  | ERROR

rem START UP
cd ..
:whenstart
luvit src/bot
set stopcode=%ERRORLEVEL%

rem WHEN CLOSED
if %stopcode% neq 101 timeout /t 18
if %stopcode% neq 100 goto whenstart