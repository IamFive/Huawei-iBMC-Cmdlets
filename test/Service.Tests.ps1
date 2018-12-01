Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Service" {
  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $OriginalServices = Get-iBMCService $session

      $OriginalServices -is [Array] | Should -Be $true
      $OriginalServices[0] -is [psobject] | Should -Be $true
      $OriginalServices[1] -is [psobject] | Should -Be $true

      $VncResult = Set-iBMCService $session 'VNC' $true 10001
      $VncResult -is [Array] | Should -Be $true
      $VncResult[0] | Should -Be $null
      $VncResult[1] -is [exception] | Should -Be $true

      $SetMediaResult = Set-iBMCService $session 'VirtualMedia' $false 10086
      $SetMediaResult -is [Array] | Should -Be $true
      $SetMediaResult | Should -Be @($null, $null)

      $UpdatedServices = Get-iBMCService $session

      $UpdatedServices[0].VNC.ProtocolEnabled | Should -Be $true
      $UpdatedServices[0].VNC.Port | Should -Be 10001

      $UpdatedServices.VirtualMedia.ProtocolEnabled | Should -Be @($false, $false)
      $UpdatedServices.VirtualMedia.Port | Should -Be @(10086, 10086)

      Set-iBMCService $session 'VNC' $OriginalServices.VNC.ProtocolEnabled $OriginalServices.VNC.Port
      Set-iBMCService $session 'VirtualMedia' $OriginalServices.VirtualMedia.ProtocolEnabled $OriginalServices.VirtualMedia.Port
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  # It "set" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
  #     Set-iBMCService $session 'VirtualMedia' $false 8209
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }
}