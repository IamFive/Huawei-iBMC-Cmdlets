Import-Module Huawei-iBMC-Cmdlets -Force

Describe "Connection Module" {

  It "Multiply Host Connect" {
    try {
      $sessions = Connect-iBMC -Address 112.93.129.9,112.93.129.96 `
        -Username chajian,chajian -Password "chajian12#$","chajian12#$" -TrustCert
      $sessions -is [Array] | Should -Be $true
      $sessions.Count | Should -Be 2
      $sessions.Alive | Should -Be @($true, $true)
    } finally {
        Disconnect-iBMC $sessions
    }
  }

  It "Multiply Host Connect2" {
    try {
      $sessions = Connect-iBMC -Address "112.93.129.9,96" `
        -Username chajian -Password "chajian12#$" -TrustCert
      $sessions -is [Array] | Should -Be $true
      $sessions.Count | Should -Be 2
      $sessions.Alive | Should -Be @($true, $true)
    } finally {
        Disconnect-iBMC $sessions
    }
  }

  It "Serial Host Connect" {
    try {
      $sessions = $null
      $sessions = Connect-iBMC -Address "112.93.129.9-10" `
      -Username chajian -Password "chajian12#$" -TrustCert
      $sessions -is [Array] | Should -Be $true
      $sessions.Count | Should -Be 2

      $sessions[0].Alive | Should -Be $true
      $sessions[0].Address.toString() | Should -Be '112.93.129.9'

      $sessions[1] -is [Exception] | Should -Be $true
    } finally {
        Disconnect-iBMC $sessions[0]
    }
  }


  It "Credential Connect" {
    try {
      $User = "chajian"
      $Pwd = ConvertTo-SecureString -String "chajian12#$" -AsPlainText -Force
      $Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User, $Pwd
      $sessions = Connect-iBMC -Address 112.93.129.9,112.93.129.96 -Credential $Credential -TrustCert
      $sessions -is [Array] | Should -Be $true
      $sessions.Count | Should -Be 2
      $sessions.Alive | Should -Be @($true, $true)
    } finally {
        Disconnect-iBMC $sessions
    }
  }
}
