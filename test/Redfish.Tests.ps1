Import-Module Huawei.iBMC.Cmdlets -Force

Describe "Connect-iBMC" {
    It "Connect with account" {
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
}

Describe "matches test" {
  It "Test Matches" {
    $IPRange = "10.1-2.1,3.1-2,3-4:80 10.3.1.3-4:81 10.4.1.5-6:82 w-1-w.baidu123.com:80" ;
    $IPArray = ConvertFrom-IPRangeString $IPRange
    Write-Host $IPArray
  }
}

