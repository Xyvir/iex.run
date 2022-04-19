@Echo OFF
setlocal enabledelayedexpansion

REM Determine if ran from interactive terminal or no, slightly changes displays and pauses
cd c:\WINDOWS\Temp
echo %cmdcmdline% | find /i "%~0" >nul
if not errorlevel 1 set interactive=0

REM Get Human readable Datetime and reverse hex temporary datetime.
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
REM convert time in to deciseconds, date into total day of year.
set /a sec=(((1%datetime:~8,2%-100)*36000)+((1%datetime:~10,2%-100)*600)+((1%datetime:~12,2%-100)*10)+(1%datetime:~15,1%-100)-999999)
set /a year=%datetime:~3,1%-10
set /a date2=(((1%datetime:~4,2%-100)*31)+(1%datetime:~4,2%-100)-1000)
set num="1 2 3 4 5 6 7 8 9"
set "date2=%date2:~-3%" & set "sec=%sec:~-6%" & set "year=%year:~-1%"
cmd /C exit %date2%%sec%
set datetime2=%year%%=ExitCode%
set datetime=%datetime:~4,2%-%datetime:~6,2%-%datetime:~2,2% at %datetime:~8,2%^:%datetime:~10,2%^:%datetime:~12,2%

REM Find PCs current IP or user-provided IP and parse it. Optionally displays scan history if "h" argument is supplied.
for /f "delims=: tokens=2" %%a in ('ipconfig /all ^| findstr Preferred ^| findstr %num% ^| find /v "169." ^| find /v "IPv6"') do IF NOT %%A=="" set NetworkIP=%%a
set NetworkIP=%NetworkIP:~1%
for /f "delims=. tokens=1-4" %%a in ('echo !NetworkIP!') do set myip=%%d
if defined myip set myip=%myip:(Preferred)=%
if defined myip set myip=000%myip%
if defined myip set myip=%myip:~-4%
set arg1=%1
if not defined arg1 set arg1=a
for /f %%a in ('echo %arg1% ^| findstr %num%') do set arg2=%%a
IF %arg1:~0,1%==h ECHO. & type ipscan_* 2>nul & GOTO :EOF
IF %arg1:~0,1%==p ECHO. & for /f %%g in ('dir /b ipscan_*') DO set prev=%%g & type !prev! 2>nul & GOTO :EOF
IF DEFINED arg2 set NetworkIP=%arg2%
for /f "delims=. tokens=1-4" %%a in ('echo !NetworkIP!') do set NetworkIP=%%a.%%b.%%c.

REM create temporary working folder. All temp file's name/path include datetime to make them unique to the current running instance.
mkdir %datetime2%
attrib +h %datetime2%


REM Create VBS script used to launch silent batch windows.
echo CreateObject("Wscript.Shell").Run "" ^& WScript.Arguments(0) ^& "", 0, False > %datetime2%.vbs
attrib +h %datetime2%.vbs
 
REM Programmatically create 'alpha' String containing all upper and lower letters for use in filtering domainnames with findstr below
FOR /F "tokens=1,2" %%a  IN ('ECHO 65 90 ^& ECHO 97 122') DO (
FOR /L %%i IN (%%a,1,%%b) DO (cmd /c exit %%i & set alpha=!alpha! !=exitcodeAscii!))

REM Create temp batch file that will do scanning of individual IPs.
(echo @echo off 
echo setlocal enabledelayedexpansion
echo set str=000%%1
echo set str=%%str:~-3%%
echo for /f "tokens=1-5" %%%%g in ^('ping -n 1 -a %NetworkIP%%%1 ^^^| findstr 32'^) do ^(
echo for /f "tokens=2" %%%%a  in ^('arp -a %NetworkIP%%%1 ^^^| findstr dynamic'^) DO set mac=%%%%a
echo IF %%%%g==Pinging for /f %%%%a in ^('echo %%%%h ^^^| findstr "%alpha%" '^) DO set hst=%%%%a
echo IF %%%%g==Reply echo %NetworkIP%%%str%%   ^^!mac^^!   ^^!hst^^! ^>^> %datetime2%/%%str%%^)
ECHO IF %%1==254 ECHO Scan Complete ^>^> %datetime2%/FINISHED
) > %datetime2%.bat
attrib +h %datetime2%.bat

REM Find current public IP using magic OpenDNS lookup server.
FOR /F "SKIP=4 TOKENS=2" %%a IN ('"NSLOOKUP myip.opendns.com resolver1.opendns.com 2>NUL"') DO set publicip=%%a
ECHO Public/External IP : %publicip% >> %datetime2%/000

REM Asynchronously launch multiple silent batch files that each store their results in individual numbered txt files in the temp folder.
IF NOT DEFINED interactive ECHO. 
ECHO Scanning %NetworkIP%X now.
if NOT DEFINED interactive ECHO View progress in titlebar. 
FOR /L %%i IN (1,1,254) DO (TITLE %NetworkIP%%%i & START "" "%datetime2%.vbs" "cmd /c %datetime2%.bat %%i")

REM Add Local computer's MAC manually
for /f %%g in ('getmac ^| findstr /v "disconnected not N/A = Name"') do set mac=%%g
for /f %%g in ('hostname') do set hostname=%%g
IF not defined arg2 (echo %NetworkIP%%myip%  %mac%   %hostname% > %datetime2%/%myip%) 


REM Check and wait for FINISHED which will only be created when the last batch file is finished running.
ECHO. & ECHO Waiting for all processes to finish up... & ECHO.
:1
IF EXIST %datetime2%/FINISHED GOTO 2
GOTO 1
:2

REM Clean up temp script files.
del /A:H %datetime2%.vbs & del /A:H %datetime2%.bat
set filename=ipscan_%datetime2%.txt

REM Combine all temp result files into one.
set info=Ip Scan of %NetworkIP%X on %datetime% [%filename%]
(ECHO %info% & ECHO.) > %filename%
for %%f in (%datetime2%\*) do type "%%f" >> %filename%
echo. >> %filename%

REM Clean up Temp Folder and results files.
attrib -h %datetime2%
del /q %datetime2%
rd %datetime2%

REM Print result file to screen.
TITLE %info%
TYPE %filename% 2>nul
IF NOT DEFINED interactive TYPE %filename% 2>nul
if DEFINED interactive START notepad.exe %filename%
TITLE Command Prompt
pause