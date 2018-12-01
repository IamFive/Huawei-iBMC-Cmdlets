Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Syslog-Settings" {

  # It "get" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     Get-iBMCSyslogSetting $session
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert

      $OriginalSetting = Get-iBMCSyslogSetting $session
      $OriginalSetting -is [Array] | Should -Be $true
      $OriginalSetting[0] -is [psobject] | Should -Be $true
      $OriginalSetting[1] -is [psobject] | Should -Be $true

      $Results = Set-iBMCSyslogSetting $session -ServiceEnabled $true -ServerIdentitySource HostName `
        -AlarmSeverity Major -TransmissionProtocol UDP
      $Results | Should -Be @($null, $null)

      $UpdatedSetting = Get-iBMCSyslogSetting $session
      $UpdatedSetting.ServiceEnabled | Should -Be @($true, $true)
      $UpdatedSetting.ServerIdentitySource | Should -Be @('HostName', 'HostName')
      $UpdatedSetting.AlarmSeverity | Should -Be @('Major', 'Major')
      $UpdatedSetting.TransmissionProtocol | Should -Be @('UDP', 'UDP')

      $Results = Set-iBMCSyslogSetting $session `
        -ServiceEnabled @($OriginalSetting[0].ServiceEnabled, $OriginalSetting[1].ServiceEnabled) `
        -ServerIdentitySource @($OriginalSetting[0].ServerIdentitySource, $OriginalSetting[1].ServerIdentitySource) `
        -AlarmSeverity @($OriginalSetting[0].AlarmSeverity, $OriginalSetting[1].AlarmSeverity) `
        -TransmissionProtocol @($OriginalSetting[0].TransmissionProtocol, $OriginalSetting[1].TransmissionProtocol)
      $Results | Should -Be @($null, $null)
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  # It "server" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     $LogType = ,@("OperationLog", "SecurityLog", "EventLog")
  #     Set-ibmcSyslogServer $session -MemberId 1 -Enabled $true -Address 192.168.14.9 `
  #       -Port 515 -LogType $LogType
  #   }
  #   finally {
  #       Disconnect-iBMC $session
  #   }
  # }
}

Describe "Syslog-Servers" {

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert

      $LogType = ,@("OperationLog", "SecurityLog", "EventLog")
      Set-ibmcSyslogServer $session -MemberId 1 -Enabled $true -Address 192.168.14.9 `
        -Port 515 -LogType $LogType

      $OriginalServers = Get-iBMCSyslogServer $session
      $OriginalServers -is [Array] | Should -Be $true
      $OriginalServers[0] -is [Array] | Should -Be $true
      $OriginalServers[0].Count | Should -Be 4
      $OriginalServers[1] -is [Array] | Should -Be $true
      $OriginalServers[1].Count | Should -Be 4

      $LogType = ,@("OperationLog", "SecurityLog", "EventLog")
      Set-ibmcSyslogServer $session -MemberId 1 -Enabled $true -Address 192.168.14.9 `
        -Port 515 -LogType $LogType

      $UpdatedServers =  Get-iBMCSyslogServer $session
      $UpdatedServers[0][1].Enabled | Should -Be $true
      $UpdatedServers[0][1].Address | Should -Be '192.168.14.9'
      $UpdatedServers[0][1].Port | Should -Be 515
      $UpdatedServers[0][1].LogType | Should -Be @("OperationLog", "SecurityLog", "EventLog")

      $UpdatedServers[1][1].Enabled | Should -Be $true
      $UpdatedServers[1][1].Address | Should -Be '192.168.14.9'
      $UpdatedServers[1][1].Port | Should -Be 515
      $UpdatedServers[1][1].LogType | Should -Be @("OperationLog", "SecurityLog", "EventLog")

      $UpdatedServers[0][0].Enabled | Should -Be $OriginalServers[0][0].Enabled
      $UpdatedServers[0][0].Address | Should -Be $OriginalServers[0][0].Address
      $UpdatedServers[0][0].Port | Should -Be $OriginalServers[0][0].Port
      $UpdatedServers[0][0].LogType | Should -Be $OriginalServers[0][0].LogType
      $UpdatedServers[1][0].Enabled | Should -Be $OriginalServers[1][0].Enabled
      $UpdatedServers[1][0].Address | Should -Be $OriginalServers[1][0].Address
      $UpdatedServers[1][0].Port | Should -Be $OriginalServers[1][0].Port
      $UpdatedServers[1][0].LogType | Should -Be $OriginalServers[1][0].LogType

      $UpdatedServers[0][2].Enabled | Should -Be $OriginalServers[0][2].Enabled
      $UpdatedServers[0][2].Address | Should -Be $OriginalServers[0][2].Address
      $UpdatedServers[0][2].Port | Should -Be $OriginalServers[0][2].Port
      $UpdatedServers[0][2].LogType | Should -Be $OriginalServers[0][2].LogType
      $UpdatedServers[1][2].Enabled | Should -Be $OriginalServers[1][2].Enabled
      $UpdatedServers[1][2].Address | Should -Be $OriginalServers[1][2].Address
      $UpdatedServers[1][2].Port | Should -Be $OriginalServers[1][2].Port
      $UpdatedServers[1][2].LogType | Should -Be $OriginalServers[1][2].LogType

      $UpdatedServers[0][3].Enabled | Should -Be $OriginalServers[0][3].Enabled
      $UpdatedServers[0][3].Address | Should -Be $OriginalServers[0][3].Address
      $UpdatedServers[0][3].Port | Should -Be $OriginalServers[0][3].Port
      $UpdatedServers[0][3].LogType | Should -Be $OriginalServers[0][3].LogType
      $UpdatedServers[1][3].Enabled | Should -Be $OriginalServers[1][3].Enabled
      $UpdatedServers[1][3].Address | Should -Be $OriginalServers[1][3].Address
      $UpdatedServers[1][3].Port | Should -Be $OriginalServers[1][3].Port
      $UpdatedServers[1][3].LogType | Should -Be $OriginalServers[1][3].LogType

      Set-ibmcSyslogServer $session -MemberId 1 -Enabled @($OriginalServers[0][1].Enabled, $OriginalServers[1][1].Enabled) `
        -Address @($OriginalServers[0][1].Address, $OriginalServers[1][1].Address) `
        -Port @($OriginalServers[0][1].Port, $OriginalServers[1][1].Port) `
        -LogType @($OriginalServers[0][1].LogType, $OriginalServers[1][1].LogType)
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  # It "server" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     $LogType = ,@("OperationLog", "SecurityLog", "EventLog")
  #     Set-ibmcSyslogServer $session -MemberId 1 -Enabled $true -Address 192.168.14.9 `
  #       -Port 515 -LogType $LogType
  #   }
  #   finally {
  #       Disconnect-iBMC $session
  #   }
  # }
}