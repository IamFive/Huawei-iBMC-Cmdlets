Import-Module Huawei-iBMC-Cmdlets -Force

Describe "SNMP-Settings" {
  # It "get" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     Get-iBMCSNMPSetting $session
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }

  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      $pwd = ConvertTo-SecureString -String "pwd12#$%^" -AsPlainText -Force
      $ServerIdentity = ,@('HostName', 'BoardSN')
      Set-iBMCSMTPSetting $session -ServiceEnabled $false -ServerAddress smtp.huawei.com `
          -TLSEnabled $false -AnonymousLoginEnabled $false `
          -SenderUserName 'Huawei-iBMC' -SenderAddress "powershell@huawei.com"  -SenderPassword $pwd `
          -EmailSubject 'iBMC Alarm Notification' -EmailSubjectContains $ServerIdentity `
          -AlarmSeverity Critical
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}


Describe "SNMP-Recipients" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCSMTPRecipients $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCSMTPRecipient $session -MemberId 1 -Enabled $true -EmailAddress r2@huawei.com -Description 'R2'
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}