Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Power" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $PowerInfos = Get-iBMCPowerInfo $session
      $PowerInfos -is [array] | Should -BeTrue
      $PowerInfos | Should -BeOfType 'psobject'

      $PowerInfos[0].PowerConsumedWatts  | Should -Match '\d+ Watts'
      $PowerInfos[0].MaxConsumedWatts  | Should -Match '\d+ Watts'
      $PowerInfos[0].MinConsumedWatts  | Should -Match '\d+ Watts'
      $PowerInfos[0].AverageConsumedWatts  | Should -Match '\d+ Watts'
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}