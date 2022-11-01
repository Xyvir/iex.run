 if( !(Start-Process -FilePath "iex.run" -NoNewWindow -Wait -ErrorAction Stop -ArgumentList "https%3A%2F%2Fninite.com%2Fopera%2Fninite.exe?@DLRemote") ){
      $Env:DLRemote = "https://ninite.com/opera/ninite.exe"; iex.run}
