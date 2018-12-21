Import-Module Huawei-iBMC-Cmdlets -Force

Describe "NTP Settings" {

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.98,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $SettingResult =  Set-iBMCNTPSetting $session -ServiceEnabled $true -PreferredNtpServer 'pre.huawei.com' `
        -AlternateNtpServer 'alt.huawei.com' -NtpAddressOrigin Static -ServerAuthenticationEnabled $false `
        -MinPollingInterval 10 -MaxPollingInterval 12

      $SettingResult -is [array] | Should -BeTrue
      $SettingResult | Should -Be @($null, $null)
      $SettingResult | Should -HaveCount 2

      $Settings = Get-iBMCNTPSetting $session
      $Settings -is [array] | Should -BeTrue
      $Settings | Should -HaveCount 2
      $Settings | Should -BeOfType 'PSObject'

      $Settings.ServiceEnabled | Should -Be @($true, $true)
      $Settings.PreferredNtpServer | Should -Be @('pre.huawei.com', 'pre.huawei.com')
      $Settings.AlternateNtpServer | Should -Be @('alt.huawei.com', 'alt.huawei.com')
      $Settings.NtpAddressOrigin | Should -Be @('Static', 'Static')
      $Settings.ServerAuthenticationEnabled | Should -Be @($false, $false)
      $Settings.MinPollingInterval | Should -Be @(10, 10)
      $Settings.MaxPollingInterval | Should -Be @(12, 12)
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}

Describe "NTP Group Key" {

  It "local" {
    try {
      $session = Connect-iBMC -Address "112.93.129.9" -Username chajian -Password "chajian12#$" -TrustCert
      Import-iBMCNTPGroupKey -Session $session -KeyFileUri "E:\huawei\PowerShell\ntp.keys"
    }
    finally {
        Disconnect-iBMC $session
    }
  }

  It "nfs" {
    try {
      $session = Connect-iBMC -Address "112.93.129.9" -Username chajian -Password "chajian12#$" -TrustCert
      Import-iBMCNTPGroupKey -Session $session -KeyFileUri "nfs://115.159.160.190/data/nfs/ntp.keys"
    }
    finally {
        Disconnect-iBMC $session
    }
  }
}