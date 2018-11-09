Import-Module Huawei-iBMC-Cmdlets -Force

Describe "NTP Settings" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCAssetTag $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address "112.93.129.9,96" -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCAssetTag $session -AssetTag 'powershell-asset-tag'
    }
    finally {
        Disconnect-iBMC $session
    }
  }

}