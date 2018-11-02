Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Service" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCService $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCService $session 'VirtualMedia' $false 8209
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}