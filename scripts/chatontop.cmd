more +1 "%~dpf0" | cmd & GOTO :EOF
powershell
$ErrorActionPreference= 'silentlycontinue'
$SCwindows = Get-Process -Name 'ScreenConnect.WindowsClient'
[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
foreach ($Process in $SCwindows) {[Microsoft.VisualBasic.Interaction]::AppActivate($Process.MainWindowTitle)}