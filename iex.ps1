### Init:
$error.clear()

# required For Url-encoded Decode
Add-Type -AssemblyName System.Web

# Get OldProgress: 
$OldProgress = $ProgressPreference; $ProgressPreference = "SilentlyContinue"

# Set Default Download Folder Default location (Will be overwritten later if config exists)
$_DownloadFolder = '$Env:Public\$github\' # Default '$Env:Public\$github\'

# Get this repo's full github URLs using api search based on github pages url
$search = irm  https://api.github.com/search/repositories?q=%22$github%22%20in%3Aname%20fork%3Atrue
$githubURL = ($search.items | where {$_.name -like "$github"} | Select -First 1).html_url
$command = ($invocuri.Absolutepath).Trim("/")
$arguments = $invocuri.Query
$arguments = [System.Web.HttpUtility]::UrlDecode($arguments)
$command = [System.Web.HttpUtility]::UrlDecode($command)
$arguments = $arguments.Split("?")

# Make github API calls and format.
$rootapiurl ="https://api.github.com/repos" + ([uri]$githubURL).AbsolutePath + "/contents"
$apiurl = $rootapiurl + "/scripts"
$configapiurl = $rootapiurl + "/customizations"
$api = invoke-restmethod $apiurl
$configapi = invoke-restmethod $configapiurl
$list = foreach ($item in $api) {$item | Select -Property name, size, sha}
$list | Add-Member -MemberType NoteProperty -Name '?' -Value ''

### Config Examples for reference only!:
 
# These configs can be toggled via 'meta-parameters' in the URL query string, by prefacing with an @ and no underscore. Defaults are always false.

# $_NoStub                 #Do not download stub script
# $_NoWildcard             #Do not match command on wildcard, n
# $_NoExecute              #Download Script only.
# $_NewWindow              #Runs in a new window. (not implemented yet)
# $_Admin                  #Run script elevetated; implies NewWindow
# $_Hidden                 #hide powershell window; also implies NewWindow
# $_cat                    #prints script text only, does not download or execute
# $_type                   #same as cat
# $_help                   #same as cat except filters to line comments starting with ##, or ::, so you can add custom iex.run help reminders in the comments of your scripts.
# $_NoClipboard            #Do not copy MagicURL to clipboard
# $_DebugVars              #show all vars created
# $_KeepVars               #do not delete any iex variables after script runs.
# $_Uninstall              #Run uninstall script after everything else


$ConfigUrl = ($configapi | Where-Object {$_.name -like "*config.html*"}).download_url

# Get Config from customizations folder and setup as variables:
$customconfig = ((curl -UseBasicParsing $ConfigURL).content).split("`n")
# -useBasicParsing is deprecated but can allow for additional compatability on versions of powershell.

#match on only lines with = signs
$customconfig = $customconfig | Where {$_ -like "*=*" }  

#Process $Customconfig variables from config.html
foreach ($item in $customconfig) {
 $thing = $item.split("=") 
 $thing1 = $thing[1]
  # Below allows for in-line comments in config file
 if ($thing1 -like "*#*") {$thing1 = $thing1.substring(0, $thing1.IndexOf("#"))}
 $thing1 = $thing1.trim(" ")
 if ($thing1 -match "^\d+$") {
   $thing1 = $thing1 -as [int] 
   Set-Variable -Name  ( "_" + ($thing[0]).trim(" ")) -Value $thing1
  } 
 else {
   Set-Variable -Name  ( "_" + ($thing[0]).trim(" ")) -Value $thing1
  } 
 }

#Process any Meta-paramenters (Prepend Underscore, Remove @, toggle if the variable exists or else create a new variable.)
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


# Expand DownloadFolder variable
$_DownloadFolder = $ExecutionContext.InvokeCommand.ExpandString($_DownloadFolder)


# change execution policy to allow running ps1
set-executionpolicy -force -scope process bypass

# create download folder it doesn't exist.
if (!(Test-Path $_DownloadFolder)) {New-Item -Path $_DownloadFolder -ItemType Directory > $null} # redirect to $null is needed as New-Item -Directory outputs dir aftewards for some reason.
$env:Path += ";$_DownloadFolder;"

# Write Stub Script to file:

if (!($_NoStub)) {
$stub = @"
@ECHO OFF
set "PATH=%PATH%;$_DownloadFolder;"
if [%~1] NEQ [] SET "PARAM=%*"  
IF DEFINED PARAM SET "PARAM=%PARAM: =?%" 
powershell -c "curl.exe -L $github/%PARAM% | iex" || powershell -c "& %PARAM%" > NUL || (ECHO You seem to be offline, see previously downloaded %~n0 files below: & ECHO. & dir /b "$_DownloadFolder")
"@ 
$stub | out-file $Env:localappdata\Microsoft\WindowsApps\$github.cmd -encoding ascii
}

write-host ""

### parse required info from github API results and check for multiple matches

if ($command) {
 if (!($_NoWildcard)) {
  $DownloadUrl = ($api | Where-Object {$_.name -like "*$command*"}).download_url
  $DownloadUrlName = ($api | Where-Object {$_.name -like "*$command*"}).name
  $sha = ($api | Where-Object {$_.name -like "*$command*"}).sha
 } else {
  $DownloadUrl = ($api | Where-Object {$_.name -like "$command.*"}).download_url
  $DownloadUrlName = ($api | Where-Object {$_.name -like "$command.*"}).name
  $sha = ($api | Where-Object {$_.name -like "$command.*"}).sha
  }
}

if ($DownloadUrl) {
  if ($DownloadUrl.gettype().Name -eq "String") {
    $exe = $DownloadUrl.substring($DownloadUrl.LastIndexOf('/') + 1, $DownloadUrl.length - $DownloadUrl.LastIndexOf('/') - 1 ) 
  }
  else {
   Write-host "Multiple matches found! Cancelling execution. Please use a more specfic search and try again: `n" -ForegroundColor Red
   $DownloadURlname | Write-Output | Write-host -ForegroundColor Red
   Write-host ""
  }
}

if ($exe -like "*!*") {$_Admin = $true}

pushd $_DownloadFolder

# Take inventory of previously downloaded files and their original github SHA written to their alternate data stream
$files = @(Get-ChildItem *) 
$files | Add-Member -MemberType NoteProperty -Name 'sha' -value '' 
foreach ($file in $files) {$file.sha = Get-Content -Path $file.name -Stream sha -ErrorAction SilentlyContinue}

### Main operation if a command was provided

if ($exe) {
  # Display contents or Download the file
  if ($_cat -or $_type) {
   write-host "$exe `n"  -foregroundcolor white
   curl.exe -s $DownloadUrl | write-host -foregroundcolor white
   write-host ""
  } elseif ($_help) {
   write-host "Help for $exe `n"  -foregroundcolor white
   curl.exe -s $DownloadUrl | select-string -pattern "^##" | write-host -foregroundcolor white 
   curl.exe -s $DownloadUrl | select-string -pattern "^::" | write-host -foregroundcolor white 
   write-host ""
  } else {
   if ($sha -in $files.sha) {
     Write-Host "Downloaded '$exe' up-to-date, skipping download." -ForegroundColor Yellow; write-host "" 
   } else {
     Write-Host "Downloading '$exe' to '$_DownloadFolder'" -ForegroundColor Yellow; write-host ""
     curl.exe -# -O $DownloadUrl
     write-host "" 
     if (Test-Path -Path $exe -PathType Leaf) {
      Set-Content -Path $exe -Stream sha -value $sha
      if ($exe -like "*!*") { mv $exe ($exe.replace("!","")) }
      } 
     }
     
  # Expand Zip if Zip and find new $exe
  if ($exe -like "*.zip") {
   expand-archive $exe
   pushd (Get-Item $exe).BaseName
   $tempexe = ((dir)  -match "$exe.*\.(exe|ps1|cmd|bat)" | select -first 1).name
   if (!($tempexe)){ $tempexe = ((dir)  -match "\.(exe|ps1|cmd|bat)" | select -first 1).name}
   $exe = $tempexe
   }
   
  # Execute the file 
  if (!($_NoExecute)) {
    $exe = $exe.replace("!","")
    Write-Host "Launching '$exe' ..." -ForegroundColor Yellow 
    write-host ""
    if ($_Admin -and $_Hidden) {
     start-process -verb RunAs -wait powershell -ArgumentList "-WindowStyle Hidden -executionpolicy Bypass -command `"& $_DownloadFolder$exe $arguments`" "
    } elseif ($_Admin) {
     start-process -verb RunAs -wait powershell -ArgumentList "-executionpolicy Bypass -command `"& $_DownloadFolder$exe $arguments`" "
    } elseif ($_Hidden) {
    start-process -wait powershell -ArgumentList "-WindowStyle Hidden -executionpolicy Bypass -command `"& $_DownloadFolder$exe $arguments`" "
    } elseif ($_NewWindow) {
    start-process -wait powershell -ArgumentList "-command `"& $exe $arguments`" "
    } else {
    start-process -nonewwindow -wait powershell -ArgumentList "-command `"& $exe $arguments`" "
    }
  } else {
  Write-Host "Skipping execution.`n" -ForegroundColor Yellow;
  }
 }
}

### If no command build and display index

If (!($DownloadUrl)) {
 $shamatch = $orphans = $index = @()
 foreach ($name in $list) {$name.name = $name.name.replace("!","")}
 $names = ($list.name + $files.name) | Select-Object -unique
 if ($names) {foreach ($name in $names) {$index += [PSCustomObject]@{Name = $name; '?' = [char]18 } } }
 $shamatch += Compare-Object -ReferenceObject $list -DifferenceObject $files -Property name,sha -ExcludeDifferent -IncludeEqual
 $orphans += Compare-Object -ReferenceObject $list -DifferenceObject $files -Property name
 foreach ($thing in $shamatch) {$thing.SideIndicator = $thing.SideIndicator -replace("==",[char]25) } 
 foreach ($thing in $orphans) {$thing.SideIndicator = $thing.SideIndicator -replace("<="," ") -replace("=>",[char]19) } 
 $full = $shamatch + $orphans
 foreach ($item in $full) {($index | Where-Object {$_.Name -like $item.name})."?" = $item.SideIndicator} 
 IF ($command) {
  Write-Host "No scripts matching '$command' found in $github, trying a built-in command`n" -ForegroundColor Yellow
  try {
    if ($_Admin -and $_Hidden) {
     start-process -verb RunAs -wait powershell -ArgumentList "-WindowStyle Hidden -executionpolicy Bypass -command `"$command $arguments`" "
    } elseif ($_Admin) {
     start-process -verb RunAs -wait powershell -ArgumentList "-executionpolicy Bypass -command `"$command $arguments`" "
    } elseif ($_Hidden) {
    start-process -wait powershell -ArgumentList "-WindowStyle Hidden -executionpolicy Bypass -command `"$command $arguments`" "
    } elseif ($_NewWindow) {
    start-process -wait powershell -ArgumentList "-command `"$command $arguments`" "
    } else {
    start-process -nonewwindow -wait powershell -ArgumentList "-command `"$command $arguments`" "
    }
   }
  catch { Write-Host "No built-in matches found, please double-check your spelling" -ForegroundColor Red }
  finally {$internal = $true; write-host ""}
  }
 if (!($internal)) { 
   Write-Host "Available Files and Status :" -ForegroundColor Yellow 
   $index | ft # ft needed to output to console in right order.
   Write-Host "Launch one of the files above by typing $github <file name>. Partial matches are supported." -ForegroundColor Yellow
   write-host ""
  }
 }

popd
if ($exe -like "*.zip") {popd}

### Display Results:

if (!($error)) {Write-Host ("$exe $github Complete!").trim(" ") -ForegroundColor Green; Write-Host ""} else {Write-Host ("$github completed with errors. `n`n $error").trim(" ") -ForegroundColor Red}

if (!($_NoClipboard))  {
if ($exe -or $internal){
 Set-Clipboard ("https://" + $invoc)
 write-host "The following 'Magic URL' has been copied to your keyboard: https://$invoc `n" 
 }}

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
