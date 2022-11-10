## recurse.ps1; example of how you can call iex.run-hosted scripts from other scripts.
## in your scripting engine call 'curl.exe iex.run/recurse | iex' to also run alphabet.cmd and paramtest.cmd in order.
$Env:testvar = "Hello World"
iex.cmd alphabet
iex.cmd paramtest?1
iex.cmd passvar
