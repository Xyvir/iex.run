set "github=%~dpf0"
more +2 "%~dpf0" | cmd & GOTO :EOF
powershell 
$Env:github
