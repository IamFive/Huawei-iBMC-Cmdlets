Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Virtual Media features" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Get-iBMCVirtualMedia $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}

