Import-Module Huawei.iBMC.Cmdlets -Force


Describe "Connect-iBMC" {
  It "Connect with account" {
    Connect-iBMC -Address 112.93.129.9,112.93.129.117 -Username chajian1,Administrator -Password "chajian12#$",Admin@7000 -TrustCert
  }

  # It "Connect with credential" {
  #   $session = Connect-iBMC -Address 112.93.129.9,112.93.129.117 -Username chajian1,Administrator -Password "chajian12#$",Admin@7000 -TrustCert
  # }
}

Describe "New-iBMCRedfishSession" {
  It "new with account" {
    $session = New-iBMCRedfishSession -Address "112.93.129.9" -Username "chajian1" -Password "chajian12#$" -TrustCert
    Write-Host "Session:"
    Write-Host $($session | fl)

    Write-Host "Close Session:"
    Close-iBMCRedfishSession $session
    Write-Host $($session | fl)

    Write-Host "Test Session:"
    Test-iBMCRedfishSession $session
    Write-Host $($session | fl)
  }

  It "new with credential" {
    $Username = "chajian1"
    $Password = ConvertTo-SecureString -String "chajian12#$" -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $Username, $Password
    $session = New-iBMCRedfishSession 112.93.129.9 $Credential -TrustCert
    Write-Host "Session:"
    Write-Host $session

    Write-Host "Close Session:"
    Close-iBMCRedfishSession $session
    Write-Host $session

    Write-Host "Test Session:"
    Test-iBMCRedfishSession $session
    Write-Host $session
  }
}

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


