more +1 "%~dpf0" | cmd & GOTO :EOF
powershell
$github = $myInvocation.ScriptName
echo $github
