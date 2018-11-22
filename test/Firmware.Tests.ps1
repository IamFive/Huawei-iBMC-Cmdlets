Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Firmware" {
  It "Get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCFirmwareInfo $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "local file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCFirmware $session -Firmware ActiveBMC -UpgradeFilePath E:\huawei\PowerShell\2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

  It "unc file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCFirmware -Session $session -Firmware ActiveBMC -UpgradeFilePath \\WOOCUPIC\share\2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

  It "https file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCFirmware -Session $session -Firmware ActiveBMC -UpgradeFilePath https://open.turnbig.net/2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

  It "nfs file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCFirmware -Session $session -Firmware ActiveBMC -UpgradeFilePath nfs://115.159.160.190/data/nfs/2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

}