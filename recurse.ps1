# in scripting engine call 'curl.exe iex.run/recurse | iex' to run the following:
# Use out-null to wait between steps or w/o to run asynchronously 
iex.run alphabet | out-null
iex.run paramtest?1 | out-null
