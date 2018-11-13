Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Reset" {
  It "Restart iBMC" {
    $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
    Reset-iBMC $session
  }

  It "Restart iBMC Server" {
    $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
    Reset-iBMCServer $session ForceRestart
  }
}