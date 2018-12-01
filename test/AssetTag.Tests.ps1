Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Asset Tag" {
  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $OriginalAssetTags = Get-iBMCAssetTag $session

      $NewTag1 = "powershell-asset-tag-$(Get-Random -Maximum 1000000)"
      $NewTag2 = "powershell-asset-tag-$(Get-Random -Maximum 1000000)"
      $Results = Set-iBMCAssetTag $session -AssetTag @($NewTag1, $NewTag2)
      $Results | Should -be @($null, $null)

      $UpdatedAssetTags = Get-iBMCAssetTag $session
      $UpdatedAssetTags | Should -be @($NewTag1, $NewTag2)

      Set-iBMCAssetTag $session $OriginalAssetTags
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  # It "set" {
  #   try {
  #     $session = Connect-iBMC -Address "112.93.129.9,96" -Username chajian -Password "chajian12#$" -TrustCert
  #     Set-iBMCAssetTag $session -AssetTag 'powershell-asset-tag'
  #   }
  #   finally {
  #       Disconnect-iBMC $session
  #   }
  # }

}