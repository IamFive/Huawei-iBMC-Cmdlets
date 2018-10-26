Import-Module Huawei.iBMC.Cmdlets -Force

Describe "BIOS settings features" {
  It "set user " {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Export-iBMCBIOSSetting $session 'nfs://115.159.160.190/data/nfs/bios.xml'
    } finally {
      Disconnect-iBMC $session
    }
  }
}

