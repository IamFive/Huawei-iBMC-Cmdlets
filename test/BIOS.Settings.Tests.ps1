Import-Module Huawei.iBMC.Cmdlets -Force

Describe "BIOS settings features" {
  It "set user " {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian1,chajian -Password "chajian12#$" -TrustCert
      Export-iBMCBIOSSetting $session 'nfs://115.159.160.190/data/nfs/9.xml','nfs://115.159.160.190/data/nfs/96.xml'
    } finally {
        Disconnect-iBMC $session
    }
  }
}

