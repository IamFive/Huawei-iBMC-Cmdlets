Import-Module Huawei-iBMC-Cmdlets -Force

Describe "BIOS settings features" {
  It "Export" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Export-iBMCBIOSSetting $session 'nfs://115.159.160.190/data/nfs/9.xml'
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Import" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Import-iBMCBIOSSetting $session 'C:\Users\Woo\Desktop\config2.xml'
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Reset" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Reset-iBMCBIOS $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Restore" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian1 -Password "chajian12#$" -TrustCert
      Restore-iBMCFactory $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

