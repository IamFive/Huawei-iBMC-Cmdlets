Import-Module Huawei-iBMC-Cmdlets -Force

Describe "SNMP-Settings" {

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $ReadOnlyCommunity = ConvertTo-SecureString -String "chajian@^$(Get-Random -Maximum 1000000)" -AsPlainText -Force
      $ReadWriteCommunity = ConvertTo-SecureString -String "chajian@^$(Get-Random -Maximum 1000000)" -AsPlainText -Force
      $SettingResult = Set-iBMCSNMPSetting $session -SnmpV1Enabled $true -SnmpV2CEnabled $true `
      -LongPasswordEnabled $false -RWCommunityEnabled $true `
      -ReadOnlyCommunity $ReadOnlyCommunity -ReadWriteCommunity $ReadWriteCommunity `
      -SnmpV3AuthProtocol MD5 -SnmpV3PrivProtocol DES

      $SettingResult[1] -is [Exception] | Should -Be $true

      $Settings = Get-iBMCSNMPSetting $session
      $Settings -is [Array] | Should -Be $true
      $Settings.SnmpV1Enabled | Should -Be @($true, $true)
      $Settings.SnmpV2CEnabled | Should -Be @($true, $true)
      $Settings.LongPasswordEnabled | Should -Be @($false, $false)
      $Settings[0].RWCommunityEnabled | Should -Be $true
      $Settings.SnmpV3AuthProtocol | Should -Be @('MD5', 'MD5')
      $Settings.SnmpV3PrivProtocol | Should -Be @('DES', 'DES')
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}


Describe "SNMP-Trap-Settings" {
  # It "get" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     Get-iBMCSNMPTrapSetting $session
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert
      $CommunityName = ConvertTo-SecureString -String "SomeP@ssw0rd$(Get-Random -Maximum 1000000)" -AsPlainText -Force
      Set-iBMCSNMPTrapSetting -Session $session -ServiceEnabled $true -TrapVersion V2C `
        -TrapV3User chajian -TrapMode EventCode -TrapServerIdentity BoardSN `
        -CommunityName $CommunityName -AlarmSeverity Critical

      $TrapSetting = Get-iBMCSNMPTrapSetting $session

      $TrapSetting -is [Array] | Should -Be $true
      $TrapSetting.ServiceEnabled | Should -Be @($true, $true)
      $TrapSetting.TrapVersion | Should -Be @('V2C', 'V2C')
      $TrapSetting.TrapV3User | Should -Be @('chajian', 'chajian')
      $TrapSetting.TrapMode | Should -Be @('EventCode', 'EventCode')
      $TrapSetting.TrapServerIdentity | Should -Be @('BoardSN', 'BoardSN')
      $TrapSetting.AlarmSeverity | Should -Be @('Critical', 'Critical')
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}


Describe "SNMP-Trap-Server" {
  # It "get" {
  #   try {
  #     $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
  #     Get-iBMCSNMPTrapServer $session
  #   }
  #   finally {
  #     Disconnect-iBMC $session
  #   }
  # }

  It "workflow" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Username chajian -Password "chajian12#$" -TrustCert

      $OriginalTrapServers = Get-iBMCSNMPTrapServer $session
      $OriginalTrapServers -is [Array] | Should -Be $true
      $OriginalTrapServers[0] -is [Array] | Should -Be $true
      $OriginalTrapServers[0].Count | Should -Be 4
      $OriginalTrapServers[1] -is [Array] | Should -Be $true
      $OriginalTrapServers[1].Count | Should -Be 4

      Set-iBMCSNMPTrapServer $session -MemberId 1 -Enabled $true -TrapServerAddress 192.168.2.10

      $UpdatedTrapServers = Get-iBMCSNMPTrapServer $session
      $UpdatedTrapServers[0][1].Enabled | Should -Be $true
      $UpdatedTrapServers[0][1].TrapServerAddress | Should -Be '192.168.2.10'
      $UpdatedTrapServers[1][1].Enabled | Should -Be $true
      $UpdatedTrapServers[1][1].TrapServerAddress | Should -Be '192.168.2.10'

      $UpdatedTrapServers[0][0].Enabled | Should -Be $OriginalTrapServers[0][0].Enabled
      $UpdatedTrapServers[0][0].TrapServerAddress | Should -Be $OriginalTrapServers[0][0].TrapServerAddress
      $UpdatedTrapServers[0][2].Enabled | Should -Be $OriginalTrapServers[0][2].Enabled
      $UpdatedTrapServers[0][2].TrapServerAddress | Should -Be $OriginalTrapServers[0][2].TrapServerAddress
      $UpdatedTrapServers[0][3].Enabled | Should -Be $OriginalTrapServers[0][3].Enabled
      $UpdatedTrapServers[0][3].TrapServerAddress | Should -Be $OriginalTrapServers[0][3].TrapServerAddress

      $UpdatedTrapServers[1][0].Enabled | Should -Be $OriginalTrapServers[1][0].Enabled
      $UpdatedTrapServers[1][0].TrapServerAddress | Should -Be $OriginalTrapServers[1][0].TrapServerAddress
      $UpdatedTrapServers[1][0].Description | Should -Be $OriginalTrapServers[1][0].Description
      $UpdatedTrapServers[1][2].Enabled | Should -Be $OriginalTrapServers[1][2].Enabled
      $UpdatedTrapServers[1][2].TrapServerAddress | Should -Be $OriginalTrapServers[1][2].TrapServerAddress
      $UpdatedTrapServers[1][2].Description | Should -Be $OriginalTrapServers[1][2].Description
      $UpdatedTrapServers[1][3].Enabled | Should -Be $OriginalTrapServers[1][3].Enabled
      $UpdatedTrapServers[1][3].TrapServerAddress | Should -Be $OriginalTrapServers[1][3].TrapServerAddress
      $UpdatedTrapServers[1][3].Description | Should -Be $OriginalTrapServers[1][3].Description

      Set-iBMCSNMPTrapServer $session -MemberId 1 -Enabled @($OriginalTrapServers[0][1].Enabled, $OriginalTrapServers[1][1].Enabled) `
        -TrapServerAddress @($OriginalTrapServers[0][1].TrapServerAddress, $OriginalTrapServers[1][1].TrapServerAddress)
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}