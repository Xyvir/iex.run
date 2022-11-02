$url = "https://www.palemoon.org/download.php?mirror=us&bits=64&type=portable"
$resp = Invoke-WebRequest -UseBasicParsing $url -MaximumRedirection 0 -ErrorAction Ignore
$Env:DLRemote = "https://" + ((($resp.RawContent -split  "//") | Select -last 1).split("`n`r") | select -first 1)
iex.run "?-y"
Palemoon-Portable.exe
