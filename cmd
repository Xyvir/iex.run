set "cmd=iex.run" || Edit the 'iex.run' portion of this line to match your vanity domain name.
set "myvar=?"
IF ["%cmdcmdline%"] NEQ ["cmd"] SET "myvar=%cmdcmdline%"
IF ["%myvar%"] NEQ ["?"] SET "myvar=%myvar:cmd  =%"
IF ["%myvar%"] NEQ ["?"] SET "myvar=%myvar: =?%" 
cls & powershell -c "curl.exe %cmd%/%myvar% | iex"
