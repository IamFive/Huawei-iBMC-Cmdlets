function Test-Output {
  $output = "Hello World"
  Write-Output $output
}

function Test-Output2 {
  Write-Host "Hello World" -foreground Green
}

function Receive-Output {
  process { Write-Host $_ -foreground Yellow }
}

$output = "sample"

#Output piped to another function, not displayed in first.
Test-Output | Receive-Output

#Output not piped to 2nd function, only displayed in first.
Test-Output2 | Receive-Output

#Pipeline sends to Out-Default at the end.
Test-Output

Write-Host $output