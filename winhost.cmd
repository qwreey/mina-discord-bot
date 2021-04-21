@echo off
rem [BOT CONTROL CODE]
rem RETURNCODE -1  | FATAL ERROR
rem RETURNCODE 100 | stop
rem RETURNCODE 101 | restart
rem RETURNCODE 102 | restart (safe mode)
rem RETURNCODE 103 | git pull and relaod (safe mode)
rem RETURNCODE 104 | git push and relaod (safe mode)
rem RETURNCODE 105 | git sync (safe mode)
rem RETURNCODE 106 | git pull and relaod
rem RETURNCODE 107 | git sync
rem [OTHER CODE]
rem RETURNCODE 200 | ssh host open
rem RETURNCODE 400 | error (?)

rem SETUP
cd ..
echo ROOT IS %cd%

rem CHECK IS VDESK
if %1 equ VDESK (
    echo MOVE SCREEN TO 1
    vdesk on:1 run:cmd /c
)

rem RUN CODE
:whenstart
echo CMD : luvit src/bot %*
luvit src/bot.lua %*
set stopcode=%ERRORLEVEL%
echo luvit RETURNCODE : %stopcode%

rem WHEN CLOSED
if %stopcode% equ 100 (
    goto end
)
if %stopcode% equ 102 (
    timeout /t 5
    goto whenstart
)
if %stopcode% equ 103 (
    git -C src pull
    goto whenstart
)
if %stopcode% equ 104 (
    git -C src add .
    git -C src commit -m "MINA : Upload in safe mode (bat mode)"
    git -C src push
    goto whenstart
)
if %stopcode% equ 105 (
    git -C src add .
    git -C src commit -m "MINA : Sync in safe mode (bat mode)"
    git -C src pull
    git -C src push
    goto whenstart
)
if %stopcode% equ 106 goto whenstart
if %stopcode% equ 107 goto whenstart
if %stopcode% neq 101 timeout /NOBREAK /t 18
if %stopcode% neq 100 goto whenstart
:end