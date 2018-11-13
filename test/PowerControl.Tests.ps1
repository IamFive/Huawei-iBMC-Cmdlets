Import-Module Huawei-iBMC-Cmdlets -Force

Describe "PowerControl" {
  It "set os" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCSystemPower $session On
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}