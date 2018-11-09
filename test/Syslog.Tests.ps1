Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Service" {
  It "get" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Get-iBMCSyslogSetting $session
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "set" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      Set-iBMCSyslogSetting $session -ServiceEnabled $true -ServerIdentitySource HostName `
        -AlarmSeverity Major -TransmissionProtocol UDP
    }
    finally {
      Disconnect-iBMC $session
    }
  }

  It "server" {
    try {
      $session = Connect-iBMC -Address 112.93.129.9 -Username chajian -Password "chajian12#$" -TrustCert
      $LogType = ,@("OperationLog", "SecurityLog", "EventLog")
      Set-ibmcSyslogServer $session -MemberId 1 -Enabled $true -Address 192.168.14.9 `
        -Port 515 -LogType $LogType
    }
    finally {
        Disconnect-iBMC $session
    }
  }
}