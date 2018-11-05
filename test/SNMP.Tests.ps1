Import-Module Huawei-iBMC-Cmdlets -Force

Describe "SNMP-Settings" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCSNMPSetting $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCSNMPSetting $session -SnmpV1Enabled $false -SnmpV2CEnabled $false `
        -LongPasswordEnabled $true -RWCommunityEnabled $true `
        -ReadOnlyCommunity 'chajian12#$' -ReadWriteCommunity 'chajian12#$' `
        -SnmpV3AuthProtocol MD5 -SnmpV3PrivProtocol DES
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}


Describe "SNMP-Trap-Settings" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCSNMPTrapSetting $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCSNMPTrapSetting -Session $session -ServiceEnabled $true -TrapVersion V2C `
        -TrapV3User chajian -TrapMode EventCode -TrapServerIdentity BoardSN `
        -CommunityName "Chajian12#$" -AlarmSeverity Critical
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}


Describe "SNMP-Trap-Server" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCSNMPTrapServer $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCSNMPTrapServer $session -MemberId 1 -Enabled $true -TrapServerAddress 192.168.2.8
    }
    finally {
      Disconnect-iBMC $session
    }
  }
}