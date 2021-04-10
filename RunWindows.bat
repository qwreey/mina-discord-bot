@echo off
rem RETURNCODE 101 | restart
rem RETURNCODE 100 | stop
rem RETURNCODE -1  | FATAL ERROR
rem RETURNCODE 102 | git pull and relaod (safe mode)
rem RETURNCODE 104 | git sync (safe mode)

rem START UP
cd ..
:whenstart
luvit src/bot
set stopcode=%ERRORLEVEL%

rem WHEN CLOSED
if %stopcode% equ 102 (
    git -C src pull
    goto whenstart
)
if %stopcode% equ 104 (
    git -C src add .
    git -C src commit -m "MINA : Upload in safe mode (bat mode)"
    git -C src pull
    git -C src push
    goto whenstart
)
if %stopcode% neq 101 timeout /t 18
if %stopcode% neq 100 goto whenstart