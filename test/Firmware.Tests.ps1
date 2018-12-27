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
      Update-iBMCInbandFirmware $session -FileUri E:\huawei\PowerShell\2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

  It "unc file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCInbandFirmware -Session $session -FileUri \\WOOCUPIC\share\2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

  It "https file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCInbandFirmware -Session $session -FileUri https://open.turnbig.net/2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

  It "nfs file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCInbandFirmware -Session $session -FileUri nfs://115.159.160.190/data/nfs/2288H_V5_5288_V5-iBMC-V318.hpm
    }
    finally {
        Disconnect-iBMC $session
    }
  }

}

Describe "InbandFirmware" {
  It "firmware local file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCInbandFirmware -Session $session -Type Firmware `
        -FileUri "E:\huawei\PowerShell\RAID-SR430C(3108)-FW-V108(4.650.00-6121).zip" `
        -SignalFileUri "E:\huawei\PowerShell\RAID-SR430C(3108)-FW-V108(4.650.00-6121).zip.asc"

      Update-iBMCInbandFirmware -Session $session -Type Firmware `
        -FileUri "E:\huawei\PowerShell\NIC(X722)-Electrical-05022FTM-FW(3.33).zip" `
        -SignalFileUri "E:\huawei\PowerShell\NIC(X722)-Electrical-05022FTM-FW(3.33).zip.asc"
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "firmware Remote file" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Update-iBMCInbandFirmware -Session $session -Type Firmware `
        -FileUri "nfs://115.159.160.190/data/nfs/NIC(X722)-Electrical-05022FTM-FW(3.33).zip" `
        -SignalFileUri "nfs://115.159.160.190/data/nfs/NIC(X722)-Electrical-05022FTM-FW(3.33).zip.asc"

      Update-iBMCInbandFirmware -Session $session -Type Firmware `
        -FileUri "nfs://115.159.160.190/data/nfs/NIC(SP330)-FW(5.05).zip" `
        -SignalFileUri "nfs://115.159.160.190/data/nfs/NIC(SP330)-FW(5.05).zip.asc"
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

Describe "SP Service" {
  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCSPService -Session $session -StartEnabled $true -SysRestartDelaySeconds 60
    }
    finally {
      Disconnect-iBMC $session
    }
  }

}