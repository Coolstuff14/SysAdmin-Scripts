@echo off
color 3f
title Loaner Refresh
cd %~dp0
type banner.txt
echo.

:menu
echo Current Logged in Users:
query user
echo.
set /p ans=Are All Other Users Logged Out? (y/n):
if "%ans%"=="y" goto cont
if "%ans%"=="Y" goto cont
if "%ans%"=="n" goto end
if "%ans%"=="N" goto end
goto menu

:cont
echo.
echo Deleting Loaner Account and Profile...

net user loaner /delete

DelProf2.exe /u /ed:Administrator /ed:helpdesk

echo Creating New Loaner Account...

net user loaner b0rr0wIT /ADD /PASSWORDCHG:NO /FULLNAME:"Loaner" /comment:"Added on %date% at %time%"

WMIC USERACCOUNT WHERE "Name='loaner'" SET PasswordExpires=FALSE

echo.
echo.
echo.
echo Done!
echo PRESS ANY KEY GOSH DARN IT!
pause>nul
goto realend

:end
echo COME BACK WHEN YOUR READY
pause

:realend