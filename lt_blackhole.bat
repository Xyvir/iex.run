@ECHO OFF 
IF NOT EXIST "%PUBLIC%\Golf" mkdir "%PUBLIC%\Golf"
cd "%PUBLIC%\Golf"

REM Specify download URL and filehash.

REM This is the remainder of the URL up to the filename.
SET "URL=https://s3.amazonaws.com/assets-cp/assets/Agent_Uninstaller.zip"

REM This is the pre-computed file hash from powershell Get-FileHash of the dowlnoaded folder to verify whether or not the existing file is correct and 100% downloaded.
SET "FILEHASH=FE387F7A7D06F3A8649767EE53417AE188D5B9A1FB3DB6E94DF3849FA35E3CC5"

REM Set variables based on the URL for the filename and appfolder
call :filenamewext "FILENAME" "%URL%"
call :filenamenoext "APPFOLDER" "%URL%"

REM Download File and extract it if it doesn't exist or doesn't match the above hash, then run the 'STARTBIN' file.
SET "DLFILEHASH=0"
IF EXIST %FILENAME% for /f %%A in ('powershell -c Get-FileHash "%FILENAME%" ^^^| Select -ExpandProperty Hash') do set "dlfilehash=%%A"
IF NOT "%FILEHASH%"=="%DLFILEHASH%" curl -# -O "%URL%" & powershell -c "Expand-Archive -LiteralPath '%public%\Golf\%FILENAME%' -DestinationPath '%PUBLIC%\Golf\%APPFOLDER%\' -Force
cd %APPFOLDER%
FOR /F %%A IN ('dir *.exe /b') do START "%FILENAME%" "%%A"

REM BlackHole Automate URL to prevent any possible future sign-ups.
echo 1.1.1.1 forrestertech.hostedrmm.com >> c:\windows\system32\drivers\etc\hosts
GOTO :EOF


:filenamenoext
SET "%~1=%~n2"
EXIT /B

:filenamewext
SET "%~1=%~nx2"
EXIT /B
