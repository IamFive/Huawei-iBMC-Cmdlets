Import-Module Huawei-iBMC-Cmdlets -Force

Describe "System Functions" {
  It "get basic" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $SystemInfos = Get-iBMCSystemInfo $session
      $SystemInfos -is [array] | Should -BeTrue
      $SystemInfos | Should -BeOfType 'psobject'
      $SystemInfos | Should -HaveCount 2

      $Properties = $SystemInfos[0] | Get-Member -MemberType Properties | Select Name
      $Properties.Count | Should -BeGreaterThan 20

      $Properties2 = $SystemInfos[1] | Get-Member -MemberType Properties | Select Name
      $Properties2.Count | Should -BeGreaterThan 20
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}