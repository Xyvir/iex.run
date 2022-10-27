$url = "https://www.palemoon.org/download.php?mirror=us&bits=64&type=portable"
$resp = Invoke-WebRequest $url -MaximumRedirection 0 -ErrorAction Ignore
$Env:DLRemote = (($resp.RawContent -split  "//") | Select -last 1).split("`n") | select -first 1
$Env:DLRemote = $Env:DLRemote.trim("`r")
$Env:DLRemote = "https://$Env:DLRemote"
iex.run "?-y"
Palemoon-Portable.exe
