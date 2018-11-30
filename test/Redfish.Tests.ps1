Import-Module Huawei-iBMC-Cmdlets -Force

$CommonFiles = @(Get-ChildItem -Path $PSScriptRoot\..\common -Recurse -Filter *.ps1)
# $ScriptFiles = @(Get-ChildItem -Path $PSScriptRoot\..\scripts -Recurse -Filter *.ps1)
$CommonFiles | ForEach-Object {
  try {
    . $_.FullName
  } catch {
      Write-Error -Message "Failed to import file $FileFullPath"
  }
}

Describe "Connect-iBMC" {
  It "Connect with account" {
    $connection = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
    Disconnect-iBMC $connection
  }

  # It "Connect with credential" {
  #   $session = Connect-iBMC -Address 112.93.129.9,112.93.129.117 -Username chajian,Administrator -Password "chajian12#$",Admin@7000 -TrustCert
  # }
}

Describe "New-iBMCRedfishSession" {
  It "new with account" {
    $session = New-iBMCRedfishSession -Address 112.93.129.9 -Username "chajian" -Password "chajian12#$"
    $Session.Alive | Should -Be $true
    Test-iBMCRedfishSession $session
    $Session.Alive | Should -Be $true

    $session = Close-iBMCRedfishSession $Session
    $Session.Alive | Should -Be $false
    $session = Test-iBMCRedfishSession $session
    $Session.Alive | Should -Be $false
  }
}

# Describe "Invoke-FirmwareUpload" {
#   It "new with account" {
#     $session = New-iBMCRedfishSession -Address 112.93.129.9 -Username "chajian" -Password "chajian12#$"
#     Invoke-FirmwareUpload $session "config.hpm" "C:\Users\Woo\Desktop\config2.xml"
#     Close-iBMCRedfishSession $Session
#   }
# }

Describe "matches test" {
  It "Test Matches" {
    $IPRange = @("10.1-2.1,3.1-2,3-4:80 10.3.1.3-4:81 10.4.1.5-6:82", "w-1-w.baidu123.com:80") ;
    $IPArray = ConvertFrom-IPRangeString $IPRange
    Write-Host $IPArray
  }
}

Describe "write process test" {
  It "sample" {
    for ($I = 1; $I -le 100; $I++ ) {Write-Progress -Activity "Search in Progress" -Status "$I% Complete:" -PercentComplete $I; Start-Sleep -m 100}
  }
}


Describe "Multiple Thread test" {
  It "run script block" {
    $ScriptBlock = {
      Write-Host 'run block'
    }

    $pool = New-RunspacePool 10

    $Tasks = @()
    1..10 | ForEach-Object {
      $task = Start-ScriptBlockThread $pool $ScriptBlock
      Write-Host $($task | fl)
      $Tasks += $task
    }

    do {
      $done = $true
      foreach ($Task in $Tasks) {
        if ($Task -ne $null) {
          if ($Task.AsyncResult.IsCompleted) {
            $Task.ps.EndInvoke($Task.AsyncResult)
            $Task.ps.Dispose()
          } else {
            $done = $false
          }
        }
      }
      if (-not $done) { Start-Sleep -Milliseconds 500 }
    } until ($done)
  }
}


