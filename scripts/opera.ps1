try {iex.run https%3A%2F%2Fninite.com%2Fopera%2Fninite.exe?@DLRemote }
catch {$Env:DLRemote = "https://ninite.com/opera/ninite.exe"; iex.run}
finally {}
