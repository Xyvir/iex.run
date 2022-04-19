REM Get Office Bitness
FOR /f "TOKENS=3" %%A in ('REG QUERY HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration /v Platform') do SET "BITNESS=%%A"

REM Run repair
echo Start-Process -FilePath "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeClickToRun.exe" -wait -verb RunAs -ArgumentList "scenario=Repair platform=%BITNESS% culture=en-us forceappshutdown=True RepairType=FullRepair DisplayLevel=True" | powershell -c "-"