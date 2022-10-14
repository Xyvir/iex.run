### Init:
$error.clear()

# Get OldProgress: 
$OldProgress = $ProgressPreference; $ProgressPreference = "SilentlyContinue"

# Get Existing Variables
$existingVariables = Get-Variable

# Set Default Download Folder Default location (Will be overwritten later if config exists)
$_DownloadFolder = '$Env:Public\$github\' # Default '$Env:Public\$github\'

# Get full github URLs

# $github = $invocuri.host
$search = irm  https://api.github.com/search/repositories?q=%22$github%22%20in%3Aname%20fork%3Atrue
$githubURL = ($search.items | where {$_.name -like "$github"}).html_url
$command = ($invocuri.Absolutepath).Trim("/")
$arguments = ($invocuri.Query).Split("?")

# Make API calls and format.
$rootapiurl ="https://api.github.com/repos" + ([uri]$githubURL).AbsolutePath + "/contents"
$apiurl = $rootapiurl + "/scripts"
$configapiurl = $rootapiurl +"/customizations"
$api = invoke-restmethod $apiurl
$configapi = invoke-restmethod $configapiurl
$list = foreach ($item in $api) {$item | Select -Property name, size, sha}
$list | Add-Member -MemberType NoteProperty -Name '?' -Value ''

### Config Examples:
 
# These configs can be toggled via 'meta-parameters' in the URL query string, by prefacing with an @ instead of $

# $_Admin = $false                 Run script elevetated.
# $NoStub = $false                 Do not download stub script; not implemented yet. 
# $NoWildcard = $false             Do not match command on wildcard, not implemented yet.
# $NoExecute = $false              Download Script only, not implemented yet.
# $HiddenWindow = $false           hide powershell window, not implemented yet.
# $DebugVars = $false              show all vars created
# $cat = $false                    prints script text only, does not download or execute
# $help = $false                   same as cat except filters to line comments starting with #, : or REM
# $Uninstall = $false              Run uninstall script after, not implemented yet.


$ConfigUrl = ($configapi | Where-Object {$_.name -like "*config.html*"}).download_url

# Get Config from customizations folder and setup as variables:
$customconfig = ((curl $ConfigURL).content).split("`n")

$customconfig = $customconfig | Where {$_ -like "*=*" }  

#Process $Customconfig variables from config.html
foreach ($item in $customconfig) {
 $thing = $item.split("=")  
 $thing1 = ($thing[1]).trim(" ")
 if ($thing1 -match "^\d+$") {
   $thing1 = $thing1 -as [int] 
   Set-Variable -Name  ( "_" + ($thing[0]).trim(" ")) -Value $thing1
  } 
 else {
   Set-Variable -Name  ( "_" + ($thing[0]).trim(" ")) -Value $thing1
  } 
 }

#Process any Meta-paramenters
foreach ($item in $arguments) {
  if ($item -like '`@*') {
    $trimitem = "_" + $item.trim('@') 
      if (test-Path variable:$trimitem) {
        Set-Variable -Name ($trimitem) -Value (!(Get-Variable -Name $trimitem).value) 
        } 
      else {
        Set-Variable -Name $trimitem -Value $true
       } 
      } 
     } 

# Expand DownloadFolder
$_DownloadFolder = $ExecutionContext.InvokeCommand.ExpandString($_DownloadFolder)

### Execute:

set-executionpolicy -force -scope process bypass
if (!(Test-Path $_DownloadFolder)) {New-Item -Path $_DownloadFolder -ItemType Directory}
$env:Path += ";$_DownloadFolder;"
echo "@ECHO OFF`nset PATH=%PATH%;$_DownloadFolder; `npowershell -c `"curl.exe \`"%~n0/%1\`" | iex`" || powershell -c `"& %1`" || dir /b $_DownloadFolder" | out-file $Env:localappdata\Microsoft\WindowsApps\$github.cmd -encoding ascii

write-host ""

if ($command) {
 $DownloadUrl = ($api | Where-Object {$_.name -like "*$command*"}).download_url
 $DownloadUrlName = ($api | Where-Object {$_.name -like "*$command*"}).name
 $sha = ($api | Where-Object {$_.name -like "*$command*"}).sha
 }

if ($DownloadUrl) {
  if ($DownloadUrl.gettype().Name -eq "String") {
    $exe = $DownloadUrl.substring($DownloadUrl.LastIndexOf('/') + 1, $DownloadUrl.length - $DownloadUrl.LastIndexOf('/') - 1 ) 
  }
  else {
   Write-host "Multiple matches found! Cancelling execution. Please use a more specfic search and try again. `n`n $DownloadUrlName `n" -ForegroundColor Red
  }
}

if ($exe -like "*!*") {$_Admin = $true}

pushd $_DownloadFolder
$files = @(Get-ChildItem *); $files | Add-Member -MemberType NoteProperty -Name 'sha' -value ''; foreach ($file in $files) {$file.sha = Get-Content -Path $file.name -Stream sha -ErrorAction SilentlyContinue}

if ($exe) {
 Write-Host "Downloading '$exe' to '$_DownloadFolder'" -ForegroundColor Yellow; write-host ""
 curl.exe -# -O $DownloadUrl
 write-host "" 
 if (Test-Path -Path $exe -PathType Leaf) {Set-Content -Path $exe -Stream sha -value $sha} 
 Set-Content -Path $exe -Stream sha -value $sha
 Write-Host "Launching '$exe' ..." -ForegroundColor Yellow 
 write-host ""
 if (!($_Admin)) {start-process -nonewwindow -wait powershell -ArgumentList "-command `"& $exe $arguments`" "}
 if ($_Admin) {start-process -verb RunAs -wait powershell -ArgumentList "-executionpolicy Bypass -command `"& $_DownloadFolder$exe $arguments`" "}
 Set-Clipboard $invocuri
}

# If no command build and display index

If (!($DownloadUrl)) {
 $shamatch = $orphans = $index = @()
 $names = ($list.name + $files.name) | Select-Object -unique
 if ($names) {foreach ($name in $names) {$index += [PSCustomObject]@{Name = $name; '?' = [char]18 } } }
 $shamatch += Compare-Object -ReferenceObject $list -DifferenceObject $files -Property name,sha -ExcludeDifferent -IncludeEqual
 $orphans += Compare-Object -ReferenceObject $list -DifferenceObject $files -Property name
 foreach ($thing in $shamatch) {$thing.SideIndicator = $thing.SideIndicator -replace("==",[char]25) } 
 foreach ($thing in $orphans) {$thing.SideIndicator = $thing.SideIndicator -replace("<="," ") -replace("=>",[char]19) } 
 $full = $shamatch + $orphans
 foreach ($item in $full) {($index | Where-Object {$_.Name -like $item.name})."?" = $item.SideIndicator} 
 IF ($command) {Write-Host "No scripts matching '$command' found in $github, please double check your spelling.`n" -ForegroundColor Red}
 Write-Host "Available Files and Status :" -ForegroundColor Yellow 
 $index | ft # ft needed to output to console in right order.
 Write-Host "Launch one of the files above by typing $github <file name>. Partial matches are supported." -ForegroundColor Yellow
 write-host ""
 }

popd

if (!($error)) {Write-Host ("$exe $github Complete!").trim(" ") -ForegroundColor Green} else {Write-Host ("$github completed with errors. `n`n $error").trim(" ") -ForegroundColor Red}

if ($DownloadUrl) {write-host ""; write-host "The corresponding 'Magic URL': `"$invocuri`" has been copied to your clipboard."}


if ($_DebugVars) {write-host ""; get-variable | where-object {(@("FormatEnumerationLimit", "MaximumAliasCount", "MaximumDriveCount", "MaximumErrorCount", "MaximumFunctionCount", "MaximumVariableCount", "PGHome", "PGSE", "PGUICulture", "PGVersionTable", "PROFILE", "PSSessionOption") -notcontains $_.name) -and (([psobject].Assembly.GetType('System.Management.Automation.SpecialVariables').GetFields('NonPublic,Static') | Where-Object FieldType -eq ([string]) | ForEach-Object GetValue $null)) -notcontains $_.name}}

### Optional: Uninstall:

if ($_Uninstall) {
  Write-Host "Uninstalling now...`n" -ForegroundColor Red
  Remove-Item -Force -Recurse $_DownloadFolder
  Remove-Item -Force $Env:localappdata\Microsoft\WindowsApps\$github.cmd
  Write-Host "Uninstall Complete. $error" -ForegroundColor Red
  }

### Cleanup:

$ProgressPreference = $OldProgress
if (!($_KeepVars)) {Get-Variable | Where-Object Name -notin $existingVariables.Name | Remove-Variable}
