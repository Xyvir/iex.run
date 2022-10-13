############## Powershell stuff goes below here #########################
# 
# NOTE: To avoid outtputting "CANNOT BIND COMMAND" errors, don't leave any newlines anywhere without a PS comments (#).
#
### Init:
$error.clear()
#
# Get OldProgress: 
$OldProgress = $ProgressPreference; $ProgressPreference = "SilentlyContinue"
#
# Get Existing Variables
$existingVariables = Get-Variable
#
# Set Default Download Folder Default location (Will be overwritten later if config exists)
$_DownloadFolder = '$Env:Public\$github\' # Default '$Env:Public\$github\'
#
#
# Get poweershell Invocation and manipulate out parts we care about.
# 
$invoc = $myinvocation | Select MyCommand | Format-Table -hidetableheaders | Out-String
$invoc = $invoc.split("`"")
$invoc = [string]::join("",($invoc.Split("`n")))
$invoc = $invoc.Replace(' | iex', '')
$curl = $invoc.SubString(0, $invoc.LastIndexOf(' '))
$invoc2 = $invoc.Replace($curl + " ","")
$invoc = $invoc.Split(" ")
$invocuri = [uri]("https://" + $invoc2)
#
# Get full github URLs
#
$github = $invocuri.host
$search = irm  https://api.github.com/search/repositories?q=%22$github%22%20in%3Aname%20fork%3Atrue
$githubURL = ($search.items | where {$_.name -like "$github"}).html_url
$command = ($invocuri.Absolutepath).Trim("/")
$arguments = ($invocuri.Query).Split("?")
#$fileURLs = (invoke-webrequest $githubURL).Links | Where-Object {$_.href -like "*blob*"} | Select -ExpandProperty href
#$Filematch = Foreach ($url in $fileURLs) { $url -split "/" | Select -Last 1 | Select-String -Pattern '(CNAME)|(404.html)' -NotMatch }
#
# Make API calls and format.
$rootapiurl ="https://api.github.com/repos" + ([uri]$githubURL).AbsolutePath + "/contents"
$apiurl = $rootapiurl + "/scripts"
$configapiurl = $rootapiurl +"/customizations"
$api = invoke-restmethod $apiurl
$configapi = invoke-restmethod $configapiurl
# $api = ConvertFrom-Json (invoke-webrequest $apiurl).content
$list = foreach ($item in $api) {$item | Select -Property name, size, sha}
$list | Add-Member -MemberType NoteProperty -Name '?' -Value ''
#
### Config Examples:
# 
# These configs can be toggled via 'meta-parameters' in the URL query string, by prefacing with an @ instead of $
#
# $_Admin = $false                 # Run script elevetated.
# $NoStub = $false                 # Do not download stub script; not implemented yet. 
# $NoWildcard = $false             # Do not match command on wildcard, not implemented yet.
# $NoExecute = $false              # Download Script only, not implemented yet.
# $HiddenWindow = $false           # hide powershell window, not implemented yet.
# $DebugVars = $false              # show all vars created
# $cat = $false                    # prints script text only, does not download or execute
# $help = $false                   # same as cat except filters to line comments starting with #, : or REM
# $Uninstall = $false              # Run uninstall script after, not implemented yet.
#
#
$ConfigUrl = ($configapi | Where-Object {$_.name -like "*config.html*"}).download_url
#
# Get Config from customizations folder and setup as variables:
$customconfig = ((curl $ConfigURL).content).split("`n")
#
$customconfig = $customconfig | Where {$_ -like "*=*" }  
#
foreach ($item in $customconfig) {$thing = $item.split("=");  $thing1 = ($thing[1]).trim(" "); if ($thing1 -match "^\d+$") {$thing1 = $thing1 -as [int]; Set-Variable -Name  ( "_" + ($thing[0]).trim(" ")) -Value $thing1} else {Set-Variable -Name  ( "_" + ($thing[0]).trim(" ")) -Value $thing1} }
#
foreach ($item in $arguments) {if ($item -like '`@*') {$trimitem = "_" + $item.trim('@'); if (test-Path variable:$trimitem) {Set-Variable -Name ($trimitem) -Value (!(Get-Variable -Name $trimitem).value) } else {Set-Variable -Name $trimitem -Value $true} } } 
#
# Expand DownloadFolder
$_DownloadFolder = $ExecutionContext.InvokeCommand.ExpandString($_DownloadFolder)
#
### Execute:
#
set-executionpolicy -force -scope process bypass
if (!(Test-Path $_DownloadFolder)) {New-Item -Path $_DownloadFolder -ItemType Directory}
$env:Path += ";$_DownloadFolder;"
if ($_DebugVars) {get-variable | where-object {(@("FormatEnumerationLimit", "MaximumAliasCount", "MaximumDriveCount", "MaximumErrorCount", "MaximumFunctionCount", "MaximumVariableCount", "PGHome", "PGSE", "PGUICulture", "PGVersionTable", "PROFILE", "PSSessionOption") -notcontains $_.name) -and (([psobject].Assembly.GetType('System.Management.Automation.SpecialVariables').GetFields('NonPublic,Static') | Where-Object FieldType -eq ([string]) | ForEach-Object GetValue $null)) -notcontains $_.name}}
echo "@ECHO OFF`nset PATH=%PATH%;$_DownloadFolder; `npowershell -c `"curl.exe \`"%~n0/%1\`" | iex`" || powershell -c `"& %1`" || dir /b $_DownloadFolder" | out-file $Env:localappdata\Microsoft\WindowsApps\$github.cmd -encoding ascii
write-host ""
if ($command) {$DownloadUrl = ($api | Where-Object {$_.name -like "*$command*"}).download_url}
if ($command) {$DownloadUrlName = ($api | Where-Object {$_.name -like "*$command*"}).name}
if ($command) {$sha = ($api | Where-Object {$_.name -like "*$command*"}).sha}
if ($DownloadUrl) {if ($DownloadUrl.gettype().Name -eq "String") {$exe = $DownloadUrl.substring($DownloadUrl.LastIndexOf('/') + 1, $DownloadUrl.length - $DownloadUrl.LastIndexOf('/') - 1 ) }}
if ($DownloadUrl) {if ($DownloadUrl.gettype().Name -eq "Object[]") {Write-host "Multiple matches found! Cancelling execution. Please use a more specfic search and try again. `n`n $DownloadUrlName `n" -ForegroundColor Red}}
if ($exe -like "*!*") {$_Admin = $true}
pushd $_DownloadFolder
if (!$DownloadUrl) {$files = @(Get-ChildItem *); $files | Add-Member -MemberType NoteProperty -Name 'sha' -value ''; foreach ($file in $files) {$file.sha = Get-Content -Path $file.name -Stream sha -ErrorAction SilentlyContinue}}
if ($exe) {Write-Host "Downloading '$exe' to '$_DownloadFolder'" -ForegroundColor Yellow; write-host ""}
if ($exe) {curl.exe -# -O $DownloadUrl; write-host ""; if (Test-Path -Path $exe -PathType Leaf) {Set-Content -Path $exe -Stream sha -value $sha} }
if ($exe) {Set-Content -Path $exe -Stream sha -value $sha}
if ($exe) {Write-Host "Launching '$exe' ..." -ForegroundColor Yellow; write-host ""}
if ($exe -and (!($_Admin)) ) {start-process -nonewwindow -wait powershell -ArgumentList "-command `"& $exe $arguments`" "}
if ($exe -and $_Admin) {start-process -verb RunAs -wait powershell -ArgumentList "-executionpolicy Bypass -command `"& $_DownloadFolder$exe $arguments`" "}
popd
if ($DownloadUrl) {Set-Clipboard $invocuri}
If (!$DownloadUrl) {$names = ($list.name + $files.name) | Select-Object -unique}
$index = @()
$orphans = @()
$shamatch = @()
if ($names) {foreach ($name in $names) {$index += [PSCustomObject]@{Name = $name; '?' = [char]18 } } }
If (!$DownloadUrl) {$shamatch += Compare-Object -ReferenceObject $list -DifferenceObject $files -Property name,sha -ExcludeDifferent -IncludeEqual}
If (!$DownloadUrl) {$orphans += Compare-Object -ReferenceObject $list -DifferenceObject $files -Property name}
If (!$DownloadUrl) {foreach ($thing in $shamatch){$thing.SideIndicator = $thing.SideIndicator -replace("==",[char]25) } }
If (!$DownloadUrl) {foreach ($thing in $orphans){$thing.SideIndicator = $thing.SideIndicator -replace("<="," ") -replace("=>",[char]19) } }
If (!$DownloadUrl) {$full = $shamatch + $orphans}
If (!$DownloadUrl) { foreach ($item in $full) {($index | Where-Object {$_.Name -like $item.name})."?" = $item.SideIndicator} }
IF ($command -AND !$DownloadUrl) {Write-Host "No scripts matching '$command' found in $github, please double check your spelling.`n" -ForegroundColor Red}
If (!$DownloadUrl) {Write-Host "Available Files and Status :" -ForegroundColor Yellow; $index | ft} # ft needed to output to console in right order.
if (!$DownloadUrl) {Write-Host "Launch one of the files above by typing $github <file name>. Partial matches are supported." -ForegroundColor Yellow; write-host ""}
if (!($error)) {Write-Host ("$exe $github Complete!").trim(" ") -ForegroundColor Green} else {Write-Host ("$github completed with errors. `n`n $error").trim(" ") -ForegroundColor Red}
if ($DownloadUrl) {write-host ""; write-host "The corresponding 'Magic URL': `"$invocuri`" has been copied to your clipboard."}
#
### Cleanup:
#
$ProgressPreference = $OldProgress
if (!($_KeepVars)) {Get-Variable | Where-Object Name -notin $existingVariables.Name | Remove-Variable}
#
### Optional: Uninstall:
#
if ($Uninstall) {Write-Host "Uninstalling now...`n" -ForegroundColor Red}
if ($Uninstall) {Remove-Item -Force -Recurse $_DownloadFolder}
if ($Uninstall) {Remove-Item -Force $Env:localappdata\Microsoft\WindowsApps\$github.cmd}
if ($Uninstall) {Write-Host "Uninstall Complete. $error" -ForegroundColor Red}
#