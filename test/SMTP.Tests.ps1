Import-Module Huawei-iBMC-Cmdlets -Force

Describe "SNMP-Settings" {
  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 `
       -Username chajian -Password "chajian12#$" -TrustCert
      # $OriginalSettings = Get-iBMCSMTPSetting $session
      # $OriginalSettings -is [Array] | Should -Be $true
      # $OriginalSettings[0] -is [psobject] | Should -Be $true
      # $OriginalSettings[1] -is [psobject] | Should -Be $true

      $pwd = ConvertTo-SecureString -String "pwd12#$%^" -AsPlainText -Force
      $ServerIdentity = ,@('HostName', 'BoardSN')
      Set-iBMCSMTPSetting $session -ServiceEnabled $true -ServerAddress smtp.huawei.com `
          -TLSEnabled $true -AnonymousLoginEnabled $false `
          -SenderUserName 'Huawei-iBMC' -SenderAddress "powershell@huawei.com"  -SenderPassword $pwd `
          -EmailSubject 'Alarm' -EmailSubjectContains $ServerIdentity `
          -AlarmSeverity Major

      $UpdatedSettings = Get-iBMCSMTPSetting $session
      $UpdatedSettings -is [Array] | Should -Be $true
      $UpdatedSettings.ServiceEnabled | Should -Be @($true, $true)
      $UpdatedSettings.ServerAddress | Should -Be @('smtp.huawei.com', 'smtp.huawei.com')
      $UpdatedSettings.TLSEnabled | Should -Be @($true, $true)
      $UpdatedSettings.AnonymousLoginEnabled | Should -Be @($false, $false)
      $UpdatedSettings.SenderUserName | Should -Be @('Huawei-iBMC', 'Huawei-iBMC')
      $UpdatedSettings.SenderAddress | Should -Be @('powershell@huawei.com', 'powershell@huawei.com')
      $UpdatedSettings.EmailSubject | Should -Be @('Alarm', 'Alarm')
      $UpdatedSettings.EmailSubjectContains | Should -Be @('HostName', 'BoardSN', 'HostName', 'BoardSN')
      $UpdatedSettings.AlarmSeverity | Should -Be @('Major', 'Major')

    }
    finally {
      Disconnect-iBMC $session
    }
  }

  # It "set" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     $pwd = ConvertTo-SecureString -String "pwd12#$%^" -AsPlainText -Force
  #     $ServerIdentity = ,@('HostName', 'BoardSN')
  #     Set-iBMCSMTPSetting $session -ServiceEnabled $false -ServerAddress smtp.huawei.com `
  #         -TLSEnabled $false -AnonymousLoginEnabled $false `
  #         -SenderUserName 'Huawei-iBMC' -SenderAddress "powershell@huawei.com"  -SenderPassword $pwd `
  #         -EmailSubject 'iBMC Alarm Notification' -EmailSubjectContains $ServerIdentity `
  #         -AlarmSeverity Critical
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }
}


Describe "SNMP-Recipients" {
  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $OriginalRecipients = Get-iBMCSMTPRecipients $session
      $OriginalRecipients -is [Array] | Should -Be $true
      $OriginalRecipients[0] -is [Array] | Should -Be $true
      $OriginalRecipients[0].Count | Should -Be 4
      $OriginalRecipients[1] -is [Array] | Should -Be $true
      $OriginalRecipients[1].Count | Should -Be 4

      Set-iBMCSMTPRecipient $session -MemberId 1 -Enabled $true `
        -EmailAddress 'recipient2@huawei.com' -Description 'R2'

      $UpdatedRecipients = Get-iBMCSMTPRecipients $session
      $UpdatedRecipients[0][1].Enabled | Should -Be $true
      $UpdatedRecipients[0][1].EmailAddress | Should -Be 'recipient2@huawei.com'
      $UpdatedRecipients[0][1].Description | Should -Be 'R2'
      $UpdatedRecipients[1][1].Enabled | Should -Be $true
      $UpdatedRecipients[1][1].EmailAddress | Should -Be 'recipient2@huawei.com'
      $UpdatedRecipients[1][1].Description | Should -Be 'R2'

      $UpdatedRecipients[0][0].Enabled | Should -Be $OriginalRecipients[0][0].Enabled
      $UpdatedRecipients[0][0].EmailAddress | Should -Be $OriginalRecipients[0][0].EmailAddress
      $UpdatedRecipients[0][0].Description | Should -Be $OriginalRecipients[0][0].Description
      $UpdatedRecipients[0][2].Enabled | Should -Be $OriginalRecipients[0][2].Enabled
      $UpdatedRecipients[0][2].EmailAddress | Should -Be $OriginalRecipients[0][2].EmailAddress
      $UpdatedRecipients[0][2].Description | Should -Be $OriginalRecipients[0][2].Description
      $UpdatedRecipients[0][3].Enabled | Should -Be $OriginalRecipients[0][3].Enabled
      $UpdatedRecipients[0][3].EmailAddress | Should -Be $OriginalRecipients[0][3].EmailAddress
      $UpdatedRecipients[0][3].Description | Should -Be $OriginalRecipients[0][3].Description

      $UpdatedRecipients[1][0].Enabled | Should -Be $OriginalRecipients[1][0].Enabled
      $UpdatedRecipients[1][0].EmailAddress | Should -Be $OriginalRecipients[1][0].EmailAddress
      $UpdatedRecipients[1][0].Description | Should -Be $OriginalRecipients[1][0].Description
      $UpdatedRecipients[1][2].Enabled | Should -Be $OriginalRecipients[1][2].Enabled
      $UpdatedRecipients[1][2].EmailAddress | Should -Be $OriginalRecipients[1][2].EmailAddress
      $UpdatedRecipients[1][2].Description | Should -Be $OriginalRecipients[1][2].Description
      $UpdatedRecipients[1][3].Enabled | Should -Be $OriginalRecipients[1][3].Enabled
      $UpdatedRecipients[1][3].EmailAddress | Should -Be $OriginalRecipients[1][3].EmailAddress
      $UpdatedRecipients[1][3].Description | Should -Be $OriginalRecipients[1][3].Description


      Set-iBMCSMTPRecipient $session -MemberId 1 -Enabled @($UpdatedRecipients[0][1].Enabled, $UpdatedRecipients[1][1].Enabled) `
        -EmailAddress @($UpdatedRecipients[0][1].EmailAddress, $UpdatedRecipients[1][1].EmailAddress) `
        -Description @($UpdatedRecipients[0][1].Description, $UpdatedRecipients[1][1].Description)
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  # It "set" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     Set-iBMCSMTPRecipient $session -MemberId 1 -Enabled $true -EmailAddress r2@huawei.com -Description 'R2'
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }
}