Import-Module Huawei-iBMC-Cmdlets -Force

Describe "BIOS settings features" {
  It "Export&Import From NFS" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      Export-iBMCBIOSSetting $session 'nfs://115.159.160.190/data/nfs/9.xml','nfs://115.159.160.190/data/nfs/96.xml'
      Import-iBMCBIOSSetting $session 'nfs://115.159.160.190/data/nfs/9.xml','nfs://115.159.160.190/data/nfs/96.xml'
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Export&Import From BMC TEMP" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      Export-iBMCBIOSSetting $session '/tmp/bios.xml'
      Import-iBMCBIOSSetting $session '/tmp/bios.xml'
    }
    finally {
      Disconnect-iBMC $session
    }
  }


  It "Import from local file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      Import-iBMCBIOSSetting $session 'C:\Users\Woo\Desktop\9.xml'
    }
    finally {
      Disconnect-iBMC $session
    }
  }


  It "Reset" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      Reset-iBMCBIOS $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "Restore" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      Restore-iBMCFactory $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

