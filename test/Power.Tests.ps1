Import-Module Huawei-iBMC-Cmdlets -Force

Describe "NTP Settings" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCPowerInfo $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}